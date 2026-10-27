#import "HSSegmentBackgroundGraphicObject.h"

@implementation HSSegmentBackgroundGraphicObject

- (void)drawInRect:(NSRect)aRect
{
    NSBezierPath *path;
    float x;

    [[NSColor colorWithCalibratedWhite:0.85 alpha:1.0] set];
    NSRectFill(aRect);
    path = [NSBezierPath bezierPath];
    for (x = _firstGuider; x < NSMaxX(aRect); x += _guiderInterval) {
        if (x >= aRect.origin.x) {
            [path moveToPoint:NSMakePoint(floorf(x) + 0.5f, aRect.origin.y)];
            [path lineToPoint:NSMakePoint(floorf(x) + 0.5f, NSMaxY(aRect))];
        }
    }
    [[NSColor colorWithCalibratedWhite:0.5 alpha:1.0] set];
    [path stroke];
}

- (void)setGuiderInterval:(CGFloat)aInterval
{
    _guiderInterval = aInterval;
}

- (CGFloat)guiderInterval
{
    return _guiderInterval;
}

- (void)setFirstGuider:(CGFloat)aGuider
{
    _firstGuider = aGuider;
}

- (CGFloat)firstGuider
{
    return _firstGuider;
}

@end
