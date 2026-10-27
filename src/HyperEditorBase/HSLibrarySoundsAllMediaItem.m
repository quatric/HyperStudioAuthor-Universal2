#import "HSLibrarySoundsAllMediaItem.h"

// All the built-in sounds of the library folders (sorted), with no
// subfolders.

@implementation HSLibrarySoundsAllMediaItem

- (id)subItems
{
    if (_subItems == nil) {
        _subItems = [[NSMutableArray alloc] initWithCapacity:[_paths count]];
        for (NSString *path in _paths) {
            HSLibrarySoundsMediaItem *item = [[HSLibrarySoundsMediaItem alloc] initWithProvider:nil path:path];
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
            NSInteger itemCount = [folder numberOfSounds];
            for (NSInteger j = 0; j < itemCount; j++)
                [_children addObject:[folder soundAtIndex:j]];
        }
        if (count > 0)
            [_children sortUsingSelector:@selector(compareWithSound:)];
    }
    return _children;
}

// The sounds whose names contain the text.
- (id)filterSounds:(id)aText byCategory:(id)aCategory
{
    if ([aText length] == 0)
        return [self childrenItems];
    NSMutableArray *items = [NSMutableArray arrayWithCapacity:0];
    for (id item in [self childrenItems]) {
        if ([[item displayName] rangeOfString:aText options:NSCaseInsensitiveSearch].location != NSNotFound)
            [items addObject:item];
    }
    return items;
}

- (id)soundAtIndex:(NSUInteger)aIndex
{
    NSArray *items = [self childrenItems];
    return aIndex < [items count] ? [items objectAtIndex:aIndex] : nil;
}

- (NSInteger)numberOfSounds
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
    return [self soundAtIndex:aIndex];
}

- (NSUInteger)numberOfDataItems
{
    return [self numberOfSounds];
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
    return [[NSBundle bundleForClass:[self class]] localizedStringForKey:@"AllCategories" value:@"" table:@"LibrarySoundsBuiltIn"];
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
