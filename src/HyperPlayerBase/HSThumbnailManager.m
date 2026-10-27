#import "HSThumbnailManager.h"
#import "HSUserObjectPreviewView.h"

static HSThumbnailManager *HSThumbnailManagerShared = nil;

// Draws aImage scaled to fit a aMaxSize square (aPixelsSize drives the scale).
static NSImage *HSThumbnailManagerScaledImage(NSImage *aImage, NSSize aPixelsSize, CGFloat aMaxSize)
{
    CGFloat scale = 1.0;
    if (aMaxSize < aPixelsSize.width)
        scale = aMaxSize / aPixelsSize.width;
    if (aMaxSize < scale * aPixelsSize.height)
        scale = aMaxSize / aPixelsSize.height;
    NSSize size = NSMakeSize(aPixelsSize.width * scale, aPixelsSize.height * scale);
    NSRect fromRect = NSZeroRect;
    fromRect.size = [aImage size];
    NSImage *thumbnail = [[[NSImage alloc] initWithSize:size] autorelease];
    [thumbnail setCachedSeparately:YES];
    [thumbnail lockFocus];
    [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationHigh];
    [aImage drawInRect:NSMakeRect(0, 0, size.width, size.height) fromRect:fromRect operation:NSCompositingOperationCopy fraction:1];
    [thumbnail unlockFocus];
    return thumbnail;
}

// Makes sure the thumbnails folder exists; a plain file in its place is removed first.
static BOOL HSThumbnailManagerPrepareFolder(NSString *aFolder)
{
    BOOL isDirectory = NO;
    BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:aFolder isDirectory:&isDirectory];
    if (exists && !isDirectory) {
        if (![[NSFileManager defaultManager] removeItemAtPath:aFolder error:NULL])
            return NO;
        exists = NO;
    }
    if (!exists)
        [[NSFileManager defaultManager] createDirectoryAtPath:aFolder withIntermediateDirectories:YES attributes:nil error:NULL];
    return YES;
}

static NSDate *HSThumbnailManagerModificationDate(NSString *aPath)
{
    // -fileAttributesAtPath:traverseLink:YES in the original.
    return [[[NSFileManager defaultManager] attributesOfItemAtPath:[aPath stringByResolvingSymlinksInPath] error:NULL] objectForKey:NSFileModificationDate];
}

