#import "HSMediaFileWrapper.h"
#import <zlib.h>
#import "HSDocumentStoring.h"
#import "HSExecutableResourceProvider.h"
#import "HSImageMediaRepresentation.h"
#import "HSMediaDataRepresentation.h"
#import "HSMediaFileRepresentation.h"
#import "HSMediaSaver.h"
#import "HSMediaWrapper.h"
#import "HSMovie.h"
#import "HSNewMedia+DataHelpers.h"
#import "HSNewMediaAccessor.h"
#import "HSPathsProvider.h"
#import "HSPlayerBaseID.h"
#import "HSTemporaryFilesManager.h"
#import "HSUID.h"
#import "NSFileManager+HSExtensions.h"
#import "NSMutableArray+EXMutableArray.h"
#import "NSString+EXMacTypes.h"

static NSString * const HSLibraryReusableMediaPboardType = @"HSLibraryReusableMediaPboardType";
static NSString * const HSLibraryReusableMediaGlobalUIDKey = @"HSLibraryReusableMediaGlobalUIDKey";
static NSString * const HSLibraryReusableMediaPathKey = @"HSLibraryReusableMediaPathKey";

static NSArray *HSNewMediaCrossplatformTypes = nil;
static NSDictionary *HSNewMediaTypesByGroups = nil;

// File wrapper that writes a media's data when the document is saved.
@implementation HSMediaFileWrapper
- (BOOL)writeToFile:(id)aFile atomically:(BOOL)aAtomically updateFilenames:(BOOL)aFilenames
{
    return [[_media mediaData] writeToFile:aFile atomically:aAtomically];
}
- (NSInteger)writeToStream:(id)aStream retrying:(BOOL)aRetrying CRC32:(unsigned int *)a32 writtenLength:(unsigned int *)aLength error:(id *)aError
{
    return [_media writeToStream:aStream retrying:aRetrying CRC32:a32 writtenLength:aLength error:aError];
}
- (id)regularFileContents
{
    return [_media mediaData];
}
- (void)dealloc
{
    [_media release];
    [super dealloc];
}
- (id)initWithMedia:(id)aMedia
{
    self = [super init];
    if (self)
        _media = [aMedia retain];
    return self;
}
@end

