#import "HSEffectCenterSelectionTracker.h"

@implementation HSEffectCenterSelectionTracker

- (void)mouseUp:(id)aUp inView:(id)aView
{
    [self mouseEvent:aUp inView:aView];
    [super mouseUp:aUp inView:aView];
}

- (void)processMouseDragged:(id)aDragged inView:(id)aView
{
    [super processMouseDragged:aDragged inView:aView];
    [self mouseEvent:aDragged inView:aView];
}

// Moves the effect center (a CIVector in the object's unflipped pixel space) to the mouse.
- (void)mouseEvent:(id)aEvent inView:(id)aView
{
    Class vectorClass;
    id geometry, key;
    NSSize size;
    NSPoint point;
    CGAffineTransform inverse;
    float x, y;
    NSInteger index;

    if (_effectsAttributes == nil || (vectorClass = NSClassFromString(@"CIVector")) == Nil)
        return;
    geometry = [self geometryAttributes];
    size = [(id<HSGeometryAttributes>)geometry size];
    point = [aView convertPointFromViewSpaceToUserSpace:[aView convertPoint:[aEvent locationInWindow] fromView:nil]];
    // CGAffineTransformInvert returns the transform unchanged when it is singular, like the original.
    inverse = CGAffineTransformInvert([geometry affineTransform]);
    point = CGPointApplyAffineTransform(point, inverse);
    y = MAX(0.0f, MIN((float)(size.height - point.y), (float)size.height));
    x = MAX(0.0f, MIN((float)point.x, (float)size.width));
    id vector = [vectorClass vectorWithX:rintf(x) Y:rintf(y)];
    index = [[self selectionKnob] associatedCenterIndex];
    if (index == 0 && [_effectsAttributes hyperValueForKey:ciInputCenter] != nil)
        key = ciInputCenter;
    else
        key = [NSString stringWithFormat:@"%@%d", ciInputCenter, (int)index];
    [_effectsAttributes setHyperValue:vector forKey:key];
}

- (void)processMouseDown:(id)aDown inView:(id)aView
{
    [super processMouseDown:aDown inView:aView];
}

- (void)setTrackingObject:(id)aObject
{
    [_effectsAttributes release];
    _effectsAttributes = nil;
    [super setTrackingObject:aObject];
    _effectsAttributes = [[[self trackingObject] queryHyperInterface:@protocol(HSEffectMutableAttributes)] retain];
}

- (void)dealloc
{
    [_effectsAttributes release];
    [super dealloc];
}

@end
