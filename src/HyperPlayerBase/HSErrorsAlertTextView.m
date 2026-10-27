#import "HSErrorsAlertTextView.h"
// The text of an errors alert with the given ranges highlighted, each the
// full width of the line.
@implementation HSErrorsAlertTextView
// The ranges' rects, widened to the left edge.
- (void)highlightedRectsCalculation
{
    for (NSValue *range in _highlitedRanges) {
        NSRange glyphRange = [[self layoutManager] glyphRangeForCharacterRange:[range rangeValue] actualCharacterRange:NULL];
        NSRect rect = [[self layoutManager] boundingRectForGlyphRange:glyphRange inTextContainer:[self textContainer]];
        rect.size.width = rect.origin.x + rect.origin.x + rect.size.width;
        rect.origin.x = 0;
        [_highlightedRects addObject:[NSValue valueWithRect:rect]];
    }
}
- (void)drawRect:(NSRect)aRect
{
    if ([_highlightedRects count] == 0)
        [self highlightedRectsCalculation];
    for (NSValue *value in _highlightedRects) {
        NSRect rect = [value rectValue];
        NSRect superFrame = [[self superview] frame];
        if (rect.size.width < superFrame.size.width)
            rect.size.width = superFrame.size.width;
        [_highlitedLineColor set];
        NSFrameRect(rect);
        [_highlitedFillColor set];
        rect.origin.y += 1.0;
        rect.size.height -= 2.0;
        NSRectFillUsingOperation(rect, NSCompositingOperationSourceOver);
    }
    [super drawRect:aRect];
}
- (void)setHighlitedRanges:(id)aRanges
{
    if (_highlitedRanges != aRanges) {
        [_highlitedRanges release];
        _highlitedRanges = [aRanges retain];
        [_highlightedRects removeAllObjects];
        [self setNeedsDisplay:YES];
    }
}
- (id)highlitedRanges
{
    return _highlitedRanges;
}
// (The original didn't release the ranges.)
- (void)dealloc
{
    [_highlitedRanges release];
    [_highlightedRects release];
    [_highlitedFillColor release];
    [_highlitedLineColor release];
    [super dealloc];
}
- (void)onceInit
{
    if (_inited)
        return;
    _inited = YES;
    [self setDrawsBackground:NO];
    _highlightedRects = [NSMutableArray new];
    _highlitedFillColor = [[NSColor colorWithDeviceRed:0.929f green:0.953f blue:0.996f alpha:1.0] retain];
    _highlitedLineColor = [[NSColor colorWithDeviceRed:0.8f green:0.8f blue:0.8f alpha:1.0] retain];
}
- (id)initWithCoder:(id)aCoder
{
    self = [super initWithCoder:aCoder];
    if (self != nil)
        [self onceInit];
    return self;
}
- (id)initWithFrame:(NSRect)aFrame textContainer:(id)aContainer
{
    self = [super initWithFrame:aFrame textContainer:aContainer];
    if (self != nil)
        [self onceInit];
    return self;
}
@end
