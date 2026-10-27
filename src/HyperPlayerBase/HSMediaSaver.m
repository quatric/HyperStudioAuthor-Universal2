#import "HSMediaSaver.h"
@implementation HSMediaSaver
// The movie in aData flattened into a temporary .mov file (nil on failure).
+ (id)pathToFlattenMediaForData:(id)aData
{
    NSDictionary *attributes = [[NSDictionary alloc] initWithObjectsAndKeys:
        aData, QTMovieDataAttribute,
        (id)kCFBooleanFalse, QTMovieResolveDataRefsAttribute,
        nil];
    if (attributes == nil)
        return nil;
    QTMovie *movie = [[QTMovie alloc] initWithAttributes:attributes error:NULL];
    [attributes release];
    if (movie == nil)
        return nil;
    NSString *path = [HSTemporaryFilesManager generatedTempFilePathWithExtension:@"mov"];
    if (path != nil
        && ![movie writeToFile:path withAttributes:[NSDictionary dictionaryWithObject:(id)kCFBooleanTrue forKey:QTMovieFlatten]])
        path = nil;
    [movie release];
    return path;
}
// The movie file at aPath flattened into a temporary file with the same
// extension. The original opened it as a QuickTime Movie (+movieAtPath:,
// without resolving data references); QTMovie (HSQTKit) opens the file directly.
+ (id)pathToFlattenMediaAtPath:(id)aPath
{
    QTMovie *movie = [QTMovie movieWithFile:aPath error:NULL];
    if (movie == nil)
        return nil;
    NSString *path = [HSTemporaryFilesManager generatedTempFilePathWithExtension:[[aPath lastPathComponent] pathExtension]];
    NSDictionary *attributes = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:QTMovieFlatten];
    return [movie writeToFile:path withAttributes:attributes] ? path : nil;
}
// QuickTime Movies no longer exist (the original opened the file with
// NewMovieFromProperties, not resolving data references and not interacting
// with the user); nothing can be returned.
+ (struct MovieType **)movieAtPath:(id)aPath
{
    return NULL;
}
// Writes the document's medias into aWrapper: each media file the stack's
// objects own (named after the media, with an extension from MediaTypes.plist
// when it has none), plus a description property list per media in the
// MediaAccessor folder (with the auxiliary data file when the media keeps one).
// The medias' storage retain counts are recounted from the objects first.
+ (BOOL)saveMediaForDocument:(id)aDocument resourcesWrapper:(id)aWrapper
{
    NSMutableSet *uids = [NSMutableSet set];
    if (uids == nil)
        return NO;
    [[HSNewMediaAccessor sharedMediaAccessor] resetAllStorageRetains];
    NSEnumerator *objects = [[aDocument stack] hyperDeepEnumerator];
    id object;
    while ((object = [objects nextObject]) != nil) {
        NSCountedSet *owned = [[object queryHyperInterface:@protocol(HSMediaCopySupport)] ownedMediaUIDs];
        if (owned == nil)
            continue;
        [uids unionSet:owned];
        NSEnumerator *ownedUIDs = [owned objectEnumerator];
        id uid;
        while ((uid = [ownedUIDs nextObject]) != nil)
            [(id)[[HSNewMediaAccessor sharedMediaAccessor] mediaForUID:uid] incrementStorageRetainCountBy:[owned countForObject:uid]];
    }
    NSFileWrapper *descriptionsWrapper = [[aWrapper fileWrappers] objectForKey:@"MediaAccessor"];
    NSEnumerator *enumerator = [uids objectEnumerator];
    if (descriptionsWrapper == nil) {
        descriptionsWrapper = [[NSFileWrapper allocWithZone:[self zone]] initDirectoryWithFileWrappers:[NSDictionary dictionary]];
        if (descriptionsWrapper == nil)
            return NO;
        [descriptionsWrapper setPreferredFilename:@"MediaAccessor"];
        [aWrapper addFileWrapper:descriptionsWrapper];
        [descriptionsWrapper release];
    }
    NSAutoreleasePool *pool = nil;
    NSDictionary *mediaTypes = nil;
    id uid;
    while ((uid = [enumerator nextObject]) != nil) {
        [pool release];
        pool = [NSAutoreleasePool new];
        id media = [[HSNewMediaAccessor sharedMediaAccessor] mediaForUID:uid];
        NSFileWrapper *mediaWrapper = [media fileWrapper];
        if (mediaWrapper == nil)
            break;
        if ([aWrapper keyForFileWrapper:mediaWrapper] == nil) {
            NSString *filename = [[media mediaName] lowercaseString];
            if ([filename length] == 0)
                filename = @"media";
            if ([[filename pathExtension] length] == 0) {
                NSString *mediaType = [media mediaType];
                if (mediaTypes == nil)
                    mediaTypes = [[HSPlayerBaseID extraDictionaryNamed:@"MediaTypes.plist"] retain];
                NSString *extension = [mediaTypes objectForKey:mediaType];
                filename = [filename stringByAppendingPathExtension:[extension length] != 0 ? extension : mediaType];
            }
            if (filename == nil)
                break;
            [mediaWrapper setPreferredFilename:filename];
            [aWrapper addFileWrapper:mediaWrapper];
        }
        NSMutableDictionary *description = [[[media extraDictionaryRepresentation] mutableCopy] autorelease];
        NSString *key = description != nil ? [aWrapper keyForFileWrapper:mediaWrapper] : nil;
        if (key == nil)
            break;
        [description setObject:key forKey:@"mediaPath"];
        if ([media shouldStoreAuxiliaryMediaData]) {
            id auxiliaryType = [media auxiliaryMediaType];
            NSData *auxiliaryData = auxiliaryType != nil ? [media auxiliaryMediaData] : nil;
            NSString *auxiliaryName = auxiliaryData != nil ? [[media auxiliaryPreferedFilenameForName:key] lowercaseString] : nil;
            NSString *auxiliaryKey = auxiliaryName != nil
                ? [aWrapper addRegularFileWithContents:auxiliaryData preferredFilename:auxiliaryName] : nil;
            if (auxiliaryKey != nil) {
                [description setObject:auxiliaryKey forKey:@"auxiliaryMediaPath"];
                [description setObject:auxiliaryType forKey:@"auxiliaryMediaType"];
            }
        }
        NSString *descriptionName = [key stringByAppendingPathExtension:@"plist"];
        if (descriptionName == nil)
            break;
        NSFileWrapper *descriptionWrapper = [[[NSFileWrapper alloc] initWithHyperDictionary:description] autorelease];
        if (descriptionWrapper == nil)
            break;
        [descriptionWrapper setPreferredFilename:descriptionName];
        [descriptionsWrapper addFileWrapper:descriptionWrapper];
    }
    [pool release];
    [mediaTypes release];
    // Every media was written unless the loop stopped early.
    return uid == nil;
}
@end
@implementation HSNewMediaAccessor (OldFormatEx)
- (void)resetAllStorageRetains
{
    if (_mediaMap != nil)
        [NSAllMapTableValues(_mediaMap) makeObjectsPerformSelector:@selector(resetStorageRetainCount)];
}
@end
