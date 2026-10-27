#import "HSSegmentPegGraphicObject.h"

@implementation HSSegmentPegGraphicObject

- (void)drawInRect:(NSRect)aRect
{
    if (_isHidden)
        return;

    NSRect bounds = [self bounds];
    NSBezierPath *path = [NSBezierPath bezierPath];
    CGFloat x = floorf(bounds.size.width * 0.5f + bounds.origin.x) + 0.5f;
    CGFloat y = bounds.origin.y;
    BOOL draw = YES;

    [path moveToPoint:NSMakePoint(x, y)];
    while (y < NSMaxY(bounds)) {
        if (draw)
            [path lineToPoint:NSMakePoint(x, y)];
        else
            [path moveToPoint:NSMakePoint(x, y)];
        draw = !draw;
        y += 2.5f;
    }
    [[NSColor grayColor] set];
    [path stroke];
}

- (BOOL)hitTest:(NSPoint)aTest
{
    return NSPointInRect(aTest, NSInsetRect([self bounds], -1.0f, 0.0f));
}

- (void)setHidden:(BOOL)aHidden
{
    _isHidden = aHidden;
}

- (BOOL)isHidden
{
    return _isHidden;
}

- (void)setTime:(double)aTime
{
    _time = aTime;
}

- (double)time
{
    return _time;
}

@end
