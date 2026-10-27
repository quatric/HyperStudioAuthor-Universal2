#import "NSBezierPath+BTCoreGraphicsExtensions.h"

static void appendElement(void *info, const CGPathElement *element)
{
    NSBezierPath *path = info;
    const CGPoint *p = element->points;
    switch (element->type) {
    case kCGPathElementMoveToPoint:
        [path moveToPoint:p[0]];
        break;
    case kCGPathElementAddLineToPoint:
        [path lineToPoint:p[0]];
        break;
    case kCGPathElementAddQuadCurveToPoint: {
        NSPoint start = [path currentPoint];
        [path curveToPoint:p[1]
             controlPoint1:NSMakePoint(start.x + 2.0 / 3 * (p[0].x - start.x), start.y + 2.0 / 3 * (p[0].y - start.y))
             controlPoint2:NSMakePoint(p[1].x + 2.0 / 3 * (p[0].x - p[1].x), p[1].y + 2.0 / 3 * (p[0].y - p[1].y))];
        break;
    }
    case kCGPathElementAddCurveToPoint:
        [path curveToPoint:p[2] controlPoint1:p[0] controlPoint2:p[1]];
        break;
    case kCGPathElementCloseSubpath:
        [path closePath];
        break;
    }
}

@implementation NSBezierPath (BTCoreGraphicsExtensions)

+ (id)BT_bezierPathWithCGPath:(struct CGPath *)aPath
{
    NSBezierPath *path = [NSBezierPath bezierPath];
    CGPathApply(aPath, path, appendElement);
    return path;
}

// Autoreleased.
- (struct CGPath *)BT_coreGraphicsPath
{
    CGMutablePathRef path = CGPathCreateMutable();
    if (!path)
        return NULL;
    NSInteger count = [self elementCount];
    NSPoint p[3] = {{0}};
    for (NSInteger i = 0; i < count; i++) {
        switch ([self elementAtIndex:i associatedPoints:p]) {
        case NSBezierPathElementMoveTo:
            CGPathMoveToPoint(path, NULL, p[0].x, p[0].y);
            break;
        case NSBezierPathElementLineTo:
            CGPathAddLineToPoint(path, NULL, p[0].x, p[0].y);
            break;
        case NSBezierPathElementCurveTo:
            CGPathAddCurveToPoint(path, NULL, p[0].x, p[0].y, p[1].x, p[1].y, p[2].x, p[2].y);
            break;
        case NSBezierPathElementClosePath:
            CGPathCloseSubpath(path);
            break;
        default:
            NSLog(@"Unknown bezier path element.");
        }
    }
    return (CGMutablePathRef)CFAutorelease(path);
}

@end
