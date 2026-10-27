#import "HSGraphicsLibraryiPhotoMediaDataProvider.h"

// The iPhoto libraries (AlbumData.xml): their photos and albums, the
// master album first.

static NSInteger HSGraphicsLibraryiPhotoMediaDataProviderDefaultSortOrder = 1;

// The text with every occurrence of the old prefix replaced, or nil if
// there was none.
static NSString *HSReplacingLibraryPath(NSString *aString, NSString *aOld, NSString *aNew)
{
    NSMutableString *string = [NSMutableString stringWithString:aString];
    if ([string replaceOccurrencesOfString:aOld withString:aNew options:NSLiteralSearch range:NSMakeRange(0, [string length])] == 0)
        return nil;
    return string;
}

@implementation HSGraphicsLibraryiPhotoMediaDataProvider

+ (NSInteger)defaultSortOrder
{
    return HSGraphicsLibraryiPhotoMediaDataProviderDefaultSortOrder;
}

+ (void)setDefaultSortOrder:(NSInteger)aOrder
{
    HSGraphicsLibraryiPhotoMediaDataProviderDefaultSortOrder = aOrder;
}

- (void)addAlbum:(HSGraphicsLibraryiPhotoAlbum *)aAlbum
{
    if (_albums == nil)
        _albums = [[NSMutableArray allocWithZone:[self zone]] initWithCapacity:0];
    if ([aAlbum isMaster] && [_albums count] != 0)
        [_albums insertObject:aAlbum atIndex:0];
    else
        [_albums addObject:aAlbum];
}

// Version 2 libraries list the photos apart (albums refer to them, and
// to their parents); version 1 albums hold their photos.
- (void)initializeWithLibraries:(id)aLibraries
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    [_photos release];
    _photos = nil;
    [_albums release];
    _albums = nil;
    for (NSDictionary *library in aLibraries) {
        @try {
            NSInteger version = [[library objectForKey:ipMajorVersionKey] intValue];
            NSDictionary *updated = [self updateLibrary:library withMajorVersion:version];
            if (version == 2) {
                NSDictionary *photos = [updated objectForKey:ipPhotosListKey];
                for (id key in [photos allKeys]) {
                    @try {
                        HSGraphicsLibraryiPhotoPhoto *photo = [[[HSGraphicsLibraryiPhotoPhoto allocWithZone:[self zone]] initWithDictionaryRepresentation:[photos objectForKey:key]] autorelease];
                        if (_photos == nil)
                            _photos = [[NSMutableDictionary allocWithZone:[self zone]] initWithCapacity:0];
                        [_photos setObject:photo forKey:key];
                    } @catch (NSException *exception) {
                    }
                }
                NSMutableSet *albums = [NSMutableSet set];
                for (id album in [updated objectForKey:ipAlbumsListKey]) {
                    @try {
                        [albums addObject:[[[HSGraphicsLibraryiPhotoAlbum allocWithZone:[self zone]] initWithDictionaryRepresentation:album photos:_photos version:2] autorelease]];
                    } @catch (NSException *exception) {
                    }
                }
                for (HSGraphicsLibraryiPhotoAlbum *album in [HSGraphicsLibraryiPhotoAlbum rootLevelAlbumsResolvingParentIndexesInAlbums:albums])
                    [self addAlbum:album];
            } else if (version == 1) {
                NSDictionary *albums = [updated objectForKey:ipAlbumsListKey];
                for (id name in [albums allKeys]) {
                    @try {
                        if (_photos == nil)
                            _photos = [[NSMutableDictionary allocWithZone:[self zone]] initWithCapacity:0];
                        [self addAlbum:[[[HSGraphicsLibraryiPhotoAlbum allocWithZone:[self zone]] initWithName:name dictionaryRepresentation:[albums objectForKey:name] photos:_photos version:1] autorelease]];
                    } @catch (NSException *exception) {
                    }
                }
            }
            NSInteger order = [[self class] defaultSortOrder];
            if (order == 1)
                [_albums sortUsingSelector:@selector(compareIncrease:)];
            else if (order == 2)
                [_albums sortUsingSelector:@selector(compareDecrease:)];
        } @catch (NSException *exception) {
        }
    }
    [pool release];
}

