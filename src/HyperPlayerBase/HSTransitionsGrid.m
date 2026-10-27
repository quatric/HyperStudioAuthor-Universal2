#import "HSTransitionsGrid.h"
#import "HSPlayerBaseID.h"
#import "HSTransitionEffect.h"
#import "HSTransitionGridCell.h"
#import "HSTransitionView.h"

// Data source and delegate methods of the transitions grid.
@interface NSObject (HSTransitionsGridDataSourceAndDelegate)
- (NSUInteger)transitionEffectCountInTransitionsGrid:(id)aGrid;
- (id)transitionEffectWithDisplayName:(NSString **)aName thumbnail:(NSImage **)aThumbnail atIndex:(NSUInteger)aIndex inTransitionsGrid:(id)aGrid;
- (id)startImageForTransitionEffect:(id)aEffect inTransitionsGrid:(id)aGrid;
- (id)endImageForTransitionEffect:(id)aEffect inTransitionsGrid:(id)aGrid;
- (void)selectionDidChangeInTransitionsGrid:(id)aGrid;
- (void)doubleClickOnTransitionEffect:(id)aEffect inTransitionsGrid:(id)aGrid;
@end

// Three-column grid of transition thumbnails; the selected transition previews in a view over its cell.
@implementation HSTransitionsGrid
- (void)stopPlayingIfNeeded
{
    if ([_transitionView isTransitionPlaying])
        [self HSTransitionsGrid_transitionDidEnd];
}
- (void)transitionViewDidFinishTransition:(id)aTransition
{
    if (_transitionView == aTransition)
        [self HSTransitionsGrid_transitionDidEnd];
    [super transitionViewDidFinishTransition:aTransition];
}
- (void)transitionViewDidStopTransition:(id)aTransition
{
    if (_transitionView == aTransition)
        [self HSTransitionsGrid_transitionDidEnd];
    [super transitionViewDidStopTransition:aTransition];
}
- (void)HSTransitionsGrid_transitionDidEnd
{
    [_transitionView removeFromSuperview];
    [_transitionView setTransitionEffect:nil];
}
- (id)endImageForTransitionView:(id)aView
{
    return [(id)_dataSource endImageForTransitionEffect:[[self selectedCell] representedObject] inTransitionsGrid:self];
}
- (id)startImageForTransitionView:(id)aView
{
    return [(id)_dataSource startImageForTransitionEffect:[[self selectedCell] representedObject] inTransitionsGrid:self];
}
- (id)transitionView
{
    if (_transitionView == nil) {
        _transitionView = [[HSTransitionView alloc] initWithFrame:NSZeroRect];
        [_transitionView enableOpenGLSurface];
        [_transitionView setScalesImagesToFit:YES];
        [_transitionView setDataSource:self];
        [_transitionView setDelegate:self];
    }
    return _transitionView;
}
// Plays the newly selected transition over its cell.
- (void)selectCellAtRow:(NSInteger)aRow column:(NSInteger)aColumn
{
    if ([self selectedRow] == aRow && [self selectedColumn] == aColumn)
        return;
    [super selectCellAtRow:aRow column:aColumn];
    NSCell *cell = [self selectedCell];
    if (![(HSTransitionGridCell *)cell isEmpty] && [[self delegate] respondsToSelector:@selector(selectionDidChangeInTransitionsGrid:)])
        [(id)[self delegate] selectionDidChangeInTransitionsGrid:self];
    if ([[self transitionView] isTransitionPlaying])
        [_transitionView stopTransition];
    if (![(HSTransitionGridCell *)cell isEmpty] && [_transitionView transitionDuration] > 0.0) {
        [_transitionView setFrame:[cell imageRectForBounds:[self cellFrameAtRow:[self selectedRow] column:[self selectedColumn]]]];
        [_transitionView setTransitionEffect:[cell representedObject]];
        [self addSubview:_transitionView];
        [_transitionView startTransition];
    }
}
// A single click previews the transition, a double click is passed to the delegate. Empty cells can't be selected.
- (void)mouseDown:(id)aDown
{
    NSCell *previousCell = [self selectedCell];
    [super mouseDown:aDown];
    NSPoint point = [self convertPoint:[aDown locationInWindow] fromView:nil];
    NSInteger row = -1, column = -1;
    if (![self getRow:&row column:&column forPoint:point])
        return;
    HSTransitionGridCell *cell = [self cellAtRow:row column:column];
    if (cell != previousCell && ![cell isEmpty] && [[self delegate] respondsToSelector:@selector(selectionDidChangeInTransitionsGrid:)])
        [(id)[self delegate] selectionDidChangeInTransitionsGrid:self];
    if ([cell isEmpty])
        [self selectCell:previousCell];
    if ([aDown clickCount] == 1) {
        if ([[self transitionView] isTransitionPlaying])
            [_transitionView stopTransition];
        if ([cell isEmpty] || [_transitionView transitionDuration] <= 0.0)
            return;
        [_transitionView setFrame:[cell imageRectForBounds:[self cellFrameAtRow:row column:column]]];
        [_transitionView setTransitionEffect:[cell representedObject]];
        [self addSubview:_transitionView];
        [_transitionView startTransition];
    } else if ([[self delegate] respondsToSelector:@selector(doubleClickOnTransitionEffect:inTransitionsGrid:)]) {
        [(id)[self delegate] doubleClickOnTransitionEffect:[cell representedObject] inTransitionsGrid:self];
    }
}
- (BOOL)canBecomeKeyView
{
    return YES;
}
- (void)drawRect:(NSRect)aRect
{
    [[NSColor colorWithCalibratedHue:0.605f saturation:0.21f brightness:0.5f alpha:1.0f] set];
    NSRectFill(aRect);
    [[NSGraphicsContext currentContext] saveGraphicsState];
    NSShadow *shadow = [NSShadow new];
    [shadow setShadowColor:[NSColor blackColor]];
    [shadow setShadowBlurRadius:5.0];
    [shadow setShadowOffset:NSMakeSize(2.0, -2.0)];
    [shadow set];
    [[NSColor whiteColor] set];
    NSBezierPath *path = [NSBezierPath bezierPathWithRect:NSInsetRect([self bounds], -2.5, -2.5)];
    [path setLineWidth:3.0];
    [path stroke];
    [shadow release];
    [[NSGraphicsContext currentContext] restoreGraphicsState];
    [super drawRect:aRect];
}
- (id)makeCellAtRow:(NSInteger)aRow column:(NSInteger)aColumn
{
    return [[[HSTransitionGridCell alloc] initImageCell:nil] autorelease];
}
- (Class)cellClass
{
    return [HSTransitionGridCell class];
}
- (void)setSelectedTransitionEffect:(id)aEffect
{
    if (aEffect == nil) {
        [self selectCellAtRow:0 column:0];
        return;
    }
    for (NSCell *cell in [self cells]) {
        if ([[cell representedObject] isEqual:aEffect]) {
            [self selectCell:cell];
            return;
        }
    }
}
- (id)selectedTransitionEffect
{
    return [[self selectedCell] representedObject];
}
- (void)setTransitionDuration:(double)aDuration
{
    [[self transitionView] setTransitionDuration:aDuration];
}
- (double)transitionDuration
{
    if ([self transitionView] == nil)
        return 0.0;
    return [_transitionView transitionDuration];
}
- (void)setTransitionEndImage:(id)aImage
{
    [[self transitionView] setEndImage:aImage];
}
- (void)setTransitionStartImage:(id)aImage
{
    [[self transitionView] setStartImage:aImage];
}
- (void)invalidateTransitionEndImage
{
    [[self transitionView] invalidateEndImage];
}
- (void)invalidateTransitionStartImage
{
    [[self transitionView] invalidateStartImage];
}
- (void)reloadData
{
    if ([self dataSource] == nil)
        return;
    while ([self numberOfRows] != 0)
        [self removeRow:0];
    NSUInteger count = [(id)[self dataSource] transitionEffectCountInTransitionsGrid:self];
    NSUInteger i;
    for (i = 0; i < count; i++) {
        NSString *displayName = nil;
        NSImage *thumbnail = nil;
        id effect = [(id)_dataSource transitionEffectWithDisplayName:&displayName thumbnail:&thumbnail atIndex:i inTransitionsGrid:self];
        if ([[self cells] count] <= i)
            [self addRow];
        NSCell *cell = [[self cells] objectAtIndex:i];
        if (displayName != nil)
            [cell setTitle:displayName];
        if (thumbnail != nil)
            [cell setImage:thumbnail];
        [cell setRepresentedObject:effect];
        NSString *key = [effect isSlow] ? @"HSSlowTransitionToolTip" : @"Select a transition effect.";
        [self setToolTip:[[HSPlayerBaseID bundle] localizedStringForKey:key value:@"" table:@"TransitionNames"] forCell:cell];
    }
    [self setIntercellSpacing:NSMakeSize(3.0, 1.0)];
    [self setCellSize:NSMakeSize(88.0, 84.0)];
    [self sizeToCells];
}
- (void)setDataSource:(id)aSource
{
    if (_dataSource == aSource)
        return;
    _dataSource = aSource;
    [self reloadData];
}
- (id)dataSource
{
    return _dataSource;
}
- (void)dealloc
{
    [_transitionView setDelegate:nil];
    [_transitionView setDataSource:nil];
    [_transitionView release];
    [super dealloc];
}
- (id)initWithFrame:(NSRect)aFrame
{
    self = [super initWithFrame:aFrame];
    if (self != nil) {
        [self setMode:NSRadioModeMatrix];
        [self addColumn];
        [self addColumn];
        [self addColumn];
    }
    return self;
}
@end
