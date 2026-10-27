#import "HSMutableResizingBehaviorAttributesImplementation.h"
// Resizing behaviour of a node from its resizing behaviour unit (the aspect
// ratio preference) and the node's resizing subattributes (which directions
// may change; all of them without subattributes).
@implementation HSMutableResizingBehaviorAttributesImplementation
+ (id)hyperImplementationWithNode:(id)aNode unit:(id)aUnit
{
    if (![aUnit isKindOfClass:[HSResizingBehaviorNodeUnit class]])
        return nil;
    return [[[self alloc] initWithNodeUnit:aUnit node:aNode] autorelease];
}
- (id)attributeObservingController
{
    return _node;
}
- (void)setPrefersToMaintainSizeAspectRatio:(BOOL)aRatio
{
    [_nodeUnit setPrefersToMaintainSizeAspectRatio:aRatio];
}
- (BOOL)prefersToMaintainSizeAspectRatio
{
    return [_nodeUnit prefersToMaintainSizeAspectRatio];
}
- (BOOL)canResizeVertically
{
    return _resizingBehaviorSubattributes == nil || [_resizingBehaviorSubattributes canResizeVertically];
}
- (BOOL)canResizeHorizontally
{
    return _resizingBehaviorSubattributes == nil || [_resizingBehaviorSubattributes canResizeHorizontally];
}
- (BOOL)canBreakSizeAspectRatio
{
    return _resizingBehaviorSubattributes == nil || [_resizingBehaviorSubattributes canBreakSizeAspectRatio];
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
    [(id)_resizingBehaviorSubattributes release];
    [_nodeUnit release];
    [_node release];
    [super dealloc];
}
- (id)initWithNodeUnit:(id)aUnit node:(id)aNode
{
    self = [super init];
    if (self != nil) {
        _node = [aNode retain];
        _nodeUnit = [aUnit retain];
        _resizingBehaviorSubattributes = [[_node queryHyperInterface:@protocol(HSResizingBehaviorSubattributes)] retain];
    }
    return self;
}
// Needs a node and unit.
- (id)init
{
    [self release];
    return nil;
}
@end
