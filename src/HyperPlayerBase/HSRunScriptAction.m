#import "HSRunScriptAction.h"
// Runs a user script (JavaScript) on the object.
@implementation HSRunScriptAction
- (BOOL)isHyperValid
{
    return [_script isValid] && [_script usesValidUIDs];
}
- (BOOL)hasHyperWarnings
{
    return [_script hasPotentialErrors];
}
- (void)startInContext:(id)aContext
{
    [self notifyDidFinish];
}
- (void)showInvalidScriptAlert
{
    HSAlert *alert = [[HSAlert new] autorelease];
    HSExecutableResourceProvider *resources = [HSExecutableResourceProvider sharedInstance];
    NSString *message = [resources localizedStringForKey:@"Java Script Alert" value:@"" table:@"Alerts"];
    NSString *information = [resources localizedStringForKey:@"It is impossible to run script. It contains syntax errors or refers to deleted stack objects. Open it in script editor for further details." value:@"" table:@"Alerts"];
    [alert setMessageText:message];
    [alert setInformativeText:information];
    [alert setAlertStyle:5];
    [alert beginSheetModalForWindow:[[[self document] playerCardView] window] modalDelegate:self didEndSelector:NULL contextInfo:NULL];
}
- (void)scriptDidFinish:(id)aFinish
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"HSScriptControllerDidFinishNotification" object:[[self hyperObject] scriptController]];
    [self notifyDidFinish];
}
- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    return [[super keysForExtraStoringWithCodingContext:aContext] arrayByAddingObject:@"script"];
}
- (void)setHyperScript:(id)aScript
{
    if ([[self hyperScript] isEqual:aScript])
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change Script" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setHyperScript:[self hyperScript]];
    [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSScriptAttribute) ofObject:self withUserInfo:nil];
    [_script release];
    _script = [aScript retain];
    [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSScriptAttribute) ofObject:self withUserInfo:nil];
}
- (id)hyperScript
{
    return _script;
}
- (void)dealloc
{
    [_script release];
    [super dealloc];
}
@end
