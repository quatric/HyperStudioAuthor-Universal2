#import "HSMediaLoader.h"
@implementation HSMediaLoader
// Medias copied to the pasteboard: one property list per media under the type
// <mediaInfoPasteboardTypePrefix><UID>. Medias already known by their UID are
// skipped; the others are made from the stored data (with no UID when the type
// doesn't carry a valid one).
+ (id)forceLoadMediasFromPasteboard:(id)aPasteboard
{
    NSMutableArray *medias = [NSMutableArray array];
    NSEnumerator *types = [[aPasteboard types] objectEnumerator];
    NSString *type;
    while ((type = [types nextObject]) != nil) {
        if (![type hasPrefix:[HSPasteboardDataProvider mediaInfoPasteboardTypePrefix]])
            continue;
        NSUInteger prefixLength = [[HSPasteboardDataProvider mediaInfoPasteboardTypePrefix] length];
        id uid = nil;
        if ([type length] > prefixLength) {
            NSString *uidString = [type substringFromIndex:prefixLength];
            if (uidString != nil) {
                uid = [HSUID UIDWithString:uidString];
                if (uid != nil && [[HSNewMediaAccessor sharedMediaAccessor] mediaForUID:uid] != nil)
                    continue;
            }
        }
        NSDictionary *info = [aPasteboard propertyListForType:type];
        if (info == nil)
            continue;
        HSMediaDataRepresentation *representation = [[HSMediaDataRepresentation alloc]
            initWithData:[info objectForKey:@"mediaData"] mediaType:[info objectForKey:@"mediaType"]];
        HSNewMedia *media = [[HSNewMedia alloc] initWithMediaUID:uid representation:representation name:[info objectForKey:@"mediaName"]];
        [medias addObject:media];
        [media release];
        [representation release];
    }
    return medias;
}
+ (id)loadResourcesWrapper:(id)aWrapper resourcesFolderPath:(id)aPath
{
    return [self loadResourcesWrapper:aWrapper resourcesFolderPath:aPath loadUIDs:YES];
}
// Original quirk kept: aDs is ignored here, UIDs are always loaded.
+ (id)loadResourcesWrapper:(id)aWrapper resourcesFolderPath:(id)aPath loadUIDs:(BOOL)aDs
{
    return [self loadResourcesWrapper:aWrapper resourcesFolderPath:aPath loadUIDs:YES filenamesMapping:nil];
}
// The medias of a stack's resources: every regular file in the MediaAccessor
// folder is a media description (uid, mediaPath, mediaName, mediaType); the
// media file itself is in the resources folder, under its stored name or the
// name aMapping gives it. With aDs the stored UIDs are kept (an already loaded
// media is reused); otherwise each media gets a new UID.
+ (id)loadResourcesWrapper:(id)aWrapper resourcesFolderPath:(id)aPath loadUIDs:(BOOL)aDs filenamesMapping:(id)aMapping
{
    NSMutableArray *medias = [NSMutableArray array];
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    NSEnumerator *descriptions = [[[[[aWrapper fileWrappers] objectForKey:@"MediaAccessor"] fileWrappers] allValues] objectEnumerator];
    NSFileWrapper *descriptionWrapper;
    while ((descriptionWrapper = [descriptions nextObject]) != nil) {
        NSAutoreleasePool *mediaPool = [NSAutoreleasePool new];
        id media = nil;
        NSDictionary *description = [descriptionWrapper isRegularFile] ? [descriptionWrapper hyperDictionaryRepresentation] : nil;
        id storedUID = [description objectForKey:@"uid"];
        id uid = nil;
        if (storedUID != nil)
            uid = aDs ? [HSUID objectWithExtraDictionary:storedUID] : [HSUID UID];
        if (uid != nil) {
            if (aDs)
                media = [[[HSNewMediaAccessor sharedMediaAccessor] mediaForUID:uid] retain];
            if (media == nil)
                media = [self HSMediaLoader_newMediaWithUID:uid description:description resourcesWrapper:aWrapper filenamesMapping:aMapping];
        }
        if (media != nil) {
            [medias addObject:media];
            [media release];
        }
        [mediaPool release];
    }
    [pool release];
    return medias;
}
// Part of the method above: a new (+1) media from its description, nil when the
// file can't be found or read.
+ (id)HSMediaLoader_newMediaWithUID:(id)aUID description:(NSDictionary *)aDescription resourcesWrapper:(id)aWrapper filenamesMapping:(id)aMapping
{
    NSString *mediaPath = [aDescription objectForKey:@"mediaPath"];
    NSString *filename = [mediaPath lastPathComponent];
    if (mediaPath == nil || filename == nil)
        return nil;
    NSFileWrapper *file = [[aWrapper fileWrappers] objectForKey:filename];
    if (file == nil) {
        file = [[aWrapper fileWrappers] objectForKey:[aMapping objectForKey:filename]];
        if (file == nil)
            return nil;
    }
    NSString *name = [aDescription objectForKey:@"mediaName"];
    if (name == nil)
        name = filename;
    id representation = nil;
    NSString *contentPath = [file hyperContentFilePath];
    if (contentPath != nil && [[NSFileManager defaultManager] hyperIsFileReadableAtPath:contentPath])
        representation = [[HSMediaFileRepresentation alloc] initWithPath:contentPath];
    else {
        NSData *data = [self dataFromFileWrapper:file];
        if (data == nil)
            return nil;
        NSString *mediaType = [aDescription objectForKey:@"mediaType"];
        if (mediaType == nil)
            mediaType = [mediaPath pathExtension];
        representation = [[HSMediaDataRepresentation alloc] initWithData:data mediaType:mediaType];
    }
    if (representation == nil)
        return nil;
    id media = [[HSNewMedia alloc] initWithMediaUID:aUID representation:representation name:name];
    [representation release];
    return media;
}
+ (id)dataFromFileWrapper:(id)aWrapper
{
    return [aWrapper regularFileContents];
}
@end
