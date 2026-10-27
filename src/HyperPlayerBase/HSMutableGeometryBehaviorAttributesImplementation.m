#import "HSMutableGeometryBehaviorAttributesImplementation.h"

// Geometry behavior attributes of a node: the aspect-ratio preference lives in
// the HSGeometryBehaviorNodeUnit; resizing and per-object restrictions are
// forwarded to the node's own standalone implementations.
@implementation HSMutableGeometryBehaviorAttributesImplementation
+ (id)hyperImplementationWithNode:(id)aNode unit:(id)aUnit
{
    if (![aUnit isKindOfClass:[HSGeometryBehaviorNodeUnit class]])
        return nil;
    return [[[self alloc] initWithNodeUnit:aUnit node:aNode] autorelease];
}
- (id)attributeObservingController
{
    return _node;
}
- (void)setPrefersToMaintainSizeScaleAspectRatio:(BOOL)aRatio
{
    [_nodeUnit setPrefersToMaintainSizeScaleAspectRatio:aRatio];
}
- (BOOL)prefersToMaintainSizeScaleAspectRatio
{
    return [_nodeUnit prefersToMaintainSizeScaleAspectRatio];
}
- (BOOL)canMoveVertically
{
    return _geometryBehaviorSubattributes ? [_geometryBehaviorSubattributes canMoveVertically] : YES;
}
- (BOOL)canMoveHorizontally
{
    return _geometryBehaviorSubattributes ? [_geometryBehaviorSubattributes canMoveHorizontally] : YES;
}
- (BOOL)canRotate
{
    return _geometryBehaviorSubattributes ? [_geometryBehaviorSubattributes canRotate] : YES;
}
- (BOOL)canSkew
{
    return _geometryBehaviorSubattributes ? [_geometryBehaviorSubattributes canSkew] : YES;
}
- (BOOL)canFlipVertically
{
    return _geometryBehaviorSubattributes ? [_geometryBehaviorSubattributes canFlipVertically] : YES;
}
- (BOOL)canFlipHorizontally
{
    return _geometryBehaviorSubattributes ? [_geometryBehaviorSubattributes canFlipHorizontally] : YES;
}
- (BOOL)canScaleVertically
{
    return _geometryBehaviorSubattributes ? [_geometryBehaviorSubattributes canScaleVertically] : YES;
}
- (BOOL)canScaleHorizontally
{
    return _geometryBehaviorSubattributes ? [_geometryBehaviorSubattributes canScaleHorizontally] : YES;
}
- (BOOL)canBreakSizeScaleAspectRatio
{
    return _geometryBehaviorSubattributes ? [_geometryBehaviorSubattributes canBreakSizeScaleAspectRatio] : YES;
}
- (BOOL)prefersResizingToScaling
{
    return _geometryBehaviorSubattributes ? [_geometryBehaviorSubattributes prefersResizingToScaling] : NO;
}
- (void)setPrefersToMaintainSizeAspectRatio:(BOOL)aRatio
{
    [_mutableResizingBehaviorAttributes setPrefersToMaintainSizeAspectRatio:aRatio];
}
- (BOOL)prefersToMaintainSizeAspectRatio
{
    return [_resizingBehaviorAttributes prefersToMaintainSizeAspectRatio];
}
- (BOOL)canResizeVertically
{
    return [_resizingBehaviorAttributes canResizeVertically];
}
- (BOOL)canResizeHorizontally
{
    return [_resizingBehaviorAttributes canResizeHorizontally];
}
- (BOOL)canBreakSizeAspectRatio
{
    return [_resizingBehaviorAttributes canBreakSizeAspectRatio];
}
- (id)hyperObject
{
    return _node;
}
- (id)nodeUnit
{
    return _nodeUnit;
}
- (id)node
{
    return _node;
}
- (void)dealloc
{
    [_mutableResizingBehaviorAttributes release];
    [_geometryBehaviorSubattributes release];
    [_resizingBehaviorAttributes release];
    [_nodeUnit release];
    [_node release];
    [super dealloc];
}
- (id)initWithNodeUnit:(id)aUnit node:(id)aNode
{
    self = [super init];
    if (self) {
        _resizingBehaviorAttributes = [[aNode queryHyperInterface:@protocol(HSStandaloneResizingBehaviorAttributes)] retain];
        if (_resizingBehaviorAttributes == nil) {
            [self release];
            return nil;
        }
        _node = [aNode retain];
        _nodeUnit = [aUnit retain];
        _mutableResizingBehaviorAttributes = [[aNode queryHyperInterface:@protocol(HSStandaloneMutableResizingBehaviorAttributes)] retain];
        _geometryBehaviorSubattributes = [[aNode queryHyperInterface:@protocol(HSGeometryBehaviorSubattributes)] retain];
    }
    return self;
}
- (id)init
{
    [self release];
    return nil;
}
@end
