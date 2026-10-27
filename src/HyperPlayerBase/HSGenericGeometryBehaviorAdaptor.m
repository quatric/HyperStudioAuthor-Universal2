#import "HSGenericGeometryBehaviorAdaptor.h"
#import "HSGeometryBehaviorApplier.h"

// Into (-pi/2, pi/2], nudged one float step toward zero.
static CGFloat HSAdaptorSkewAngle(CGAffineTransform aTransform)
{
    double angle = atan2(aTransform.a * aTransform.c + aTransform.b * aTransform.d, aTransform.a * aTransform.d - aTransform.b * aTransform.c);
    if (angle < -M_PI_2)
        angle += M_PI;
    else if (angle > M_PI_2)
        angle -= M_PI;
    return nextafterf((float)angle, 0.0f);
}

// In [0, 2pi), from the x axis (or the y axis when the x axis collapses).
static CGFloat HSAdaptorRotationAngle(CGAffineTransform aTransform, BOOL aFlippedHorizontally)
{
    CGFloat angle;
    if (aTransform.a != 0 || aTransform.b != 0) {
        if (aFlippedHorizontally)
            angle = atan2(-aTransform.b, -aTransform.a);
        else
            angle = atan2(aTransform.b, aTransform.a);
    } else {
        if (aFlippedHorizontally)
            angle = atan2(-aTransform.d, -aTransform.c) - M_PI_2;
        else
            angle = atan2(aTransform.d, aTransform.c) - M_PI_2;
    }
    if (angle < 0)
        angle += 6.2831855f;
    return angle;
}

// Scales along the rotated x axis and along the skewed y axis.
static CGAffineTransform HSAdaptorCompose(CGFloat aHorizontalScale, CGFloat aVerticalScale, CGFloat aSkewTangent, CGFloat aRotationAngle, CGFloat aX, CGFloat aY)
{
    CGFloat sine = sin(aRotationAngle), cosine = cos(aRotationAngle);
    CGAffineTransform transform;
    transform.a = aHorizontalScale * cosine;
    transform.b = aHorizontalScale * sine;
    transform.c = (cosine * aSkewTangent - sine) * aVerticalScale;
    transform.d = (sine * aSkewTangent + cosine) * aVerticalScale;
    transform.tx = aX;
    transform.ty = aY;
    return transform;
}

// Rebuilds a transform whose x or y axis collapsed, keeping its rotation and
// skew, with the given scale along x and height along y.
static CGAffineTransform HSAdaptorRebuild(CGAffineTransform aTransform, CGFloat aHorizontalScale, CGFloat aHeight)
{
    CGFloat skew = 0, rotation;
    BOOL flipped = NO;
    if (aTransform.a == 0 && aTransform.b == 0) {
        rotation = atan2(aTransform.d, aTransform.c) - M_PI_2;
    } else {
        flipped = aTransform.a * aTransform.d - aTransform.b * aTransform.c < 0;
        skew = HSAdaptorSkewAngle(aTransform);
        rotation = atan2(aTransform.b, aTransform.a);
    }
    if (rotation < 0)
        rotation += 6.2831855f;
    CGFloat tangent = tan(skew);
    CGFloat verticalScale = aHeight / hypot(tangent, 1);
    if (flipped)
        verticalScale = -verticalScale;
    return HSAdaptorCompose(aHorizontalScale, verticalScale, tangent, rotation, aTransform.tx, aTransform.ty);
}

// Scales the axes by the factors, keeping the point (in untransformed
// coordinates) in place.
static CGAffineTransform HSAdaptorScaleAbout(CGAffineTransform aTransform, CGFloat aHorizontalFactor, CGFloat aVerticalFactor, CGFloat aX, CGFloat aY)
{
    CGFloat dx = aX * (1 - aHorizontalFactor), dy = aY * (1 - aVerticalFactor);
    CGAffineTransform transform;
    transform.a = aTransform.a * aHorizontalFactor;
    transform.b = aTransform.b * aHorizontalFactor;
    transform.c = aTransform.c * aVerticalFactor;
    transform.d = aTransform.d * aVerticalFactor;
    transform.tx = aTransform.tx + aTransform.a * dx + aTransform.c * dy;
    transform.ty = aTransform.ty + aTransform.b * dx + aTransform.d * dy;
    return transform;
}

// Fits a proportional request into the aspect ratio of aRatio (a size or a
// size scale) by the maintaining rule: 1 the larger factor, 2 by width, 3 by
// height, otherwise the smaller factor.
static NSSize HSAdaptorApplyAspectRule(NSSize aTo, NSSize aRatio, NSInteger aRule)
{
    NSSize result = aTo;
    CGFloat horizontal = aTo.width / aRatio.width, vertical = aTo.height / aRatio.height;
    if (aRule == 1) {
        if (horizontal < vertical)
            result.width = aRatio.width * vertical;
        else
            result.height = aRatio.height * horizontal;
    } else if (aRule == 3) {
        result.width = aRatio.width * aTo.height / aRatio.height;
    } else if (aRule == 2) {
        result.height = aRatio.height * aTo.width / aRatio.width;
    } else {
        if (vertical < horizontal)
            result.width = aRatio.width * vertical;
        else
            result.height = aRatio.height * horizontal;
    }
    return result;
}

// Turns geometry requests into the transform and size the object's behavior
// attributes allow: what cannot move, resize, scale, flip, skew or rotate
// keeps its current value, and sizes stay within the Min/Max constraints.
@implementation HSGenericGeometryBehaviorAdaptor

+ (id)hyperImplementationWithNode:(id)aNode unit:(id)aUnit
{
    return [[[self alloc] initWithHyperObject:aNode] autorelease];
}

+ (NSSize)adaptResizingUnproportionallyFromSize:(NSSize)aSize toSize:(NSSize)aSize2 canResizeHorizontally:(BOOL)aHorizontally canResizeVertically:(BOOL)aVertically withMinSize:(NSSize)aSize3 maxSize:(NSSize)aSize4 layoutGuidingContext:(id)aContext
{
    NSSize result = aSize;
    if (aHorizontally) {
        if (aSize2.width < aSize3.width)
            result.width = aSize3.width;
        else if (aSize4.width < aSize2.width)
            result.width = aSize4.width;
        else
            result.width = aSize2.width;
    }
    if (aVertically) {
        if (aSize2.height < aSize3.height)
            result.height = aSize3.height;
        else if (aSize4.height < aSize2.height)
            result.height = aSize4.height;
        else
            result.height = aSize2.height;
    }
    return result;
}

// Keeps the from size whenever no size of its aspect ratio fits the limits;
// a target within the limits is taken as it is.
+ (NSSize)adaptResizingProportionallyFromSize:(NSSize)aSize toSize:(NSSize)aSize2 withMinSize:(NSSize)aSize3 maxSize:(NSSize)aSize4 layoutGuidingContext:(id)aContext
{
    if (aSize.width == 0 || aSize.height == 0)
        return aSize;
    CGFloat width, height;
    if (aSize2.width < aSize3.width) {
        height = aSize.height * aSize3.width / aSize.width;
        if (height <= aSize4.height) {
            if (aSize3.height <= height)
                return NSMakeSize(aSize3.width, height);
            width = aSize.width * aSize3.height / aSize.height;
            if (width <= aSize4.width)
                return NSMakeSize(width, aSize3.height);
        }
    } else if (aSize4.width < aSize2.width) {
        height = aSize.height * aSize4.width / aSize.width;
        if (aSize3.height <= height) {
            if (height <= aSize4.height)
                return NSMakeSize(aSize4.width, height);
            width = aSize.width * aSize4.height / aSize.height;
            if (aSize3.width <= width)
                return NSMakeSize(width, aSize4.height);
        }
    } else if (aSize2.height < aSize3.height) {
        width = aSize.width * aSize3.height / aSize.height;
        if (width <= aSize4.width) {
            if (aSize3.width <= width)
                return NSMakeSize(width, aSize3.height);
            height = aSize.height * aSize3.width / aSize.width;
            if (height <= aSize4.height)
                return NSMakeSize(aSize3.width, height);
        }
    } else if (aSize4.height < aSize2.height) {
        width = aSize.width * aSize4.height / aSize.height;
        if (aSize3.width <= width) {
            if (width <= aSize4.width)
                return NSMakeSize(width, aSize4.height);
            height = aSize.height * aSize4.width / aSize.width;
            if (aSize3.height <= height)
                return NSMakeSize(aSize4.width, height);
        }
    } else {
        return aSize2;
    }
    return aSize;
}

