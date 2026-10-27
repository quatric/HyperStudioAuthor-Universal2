#import "HSForwardAction.h"
@implementation HSForwardAction
- (BOOL)canBeExportedToHTML5DocumentType:(id)aType
{
    return YES;
}
// Only within the action's own stack.
- (BOOL)canRunInContext:(id)aContext
{
    if (![super canRunInContext:aContext])
        return NO;
    return [[aContext document] stack] == [self stack];
}
// Stage 13 is the navigation operation's finished stage.
- (void)willConcludeNavigationOperation:(id)aOperation
{
    [[[_context navigationController] historyStack] concludeHistoryOperation:[aOperation stage] == 13];
}
- (void)willStartNavigationOperation:(id)aOperation
{
    [[[_context navigationController] historyStack] startForwardOperation];
}
- (id)createNavigationOperation
{
    return [[[_context navigationController] historyStack] createForwardNavigationOperationWithTransition:[self transition]];
}
@end
