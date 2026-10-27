#import "KeynoteBezierPathsBuilder.h"

@implementation KeynoteBezierPathsBuilder

// Star and polygon paths are built on a 20 x 20 box, centered at (0, 0) and flipped; the size is not used.
+ (id)starPathWithNumberOfCorners:(NSInteger)aCorners inscribedToCircumscribedCirclesRatio:(CGFloat)aRatio size:(NSSize)aSize
{
    NSBezierPath *path = [NSBezierPath bezierPath];
    float step = (6.2831855f / (float)aCorners) * 0.5f;
    float angle = step;
    NSInteger i;

    [path moveToPoint:NSMakePoint(0.0, 10.0)];
    for (i = 0; i < aCorners; i++) {
        [path hyperLineToPoint:NSMakePoint((float)sin(angle) * aRatio * 10.0, (float)cos(angle) * aRatio * 10.0)];
        angle += step;
        [path hyperLineToPoint:NSMakePoint((float)(sin(angle) * 10.0), (float)(cos(angle) * 10.0))];
        angle += step;
    }
    [path closePath];
    [path transformUsingAffineTransform:[NSAffineTransform transformWithHyperCGAffineTransform:CGAffineTransformMake(1.0, 0.0, 0.0, -1.0, 0.0, 20.0)]];
    return path;
}

+ (id)polygonPathWithNumberOfCorners:(NSInteger)aCorners size:(NSSize)aSize
{
    NSBezierPath *path = [NSBezierPath bezierPath];
    float step = 6.2831855f / (float)aCorners;
    float angle = step;
    NSInteger i;

    [path moveToPoint:NSMakePoint(0.0, 10.0)];
    for (i = 1; i < aCorners; i++) {
        [path hyperLineToPoint:NSMakePoint((float)(sin(angle) * 10.0), (float)(cos(angle) * 10.0))];
        angle += step;
    }
    [path hyperClosePath];
    [path transformUsingAffineTransform:[NSAffineTransform transformWithHyperCGAffineTransform:CGAffineTransformMake(1.0, 0.0, 0.0, -1.0, 0.0, 20.0)]];
    return path;
}

+ (id)doubleArrowPathWithFlippedControlPointX:(CGFloat)aX controlPointVerticalOffsetToPathHeightRatio:(CGFloat)aRatio size:(NSSize)aSize
{
    NSBezierPath *path = [NSBezierPath bezierPath];
    float rightX = aSize.width - aX;
    float bottom = aSize.height * aRatio;
    float top = aSize.height * (1.0 - aRatio);

    [path moveToPoint:NSMakePoint(0.0, aSize.height * 0.5)];
    [path hyperLineToPoint:NSMakePoint(aX, 0.0)];
    [path hyperLineToPoint:NSMakePoint(aX, bottom)];
    [path hyperLineToPoint:NSMakePoint(rightX, bottom)];
    [path hyperLineToPoint:NSMakePoint(rightX, 0.0)];
    [path hyperLineToPoint:NSMakePoint(aSize.width, aSize.height * 0.5)];
    [path hyperLineToPoint:NSMakePoint(rightX, aSize.height)];
    [path hyperLineToPoint:NSMakePoint(rightX, top)];
    [path hyperLineToPoint:NSMakePoint(aX, top)];
    [path hyperLineToPoint:NSMakePoint(aX, aSize.height)];
    [path hyperClosePath];
    return path;
}

+ (id)rightArrowPathWithFlippedControlPointX:(CGFloat)aX controlPointVerticalOffsetToPathHeightRatio:(CGFloat)aRatio size:(NSSize)aSize
{
    NSBezierPath *path = [NSBezierPath bezierPath];
    float headX = aSize.width - aX;
    float bottom = aSize.height * aRatio;
    float top = aSize.height * (1.0 - aRatio);

    [path moveToPoint:NSMakePoint(0.0, bottom)];
    [path hyperLineToPoint:NSMakePoint(headX, bottom)];
    [path hyperLineToPoint:NSMakePoint(headX, 0.0)];
    [path hyperLineToPoint:NSMakePoint(aSize.width, aSize.height * 0.5)];
    [path hyperLineToPoint:NSMakePoint(headX, aSize.height)];
    [path hyperLineToPoint:NSMakePoint(headX, top)];
    [path hyperLineToPoint:NSMakePoint(0.0, top)];
    [path hyperClosePath];
    return path;
}

+ (id)roundedRectPathWithScalar:(NSInteger)aScalar size:(NSSize)aSize
{
    NSBezierPath *path = [NSBezierPath bezierPath];
    float radius = (float)aScalar;
    float half = (float)aScalar * 0.5f;

    [path moveToPoint:NSMakePoint(0.0, radius)];
    [path hyperLineToPoint:NSMakePoint(0.0, aSize.height - radius)];
    [path curveToPoint:NSMakePoint(radius, aSize.height) controlPoint1:NSMakePoint(0.0, aSize.height - half) controlPoint2:NSMakePoint(half, aSize.height)];
    [path hyperLineToPoint:NSMakePoint(aSize.width - radius, aSize.height)];
    [path curveToPoint:NSMakePoint(aSize.width, aSize.height - radius) controlPoint1:NSMakePoint(aSize.width - half, aSize.height) controlPoint2:NSMakePoint(aSize.width, aSize.height - half)];
    [path hyperLineToPoint:NSMakePoint(aSize.width, radius)];
    [path curveToPoint:NSMakePoint(aSize.width - radius, 0.0) controlPoint1:NSMakePoint(aSize.width, half) controlPoint2:NSMakePoint(aSize.width - half, 0.0)];
    [path hyperLineToPoint:NSMakePoint(radius, 0.0)];
    [path curveToPoint:NSMakePoint(0.0, radius) controlPoint1:NSMakePoint(half, 0.0) controlPoint2:NSMakePoint(0.0, half)];
    [path closePath];
    return path;
}

@end