- (void)adaptResizingFrameProportionallyBy:(CGFloat)aBy aboutRelativePoint:(NSPoint)aPoint followResizingScalingPreference:(BOOL)aPreference withLayoutGuidingContext:(id)aContext adaptedSize:(NSSize *)aSize affineTransform:(CGAffineTransform *)aTransform flippedHorizontally:(BOOL *)aHorizontally
{
    BOOL canMoveHorizontally = [_geometryBehaviorAttributes canMoveHorizontally];
    BOOL canMoveVertically = [_geometryBehaviorAttributes canMoveVertically];
    NSSize size = [_geometryAttributes size];
    BOOL fixedX = !canMoveHorizontally && aPoint.x != 0;
    BOOL fixedY = !canMoveVertically && aPoint.y != 0;
    BOOL resizeHorizontally = [_geometryBehaviorAttributes canResizeHorizontally] && !fixedX;
    BOOL resizeVertically = [_geometryBehaviorAttributes canResizeVertically] && !fixedY;
    BOOL scaleHorizontally = [_geometryBehaviorAttributes canScaleHorizontally] && !fixedX;
    BOOL scaleVertically = [_geometryBehaviorAttributes canScaleVertically] && !fixedY;
    BOOL preference = aPreference;
    if (![_geometryBehaviorAttributes prefersResizingToScaling])
        preference = !preference;
    if (!resizeVertically || !resizeHorizontally || (!preference && size.width != 0 && size.height != 0 && scaleHorizontally && scaleVertically)) {
        if (aSize)
            *aSize = size;
        if (aTransform || aHorizontally)
            [self adaptSizeScalingProportionallyBy:aBy aboutRelativePoint:aPoint canScaleHorizontally:scaleHorizontally canScaleVertically:scaleVertically withLayoutGuidingContext:aContext adaptedAffineTransform:aTransform flippedHorizontally:aHorizontally];
    } else {
        [self adaptResizingProportionallyBy:aBy aboutRelativePoint:aPoint canResizeHorizontally:resizeHorizontally canResizeVertically:resizeVertically withLayoutGuidingContext:aContext adaptedSize:aSize affineTransform:aTransform flippedHorizontally:aHorizontally];
    }
}

- (void)adaptResizingFrameBy:(NSSize)aBy aboutRelativePoint:(NSPoint)aPoint followResizingScalingPreference:(BOOL)aPreference maintainAspectRatio:(NSInteger)aRatio byAspectRatioMaintainingRule:(NSInteger)aRule withLayoutGuidingContext:(id)aContext adaptedSize:(NSSize *)aSize affineTransform:(CGAffineTransform *)aTransform flippedHorizontally:(BOOL *)aHorizontally
{
    BOOL canMoveHorizontally = [_geometryBehaviorAttributes canMoveHorizontally];
    BOOL canMoveVertically = [_geometryBehaviorAttributes canMoveVertically];
    NSSize size = [_geometryAttributes size];
    BOOL fixedX = !canMoveHorizontally && aPoint.x != 0;
    BOOL fixedY = !canMoveVertically && aPoint.y != 0;
    BOOL resizeHorizontally = [_geometryBehaviorAttributes canResizeHorizontally] && !fixedX;
    BOOL resizeVertically = [_geometryBehaviorAttributes canResizeVertically] && !fixedY;
    BOOL scaleHorizontally = [_geometryBehaviorAttributes canScaleHorizontally] && !fixedX;
    BOOL scaleVertically = [_geometryBehaviorAttributes canScaleVertically] && !fixedY;
    BOOL preference = aPreference;
    if (![_geometryBehaviorAttributes prefersResizingToScaling])
        preference = !preference;
    if ((!preference && size.width != 0 && size.height != 0 && (scaleVertically || scaleHorizontally)) || (!resizeVertically && !resizeHorizontally)) {
        if (aSize)
            *aSize = size;
        if (aTransform || aHorizontally)
            [self adaptSizeScalingBy:aBy aboutRelativePoint:aPoint maintainAspectRatio:aRatio byAspectRatioMaintainingRule:aRule canScaleHorizontally:scaleHorizontally canScaleVertically:scaleVertically withLayoutGuidingContext:aContext adaptedAffineTransform:aTransform flippedHorizontally:aHorizontally];
    } else {
        [self adaptResizingBy:aBy aboutRelativePoint:aPoint maintainAspectRatio:aRatio byAspectRatioMaintainingRule:aRule canResizeHorizontally:resizeHorizontally canResizeVertically:resizeVertically withLayoutGuidingContext:aContext adaptedSize:aSize affineTransform:aTransform flippedHorizontally:aHorizontally];
    }
}

- (void)adaptResizingFrameTo:(NSSize)aTo aboutRelativePoint:(NSPoint)aPoint followResizingScalingPreference:(BOOL)aPreference maintainAspectRatio:(NSInteger)aRatio byAspectRatioMaintainingRule:(NSInteger)aRule withLayoutGuidingContext:(id)aContext adaptedSize:(NSSize *)aSize affineTransform:(CGAffineTransform *)aTransform
{
    [self adaptResizingFrameTo:aTo aboutRelativePoint:aPoint followResizingScalingPreference:aPreference maintainAspectRatio:aRatio byAspectRatioMaintainingRule:aRule withLayoutGuidingContext:aContext force:NO adaptedSize:aSize affineTransform:aTransform];
}

// Forcing treats resizing and scaling as allowed on both axes; moving limits
// still apply.
- (void)adaptResizingFrameTo:(NSSize)aTo aboutRelativePoint:(NSPoint)aPoint followResizingScalingPreference:(BOOL)aPreference maintainAspectRatio:(NSInteger)aRatio byAspectRatioMaintainingRule:(NSInteger)aRule withLayoutGuidingContext:(id)aContext force:(BOOL)aForce adaptedSize:(NSSize *)aSize affineTransform:(CGAffineTransform *)aTransform
{
    BOOL canMoveHorizontally = [_geometryBehaviorAttributes canMoveHorizontally];
    BOOL canMoveVertically = [_geometryBehaviorAttributes canMoveVertically];
    BOOL fixedX = !canMoveHorizontally && aPoint.x != 0;
    BOOL fixedY = !canMoveVertically && aPoint.y != 0;
    if (fixedX && fixedY) {
        if (aSize)
            *aSize = [_geometryAttributes size];
        if (aTransform)
            *aTransform = [_geometryAttributes affineTransform];
        return;
    }
    NSSize size = [_geometryAttributes size];
    BOOL resizeHorizontally = ([_geometryBehaviorAttributes canResizeHorizontally] || aForce) && !fixedX;
    BOOL resizeVertically = ([_geometryBehaviorAttributes canResizeVertically] || aForce) && !fixedY;
    BOOL scaleHorizontally = ([_geometryBehaviorAttributes canScaleHorizontally] || aForce) && !fixedX;
    BOOL scaleVertically = ([_geometryBehaviorAttributes canScaleVertically] || aForce) && !fixedY;
    BOOL preference = aPreference;
    if (![_geometryBehaviorAttributes prefersResizingToScaling])
        preference = !preference;
    if ((!preference && size.width != 0 && size.height != 0 && (scaleVertically || scaleHorizontally)) || (!resizeVertically && !resizeHorizontally)) {
        if (aSize)
            *aSize = size;
        if (!aTransform)
            return;
        if ((scaleVertically || scaleHorizontally) && (size.width != 0 || size.height != 0)) {
            NSSize scale;
            scale.width = size.width != 0 ? aTo.width / size.width : [_geometryAttributes widthScale];
            scale.height = size.height != 0 ? aTo.height / size.height : [_geometryAttributes heightScale];
            *aTransform = [self adaptSizeScalingTo:scale aboutRelativePoint:aPoint maintainAspectRatio:aRatio byAspectRatioMaintainingRule:aRule canScaleHorizontally:scaleHorizontally canScaleVertically:scaleVertically withLayoutGuidingContext:aContext];
        } else {
            *aTransform = [_geometryAttributes affineTransform];
        }
    } else {
        NSSize sizeScale = [_geometryAttributes sizeScale];
        NSSize to = aTo;
        if (sizeScale.width != 0)
            to.width = aTo.width / sizeScale.width;
        if (sizeScale.height != 0)
            to.height = aTo.height / sizeScale.height;
        [self adaptResizingTo:to aboutRelativePoint:aPoint maintainAspectRatio:aRatio byAspectRatioMaintainingRule:aRule canResizeHorizontally:resizeHorizontally canResizeVertically:resizeVertically withLayoutGuidingContext:aContext adaptedSize:aSize affineTransform:aTransform];
    }
}

