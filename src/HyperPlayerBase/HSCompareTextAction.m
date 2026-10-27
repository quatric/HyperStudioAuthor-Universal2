#import "HSCompareTextAction.h"
#import "HSActionEvent.h"
#import "HSActionExecutionContext.h"
#import "HSAlert.h"
#import "HSExecutableResourceProvider.h"
#import "HSPlaySoundAction.h"
#import "HSUID.h"

// Compares the text of a response field with another field's text or a
// defined string, then runs the click actions of the right-answer or
// wrong-answer object.
@implementation HSCompareTextAction

// The seven comparison selectors, in the order the editor lists them.
+ (SEL *)compareSelectors
{
    static SEL selectors[7];
    if (selectors[0] == NULL) {
        selectors[0] = @selector(HSCompareTextAction_contains:options:);
        selectors[1] = @selector(HSCompareTextAction_isLessThan:options:);
        selectors[2] = @selector(HSCompareTextAction_isLessThanOrEqualTo:options:);
        selectors[3] = @selector(HSCompareTextAction_isEqualTo:options:);
        selectors[4] = @selector(HSCompareTextAction_isNotEqualTo:options:);
        selectors[5] = @selector(HSCompareTextAction_isGreaterThanOrEqualTo:options:);
        selectors[6] = @selector(HSCompareTextAction_isGreaterThan:options:);
    }
    return selectors;
}

- (id)HTML5DictionaryRepresentationInContext:(id)aContext
{
    if (![self isValid])
        return nil;
    NSMutableDictionary *representation = [super HTML5DictionaryRepresentationInContext:aContext];
    [representation setObject:[_responseObjectUID stringValue] forKey:@"responseTextUID"];
    if (_textToMatchObjectUID != nil)
        [representation setObject:[_textToMatchObjectUID stringValue] forKey:@"textToMatchUID"];
    else
        [representation setObject:_definedString forKey:@"customText"];
    [representation setObject:(_comparisonMatchObjectUID != nil ? [_comparisonMatchObjectUID stringValue] : [NSString string]) forKey:@"rightAnswerUID"];
    [representation setObject:(_comparisonMismatchObjectUID != nil ? [_comparisonMismatchObjectUID stringValue] : [NSString string]) forKey:@"wrongAnswerUID"];
    [representation setObject:NSStringFromSelector(_comparisonSelector) forKey:@"compareSelector"];
    [representation setObject:(_isCaseSensitiveComparison ? @"1" : @"0") forKey:@"isCaseSensitiveComparison"];
    return representation;
}

- (BOOL)canBeExportedToHTML5DocumentType:(id)aType
{
    return YES;
}

// Copies of play-sound actions run so that they belong to this action's owner.
- (void)startInContext:(id)aContext
{
    id stack = [self stack];
    id response = [[stack childInTreeWithUID:[self responseObjectUID]] queryHyperInterface:@protocol(HSSystemTextViewAttribute)];
    id textToMatch = [[stack childInTreeWithUID:[self textToMatchObjectUID]] queryHyperInterface:@protocol(HSSystemTextViewAttribute)];
    if ((textToMatch != nil || _definedString != nil) && response != nil) {
        NSUInteger options = NSNumericSearch | (_isCaseSensitiveComparison ? 0 : NSCaseInsensitiveSearch);
        NSString *string = textToMatch != nil ? [textToMatch hyperPlainText] : _definedString;
        BOOL matched = ((BOOL (*)(id, SEL, id, NSUInteger))objc_msgSend)([response hyperPlainText], _comparisonSelector, string, options);
        HSActionEvent *event = [HSActionEvent actionEventOfType:kHSClickActionEventType];
        HSUID *uid = matched ? _comparisonMatchObjectUID : _comparisonMismatchObjectUID;
        id target = nil;
        if (uid != nil)
            target = [stack childInTreeWithUID:uid];
        if (uid == nil || target != nil) {
            for (id action in [[target queryHyperInterface:@protocol(HSActor)] hyperActionsForEvent:event]) {
                if ([action isKindOfType:[HSPlaySoundAction actionType]]) {
                    action = [[action copy] autorelease];
                    [action setOwner:[self owner]];
                }
                [action startInContext:aContext];
            }
            [self notifyDidFinish];
            return;
        }
    }
    [aContext cancelIfPresentSequencerActionWithObject:[[self owner] hyperObjectForAction:self]];
    [aContext displayAlert:[self missingObjectsAlert] modalDelegate:self didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) contextInfo:NULL];
}

