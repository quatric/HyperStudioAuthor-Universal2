#import "HSRunTimeEditorUndoManager.h"
@implementation HSRunTimeEditorUndoManager
- (void)registerUndoWithTarget:(id)aTarget selector:(SEL)aSelector object:(id)aObject
{
    [[self delegate] willRegisterUndoInUndoManager:self];
    [super registerUndoWithTarget:aTarget selector:aSelector object:aObject];
    [[self delegate] didRegisterUndoInUndoManager:self];
}
- (id)prepareWithInvocationTarget:(id)aTarget
{
    [[self delegate] willRegisterUndoInUndoManager:self];
    id proxy = [super prepareWithInvocationTarget:aTarget];
    [[self delegate] didRegisterUndoInUndoManager:self];
    return proxy;
}
- (id)delegate
{
    return _delegate;
}
- (void)setDelegate:(id)aDelegate
{
    _delegate = aDelegate;
}
@end
