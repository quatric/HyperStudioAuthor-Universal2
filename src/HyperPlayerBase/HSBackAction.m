#import "HSBackAction.h"
// Goes back to the previously visited card (navigation history).
@implementation HSBackAction
- (BOOL)canBeExportedToHTML5DocumentType:(id)aType
{
    return YES;
}
- (BOOL)canBeStoredAsXMLElement
{
    return YES;
}
- (id)XMLElementName
{
    return @"actBack";
}
// Only within the stack the action belongs to.
- (BOOL)canRunInContext:(id)aContext
{
    if (![super canRunInContext:aContext])
        return NO;
    return [[aContext document] stack] == [self stack];
}
// Stage 13: the operation finished.
- (void)willConcludeNavigationOperation:(id)aOperation
{
    [[[_context navigationController] historyStack] concludeHistoryOperation:[aOperation stage] == 13];
}
- (void)willStartNavigationOperation:(id)aOperation
{
    [[[_context navigationController] historyStack] startBackOperation];
}
- (id)createNavigationOperation
{
    return [[[_context navigationController] historyStack] createBackNavigationOperationWithTransition:[self transition]];
}
- (BOOL)canGoToHyperDestinationCard
{
    return [[_context navigationController] canGoBack];
}
- (id)cantChangeCardAlertMessage
{
    return [[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"HSCannotGoBackAlertMessage" value:@"" table:@"Alerts"];
}
- (id)cantChangeCardAlertTitle
{
    return [[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"HSCannotGoBackAlertTitle" value:@"" table:@"Alerts"];
}
@end