// Reads the library files changed since the last time (or all, when
// the libraries appeared or went away).
- (void)initializeWithLibraryFiles:(id)aFiles
{
    @try {
        NSMutableArray *libraries = [NSMutableArray arrayWithCapacity:[aFiles count]];
        BOOL changed = NO;
        for (NSURL *url in aFiles) {
            if (![url isFileURL])
                continue;
            NSString *path = [url path];
            NSString *name = [path lastPathComponent];
            NSDate *date = [[[NSFileManager defaultManager] attributesOfItemAtPath:[path stringByResolvingSymlinksInPath] error:NULL] objectForKey:NSFileModificationDate];
            if (![[NSFileManager defaultManager] isReadableFileAtPath:path])
                date = nil;
            if (![[[self modificationTimes] objectForKey:name] isEqualToDate:date]) {
                [[self modificationTimes] removeObjectForKey:name];
                if (date != nil)
                    [[self modificationTimes] setObject:date forKey:name];
                changed = YES;
            }
            NSDictionary *library = [NSDictionary dictionaryWithContentsOfFile:[url path]];
            if (library != nil)
                [libraries addObject:library];
        }
        if (changed || ([libraries count] == 0) != ([_photos count] == 0))
            [self initializeWithLibraries:libraries];
    } @catch (NSException *exception) {
    }
}

// The library's paths moved to where the iPhoto library is now, when
// it was moved since.
- (id)updateLibrary:(id)aLibrary withMajorVersion:(NSInteger)aVersion
{
    NSMutableDictionary *library = [NSMutableDictionary dictionaryWithDictionary:aLibrary];
    NSString *oldPath = nil;
    if (aVersion == 2)
        oldPath = [NSString stringWithString:[aLibrary objectForKey:ipArchivePathKey]];
    if ([[NSFileManager defaultManager] isReadableFileAtPath:oldPath])
        return library;
    NSString *folder = nil;
    for (NSString *key in [NSArray arrayWithObjects:iPhotoRecentDatabasesKey, iPhotoRecentDatabases1Key, nil]) {
        folder = [[[[NSBundle bundleForClass:[self class]] localizedStringForKey:key value:@"" table:@"LibraryGraphicsiPhoto"] stringByExpandingTildeInPath] stringByDeletingLastPathComponent];
        if (folder != nil)
            break;
    }
    if (folder == nil)
        return library;
    NSURL *url = [NSURL fileURLWithPath:folder];
    NSURL *resolved = [HSGraphicsLibraryiPhotoHelper resolveAliasesInURL:url];
    if (resolved == nil)
        resolved = url;
    NSString *newPath = [resolved path];
    if ([newPath isEqual:oldPath] || ![[NSFileManager defaultManager] isReadableFileAtPath:newPath])
        return library;
    id albums;
    if (aVersion == 2) {
        [library setObject:newPath forKey:ipArchivePathKey];
        NSMutableDictionary *photos = [NSMutableDictionary dictionaryWithDictionary:[library objectForKey:ipPhotosListKey]];
        for (id key in [photos allKeys]) {
            @try {
                NSMutableDictionary *photo = [NSMutableDictionary dictionaryWithDictionary:[photos objectForKey:key]];
                NSString *path = HSReplacingLibraryPath([photo objectForKey:ipPhotoPathKey], oldPath, newPath);
                if (path != nil)
                    [photo setObject:path forKey:ipPhotoPathKey];
                path = HSReplacingLibraryPath([photo objectForKey:ipThumbPathKey], oldPath, newPath);
                if (path != nil)
                    [photo setObject:path forKey:ipThumbPathKey];
                [photos setObject:photo forKey:key];
            } @catch (NSException *exception) {
            }
        }
        [library setObject:photos forKey:ipPhotosListKey];
        albums = [NSMutableArray arrayWithArray:[library objectForKey:ipAlbumsListKey]];
        NSUInteger index = 0;
        for (id entry in [[albums copy] autorelease]) {
            @try {
                NSMutableDictionary *album = [NSMutableDictionary dictionaryWithDictionary:entry];
                NSString *path = HSReplacingLibraryPath([album objectForKey:ipSongPathKey], oldPath, newPath);
                if (path != nil) {
                    [album setObject:path forKey:ipSongPathKey];
                    [albums replaceObjectAtIndex:index withObject:album];
                }
            } @catch (NSException *exception) {
            }
            index++;
        }
    } else {
        // Version 1 has no archive path: it's the photos' path up to
        // the iPhoto Library folder.
        albums = [NSMutableDictionary dictionaryWithDictionary:[library objectForKey:ipAlbumsListKey]];
        NSString *libraryFolderName = [[NSBundle bundleForClass:[self class]] localizedStringForKey:@"iPhotoLibraryFolderName" value:@"" table:@"LibraryGraphicsiPhoto"];
        for (id key in [albums allKeys]) {
            @try {
                NSMutableDictionary *album = [NSMutableDictionary dictionaryWithDictionary:[albums objectForKey:key]];
                NSMutableDictionary *albumPhotos = [NSMutableDictionary dictionaryWithDictionary:[album objectForKey:ipAlbumPhotosKey]];
                for (id photoKey in [albumPhotos allKeys]) {
                    NSMutableDictionary *photo = [NSMutableDictionary dictionaryWithDictionary:[albumPhotos objectForKey:photoKey]];
                    NSString *photoPath = [photo objectForKey:ipPhotoPathKey];
                    if (oldPath == nil || [oldPath isEqual:@""]) {
                        for (NSString *path = photoPath; path != nil; path = [path stringByDeletingLastPathComponent]) {
                            if ([path isEqual:@"/"])
                                break;
                            if ([[path lastPathComponent] isEqual:libraryFolderName]) {
                                oldPath = path;
                                break;
                            }
                        }
                    }
                    if (oldPath != nil && ![oldPath isEqual:@""] && ![oldPath isEqual:newPath]) {
                        NSString *path = HSReplacingLibraryPath(photoPath, oldPath, newPath);
                        if (path != nil)
                            [photo setObject:path forKey:ipPhotoPathKey];
                        path = HSReplacingLibraryPath([photo objectForKey:ipThumbPathKey], oldPath, newPath);
                        if (path != nil)
                            [photo setObject:path forKey:ipThumbPathKey];
                    }
                    [albumPhotos setObject:photo forKey:photoKey];
                }
                [album setObject:albumPhotos forKey:ipAlbumPhotosKey];
                [albums setObject:album forKey:key];
            } @catch (NSException *exception) {
            }
        }
    }
    [library setObject:albums forKey:ipAlbumsListKey];
    return library;
}

