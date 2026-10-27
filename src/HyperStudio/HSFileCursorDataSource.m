#import "HSFileCursorDataSource.h"

@implementation HSFileCursorDataSource

- (void)setCursorFromFileName:(id)aName
{
    NSImage *image;
    HSCursor *cursor;
    NSSize size;

    if (aName == nil)
        return;
    image = [[NSImage alloc] initWithContentsOfFile:aName];
    if (image == nil)
        return;
    size = [image size];
    cursor = [[HSCursor alloc] initWithImage:image hotSpot:NSMakePoint(size.width * 0.5, size.height * 0.5)];
    [self setCursor:cursor];
    [image release];
    [cursor release];
}

- (void)setCursor:(id)aCursor
{
    if (_cursor != aCursor) {
        [_cursor release];
        _cursor = [aCursor retain];
    }
}

- (id)cursorAtIndex:(NSUInteger)aIndex
{
    return _cursor;
}

- (NSUInteger)countOfCursors
{
    return _cursor != nil;
}

- (void)dealloc
{
    [_cursor release];
    [super dealloc];
}

@end