- (id)missingObjectsAlert
{
    NSString *informativeText = [[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"HSCannotPerformActionAlertInformativeText" value:@"" table:@"Alerts"];
    NSString *message = [[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"HSCannotPerformActionAlertMessageText" value:@"" table:@"Alerts"];
    return [HSAlert alertWithMessageText:message defaultButton:nil alternateButton:nil otherButton:nil informativeText:informativeText];
}

- (void)alertDidEnd:(id)aEnd returnCode:(NSInteger)aCode contextInfo:(void *)aInfo
{
    [self notifyDidFinish];
}

- (BOOL)isAbleToStartInInvalidState
{
    return YES;
}

// Every referenced object must exist, and at least one answer object is needed.
- (BOOL)isValid
{
    id stack = [self stack];
    if ([stack childInTreeWithUID:_responseObjectUID] == nil)
        return NO;
    if ([stack childInTreeWithUID:_textToMatchObjectUID] == nil && _definedString == nil)
        return NO;
    if (_comparisonMatchObjectUID != nil && [stack childInTreeWithUID:_comparisonMatchObjectUID] == nil)
        return NO;
    if (_comparisonMismatchObjectUID != nil && [stack childInTreeWithUID:_comparisonMismatchObjectUID] == nil)
        return NO;
    return _comparisonMatchObjectUID != nil || _comparisonMismatchObjectUID != nil;
}

- (void)setCaseSensitiveComparison:(BOOL)aComparison
{
    if (_isCaseSensitiveComparison == aComparison)
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Set Ignore Case" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setCaseSensitiveComparison:_isCaseSensitiveComparison];
    [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSCompareTextActionCaseSensitiveComparisonAttribute) ofObject:self withUserInfo:nil];
    _isCaseSensitiveComparison = aComparison;
    [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSCompareTextActionCaseSensitiveComparisonAttribute) ofObject:self withUserInfo:nil];
}

- (BOOL)isCaseSensitiveComparison
{
    return _isCaseSensitiveComparison;
}

// Names are stored without the trailing "options:"; unknown names are ignored.
- (void)setComparisonSelectorName:(id)aName
{
    SEL *selectors = [HSCompareTextAction compareSelectors];
    SEL selector = NSSelectorFromString([aName stringByAppendingString:@"options:"]);
    for (int i = 0; i < 7; i++) {
        if (selectors[i] == selector) {
            _comparisonSelector = selector;
            return;
        }
    }
}

- (id)comparisonSelectorName
{
    NSString *name = NSStringFromSelector(_comparisonSelector);
    return [name substringToIndex:[name length] - 8];
}

- (void)setComparisonSelector:(SEL)aSelector
{
    if (_comparisonSelector == aSelector)
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Set Comparison Function" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setComparisonSelector:_comparisonSelector];
    [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSCompareTextActionComparisonSelectorAttribute) ofObject:self withUserInfo:nil];
    _comparisonSelector = aSelector;
    [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSCompareTextActionComparisonSelectorAttribute) ofObject:self withUserInfo:nil];
}

- (SEL)comparisonSelector
{
    return _comparisonSelector;
}

// Legacy right/wrong answer keys. For "is not equal to" the match object is
// the wrong answer.
- (void)setWrongAnswerObjectUID:(id)aUID
{
    if (_comparisonMismatchObjectUID != aUID) {
        [aUID retain];
        [_comparisonMismatchObjectUID release];
        _comparisonMismatchObjectUID = aUID;
    }
}

- (id)wrongAnswerObjectUID
{
    if (_comparisonSelector == @selector(HSCompareTextAction_isNotEqualTo:options:))
        return _comparisonMatchObjectUID;
    return _comparisonMismatchObjectUID;
}

