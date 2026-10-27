#import "HSYouTubeFavoritesDataProvider.h"

static HSYouTubeFavoritesDataProvider *HSYouTubeFavoritesDataProviderShared = nil;

@implementation HSYouTubeFavoritesDataProvider

+ (id)allocWithZone:(NSZone *)aZone
{
    if (!HSYouTubeFavoritesDataProviderShared) {
        HSYouTubeFavoritesDataProviderShared = [super allocWithZone:aZone];
        return HSYouTubeFavoritesDataProviderShared;
    }
    return nil;
}

+ (id)sharedYouTubeFavoritesDataProvider
{
    if (!HSYouTubeFavoritesDataProviderShared)
        [[self alloc] init];
    return HSYouTubeFavoritesDataProviderShared;
}

- (id)autorelease
{
    return self;
}

- (void)release
{
}

- (NSUInteger)retainCount
{
    return NSUIntegerMax;
}

- (id)retain
{
    return self;
}

- (id)copyWithZone:(NSZone *)aZone
{
    return self;
}

- (id)init
{
    self = [super init];
    if (self && !_dataItems)
        [self synchronize];
    return self;
}

- (void)dealloc
{
    [_dataItems release];
    [_findedItems release];
    [super dealloc];
}

// Loads the favourites list from the support folder on the first call and
// writes it back on later calls.
- (void)synchronize
{
    NSString *path = [[[HSPathsProvider sharedPathsProvider] hyperStudioSupportFolder] stringByAppendingPathComponent:@"YouTubeFavorites.plist"];
    if (!_dataItems) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:path])
            _dataItems = [[NSMutableArray alloc] initWithContentsOfFile:path];
        if (!_dataItems)
            _dataItems = [NSMutableArray new];
    } else {
        [_dataItems writeToFile:path atomically:YES];
    }
}

- (void)provideDataItemsForSearchString:(id)aString
{
    [_findedItems release];
    _findedItems = nil;
    if (aString && [aString length]) {
        _findedItems = [NSMutableArray new];
        NSEnumerator *enumerator = [_dataItems objectEnumerator];
        id item;
        while ((item = [enumerator nextObject])) {
            NSString *title = [item objectForKey:HSYouTubeDataTitleCondition];
            NSString *description = [item objectForKey:HSYouTubeDataDescriptionCondition];
            NSString *author = [item objectForKey:HSYouTubeDataAuthorCondition];
            if ([title rangeOfString:aString options:NSCaseInsensitiveSearch].location != NSNotFound
                || [description rangeOfString:aString options:NSCaseInsensitiveSearch].location != NSNotFound
                || [author rangeOfString:aString options:NSCaseInsensitiveSearch].location != NSNotFound)
                [_findedItems addObject:item];
        }
    }
}

- (void)removeItemAtIndex:(NSUInteger)aIndex
{
    if ([[self visibleDataItems] count]) {
        [_dataItems removeObject:[[self visibleDataItems] objectAtIndex:aIndex]];
        [_findedItems removeObjectAtIndex:aIndex];
        [self synchronize];
    }
}

- (void)addItem:(id)aItem
{
    if (![_dataItems containsObject:aItem]) {
        [_dataItems addObject:aItem];
        [self synchronize];
    }
}

- (id)dataValueForIndex:(NSUInteger)aIndex valueCondition:(id)aCondition
{
    return [[[self visibleDataItems] objectAtIndex:aIndex] objectForKey:aCondition];
}

- (NSUInteger)numberOfDataItems
{
    return [[self visibleDataItems] count];
}

- (id)visibleDataItems
{
    return _findedItems ? _findedItems : _dataItems;
}

@end
