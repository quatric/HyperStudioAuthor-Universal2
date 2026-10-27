#import "HSPauseView.h"

@implementation HSPauseView

- (BOOL)acceptsFirstResponder
{
    return YES;
}

- (void)mouseDown:(NSEvent *)aEvent
{
    NSPoint point = [aEvent locationInWindow];
    if (NSPointInRect(point, [self pauseButtonFrame])) {
        [_delegate resumeButtonDidClick];
    }
}

- (void)drawRect:(NSRect)aRect
{
    [[NSColor colorWithCalibratedRed:0.0 green:0.0 blue:0.0 alpha:0.4] set];
    [NSBezierPath fillRect:aRect];

    NSRect frame = [self pauseButtonFrame];
    if (NSIntersectsRect(aRect, frame)) {
        NSBezierPath *circle = [NSBezierPath bezierPathWithRoundedRect:frame xRadius:5.0 yRadius:5.0];
        [circle setLineWidth:5.0];
        [[NSColor whiteColor] set];
        [circle stroke];

        CGFloat left = frame.origin.x + 10.0;
        NSBezierPath *triangle = [NSBezierPath bezierPath];
        [triangle setLineJoinStyle:NSRoundLineJoinStyle];
        [triangle setLineCapStyle:NSRoundLineCapStyle];
        [triangle setLineWidth:7.0];
        [triangle moveToPoint:NSMakePoint(left, frame.origin.y + 10.0)];
        [triangle lineToPoint:NSMakePoint(left, frame.origin.y + frame.size.height - 10.0)];
        [triangle lineToPoint:NSMakePoint(frame.origin.x + frame.size.width - 10.0,
                                          frame.origin.y + frame.size.height * 0.5)];
        [triangle lineToPoint:NSMakePoint(left, frame.origin.y + 10.0)];
        [triangle closePath];
        [triangle stroke];
        [triangle fill];
    }
}

- (void)resetCursorRects
{
    NSCursor *cursor = [NSCursor pointingHandCursor];
    [self addCursorRect:[self pauseButtonFrame] cursor:cursor];
    [cursor setOnMouseEntered:YES];
}

- (NSRect)pauseButtonFrame
{
    NSRect frame = [self frame];
    return NSMakeRect(frame.origin.x + frame.size.width * 0.5 - 50.0,
                      frame.origin.y + frame.size.height * 0.5 - 50.0,
                      100.0, 100.0);
}

- (void)setDelegate:(id <HSPauseViewDelegate>)aDelegate
{
    _delegate = aDelegate;
}

@end