- (void)setRightAnswerObjectUID:(id)aUID
{
    if (_comparisonMatchObjectUID != aUID) {
        [aUID retain];
        [_comparisonMatchObjectUID release];
        _comparisonMatchObjectUID = aUID;
    }
}

- (id)rightAnswerObjectUID
{
    if (_comparisonSelector == @selector(HSCompareTextAction_isNotEqualTo:options:))
        return _comparisonMismatchObjectUID;
    return _comparisonMatchObjectUID;
}

- (void)setComparisonMismatchObjectUID:(id)aUID
{
    if ([_comparisonMismatchObjectUID isEqual:aUID])
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Set Wrong Answer Object" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setComparisonMismatchObjectUID:_comparisonMismatchObjectUID];
    [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSActionValidationStatusAttribute) ofObject:self withUserInfo:nil];
    [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSCompareTextActionComparisonMismatchObjectUIDAttribute) ofObject:self withUserInfo:nil];
    [aUID retain];
    [_comparisonMismatchObjectUID release];
    _comparisonMismatchObjectUID = aUID;
    // fixed: the original sent change 1 again here, so observers never saw the did-change.
    [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSCompareTextActionComparisonMismatchObjectUIDAttribute) ofObject:self withUserInfo:nil];
    [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSActionValidationStatusAttribute) ofObject:self withUserInfo:nil];
}

- (id)comparisonMismatchObjectUID
{
    return _comparisonMismatchObjectUID;
}

- (void)setComparisonMatchObjectUID:(id)aUID
{
    if ([_comparisonMatchObjectUID isEqual:aUID])
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Set Right Answer Object" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setComparisonMatchObjectUID:_comparisonMatchObjectUID];
    [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSActionValidationStatusAttribute) ofObject:self withUserInfo:nil];
    [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSCompareTextActionComparisonMatchObjectUIDAttribute) ofObject:self withUserInfo:nil];
    [aUID retain];
    [_comparisonMatchObjectUID release];
    _comparisonMatchObjectUID = aUID;
    [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSCompareTextActionComparisonMatchObjectUIDAttribute) ofObject:self withUserInfo:nil];
    [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSActionValidationStatusAttribute) ofObject:self withUserInfo:nil];
}

- (id)comparisonMatchObjectUID
{
    return _comparisonMatchObjectUID;
}

- (void)setComparisonMismatchObjectUIDString:(id)aString
{
    [_comparisonMismatchObjectUID release];
    _comparisonMismatchObjectUID = [[HSUID UIDWithString:aString] retain];
}

- (id)comparisonMismatchObjectUIDString
{
    return [_comparisonMismatchObjectUID stringValue];
}

- (void)setComparisonMatchObjectUIDString:(id)aString
{
    [_comparisonMatchObjectUID release];
    _comparisonMatchObjectUID = [[HSUID UIDWithString:aString] retain];
}

- (id)comparisonMatchObjectUIDString
{
    return [_comparisonMatchObjectUID stringValue];
}

// Legacy key for the defined string.
- (void)setComparisonString:(id)aString
{
    if (![aString isEqual:_definedString]) {
        [_definedString release];
        _definedString = [aString retain];
    }
}

- (id)comparisonString
{
    return _definedString;
}

- (void)setDefinedString:(id)aString
{
    if ([aString isEqual:_definedString])
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Set Defined String" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setDefinedString:[self definedString]];
    [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSActionValidationStatusAttribute) ofObject:self withUserInfo:nil];
    [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSCompareTextActionDefinedStringAttribute) ofObject:self withUserInfo:nil];
    [_definedString release];
    _definedString = [aString retain];
    [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSCompareTextActionDefinedStringAttribute) ofObject:self withUserInfo:nil];
    [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSActionValidationStatusAttribute) ofObject:self withUserInfo:nil];
}

- (id)definedString
{
    return _definedString;
}

// Legacy key for the text-to-match object.
- (void)setComparisonObjectUID:(id)aUID
{
    if (_textToMatchObjectUID != aUID) {
        [aUID retain];
        [_textToMatchObjectUID release];
        _textToMatchObjectUID = aUID;
    }
}

