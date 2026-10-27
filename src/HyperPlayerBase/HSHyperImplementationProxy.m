#import "HSHyperImplementationProxy.h"
// Stands for one interface of a hyper object: messages go to the
// implementation; other interfaces are asked of the parent object. The
// proxy conforms to its interface (or, without one, to whatever the
// implementation conforms to).
@implementation HSHyperImplementationProxy
+ (id)proxyWithImplementation:(id)aImplementation forObject:(id)aObject
{
    return [self proxyWithImplementation:aImplementation ofProtocol:nil forObject:aObject];
}
+ (id)proxyWithImplementation:(id)aImplementation ofProtocol:(id)aProtocol forObject:(id)aObject
{
    id identifier = aProtocol != nil ? [HSProtocolIdentifier identifierForProtocol:aProtocol] : nil;
    return [[[self alloc] initWithImplementation:aImplementation forInterface:identifier parentObject:aObject] autorelease];
}
- (BOOL)isHyperObjectDirectedAtParentObject
{
    return _isHyperObjectDirectedAtParentObject;
}
- (void)setHyperObjectDirectedAtParentObject:(BOOL)aObject
{
    _isHyperObjectDirectedAtParentObject = aObject != NO;
}
- (void)forwardInvocation:(id)aInvocation
{
    [aInvocation invokeWithTarget:_implementation];
}
- (id)methodSignatureForSelector:(SEL)aSelector
{
    id signature = [super methodSignatureForSelector:aSelector];
    if (signature == nil)
        signature = [_implementation methodSignatureForSelector:aSelector];
    return signature;
}
- (BOOL)lastHyperAccessDidReturnMultipleValues
{
    return [_implementation lastHyperAccessDidReturnMultipleValues];
}
// Protocols are compared by name, then for equality (the pre-Leopard
// Protocol-object path is dropped).
- (BOOL)conformsToProtocol:(id)aProtocol
{
    if ([super conformsToProtocol:aProtocol])
        return YES;
    if (_interfaceIdentifier == nil)
        return [_implementation conformsToProtocol:aProtocol];
    Protocol *interface = [_interfaceIdentifier protocol];
    if (interface == aProtocol)
        return YES;
    const char *name = protocol_getName(aProtocol);
    const char *interfaceName = interface != nil ? protocol_getName(interface) : NULL;
    if (name == NULL || interfaceName == NULL || strcmp(name, interfaceName) != 0)
        return NO;
    return protocol_isEqual(aProtocol, interface);
}
- (id)queryHyperInterface:(id)aInterface
{
    if ([self conformsToProtocol:aInterface])
        return self;
    return [_parentObject queryHyperInterface:aInterface];
}
- (id)hyperObject
{
    if (_isHyperObjectDirectedAtParentObject)
        return _parentObject;
    return [super hyperObject];
}
- (void)dealloc
{
    [_parentObject release];
    [_implementation release];
    [_interfaceIdentifier release];
    [super dealloc];
}
- (id)init
{
    return [self initWithImplementation:nil forInterface:nil parentObject:nil];
}
- (id)initWithImplementation:(id)aImplementation forInterface:(id)aInterface parentObject:(id)aObject
{
    self = [super init];
    if (self != nil) {
        _parentObject = [aObject retain];
        _implementation = [aImplementation retain];
        _interfaceIdentifier = [aInterface retain];
    }
    return self;
}
@end
