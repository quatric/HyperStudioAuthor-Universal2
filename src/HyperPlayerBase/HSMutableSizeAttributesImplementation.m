#import "HSMutableSizeAttributesImplementation.h"
// A node's size, kept in its size storage unit; the default size comes from
// the node's default size subattributes (else the current size).
@implementation HSMutableSizeAttributesImplementation
+ (id)hyperImplementationWithNode:(id)aNode unit:(id)aUnit
{
    if (![aUnit conformsToProtocol:@protocol(HSSizeNodeStorage)])
        return nil;
    return [[[self alloc] initWithNodeStorage:aUnit node:aNode] autorelease];
}
- (id)attributeObservingController
{
    return _node;
}
- (void)setSize:(NSSize)aSize
{
    [_nodeStorage setSize:aSize];
}
- (NSSize)size
{
    return [_nodeStorage size];
}
- (NSSize)defaultSize
{
    if (_defaultSizeSubattributes != nil)
        return [_defaultSizeSubattributes defaultSize];
    return [self size];
}
- (CGFloat)height
{
    return [self size].height;
}
- (CGFloat)width
{
    return [self size].width;
}
- (id)hyperObject
{
    return _node;
}
- (id)nodeStorage
{
    return _nodeStorage;
}
- (id)node
{
    return _node;
}
- (void)dealloc
{
    [(id)_defaultSizeSubattributes release];
    [(id)_nodeStorage release];
    [_node release];
    [super dealloc];
}
// Registers itself with the node for the size interfaces.
- (id)initWithNodeStorage:(id)aStorage node:(id)aNode
{
    self = [super init];
    if (self != nil) {
        _node = [aNode retain];
        _nodeStorage = [aStorage retain];
        _defaultSizeSubattributes = [[aNode queryHyperInterface:@protocol(HSDefaultSizeSubattributes)] retain];
        [_node associateImplementation:self withInterface:@protocol(HSSizeAttributes)];
        [_node associateImplementation:self withInterface:@protocol(HSMutableSizeAttributes)];
        [_node associateImplementation:self withInterface:@protocol(HSStandaloneSizeAttributes)];
        [_node associateImplementation:self withInterface:@protocol(HSStandaloneMutableSizeAttributes)];
    }
    return self;
}
// Needs a node and its storage.
- (id)init
{
    [self release];
    return nil;
}
@end
