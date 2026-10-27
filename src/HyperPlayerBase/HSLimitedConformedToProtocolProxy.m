#import "HSLimitedConformedToProtocolProxy.h"
// A proxy that claims every protocol but answers only what its object
// implements; anything else does nothing (it goes to -nullSelector).
@implementation HSLimitedConformedToProtocolProxy
+ (id)proxyWithObject:(id)aObject
{
    return [[[self alloc] initWithObject:aObject] autorelease];
}
- (void)forwardInvocation:(id)aInvocation
{
    id target = _object;
    if (![_object respondsToSelector:[aInvocation selector]]) {
        [aInvocation setSelector:@selector(nullSelector)];
        target = self;
    }
    [aInvocation invokeWithTarget:target];
}
- (id)methodSignatureForSelector:(SEL)aSelector
{
    NSMethodSignature *signature = [_object methodSignatureForSelector:aSelector];
    if (signature == nil)
        signature = [super methodSignatureForSelector:@selector(nullSelector)];
    return signature;
}
- (BOOL)respondsToSelector:(SEL)aSelector
{
    return [super respondsToSelector:aSelector] || [_object respondsToSelector:aSelector];
}
- (BOOL)conformsToProtocol:(id)aProtocol
{
    return YES;
}
- (id)nullSelector
{
    return nil;
}
- (void)dealloc
{
    [_object release];
    [super dealloc];
}
- (id)initWithObject:(id)aObject
{
    self = [super init];
    if (self != nil)
        _object = [aObject retain];
    return self;
}
@end
