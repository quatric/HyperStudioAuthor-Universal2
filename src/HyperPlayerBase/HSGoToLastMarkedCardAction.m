#import "HSGoToLastMarkedCardAction.h"
// Goes back to the last marked card visited (or says there's none).
@implementation HSGoToLastMarkedCardAction
- (BOOL)canBeExportedToHTML5DocumentType:(id)aType
{
    return YES;
}
- (id)XMLElementName
{
    return @"actLastMarkedCard";
}
- (BOOL)canBeStoredAsXMLElement
{
    return YES;
}
- (void)alertDidEnd:(id)aEnd returnCode:(NSInteger)aCode contextInfo:(void *)aInfo
{
    [self notifyDidFinish];
}
- (void)startInContext:(id)aContext
{
    if ([[HSHistoryStack sharedHistoryStack] lastMarkedCard] == nil)
        [aContext displayAlert:[self noMarkedCardsAlert] modalDelegate:self didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) contextInfo:NULL];
    else
        [super startInContext:aContext];
}
- (BOOL)canRunInContext:(id)aContext
{
    if (![super canRunInContext:aContext])
        return NO;
    return [[aContext document] stack] == [self stack];
}
- (id)noMarkedCardsAlert
{
    if (_noMarkedCardsAlert == nil) {
        HSExecutableResourceProvider *resources = [HSExecutableResourceProvider sharedInstance];
        _noMarkedCardsAlert = [HSAlert new];
        [_noMarkedCardsAlert setMessageText:[resources localizedStringForKey:@"Cannot perform action" value:@"" table:@"Alerts"]];
        [_noMarkedCardsAlert setInformativeText:[resources localizedStringForKey:@"HSNoMarkedCardsVisited" value:@"" table:@"Alerts"]];
        [_noMarkedCardsAlert addButtonWithTitle:[resources localizedStringForKey:@"OK" value:@"" table:@"Alerts"]];
        [_noMarkedCardsAlert setAlertStyle:5];
    }
    return _noMarkedCardsAlert;
}
- (id)createNavigationOperation
{
    return [[[[_context document] historyStack] lastMarkedCard] createNavigationOperationWithTransition:[self transition]];
}
- (void)dealloc
{
    [_noMarkedCardsAlert release];
    [super dealloc];
}
@end
