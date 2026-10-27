#import "HSShowHideTransitionAttributesImplementation.h"
// An object's show/hide transition, kept by its node unit.
@implementation HSShowHideTransitionAttributesImplementation
+ (id)hyperImplementationWithNode:(id)aNode unit:(id)aUnit
{
    if (![aUnit isKindOfClass:[HSShowHideTransitionNodeUnit class]])
        return nil;
    return [[[self alloc] initWithNodeUnit:aUnit node:aNode] autorelease];
}
- (id)attributeObservingController
{
    return _node;
}
- (double)transitionTime
{
    return [_nodeUnit transitionTime];
}
- (void)setTransition:(id)aTransition
{
    [_nodeUnit setTransition:aTransition];
}
- (id)transition
{
    return [_nodeUnit transition];
}
- (id)hyperObject
{
    return _node;
}
- (id)node
{
    return _node;
}
- (void)dealloc
{
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
    }
    return self;
}
- (void)pauseTransition
{
    [_nodeUnit pauseTransition];
}

- (void)resumeTransition
{
    [_nodeUnit resumeTransition];
}

@end
