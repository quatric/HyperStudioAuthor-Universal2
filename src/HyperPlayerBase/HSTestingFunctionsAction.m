#import "HSTestingFunctionsAction.h"
// A testing (quiz) action: records a correct (type 1) or incorrect (type 2)
// answer for its object on the current card, or asks the user's name
// (type 3), in the stack's testing functions. An unsaved stack first warns
// that the results can't be stored.
@implementation HSTestingFunctionsAction
- (void)setTestingFunctionType:(NSInteger)aType
{
    if ([self testingFunctionType] == aType)
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Set Testing Functon Type" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setTestingFunctionType:[self testingFunctionType]];
    [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSTestingFunctionTypeAttribute) ofObject:self withUserInfo:nil];
    _testingFunctionType = (int)aType;
    [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSTestingFunctionTypeAttribute) ofObject:self withUserInfo:nil];
}
- (NSInteger)testingFunctionType
{
    return _testingFunctionType;
}
- (BOOL)canChangeSynchronousFlag
{
    return NO;
}
- (BOOL)isSynchronous
{
    return YES;
}
// The user name sheet ended; self was retained for it.
- (void)sheetDidEnd:(id)aEnd returnCode:(NSInteger)aCode contextInfo:(void *)aInfo
{
    id testing = [[self stack] queryHyperInterface:@protocol(HSTestingFunctions)];
    if (testing != nil)
        [testing setUserName:[_userNameField stringValue]];
    [aEnd orderOut:self];
    [self notifyDidFinish];
    [self release];
}
// A name is required.
- (void)userNameEntered:(id)aEntered
{
    if ([[_userNameField stringValue] length] != 0)
        [NSApp endSheet:[self askUserNameWindow]];
    else
        NSBeep();
}
- (void)startInContext:(id)aContext
{
    if ([aContext documentURL] != nil) {
        [self continueInContext:aContext];
        return;
    }
    HSAlert *alert = [HSAlert new];
    [alert setAlertStyle:5];
    HSExecutableResourceProvider *provider = [HSExecutableResourceProvider sharedInstance];
    [alert setMessageText:[provider localizedStringForKey:@"HSTestingFunctionsUnsavedDocumentMessageText" value:@"" table:@"Alerts"]];
    [alert setInformativeText:[provider localizedStringForKey:@"HSTestingFunctionsUnsavedDocumentInformativeText" value:@"" table:@"Alerts"]];
    [alert addButtonWithTitle:[provider localizedStringForKey:@"Continue" value:@"" table:@"Alerts"]];
    [alert addButtonWithTitle:[provider localizedStringForKey:@"Cancel" value:@"" table:@"Alerts"]];
    [aContext retain];
    [aContext displayAlert:alert modalDelegate:self didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) contextInfo:aContext];
}
// The context was retained for the alert. Continue goes on, Cancel finishes.
- (void)alertDidEnd:(id)aEnd returnCode:(NSInteger)aCode contextInfo:(void *)aInfo
{
    [aEnd release];
    id context = [(id)aInfo autorelease];
    if (aCode == NSAlertFirstButtonReturn)
        [self continueInContext:context];
    else
        [self notifyDidFinish];
}
- (void)continueInContext:(id)aContext
{
    id testing = [[self stack] queryHyperInterface:@protocol(HSTestingFunctions)];
    id cardUID = [[[self card] queryHyperInterface:@protocol(HSObjectAttributes)] hyperUID];
    id objectUID = [[[self hyperObject] queryHyperInterface:@protocol(HSObjectAttributes)] hyperUID];
    switch ([self testingFunctionType]) {
    case 1:
        [testing recordCorrectAnswerForObjectWithUID:objectUID cardUID:cardUID];
        break;
    case 2:
        [testing recordIncorrectAnswerForObjectWithUID:objectUID cardUID:cardUID];
        break;
    case 3:
        [self retain];
        [aContext beginModalSheet:[self askUserNameWindow] modalDelegate:self didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:) contextInfo:NULL];
        return;
    }
    [self notifyDidFinish];
}
// Loaded from its nib on first use.
- (id)askUserNameWindow
{
    if (_askUserNameWindow == nil) {
        [NSBundle loadNibNamed:@"TestingFunctionsUserName" owner:self];
        [_askUserNameWindow setDefaultButtonCell:[_defaultButton cell]];
    }
    return _askUserNameWindow;
}
- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    return [[super keysForExtraStoringWithCodingContext:aContext] arrayByAddingObjectsFromArray:[NSArray arrayWithObject:@"testingFunctionType"]];
}
@end
