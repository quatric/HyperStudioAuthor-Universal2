#import "HSLibraryPicturesDataProvider.h"

// The ready-made pictures: the pictures folders.

static NSInteger HSLibraryPicturesDataProviderDefaultSortOrder = 1;

@implementation HSLibraryPicturesDataProvider

+ (id)providerMediaType
{
    return @"picture";
}

+ (NSInteger)defaultSortOrder
{
    return HSLibraryPicturesDataProviderDefaultSortOrder;
}

+ (void)setDefaultSortOrder:(NSInteger)aOrder
{
    HSLibraryPicturesDataProviderDefaultSortOrder = aOrder;
}

// The "All" item, then the folders.
- (id)rootItems
{
    if (_rootItems == nil) {
        _rootItems = [[NSMutableArray allocWithZone:[self zone]] initWithCapacity:0];
        NSArray *folders = [HSLibraryPicturesHelper picturesFolders];
        HSLibraryPicturesAllMediaItem *allItem = [[HSLibraryPicturesAllMediaItem alloc] initWithPaths:folders];
        [_rootItems addObject:allItem];
        [allItem release];
        for (NSString *folder in folders) {
            if (![[HSExcludedMediaFileTypesHelper excludedMediaFileTypes] containsObject:[folder pathExtension]])
                [_rootItems addObject:[[[HSLibraryPicturesMediaItem allocWithZone:[self zone]] initWithProvider:self path:folder] autorelease]];
        }
    }
    return _rootItems;
}

- (id)dataFolderAtIndex:(NSUInteger)aIndex
{
    NSArray *items = [self rootItems];
    if (aIndex < [items count])
        return [items objectAtIndex:aIndex];
    return nil;
}

- (NSUInteger)numberOfDataFolders
{
    return [[self rootItems] count];
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
    return self;
}

- (id)displayStringForCategory:(id)aCategory
{
    return aCategory;
}

- (id)searchCategories
{
    return nil;
}

- (id)mediaDisplayName
{
    return [[NSBundle bundleForClass:[self class]] localizedStringForKey:@"PicturesDisplayName" value:@"" table:@"LibraryGraphicsBuiltIn"];
}

- (id)mediaIcon
{
    if (_iconImage == nil) {
        NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"PicturesMedia" ofType:@"tiff"];
        if (path != nil)
            _iconImage = [[NSImage allocWithZone:[self zone]] initWithContentsOfFile:path];
    }
    return _iconImage;
}

- (id)rootItem
{
    return self;
}

- (id)dataForDescription:(id)aDescription
{
    return nil;
}

// The data are file paths.
- (id)dataForURL:(id)aURL
{
    return [aURL path];
}

- (id)descriptionForData:(id)aData
{
    return nil;
}

- (id)fileURLForData:(id)aData
{
    if (![aData isKindOfClass:[NSString class]])
        return nil;
    return [NSURL fileURLWithPath:aData];
}

- (id)displayNameForData:(id)aData
{
    if (![aData isKindOfClass:[NSString class]])
        return nil;
    return [[[[HSLibraryPicture alloc] initWithURL:[NSURL fileURLWithPath:aData]] autorelease] displayName];
}

- (id)identifierImage
{
    return nil;
}

- (id)identifierImageForData:(id)aData
{
    return nil;
}

- (id)previewImageForData:(id)aData
{
    if (![aData isKindOfClass:[NSString class]])
        return nil;
    return [[[[HSLibraryPicture alloc] initWithURL:[NSURL fileURLWithPath:aData]] autorelease] pictureImage];
}

- (id)subitemAtIndex:(NSUInteger)aIndex
{
    NSArray *items = [self rootItems];
    if (aIndex < [items count])
        return [items objectAtIndex:aIndex];
    return nil;
}

- (NSUInteger)numberOfSubitems
{
    return [[self rootItems] count];
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
    if (![aData isKindOfClass:[NSString class]])
        return NO;
    return [[HSLibraryPicturesHelper picturesFileTypes] containsObject:[[NSFileManager defaultManager] hyperFileTypeAtPath:aData]];
}

- (BOOL)supportedData:(id)aData
{
    return [self supportedData:aData error:NULL];
}

- (id)providerType
{
    return nil;
}

- (id)mediaType
{
    return [[self class] providerMediaType];
}

- (BOOL)sourceApplicationPresents
{
    return YES;
}

- (void)dealloc
{
    [_rootItems release];
    [_iconImage release];
    [super dealloc];
}

@end
