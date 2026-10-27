#import "HSGraphicsLibraryAnimationsMediaItem.h"
#import <objc/message.h>

// A built-in animations folder of the library: its own animations and its
// subfolders' (sorted); subfolders (but hidden ones) are subitems.

@implementation HSGraphicsLibraryAnimationsMediaItem

- (id)copyWithZone:(NSZone *)aZone
{
    return [self retain];
}

- (id)folderImage
{
    if (_folderImage == nil) {
        NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"LibraryGenericFolder" ofType:@"tiff"];
        if (path != nil)
            _folderImage = [[NSImage alloc] initWithContentsOfFile:path];
    }
    return _folderImage;
}

- (id)subItems
{
    if (_subItems == nil) {
        _subItems = [[NSMutableArray alloc] initWithCapacity:0];
        NSFileManager *manager = [NSFileManager defaultManager];
        for (NSString *name in [manager contentsOfDirectoryAtPath:_path error:NULL]) {
            NSString *path = [_path stringByAppendingPathComponent:name];
            NSDictionary *attributes = [manager attributesOfItemAtPath:[path stringByResolvingSymlinksInPath] error:NULL];
            if (![[attributes objectForKey:NSFileType] isEqualToString:NSFileTypeDirectory] || [name hasPrefix:@"."])
                continue;
            HSGraphicsLibraryAnimationsMediaItem *item = [[HSGraphicsLibraryAnimationsMediaItem alloc] initWithProvider:_dataProvider path:path];
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
        [HSGraphicsLibraryMoviesHelper plainScanDirectory:_path fileTypes:[HSGraphicsLibraryMoviesHelper animationsFileTypes] toArray:_children insertClass:[HSGraphicsLibraryAnimation class]];
        NSInteger count = [self numberOfSubitems];
        for (NSInteger i = 0; i < count; i++) {
            id folder = [self subitemAtIndex:i];
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
    NSArray *items = [self subItems];
    return aIndex < [items count] ? [items objectAtIndex:aIndex] : nil;
}

- (NSUInteger)numberOfSubitems
{
    return [[self subItems] count];
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
    return [[_path lastPathComponent] stringByDeletingPathExtension];
}

// The folder image with subfolders, else the library's icon.
- (id)icon
{
    if ([self numberOfSubitems] != 0)
        return [self folderImage];
    return [_dataProvider mediaIcon];
}

- (void)dealloc
{
    [_children release];
    [_path release];
    [_subItems release];
    [_folderImage release];
    [super dealloc];
}

// (The provider isn't retained.)
- (id)initWithProvider:(id)aProvider path:(id)aPath
{
    if ((self = [super init])) {
        _dataProvider = aProvider;
        _path = [aPath copy];
    }
    return self;
}

@end
