#import "HyperPlayerBasePrefix.h"


@interface HSWeakObjectProxy : NSProxy <HSObjectProxy>
{
    id _object;
}
+ (id)proxyWithObject:(id)aObject;
- (id)description;
- (void)setObject:(id)aObject;
- (id)object;
- (void)forwardInvocation:(id)aInvocation;
- (id)methodSignatureForSelector:(SEL)aSelector;
- (id)initWithObject:(id)aObject;
- (id)init;
@end

@interface HSObjectProxy : NSProxy <HSObjectProxy>
{
    id _object;
}
+ (id)proxyWithObject:(id)aObject;
- (id)description;
- (void)setObject:(id)aObject;
- (id)object;
- (void)forwardInvocation:(id)aInvocation;
- (id)methodSignatureForSelector:(SEL)aSelector;
- (void)dealloc;
- (id)initWithObject:(id)aObject;
- (id)init;
@end

