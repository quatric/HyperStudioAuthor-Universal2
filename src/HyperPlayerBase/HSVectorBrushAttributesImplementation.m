#import "HSVectorBrushAttributesImplementation.h"
// HSVectorBrushAttributes of a node with a vector brush unit.
@implementation HSVectorBrushAttributesImplementation
+ (id)hyperImplementationWithNode:(id)aNode unit:(id)aUnit
{
    if (![aUnit isKindOfClass:[HSVectorBrushNodeUnit class]])
        return nil;
    return [[[self alloc] initWithNodeUnit:aUnit node:aNode] autorelease];
}
- (id)attributeObservingController
{
    return _node;
}
- (id)brushRenderer
{
    return [_nodeUnit brushRenderer];
}
- (NSRect)hyperToolBoundingRect
{
    return [_nodeUnit toolBoundingRect];
}
- (id)hyperTouchProvider
{
    return [_nodeUnit touchProvider];
}
- (id)hyperTool
{
    return [_nodeUnit tool];
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
@end
