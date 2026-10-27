#import "HSGoToHomeStackAction.h"
// "Go to Home Stack": a card change to the home stack's default card. Valid
// when the home stack file can be read (always outside HyperStudio, where
// the action only shows an alert). A missing home stack is reset to the
// default one after an alert.
@implementation HSGoToHomeStackAction
- (id)HTML5DictionaryRepresentationInContext:(id)aContext
{
    if (![self isValid])
        return nil;
    id url = [[HSHomeStackController sharedHomeStackController] homeStackURL];
    NSString *name = [aContext nameForLinkedStackURL:url];
    NSMutableDictionary *dictionary;
    NSString *destination;
    if ([name length] != 0) {
        dictionary = [super HTML5DictionaryRepresentationInContext:aContext];
        destination = [NSString stringWithFormat:@"%@/stack.json", name];
    } else {
        if (![aContext shouldAddLinkedStacks])
            return nil;
        dictionary = [super HTML5DictionaryRepresentationInContext:aContext];
        destination = @"";
    }
    [dictionary setObject:destination forKey:@"goto"];
    return dictionary;
}
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
    return @"actGoToHomeStack";
}
- (void)homeStackURLDidChange:(id)aChange
{
    [[self attributeNotificationCenter] notifyChange:2
                                         ofAttribute:@protocol(HSActionValidationStatusAttribute)
                                            ofObject:self
                                        withUserInfo:nil];
}
// Also starts watching the home stack URL. (The original adds the observer
// on every call; removing it first keeps a single registration.)
- (BOOL)isValid
{
    if (![HSHomeStackController isHomeStackSupportedByCurrentEnvironment])
        return YES;
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    id controller = [HSHomeStackController sharedHomeStackController];
    [center removeObserver:self name:HSHomeStackURLDidChangeNotification object:controller];
    [center addObserver:self
               selector:@selector(homeStackURLDidChange:)
                   name:HSHomeStackURLDidChangeNotification
                 object:controller];
    NSURL *url = [[HSHomeStackController sharedHomeStackController] homeStackURL];
    return url != nil && [[NSFileManager defaultManager] isReadableFileAtPath:[url path]];
}
- (id)createNavigationOperation
{
    id controller = [HSHomeStackController sharedHomeStackController];
    return [[HSNavigationOperation alloc] initWithDestinationStackURL:[controller homeStackURL]
                                               destinationCardIndex:[controller defaultCardIndex]
                                                         transition:[self transition]];
}
- (void)startInContext:(id)aContext
{
    if (![HSHomeStackController isHomeStackSupportedByCurrentEnvironment]) {
        [self showCantGoHomeStackAlertWithActionExecutionContext:aContext];
        return;
    }
    if ([self isValid]) {
        [[[aContext navigationController] presentationSync] prepareForUserInitiatedNavigationOperation];
        [super startInContext:aContext];
        return;
    }
    if ([[self document] isWebPlayerDocument])
        return;
    [aContext displayAlert:[self cantFindHomeStackAlert]
             modalDelegate:self
            didEndSelector:@selector(cantFindHomeStackAlertDidEnd:returnCode:contextInfo:)
               contextInfo:aContext];
}
- (void)cantFindHomeStackAlertDidEnd:(id)aEnd returnCode:(NSInteger)aCode contextInfo:(void *)aInfo
{
    [[HSHomeStackController sharedHomeStackController] resetHomeStackURL];
    [self setAndPerformNavigationOperationInContext:(id)aInfo];
}
// Kept in the change card action's alert (released by it).
- (id)cantFindHomeStackAlert
{
    if (_alert == nil) {
        HSExecutableResourceProvider *provider = [HSExecutableResourceProvider sharedInstance];
        _alert = [HSAlert new];
        [_alert setMessageText:[provider localizedStringForKey:@"CannotOpenHomeStackAlertTitle" value:@"" table:@"Alerts"]];
        [_alert setInformativeText:[provider localizedStringForKey:@"CannotOpenHomeStackAlertMessage"
                                                             value:@""
                                                             table:@"Alerts"]];
    }
    return _alert;
}
- (void)alertDidEnd:(id)aEnd returnCode:(NSInteger)aCode contextInfo:(void *)aInfo
{
    [aEnd release];
    [self notifyDidFinish];
}
// The alert is released in alertDidEnd:returnCode:contextInfo:.
- (void)showCantGoHomeStackAlertWithActionExecutionContext:(id)aContext
{
    HSExecutableResourceProvider *provider = [HSExecutableResourceProvider sharedInstance];
    HSAlert *alert = [HSAlert new];
    [alert setAlertStyle:5];
    [alert setMessageText:[provider localizedStringForKey:@"CantGoToHomeStackAlertMessageText" value:@"" table:@"Alerts"]];
    [alert setInformativeText:[provider localizedStringForKey:@"CantGoToHomeStackAlertInformativeText"
                                                        value:@""
                                                        table:@"Alerts"]];
    [alert addButtonWithTitle:[provider localizedStringForKey:@"OK" value:@"" table:@"Alerts"]];
    [aContext displayAlert:alert
             modalDelegate:self
            didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:)
               contextInfo:NULL];
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}
@end
