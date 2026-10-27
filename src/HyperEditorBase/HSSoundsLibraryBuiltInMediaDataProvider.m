#import "HSSoundsLibraryBuiltInMediaDataProvider.h"

// The ready-made sounds: the built-in library's folders, the "All" one first.

static NSInteger HSSoundsLibraryBuiltInMediaDataProviderDefaultSortOrder = 1;

static NSInteger HSSoundsLibraryBuiltInMediaDataProviderRootItemsCompare(id aItem, id aItem2, void *aContext)
{
    if ([[aItem mediaItem] isMemberOfClass:[HSLibrarySoundsAllMediaItem class]])
        return NSOrderedAscending;
    if ([[aItem2 mediaItem] isMemberOfClass:[HSLibrarySoundsAllMediaItem class]])
        return NSOrderedDescending;
    return [[[aItem mediaItem] displayName] compare:[[aItem2 mediaItem] displayName]];
}

@implementation HSSoundsLibraryBuiltInMediaDataProvider

+ (NSInteger)defaultSortOrder
{
    return HSSoundsLibraryBuiltInMediaDataProviderDefaultSortOrder;
}

+ (void)setDefaultSortOrder:(NSInteger)aOrder
{
    HSSoundsLibraryBuiltInMediaDataProviderDefaultSortOrder = aOrder;
}

// The built-in library's top folders, wrapped.
- (id)rootItems
{
    if (_rootItems == nil) {
        _rootItems = [[NSMutableArray allocWithZone:[self zone]] initWithCapacity:0];
        id provider = [[HSLibraryManager sharedLibraryManager] providerForMediaType:[HSLibrarySoundsDataProvider providerMediaType]];
        id rootItem = [[provider queryInterface:@protocol(HSLibraryMediaUserInterface)] rootItem];
        NSUInteger count = [rootItem numberOfSubitems];
        for (NSUInteger index = 0; index < count; index++) {
            HSLibrarySoundsDataProvider *dataProvider = [[HSLibrarySoundsDataProvider alloc] init];
            id item = [HSSoundsLibraryBuiltInMediaItem itemWithMediaItem:[rootItem subitemAtIndex:index] mediaType:[dataProvider mediaType]];
            [dataProvider release];
            if (item != nil)
                [_rootItems addObject:item];
        }
        [_rootItems sortUsingFunction:HSSoundsLibraryBuiltInMediaDataProviderRootItemsCompare context:NULL];
    }
    return _rootItems;
}

- (id)mediaDisplayName
{
    return [[NSBundle bundleForClass:[self class]] localizedStringForKey:@"BuiltInSoundsDisplayName" value:@"" table:@"LibrarySoundsBuiltIn"];
}

- (id)mediaIcon
{
    return nil;
}

- (id)rootItem
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

- (id)subitemAtIndex:(NSUInteger)aIndex
{
    return [[self rootItems] objectAtIndex:aIndex];
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
    return NO;
}

- (BOOL)supportedData:(id)aData
{
    return [self supportedData:aData error:NULL];
}

- (id)providerType
{
    return @"ReadyMade";
}

- (id)mediaType
{
    return nil;
}

- (BOOL)sourceApplicationPresents
{
    return YES;
}

- (void)dealloc
{
    [_rootItems release];
    [super dealloc];
}

@end
