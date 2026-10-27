#import "HSFolderCursorsDataSource.h"

static const NSSize kHSMaxCursorSize = { 32.0f, 32.0f };

@implementation HSFolderCursorsDataSource

+ (id)defaultPath
{
    return [[HSPathsProvider sharedPathsProvider] userLibraryFolder];
}

- (id)cursorAtIndex:(NSUInteger)aIndex
{
    return [_cursors objectAtIndex:aIndex];
}

- (NSUInteger)countOfCursors
{
    return [_cursors count];
}

- (void)setPath:(id)aPath
{
    if (![_path isEqualToString:aPath]) {
        [_path release];
        _path = [aPath retain];
        [self updateCursors];
    }
}

- (id)path
{
    if (_path == nil)
        _path = [[[self class] defaultPath] retain];
    return _path;
}

// Every image in the folder becomes a cursor, scaled down to 32x32 when larger.
- (void)updateCursors
{
    [_cursors release];
    _cursors = nil;
    if (_path == nil)
        return;

    _cursors = [NSMutableArray new];
    NSEnumerator *e = [[[NSFileManager defaultManager] directoryContentsAtPath:_path] objectEnumerator];
    NSString *name;

    while ((name = [e nextObject]) != nil) {
        NSString *file = [[NSString stringWithString:_path] stringByAppendingPathComponent:name];
        NSString *resolved = [[NSFileManager defaultManager] hyperResolveAliasAtPath:file];
        NSArray *types = [NSImage imageFileTypes];

        if (resolved == nil)
            resolved = file;
        if (![types containsObject:[resolved pathExtension]])
            continue;

        NSImage *image = [[NSImage alloc] initWithContentsOfFile:resolved];
        if ([image size].width > kHSMaxCursorSize.width || [image size].height > kHSMaxCursorSize.height) {
            NSImage *scaled = [[[NSImage alloc] initWithSize:kHSMaxCursorSize] autorelease];
            [scaled lockFocus];
            [image drawInRect:NSMakeRect(0, 0, kHSMaxCursorSize.width, kHSMaxCursorSize.height)
                     fromRect:NSMakeRect(0, 0, [image size].width, [image size].height)
                    operation:NSCompositeSourceOver
                     fraction:1.0f];
            [scaled unlockFocus];
            [image release];
            image = [scaled retain];
        }

        NSSize size = [image size];
        // Original quirk kept: the hot spot takes half the height as x and half the width as y.
        HSCursor *cursor = [[HSCursor alloc] initWithImage:image hotSpot:NSMakePoint(size.height * 0.5f, size.width * 0.5f)];
        [_cursors addObject:cursor];
        [image release];
        [cursor release];
    }
}

- (void)dealloc
{
    [_cursors release];
    [_path release];
    [super dealloc];
}

@end
