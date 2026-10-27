#import "HSLibraryPasteboardDataProvider.h"

// Provides the pasteboard data of dragged library items: one item provides
// its own; several give their file paths, or reusable media entries (global
// UID and path) for the items one of the library's filters knows.

@implementation HSLibraryPasteboardDataProvider

+ (id)dataProviderWithItems:(id)aItems
{
    return [[[[self class] alloc] initWithItems:aItems] autorelease];
}

- (void)pasteboard:(id)aPasteboard provideDataForType:(id)aType
{
    if ([_itemsArray count] == 0)
        return;
    if ([_itemsArray count] == 1) {
        id item = [_itemsArray objectAtIndex:0];
        if ([item respondsToSelector:@selector(pasteboard:provideDataForType:)])
            [item pasteboard:aPasteboard provideDataForType:aType];
        return;
    }
    NSMutableArray *list = [NSMutableArray array];
    NSEnumerator *enumerator = [_itemsArray objectEnumerator];
    id item;
    if ([aType isEqualToString:@"HSLibraryReusableMediaPboardType"]) {
        HSLibraryManager *manager = [HSLibraryManager sharedLibraryManager];
        while ((item = [enumerator nextObject])) {
            NSString *path = [[item dataURL] path];
            if (path == nil)
                continue;
            NSString *uid = [[manager mediaContentFilter] globalUIDStringForMediaItem:path];
            if (uid == nil)
                uid = [[manager moviesContentFilter] globalUIDStringForMediaItem:path];
            if (uid == nil)
                uid = [[manager soundsContentFilter] globalUIDStringForMediaItem:path];
            if ([uid length] != 0)
                [list addObject:[NSDictionary dictionaryWithObjectsAndKeys:uid, @"HSLibraryReusableMediaGlobalUIDKey", path, @"HSLibraryReusableMediaPathKey", nil]];
        }
    } else if ([aType isEqualToString:NSFilenamesPboardType]) {
        while ((item = [enumerator nextObject])) {
            NSString *path = [[item dataURL] path];
            if (path != nil)
                [list addObject:path];
        }
    } else
        return;
    if ([list count] != 0)
        [aPasteboard setPropertyList:list forType:aType];
}

- (void)dealloc
{
    [_itemsArray release];
    [super dealloc];
}

- (id)initWithItems:(id)aItems
{
    if ((self = [super init]))
        _itemsArray = [aItems retain];
    return self;
}

@end
