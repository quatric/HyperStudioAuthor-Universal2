#import "NSBezierPath+BTPixelizing.h"

@implementation NSBezierPath (BTPixelizing)

// The flattened path with every point on the grid of aStep and every line a
// staircase of whole steps.
- (id)BT_bezierPathByPixelizingPathWithStep:(NSSize)aStep
{
    NSBezierPath *result = [NSBezierPath bezierPath];
    NSBezierPath *flat = [self bezierPathByFlatteningPath];
    NSInteger count = [flat elementCount];
    NSPoint last = NSZeroPoint;
    // A close path has no points of its own: the line goes to the previous
    // element's point.
    NSPoint p[3] = {{0}};
    for (NSInteger i = 0; i < count; i++) {
        switch ([flat elementAtIndex:i associatedPoints:p]) {
        case NSBezierPathElementMoveTo:
            last = p[0];
            [result moveToPoint:NSMakePoint(round(p[0].x / aStep.width) * aStep.width,
                                            round(p[0].y / aStep.height) * aStep.height)];
            break;
        case NSBezierPathElementLineTo:
            [result BT_appendBezierPathWithPixelizedLineToPoint:p[0] otherPoint:last pixelizationStep:aStep];
            last = p[0];
            break;
        case NSBezierPathElementCurveTo:
            break;
        case NSBezierPathElementClosePath:
            [result BT_appendBezierPathWithPixelizedLineToPoint:p[0] otherPoint:last pixelizationStep:aStep];
            [result closePath];
            last = p[0];
            break;
        default:
            NSLog(@"Unknown bezier path lement.");
        }
    }
    return result;
}

// From the current point to aPoint on the grid; diagonals step along the
// line through aPoint and aPoint2, sideways where it's nearer the next column
// than the next row.
- (void)BT_appendBezierPathWithPixelizedLineToPoint:(NSPoint)aPoint otherPoint:(NSPoint)aPoint2 pixelizationStep:(NSSize)aStep
{
    NSPoint current = [self currentPoint];
    CGFloat w = aStep.width, h = aStep.height;
    CGFloat px = round(aPoint.x / w) * w, py = round(aPoint.y / h) * h;
    CGFloat fx = w * 0.1, fy = h * 0.1;
    if (current.x - fx <= px && px <= current.x + fx) {
        [self lineToPoint:NSMakePoint(current.x, py)];
        return;
    }
    if (current.y - fy <= py && py <= current.y + fy) {
        [self lineToPoint:NSMakePoint(px, current.y)];
        return;
    }
    CGFloat slope = (aPoint.y - aPoint2.y) / (aPoint.x - aPoint2.x);
    CGFloat intercept = fma(-slope, aPoint.x, aPoint.y);
    CGFloat dx = px <= current.x ? -w : w, dy = py <= current.y ? -h : h;
    CGFloat x = current.x, y = current.y, nextX = x + dx, nextY = y + dy;
    CGFloat remainingY = fabs(py - nextY), remainingX = fabs(px - nextX);
    while (-fx <= remainingX || -fy <= remainingY) {
        CGFloat here = fma(slope, x, intercept), there = fma(slope, nextX, intercept);
        if (fabs(there - y) <= fabs(here - nextY)) {
            remainingX -= w;
            [self lineToPoint:NSMakePoint(nextX, y)];
            x = nextX;
            nextX += dx;
        } else {
            remainingY -= h;
            [self lineToPoint:NSMakePoint(x, nextY)];
            y = nextY;
            nextY += dy;
        }
    }
}

@end
