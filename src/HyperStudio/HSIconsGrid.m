#import "HSIconsGrid.h"

@implementation HSIconsGrid

- (void)sizeToCells
{
    NSView *contentView = [[self enclosingScrollView] contentView];
    NSSize cellSize = [self cellSize];
    float rows = [self numberOfRows];
    float columns = [self numberOfColumns];
    NSRect cellsRect = NSMakeRect(NSZeroPoint.x, NSZeroPoint.y, cellSize.width * columns + columns - 1.0f, cellSize.height * rows + rows - 1.0f);
    NSRect contentRect = NSMakeRect(NSZeroPoint.x, NSZeroPoint.y, [contentView frame].size.width, [contentView frame].size.height);
    if (!NSContainsRect(contentRect, cellsRect))
        [super sizeToCells];
    else
        [self setFrame:[contentView frame]];
}

- (void)mouseDown:(id)aDown
{
    id previousCell = [self selectedCell];
    [super mouseDown:aDown];
    NSPoint point = [self convertPoint:[aDown locationInWindow] fromView:nil];
    NSInteger row = -1;
    NSInteger column = -1;
    if (![self getRow:&row column:&column forPoint:point]) {
        [self deselectSelectedCell];
        if ([[self delegate] respondsToSelector:@selector(selectionDidChangeInIconsGrid:)])
            [(id)[self delegate] selectionDidChangeInIconsGrid:self];
        return;
    }
    id cell = [self cellAtRow:row column:column];
    if ([aDown clickCount] == 2) {
        if ([[self delegate] respondsToSelector:@selector(doubleClickAtIndex:inIconsGrid:)])
            [(id)[self delegate] doubleClickAtIndex:[[self cells] indexOfObject:cell] inIconsGrid:self];
    } else if (cell != previousCell) {
        if ([[self delegate] respondsToSelector:@selector(selectionDidChangeInIconsGrid:)])
            [(id)[self delegate] selectionDidChangeInIconsGrid:self];
    }
}

- (void)reloadData
{
    if ([self dataSource] != nil) {
        while ([self numberOfRows] != 0)
            [self removeRow:0];
        NSUInteger count = [[self dataSource] iconsCountInIconsGrid:self];
        for (NSUInteger i = 0; i < count; i++) {
            if ([[self cells] count] <= i)
                [self addRow];
        }
    }
    [self setNeedsDisplay:YES];
}

- (void)setDataSource:(id)aSource
{
    _dataSource = aSource;
}

- (id)dataSource
{
    return _dataSource;
}

- (id)makeCellAtRow:(NSInteger)aRow column:(NSInteger)aColumn
{
    return [[HSIconsGridCell new] autorelease];
}

- (Class)cellClass
{
    return [HSIconsGridCell class];
}

- (void)drawRect:(NSRect)aRect
{
    NSSize cellSize = [self cellSize];
    NSRect bounds = [self bounds];
    [[NSColor gridColor] set];
    NSBezierPath *path = [NSBezierPath bezierPath];
    [path setLineWidth:1.0];
    NSSize spacing = [self intercellSpacing];
    for (float x = spacing.width + cellSize.width - 0.5f; x <= bounds.size.width; x += spacing.width + cellSize.width) {
        [path moveToPoint:NSMakePoint(x, 0.0)];
        [path lineToPoint:NSMakePoint(x, bounds.size.height)];
    }
    spacing = [self intercellSpacing];
    for (float y = spacing.height + cellSize.height - 0.5f; y <= bounds.size.height; y += spacing.height + cellSize.height) {
        [path moveToPoint:NSMakePoint(0.0, y)];
        [path lineToPoint:NSMakePoint(bounds.size.width, y)];
    }
    [path stroke];
    [super drawRect:aRect];
}

- (BOOL)acceptsFirstResponder
{
    return YES;
}

- (BOOL)isOpaque
{
    return NO;
}

- (id)initWithFrame:(NSRect)aFrame
{
    self = [super initWithFrame:aFrame];
    if (self != nil) {
        [self setMode:NSRadioModeMatrix];
        [self setIntercellSpacing:NSMakeSize(1.0, 1.0)];
        [self setAllowsEmptySelection:YES];
    }
    return self;
}

@end
