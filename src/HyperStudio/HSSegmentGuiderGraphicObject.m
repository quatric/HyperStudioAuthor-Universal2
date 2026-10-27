#import "HSSegmentGuiderGraphicObject.h"

@implementation HSSegmentGuiderGraphicObject

// A red one-point line down the middle of the bounds.
- (void)drawInRect:(NSRect)aRect
{
    NSBezierPath *path = [NSBezierPath bezierPath];
    NSRect bounds = [self bounds];
    float x = floorf(bounds.size.width * 0.5f + bounds.origin.x) + 0.5f;
    [path moveToPoint:NSMakePoint(x, bounds.origin.y)];
    [path lineToPoint:NSMakePoint(x, bounds.origin.y + bounds.size.height)];
    [[NSColor redColor] set];
    [path stroke];
}

- (BOOL)hitTest:(NSPoint)aTest
{
    return NSPointInRect(aTest, NSInsetRect([self bounds], -1.0, 0));
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