- (id)displayStringForCategory:(id)aCategory
{
    return aCategory;
}

- (id)searchCategories
{
    return nil;
}

- (id)modificationTimes
{
    if (_modificationTimes == nil)
        _modificationTimes = [[NSMutableDictionary allocWithZone:[self zone]] initWithCapacity:0];
    return _modificationTimes;
}

- (id)dataFolderAtIndex:(NSUInteger)aIndex
{
    if (aIndex < [_albums count])
        return [_albums objectAtIndex:aIndex];
    return nil;
}

- (NSUInteger)numberOfDataFolders
{
    return [_albums count];
}

- (id)dataItemAtIndex:(NSUInteger)aIndex
{
    return nil;
}

- (NSUInteger)numberOfDataItems
{
    return 0;
}

- (id)dataDisplayName
{
    return [self mediaDisplayName];
}

- (id)dataURL
{
    return nil;
}

- (id)rootDataFolder
{
    if (_albums == nil)
        [self initializeWithLibraryFiles:[HSGraphicsLibraryiPhotoHelper iPhotoRecentDatabases]];
    return self;
}

- (id)mediaDisplayName
{
    return [[NSBundle bundleForClass:[self class]] localizedStringForKey:@"iPhotoDisplayName" value:@"" table:@"LibraryGraphicsiPhoto"];
}

- (id)mediaIcon
{
    return nil;
}

- (id)rootItem
{
    [self initializeWithLibraryFiles:[HSGraphicsLibraryiPhotoHelper iPhotoRecentDatabases]];
    return self;
}

- (id)subitemAtIndex:(NSUInteger)aIndex
{
    if (aIndex < [_albums count])
        return [_albums objectAtIndex:aIndex];
    return nil;
}

- (NSUInteger)numberOfSubitems
{
    return [_albums count];
}

- (id)actionTarget
{
    return nil;
}

- (SEL)actionSelector
{
    return NULL;
}

- (id)actionImage
{
    return nil;
}

- (id)displayName
{
    return [self mediaDisplayName];
}

- (id)icon
{
    return [self mediaIcon];
}

- (id)queryInterface:(id)aInterface
{
    return [self conformsToProtocol:aInterface] ? self : nil;
}

- (BOOL)isPlayable
{
    return NO;
}

- (BOOL)supportedData:(id)aData error:(id *)aError
{
    return NO;
}

- (BOOL)supportedData:(id)aData
{
    return [self supportedData:aData error:NULL];
}

- (id)providerType
{
    return @"iPhoto";
}

- (id)mediaType
{
    return @"iPhotoPicture";
}

- (BOOL)sourceApplicationPresents
{
    return [HSGraphicsLibraryiPhotoHelper iPhotoApplicationVersionSupported];
}

- (void)dealloc
{
    [_photos release];
    [_albums release];
    [_modificationTimes release];
    [super dealloc];
}

@end