// A media item (image, sound or movie) with one or more representations:
// a file, in-memory data or an image. Media register with the shared
// HSNewMediaAccessor under their UID.
@implementation HSNewMedia
+ (id)crossplatformCompatibleMediaTypes
{
    if (HSNewMediaCrossplatformTypes == nil)
        HSNewMediaCrossplatformTypes = [[NSArray alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"CrossMediaTypes" ofType:@"plist"]];
    return HSNewMediaCrossplatformTypes;
}
+ (id)filteredTypeForFileType:(id)aType
{
    if ([aType isEqualToString:NSTIFFPboardType])
        return @"tiff";
    if ([aType isEqualToString:HSPNGFileType])
        return @"png";
    return aType;
}
+ (id)uniqueTempPathWithExtension:(id)aExtension baseName:(id)aName
{
    NSString *baseName = aName;
    if ([aName length] == 0)
        baseName = @"media";
    else if ([aName length] > 31)
        baseName = [aName substringToIndex:31];
    NSString *folder = [[HSPathsProvider sharedPathsProvider] temporaryFolder];
    // Control characters, '.', '/' and non-ASCII bytes become spaces.
    char *prefix = strdup([baseName fileSystemRepresentation]);
    for (size_t i = 0; i < strlen(prefix); i++) {
        unsigned char c = (unsigned char)prefix[i];
        if (c < 0x20 || c == '.' || c >= 0x80 || c == '/')
            prefix[i] = ' ';
    }
    // tempnam() is deprecated; this builds the same folder/prefixXXXXXX name.
    static const char letters[] = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    char suffix[7];
    for (int i = 0; i < 6; i++)
        suffix[i] = letters[arc4random_uniform(sizeof(letters) - 1)];
    suffix[6] = 0;
    NSString *path = [NSString stringWithFormat:@"%@/%s%s", folder, prefix, suffix];
    free(prefix);
    NSString *extension = [aExtension length] ? aExtension : @"mov";
    return [NSString extraCreateUniqueFilename:[path stringByStandardizingPath] extension:extension];
}
+ (NSInteger)mediaGroupForMediaType:(id)aType
{
    id group = [[[self mediaTypesByGroups] objectForKey:aType] extraFirstObject];
    return group ? [group integerValue] : 0;
}
+ (id)mediaTypesByGroups
{
    if (HSNewMediaTypesByGroups == nil)
        HSNewMediaTypesByGroups = [[HSPlayerBaseID extraDictionaryNamed:@"MediaTypesByGroups"] retain];
    return HSNewMediaTypesByGroups;
}
+ (id)extraClassNameForStoring
{
    return NSStringFromClass([HSMediaWrapper class]);
}
// Media from a library drag (by UID, else by path of the right group), a file
// URL or a QuickTime movie; nil unless it belongs to aGroup.
+ (id)mediaWithPasteboard:(id)aPasteboard mediaGroup:(NSInteger)aGroup
{
    NSArray *types = [NSArray arrayWithObjects:HSLibraryReusableMediaPboardType, NSURLPboardType, QTMoviePasteboardType, nil];
    NSString *type = [aPasteboard availableTypeFromArray:types];
    HSNewMedia *media = nil;
    if ([type isEqualToString:HSLibraryReusableMediaPboardType]) {
        for (NSDictionary *item in [aPasteboard propertyListForType:HSLibraryReusableMediaPboardType]) {
            NSString *uidString = [item objectForKey:HSLibraryReusableMediaGlobalUIDKey];
            HSUID *uid = uidString ? [HSUID UIDWithString:uidString] : nil;
            if (uid) {
                HSNewMedia *existing = [[HSNewMediaAccessor sharedMediaAccessor] mediaForUID:uid];
                media = [existing mediaGroup] == aGroup ? existing : nil;
                if (media == nil && existing == nil) {
                    NSString *path = [item objectForKey:HSLibraryReusableMediaPathKey];
                    if (path == nil)
                        continue;
                    NSString *fileType = [[NSFileManager defaultManager] hyperFileTypeAtPath:path];
                    if (fileType && [HSNewMedia mediaGroupForMediaType:fileType] == aGroup)
                        media = [HSNewMedia mediaWithPath:path mediaUID:uid];
                }
            }
            if (media)
                break;
        }
    } else if ([type isEqualToString:NSURLPboardType]) {
        NSURL *url = [NSURL URLFromPasteboard:aPasteboard];
        if ([url isFileURL] && [url path]) {
            NSString *fileType = [[NSFileManager defaultManager] hyperFileTypeAtPath:[url path]];
            if (fileType && [HSNewMedia mediaGroupForMediaType:fileType] == aGroup)
                media = [HSNewMedia mediaWithPath:[url path]];
        }
    } else if ([type isEqualToString:QTMoviePasteboardType]) {
        // The AppKit 1038 (10.6) check is always true now.
        if ([aPasteboard canReadItemWithDataConformingToTypes:[NSArray arrayWithObjects:QTMoviePasteboardType, nil]]) {
            QTMovie *movie = [QTMovie movieWithPasteboard:aPasteboard error:NULL];
            if (movie)
                media = [self mediaWithQTMovie:movie name:[[movie movieAttributes] objectForKey:QTMovieDisplayNameAttribute] type:@"mov"];
        }
    }
    return [media mediaGroup] == aGroup ? media : nil;
}
+ (BOOL)canInitMediaWithPasteboard:(id)aPasteboard mediaGroup:(NSInteger)aGroup
{
    NSArray *types = [NSArray arrayWithObjects:HSLibraryReusableMediaPboardType, NSURLPboardType, QTMoviePasteboardType, nil];
    NSString *type = [aPasteboard availableTypeFromArray:types];
    if ([type isEqualToString:HSLibraryReusableMediaPboardType]) {
        for (NSDictionary *item in [aPasteboard propertyListForType:HSLibraryReusableMediaPboardType]) {
            NSString *uidString = [item objectForKey:HSLibraryReusableMediaGlobalUIDKey];
            HSUID *uid = uidString ? [HSUID UIDWithString:uidString] : nil;
            if (uid) {
                HSNewMedia *existing = [[HSNewMediaAccessor sharedMediaAccessor] mediaForUID:uid];
                if ([existing mediaGroup] == aGroup)
                    return YES;
                if (existing)
                    continue;
            }
            NSString *path = [item objectForKey:HSLibraryReusableMediaPathKey];
            if (path) {
                NSString *fileType = [[NSFileManager defaultManager] hyperFileTypeAtPath:path];
                if (fileType && [HSNewMedia mediaGroupForMediaType:fileType] == aGroup)
                    return YES;
            }
        }
        return NO;
    }
    if ([type isEqualToString:NSURLPboardType]) {
        NSURL *url = [NSURL URLFromPasteboard:aPasteboard];
        NSString *path = [url path];
        if (![url isFileURL] || path == nil)
            return NO;
        NSString *fileType = [[path pathExtension] lowercaseString];
        if (fileType == nil)
            fileType = [[NSFileManager defaultManager] hyperFileTypeAtPath:path];
        if (fileType && [[HSNewMediaAccessor supportedMediaTypes] containsObject:fileType])
            return [HSNewMedia mediaGroupForMediaType:fileType] == aGroup;
        return NO;
    }
    if ([type isEqualToString:QTMoviePasteboardType])
        return [aPasteboard canReadItemWithDataConformingToTypes:[NSArray arrayWithObjects:QTMoviePasteboardType, nil]];
    return NO;
}
+ (id)mediaWithQTMovie:(id)aMovie name:(id)aName type:(id)aType
{
    NSString *path = [HSTemporaryFilesManager generatedTempFilePathWithExtension:aType];
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], QTMovieFlatten, nil];
    if (![aMovie writeToFile:path withAttributes:attributes error:NULL])
        return nil;
    return [HSNewMedia mediaWithPath:path name:aName removeWhenDone:YES];
}
+ (id)mediaWithImage:(id)aImage
{
    HSImageMediaRepresentation *representation = [[HSImageMediaRepresentation alloc] initWithImage:aImage];
    NSString *name = [(NSImage *)aImage name];
    HSNewMedia *media = [[[HSNewMedia alloc] initWithMediaUID:nil representation:representation name:name ? name : @"image"] autorelease];
    [representation release];
    return media;
}
+ (id)mediaWithImage:(id)aImage name:(id)aName
{
    HSImageMediaRepresentation *representation = [[[HSImageMediaRepresentation alloc] initWithImage:aImage] autorelease];
    return [[[HSNewMedia alloc] initWithMediaUID:nil representation:representation name:[aName length] ? aName : @"image"] autorelease];
}
+ (id)mediaWithMedia:(id)aMedia type:(id)aType
{
    return [[[self alloc] initWithMedia:aMedia type:aType] autorelease];
}
+ (id)mediaWithPath:(id)aPath
{
    return [[[self alloc] initWithPath:aPath] autorelease];
}
+ (id)mediaWithPath:(id)aPath mediaUID:(id)aUID
{
    return [[[self alloc] initWithPath:aPath mediaUID:aUID] autorelease];
}
+ (id)mediaWithPath:(id)aPath removeWhenDone:(BOOL)aDone
{
    return [[[self alloc] initWithPath:aPath removeWhenDone:aDone] autorelease];
}
+ (id)mediaWithPath:(id)aPath name:(id)aName
{
    return [[[self alloc] initWithPath:aPath name:aName] autorelease];
}
+ (id)mediaWithPath:(id)aPath name:(id)aName removeWhenDone:(BOOL)aDone
{
    return [[[self alloc] initWithPath:aPath name:aName removeWhenDone:aDone] autorelease];
}
+ (id)mediaWithPath:(id)aPath name:(id)aName removeWhenDone:(BOOL)aDone mediaUID:(id)aUID
{
    return [[[self alloc] initWithPath:aPath name:aName removeWhenDone:aDone mediaUID:aUID] autorelease];
}
+ (id)mediaWithData:(id)aData name:(id)aName type:(id)aType
{
    return [[[self alloc] initWithData:aData name:aName type:aType] autorelease];
}
- (id)debugDescription
{
    return [NSString stringWithFormat:@"%@ %@", [self description], [self representations]];
}
- (id)auxiliaryPreferedFilenameForName:(id)aName
{
    return [[aName stringByDeletingPathExtension] stringByAppendingPathExtension:@"png"];
}
- (id)auxiliaryMediaType
{
    return @"png";
}
- (id)auxiliaryMediaData
{
    return [self imagePNGRepresentation];
}
// Images in types other platforms can't read also store a PNG copy.
- (BOOL)shouldStoreAuxiliaryMediaData
{
    NSString *type = [[[self class] filteredTypeForFileType:[self mediaType]] lowercaseString];
    if ([[[self class] crossplatformCompatibleMediaTypes] containsObject:type])
        return NO;
    return [self image] != nil;
}
- (id)GPSDictionary
{
    for (id representation in _representations) {
        NSDictionary *dictionary = [representation GPSDictionary];
        if (dictionary)
            return dictionary;
    }
    return nil;
}
- (id)fullPathToMediaFile
{
    return [self fullPathToMediaFileCreateIfNeeded:NO];
}
// Media without a file can write their data to a temporary file.
- (id)fullPathToMediaFileCreateIfNeeded:(BOOL)aNeeded
{
    NSString *path = [[self fileRepresentation] resolvedPath];
    if (path == nil && aNeeded) {
        NSString *type = [HSNewMedia filteredTypeForFileType:[self mediaType]];
        NSUInteger code = [type extraFourCharCode];
        if (code && [type hasPrefix:@"'"])
            type = [HSNewMediaAccessor extensionForHFSType:[NSNumber numberWithUnsignedLong:code]];
        NSString *tempPath = [HSTemporaryFilesManager generatedTempFilePathWithExtension:type];
        if ([[self mediaData] writeToFile:tempPath atomically:YES]) {
            HSMediaFileRepresentation *representation = [[HSMediaFileRepresentation alloc] initWithPath:tempPath removeWhenDone:YES];
            [[self representations] addObject:representation];
            [representation release];
            path = tempPath;
        }
    }
    return path;
}
- (NSInteger)mediaGroupForMediaAtPath:(id)aPath
{
    if (aPath == nil)
        return 0;
    NSArray *groups = [self mediaTypesFromDictionary:[[self class] mediaTypesByGroups] forFileType:[self mediaType]];
    NSInteger group = 0;
    NSEnumerator *enumerator = [groups objectEnumerator];
    id candidate;
    while ((candidate = [enumerator nextObject]) && group == 0) {
        if ([self canUseMediaFromPath:aPath forMediaType:[candidate intValue]])
            group = [candidate intValue];
    }
    return group;
}
- (id)mediaTypesFromDictionary:(id)aDictionary forFileType:(id)aType
{
    NSMutableArray *groups = [NSMutableArray array];
    NSEnumerator *enumerator = [aDictionary keyEnumerator];
    NSString *key;
    while ((key = [enumerator nextObject]) && [groups count] == 0) {
        if ([key isEqualToString:aType])
            [groups addObjectsFromArray:[aDictionary objectForKey:key]];
    }
    return groups;
}
// Groups: 1 video, 2 sound, 3 image.
- (BOOL)canUseMediaFromPath:(id)aPath forMediaType:(NSInteger)aType
{
    switch (aType) {
        case 1:
            return [HSMovie canInitAsVideoWithURL:[NSURL fileURLWithPath:aPath] error:NULL];
        case 2: {
            HSMovie *movie = [[[HSMovie alloc] initWithURL:[NSURL fileURLWithPath:aPath] error:NULL] autorelease];
            if (movie && [movie isSound])
                return YES;
            // Original quirk: otherwise a file counts as sound when it has a
            // protected movie track.
            return [HSMovie hasProtectedMovieTrackAtMovieWithURL:[NSURL fileURLWithPath:aPath] error:NULL];
        }
        case 3:
            return [[[NSImage alloc] initWithContentsOfFile:aPath] autorelease] != nil;
    }
    return NO;
}
- (id)dictionaryRepresentation
{
    return [NSDictionary dictionaryWithObjectsAndKeys:[self mediaType], @"mediaType", [self mediaName], @"mediaName", [self mediaData], @"mediaData", nil];
}
- (id)extraClassNameForStoring
{
    return NSStringFromClass([HSMediaWrapper class]);
}
// Writes the media into a document stream. File representations are written
// directly when self-contained, else flattened by HSMediaSaver first; data
// representations go through QuickTime for movies. When nothing could be
// read the user may locate the file (result 2) or cancel.
- (NSInteger)writeToStream:(id)aStream retrying:(BOOL)aRetrying CRC32:(unsigned int *)a32 writtenLength:(unsigned int *)aLength error:(id *)aError
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    BOOL failedToRead = NO;
    BOOL failedToWrite = NO;
    if (aError)
        *aError = nil;
    NSMutableArray *filePaths = nil;
    NSMutableArray *flattenPaths = nil;
    NSMutableArray *otherRepresentations = nil;
    NSData *movieData = nil;
    NSData *flattenData = nil;
    NSString *pathToRemove = nil;
    NSInteger result = 0;
    NSUInteger count = [_representations count];
    for (NSUInteger i = 0; i < count; i++) {
        id representation = [_representations objectAtIndex:i];
        if ([representation isKindOfClass:[HSMediaFileRepresentation class]]) {
            if (![representation isValid])
                continue;
            NSString *path = [representation resolvedPath];
            if (path == nil)
                continue;
            NSMutableArray **list;
            if ([[NSFileManager defaultManager] resourceTypesCountAtPath:path] > 0 && ![[path pathExtension] isEqualToString:@"dv"]) {
                list = &flattenPaths;
            } else if ([self mediaGroup] != 1) {
                list = &filePaths;
            } else {
                HSMovie *movie = [[HSMovie alloc] initWithURL:[NSURL fileURLWithPath:path] error:NULL];
                if (movie == nil)
                    continue;
                list = ([movie isAnimatedGifMovie] || [movie isMovieSelfContained]) ? &filePaths : &flattenPaths;
                [movie release];
            }
            if (*list) {
                [*list addObject:path];
            } else {
                *list = [NSMutableArray arrayWithObject:path];
                if (*list == nil)
                    break;
            }
        } else if (movieData == nil) {
            if ([representation isKindOfClass:[HSMediaDataRepresentation class]]) {
                NSData *data = [representation mediaData];
                if (data == nil)
                    continue;
                if ([self mediaGroup] != 1) {
                    movieData = data;
                    continue;
                }
                NSDictionary *attributes = [[NSDictionary alloc] initWithObjectsAndKeys:data, QTMovieDataAttribute, kCFBooleanFalse, QTMovieResolveDataRefsAttribute, nil];
                if (attributes == nil)
                    break;
                QTMovie *qtMovie = [[QTMovie alloc] initWithAttributes:attributes error:NULL];
                [attributes release];
                if (qtMovie == nil)
                    continue;
                HSMovie *movie = [[HSMovie alloc] initWithMovie:qtMovie error:NULL];
                [qtMovie release];
                if (movie == nil)
                    continue;
                if ([movie isAnimatedGifMovie] || [movie isMovieSelfContained])
                    movieData = data;
                else
                    flattenData = data;
                [movie release];
            } else if (otherRepresentations) {
                [otherRepresentations addObject:representation];
            } else {
                otherRepresentations = [NSMutableArray arrayWithObject:representation];
                if (otherRepresentations == nil)
                    break;
            }
        }
    }

    NSUInteger fileCount = [filePaths count];
    NSUInteger flattenCount = [flattenPaths count];
    NSUInteger fileIndex = 0;
    NSUInteger flattenIndex = 0;
    BOOL written = NO;
    while (!failedToWrite) {
        NSString *path;
        if (fileIndex < fileCount) {
            path = [filePaths objectAtIndex:fileIndex++];
        } else if (flattenIndex < flattenCount) {
            path = [HSMediaSaver pathToFlattenMediaAtPath:[flattenPaths objectAtIndex:flattenIndex++]];
            if (path == nil)
                continue;
            HSMediaFileRepresentation *representation = [[HSMediaFileRepresentation alloc] initWithPath:path removeWhenDone:YES];
            if (representation) {
                [_representations addObject:representation];
                [representation release];
            } else {
                pathToRemove = path;
            }
        } else {
            break;
        }
        NSString *tempPath = nil;
        if ([self HSNewMedia_writeFileAtPath:path toStream:aStream CRC32:a32 writtenLength:aLength error:aError failedToRead:&failedToRead failedToWrite:&failedToWrite tempFilePath:&tempPath]) {
            // A file copied aside while writing becomes the file representation.
            if ([[NSFileManager defaultManager] hyperIsFileReadableAtPath:tempPath]) {
                HSMediaFileRepresentation *representation = [[HSMediaFileRepresentation alloc] initWithPath:tempPath removeWhenDone:YES];
                [[self representations] removeObject:[self fileRepresentation]];
                [[self representations] addObject:representation];
                [representation release];
            }
            [tempPath release];
            written = YES;
            break;
        }
        [tempPath release];
    }

    if (written) {
        result = 1;
    } else if (!failedToWrite) {
        if (movieData == nil && flattenData == nil) {
            for (id representation in otherRepresentations) {
                NSData *data = [representation mediaData];
                if (data == nil)
                    continue;
                if ([self mediaGroup] != 1) {
                    movieData = data;
                    break;
                }
                NSDictionary *attributes = [[NSDictionary alloc] initWithObjectsAndKeys:data, QTMovieDataAttribute, kCFBooleanFalse, QTMovieResolveDataRefsAttribute, nil];
                if (attributes == nil)
                    break;
                QTMovie *qtMovie = [[QTMovie alloc] initWithAttributes:attributes error:NULL];
                [attributes release];
                if (qtMovie == nil)
                    continue;
                HSMovie *movie = [[HSMovie alloc] initWithMovie:qtMovie error:NULL];
                [qtMovie release];
                if (movie == nil)
                    continue;
                if ([movie isAnimatedGifMovie] || [movie isMovieSelfContained])
                    movieData = data;
                else
                    flattenData = data;
                [movie release];
                break;
            }
        }
        if (movieData) {
            NSUInteger length = [movieData length];
            const Bytef *bytes = [movieData bytes];
            if (length == 0) {
                failedToRead = YES;
                if (aError) {
                    [*aError release];
                    *aError = [[NSError alloc] initWithDomain:NSCocoaErrorDomain code:NSFileReadCorruptFileError userInfo:nil];
                }
            } else if (bytes) {
                NSInteger writtenCount = [aStream write:bytes maxLength:length];
                if (writtenCount == -1) {
                    failedToWrite = YES;
                    if (aError) {
                        [*aError release];
                        *aError = [[aStream streamError] retain];
                    }
                } else {
                    if (a32)
                        *a32 = (unsigned int)crc32(0, bytes, (uInt)writtenCount);
                    if (aLength)
                        *aLength = (unsigned int)writtenCount;
                    if ((NSUInteger)writtenCount == length)
                        result = 1;
                    else
                        failedToWrite = YES;
                }
            }
        } else {
            NSString *path = flattenData ? [HSMediaSaver pathToFlattenMediaForData:flattenData] : nil;
            if (path == nil) {
                failedToRead = YES;
            } else {
                HSMediaFileRepresentation *representation = [[HSMediaFileRepresentation alloc] initWithPath:path removeWhenDone:YES];
                if (representation) {
                    [_representations addObject:representation];
                    [representation release];
                } else {
                    pathToRemove = path;
                }
                if ([self HSNewMedia_writeFileAtPath:path toStream:aStream CRC32:a32 writtenLength:aLength error:aError failedToRead:&failedToRead failedToWrite:&failedToWrite tempFilePath:NULL])
                    result = 1;
            }
        }
    }
    if (pathToRemove)
        [[NSFileManager defaultManager] removeItemAtPath:pathToRemove error:NULL];
    [pool release];

    pool = [[NSAutoreleasePool alloc] init];
    // Original quirk: the alert also shows when a later file was written after
    // an earlier one failed to read. Autosaves never ask.
    if (!failedToWrite && failedToRead) {
        BOOL ask = YES;
        if (!aRetrying) {
            NSArray *documents = [[NSDocumentController sharedDocumentController] documents];
            ask = [documents count] && [[documents objectAtIndex:0] currentSaveOperationType] != 3;
        }
        NSString *name = nil;
        if (ask) {
            name = [_mediaName retain];
            if (name == nil) {
                for (id representation in _representations) {
                    if ([representation isKindOfClass:[HSMediaFileRepresentation class]]) {
                        name = [[[representation path] lastPathComponent] retain];
                        if (name)
                            break;
                    }
                }
            }
        }
        NSAlert *alert = name ? [[[NSAlert alloc] init] autorelease] : nil;
        if (alert) {
            HSExecutableResourceProvider *provider = [HSExecutableResourceProvider sharedInstance];
            NSString *message, *information = nil, *findTitle = nil, *cancelTitle = nil;
            if (aRetrying) {
                message = [provider localizedStringForKey:@"HSInvalidMediaFileReplacementAlertMessageText" value:@"" table:@"Alerts"];
                if (message)
                    information = [[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"HSInvalidMediaFileReplacementAlertInformativeText" value:@"" table:@"Alerts"];
                if (information)
                    findTitle = [[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"HSInvalidMediaFileReplacementAlertFindButtonTitle" value:@"" table:@"Alerts"];
                if (findTitle)
                    cancelTitle = [[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"HSInvalidMediaFileReplacementAlertCancelButtonTitle" value:@"" table:@"Alerts"];
            } else {
                message = [provider localizedStringForKey:@"HSInvalidMediaFileAlertMessageText" value:@"" table:@"Alerts"];
                NSString *format = message ? [[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"HSInvalidMediaFileAlertInformativeTextFormat" value:@"" table:@"Alerts"] : nil;
                if (format)
                    information = [NSString stringWithFormat:format, name];
                if (information)
                    findTitle = [[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"HSInvalidMediaFileAlertFindButtonTitle" value:@"" table:@"Alerts"];
                if (findTitle)
                    cancelTitle = [[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"HSInvalidMediaFileAlertCancelButtonTitle" value:@"" table:@"Alerts"];
            }
            if (cancelTitle) {
                [alert setMessageText:message];
                [alert setInformativeText:information];
                [alert addButtonWithTitle:findTitle];
                [alert addButtonWithTitle:cancelTitle];
                BOOL cancelled = [alert runModal] == NSAlertSecondButtonReturn;
                if (!cancelled) {
                    NSOpenPanel *panel = [NSOpenPanel openPanel];
                    NSString *folder = nil;
                    NSArray *fileTypes = nil;
                    if (panel) {
                        [panel setAllowsMultipleSelection:NO];
                        folder = [[HSPathsProvider sharedPathsProvider] mediaObjectsFolder];
                        if (folder)
                            fileTypes = [NSArray arrayWithObjects:[self mediaType], nil];
                    }
                    if ([fileTypes count]) {
                        // runModalForDirectory:file:types: is gone.
                        [panel setDirectoryURL:[NSURL fileURLWithPath:folder isDirectory:YES]];
                        [panel setNameFieldStringValue:name];
                        [panel setAllowedFileTypes:fileTypes];
                        if ([panel runModal] != NSModalResponseOK) {
                            cancelled = YES;
                        } else {
                            NSString *directory = [[panel directoryURL] path];
                            NSString *file = [[panel URL] path];
                            if (directory) {
                                [[HSPathsProvider sharedPathsProvider] setMediaObjectsFolder:directory];
                                NSString *fileName = [file lastPathComponent];
                                HSMediaFileRepresentation *representation = fileName ? [[HSMediaFileRepresentation alloc] initWithPath:file removeWhenDone:NO] : nil;
                                if (representation) {
                                    [_representations removeAllObjects];
                                    [_representations addObject:representation];
                                    [representation release];
                                    [[NSNotificationCenter defaultCenter] postNotificationName:@"HSMediaDidChangeDataSourceNotification" object:self];
                                    NSString *newName = [fileName copy];
                                    [_mediaName release];
                                    _mediaName = newName;
                                    if (newName)
                                        result = 2;
                                }
                            }
                        }
                    }
                }
                if (cancelled && aError) {
                    NSError *underlying = *aError;
                    NSDictionary *userInfo = underlying ? [NSDictionary dictionaryWithObjectsAndKeys:underlying, NSUnderlyingErrorKey, nil] : nil;
                    *aError = [[NSError alloc] initWithDomain:NSCocoaErrorDomain code:NSUserCancelledError userInfo:userInfo];
                    [underlying release];
                }
            }
        }
        // Fix: the original leaked the retained name.
        [name release];
    }
    [pool release];
    if (aError) {
        if (*aError)
            [*aError autorelease];
        else if (failedToWrite)
            *aError = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFileWriteUnknownError userInfo:nil];
        else if (failedToRead)
            *aError = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFileReadUnknownError userInfo:nil];
    }
    return result;
}
// Copies the file at aPath into aStream a page at a time, also into a
// temporary file when the media file is not a temporary one already.
// Errors are returned retained (writeToStream autoreleases them).
- (BOOL)HSNewMedia_writeFileAtPath:(id)aPath toStream:(id)aStream CRC32:(unsigned int *)a32 writtenLength:(unsigned int *)aLength error:(id *)aError failedToRead:(BOOL *)aRead failedToWrite:(BOOL *)aWrite tempFilePath:(id *)aPath2
{
    const char *fsPath = [aPath fileSystemRepresentation];
    size_t pageSize = fsPath ? (size_t)getpagesize() : 0;
    Bytef *buffer = pageSize ? CFAllocatorAllocate(kCFAllocatorDefault, pageSize, 0) : NULL;
    if (buffer == NULL) {
        if (aWrite)
            *aWrite = YES;
        return NO;
    }
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:aPath, NSFilePathErrorKey, nil];
    BOOL result = NO;
    NSOutputStream *tempStream = nil;
    int file = open(fsPath, O_RDONLY);
    if (file == -1) {
        if (aRead)
            *aRead = YES;
        if (aError) {
            [*aError release];
            *aError = [[NSError alloc] initWithDomain:NSPOSIXErrorDomain code:errno userInfo:userInfo];
        }
        CFAllocatorDeallocate(kCFAllocatorDefault, buffer);
        return NO;
    }
    ssize_t count = read(file, buffer, pageSize);
    if (count <= 0) {
        if (aRead)
            *aRead = YES;
        if (aError) {
            [*aError release];
            if (count == 0)
                *aError = [[NSError alloc] initWithDomain:NSCocoaErrorDomain code:NSFileReadCorruptFileError userInfo:userInfo];
            else
                *aError = [[NSError alloc] initWithDomain:NSPOSIXErrorDomain code:errno userInfo:userInfo];
        }
        goto done;
    }
    if ([self HSNewMedia_shouldWriteToTempFile] && aPath2) {
        NSString *tempPath = [self HSNewMedia_generateTempFilePath];
        [*aPath2 release];
        *aPath2 = [tempPath retain];
        tempStream = [[NSOutputStream alloc] initToFileAtPath:tempPath append:NO];
        if (tempStream == nil) {
            // Fix: the original returned here and leaked the file and buffer.
            if (aWrite)
                *aWrite = YES;
            goto done;
        }
        [tempStream open];
    }
    if (a32)
        *a32 = (unsigned int)crc32(0, NULL, 0);
    if (aLength)
        *aLength = 0;
    for (;;) {
        NSInteger written = [aStream write:buffer maxLength:count];
        if (written == -1
            || (tempStream && ([tempStream write:buffer maxLength:count] != count))) {
            if (aWrite)
                *aWrite = YES;
            if (aError) {
                [*aError release];
                *aError = [[aStream streamError] retain];
            }
            goto done;
        }
        if (a32)
            *a32 = (unsigned int)crc32(*a32, buffer, (uInt)written);
        if (aLength)
            *aLength += (unsigned int)written;
        if (written != count) {
            if (aWrite)
                *aWrite = YES;
            goto done;
        }
        count = read(file, buffer, pageSize);
        if (count == -1) {
            // Original quirk: a read error after the first page still
            // returns YES, with *aRead set.
            if (aRead)
                *aRead = YES;
            if (aError) {
                [*aError release];
                *aError = [[NSError alloc] initWithDomain:NSPOSIXErrorDomain code:errno userInfo:userInfo];
            }
            result = YES;
            break;
        }
        if (count == 0) {
            result = YES;
            break;
        }
    }
done:
    close(file);
    CFAllocatorDeallocate(kCFAllocatorDefault, buffer);
    [tempStream close];
    [tempStream release];
    return result;
}
- (id)HSNewMedia_generateTempFilePath
{
    NSString *type = [HSNewMedia filteredTypeForFileType:[self mediaType]];
    NSUInteger code = [type extraFourCharCode];
    if (code && [type hasPrefix:@"'"])
        type = [HSNewMediaAccessor extensionForHFSType:[NSNumber numberWithUnsignedInt:(unsigned int)code]];
    return [HSTemporaryFilesManager generatedTempFilePathWithExtension:type];
}
- (BOOL)HSNewMedia_shouldWriteToTempFile
{
    NSString *path = [self fullPathToMediaFile];
    if ([path length] == 0)
        return NO;
    return ![HSTemporaryFilesManager containsTempFileAtPath:path];
}
- (BOOL)isValid
{
    for (id representation in [self representations]) {
        if ([representation isValid])
            return YES;
    }
    return NO;
}
- (id)mediaData
{
    NSData *data = [[self dataRepresentation] mediaData];
    if (data)
        return data;
    for (id representation in [self representations]) {
        data = [representation mediaData];
        if (data)
            return data;
    }
    return nil;
}
- (id)mediaName
{
    return _mediaName;
}
- (id)mediaType
{
    return [[[self representations] extraFirstObject] mediaType];
}
// Original quirk: the media path setter replaces the media name.
- (void)setMediaPath:(id)aPath
{
    if (![_mediaName isEqual:aPath]) {
        [_mediaName release];
        _mediaName = [aPath retain];
    }
}
- (id)mediaPath
{
    return @"to be defined in HSMediaSaver";
}
- (NSInteger)mediaGroup
{
    if (_mediaGroup == 0)
        _mediaGroup = (int)[self mediaGroupForMediaAtPath:[self fullPathToMediaFile]];
    return _mediaGroup;
}
- (id)mediaUID
{
    return _uid;
}
- (id)representations
{
    if (_representations == nil)
        _representations = [NSMutableArray new];
    return _representations;
}
- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    return [NSArray arrayWithObjects:@"uid", @"mediaName", @"mediaPath", @"mediaType", @"storageRetainCount", nil];
}
- (void)incrementStorageRetainCountBy:(NSUInteger)aBy
{
    _storageRetainCount += (unsigned int)aBy;
}
- (NSUInteger)storageRetainCount
{
    return _storageRetainCount;
}
- (void)resetStorageRetainCount
{
    _storageRetainCount = 0;
}
- (void)dealloc
{
    if (_uid)
        [[HSNewMediaAccessor sharedMediaAccessor] unregisterMedia:self];
    [_uid release];
    [_mediaName release];
    [_representations release];
    [super dealloc];
}
// A copy of aMedia under a new UID with the name's extension switched to
// aType. Only the first data representation (else the first file one) is
// carried over; without either the result is nil.
- (id)initWithMedia:(id)aMedia type:(id)aType
{
    self = [super init];
    if (self == nil)
        return nil;
    _uid = [[HSUID UID] retain];
    NSString *name = [aMedia mediaName];
    if ([[name pathExtension] isEqualToString:aType])
        _mediaName = [name copy];
    else
        _mediaName = [[[name stringByDeletingPathExtension] stringByAppendingPathExtension:aType] retain];
    _mediaGroup = (int)[aMedia mediaGroup];
    id dataRepresentation = nil;
    id fileRepresentation = nil;
    for (id representation in [aMedia representations]) {
        if ([representation isKindOfClass:[HSMediaDataRepresentation class]]) {
            dataRepresentation = representation;
            break;
        }
        if (fileRepresentation == nil && [representation isKindOfClass:[HSMediaFileRepresentation class]])
            fileRepresentation = representation;
    }
    id representation = nil;
    if (dataRepresentation)
        representation = [[HSMediaDataRepresentation alloc] initWithRepresentation:dataRepresentation mediaType:aType];
    else if (fileRepresentation)
        representation = [[HSMediaFileRepresentation alloc] initWithRepresentation:fileRepresentation mediaType:aType];
    if (representation == nil) {
        [self release];
        return nil;
    }
    _representations = [[NSMutableArray alloc] initWithObjects:representation, nil];
    [representation release];
    return self;
}
// A UID already registered returns that media instead, which then gets the
// representation and name as well (original).
- (id)initWithMediaUID:(id)aUID representation:(id)aRepresentation name:(id)aName
{
    self = [super init];
    if (self == nil)
        return nil;
    if (aUID == nil) {
        aUID = [HSUID UID];
    } else if ([[HSNewMediaAccessor sharedMediaAccessor] mediaForUID:aUID]) {
        [self release];
        self = [[[HSNewMediaAccessor sharedMediaAccessor] mediaForUID:aUID] retain];
    }
    // Fix: the original overwrote the existing media's UID and name without
    // releasing them.
    id uid = [aUID retain];
    [_uid release];
    _uid = uid;
    [[self representations] addObject:aRepresentation];
    id name = [aName retain];
    [_mediaName release];
    _mediaName = name;
    [[HSNewMediaAccessor sharedMediaAccessor] registerMedia:self];
    return self;
}
- (id)initWithPath:(id)aPath
{
    return [self initWithPath:aPath removeWhenDone:NO];
}
- (id)initWithPath:(id)aPath mediaUID:(id)aUID
{
    return [self initWithPath:aPath name:[aPath lastPathComponent] removeWhenDone:NO mediaUID:aUID];
}
- (id)initWithPath:(id)aPath removeWhenDone:(BOOL)aDone
{
    return [self initWithPath:aPath name:[aPath lastPathComponent] removeWhenDone:aDone];
}
- (id)initWithPath:(id)aPath name:(id)aName
{
    return [self initWithPath:aPath name:aName removeWhenDone:NO];
}
- (id)initWithPath:(id)aPath name:(id)aName removeWhenDone:(BOOL)aDone
{
    return [self initWithPath:aPath name:aName removeWhenDone:aDone mediaUID:nil];
}
- (id)initWithPath:(id)aPath name:(id)aName removeWhenDone:(BOOL)aDone mediaUID:(id)aUID
{
    HSMediaFileRepresentation *representation = [[HSMediaFileRepresentation alloc] initWithPath:aPath removeWhenDone:aDone];
    id media = [self initWithMediaUID:aUID representation:representation name:aName];
    [representation release];
    return media;
}
- (id)initWithData:(id)aData name:(id)aName type:(id)aType
{
    HSMediaDataRepresentation *representation = [[HSMediaDataRepresentation alloc] initWithData:aData mediaType:aType];
    id media = [self initWithMediaUID:[HSUID UID] representation:representation name:aName];
    [representation release];
    return media;
}
@end

@implementation HSNewMedia (StoringSupport)
- (id)fileWrapper
{
    return [[[HSMediaFileWrapper alloc] initWithMedia:self] autorelease];
}
@end