- (void)adaptResizingFrameToHeight:(CGFloat)aHeight aboutRelativePoint:(NSPoint)aPoint followResizingScalingPreference:(BOOL)aPreference maintainAspectRatio:(NSInteger)aRatio withLayoutGuidingContext:(id)aContext adaptedSize:(NSSize *)aSize affineTransform:(CGAffineTransform *)aTransform
{
    if ([_geometryBehaviorAttributes canMoveVertically] || aPoint.y == 0) {
        BOOL canResize = [_geometryBehaviorAttributes canResizeVertically];
        BOOL canScale = [_geometryBehaviorAttributes canScaleVertically];
        if (canScale || canResize) {
            NSSize size = [_geometryAttributes size];
            BOOL preference = aPreference;
            if (![_geometryBehaviorAttributes prefersResizingToScaling])
                preference = !preference;
            if (canResize && (preference || size.height == 0 || !canScale)) {
                BOOL resizeHorizontally = [_geometryBehaviorAttributes canResizeHorizontally] && ([_geometryBehaviorAttributes canMoveHorizontally] || aPoint.x == 0);
                CGFloat height = aHeight;
                CGFloat heightScale = [_geometryAttributes heightScale];
                if (heightScale != 0)
                    height = aHeight / heightScale;
                [self adaptResizingTo:NSMakeSize(size.width, height) aboutRelativePoint:aPoint maintainAspectRatio:aRatio byAspectRatioMaintainingRule:3 canResizeHorizontally:resizeHorizontally canResizeVertically:YES withLayoutGuidingContext:aContext adaptedSize:aSize affineTransform:aTransform];
                return;
            }
            if (aSize)
                *aSize = size;
            if (aTransform) {
                if (!canScale || size.height == 0) {
                    *aTransform = [_geometryAttributes affineTransform];
                } else {
                    BOOL scaleHorizontally = [_geometryBehaviorAttributes canScaleHorizontally] && ([_geometryBehaviorAttributes canMoveHorizontally] || aPoint.x == 0);
                    NSSize scale = NSMakeSize([_geometryAttributes widthScale], aHeight / size.height);
                    *aTransform = [self adaptSizeScalingTo:scale aboutRelativePoint:aPoint maintainAspectRatio:aRatio byAspectRatioMaintainingRule:3 canScaleHorizontally:scaleHorizontally canScaleVertically:YES withLayoutGuidingContext:aContext];
                }
            }
            return;
        }
    }
    if (aSize)
        *aSize = [_geometryAttributes size];
    if (aTransform)
        *aTransform = [_geometryAttributes affineTransform];
}

- (void)adaptResizingFrameToWidth:(CGFloat)aWidth aboutRelativePoint:(NSPoint)aPoint followResizingScalingPreference:(BOOL)aPreference maintainAspectRatio:(NSInteger)aRatio withLayoutGuidingContext:(id)aContext adaptedSize:(NSSize *)aSize affineTransform:(CGAffineTransform *)aTransform
{
    if ([_geometryBehaviorAttributes canMoveHorizontally] || aPoint.x == 0) {
        BOOL canResize = [_geometryBehaviorAttributes canResizeHorizontally];
        BOOL canScale = [_geometryBehaviorAttributes canScaleHorizontally];
        if (canScale || canResize) {
            NSSize size = [_geometryAttributes size];
            BOOL preference = aPreference;
            if (![_geometryBehaviorAttributes prefersResizingToScaling])
                preference = !preference;
            if (canResize && (preference || size.width == 0 || !canScale)) {
                BOOL resizeVertically = [_geometryBehaviorAttributes canResizeVertically] && ([_geometryBehaviorAttributes canMoveVertically] || aPoint.y == 0);
                CGFloat width = aWidth;
                CGFloat widthScale = [_geometryAttributes widthScale];
                if (widthScale != 0)
                    width = aWidth / widthScale;
                [self adaptResizingTo:NSMakeSize(width, size.height) aboutRelativePoint:aPoint maintainAspectRatio:aRatio byAspectRatioMaintainingRule:2 canResizeHorizontally:YES canResizeVertically:resizeVertically withLayoutGuidingContext:aContext adaptedSize:aSize affineTransform:aTransform];
                return;
            }
            if (aSize)
                *aSize = size;
            if (aTransform) {
                if (!canScale || size.width == 0) {
                    *aTransform = [_geometryAttributes affineTransform];
                } else {
                    BOOL scaleVertically = [_geometryBehaviorAttributes canScaleVertically] && ([_geometryBehaviorAttributes canMoveVertically] || aPoint.y == 0);
                    NSSize scale = NSMakeSize(aWidth / size.width, [_geometryAttributes heightScale]);
                    *aTransform = [self adaptSizeScalingTo:scale aboutRelativePoint:aPoint maintainAspectRatio:aRatio byAspectRatioMaintainingRule:2 canScaleHorizontally:YES canScaleVertically:scaleVertically withLayoutGuidingContext:aContext];
                }
            }
            return;
        }
    }
    if (aSize)
        *aSize = [_geometryAttributes size];
    if (aTransform)
        *aTransform = [_geometryAttributes affineTransform];
}

- (CGAffineTransform)adaptRotationBy:(CGFloat)aBy aboutRelativePoint:(NSPoint)aPoint withLayoutGuidingContext:(id)aContext
{
    return [self adaptRotationBy:aBy aboutRelativePoint:aPoint canRotate:[_geometryBehaviorAttributes canRotate] withLayoutGuidingContext:aContext];
}

- (CGAffineTransform)adaptRotationTo:(CGFloat)aTo aboutRelativePoint:(NSPoint)aPoint withLayoutGuidingContext:(id)aContext
{
    if (![_geometryBehaviorAttributes canRotate])
        return [_geometryAttributes affineTransform];
    CGFloat angle = [_geometryAttributes rotationAngle];
    return [self adaptRotationBy:aTo - angle aboutRelativePoint:aPoint canRotate:YES withLayoutGuidingContext:aContext];
}

// Shears the y axis along the x axis so the skew angle grows by aBy.
- (CGAffineTransform)adaptSkewingBy:(CGFloat)aBy withLayoutGuidingContext:(id)aContext
{
    CGAffineTransform transform = [_geometryAttributes affineTransform];
    if ((transform.a == 0 && transform.b == 0) || (transform.c == 0 && transform.d == 0) || ![_geometryBehaviorAttributes canSkew])
        return transform;
    BOOL flippedHorizontally = [_geometryAttributes isFlippedHorizontally];
    BOOL flippedVertically = flippedHorizontally;
    CGFloat horizontalScale = 0, verticalScale, skew = 0;
    if (transform.a != 0 || transform.b != 0) {
        horizontalScale = hypot(transform.a, transform.b);
        CGFloat determinant = transform.a * transform.d - transform.b * transform.c;
        if (determinant < 0)
            flippedVertically = !flippedVertically;
        verticalScale = fabs(determinant) / horizontalScale;
        skew = HSAdaptorSkewAngle(transform);
    } else {
        verticalScale = hypot(transform.c, transform.d);
    }
    if (flippedHorizontally)
        horizontalScale = -horizontalScale;
    if (flippedVertically)
        verticalScale = -verticalScale;
    CGFloat shear = (tan(aBy + skew) - tan(skew)) * verticalScale / horizontalScale;
    transform.c += shear * transform.a;
    transform.d += shear * transform.b;
    return transform;
}

