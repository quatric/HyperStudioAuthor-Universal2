#import "HSGoToURLAction.h"

// Opens a web page or composes mail (URL type 1, mailto: URLs) through one of
// two owned sub-actions.
@implementation HSGoToURLAction
+ (id)actionWithURL:(id)aURL
{
    id action = [self action];
    if (aURL) {
        [action setURLType:[[aURL absoluteString] hasPrefix:@"mailto"] ? 1 : 0];
        [[[action currentAction] queryHyperInterface:@protocol(HSMutableURLAttributes)] setURL:aURL];
    }
    return action;
}
- (void)importFromXMLElementRepresentation:(id)aRepresentation inContext:(id)aContext
{
    [super importFromXMLElementRepresentation:aRepresentation inContext:aContext];
    NSURL *url = [NSURL URLWithString:[[aRepresentation attributeForName:@"url"] stringValue]];
    [self setURLType:[[url absoluteString] hasPrefix:@"mailto"] ? 1 : 0];
    [[[self currentAction] queryHyperInterface:@protocol(HSMutableURLAttributes)] setURL:url];
}
- (id)XMLElementRepresentationInContext:(id)aContext
{
    id element = [super XMLElementRepresentationInContext:aContext];
    NSURL *url = [[[self currentAction] queryHyperInterface:@protocol(HSURLAttribute)] URL];
    [element addAttribute:[NSXMLNode attributeWithName:@"url" stringValue:[url absoluteString]]];
    return element;
}
- (id)XMLElementName
{
    return @"actOpenWebPage";
}
- (BOOL)canBeStoredAsXMLElement
{
    return YES;
}
- (BOOL)supportedInIPad
{
    return YES;
}
- (BOOL)canBeExportedToHTML5DocumentType:(id)aType
{
    return YES;
}
- (id)HTML5DictionaryRepresentationInContext:(id)aContext
{
    return [[self currentAction] HTML5DictionaryRepresentationInContext:aContext];
}
- (BOOL)isValid
{
    return [[self currentAction] isValid];
}
// Forwards the sub-action's validation changes as this action's own.
- (void)validateActionWithNotification:(id)aNotification
{
    [[self attributeNotificationCenter] notifyChange:[aNotification attributeChange] ofAttributeSet:[aNotification attributeProtocolSet] ofObject:self withUserInfo:[aNotification userInfo]];
}
- (id)hyperObjectForAction:(id)aAction
{
    return [self hyperObject];
}
- (id)openWebPageActionAttributes
{
    return [[self openWebPageAction] queryHyperInterface:@protocol(HSOpenWebPageActionAttributes)];
}
- (id)sendMailActionAttributes
{
    return [[self sendMailAction] queryHyperInterface:@protocol(HSSendMailActionAttributes)];
}
- (void)setURLType:(NSInteger)aType
{
    if ([self URLType] == aType)
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Set URL Type" value:@"" table:@"UndoManager"]];
    [(HSGoToURLAction *)[[self undoManager] prepareWithInvocationTarget:self] setURLType:[self URLType]];
    [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSActionValidationStatusAttribute) ofObject:self withUserInfo:nil];
    [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSGoToURLActionTypeAttribute) ofObject:self withUserInfo:nil];
    [self setCurrentAction:(aType == 0 ? [self openWebPageAction] : [self sendMailAction])];
    [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSGoToURLActionTypeAttribute) ofObject:self withUserInfo:nil];
    [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSActionValidationStatusAttribute) ofObject:self withUserInfo:nil];
}
- (NSInteger)URLType
{
    return [[[[self currentAction] class] actionType] isEqual:[HSSendMailAction actionType]] ? 1 : 0;
}
// Skipped when external links and mail are restricted.
- (void)startInContext:(id)aContext
{
    if (![HSRestrictionsManager restrictionState:HSOpenExternalLinksAndEMailDisabled])
        [[self currentAction] startInContext:aContext];
    [self notifyDidFinish];
}
- (void)setCurrentAction:(id)aAction
{
    if (_currentAction == aAction)
        return;
    [_currentAction setOwner:nil];
    [_currentAction release];
    _currentAction = [aAction retain];
    if ([_currentAction implementsHyperInterface:@protocol(HSSendMailActionAttributes)]) {
        [_sendMailAction release];
        _sendMailAction = [_currentAction retain];
    } else if ([_currentAction implementsHyperInterface:@protocol(HSOpenWebPageActionAttributes)]) {
        [_openWebPageAction release];
        _openWebPageAction = [_currentAction retain];
    }
    [_currentAction setOwner:self];
}
- (id)currentAction
{
    if (!_currentAction) {
        _currentAction = [[self openWebPageAction] retain];
        [_currentAction setOwner:self];
    }
    return _currentAction;
}
- (id)sendMailAction
{
    if (!_sendMailAction) {
        _sendMailAction = [HSSendMailAction new];
        [_sendMailAction addObserver:self selector:@selector(validateActionWithNotification:) ofChanges:HSAllAttributeChanges ofAttribute:@protocol(HSActionValidationStatusAttribute) withPriority:0];
    }
    return _sendMailAction;
}
- (id)openWebPageAction
{
    if (!_openWebPageAction) {
        _openWebPageAction = [HSOpenWebPageAction new];
        [_openWebPageAction addObserver:self selector:@selector(validateActionWithNotification:) ofChanges:HSAllAttributeChanges ofAttribute:@protocol(HSActionValidationStatusAttribute) withPriority:0];
    }
    return _openWebPageAction;
}
- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    return [[super keysForExtraStoringWithCodingContext:aContext] arrayByAddingObjectsFromArray:[NSArray arrayWithObjects:@"currentAction", nil]];
}
- (void)dealloc
{
    [_openWebPageAction removeAttributeObserver:self];
    [_sendMailAction removeAttributeObserver:self];
    [_openWebPageAction release];
    [_sendMailAction release];
    [_currentAction release];
    [super dealloc];
}
@end
