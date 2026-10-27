#import "HSResizeCardObjectTracker.h"
@implementation HSResizeCardObjectTracker
static id HSResizeAttributeSet(void)
{
    return [NSEProtocolSet protocolSetWithProtocols:@protocol(HSWidthAttribute), @protocol(HSHeightAttribute),
        @protocol(HSWidthScaleAttribute), @protocol(HSHeightScaleAttribute),
        @protocol(HSHorizontalScaleAttribute), @protocol(HSVerticalScaleAttribute), nil];
}
- (void)mouseUp:(id)aUp inView:(id)aView
{
    [self mouseEvent:aUp inView:aView];
    id geometry = [self geometryAttributes];
    [[geometry attributeObservingController] endContinuousChangeOfAttributeSet:HSResizeAttributeSet()];
    if (!NSEqualSizes([(id<HSGeometryAttributes>)geometry size], _startSize))
        [[geometry queryHyperInterface:@protocol(HSImageCacheAttributes)] forceRecacheIfNeededForGroupObjectsOnly:NO];
    [super mouseUp:aUp inView:aView];
}
- (void)processMouseDragged:(id)aDragged inView:(id)aView
{
    [super processMouseDragged:aDragged inView:aView];
    [self mouseEvent:aDragged inView:aView];
}
- (void)processMouseDown:(id)aDown inView:(id)aView
{
    [super processMouseDown:aDown inView:aView];
    id geometry = [self geometryAttributes];
    [[geometry attributeObservingController] beginContinuousChangeOfAttributeSet:HSResizeAttributeSet()];
    NSRect frame = [geometry frameBoundingRect];
    _centerPoint.x = frame.size.width * 0.5f + frame.origin.x;
    _centerPoint.y = frame.size.height * 0.5f + frame.origin.y;
    NSPoint start = [self startPoint];
    _distanceFromCenterToStartPoint = hypotf(start.x - _centerPoint.x, start.y - _centerPoint.y);
    _startSize = [(id<HSGeometryAttributes>)geometry size];
}
- (void)mouseEvent:(id)aEvent inView:(id)aView
{
    [super mouseEvent:aEvent inView:aView];
    NSPoint point = [aView convertPointFromViewSpaceToUserSpace:[aView convertPoint:[aEvent locationInWindow] fromView:nil]];
    float distance = _distanceFromCenterToStartPoint;
    NSSize size = _startSize;
    if (distance != 0.0f) {
        float scale = hypotf(point.x - _centerPoint.x, point.y - _centerPoint.y) / distance;
        size.height *= scale;
        size.width *= scale;
    }
    [[self geometryApplier] resizeFrameTo:size aboutRelativePoint:NSMakePoint(0.5, 0.5) withLayoutGuidingContext:nil];
}
@end