- (CGAffineTransform)adaptSkewingTo:(CGFloat)aTo withLayoutGuidingContext:(id)aContext
{
    CGAffineTransform transform = [_geometryAttributes affineTransform];
    if ((transform.a == 0 && transform.b == 0) || (transform.c == 0 && transform.d == 0) || ![_geometryBehaviorAttributes canSkew])
        return transform;
    BOOL flippedHorizontally = [_geometryAttributes isFlippedHorizontally];
    BOOL flippedVertically = flippedHorizontally;
    CGFloat horizontalScale = 0, verticalScale;
    if (transform.a != 0 || transform.b != 0) {
        horizontalScale = hypot(transform.a, transform.b);
        CGFloat determinant = transform.a * transform.d - transform.b * transform.c;
        if (determinant < 0)
            flippedVertically = !flippedVertically;
        verticalScale = fabs(determinant) / horizontalScale;
    } else {
        verticalScale = hypot(transform.c, transform.d);
    }
    CGFloat rotation = HSAdaptorRotationAngle(transform, flippedHorizontally);
    if (flippedHorizontally)
        horizontalScale = -horizontalScale;
    if (flippedVertically)
        verticalScale = -verticalScale;
    return HSAdaptorCompose(horizontalScale, verticalScale, tan(aTo), rotation, transform.tx, transform.ty);
}

- (CGAffineTransform)adaptFlippingVerticallyWithLayoutGuidingContext:(id)aContext
{
    CGAffineTransform transform = [_geometryAttributes affineTransform];
    if ([_geometryBehaviorAttributes canFlipVertically]) {
        CGFloat height = [_geometryAttributes height];
        transform.tx += transform.c * height;
        transform.ty += transform.d * height;
        transform.c = -transform.c;
        transform.d = -transform.d;
    }
    return transform;
}

- (void)adaptFlippingHorizontallyWithLayoutGuidingContext:(id)aContext adaptedAffineTransform:(CGAffineTransform *)aTransform flippedHorizontally:(BOOL *)aHorizontally
{
    if ([_geometryBehaviorAttributes canFlipHorizontally]) {
        if (aTransform) {
            CGFloat width = [_geometryAttributes width];
            CGAffineTransform transform = [_geometryAttributes affineTransform];
            aTransform->a = -transform.a;
            aTransform->b = -transform.b;
            aTransform->c = transform.c;
            aTransform->d = transform.d;
            aTransform->tx = transform.a * width + transform.tx;
            aTransform->ty = transform.b * width + transform.ty;
        }
        if (aHorizontally)
            *aHorizontally = ![_geometryAttributes isFlippedHorizontally];
    } else {
        if (aTransform)
            *aTransform = [_geometryAttributes affineTransform];
        if (aHorizontally)
            *aHorizontally = [_geometryAttributes isFlippedHorizontally];
    }
}

- (CGAffineTransform)adaptSizeScalingTo:(NSSize)aTo aboutRelativePoint:(NSPoint)aPoint maintainAspectRatio:(NSInteger)aRatio byAspectRatioMaintainingRule:(NSInteger)aRule withLayoutGuidingContext:(id)aContext
{
    BOOL scaleHorizontally = [_geometryBehaviorAttributes canScaleHorizontally] && ([_geometryBehaviorAttributes canMoveHorizontally] || aPoint.x == 0);
    BOOL scaleVertically = [_geometryBehaviorAttributes canScaleVertically] && ([_geometryBehaviorAttributes canMoveVertically] || aPoint.y == 0);
    if (!scaleVertically && !scaleHorizontally)
        return [_geometryAttributes affineTransform];
    return [self adaptSizeScalingTo:aTo aboutRelativePoint:aPoint maintainAspectRatio:aRatio byAspectRatioMaintainingRule:aRule canScaleHorizontally:scaleHorizontally canScaleVertically:scaleVertically withLayoutGuidingContext:aContext];
}

- (void)adaptSizeScalingProportionallyBy:(CGFloat)aBy aboutRelativePoint:(NSPoint)aPoint withLayoutGuidingContext:(id)aContext adaptedAffineTransform:(CGAffineTransform *)aTransform flippedHorizontally:(BOOL *)aHorizontally
{
    BOOL scaleHorizontally = [_geometryBehaviorAttributes canScaleHorizontally] && ([_geometryBehaviorAttributes canMoveHorizontally] || aPoint.x == 0);
    BOOL scaleVertically = [_geometryBehaviorAttributes canScaleVertically] && ([_geometryBehaviorAttributes canMoveVertically] || aPoint.y == 0);
    [self adaptSizeScalingProportionallyBy:aBy aboutRelativePoint:aPoint canScaleHorizontally:scaleHorizontally canScaleVertically:scaleVertically withLayoutGuidingContext:aContext adaptedAffineTransform:aTransform flippedHorizontally:aHorizontally];
}

- (void)adaptSizeScalingBy:(NSSize)aBy aboutRelativePoint:(NSPoint)aPoint maintainAspectRatio:(NSInteger)aRatio byAspectRatioMaintainingRule:(NSInteger)aRule withLayoutGuidingContext:(id)aContext adaptedAffineTransform:(CGAffineTransform *)aTransform flippedHorizontally:(BOOL *)aHorizontally
{
    BOOL scaleHorizontally = [_geometryBehaviorAttributes canScaleHorizontally] && ([_geometryBehaviorAttributes canMoveHorizontally] || aPoint.x == 0);
    BOOL scaleVertically = [_geometryBehaviorAttributes canScaleVertically] && ([_geometryBehaviorAttributes canMoveVertically] || aPoint.y == 0);
    [self adaptSizeScalingBy:aBy aboutRelativePoint:aPoint maintainAspectRatio:aRatio byAspectRatioMaintainingRule:aRule canScaleHorizontally:scaleHorizontally canScaleVertically:scaleVertically withLayoutGuidingContext:aContext adaptedAffineTransform:aTransform flippedHorizontally:aHorizontally];
}

- (CGAffineTransform)adaptMovingBy:(NSSize)aBy withLayoutGuidingContext:(id)aContext
{
    BOOL canMoveVertically = [_geometryBehaviorAttributes canMoveVertically];
    BOOL canMoveHorizontally = [_geometryBehaviorAttributes canMoveHorizontally];
    return [self adaptMovingBy:aBy canMoveHorizontally:canMoveHorizontally canMoveVertically:canMoveVertically withLayoutGuidingContext:aContext];
}

- (CGAffineTransform)adaptMovingVerticallyBy:(CGFloat)aBy withLayoutGuidingContext:(id)aContext
{
    return [self adaptMovingBy:NSMakeSize(0, aBy) canMoveHorizontally:NO canMoveVertically:[_geometryBehaviorAttributes canMoveVertically] withLayoutGuidingContext:aContext];
}

- (CGAffineTransform)adaptMovingHorizontallyBy:(CGFloat)aBy withLayoutGuidingContext:(id)aContext
{
    return [self adaptMovingBy:NSMakeSize(aBy, 0) canMoveHorizontally:[_geometryBehaviorAttributes canMoveHorizontally] canMoveVertically:NO withLayoutGuidingContext:aContext];
}

- (void)adaptResizingProportionallyBy:(CGFloat)aBy aboutRelativePoint:(NSPoint)aPoint withLayoutGuidingContext:(id)aContext adaptedSize:(NSSize *)aSize affineTransform:(CGAffineTransform *)aTransform flippedHorizontally:(BOOL *)aHorizontally
{
    BOOL resizeHorizontally = [_geometryBehaviorAttributes canResizeHorizontally] && ([_geometryBehaviorAttributes canMoveHorizontally] || aPoint.x == 0);
    BOOL resizeVertically = [_geometryBehaviorAttributes canResizeVertically] && ([_geometryBehaviorAttributes canMoveVertically] || aPoint.y == 0);
    [self adaptResizingProportionallyBy:aBy aboutRelativePoint:aPoint canResizeHorizontally:resizeHorizontally canResizeVertically:resizeVertically withLayoutGuidingContext:aContext adaptedSize:aSize affineTransform:aTransform flippedHorizontally:aHorizontally];
}

