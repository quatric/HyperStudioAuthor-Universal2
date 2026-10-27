#import "HSSegmentSelectionGraphicObject.h"

@implementation HSSegmentSelectionGraphicObject

// A yellow bar over the segment, rounded on the requested ends.
- (void)drawInRect:(NSRect)aRect
{
    NSRect bounds = [self bounds];
    float left = floorf(bounds.origin.x) + 0.5f;
    float right = floorf(bounds.origin.x + bounds.size.width) + 0.5f;
    float top = floorf(bounds.origin.y);
    float bottom = floorf(bounds.origin.y + bounds.size.height) - 1.0f;
    float radius = MIN(10.0f, right - left);
    NSBezierPath *path = [NSBezierPath bezierPath];
    [path moveToPoint:NSMakePoint(left + radius, top)];
    [path lineToPoint:NSMakePoint(right - radius, top)];
    if (_rightEdgeRounded) {
        [path appendBezierPathWithArcFromPoint:NSMakePoint(right, top) toPoint:NSMakePoint(right, top + radius) radius:radius];
        [path lineToPoint:NSMakePoint(right, bottom - radius)];
        [path appendBezierPathWithArcFromPoint:NSMakePoint(right, bottom) toPoint:NSMakePoint(right - radius, bottom) radius:radius];
    } else {
        [path lineToPoint:NSMakePoint(right, top)];
        [path lineToPoint:NSMakePoint(right, bottom)];
        [path lineToPoint:NSMakePoint(right - radius, bottom)];
    }
    [path lineToPoint:NSMakePoint(left + radius, bottom)];
    if (_leftEdgeRounded) {
        [path appendBezierPathWithArcFromPoint:NSMakePoint(left, bottom) toPoint:NSMakePoint(left, bottom - radius) radius:radius];
        [path lineToPoint:NSMakePoint(left, top + radius)];
        [path appendBezierPathWithArcFromPoint:NSMakePoint(left, top) toPoint:NSMakePoint(left + radius, top) radius:radius];
    } else {
        [path lineToPoint:NSMakePoint(left, bottom)];
        [path lineToPoint:NSMakePoint(left, top)];
        [path lineToPoint:NSMakePoint(left + radius, top)];
    }
    [path closePath];
    [[NSColor yellowColor] set];
    [path fill];
}

- (void)setRightEdgeRounded:(BOOL)aRounded
{
    _rightEdgeRounded = aRounded;
}

- (void)setLeftEdgeRounded:(BOOL)aRounded
{
    _leftEdgeRounded = aRounded;
}

@end
