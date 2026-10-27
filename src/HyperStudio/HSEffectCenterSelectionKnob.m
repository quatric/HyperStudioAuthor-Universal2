#import "HSEffectCenterSelectionKnob.h"

@implementation HSEffectCenterSelectionKnob

+ (id)affectingAttributes
{
    static NSEProtocolSet *attributes = nil;
    if (attributes == nil)
        attributes = [[NSEProtocolSet alloc] initWithProtocols:@protocol(HSGeometryAttribute), @protocol(HSEffectVisualAttribute), nil];
    return attributes;
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
    static NSImage *image = nil;
    if (image == nil)
        image = [[NSImage imageNamed:@"hRoundGreen_on"] retain];
    return image;
}

+ (id)normalStateImage
{
    static NSImage *image = nil;
    if (image == nil)
        image = [[NSImage imageNamed:@"hRoundGreen"] retain];
    return image;
}

- (BOOL)canBeLocked
{
    return NO;
}

- (id)cursorAtPoint:(NSPoint)aPoint modifierFlags:(NSUInteger)aFlags inView:(id)aView owner:(id)aOwner
{
    return [HSCursor cursorNamed:HSArrowMoveCursor];
}

- (BOOL)isEqualToKnob:(id)aKnob
{
    if ([super isEqualToKnob:aKnob] && [aKnob isKindOfClass:[HSEffectCenterSelectionKnob class]])
        return [self associatedCenterIndex] == [aKnob associatedCenterIndex];
    return NO;
}

- (NSInteger)associatedCenterIndex
{
    return _centerIndex;
}

- (void)setAssociatedCenterIndex:(NSInteger)aIndex
{
    if (_centerIndex != aIndex) {
        _centerIndex = (int)aIndex;
        [self invalidateCachedFrame];
    }
}

// Centered on the effect's center point, which is kept bottom-up in the object's own space.
- (NSRect)calculateFrameForOwner:(id)aOwner inView:(id)aView
{
    id effect = [aOwner queryHyperInterface:@protocol(HSEffectAttributes)];
    if (effect == nil)
        return NSZeroRect;
    id geometry = [aOwner queryHyperInterface:@protocol(HSGeometryAttributes)];
    if (geometry == nil)
        return NSZeroRect;
    id vector = nil;
    if (_centerIndex == 0)
        vector = [effect hyperValueForKey:ciInputCenter];
    if (vector == nil)
        vector = [effect hyperValueForKey:[NSString stringWithFormat:@"%@%d", ciInputCenter, _centerIndex]];
    float y = [vector Y];
    float x = [vector X];
    if ([aView isFlipped])
        y = [(id<HSGeometryAttributes>)geometry size].height - y;
    CGAffineTransform transform = [geometry affineTransform];
    NSPoint point = [aView convertPointFromUserSpaceToViewSpace:NSMakePoint(transform.a * x + transform.c * y + transform.tx, transform.b * x + transform.d * y + transform.ty)];
    NSSize size = [self imageSize];
    return NSMakeRect(point.x + size.width * -0.5f, point.y + size.height * -0.5f, size.width, size.height);
}

- (id)createSelectionTrackerForModifierFlags:(NSUInteger)aFlags
{
    return [[HSEffectCenterSelectionTracker alloc] init];
}

@end