- (void)adaptResizingBy:(NSSize)aBy aboutRelativePoint:(NSPoint)aPoint maintainAspectRatio:(NSInteger)aRatio byAspectRatioMaintainingRule:(NSInteger)aRule withLayoutGuidingContext:(id)aContext adaptedSize:(NSSize *)aSize affineTransform:(CGAffineTransform *)aTransform flippedHorizontally:(BOOL *)aHorizontally
{
    BOOL resizeHorizontally = [_geometryBehaviorAttributes canResizeHorizontally] && ([_geometryBehaviorAttributes canMoveHorizontally] || aPoint.x == 0);
    BOOL resizeVertically = [_geometryBehaviorAttributes canResizeVertically] && ([_geometryBehaviorAttributes canMoveVertically] || aPoint.y == 0);
    [self adaptResizingBy:aBy aboutRelativePoint:aPoint maintainAspectRatio:aRatio byAspectRatioMaintainingRule:aRule canResizeHorizontally:resizeHorizontally canResizeVertically:resizeVertically withLayoutGuidingContext:aContext adaptedSize:aSize affineTransform:aTransform flippedHorizontally:aHorizontally];
}

- (void)adaptResizingTo:(NSSize)aTo aboutRelativePoint:(NSPoint)aPoint maintainAspectRatio:(NSInteger)aRatio byAspectRatioMaintainingRule:(NSInteger)aRule withLayoutGuidingContext:(id)aContext adaptedSize:(NSSize *)aSize affineTransform:(CGAffineTransform *)aTransform
{
    BOOL resizeHorizontally = [_geometryBehaviorAttributes canResizeHorizontally] && ([_geometryBehaviorAttributes canMoveHorizontally] || aPoint.x == 0);
    BOOL resizeVertically = [_geometryBehaviorAttributes canResizeVertically] && ([_geometryBehaviorAttributes canMoveVertically] || aPoint.y == 0);
    if (!resizeVertically && !resizeHorizontally) {
        if (aSize)
            *aSize = [_geometryAttributes size];
        if (aTransform)
            *aTransform = [_geometryAttributes affineTransform];
        return;
    }
    [self adaptResizingTo:aTo aboutRelativePoint:aPoint maintainAspectRatio:aRatio byAspectRatioMaintainingRule:aRule canResizeHorizontally:resizeHorizontally canResizeVertically:resizeVertically withLayoutGuidingContext:aContext adaptedSize:aSize affineTransform:aTransform];
}

- (void)adaptSize:(NSSize *)aSize affineTransform:(CGAffineTransform *)aTransform flippedHorizontally:(BOOL *)aHorizontally withLayoutGuidingContext:(id)aContext
{
    if (aSize)
        *aSize = [self adaptSize:*aSize withLayoutGuidingContext:aContext];
    if (aTransform || aHorizontally)
        [self adaptAffineTransform:aTransform flippedHorizontally:aHorizontally withLayoutGuidingContext:aContext];
}

// Decomposes the requested transform and puts back the current value of
// every component the behavior does not allow to change. Without both scales,
// or when the size scale ratio must hold, the scales follow the size scale.
- (void)adaptAffineTransform:(CGAffineTransform *)aTransform flippedHorizontally:(BOOL *)aHorizontally withLayoutGuidingContext:(id)aContext
{
    BOOL flippedHorizontally = [_geometryAttributes isFlippedHorizontally];
    BOOL requestedFlip = aHorizontally ? *aHorizontally : flippedHorizontally;
    if (!aTransform) {
        if ([_geometryBehaviorAttributes canFlipHorizontally])
            flippedHorizontally = requestedFlip;
        if (aHorizontally)
            *aHorizontally = flippedHorizontally;
        return;
    }
    CGAffineTransform transform = *aTransform;
    CGFloat horizontalScale = 0, skew = 0;
    CGFloat verticalScale = hypot(transform.c, transform.d);
    BOOL flippedVertically = requestedFlip;
    if (transform.a != 0 || transform.b != 0) {
        if (transform.a * transform.d - transform.b * transform.c < 0)
            flippedVertically = !flippedVertically;
        horizontalScale = hypot(transform.a, transform.b);
        skew = HSAdaptorSkewAngle(transform);
    }
    CGFloat rotation = HSAdaptorRotationAngle(transform, requestedFlip);
    CGFloat x = transform.tx, y = transform.ty;
    BOOL canScaleHorizontally = [_geometryBehaviorAttributes canScaleHorizontally];
    BOOL canScaleVertically = [_geometryBehaviorAttributes canScaleVertically];
    NSSize sizeScale = [_geometryAttributes sizeScale];
    if (sizeScale.width == 0 || sizeScale.height == 0 || [_geometryBehaviorAttributes canBreakSizeScaleAspectRatio]) {
        if (!canScaleHorizontally)
            horizontalScale = sizeScale.width;
        if (!canScaleVertically)
            verticalScale = sizeScale.height;
    } else if (canScaleHorizontally && canScaleVertically) {
        horizontalScale = verticalScale = MIN(horizontalScale, verticalScale);
    } else {
        horizontalScale = sizeScale.width;
        verticalScale = sizeScale.height;
    }
    if ([_geometryBehaviorAttributes canFlipHorizontally])
        flippedHorizontally = requestedFlip;
    if (![_geometryBehaviorAttributes canFlipVertically])
        flippedVertically = [_geometryAttributes isFlippedVertically];
    if (![_geometryBehaviorAttributes canSkew])
        skew = [_geometryAttributes skewAngle];
    if (![_geometryBehaviorAttributes canRotate])
        rotation = [_geometryAttributes rotationAngle];
    if (![_geometryBehaviorAttributes canMoveHorizontally])
        x = [_geometryAttributes horizontalOffset];
    if (![_geometryBehaviorAttributes canMoveVertically])
        y = [_geometryAttributes verticalOffset];
    CGFloat tangent = tan(skew);
    verticalScale /= hypot(tangent, 1);
    if (flippedHorizontally)
        horizontalScale = -horizontalScale;
    if (flippedVertically)
        verticalScale = -verticalScale;
    *aTransform = HSAdaptorCompose(horizontalScale, verticalScale, tangent, rotation, x, y);
    if (aHorizontally)
        *aHorizontally = flippedHorizontally;
}

// Rotates about the point given relative to the object's size.
- (CGAffineTransform)adaptRotationBy:(CGFloat)aBy aboutRelativePoint:(NSPoint)aPoint canRotate:(BOOL)aRotate withLayoutGuidingContext:(id)aContext
{
    CGAffineTransform transform = [_geometryAttributes affineTransform];
    if (!aRotate)
        return transform;
    CGFloat sine = sin(aBy), cosine = cos(aBy);
    NSSize size = [_geometryAttributes size];
    CGFloat pivotX = transform.a * size.width * aPoint.x + transform.c * size.height * aPoint.y + transform.tx;
    CGFloat pivotY = transform.b * size.width * aPoint.x + transform.d * size.height * aPoint.y + transform.ty;
    CGAffineTransform rotated;
    rotated.a = transform.a * cosine - transform.b * sine;
    rotated.b = transform.a * sine + transform.b * cosine;
    rotated.c = transform.c * cosine - transform.d * sine;
    rotated.d = transform.c * sine + transform.d * cosine;
    rotated.tx = transform.tx * cosine - transform.ty * sine + (1 - cosine) * pivotX + sine * pivotY;
    rotated.ty = transform.ty * cosine + transform.tx * sine + (1 - cosine) * pivotY - sine * pivotX;
    return rotated;
}

- (CGAffineTransform)adaptMovingBy:(NSSize)aBy canMoveHorizontally:(BOOL)aHorizontally canMoveVertically:(BOOL)aVertically withLayoutGuidingContext:(id)aContext
{
    CGAffineTransform transform = [_geometryAttributes affineTransform];
    if (aVertically)
        transform.ty += aBy.height;
    if (aHorizontally)
        transform.tx += aBy.width;
    return transform;
}

