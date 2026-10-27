#import "HSGraphicsLibraryiPhotoAlbum.h"

// An album of an iPhoto library, with its photos and subalbums.

static NSImage *HSiPhotoAlbumImage(NSImage **aImage, NSString *aName)
{
    if (*aImage == nil)
        *aImage = [[[HSImagesProvider sharedImagesProvider] imageForName:aName ofType:@"tiff"] retain];
    return *aImage;
}

@implementation HSGraphicsLibraryiPhotoAlbum

// The albums without a parent; the others go in their parents (or
// nowhere when theirs is missing).
+ (id)rootLevelAlbumsResolvingParentIndexesInAlbums:(id)aAlbums
{
    NSMutableSet *rootAlbums = [NSMutableSet set];
    for (HSGraphicsLibraryiPhotoAlbum *album in aAlbums) {
        if (album->_parentID == 0) {
            [rootAlbums addObject:album];
            continue;
        }
        for (HSGraphicsLibraryiPhotoAlbum *parent in aAlbums) {
            if (parent->_albumID == album->_parentID) {
                [parent addSubalbum:album];
                break;
            }
        }
    }
    return rootAlbums;
}

- (id)copyWithZone:(NSZone *)aZone
{
    return [self retain];
}

- (BOOL)isOfType:(NSString *)aType
{
    return [_type isEqualToString:[[NSBundle bundleForClass:[self class]] localizedStringForKey:aType value:@"" table:@"LibraryGraphicsiPhoto"]];
}

- (BOOL)isNamed:(NSString *)aName
{
    return [[self displayName] isEqualToString:[[NSBundle bundleForClass:[self class]] localizedStringForKey:aName value:@"" table:@"LibraryGraphicsiPhoto"]];
}

- (BOOL)isEvent
{
    return [self isOfType:@"iPhotoEvent"];
}

- (BOOL)isSlideshow
{
    return [self isOfType:@"iPhotoSlideshow"];
}

- (BOOL)isBook
{
    return [self isOfType:@"iPhotoBook"];
}

- (BOOL)isFolder
{
    return [self isOfType:@"iPhotoFolder"];
}

- (BOOL)isSmart
{
    return [self isOfType:@"iPhotoSmart"];
}

- (BOOL)isSpecialMonth
{
    return [self isOfType:@"iPhotoSpecialMonth"];
}

- (BOOL)isSpecialRoll
{
    return [self isOfType:@"iPhotoSpecialRoll"];
}

- (BOOL)isFlagged
{
    return [self isNamed:@"iPhotoFlagged"];
}

- (BOOL)isLastImport
{
    return [self isNamed:@"iPhotoLastImport"];
}

- (NSInteger)compareDecrease:(id)aDecrease
{
    return [aDecrease compareIncrease:self];
}

// The special albums first (by weight), then by name.
- (NSInteger)compareIncrease:(id)aIncrease
{
    NSInteger weight = [self sortWeight];
    NSInteger otherWeight = [aIncrease sortWeight];
    if (weight == otherWeight)
        return [[self displayName] compare:[aIncrease displayName] options:NSCaseInsensitiveSearch | NSNumericSearch];
    return otherWeight < weight ? NSOrderedAscending : NSOrderedDescending;
}

- (id)filterPhotos:(id)aPhotos byCategory:(id)aCategory
{
    if ([aPhotos length] == 0)
        return _photos;
    NSMutableArray *photos = [NSMutableArray arrayWithCapacity:0];
    for (id photo in _photos) {
        if ([[photo displayName] rangeOfString:aPhotos options:NSCaseInsensitiveSearch].location != NSNotFound)
            [photos addObject:photo];
    }
    return photos;
}

- (BOOL)isMaster
{
    return _isMaster;
}

- (NSInteger)sortWeight
{
    if ([self isMaster])
        return 8;
    if ([self isLastImport])
        return 7;
    if ([self isSpecialRoll])
        return 6;
    if ([self isSpecialMonth])
        return 5;
    if ([self isFolder])
        return 4;
    if ([self isSmart])
        return 3;
    if ([self isBook])
        return 1;
    return [self isSlideshow] ? 0 : 2;
}

- (id)photoAtIndex:(NSUInteger)aIndex
{
    if (aIndex < [_photos count])
        return [_photos objectAtIndex:aIndex];
    return nil;
}

- (NSUInteger)numberOfPhotos
{
    return [_photos count];
}

- (id)dataDisplayName
{
    return [self displayName];
}

- (id)dataURL
{
    return nil;
}

- (id)dataFolderAtIndex:(NSUInteger)aIndex
{
    return nil;
}

- (NSUInteger)numberOfDataFolders
{
    return 0;
}

- (id)dataItemAtIndex:(NSUInteger)aIndex
{
    return [self photoAtIndex:aIndex];
}

- (NSUInteger)numberOfDataItems
{
    return [self numberOfPhotos];
}

- (id)subitemAtIndex:(NSUInteger)aIndex
{
    return [_subalbums objectAtIndex:aIndex];
}

- (NSUInteger)numberOfSubitems
{
    return _subalbums == nil ? 0 : [_subalbums count];
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
    return _name;
}

