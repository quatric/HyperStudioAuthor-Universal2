#import "HSObjectAssistantContainerView.h"

static const CGFloat HSObjectAssistantCornerRadius = 6.0;

// A shape from the top edge aTop down to the bottom of aBounds, with rounded bottom corners.
static void HSObjectAssistantAppendRoundedBottom(NSBezierPath *aPath, NSRect aBounds, CGFloat aTop)
{
    CGFloat radius = HSObjectAssistantCornerRadius;
    CGFloat width = NSWidth(aBounds);
    [aPath moveToPoint:NSMakePoint(0.0, aTop)];
    [aPath lineToPoint:NSMakePoint(0.0, radius)];
    [aPath appendBezierPathWithArcFromPoint:NSZeroPoint toPoint:NSMakePoint(radius, 0.0) radius:radius];
    [aPath lineToPoint:NSMakePoint(width - radius, 0.0)];
    [aPath appendBezierPathWithArcFromPoint:NSMakePoint(width, 0.0) toPoint:NSMakePoint(width, radius) radius:radius];
    [aPath lineToPoint:NSMakePoint(width, aTop)];
    [aPath closePath];
}

@implementation HSObjectAssistantContainerView

- (void)setFrameSize:(NSSize)aSize
{
    [_contentPath release];
    _contentPath = nil;
    [_bottomAreaPath release];
    _bottomAreaPath = nil;
    [super setFrameSize:aSize];
}

- (BOOL)mouseDownCanMoveWindow
{
    return NO;
}

- (void)drawRect:(NSRect)aRect
{
    [[NSColor colorWithCalibratedWhite:0.93f alpha:1.0] set];
    [[self contentPath] fill];
    if (![self separatesBottomArea])
        return;
    [[NSColor colorWithCalibratedWhite:0.89f alpha:1.0] set];
    [[self bottomAreaPath] fill];
    [[NSColor colorWithCalibratedWhite:0.7f alpha:1.0] set];
    NSBezierPath *line = [NSBezierPath new];
    [line moveToPoint:NSMakePoint(0.0, 43.5)];
    [line lineToPoint:NSMakePoint(NSWidth([self bounds]), 43.5)];
    [line stroke];
    [line release];
    [[NSColor colorWithCalibratedWhite:1.0 alpha:1.0] set];
    line = [NSBezierPath new];
    [line moveToPoint:NSMakePoint(0.0, 42.5)];
    [line lineToPoint:NSMakePoint(NSWidth([self bounds]), 42.5)];
    [line stroke];
    [line release];
}

- (id)bottomAreaPath
{
    if (_bottomAreaPath == nil) {
        _bottomAreaPath = [NSBezierPath new];
        HSObjectAssistantAppendRoundedBottom(_bottomAreaPath, [self bounds], 44.0);
    }
    return _bottomAreaPath;
}

- (id)contentPath
{
    if (_contentPath == nil) {
        _contentPath = [NSBezierPath new];
        HSObjectAssistantAppendRoundedBottom(_contentPath, [self bounds], NSHeight([self bounds]));
    }
    return _contentPath;
}

- (void)setSeparatesBottomArea:(BOOL)aArea
{
    if (_separatesBottomArea != aArea) {
        _separatesBottomArea = aArea;
        [self setNeedsDisplay:YES];
    }
}

- (BOOL)separatesBottomArea
{
    return _separatesBottomArea;
}

- (void)dealloc
{
    [_bottomAreaPath release];
    [_contentPath release];
    [super dealloc];
}

@end