// A collapsed axis is first rebuilt from the transform's rotation and skew so
// that it can be scaled.
- (CGAffineTransform)adaptSizeScalingTo:(NSSize)aTo aboutRelativePoint:(NSPoint)aPoint maintainAspectRatio:(NSInteger)aRatio byAspectRatioMaintainingRule:(NSInteger)aRule canScaleHorizontally:(BOOL)aHorizontally canScaleVertically:(BOOL)aVertically withLayoutGuidingContext:(id)aContext
{
    NSSize scale = [self adaptSizeScale:aTo maintainAspectRatio:aRatio byAspectRatioMaintainingRule:aRule canScaleHorizontally:aHorizontally canScaleVertically:aVertically withLayoutGuidingContext:aContext];
    NSSize size = [_geometryAttributes size];
    CGFloat x = size.width * aPoint.x, y = size.height * aPoint.y;
    CGAffineTransform transform = [_geometryAttributes affineTransform];
    if (!aHorizontally) {
        CGFloat heightScale = hypot(transform.c, transform.d);
        if (heightScale == 0) {
            if (scale.height != 0) {
                CGFloat horizontalScale = (transform.a != 0 || transform.b != 0) ? hypot(transform.a, transform.b) : 0;
                transform = HSAdaptorRebuild(transform, horizontalScale, 1);
            }
            heightScale = 1;
        }
        return HSAdaptorScaleAbout(transform, 1, scale.height / heightScale, x, y);
    }
    if (!aVertically) {
        CGFloat widthScale = hypot(transform.a, transform.b);
        if (widthScale == 0) {
            if (scale.width != 0)
                transform = HSAdaptorRebuild(transform, 1, hypot(transform.c, transform.d));
            widthScale = 1;
        }
        return HSAdaptorScaleAbout(transform, scale.width / widthScale, 1, x, y);
    }
    CGFloat widthScale = hypot(transform.a, transform.b);
    CGFloat heightScale = hypot(transform.c, transform.d);
    BOOL rebuild = NO;
    if (widthScale == 0) {
        widthScale = 1;
        rebuild = scale.width != 0;
    }
    if (heightScale == 0) {
        heightScale = 1;
        rebuild = rebuild || scale.height != 0;
    }
    if (rebuild)
        transform = HSAdaptorRebuild(transform, widthScale, heightScale);
    return HSAdaptorScaleAbout(transform, scale.width / widthScale, scale.height / heightScale, x, y);
}

- (void)adaptSizeScalingProportionallyBy:(CGFloat)aBy aboutRelativePoint:(NSPoint)aPoint canScaleHorizontally:(BOOL)aHorizontally canScaleVertically:(BOOL)aVertically withLayoutGuidingContext:(id)aContext adaptedAffineTransform:(CGAffineTransform *)aTransform flippedHorizontally:(BOOL *)aHorizontally2
{
    NSSize sizeScale = [_geometryAttributes sizeScale];
    CGFloat horizontalFactor, verticalFactor = aBy;
    if (sizeScale.width != 0)
        horizontalFactor = [_geometryBehaviorAttributes canFlipHorizontally] ? aBy : fabs(aBy);
    else
        horizontalFactor = 1;
    if (aTransform) {
        if (aHorizontally && aVertically) {
            NSSize scale = [self adaptScalingProportionallyTo:NSMakeSize(fabs(aBy) * sizeScale.width, fabs(aBy) * sizeScale.height) withLayoutGuidingContext:aContext];
            if (sizeScale.width != 0)
                horizontalFactor = copysign(fabs(scale.width / sizeScale.width), horizontalFactor);
            if (sizeScale.height != 0) {
                verticalFactor = scale.height / sizeScale.height;
                if ([_geometryBehaviorAttributes canFlipVertically])
                    verticalFactor = copysign(fabs(verticalFactor), aBy);
            }
        } else {
            if (sizeScale.width != 0)
                horizontalFactor = copysign(1, horizontalFactor);
            if (sizeScale.height != 0)
                verticalFactor = [_geometryBehaviorAttributes canFlipVertically] ? copysign(1, aBy) : 1;
        }
        NSSize size = [_geometryAttributes size];
        *aTransform = HSAdaptorScaleAbout([_geometryAttributes affineTransform], horizontalFactor, verticalFactor, size.width * aPoint.x, size.height * aPoint.y);
    }
    if (aHorizontally2) {
        BOOL flipped = [_geometryAttributes isFlippedHorizontally];
        *aHorizontally2 = horizontalFactor < 0 ? !flipped : flipped;
    }
}

- (void)adaptSizeScalingBy:(NSSize)aBy aboutRelativePoint:(NSPoint)aPoint maintainAspectRatio:(NSInteger)aRatio byAspectRatioMaintainingRule:(NSInteger)aRule canScaleHorizontally:(BOOL)aHorizontally canScaleVertically:(BOOL)aVertically withLayoutGuidingContext:(id)aContext adaptedAffineTransform:(CGAffineTransform *)aTransform flippedHorizontally:(BOOL *)aHorizontally2
{
    NSSize sizeScale = [_geometryAttributes sizeScale];
    CGFloat verticalFactor = aBy.height;
    NSSize scale = [self adaptSizeScale:NSMakeSize(fabs(aBy.width) * sizeScale.width, fabs(aBy.height) * sizeScale.height) maintainAspectRatio:aRatio byAspectRatioMaintainingRule:aRule canScaleHorizontally:aHorizontally canScaleVertically:aVertically withLayoutGuidingContext:aContext];
    CGFloat horizontalFactor;
    if (sizeScale.width != 0) {
        horizontalFactor = scale.width / sizeScale.width;
        if ([_geometryBehaviorAttributes canFlipHorizontally])
            horizontalFactor = copysign(fabs(horizontalFactor), aBy.width);
    } else {
        horizontalFactor = 1;
    }
    if (aTransform) {
        if (sizeScale.height != 0) {
            verticalFactor = scale.height / sizeScale.height;
            if ([_geometryBehaviorAttributes canFlipVertically])
                verticalFactor = copysign(fabs(verticalFactor), aBy.height);
        }
        NSSize size = [_geometryAttributes size];
        *aTransform = HSAdaptorScaleAbout([_geometryAttributes affineTransform], horizontalFactor, verticalFactor, size.width * aPoint.x, size.height * aPoint.y);
    }
    if (aHorizontally2) {
        BOOL flipped = [_geometryAttributes isFlippedHorizontally];
        *aHorizontally2 = horizontalFactor < 0 ? !flipped : flipped;
    }
}

- (void)adaptResizingProportionallyBy:(CGFloat)aBy aboutRelativePoint:(NSPoint)aPoint canResizeHorizontally:(BOOL)aHorizontally canResizeVertically:(BOOL)aVertically withLayoutGuidingContext:(id)aContext adaptedSize:(NSSize *)aSize affineTransform:(CGAffineTransform *)aTransform flippedHorizontally:(BOOL *)aHorizontally2
{
    NSSize size = [_geometryAttributes size];
    if (aHorizontally && aVertically)
        size = [self adaptResizingProportionallyTo:NSMakeSize(size.width * fabs(aBy), size.height * fabs(aBy)) withLayoutGuidingContext:aContext];
    if (aSize)
        *aSize = size;
    if (aTransform || aHorizontally2)
        [self adaptAffineTransformForResizingByFactorToSize:size aboutRelativePoint:aPoint flipHorizontally:aBy < 0 flipVertically:aBy < 0 withLayoutGuidingContext:aContext adaptedAffineTransform:aTransform flippedHorizontally:aHorizontally2];
}

