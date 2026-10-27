#import "HSMoveSnappingCardObjectTracker.h"
// Moving an object in the player near its drop off target snaps it onto the
// target's centre (with the target's reward sound); moving away unsnaps it.
@implementation HSMoveSnappingCardObjectTracker
- (BOOL)unsnapIfNeededToPoint:(NSPoint)aPoint
{
    HSInteractiveAnimationManager *manager = [HSInteractiveAnimationManager sharedAnimationManager];
    BOOL unsnapping = NO;
    if (_isSnapped) {
        [manager stopAnimationForAnimatedObject:[self trackingObject]];
        NSRect frame = [[self geometryAttributes] frameBoundingRect];
        HSMovingCardObjectAnimation *animation = [[[HSMovingCardObjectAnimation alloc] initWithStartPoint:frame.origin dstPoint:aPoint duration:0.1] autorelease];
        [animation setBasePointType:1];
        [[HSInteractiveAnimationManager sharedAnimationManager] startAnimation:animation forAnimatedObject:[self trackingObject]];
        unsnapping = YES;
        if (_isSnapped)
            return YES;
    }
    if ([[HSInteractiveAnimationManager sharedAnimationManager] hasCurrentlyPlayedAnimationForObject:[self trackingObject]]) {
        [[[HSInteractiveAnimationManager sharedAnimationManager] animationForAnimatedObject:[self trackingObject]] updateDestinationPoint:aPoint];
        return YES;
    }
    return unsnapping;
}
- (void)snapFromCurrentPoint:(NSPoint)aPoint toPoint:(NSPoint)aPoint2 animated:(BOOL)aAnimated
{
    if (NSEqualPoints(aPoint, aPoint2))
        return;
    if ([[HSInteractiveAnimationManager sharedAnimationManager] hasCurrentlyPlayedAnimationForObject:[self trackingObject]])
        [[HSInteractiveAnimationManager sharedAnimationManager] stopAnimationForAnimatedObject:[self trackingObject]];
    if (!aAnimated) {
        [[self geometryApplier] moveCenterTo:aPoint2 withLayoutGuidingContext:nil];
        return;
    }
    HSMovingCardObjectAnimation *animation = [[[HSMovingCardObjectAnimation alloc] initWithStartPoint:aPoint dstPoint:aPoint2 duration:0.1] autorelease];
    [[HSInteractiveAnimationManager sharedAnimationManager] startAnimation:animation forAnimatedObject:[self trackingObject]];
}
// Within the target's snapping range (on both axes) the object's centre
// snaps to the target's (once) and the reward sound plays.
- (BOOL)snapToDropOffTargetIfNeededObjectWithOrigin:(NSPoint)aOrigin
{
    id card = [[self trackingObject] card];
    if (![[card document] isInPlayerMode] && ![[card document] isInHyperCastingMode])
        return NO;
    id snapOptions = [[self snappingTarget] queryHyperInterface:@protocol(HSMutableSnapOptionsAttributes)];
    if (snapOptions == nil || ![snapOptions isDropOffSnappingEnabled])
        return NO;
    NSSize size = [(id<HSSizeAttributes>)[self geometryAttributes] size];
    NSPoint snappingPoint = [self snappingPoint];
    double range = (double)(unsigned int)[snapOptions dropOffSnappingRange];
    NSPoint center = NSMakePoint(size.width * 0.5f + aOrigin.x, size.height * 0.5f + aOrigin.y);
    if (!(fabs(center.x - snappingPoint.x) < range && fabs(center.y - snappingPoint.y) < range))
        return NO;
    if (!_isSnapped) {
        [self snapFromCurrentPoint:center toPoint:snappingPoint animated:YES];
        _isSnapped = YES;
        id media = [snapOptions dropOffRewardSoundMedia];
        if (media != nil && [snapOptions playDropOffRewardSound]) {
            NSString *path = [media fullPathToMediaFileCreateIfNeeded:YES];
            if (path != nil) {
                id movie = [HSMovie movieWithURL:[NSURL fileURLWithPath:path] error:NULL];
                [[HSActionMediaPlayer sharedActionMediaPlayer] startSound:movie forObject:card];
            }
        }
    }
    return YES;
}
// The drop off target's centre.
- (NSPoint)snappingPoint
{
    id target = [self snappingTarget];
    if (target == nil)
        return NSZeroPoint;
    NSRect frame = [[target queryHyperInterface:@protocol(HSGeometryAttributes)] frameBoundingRect];
    return NSMakePoint(frame.size.width * 0.5f + frame.origin.x, frame.size.height * 0.5f + frame.origin.y);
}
- (id)snappingTarget
{
    id identification = [[self trackingObject] queryHyperInterface:@protocol(HSMutableSnappingTargetUIDIdentification)];
    id access = [[[self trackingObject] card] queryHyperInterface:@protocol(HSUserObjectUIDBasedAccess)];
    return [[access childInTreeWithUID:[identification dropOffTargetUID]] queryHyperInterface:@protocol(HSMutableCardObjectAttributes)];
}
- (void)moveCardObjectOriginTo:(NSPoint)aTo
{
    if ([self snapToDropOffTargetIfNeededObjectWithOrigin:aTo])
        return;
    if (![self unsnapIfNeededToPoint:aTo])
        [[self geometryApplier] moveFrameBoundingRectOriginTo:aTo withLayoutGuidingContext:nil];
    _isSnapped = NO;
}
// An object starting on its target's centre starts snapped.
- (void)processMouseDown:(id)aDown inView:(id)aView
{
    [super processMouseDown:aDown inView:aView];
    id card = [[self trackingObject] card];
    if (![[card document] isInPlayerMode] && ![[card document] isInHyperCastingMode])
        return;
    id snapOptions = [[self snappingTarget] queryHyperInterface:@protocol(HSMutableSnapOptionsAttributes)];
    if (snapOptions == nil || ![snapOptions isDropOffSnappingEnabled])
        return;
    NSPoint snappingPoint = [self snappingPoint];
    NSSize size = [(id<HSSizeAttributes>)[self geometryAttributes] size];
    NSPoint origin = [self startOrigin];
    if (NSEqualPoints(NSMakePoint(origin.x + size.width * 0.5f, origin.y + size.height * 0.5f), snappingPoint))
        _isSnapped = YES;
}
@end
