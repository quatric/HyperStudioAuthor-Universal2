#import "HSFrameManipulationSelectionKnob.h"

@implementation HSFrameManipulationSelectionKnob

+ (id)affectingAttributes
{
    static NSEProtocolSet *sAffectingAttributes = nil;
    if (sAffectingAttributes == nil)
        sAffectingAttributes = [[NSEProtocolSet alloc] initWithProtocol:@protocol(HSGeometryAttribute)];
    return sAffectingAttributes;
}

+ (id)beingTrackedActiveStateImage
{
    return nil;
}

+ (id)activeStateImage
{
    return nil;
}

+ (id)beingTrackedStateImage
{
    static NSImage *sImage = nil;
    if (sImage == nil)
        sImage = [[NSImage imageNamed:@"hSquare_on"] retain];
    return sImage;
}

+ (id)normalStateImage
{
    static NSImage *sImage = nil;
    if (sImage == nil)
        sImage = [[NSImage imageNamed:@"hSquare"] retain];
    return sImage;
}

- (BOOL)proportionalScaleForModifierFlags:(NSUInteger)aFlags inCanvasLayer:(id)aLayer
{
    id<HSGeometryBehaviorAttributes> behavior = [aLayer queryHyperInterface:@protocol(HSGeometryBehaviorAttributes)];
    BOOL proportional = [behavior prefersResizingToScaling] ? [behavior prefersToMaintainSizeAspectRatio] : [behavior prefersToMaintainSizeScaleAspectRatio];
    if (aFlags & NSEventModifierFlagShift)
        proportional = !proportional;
    return proportional;
}

- (id)cursorAtPoint:(NSPoint)aPoint modifierFlags:(NSUInteger)aFlags inView:(id)aView owner:(id)aOwner
{
    id<HSGeometryAttributes> geometry = [aOwner queryHyperInterface:@protocol(HSGeometryAttributes)];
    if (geometry == nil || aView == nil)
        return nil;
    NSRect frame = [aView viewBoundingRectForUserRect:[geometry frameBoundingRect]];
    float frameCenterX = frame.origin.x + frame.size.width * 0.5f;
    float frameCenterY = frame.origin.y + frame.size.height * 0.5f;
    NSRect knobFrame = [self frameForOwner:aOwner inView:aView];
    float knobCenterX = knobFrame.size.width * 0.5f + knobFrame.origin.x;
    float knobCenterY = knobFrame.size.height * 0.5f + knobFrame.origin.y;
    float angle = (float)atan2(knobCenterY - frameCenterY, knobCenterX - frameCenterX);
    float halfWidth = frame.size.width * 0.5f;
    float halfHeight = frame.size.height * 0.5f;
    float horizontalHalfAngle = (float)(atan2(halfHeight, halfWidth) * 0.5);
    float verticalHalfAngle = (float)(atan2(halfWidth, halfHeight) * 0.5);
    if (angle < -horizontalHalfAngle)
        angle += 3.1415927f;
    if (3.1415927f - horizontalHalfAngle < angle)
        angle -= 3.1415927f;

    NSString *cursorName;
    if (angle > -horizontalHalfAngle && angle <= horizontalHalfAngle) {
        cursorName = HSScaleHorCursor;
        if (aFlags & NSEventModifierFlagShift)
            cursorName = knobCenterX < frameCenterX ? HSScaleProportLCursor : HSScaleProportRCursor;
    } else if (angle > horizontalHalfAngle && angle <= 1.5707964f - verticalHalfAngle) {
        cursorName = HSTLBRCursor;
        if ([self proportionalScaleForModifierFlags:aFlags inCanvasLayer:aOwner])
            cursorName = knobCenterX < frameCenterX ? HSScaleProportTLCursor : HSScaleProportBRCursor;
    } else if (angle > 1.5707964f - verticalHalfAngle && angle <= verticalHalfAngle + 1.5707964f) {
        cursorName = HSScaleVertCursor;
        if (aFlags & NSEventModifierFlagShift)
            cursorName = knobCenterY < frameCenterY ? HSScaleProportTCursor : HSScaleProportBCursor;
    } else if (angle > verticalHalfAngle + 1.5707964f && angle <= 3.1415927f - horizontalHalfAngle) {
        cursorName = HSTRBLCursor;
        if ([self proportionalScaleForModifierFlags:aFlags inCanvasLayer:aOwner])
            cursorName = knobCenterX < frameCenterX ? HSScaleProportBLCursor : HSScaleProportTRCursor;
    } else {
        return nil;
    }
    if (cursorName == nil)
        return nil;
    return [HSCursor cursorNamed:cursorName];
}

- (NSRect)calculateFrameForOwner:(id)aOwner inView:(id)aView
{
    NSSize imageSize = [self imageSize];
    id<HSGeometryAttributes> geometry = [aOwner queryHyperInterface:@protocol(HSGeometryAttributes)];
    NSSize factor = [self framePositionFactor];
    NSSize offset = [self framePositionOffset];
    NSSize size = [geometry size];
    CGAffineTransform transform = [geometry affineTransform];
    if ([geometry isFlippedHorizontally]) {
        transform.ty = transform.b * size.width + transform.ty;
        transform.tx = transform.a * size.width + transform.tx;
        transform.a = -transform.a;
        transform.b = -transform.b;
    }
    CGFloat y = offset.height + size.height * factor.height;
    CGFloat x = offset.width + size.width * factor.width;
    if ([geometry isFlippedVertically]) {
        transform.ty = transform.d * size.height + transform.ty;
        transform.tx = size.height * transform.c + transform.tx;
        transform.c = -transform.c;
        transform.d = -transform.d;
    }
    NSPoint point = [aView convertPointFromUserSpaceToViewSpace:NSMakePoint(transform.tx + transform.a * x + transform.c * y,
                                                                             transform.ty + transform.b * x + transform.d * y)];
    return NSMakeRect(point.x + imageSize.width * -0.5, point.y + imageSize.height * -0.5, imageSize.width, imageSize.height);
}

- (NSSize)framePositionOffset
{
    return NSZeroSize;
}

- (NSSize)framePositionFactor
{
    return NSZeroSize;
}

@end