- (void)adaptResizingBy:(NSSize)aBy aboutRelativePoint:(NSPoint)aPoint maintainAspectRatio:(NSInteger)aRatio byAspectRatioMaintainingRule:(NSInteger)aRule canResizeHorizontally:(BOOL)aHorizontally canResizeVertically:(BOOL)aVertically withLayoutGuidingContext:(id)aContext adaptedSize:(NSSize *)aSize affineTransform:(CGAffineTransform *)aTransform flippedHorizontally:(BOOL *)aHorizontally2
{
    NSSize size = [_geometryAttributes size];
    size = [self adaptResizingTo:NSMakeSize(size.width * fabs(aBy.width), size.height * fabs(aBy.height)) maintainAspectRatio:aRatio byAspectRatioMaintainingRule:aRule canResizeHorizontally:aHorizontally canResizeVertically:aVertically withLayoutGuidingContext:aContext];
    if (aSize)
        *aSize = size;
    if (aTransform || aHorizontally2)
        [self adaptAffineTransformForResizingByFactorToSize:size aboutRelativePoint:aPoint flipHorizontally:aBy.width < 0 flipVertically:aBy.height < 0 withLayoutGuidingContext:aContext adaptedAffineTransform:aTransform flippedHorizontally:aHorizontally2];
}

// Keeps the relative point in place while the size changes, flipping the axes
// the behavior allows to flip.
- (void)adaptAffineTransformForResizingByFactorToSize:(NSSize)aSize aboutRelativePoint:(NSPoint)aPoint flipHorizontally:(BOOL)aHorizontally flipVertically:(BOOL)aVertically withLayoutGuidingContext:(id)aContext adaptedAffineTransform:(CGAffineTransform *)aTransform flippedHorizontally:(BOOL *)aHorizontally2
{
    BOOL flipHorizontally = aHorizontally && [_geometryBehaviorAttributes canFlipHorizontally];
    if (aTransform) {
        BOOL flipVertically = aVertically && [_geometryBehaviorAttributes canFlipVertically];
        NSSize size = [_geometryAttributes size];
        CGFloat horizontalSign = flipHorizontally ? -1 : 1;
        CGFloat verticalSign = flipVertically ? -1 : 1;
        CGAffineTransform transform = [_geometryAttributes affineTransform];
        CGFloat dx = (size.width - copysign(fabs(aSize.width), horizontalSign)) * aPoint.x;
        CGFloat dy = (size.height - copysign(fabs(aSize.height), verticalSign)) * aPoint.y;
        aTransform->a = horizontalSign * transform.a;
        aTransform->b = horizontalSign * transform.b;
        aTransform->c = verticalSign * transform.c;
        aTransform->d = verticalSign * transform.d;
        aTransform->tx = dy * transform.c + dx * transform.a + transform.tx;
        aTransform->ty = dx * transform.b + dy * transform.d + transform.ty;
    }
    if (aHorizontally2) {
        BOOL flipped = [_geometryAttributes isFlippedHorizontally];
        *aHorizontally2 = flipHorizontally ? !flipped : flipped;
    }
}

- (void)adaptResizingTo:(NSSize)aTo aboutRelativePoint:(NSPoint)aPoint maintainAspectRatio:(NSInteger)aRatio byAspectRatioMaintainingRule:(NSInteger)aRule canResizeHorizontally:(BOOL)aHorizontally canResizeVertically:(BOOL)aVertically withLayoutGuidingContext:(id)aContext adaptedSize:(NSSize *)aSize affineTransform:(CGAffineTransform *)aTransform
{
    NSSize adapted = [self adaptResizingTo:aTo maintainAspectRatio:aRatio byAspectRatioMaintainingRule:aRule canResizeHorizontally:aHorizontally canResizeVertically:aVertically withLayoutGuidingContext:aContext];
    if (aSize)
        *aSize = adapted;
    if (aTransform) {
        NSSize size = [_geometryAttributes size];
        CGAffineTransform transform = [_geometryAttributes affineTransform];
        CGFloat dx = (size.width - adapted.width) * aPoint.x;
        CGFloat dy = (size.height - adapted.height) * aPoint.y;
        transform.tx += transform.c * dy + transform.a * dx;
        transform.ty += dy * transform.d + dx * transform.b;
        *aTransform = transform;
    }
}

- (NSSize)adaptResizingProportionallyBy:(CGFloat)aBy withLayoutGuidingContext:(id)aContext
{
    NSSize size = [_geometryAttributes size];
    if ([_geometryBehaviorAttributes canResizeHorizontally] && [_geometryBehaviorAttributes canResizeVertically])
        size = [self adaptResizingProportionallyTo:NSMakeSize(size.width * aBy, size.height * aBy) withLayoutGuidingContext:aContext];
    return size;
}

- (NSSize)adaptResizingTo:(NSSize)aTo maintainAspectRatio:(NSInteger)aRatio byAspectRatioMaintainingRule:(NSInteger)aRule withLayoutGuidingContext:(id)aContext
{
    BOOL canResizeHorizontally = [_geometryBehaviorAttributes canResizeHorizontally];
    BOOL canResizeVertically = [_geometryBehaviorAttributes canResizeVertically];
    if (!canResizeVertically && !canResizeHorizontally)
        return [_geometryAttributes size];
    return [self adaptResizingTo:aTo maintainAspectRatio:aRatio byAspectRatioMaintainingRule:aRule canResizeHorizontally:canResizeHorizontally canResizeVertically:canResizeVertically withLayoutGuidingContext:aContext];
}

- (NSSize)adaptSize:(NSSize)aSize withLayoutGuidingContext:(id)aContext
{
    BOOL canResizeHorizontally = [_geometryBehaviorAttributes canResizeHorizontally];
    BOOL canResizeVertically = [_geometryBehaviorAttributes canResizeVertically];
    if (!canResizeVertically && !canResizeHorizontally)
        return [_geometryAttributes size];
    return [self adaptResizingTo:aSize maintainAspectRatio:2 byAspectRatioMaintainingRule:0 canResizeHorizontally:canResizeHorizontally canResizeVertically:canResizeVertically withLayoutGuidingContext:aContext];
}

// Request 3 with a breakable ratio and a partial scale keeps the size scale.
- (NSSize)adaptSizeScale:(NSSize)aScale maintainAspectRatio:(NSInteger)aRatio byAspectRatioMaintainingRule:(NSInteger)aRule canScaleHorizontally:(BOOL)aHorizontally canScaleVertically:(BOOL)aVertically withLayoutGuidingContext:(id)aContext
{
    NSSize sizeScale = [_geometryAttributes sizeScale];
    if (sizeScale.width != 0 && sizeScale.height != 0) {
        BOOL partial = !aHorizontally || !aVertically;
        if ([_geometryBehaviorAttributes canBreakSizeScaleAspectRatio]) {
            if (!partial) {
                if ([self maintainsSizeScaleAspectRatioWithRequest:aRatio])
                    return [self adaptScalingProportionallyTo:HSAdaptorApplyAspectRule(aScale, sizeScale, aRule) withLayoutGuidingContext:aContext];
                return [self adaptScalingUnproportionallyTo:aScale canScaleHorizontally:aHorizontally canScaleVertically:aVertically withLayoutGuidingContext:aContext];
            }
        } else {
            if (partial)
                return sizeScale;
            return [self adaptScalingProportionallyTo:HSAdaptorApplyAspectRule(aScale, sizeScale, aRule) withLayoutGuidingContext:aContext];
        }
    }
    if (aRatio == 3)
        return sizeScale;
    return [self adaptScalingUnproportionallyTo:aScale canScaleHorizontally:aHorizontally canScaleVertically:aVertically withLayoutGuidingContext:aContext];
}

- (NSSize)adaptResizingTo:(NSSize)aTo maintainAspectRatio:(NSInteger)aRatio byAspectRatioMaintainingRule:(NSInteger)aRule canResizeHorizontally:(BOOL)aHorizontally canResizeVertically:(BOOL)aVertically withLayoutGuidingContext:(id)aContext
{
    NSSize size = [_geometryAttributes size];
    if (size.width != 0 && size.height != 0) {
        BOOL partial = !aHorizontally || !aVertically;
        if ([_geometryBehaviorAttributes canBreakSizeAspectRatio]) {
            if (!partial) {
                if ([self maintainsSizeAspectRatioWithRequest:aRatio])
                    return [self adaptResizingProportionallyTo:HSAdaptorApplyAspectRule(aTo, size, aRule) withLayoutGuidingContext:aContext];
                return [self adaptResizingUnproportionallyTo:aTo canResizeHorizontally:aHorizontally canResizeVertically:aVertically withLayoutGuidingContext:aContext];
            }
        } else {
            if (partial)
                return size;
            return [self adaptResizingProportionallyTo:HSAdaptorApplyAspectRule(aTo, size, aRule) withLayoutGuidingContext:aContext];
        }
    }
    if (aRatio == 3)
        return size;
    return [self adaptResizingUnproportionallyTo:aTo canResizeHorizontally:aHorizontally canResizeVertically:aVertically withLayoutGuidingContext:aContext];
}

