#import "HyperPlayerBasePrefix.h"


@interface HSLimitedConformedToProtocolProxy : NSObject
{
    id _object;
}
+ (id)proxyWithObject:(id)aObject;
- (void)forwardInvocation:(id)aInvocation;
- (id)methodSignatureForSelector:(SEL)aSelector;
- (BOOL)respondsToSelector:(SEL)aSelector;
- (BOOL)conformsToProtocol:(id)aProtocol;
- (id)nullSelector;
- (void)dealloc;
- (id)initWithObject:(id)aObject;
@end

