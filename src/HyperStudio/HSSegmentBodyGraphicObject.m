#import "HSSegmentBodyGraphicObject.h"

@implementation HSSegmentBodyGraphicObject

- (void)drawInRect:(NSRect)aRect
{
    NSRect bounds = [self bounds];
    float left = floorf(bounds.origin.x) + 0.5f;
    float right = floorf(bounds.origin.x + bounds.size.width) + 0.5f;
    float bottom = floorf(bounds.origin.y);
    float top = floorf(bounds.origin.y + bounds.size.height) - 0.5f;
    float radius = MIN(10.0f, right - left);
    NSBezierPath *path = [NSBezierPath bezierPath];

    [path moveToPoint:NSMakePoint(left + radius, bottom)];
    [path lineToPoint:NSMakePoint(right - radius, bottom)];
    [path appendBezierPathWithArcFromPoint:NSMakePoint(right, bottom) toPoint:NSMakePoint(right, bottom + radius) radius:radius];
    [path lineToPoint:NSMakePoint(right, top - radius)];
    [path appendBezierPathWithArcFromPoint:NSMakePoint(right, top) toPoint:NSMakePoint(right - radius, top) radius:radius];
    [path lineToPoint:NSMakePoint(left + radius, top)];
    [path appendBezierPathWithArcFromPoint:NSMakePoint(left, top) toPoint:NSMakePoint(left, top - radius) radius:radius];
    [path lineToPoint:NSMakePoint(left, bottom + radius)];
    [path appendBezierPathWithArcFromPoint:NSMakePoint(left, bottom) toPoint:NSMakePoint(left + radius, bottom) radius:radius];
    [path closePath];
    [[NSColor greenColor] set];
    [path fill];
    [[NSColor darkGrayColor] set];
    [path stroke];
}

- (void)setEndValue:(double)aValue
{
    _endValue = aValue;
}

- (double)endValue
{
    return _endValue;
}

- (void)setStartValue:(double)aValue
{
    _startValue = aValue;
}

- (double)startValue
{
    return _startValue;
}

@end