- (id)icon
{
    if ([self isMaster]) {
        if (_libraryVersion < 3.0f)
            return HSiPhotoAlbumImage(&_libraryImage, @"iPhotoLibrary");
        return HSiPhotoAlbumImage(&_library4Image, @"iPhotoLibrary4");
    }
    if ([self isLastImport])
        return HSiPhotoAlbumImage(&_lastImportImage, @"iPhotoLastImport");
    if ([self isFlagged])
        return HSiPhotoAlbumImage(&_flaggedImage, @"iPhotoFlagged");
    if ([self isSpecialRoll])
        return HSiPhotoAlbumImage(&_specialRollImage, @"iPhotoSpecialRoll");
    if ([self isSpecialMonth])
        return HSiPhotoAlbumImage(&_specialMonthImage, @"iPhotoSpecialMonth");
    if ([self isSmart])
        return HSiPhotoAlbumImage(&_smartAlbumImage, @"iPhotoSmartAlbum");
    if ([self isFolder])
        return HSiPhotoAlbumImage(&_folderImage, @"iPhotoFolder");
    if ([self isBook])
        return HSiPhotoAlbumImage(&_bookImage, @"iPhotoBook");
    if ([self isSlideshow])
        return HSiPhotoAlbumImage(&_slideshowImage, @"iPhotoSlideshow");
    if ([self isEvent])
        return HSiPhotoAlbumImage(&_eventImage, @"iPhotoEvent");
    return HSiPhotoAlbumImage(&_albumImage, @"iPhotoAlbum");
}

- (void)addSubalbum:(id)aSubalbum
{
    if (_subalbums == nil)
        _subalbums = [[NSMutableArray alloc] initWithObjects:aSubalbum, nil];
    else
        [_subalbums addObject:aSubalbum];
}

- (void)dealloc
{
    [_photos release];
    [_subalbums release];
    [_name release];
    [_type release];
    [_lastImportImage release];
    [_libraryImage release];
    [_library4Image release];
    [_smartAlbumImage release];
    [_albumImage release];
    [_specialMonthImage release];
    [_specialRollImage release];
    [_folderImage release];
    [_bookImage release];
    [_slideshowImage release];
    [_flaggedImage release];
    [_eventImage release];
    [super dealloc];
}

// Version 2 albums list the keys of their photos (iPhoto 4 ones have an
// ID); version 1 albums hold their photos, added to the library's.
- (id)initWithDictionaryRepresentation:(id)aRepresentation photos:(id)aPhotos version:(NSInteger)aVersion
{
    if (!(self = [super init]))
        return nil;
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    _name = [[aRepresentation objectForKey:ipAlbumNameKey] retain];
    _type = [[aRepresentation objectForKey:ipAlbumTypeKey] retain];
    id parent = [aRepresentation objectForKey:ipParentKey];
    if (parent != nil)
        _parentID = [parent unsignedIntValue];
    if (aVersion == 1)
        _libraryVersion = 1.1f;
    else if (aVersion == 2) {
        id albumID = [aRepresentation objectForKey:ipAlbumIDKey];
        if (albumID == nil)
            _libraryVersion = 2.0f;
        else {
            _libraryVersion = 3.0f;
            _albumID = [albumID unsignedIntValue];
        }
    }
    _photos = [[NSMutableArray allocWithZone:[self zone]] initWithCapacity:0];
    @try {
        id master = [aRepresentation objectForKey:ipMasterKey];
        _isMaster = master != nil;
        @try {
            _isMaster = [master boolValue];
        } @catch (NSException *exception) {
        }
    } @catch (NSException *exception) {
    }
    if (aVersion == 2) {
        for (id key in [aRepresentation objectForKey:ipAlbumKeysListKey]) {
            @try {
                [_photos addObject:[aPhotos objectForKey:key]];
            } @catch (NSException *exception) {
            }
        }
    } else if (aVersion == 1) {
        NSDictionary *albumPhotos = [aRepresentation objectForKey:ipAlbumPhotosKey];
        for (id key in [albumPhotos allKeys]) {
            id photo = [aPhotos objectForKey:key];
            if (photo != nil) {
                [_photos addObject:photo];
                continue;
            }
            @try {
                photo = [[[HSGraphicsLibraryiPhotoPhoto allocWithZone:[self zone]] initWithDictionaryRepresentation:[albumPhotos objectForKey:key]] autorelease];
                [aPhotos setObject:photo forKey:key];
                [_photos addObject:photo];
            } @catch (NSException *exception) {
            }
        }
    } else {
        [self release];
        self = nil;
    }
    [pool release];
    return self;
}

- (id)initWithName:(id)aName dictionaryRepresentation:(id)aRepresentation photos:(id)aPhotos version:(NSInteger)aVersion
{
    if ((self = [self initWithDictionaryRepresentation:aRepresentation photos:aPhotos version:aVersion])) {
        // Fix: the name from the dictionary leaked.
        [_name release];
        _name = [aName retain];
    }
    return self;
}

- (id)init
{
    return [self initWithDictionaryRepresentation:nil photos:nil version:0];
}

@end
