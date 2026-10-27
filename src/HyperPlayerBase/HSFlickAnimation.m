#import "HSFlickAnimation.h"
@implementation HSFlickAnimation
- (id)runLoopModesForAnimating
{
    return [NSArray arrayWithObjects:NSDefaultRunLoopMode, NSEventTrackingRunLoopMode, NSModalPanelRunLoopMode, nil];
}
- (void)setCurrentProgress:(CGFloat)aProgress
{
    [super setCurrentProgress:aProgress];
    NSUInteger count = [_objects count];
    for (NSUInteger i = 0; i < count; i++) {
        NSPoint center = NSMakePoint(_destinationDeltas[i].width * aProgress + _startPoints[i].x,
                                     _destinationDeltas[i].height * aProgress + _startPoints[i].y);
        [[[[_objects objectAtIndex:i] queryHyperInterface:@protocol(HSGeometryBehaviorAdapting)] queryGeometryBehaviorApplier]
            moveCenterTo:center withLayoutGuidingContext:nil];
    }
}
// Each object flies from its center out of the parent (20 points past its
// edge) along the direction; the duration is the distance over the velocity.
// Original quirk kept: along an axis the distance is the last object's, on a
// diagonal the largest one.
- (void)prepareToStartAnimationInDirection:(NSSize)aDirection
{
    id parent = [[[_objects objectAtIndex:0] queryHyperInterface:@protocol(HSNodeChild)] hyperParent];
    NSSize parentSize = [(id<HSSizeAttributes>)[parent queryHyperInterface:@protocol(HSSizeAttributes)] size];
    NSUInteger count = [_objects count];
    float distance = 0.0f;
    BOOL horizontal = aDirection.width > 0.0001 || aDirection.width < -0.0001;
    BOOL vertical = aDirection.height > 0.0001 || aDirection.height < -0.0001;
    for (NSUInteger i = 0; i < count; i++) {
        NSRect frame = [[[_objects objectAtIndex:i] queryHyperInterface:@protocol(HSGeometryAttributes)] frameBoundingRect];
        float startX = frame.origin.x + frame.size.width * 0.5f;
        float startY = frame.origin.y + frame.size.height * 0.5f;
        _startPoints[i] = NSMakePoint(startX, startY);
        float outY = frame.size.height * 0.5 + 20.0;
        if (!horizontal) {
            float destinationY = aDirection.height > 0 ? outY + parentSize.height : -outY;
            _destinationDeltas[i] = NSMakeSize(0, destinationY - startY);
            distance = fabsf(_destinationDeltas[i].height);
            continue;
        }
        float outX = frame.size.width * 0.5 + 20.0;
        float destinationX = aDirection.width > 0 ? outX + parentSize.width : -outX;
        if (!vertical) {
            _destinationDeltas[i] = NSMakeSize(destinationX - startX, 0);
            distance = fabsf(_destinationDeltas[i].width);
            continue;
        }
        // Where the line leaves through the top/bottom edge and through the
        // left/right edge: the nearer exit wins.
        float destinationY = aDirection.height > 0 ? outY + parentSize.height : -outY;
        float xAtEdgeY = (destinationY - startY) * aDirection.width / aDirection.height + startX;
        float yAtEdgeX = (destinationX - startX) * aDirection.height / aDirection.width + startY;
        float viaY = hypotf(xAtEdgeY - startX, destinationY - startY);
        float viaX = hypotf(destinationX - startX, yAtEdgeX - startY);
        if (viaY <= viaX)
            _destinationDeltas[i] = NSMakeSize(xAtEdgeY - startX, destinationY - startY);
        else
            _destinationDeltas[i] = NSMakeSize(destinationX - startX, yAtEdgeX - startY);
        distance = fmaxf(distance, fminf(viaY, viaX));
    }
    [self setDuration:distance / _velocity];
}
- (void)dealloc
{
    [_objects release];
    NSZoneFree([self zone], _startPoints);
    [super dealloc];
}
- (id)initWithObjects:(id)aObjects velocity:(CGFloat)aVelocity direction:(NSSize)aDirection
{
    self = [super init];
    if (self != nil) {
        _objects = [aObjects copy];
        _velocity = aVelocity;
        NSUInteger count = [aObjects count];
        // One block: the start points, then the deltas.
        _startPoints = NSZoneMalloc([self zone], count * (sizeof(NSPoint) + sizeof(NSSize)));
        _destinationDeltas = (NSSize *)(_startPoints + count);
        [self prepareToStartAnimationInDirection:aDirection];
    }
    return self;
}
- (id)init
{
    [self release];
    return nil;
}
@end
