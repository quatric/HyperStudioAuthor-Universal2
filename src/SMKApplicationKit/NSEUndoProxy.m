#import "NSEUndoProxy.h"

@implementation NSEUndoProxy

/* i386 ivar offsets: _undoManager=0x4, _undoTarget=0x8 */

// The next message sent to the proxy is registered as the undo action, in
// aManager, to be sent to aTarget.
- (id)prepareUndoInManager:(id)aManager withInvocationTarget:(id)aTarget
{
    _undoTarget = aTarget;
    _undoManager = aManager;
    return self;
}

// Registers [aTarget aSelector:aObject] as the undo action, through the
// proxy (so the undo manager keeps the proxy, not the target).
- (void)registerUndoInManager:(id)aManager withTarget:(id)aTarget selector:(SEL)aSelector object:(id)aObject
{
    NSMethodSignature *signature = [aTarget methodSignatureForSelector:aSelector];
    if (!signature)
        return;
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    if (!invocation)
        return;
    [invocation setSelector:aSelector];
    [invocation setArgument:&aObject atIndex:2];
    [invocation retainArguments];
    [[aManager prepareWithInvocationTarget:self] NSEUndoProxy_performUndoActionWithInvocation:invocation
                                                                                       target:aTarget];
}

- (void)forwardInvocation:(id)aInvocation
{
    if (!_undoTarget) {
        [super forwardInvocation:aInvocation];
        return;
    }
    [aInvocation setTarget:nil];
    [aInvocation retainArguments];
    NSUndoManager *manager = _undoManager;
    id target = _undoTarget;
    _undoManager = nil;
    _undoTarget = nil;
    [[manager prepareWithInvocationTarget:self] NSEUndoProxy_performUndoActionWithInvocation:aInvocation
                                                                                      target:target];
}

- (id)methodSignatureForSelector:(SEL)aSelector
{
    if (!_undoTarget)
        return [super methodSignatureForSelector:aSelector];
    return [_undoTarget methodSignatureForSelector:aSelector];
}

- (void)NSEUndoProxy_performUndoActionWithInvocation:(id)aInvocation target:(void *)aTarget
{
    [aInvocation invokeWithTarget:(id)aTarget];
    [aInvocation setTarget:nil];
}

- (NSUInteger)hash
{
    return (NSUInteger)self >> 2;
}

- (BOOL)isEqual:(id)aEqual
{
    return aEqual == self;
}

@end

