#import "HSImageLibraryDataSource.h"

static HSImageLibraryDataSource *HSImageLibraryDataSourceShared = nil;

@implementation HSImageLibraryDataSource

+ (id)allocWithZone:(NSZone *)aZone
{
    @synchronized(self) {
        if (!HSImageLibraryDataSourceShared) {
            HSImageLibraryDataSourceShared = [super allocWithZone:aZone];
            return HSImageLibraryDataSourceShared;
        }
    }
    return nil;
}

+ (id)sharedImageLibraryDataSource
{
    @synchronized(self) {
        if (!HSImageLibraryDataSourceShared)
            [[self alloc] init];
    }
    return HSImageLibraryDataSourceShared;
}

- (void)updateChoosableItemsIfNeeded
{
}

- (id)URLForChoosableItemAtIndex:(NSUInteger)aIndex
{
    return nil;
}

- (id)labelForChoosableItemAtIndex:(NSUInteger)aIndex
{
    return nil;
}

// Media objects are created lazily; unloaded slots hold NSNull.
- (id)mediaForChoosableItemAtIndex:(NSUInteger)aIndex
{
    id media = [[self items] objectAtIndex:aIndex];
    if (media == [NSNull null]) {
        media = [self mediaForImageWithName:[[self itemsNames] objectAtIndex:aIndex]];
        [[self items] replaceObjectAtIndex:aIndex withObject:media];
    }
    return media;
}

- (NSUInteger)countOfChoosableItems
{
    return [[self items] count];
}

- (id)items
{
    if (!_items) {
        NSUInteger count = [[self itemsNames] count];
        _items = [[NSMutableArray alloc] initWithCapacity:count];
        for (NSUInteger i = 0; i < count; i++)
            [_items addObject:[NSNull null]];
    }
    return _items;
}

- (id)itemsNames
{
    if (!_itemsNames) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"ImagesLibrary" ofType:@"plist"];
        _itemsNames = [[NSArray alloc] initWithContentsOfFile:path];
    }
    return _itemsNames;
}

- (id)mediaForImageWithName:(id)aName
{
    NSString *path = [[NSBundle mainBundle] pathForResource:[aName stringByDeletingPathExtension] ofType:[aName pathExtension] inDirectory:@"ButtonIcons"];
    return [HSNewMedia mediaWithPath:path];
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

@end
