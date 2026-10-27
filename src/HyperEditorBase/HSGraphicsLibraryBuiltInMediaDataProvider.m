#import "HSGraphicsLibraryBuiltInMediaDataProvider.h"

// The ready-made graphics: the built-in library's folders, the "All" one first.

static NSInteger HSGraphicsLibraryBuiltInMediaDataProviderDefaultSortOrder = 1;

static NSInteger HSGraphicsLibraryBuiltInMediaDataProviderRootItemsCompare(id aItem, id aItem2, void *aContext)
{
    if ([[aItem mediaItem] isMemberOfClass:[HSLibraryPicturesAllMediaItem class]])
        return NSOrderedAscending;
    if ([[aItem2 mediaItem] isMemberOfClass:[HSLibraryPicturesAllMediaItem class]])
        return NSOrderedDescending;
    return [[[aItem mediaItem] displayName] compare:[[aItem2 mediaItem] displayName]];
}

@implementation HSGraphicsLibraryBuiltInMediaDataProvider

+ (NSInteger)defaultSortOrder
{
    return HSGraphicsLibraryBuiltInMediaDataProviderDefaultSortOrder;
}

+ (void)setDefaultSortOrder:(NSInteger)aOrder
{
    HSGraphicsLibraryBuiltInMediaDataProviderDefaultSortOrder = aOrder;
}

// The built-in library's top folders, wrapped.
- (id)rootItems
{
    if (_rootItems == nil) {
        _rootItems = [[NSMutableArray allocWithZone:[self zone]] initWithCapacity:0];
        id provider = [[HSLibraryManager sharedLibraryManager] providerForMediaType:[HSLibraryPicturesDataProvider providerMediaType]];
        id rootItem = [[provider queryInterface:@protocol(HSLibraryMediaUserInterface)] rootItem];
        NSUInteger count = [rootItem numberOfSubitems];
        for (NSUInteger index = 0; index < count; index++) {
            HSLibraryPicturesDataProvider *dataProvider = [[HSLibraryPicturesDataProvider alloc] init];
            id item = [HSGraphicsLibraryBuiltInMediaItem itemWithMediaItem:[rootItem subitemAtIndex:index] mediaType:[dataProvider mediaType]];
            [dataProvider release];
            if (item != nil)
                [_rootItems addObject:item];
        }
        [_rootItems sortUsingFunction:HSGraphicsLibraryBuiltInMediaDataProviderRootItemsCompare context:NULL];
    }
    return _rootItems;
}

- (id)mediaDisplayName
{
    return [[NSBundle bundleForClass:[self class]] localizedStringForKey:@"BuiltInGraphicsDisplayName" value:@"" table:@"LibraryGraphicsBuiltIn"];
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
