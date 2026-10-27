#import "HSWeakObjectProxy.h"
// Proxies forwarding every message to an object: HSWeakObjectProxy doesn't
// retain it, HSObjectProxy does. Messages to a nil object are dropped.
@implementation HSWeakObjectProxy
+ (id)proxyWithObject:(id)aObject
{
    return [[[self alloc] initWithObject:aObject] autorelease];
}
- (id)description
{
    return [NSString stringWithFormat:@"<%@: 0x%lx\n\tobject = %@>", NSStringFromClass([self class]), (unsigned long)self, _object];
}
- (void)setObject:(id)aObject
{
    _object = aObject;
}
- (id)object
{
    return _object;
}
- (void)forwardInvocation:(id)aInvocation
{
    if (_object != nil)
        [aInvocation invokeWithTarget:_object];
}
- (id)methodSignatureForSelector:(SEL)aSelector
{
    return [_object methodSignatureForSelector:aSelector];
}
- (id)initWithObject:(id)aObject
{
    _object = aObject;
    return self;
}
- (id)init
{
    return [self initWithObject:nil];
}
@end

@implementation HSObjectProxy
+ (id)proxyWithObject:(id)aObject
{
    return [[[self alloc] initWithObject:aObject] autorelease];
}
- (id)description
{
    return [NSString stringWithFormat:@"<%@: 0x%lx\n\tobject = %@>", NSStringFromClass([self class]), (unsigned long)self, _object];
}
- (void)setObject:(id)aObject
{
    if (_object == aObject)
        return;
    [aObject retain];
    [_object release];
    _object = aObject;
}
- (id)object
{
    return _object;
}
- (void)forwardInvocation:(id)aInvocation
{
    if (_object != nil)
        [aInvocation invokeWithTarget:_object];
}
- (id)methodSignatureForSelector:(SEL)aSelector
{
    return [_object methodSignatureForSelector:aSelector];
}
- (void)dealloc
{
    [_object release];
    [super dealloc];
}
- (id)initWithObject:(id)aObject
{
    _object = [aObject retain];
    return self;
}
- (id)init
{
    return [self initWithObject:nil];
}
@end
