#import "HSGraphicsLibraryBuiltinMoviesDataProvider.h"

// The ready-made animations: the animations folders.

static NSInteger HSGraphicsLibraryBuiltinMoviesDataProviderDefaultSortOrder = 1;

@implementation HSGraphicsLibraryBuiltinMoviesDataProvider

+ (NSInteger)defaultSortOrder
{
    return HSGraphicsLibraryBuiltinMoviesDataProviderDefaultSortOrder;
}

+ (void)setDefaultSortOrder:(NSInteger)aOrder
{
    HSGraphicsLibraryBuiltinMoviesDataProviderDefaultSortOrder = aOrder;
}

- (id)builtinMoviesFolders
{
    return [HSGraphicsLibraryMoviesHelper animationsFolders];
}

// The "All" item, then the folders.
- (id)rootItems
{
    if (_rootItems == nil) {
        _rootItems = [[NSMutableArray allocWithZone:[self zone]] initWithCapacity:0];
        NSArray *folders = [self builtinMoviesFolders];
        HSGraphicsLibraryAnimationsAllMediaItem *allItem = [[HSGraphicsLibraryAnimationsAllMediaItem alloc] initWithPaths:folders];
        [_rootItems addObject:allItem];
        [allItem release];
        for (NSString *folder in folders) {
            BOOL isDirectory = NO;
            [[NSFileManager defaultManager] fileExistsAtPath:folder isDirectory:&isDirectory];
            if (isDirectory)
                [_rootItems addObject:[[[HSGraphicsLibraryAnimationsMediaItem allocWithZone:[self zone]] initWithProvider:self path:folder] autorelease]];
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
    return [[NSBundle bundleForClass:[self class]] localizedStringForKey:@"BuiltinMoviesDisplayName" value:@"" table:@"LibraryMoviesBuiltIn"];
}

- (id)mediaIcon
{
    if (_medidIcon == nil) {
        NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"LibraryAnimationMedia" ofType:@"tiff"];
        if (path != nil)
            _medidIcon = [[NSImage allocWithZone:[self zone]] initWithContentsOfFile:path];
    }
    return _medidIcon;
}

- (id)rootItem
{
    return self;
}

- (id)dataForDescription:(id)aDescription
{
    return nil;
}

- (id)dataForURL:(id)aURL
{
    return nil;
}

- (id)descriptionForData:(id)aData
{
    return nil;
}

- (id)fileURLForData:(id)aData
{
    return nil;
}

- (id)displayNameForData:(id)aData
{
    return nil;
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
    return nil;
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
    return NO;
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
    return @"animation";
}

- (BOOL)sourceApplicationPresents
{
    return YES;
}

- (void)dealloc
{
    [_rootItems release];
    [_medidIcon release];
    [super dealloc];
}

@end
