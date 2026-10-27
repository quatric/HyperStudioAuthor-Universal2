#import "HSMakeHomeStackAction.h"
// "Make Home Stack": makes the current stack the home stack, saving it first
// if it was never saved. Only the HyperStudio application supports it.
@implementation HSMakeHomeStackAction
- (BOOL)canBeExportedToHTML5DocumentType:(id)aType
{
    return YES;
}
- (id)XMLElementName
{
    return @"actMakeHomeStack";
}
- (BOOL)canBeStoredAsXMLElement
{
    return YES;
}
- (BOOL)supportedInIPad
{
    return YES;
}
// The context is the action execution context.
- (void)document:(id)aDocument didSave:(BOOL)aSave contextInfo:(void *)aInfo
{
    if (aSave)
        [self setHomeStackToCurrentStackWithActionExecutionContext:(id)aInfo];
    else
        [self showCantSetHomeStackAlertWithActionExecutionContext:(id)aInfo];
}
- (void)startInContext:(id)aContext
{
    if (![HSHomeStackController isHomeStackSupportedByCurrentEnvironment])
        [self showCantExecuteHomeStackActionAlertWithActionExecutionContext:aContext];
    else if ([aContext documentURL] != nil)
        [self setHomeStackToCurrentStackWithActionExecutionContext:aContext];
    else
        [aContext runModalSavePanelForSaveOperation:NSSaveOperation
                                           delegate:self
                                    didSaveSelector:@selector(document:didSave:contextInfo:)
                                        contextInfo:aContext];
}
- (void)showCantExecuteHomeStackActionAlertWithActionExecutionContext:(id)aContext
{
    HSExecutableResourceProvider *provider = [HSExecutableResourceProvider sharedInstance];
    HSAlert *alert = [HSAlert new];
    [alert setAlertStyle:5];
    NSString *format = [provider localizedStringForKey:@"Cannot run the action" value:@"" table:@"Alerts"];
    NSString *name = [provider localizedStringForKey:@"I'm Home Stack" value:@"" table:@"Alerts"];
    [alert setMessageText:[NSString stringWithFormat:format, name]];
    [alert setInformativeText:[provider localizedStringForKey:@"This functionality is supported only in HyperStudio 5."
                                                        value:@""
                                                        table:@"Alerts"]];
    [alert addButtonWithTitle:[provider localizedStringForKey:@"OK" value:@"" table:@"Alerts"]];
    [alert runModal];
    [alert release];
    [self notifyDidFinish];
}
- (void)setHomeStackToCurrentStackWithActionExecutionContext:(id)aContext
{
    [aContext setHomeStackToCurrentStack];
    [self notifyDidFinish];
}
- (void)alertDidEnd:(id)aEnd returnCode:(NSInteger)aCode contextInfo:(void *)aInfo
{
    [aEnd release];
    [self notifyDidFinish];
}
// The alert is released in alertDidEnd:returnCode:contextInfo:.
- (void)showCantSetHomeStackAlertWithActionExecutionContext:(id)aContext
{
    HSExecutableResourceProvider *provider = [HSExecutableResourceProvider sharedInstance];
    HSAlert *alert = [HSAlert new];
    [alert setAlertStyle:5];
    [alert setMessageText:[provider localizedStringForKey:@"UnsavedDocumentAsHomeStackAlertMessageText"
                                                    value:@""
                                                    table:@"Alerts"]];
    [alert setInformativeText:[provider localizedStringForKey:@"UnsavedDocumentAsHomeStackAlertInformativeText"
                                                        value:@""
                                                        table:@"Alerts"]];
    [alert addButtonWithTitle:[provider localizedStringForKey:@"OK" value:@"" table:@"Alerts"]];
    [aContext displayAlert:alert
             modalDelegate:self
            didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:)
               contextInfo:NULL];
}
- (BOOL)isSynchronous
{
    return YES;
}
- (BOOL)canChangeSynchronousFlag
{
    return NO;
}
@end
