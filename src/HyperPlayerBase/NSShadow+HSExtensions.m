#import "NSShadow+HSExtensions.h"
// Shadows as angle (radians, counter-clockwise from +x, with y down) and
// distance instead of an offset.
@implementation NSShadow (HSExtensions)
+ (CGFloat)hyperShadowDistanceWithShadowOffset:(NSSize)aOffset
{
    return sqrtf(aOffset.width * aOffset.width + aOffset.height * aOffset.height);
}
+ (NSSize)hyperShadowOffsetWithShadowDistance:(CGFloat)aDistance currentOffset:(NSSize)aOffset
{
    return [self hyperShadowOffsetWithShadowAngle:[self hyperShadowAngleWithShadowOffset:aOffset] shadowDistance:aDistance];
}
+ (NSSize)hyperShadowOffsetWithShadowAngle:(CGFloat)aAngle currentOffset:(NSSize)aOffset
{
    return [self hyperShadowOffsetWithShadowAngle:aAngle shadowDistance:[self hyperShadowDistanceWithShadowOffset:aOffset]];
}
+ (NSSize)hyperShadowOffsetWithShadowAngle:(CGFloat)aAngle shadowDistance:(CGFloat)aDistance
{
    return NSMakeSize(aDistance * cosf(aAngle), -aDistance * sinf(aAngle));
}
+ (CGFloat)hyperShadowAngleWithShadowOffset:(NSSize)aOffset
{
    return atan2f(-aOffset.height, aOffset.width);
}
// Relative tolerance for "at least 2π": 0.0005 of the larger magnitude.
static BOOL HSIsAtLeastTwoPi(float aAngle, float aTwoPi)
{
    float scale = MAX(aAngle != 0 ? fabsf(aAngle) : 1.0f, aTwoPi != 0 ? fabsf(aTwoPi) : 1.0f);
    return aAngle >= aTwoPi - scale * 0.0005f;
}
// The angle in [0, 2π). (The original reads π from an imported `pi`.)
+ (CGFloat)hyperNormalizedShadowAngleWithShadowOffset:(NSSize)aOffset
{
    float angle = [self hyperShadowAngleWithShadowOffset:aOffset];
    double twoPi = M_PI + M_PI;
    float twoPiF = (float)twoPi;
    if (HSIsAtLeastTwoPi(angle, twoPiF)) {
        angle = (float)(M_PI * -2.0 * floorf((float)(angle / twoPi)) + angle);
    } else if (angle < 0) {
        angle = (float)(angle + (floorf((float)(fabsf(angle) / twoPi)) + 1.0) * twoPi);
        if (HSIsAtLeastTwoPi(angle, twoPiF))
            angle = (float)(angle + M_PI * -2.0);
    }
    return angle;
}
// Distance 2 at 45° down-right, blur 3, 75% black.
+ (id)hyperShadowWithDefaultSettingsForTextObject
{
    NSShadow *shadow = [[[self alloc] init] autorelease];
    [shadow setShadowOffset:NSMakeSize(1.4142135f, -1.4142135f)];
    [shadow setShadowBlurRadius:3];
    [shadow setShadowColor:[NSColor colorWithCalibratedWhite:0 alpha:0.75f]];
    return shadow;
}
- (NSSize)hyperShadowOffsetForDistance:(CGFloat)aDistance
{
    return [NSShadow hyperShadowOffsetWithShadowAngle:[self hyperShadowAngle] shadowDistance:aDistance];
}
- (void)setHyperShadowDistance:(CGFloat)aDistance
{
    [self setShadowOffset:[self hyperShadowOffsetForDistance:aDistance]];
}
- (CGFloat)hyperShadowDistance
{
    return [NSShadow hyperShadowDistanceWithShadowOffset:[self shadowOffset]];
}
- (NSSize)hyperShadowOffsetForAngle:(CGFloat)aAngle
{
    return [NSShadow hyperShadowOffsetWithShadowAngle:aAngle shadowDistance:[self hyperShadowDistance]];
}
- (void)setHyperShadowAngle:(CGFloat)aAngle
{
    [self setShadowOffset:[self hyperShadowOffsetForAngle:aAngle]];
}
- (CGFloat)hyperShadowAngle
{
    return [NSShadow hyperShadowAngleWithShadowOffset:[self shadowOffset]];
}
@end
