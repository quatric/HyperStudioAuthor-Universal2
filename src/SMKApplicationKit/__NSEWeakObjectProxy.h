#import "SMKApplicationKitPrefix.h"


@interface __NSEWeakObjectProxy : NSProxy
{
    id _object;
}
- (id)description;
- (void)forwardInvocation:(id)aInvocation;
- (id)methodSignatureForSelector:(SEL)aSelector;
- (void)__NSEWeakObjectProxy_invalidate;
- (id)__NSEWeakObjectProxy_initWithObject:(id)aObject;
@end

@interface __NSEObjectProxy : NSProxy
{
    id _object;
}
- (id)description;
- (void)forwardInvocation:(id)aInvocation;
- (id)methodSignatureForSelector:(SEL)aSelector;
- (void)dealloc;
- (id)__NSEObjectProxy_initWithObject:(id)aObject;
@end

@interface NSObject (NSEObjectImplementation)
+ (void)NSE_invalidateWeakProxy:(id)aProxy;
+ (void)load;
- (id)NSE_newWeakProxy;
- (id)NSE_newProxy;
- (void)NSE_removeAssociatedObjectForKey:(void *)aKey;
- (void)NSE_setAssociatedObject:(id)aObject forKey:(void *)aKey withPolicy:(NSUInteger)aPolicy;
- (id)NSE_associatedObjectForKey:(void *)aKey;
@end

