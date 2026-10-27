#import "HSCursorsLibraryDataSource.h"

static HSCursorsLibraryDataSource *sSharedDataSource = nil;

@implementation HSCursorsLibraryDataSource

+ (id)sharedCursorsLibraryDataSource
{
    if (sSharedDataSource == nil)
        sSharedDataSource = [[self alloc] init];
    return sSharedDataSource;
}

- (id)cursorAtIndex:(NSUInteger)aIndex
{
    return [[self cursors] objectAtIndex:aIndex];
}

- (NSUInteger)countOfCursors
{
    return [[self cursors] count];
}

- (id)cursors
{
    if (_cursors == nil)
        [self loadCursors];
    return _cursors;
}

// Entries name an image plus hot spot, an HSCursor class selector, or a named cursor.
- (void)loadCursors
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"CursorsLibrary" ofType:@"plist"];

    if (path == nil) {
        _cursors = [[NSArray alloc] init];
        return;
    }

    NSArray *entries = [[NSArray alloc] initWithContentsOfFile:path];
    NSMutableArray *cursors = [[NSMutableArray alloc] init];

    if ([entries count] != 0) {
        NSEnumerator *e = [entries objectEnumerator];
        id entry;
        while ((entry = [e nextObject]) != nil) {
            NSString *imageName = [entry valueForKey:@"CursorImageFileName"];
            NSString *hotSpot = [entry valueForKey:@"HotSpot"];
            NSString *selectorName = [entry valueForKey:@"CursorSelector"];
            NSString *name = [entry valueForKey:@"CursorName"];
            id cursor = nil;

            if (imageName != nil && hotSpot != nil) {
                NSImage *image = [NSImage imageNamed:imageName];
                if (image != nil) {
                    cursor = [[HSCursor alloc] initWithImage:image hotSpot:NSPointFromString(hotSpot)];
                    [cursors addObject:cursor];
                    [cursor release];
                }
                continue;
            }
            if (selectorName != nil) {
                SEL selector = NSSelectorFromString(selectorName);
                if (selector != NULL && [[HSCursor class] respondsToSelector:selector])
                    cursor = [[HSCursor class] performSelector:selector];
            } else if (name != nil) {
                cursor = [HSCursor cursorNamed:name];
            }
            if (cursor != nil)
                [cursors addObject:cursor];
        }
    }
    _cursors = [[NSArray alloc] initWithArray:cursors];
    [entries release];
    [cursors release];
}

- (void)dealloc
{
    if (sSharedDataSource == self)
        sSharedDataSource = nil;
    if (_cursors != nil)
        [_cursors release];
    [super dealloc];
}

// Original quirk kept: a second instance is torn down with [super dealloc] and the singleton returned retained.
- (id)init
{
    if (sSharedDataSource != nil) {
        [super dealloc];
        return [sSharedDataSource retain];
    }
    if (self != nil)
        sSharedDataSource = self;
    return self;
}

@end
