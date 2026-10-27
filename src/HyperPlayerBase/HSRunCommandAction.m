#import "HSRunCommandAction.h"
// "Run command" (XML "actOpenStack"): 0 new document, 1 open document
// (default), 2 send HyperStudio feedback. Each one needs the document
// controller or application to support it; otherwise an alert says so.
@implementation HSRunCommandAction
- (void)importFromXMLElementRepresentation:(id)aRepresentation inContext:(id)aContext
{
    [super importFromXMLElementRepresentation:aRepresentation inContext:aContext];
    [self setRunCommandActionType:[[[aRepresentation attributeForName:@"openStackType"] stringValue] intValue]];
}
- (id)XMLElementRepresentationInContext:(id)aContext
{
    id element = [super XMLElementRepresentationInContext:aContext];
    [element addAttribute:[NSXMLNode attributeWithName:@"openStackType"
                                           stringValue:[NSString stringWithFormat:@"%d", _runCommandActionType]]];
    return element;
}
- (id)XMLElementName
{
    return @"actOpenStack";
}
- (BOOL)canBeStoredAsXMLElement
{
    return YES;
}
- (BOOL)supportedInIPad
{
    return _runCommandActionType == 1;
}
- (void)setRunCommandActionType:(NSInteger)aType
{
    if ([self runCommandActionType] == aType)
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Set Run Command Action Type"
                                                                             value:@""
                                                                             table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setRunCommandActionType:[self runCommandActionType]];
    [[self attributeNotificationCenter] notifyChange:1
                                         ofAttribute:@protocol(HSRunCommandActionTypeAttribute)
                                            ofObject:self
                                        withUserInfo:nil];
    _runCommandActionType = (int)aType;
    [[self attributeNotificationCenter] notifyChange:2
                                         ofAttribute:@protocol(HSRunCommandActionTypeAttribute)
                                            ofObject:self
                                        withUserInfo:nil];
}
- (NSInteger)runCommandActionType
{
    return _runCommandActionType;
}
- (void)startInContext:(id)aContext
{
    [self performSelector:@selector(startAfterClosingCurrentUndoGroup) withObject:nil afterDelay:0];
}
// When the command runs, the action does not notify that it finished (as in
// the original); only the alert path does.
- (void)startAfterClosingCurrentUndoGroup
{
    id controller = [NSDocumentController sharedDocumentController];
    NSString *commandName = nil;
    switch ([self runCommandActionType]) {
    case 0:
        if ([controller respondsToSelector:@selector(allowNewDocument)] && [controller allowNewDocument]) {
            [controller openUntitledDocumentAndDisplay:YES error:NULL];
            return;
        }
        commandName = [[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"New Document"
                                                                                     value:@""
                                                                                     table:@"Alerts"];
        break;
    case 1:
        if ([controller respondsToSelector:@selector(allowOpenDocument)] && [controller allowOpenDocument]) {
            NSArray *urls = [controller URLsFromRunningOpenPanel];
            if ([urls count] == 0)
                urls = nil;
            else if (![controller isMultiDocument])
                urls = [NSArray arrayWithObject:[urls extraFirstObject]];
            for (NSURL *url in urls)
                [controller openDocumentWithContentsOfURL:url display:YES error:NULL];
            return;
        }
        commandName = [[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"Open Document"
                                                                                     value:@""
                                                                                     table:@"Alerts"];
        break;
    case 2:
        if ([controller respondsToSelector:@selector(allowProvideHyperStudioFeedback)]) {
            id target = [NSApp targetForAction:@selector(provideHyperStudioFeedback:)];
            if (target != nil)
                [NSApp sendAction:@selector(provideHyperStudioFeedback:) to:target from:nil];
            return;
        }
        break;
    }
    HSExecutableResourceProvider *provider = [HSExecutableResourceProvider sharedInstance];
    HSAlert *alert = [HSAlert new];
    NSString *format = [provider localizedStringForKey:@"Cannot run the action" value:@"" table:@"Alerts"];
    [alert setMessageText:[NSString stringWithFormat:format, commandName]];
    [alert setInformativeText:[provider localizedStringForKey:@"This functionality is supported only in HyperStudio 5."
                                                        value:@""
                                                        table:@"Alerts"]];
    [alert runModal];
    [alert release];
    [self notifyDidFinish];
}
- (BOOL)canRunInContext:(id)aContext
{
    return ![aContext isInHyperCastingMode];
}
- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    return [[super keysForExtraStoringWithCodingContext:aContext]
        arrayByAddingObjectsFromArray:[NSArray arrayWithObject:@"runCommandActionType"]];
}
- (id)init
{
    self = [super init];
    if (self != nil)
        _runCommandActionType = 1;
    return self;
}
@end
