#import "HSResponderProxy.h"
// A responder that passes what it can't do to the real responder.
@implementation HSResponderProxy
- (void)forwardInvocation:(id)aInvocation
{
    [aInvocation invokeWithTarget:_realResponder];
}
- (id)methodSignatureForSelector:(SEL)aSelector
{
    NSMethodSignature *signature = [super methodSignatureForSelector:aSelector];
    if (signature == nil)
        signature = [_realResponder methodSignatureForSelector:aSelector];
    return signature;
}
- (BOOL)conformsToProtocol:(id)aProtocol
{
    return [super conformsToProtocol:aProtocol] || [_realResponder conformsToProtocol:aProtocol];
}
- (void)doCommandBySelector:(SEL)aSelector
{
    if ([super respondsToSelector:aSelector])
        [super doCommandBySelector:aSelector];
    else if ([_realResponder respondsToSelector:aSelector])
        [(NSResponder *)_realResponder doCommandBySelector:aSelector];
}
- (BOOL)tryToPerform:(SEL)aPerform with:(id)aWith
{
    if ([super respondsToSelector:aPerform])
        return [super tryToPerform:aPerform with:aWith];
    if (![_realResponder respondsToSelector:aPerform])
        return NO;
    [_realResponder performSelector:aPerform withObject:aWith];
    return YES;
}
- (BOOL)respondsToSelector:(SEL)aSelector
{
    return [super respondsToSelector:aSelector] || [_realResponder respondsToSelector:aSelector];
}
- (void)dealloc
{
    [super dealloc];
}
// (Not retained.)
- (id)initWithRealResponder:(id)aResponder
{
    self = [super init];
    if (self != nil)
        _realResponder = aResponder;
    return self;
}
@end
