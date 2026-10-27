#import "HSGraphicsLibraryAnimationsAllMediaItem.h"
#import <objc/message.h>

// All the built-in animations of the library folders (sorted), with no
// subfolders.

@implementation HSGraphicsLibraryAnimationsAllMediaItem

- (id)copyWithZone:(NSZone *)aZone
{
    if ([self zone] == aZone)
        return [self retain];
    return [[[self class] allocWithZone:aZone] initWithPaths:_paths];
}

- (id)subItems
{
    if (_subItems == nil) {
        _subItems = [[NSMutableArray alloc] initWithCapacity:[_paths count]];
        for (NSString *path in _paths) {
            HSGraphicsLibraryAnimationsMediaItem *item = [[HSGraphicsLibraryAnimationsMediaItem alloc] initWithProvider:nil path:path];
            [_subItems addObject:item];
            [item release];
        }
    }
    return _subItems;
}

- (id)childrenItems
{
    if (_children == nil) {
        _children = [[NSMutableArray alloc] initWithCapacity:0];
        NSInteger count = [[self subItems] count];
        for (NSInteger i = 0; i < count; i++) {
            id folder = [[self subItems] objectAtIndex:i];
            NSInteger itemCount = [folder numberOfAnimations];
            for (NSInteger j = 0; j < itemCount; j++)
                [_children addObject:[folder animationAtIndex:j]];
        }
        if (count > 0)
            [_children sortUsingSelector:@selector(compareWithAnimation:)];
    }
    return _children;
}

// The animations the library's filter matches by name and category (by
// name only without a filter).
- (id)filterPictures:(id)aText byCategory:(id)aCategory
{
    if ([aText length] == 0 && aCategory == nil)
        return [self childrenItems];
    NSMutableArray *items = [NSMutableArray arrayWithCapacity:0];
    id filter = [[HSLibraryManager sharedLibraryManager] moviesContentFilter];
    for (id item in [self childrenItems]) {
        BOOL matches;
        if (filter == nil)
            matches = [[item displayName] rangeOfString:aText options:NSCaseInsensitiveSearch].location != NSNotFound;
        else
            matches = ((BOOL (*)(id, SEL, id, id, id))objc_msgSend)(filter, @selector(mediaItem:conformsToDisplayNameFilter:mediaTypeFilter:), [[item URL] path], aText, aCategory);
        if (matches)
            [items addObject:item];
    }
    return items;
}

- (id)animationAtIndex:(NSUInteger)aIndex
{
    NSArray *items = [self childrenItems];
    return aIndex < [items count] ? [items objectAtIndex:aIndex] : nil;
}

- (NSInteger)numberOfAnimations
{
    return [[self childrenItems] count];
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
    return [self subitemAtIndex:aIndex];
}

- (NSUInteger)numberOfDataFolders
{
    return [self numberOfSubitems];
}

- (id)dataItemAtIndex:(NSUInteger)aIndex
{
    return [self animationAtIndex:aIndex];
}

- (NSUInteger)numberOfDataItems
{
    return [self numberOfAnimations];
}

- (id)subitemAtIndex:(NSUInteger)aIndex
{
    return nil;
}

- (NSUInteger)numberOfSubitems
{
    return 0;
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
    return [[NSBundle bundleForClass:[self class]] localizedStringForKey:@"AllCategories" value:@"" table:@"LibraryMoviesBuiltIn"];
}

- (id)icon
{
    if (_iconImage == nil) {
        NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"AllCategories" ofType:@"tiff"];
        if (path != nil)
            _iconImage = [[NSImage alloc] initWithContentsOfFile:path];
    }
    return _iconImage;
}

- (void)dealloc
{
    [_children release];
    [_paths release];
    [_subItems release];
    [_iconImage release];
    [super dealloc];
}

- (id)initWithPaths:(id)aPaths
{
    if ((self = [super init]))
        _paths = [aPaths retain];
    return self;
}

@end