- (id)comparisonObjectUID
{
    return _textToMatchObjectUID;
}

- (void)setTextToMatchObjectUID:(id)aUID
{
    if ([aUID isEqual:_textToMatchObjectUID])
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Set Matching Text Object" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setTextToMatchObjectUID:[self textToMatchObjectUID]];
    [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSActionValidationStatusAttribute) ofObject:self withUserInfo:nil];
    [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSCompareTextActionTextToMatchObjectAttribute) ofObject:self withUserInfo:nil];
    [_textToMatchObjectUID release];
    _textToMatchObjectUID = [aUID retain];
    [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSCompareTextActionTextToMatchObjectAttribute) ofObject:self withUserInfo:nil];
    [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSActionValidationStatusAttribute) ofObject:self withUserInfo:nil];
}

- (id)textToMatchObjectUID
{
    return _textToMatchObjectUID;
}

- (void)setResponseObjectUID:(id)aUID
{
    if ([aUID isEqual:_responseObjectUID])
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Set Answer Text Object" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setResponseObjectUID:[self responseObjectUID]];
    [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSActionValidationStatusAttribute) ofObject:self withUserInfo:nil];
    [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSCompareTextActionResponseObjectAttribute) ofObject:self withUserInfo:nil];
    [_responseObjectUID release];
    _responseObjectUID = [aUID retain];
    [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSCompareTextActionResponseObjectAttribute) ofObject:self withUserInfo:nil];
    [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSActionValidationStatusAttribute) ofObject:self withUserInfo:nil];
}

- (id)responseObjectUID
{
    return _responseObjectUID;
}

// No copy when the response field, the text to match and both answer objects
// are all among the replaced objects.
- (id)copyReplacingObjectUIDs:(id)aDs sortedByPriority:(id)aPriority withImageObjectUID:(id)aUID
{
    id match = [self comparisonMatchObjectUID];
    BOOL matchReplaced = match == nil || [aDs containsObject:match];
    id mismatch = [self comparisonMismatchObjectUID];
    BOOL mismatchReplaced = mismatch == nil || [aDs containsObject:mismatch];
    id textToMatch = [self textToMatchObjectUID];
    BOOL textReplaced = !(([aDs containsObject:textToMatch] == NO && textToMatch != nil) || [self definedString] != nil);
    if (matchReplaced && mismatchReplaced && [aDs containsObject:[self responseObjectUID]] && textReplaced)
        return nil;
    return [super copyReplacingObjectUIDs:aDs sortedByPriority:aPriority withImageObjectUID:aUID];
}

// Documents with the match/mismatch keys ignore the legacy right/wrong ones.
// Without a stored selector the comparison is "is equal to".
- (void)loadExtraDictionaryRepresentation:(id)aRepresentation withCodingContext:(id)aContext
{
    NSMutableDictionary *copy = nil;
    if ([aRepresentation objectForKey:@"comparisonMatchObjectUIDString"] != nil || [aRepresentation objectForKey:@"comparisonMismatchObjectUIDString"] != nil) {
        copy = [aRepresentation mutableCopy];
        [copy removeObjectForKey:@"rightAnswerObjectUID"];
        [copy removeObjectForKey:@"wrongAnswerObjectUID"];
        aRepresentation = copy;
    }
    if ([aRepresentation objectForKey:@"comparisonSelectorName"] == nil)
        _comparisonSelector = @selector(HSCompareTextAction_isEqualTo:options:);
    [super loadExtraDictionaryRepresentation:aRepresentation withCodingContext:aContext];
    [copy release];
}

// Storing keeps the text to match only for the equality comparisons, so
// loading adds those keys for the others.
- (id)keysForExtraLoadingWithCodingContext:(id)aContext
{
    NSArray *keys = [super keysForExtraLoadingWithCodingContext:aContext];
    if (_comparisonSelector != @selector(HSCompareTextAction_isEqualTo:options:) && _comparisonSelector != @selector(HSCompareTextAction_isNotEqualTo:options:))
        keys = [keys arrayByAddingObjectsFromArray:[NSArray arrayWithObjects:@"textToMatchObjectUID", @"definedString", nil]];
    return keys;
}

- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    NSMutableArray *keys = [NSMutableArray arrayWithObjects:@"responseObjectUID", @"comparisonSelectorName", @"comparisonObjectUID", @"comparisonString", @"rightAnswerObjectUID", @"wrongAnswerObjectUID", @"comparisonMatchObjectUIDString", @"comparisonMismatchObjectUIDString", @"caseSensitiveComparison", nil];
    if (_comparisonSelector == @selector(HSCompareTextAction_isEqualTo:options:) || _comparisonSelector == @selector(HSCompareTextAction_isNotEqualTo:options:)) {
        [keys addObject:@"textToMatchObjectUID"];
        [keys addObject:@"definedString"];
    }
    return [[super keysForExtraStoringWithCodingContext:aContext] arrayByAddingObjectsFromArray:keys];
}

- (void)dealloc
{
    [_responseObjectUID release];
    [_textToMatchObjectUID release];
    [_definedString release];
    [_comparisonMatchObjectUID release];
    [_comparisonMismatchObjectUID release];
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self != nil)
        _comparisonSelector = @selector(HSCompareTextAction_contains:options:);
    return self;
}

- (id)XMLElementName
{
    return @"actCompareText";
}

- (BOOL)canBeStoredAsXMLElement
{
    return YES;
}

- (BOOL)supportedInIPad
{
    return YES;
}

- (id)XMLElementRepresentationInContext:(id)aContext
{
    NSXMLElement *element = [super XMLElementRepresentationInContext:aContext];
    [element addAttribute:[NSXMLNode attributeWithName:@"responseObjectUID" stringValue:[_responseObjectUID stringValue]]];
    [element addAttribute:[NSXMLNode attributeWithName:@"textToMatchObjectUID" stringValue:[_textToMatchObjectUID stringValue]]];
    [element addAttribute:[NSXMLNode attributeWithName:@"definedString" stringValue:_definedString]];
    [element addAttribute:[NSXMLNode attributeWithName:@"rightAnswerObjectUID" stringValue:[_comparisonMatchObjectUID stringValue]]];
    [element addAttribute:[NSXMLNode attributeWithName:@"wrongAnswerObjectUID" stringValue:[_comparisonMismatchObjectUID stringValue]]];
    [element addAttribute:[NSXMLNode attributeWithName:@"compareSelector" stringValue:NSStringFromSelector(_comparisonSelector)]];
    [element addAttribute:[NSXMLNode attributeWithName:@"isCaseSensitiveComparison" stringValue:_isCaseSensitiveComparison ? @"1" : @"0"]];
    return element;
}

@end

@implementation NSString (HSCompareTextAction)

- (BOOL)HSCompareTextAction_isLessThanOrEqualTo:(id)aTo options:(NSUInteger)aOptions
{
    return ![self HSCompareTextAction_isGreaterThan:aTo options:aOptions];
}

- (BOOL)HSCompareTextAction_isGreaterThanOrEqualTo:(id)aTo options:(NSUInteger)aOptions
{
    return ![self HSCompareTextAction_isLessThan:aTo options:aOptions];
}

- (BOOL)HSCompareTextAction_isLessThan:(id)aThan options:(NSUInteger)aOptions
{
    return [self compare:aThan options:aOptions] == NSOrderedAscending;
}

- (BOOL)HSCompareTextAction_isGreaterThan:(id)aThan options:(NSUInteger)aOptions
{
    return [self compare:aThan options:aOptions] == NSOrderedDescending;
}

- (BOOL)HSCompareTextAction_contains:(id)aContains options:(NSUInteger)aOptions
{
    return [self rangeOfString:aContains options:aOptions].length != 0;
}

- (BOOL)HSCompareTextAction_isNotEqualTo:(id)aTo options:(NSUInteger)aOptions
{
    return [self compare:aTo options:aOptions] != NSOrderedSame;
}

- (BOOL)HSCompareTextAction_isEqualTo:(id)aTo options:(NSUInteger)aOptions
{
    return [self compare:aTo options:aOptions] == NSOrderedSame;
}

@end
