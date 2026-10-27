#import "__NSEWeakObjectProxy.h"

@implementation __NSEWeakObjectProxy

/* i386 ivar offsets: _object=0x4 */

- (id)description
{
    return [NSString stringWithFormat:@"<%@: %p\n\tobject: %@>", NSStringFromClass([self class]), self, _object];
}

// Messages go to the object while it's there.
- (void)forwardInvocation:(id)aInvocation
{
    if (!_object)
        [super forwardInvocation:aInvocation];
    else
        [aInvocation invokeWithTarget:_object];
}

- (id)methodSignatureForSelector:(SEL)aSelector
{
    if (!_object)
        return [super methodSignatureForSelector:aSelector];
    return [_object methodSignatureForSelector:aSelector];
}

- (void)__NSEWeakObjectProxy_invalidate
{
    _object = nil;
}

// Doesn't retain the object.
- (id)__NSEWeakObjectProxy_initWithObject:(id)aObject
{
    _object = aObject;
    return self;
}

@end

@implementation __NSEObjectProxy

/* i386 ivar offsets: _object=0x4 */

- (id)description
{
    return [NSString stringWithFormat:@"<%@: %p\n\tobject: %@>", NSStringFromClass([self class]), self, _object];
}

- (void)forwardInvocation:(id)aInvocation
{
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

- (id)__NSEObjectProxy_initWithObject:(id)aObject
{
    _object = [aObject retain];
    return self;
}

@end

@implementation NSObject (NSEObjectImplementation)

+ (void)NSE_invalidateWeakProxy:(id)aProxy
{
    [aProxy __NSEWeakObjectProxy_invalidate];
}

// Tiger to Snow Leopard (Foundation 677-833) got backported methods here.
+ (void)load
{
}

// A proxy that forwards to the receiver without retaining it, until
// invalidated (+NSE_invalidateWeakProxy:).
- (id)NSE_newWeakProxy
{
    return [[__NSEWeakObjectProxy alloc] __NSEWeakObjectProxy_initWithObject:self];
}

// A proxy that retains the receiver and forwards to it.
- (id)NSE_newProxy
{
    return [[__NSEObjectProxy alloc] __NSEObjectProxy_initWithObject:self];
}

// The associated objects are the runtime's (Tiger and Leopard, CF <= 550,
// used an emulation).
- (void)NSE_removeAssociatedObjectForKey:(void *)aKey
{
    objc_setAssociatedObject(self, aKey, nil, OBJC_ASSOCIATION_ASSIGN);
}

- (void)NSE_setAssociatedObject:(id)aObject forKey:(void *)aKey withPolicy:(NSUInteger)aPolicy
{
    objc_setAssociatedObject(self, aKey, aObject, (objc_AssociationPolicy)aPolicy);
}

- (id)NSE_associatedObjectForKey:(void *)aKey
{
    return objc_getAssociatedObject(self, aKey);
}

@end