- (NSSize)adaptScalingUnproportionallyTo:(NSSize)aTo canScaleHorizontally:(BOOL)aHorizontally canScaleVertically:(BOOL)aVertically withLayoutGuidingContext:(id)aContext
{
    NSSize size = [_geometryAttributes size];
    NSSize maxSize = [self maxSize];
    NSSize minSize = [self minSize];
    NSSize frameSize = [_geometryAttributes affineFrameSize];
    NSSize adapted = [[self class] adaptResizingUnproportionallyFromSize:frameSize toSize:NSMakeSize(size.width * aTo.width, size.height * aTo.height) canResizeHorizontally:aHorizontally canResizeVertically:aVertically withMinSize:minSize maxSize:maxSize layoutGuidingContext:aContext];
    NSSize result = aTo;
    if (size.width != 0)
        result.width = adapted.width / size.width;
    if (size.height != 0)
        result.height = adapted.height / size.height;
    return result;
}

// With one side empty the other side alone sets both factors.
- (NSSize)adaptScalingProportionallyTo:(NSSize)aTo withLayoutGuidingContext:(id)aContext
{
    NSSize size = [_geometryAttributes size];
    if (size.width != 0 && size.height != 0) {
        NSSize maxSize = [self maxSize];
        NSSize minSize = [self minSize];
        NSSize adapted = [[self class] adaptResizingProportionallyFromSize:[_geometryAttributes affineFrameSize] toSize:NSMakeSize(aTo.width * size.width, aTo.height * size.height) withMinSize:minSize maxSize:maxSize layoutGuidingContext:aContext];
        return NSMakeSize(adapted.width / size.width, adapted.height / size.height);
    }
    if (size.width == 0) {
        if (size.height == 0)
            return aTo;
        NSSize maxSize = [self maxSize];
        NSSize minSize = [self minSize];
        NSSize adapted = [[self class] adaptResizingUnproportionallyFromSize:[_geometryAttributes affineFrameSize] toSize:NSMakeSize(0, aTo.height * size.height) canResizeHorizontally:NO canResizeVertically:YES withMinSize:minSize maxSize:maxSize layoutGuidingContext:aContext];
        CGFloat factor = adapted.height / size.height;
        return NSMakeSize(factor, factor);
    }
    NSSize maxSize = [self maxSize];
    NSSize minSize = [self minSize];
    NSSize adapted = [[self class] adaptResizingUnproportionallyFromSize:[_geometryAttributes affineFrameSize] toSize:NSMakeSize(aTo.width * size.width, 0) canResizeHorizontally:YES canResizeVertically:NO withMinSize:minSize maxSize:maxSize layoutGuidingContext:aContext];
    CGFloat factor = adapted.width / size.width;
    return NSMakeSize(factor, factor);
}

// Sizes are compared with the limits after the size scale.
- (NSSize)adaptResizingUnproportionallyTo:(NSSize)aTo canResizeHorizontally:(BOOL)aHorizontally canResizeVertically:(BOOL)aVertically withLayoutGuidingContext:(id)aContext
{
    NSSize sizeScale = [_geometryAttributes sizeScale];
    NSSize size = [_geometryAttributes size];
    Class cls = [self class];
    NSSize maxSize = [self maxSize];
    NSSize minSize = [self minSize];
    CGFloat horizontal = sizeScale.width != 0 ? sizeScale.width : 1;
    CGFloat vertical = sizeScale.height != 0 ? sizeScale.height : 1;
    NSSize adapted = [cls adaptResizingUnproportionallyFromSize:NSMakeSize(size.width * horizontal, size.height * vertical) toSize:NSMakeSize(aTo.width * horizontal, aTo.height * vertical) canResizeHorizontally:aHorizontally canResizeVertically:aVertically withMinSize:minSize maxSize:maxSize layoutGuidingContext:aContext];
    return NSMakeSize(adapted.width / horizontal, adapted.height / vertical);
}

- (NSSize)adaptResizingProportionallyTo:(NSSize)aTo withLayoutGuidingContext:(id)aContext
{
    NSSize sizeScale = [_geometryAttributes sizeScale];
    NSSize size = [_geometryAttributes size];
    Class cls = [self class];
    NSSize maxSize = [self maxSize];
    NSSize minSize = [self minSize];
    CGFloat horizontal = sizeScale.width != 0 ? sizeScale.width : 1;
    CGFloat vertical = sizeScale.height != 0 ? sizeScale.height : 1;
    NSSize adapted = [cls adaptResizingProportionallyFromSize:NSMakeSize(size.width * horizontal, size.height * vertical) toSize:NSMakeSize(aTo.width * horizontal, aTo.height * vertical) withMinSize:minSize maxSize:maxSize layoutGuidingContext:aContext];
    return NSMakeSize(adapted.width / horizontal, adapted.height / vertical);
}

- (NSSize)maxSize
{
    return NSSizeFromString([_hyperObject hyperConstraintValue:@"Max" forAttribute:@selector(hyperSize)]);
}

- (NSSize)minSize
{
    return NSSizeFromString([_hyperObject hyperConstraintValue:@"Min" forAttribute:@selector(hyperSize)]);
}

// Requests: 1 the opposite of the preference, 2 never, 3 always, otherwise
// the preference.
- (BOOL)maintainsSizeScaleAspectRatioWithRequest:(NSInteger)aRequest
{
    if (aRequest == 1)
        return ![_geometryBehaviorAttributes prefersToMaintainSizeScaleAspectRatio];
    if (aRequest == 2)
        return NO;
    if (aRequest == 3)
        return YES;
    return [_geometryBehaviorAttributes prefersToMaintainSizeScaleAspectRatio];
}

- (BOOL)maintainsSizeAspectRatioWithRequest:(NSInteger)aRequest
{
    if (aRequest == 1)
        return ![_geometryBehaviorAttributes prefersToMaintainSizeAspectRatio];
    if (aRequest == 2)
        return NO;
    if (aRequest == 3)
        return YES;
    return [_geometryBehaviorAttributes prefersToMaintainSizeAspectRatio];
}

// The applier is held weakly: it lives in the autorelease pool and clears
// itself here when it goes away.
- (id)queryGeometryBehaviorApplier
{
    if (_geometryBehaviorApplier) {
        [[_geometryBehaviorApplier retain] autorelease];
    } else {
        _geometryBehaviorApplier = [[[HSGeometryBehaviorApplier alloc] initWithGeometryBehaviorAdaptor:self] autorelease];
        [_geometryBehaviorApplier registerWeakReferencer:self];
    }
    return _geometryBehaviorApplier;
}

- (id)hyperObject
{
    return _hyperObject;
}

- (void)dereferenceObject:(id)aObject
{
    if (_geometryBehaviorApplier == aObject)
        _geometryBehaviorApplier = nil;
}

- (void)dealloc
{
    [_geometryAttributes release];
    [_geometryBehaviorAttributes release];
    [_hyperObject release];
    [super dealloc];
}

// Fails unless the object has both geometry interfaces.
- (id)initWithHyperObject:(id)aObject
{
    self = [super init];
    if (self) {
        _geometryAttributes = [[aObject queryHyperInterface:@protocol(HSGeometryAttributes)] retain];
        if (_geometryAttributes) {
            _geometryBehaviorAttributes = [[aObject queryHyperInterface:@protocol(HSGeometryBehaviorAttributes)] retain];
            if (_geometryBehaviorAttributes) {
                _hyperObject = [aObject retain];
                return self;
            }
        }
        [self release];
    }
    return nil;
}

- (id)init
{
    [self release];
    return nil;
}

@end