// Thumbnails are kept in a property list (key: object UID or original file path) plus one TIFF per thumbnail;
// loaded images are cached in memory. All access goes through a recursive lock.
@implementation HSThumbnailManager
+ (id)sharedThumbnailManager
{
    if (!HSThumbnailManagerShared)
        HSThumbnailManagerShared = [[self class] new];
    return HSThumbnailManagerShared;
}
- (void)generateMovieThumbnailInMainThread:(id)aThread
{
    HSMovie *movie = [HSMovie movieWithURL:[NSURL fileURLWithPath:aThread] error:NULL];
    [_mainThreadImage release];
    _mainThreadImage = [[movie posterImage] retain];
}
- (id)thumbnailsImagesFolder
{
    if (!_thumbnailsImagesFolder)
        _thumbnailsImagesFolder = [[[HSPathsProvider sharedPathsProvider] thumbnailsImagesFolder] retain];
    return _thumbnailsImagesFolder;
}
- (id)thumbnailFileExtension
{
    return @"tiff";
}
- (BOOL)isThumbnailValid:(id)aValid
{
    BOOL valid = NO;
    @try {
        NSEnumerator *enumerator = [[self thumbnails] objectEnumerator];
        NSDictionary *entry;
        while ((entry = [enumerator nextObject])) {
            if ([[entry objectForKey:HSThumbnailFileNameKey] isEqualToString:aValid]) {
                valid = YES;
                break;
            }
        }
    } @catch (NSException *exception) {
    }
    return valid;
}
- (void)clenaupThread:(id)aThread
{
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    [aThread cleanup];
    [pool release];
}
- (id)cacheThumbnailForUID:(id)aUID
{
    if (!aUID)
        return nil;
    NSDictionary *entry = nil;
    @try {
        entry = [[self thumbnails] objectForKey:aUID];
    } @catch (NSException *exception) {
    }
    if (!entry)
        return nil;
    NSString *path = [[self thumbnailsImagesFolder] stringByAppendingPathComponent:[entry objectForKey:HSThumbnailFileNameKey]];
    NSImage *image = [[NSImage allocWithZone:[self zone]] initWithContentsOfFile:path];
    if (image) {
        @try {
            [[self cachedThumbnails] setObject:[NSDictionary dictionaryWithObjectsAndKeys:image, HSCachedThumbnailImageKey, nil] forKey:aUID];
        } @catch (NSException *exception) {
        }
    }
    return [image autorelease];
}
- (id)createThumbnailForUID:(id)aUID originalImage:(id)aImage
{
    if (!aUID || !aImage)
        return nil;
    NSSize size = [(NSImage *)aImage size];
    // Quirk: an original that already fits gets no thumbnail (nil), so callers fall back to the original.
    if (size.width <= [self thumbnailSize] && size.height <= [self thumbnailSize])
        return nil;
    NSImage *thumbnail = HSThumbnailManagerScaledImage(aImage, size, [self thumbnailSize]);
    NSString *path = [self thumbnailsImagesFolder];
    if (!HSThumbnailManagerPrepareFolder(path))
        return nil;
    // File names are cut to fit 255 characters with the extension.
    NSString *name = aUID;
    NSInteger excess = (NSInteger)[aUID length] - 254 + (NSInteger)[[self thumbnailFileExtension] length];
    if (excess > 0)
        name = [aUID substringToIndex:[aUID length] - excess];
    path = [[path stringByAppendingPathComponent:name] stringByAppendingPathExtension:[self thumbnailFileExtension]];
    @try {
        if (![[thumbnail TIFFRepresentationUsingCompression:NSTIFFCompressionLZW factor:0] writeToFile:path atomically:NO])
            thumbnail = nil;
        @try {
            [[self thumbnails] setObject:[NSDictionary dictionaryWithObjectsAndKeys:[path lastPathComponent], HSThumbnailFileNameKey, nil] forKey:aUID];
            [self saveThumbnails];
        } @catch (NSException *exception) {
        }
        @try {
            [[self cachedThumbnails] setObject:[NSDictionary dictionaryWithObjectsAndKeys:thumbnail, HSCachedThumbnailImageKey, nil] forKey:aUID];
        } @catch (NSException *exception) {
        }
    } @catch (NSException *exception) {
        thumbnail = nil;
    }
    return thumbnail;
}
- (id)cacheThumbnailForObject:(id)aObject
{
    NSString *uid = [[aObject hyperUID] stringValue];
    if (!uid)
        return nil;
    NSDictionary *entry = nil;
    @try {
        entry = [[self thumbnails] objectForKey:uid];
    } @catch (NSException *exception) {
    }
    if (!entry)
        return nil;
    NSString *path = [[self thumbnailsImagesFolder] stringByAppendingPathComponent:[entry objectForKey:HSThumbnailFileNameKey]];
    NSImage *image = [[NSImage allocWithZone:[self zone]] initWithContentsOfFile:path];
    if (!image)
        return [self createThumbnailForObject:aObject];
    @try {
        [[self cachedThumbnails] setObject:[NSDictionary dictionaryWithObjectsAndKeys:image, HSCachedThumbnailImageKey, nil] forKey:uid];
    } @catch (NSException *exception) {
    }
    return [image autorelease];
}
- (id)createThumbnailForObject:(id)aObject
{
    NSString *uid = [[aObject hyperUID] stringValue];
    if (!uid)
        return nil;
    NSImage *thumbnail = [HSUserObjectInPlayerPreviewView thumbnailPreviewImageWithMaxSize:NSMakeSize([self thumbnailSize], [self thumbnailSize]) forObject:aObject];
    if (!thumbnail)
        return nil;
    NSString *path = [self thumbnailsImagesFolder];
    if (!HSThumbnailManagerPrepareFolder(path))
        return nil;
    NSString *name = uid;
    NSInteger excess = (NSInteger)[uid length] - 254 + (NSInteger)[[self thumbnailFileExtension] length];
    if (excess > 0)
        name = [uid substringToIndex:[uid length] - excess];
    path = [[path stringByAppendingPathComponent:name] stringByAppendingPathExtension:[self thumbnailFileExtension]];
    @try {
        if (![[thumbnail TIFFRepresentationUsingCompression:NSTIFFCompressionLZW factor:0] writeToFile:path atomically:NO])
            thumbnail = nil;
        @try {
            [[self thumbnails] setObject:[NSDictionary dictionaryWithObjectsAndKeys:[path lastPathComponent], HSThumbnailFileNameKey, nil] forKey:uid];
            [self saveThumbnails];
        } @catch (NSException *exception) {
        }
        @try {
            [[self cachedThumbnails] setObject:[NSDictionary dictionaryWithObjectsAndKeys:thumbnail, HSCachedThumbnailImageKey, nil] forKey:uid];
        } @catch (NSException *exception) {
        }
    } @catch (NSException *exception) {
        thumbnail = nil;
    }
    return thumbnail;
}
- (id)cacheThumbnailForPath:(id)aPath
{
    NSDictionary *entry = nil;
    @try {
        entry = [[self thumbnails] objectForKey:aPath];
    } @catch (NSException *exception) {
    }
    if (!entry)
        return nil;
    // A thumbnail of a file that changed since is regenerated.
    NSDate *date = HSThumbnailManagerModificationDate(aPath);
    if (![date isEqualToDate:[entry objectForKey:HSOriginalFileModificationDateKey]])
        return [self createThumbnailForPath:aPath];
    NSString *path = [[self thumbnailsImagesFolder] stringByAppendingPathComponent:[entry objectForKey:HSThumbnailFileNameKey]];
    NSImage *image = [[NSImage allocWithZone:[self zone]] initWithContentsOfFile:path];
    if (!image)
        return [self createThumbnailForPath:aPath];
    @try {
        [[self cachedThumbnails] setObject:[NSDictionary dictionaryWithObjectsAndKeys:date, HSOriginalFileModificationDateKey, image, HSCachedThumbnailImageKey, nil] forKey:aPath];
    } @catch (NSException *exception) {
    }
    return [image autorelease];
}
- (id)createThumbnailForPath:(id)aPath
{
    BOOL isDirectory = NO;
    if (![[NSFileManager defaultManager] fileExistsAtPath:aPath isDirectory:&isDirectory] || isDirectory)
        return nil;
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    BOOL fromMovie = NO;
    NSImage *image = [[[NSImage allocWithZone:[self zone]] initWithContentsOfFile:aPath] autorelease];
    if (!image) {
        // Not an image: use the movie poster, which has to be made on the main thread.
        NSArray *modes = [NSArray arrayWithObjects:NSDefaultRunLoopMode, NSModalPanelRunLoopMode, NSEventTrackingRunLoopMode, HSThumbnailGenerationRunLoopMode, nil];
        [self performSelectorOnMainThread:@selector(generateMovieThumbnailInMainThread:) withObject:aPath waitUntilDone:YES modes:modes];
        image = [_mainThreadImage autorelease];
        _mainThreadImage = nil;
        fromMovie = image != nil;
    }
    // The original returned here without releasing the pool; fixed.
    if (!image) {
        [pool release];
        return nil;
    }
    [image setCacheMode:NSImageCacheBySize];
    NSImage *thumbnail = nil;
    NSSize pixelsSize = [image hyperPixelsSize];
    // Quirk: an image (not a movie poster) that already fits gets no thumbnail (nil).
    if (fromMovie || pixelsSize.width > [self thumbnailSize] || pixelsSize.height > [self thumbnailSize]) {
        thumbnail = HSThumbnailManagerScaledImage(image, pixelsSize, [self thumbnailSize]);
        NSString *path = [self thumbnailsImagesFolder];
        if (!HSThumbnailManagerPrepareFolder(path)) {
            [pool release];
            return nil;
        }
        NSDate *date = HSThumbnailManagerModificationDate(aPath);
        NSString *name = [[aPath lastPathComponent] stringByAppendingString:@"."];
        NSString *dateString = [date description];
        NSInteger excess = (NSInteger)[[self thumbnailFileExtension] length] + (NSInteger)[dateString length] + (NSInteger)[name length] - 254;
        if (excess > 0)
            name = [name substringToIndex:[name length] - excess];
        path = [[[path stringByAppendingPathComponent:name] stringByAppendingString:dateString] stringByAppendingPathExtension:[self thumbnailFileExtension]];
        [self removeThumbnailForPath:aPath];
        @try {
            if (![[thumbnail TIFFRepresentationUsingCompression:NSTIFFCompressionLZW factor:0] writeToFile:path atomically:NO]) {
                thumbnail = nil;
            } else {
                @try {
                    NSDictionary *entry = [NSDictionary dictionaryWithObjectsAndKeys:date, HSOriginalFileModificationDateKey, [path lastPathComponent], HSThumbnailFileNameKey, NSStringFromSize([image hyperPixelsSize]), HSOriginalFileSizeKey, nil];
                    [[self thumbnails] setObject:entry forKey:aPath];
                    [self saveThumbnails];
                } @catch (NSException *exception) {
                }
                @try {
                    [[self cachedThumbnails] setObject:[NSDictionary dictionaryWithObjectsAndKeys:date, HSOriginalFileModificationDateKey, thumbnail, HSCachedThumbnailImageKey, nil] forKey:aPath];
                } @catch (NSException *exception) {
                }
            }
        } @catch (NSException *exception) {
            thumbnail = nil;
        }
    }
    [thumbnail retain];
    [pool release];
    return [thumbnail autorelease];
}
- (id)cachedThumbnailImageForKey:(id)aKey
{
    NSDictionary *entry = [[self cachedThumbnails] objectForKey:aKey];
    NSDate *date = [entry objectForKey:HSOriginalFileModificationDateKey];
    if (date && ![HSThumbnailManagerModificationDate(aKey) isEqualToDate:date])
        return nil;
    return [entry objectForKey:HSCachedThumbnailImageKey];
}
- (id)cachedThumbnails
{
    if (!_cachedThumbnails)
        _cachedThumbnails = [[NSMutableDictionary allocWithZone:[self zone]] initWithCapacity:0];
    return _cachedThumbnails;
}
- (id)thumbnails
{
    if (!_thumbnails)
        [self loadThumbnails];
    return _thumbnails;
}
- (void)saveThumbnailsDatabase
{
    // Busy: try again later.
    if (![_thumbnailsLock tryLock]) {
        [self saveThumbnails];
        return;
    }
    NSString *path = [[HSPathsProvider sharedPathsProvider] thumbnailsFilePath];
    if (HSThumbnailManagerPrepareFolder([path stringByDeletingLastPathComponent]))
        [_thumbnails writeToFile:path atomically:YES];
    [_thumbnailsLock unlock];
}
- (void)saveThumbnails
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(saveThumbnailsDatabase) object:nil];
    [self performSelector:@selector(saveThumbnailsDatabase) withObject:nil afterDelay:1.0];
}
- (void)loadThumbnails
{
    [_thumbnails release];
    _thumbnails = [[NSMutableDictionary allocWithZone:[self zone]] initWithContentsOfFile:[[HSPathsProvider sharedPathsProvider] thumbnailsFilePath]];
    if (!_thumbnails)
        _thumbnails = [[NSMutableDictionary allocWithZone:[self zone]] initWithCapacity:0];
}
- (BOOL)isAttributesNotificationPostingDisabled
{
    return NO;
}
- (id)cardGroupController
{
    return nil;
}
- (id)delegate
{
    return nil;
}
- (id)scriptController
{
    return nil;
}
- (id)undoManager
{
    return nil;
}
// Drops thumbnails of files that no longer exist (runs on a background thread from -init).
- (void)cleanup
{
    [self HSThumbnailManager_lock];
    @try {
        NSDictionary *thumbnails = [[self thumbnails] copy];
        NSEnumerator *enumerator = [thumbnails keyEnumerator];
        NSString *key;
        while ((key = [enumerator nextObject])) {
            if ([[thumbnails objectForKey:key] objectForKey:HSOriginalFileModificationDateKey] && ![[NSFileManager defaultManager] fileExistsAtPath:key])
                [self removeThumbnailForPath:key];
        }
        [thumbnails release];
    } @catch (NSException *exception) {
    }
    [_thumbnailsLock unlock];
}
- (BOOL)thumbnailExistForUID:(id)aUID
{
    BOOL exists = NO;
    if (!aUID)
        return NO;
    [self HSThumbnailManager_lock];
    @try {
        exists = [[self thumbnails] objectForKey:aUID] != nil;
    } @catch (NSException *exception) {
    }
    [_thumbnailsLock unlock];
    return exists;
}
- (BOOL)thumbnailExistForObject:(id)aObject
{
    BOOL exists = NO;
    if (!aObject)
        return NO;
    NSString *uid = [[aObject hyperUID] stringValue];
    [self HSThumbnailManager_lock];
    @try {
        exists = [[self thumbnails] objectForKey:uid] != nil;
    } @catch (NSException *exception) {
    }
    [_thumbnailsLock unlock];
    return exists;
}
- (BOOL)thumbnailExistForObjectDescription:(id)aDescription
{
    if (!aDescription)
        return NO;
    HSNode *node = [[HSNode nodeWithDictionary:aDescription] retain];
    BOOL exists = [self thumbnailExistForObject:node];
    [node release];
    return exists;
}
- (BOOL)thumbnailExistForPath:(id)aPath
{
    BOOL exists = NO;
    [self HSThumbnailManager_lock];
    @try {
        exists = [[self thumbnails] objectForKey:aPath] != nil;
    } @catch (NSException *exception) {
    }
    [_thumbnailsLock unlock];
    return exists;
}
- (BOOL)thumbnailExistForURL:(id)aURL
{
    return [self thumbnailExistForPath:[aURL path]];
}
- (void)removeThumbnailForUID:(id)aUID
{
    if (!aUID)
        return;
    [self HSThumbnailManager_lock];
    @try {
        [[self cachedThumbnails] removeObjectForKey:aUID];
    } @catch (NSException *exception) {
    }
    @try {
        NSDictionary *entry = [[self thumbnails] objectForKey:aUID];
        if (entry) {
            [[NSFileManager defaultManager] removeItemAtPath:[[self thumbnailsImagesFolder] stringByAppendingPathComponent:[entry objectForKey:HSThumbnailFileNameKey]] error:NULL];
            [[self thumbnails] removeObjectForKey:aUID];
            [self saveThumbnails];
        }
    } @catch (NSException *exception) {
    }
    [_thumbnailsLock unlock];
}
- (void)removeThumbnailForObject:(id)aObject
{
    if (!aObject)
        return;
    [self removeThumbnailForUID:[[aObject hyperUID] stringValue]];
}
- (void)removeThumbnailForObjectDescription:(id)aDescription
{
    if (!aDescription)
        return;
    HSNode *node = [[HSNode nodeWithDictionary:aDescription] retain];
    [self removeThumbnailForObject:node];
    [node release];
}
- (void)removeThumbnailForPath:(id)aPath
{
    // Same steps as -removeThumbnailForUID:, keyed by the original file path.
    [self removeThumbnailForUID:aPath];
}
- (void)removeThumbnailForURL:(id)aURL
{
    [self removeThumbnailForPath:[aURL path]];
}
- (id)thumbnailForUID:(id)aUID originalImage:(id)aImage
{
    NSImage *thumbnail = nil;
    if (!aUID)
        return nil;
    if (aImage) {
        // A new original replaces the old thumbnail.
        if ([self thumbnailExistForUID:aUID])
            [self removeThumbnailForUID:aUID];
        [self HSThumbnailManager_lock];
        thumbnail = [self createThumbnailForUID:aUID originalImage:aImage];
        [_thumbnailsLock unlock];
        return thumbnail;
    }
    [self HSThumbnailManager_lock];
    @try {
        thumbnail = [self cachedThumbnailImageForKey:aUID];
    } @catch (NSException *exception) {
    }
    if (!thumbnail) {
        NSDictionary *entry = nil;
        @try {
            entry = [[self thumbnails] objectForKey:aUID];
        } @catch (NSException *exception) {
        }
        if (entry)
            thumbnail = [self cacheThumbnailForUID:aUID];
    }
    [_thumbnailsLock unlock];
    return thumbnail;
}
- (id)thumbnailForObject:(id)aObject
{
    NSImage *thumbnail = nil;
    if (!aObject)
        return nil;
    // The object is rendered with the manager as its node support.
    id support = [aObject support];
    if (support != self) {
        [support retain];
        [aObject setSupport:self];
    }
    NSString *uid = [[aObject hyperUID] stringValue];
    if (uid) {
        [self HSThumbnailManager_lock];
        @try {
            thumbnail = [self cachedThumbnailImageForKey:uid];
        } @catch (NSException *exception) {
        }
        if (!thumbnail) {
            NSDictionary *entry = nil;
            @try {
                entry = [[self thumbnails] objectForKey:uid];
            } @catch (NSException *exception) {
            }
            thumbnail = entry ? [self cacheThumbnailForObject:aObject] : [self createThumbnailForObject:aObject];
        }
        [_thumbnailsLock unlock];
    }
    if (support != self) {
        [aObject setSupport:support];
        [support release];
    }
    return thumbnail;
}
- (id)thumbnailForObjectDescription:(id)aDescription
{
    if (!aDescription)
        return nil;
    HSNode *node = [[HSNode nodeWithDictionary:aDescription] retain];
    NSImage *thumbnail = [self thumbnailForObject:node];
    [node release];
    return thumbnail;
}
- (NSSize)thumbnailOriginalSizeForPath:(id)aPath
{
    NSSize size = NSZeroSize;
    [self HSThumbnailManager_lock];
    NSDictionary *entry = nil;
    @try {
        entry = [[self thumbnails] objectForKey:aPath];
    } @catch (NSException *exception) {
    }
    if (entry)
        size = NSSizeFromString([entry objectForKey:HSOriginalFileSizeKey]);
    [_thumbnailsLock unlock];
    return size;
}
- (NSSize)thumbnailOriginalSizeForURL:(id)aURL
{
    return [self thumbnailOriginalSizeForPath:[aURL path]];
}
- (id)thumbnailForPath:(id)aPath
{
    NSImage *thumbnail = nil;
    [self HSThumbnailManager_lock];
    @try {
        thumbnail = [self cachedThumbnailImageForKey:aPath];
    } @catch (NSException *exception) {
    }
    if (!thumbnail) {
        NSDictionary *entry = nil;
        @try {
            entry = [[self thumbnails] objectForKey:aPath];
        } @catch (NSException *exception) {
        }
        thumbnail = entry ? [self cacheThumbnailForPath:aPath] : [self createThumbnailForPath:aPath];
    }
    [_thumbnailsLock unlock];
    return thumbnail;
}
- (id)thumbnailForURL:(id)aURL
{
    return [self thumbnailForPath:[aURL path]];
}
- (CGFloat)thumbnailSize
{
    return 180.0;
}
// Spins the thumbnail run loop mode while waiting, so a movie poster requested
// from a background thread can still be made on the main thread.
- (void)HSThumbnailManager_lock
{
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    while (![_thumbnailsLock tryLock]) {
        NSAutoreleasePool *pool = [NSAutoreleasePool new];
        [runLoop runMode:HSThumbnailGenerationRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.001]];
        [pool release];
    }
}
- (void)dealloc
{
    [_thumbnails release];
    [_cachedThumbnails release];
    [_thumbnailsLock release];
    [_thumbnailsImagesFolder release];
    [_mainThreadImage release];
    [super dealloc];
}
- (id)init
{
    self = [super init];
    if (self) {
        _thumbnailsLock = [[NSRecursiveLock allocWithZone:[self zone]] init];
        [NSThread detachNewThreadSelector:@selector(clenaupThread:) toTarget:self withObject:self];
    }
    return self;
}
@end
