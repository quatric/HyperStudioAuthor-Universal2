#import "HSLibrarySoundsDataProvider.h"

// The ready-made sounds: the sounds folders.

static NSInteger HSLibrarySoundsDataProviderDefaultSortOrder = 1;

@implementation HSLibrarySoundsDataProvider

+ (id)providerMediaType
{
    return @"sound";
}

+ (NSInteger)defaultSortOrder
{
    return HSLibrarySoundsDataProviderDefaultSortOrder;
}

+ (void)setDefaultSortOrder:(NSInteger)aOrder
{
    HSLibrarySoundsDataProviderDefaultSortOrder = aOrder;
}

- (id)invalidSoundImage
{
    if (_invalidSoundImage == nil)
        _invalidSoundImage = [[[HSImagesProvider sharedImagesProvider] imageForName:@"InvalidSoundPreview" ofType:@"tiff"] retain];
    return _invalidSoundImage;
}

- (id)previewImage
{
    if (_previewImage == nil) {
        NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"SoundPreview" ofType:@"tiff"];
        if (path != nil)
            _previewImage = [[NSImage allocWithZone:[self zone]] initWithContentsOfFile:path];
    }
    return _previewImage;
}

// The "All" item, then the folders.
- (id)rootItems
{
    if (_rootItems == nil) {
        _rootItems = [[NSMutableArray allocWithZone:[self zone]] initWithCapacity:0];
        NSArray *folders = [HSLibrarySoundsHelper soundsFolders];
        HSLibrarySoundsAllMediaItem *allItem = [[HSLibrarySoundsAllMediaItem alloc] initWithPaths:folders];
        [_rootItems addObject:allItem];
        [allItem release];
        for (NSString *folder in folders) {
            if (![[HSExcludedMediaFileTypesHelper excludedMediaFileTypes] containsObject:[folder pathExtension]])
                [_rootItems addObject:[[[HSLibrarySoundsMediaItem allocWithZone:[self zone]] initWithProvider:self path:folder] autorelease]];
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
    return [[NSBundle bundleForClass:[self class]] localizedStringForKey:@"SoundsDisplayName" value:@"" table:@"LibrarySoundsBuiltIn"];
}

- (id)mediaIcon
{
    if (_iconImage == nil) {
        NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"SoundsMedia" ofType:@"tiff"];
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
    return [[[[HSLibrarySound alloc] initWithURL:[NSURL fileURLWithPath:aData]] autorelease] displayName];
}

- (id)identifierImage
{
    return nil;
}

- (id)identifierImageForData:(id)aData
{
    return nil;
}

// A sound's preview, or the invalid one when the file can't be read.
- (id)previewImageForData:(id)aData
{
    if (![aData isKindOfClass:[NSString class]])
        return nil;
    NSURL *url = [NSURL fileURLWithPath:aData];
    if ([url isFileURL] && [[NSFileManager defaultManager] isReadableFileAtPath:[url path]])
        return [self previewImage];
    return [self invalidSoundImage];
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
    return YES;
}

- (BOOL)supportedData:(id)aData error:(id *)aError
{
    if (![aData isKindOfClass:[NSString class]])
        return NO;
    return [HSMovie canInitAsSoundOnlyWithURL:[NSURL fileURLWithPath:aData] error:aError];
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
    [_previewImage release];
    [_invalidSoundImage release];
    [super dealloc];
}

@end
