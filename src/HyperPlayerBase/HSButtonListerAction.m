#import "HSButtonListerAction.h"
#import "HSActionExecutionContext.h"

@implementation HSButtonListerAction

- (BOOL)canBeExportedToHTML5DocumentType:(id)aType
{
    return ![aType isEqualToString:@"HSiBooksAuthorDocumentType"];
}

- (id)HTML5DictionaryRepresentationInContext:(id)aContext
{
    id dictionary = [super HTML5DictionaryRepresentationInContext:aContext];
    NSMutableArray *objects = [NSMutableArray new];
    for (id uid in [self buttonUIDs]) {
        NSDictionary *object = [[NSDictionary alloc] initWithObjectsAndKeys:[uid stringValue], @"id", nil];
        [objects addObject:object];
        [object release];
    }
    [dictionary setObject:objects forKey:@"objects"];
    [objects release];
    [dictionary setObject:[NSString stringWithFormat:@"%.1f", (double)[self performDelay]] forKey:@"timer"];
    [dictionary setObject:[self shouldRepeat] ? @"1" : @"0" forKey:@"isLooped"];
    return dictionary;
}

- (id)XMLElementRepresentationInContext:(id)aContext
{
    id element = [super XMLElementRepresentationInContext:aContext];
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    [element addAttribute:[NSXMLNode attributeWithName:@"performDelay" stringValue:[NSString stringWithFormat:@"%.2f", (double)_performDelay]]];
    [element addAttribute:[NSXMLNode attributeWithName:@"shouldRepeat" stringValue:_shouldRepeat ? HSXMLStoring1String : HSXMLStoring0String]];
    for (id uid in [self buttonUIDs])
        [element addChild:[NSXMLElement elementWithName:@"buttonUID" stringValue:[uid stringValue]]];
    [pool release];
    return element;
}

- (id)XMLElementName
{
    return @"actButtonLister";
}

- (BOOL)supportedInIPad
{
    return NO;
}

- (BOOL)canBeStoredAsXMLElement
{
    return YES;
}

- (BOOL)handleMouseDownEvent:(id)aEvent
{
    [self setCurentButtonIndex:[self currentButtonIndex] + 1];
    return YES;
}

- (BOOL)handleKeyUpEvent:(id)aEvent
{
    return NO;
}

- (BOOL)handleKeyDownEvent:(id)aEvent
{
    if ([aEvent isARepeat])
        return YES;
    if ([(NSEvent *)aEvent keyCode] == 0x35) {     // Escape
        [self stop:self];
        return NO;
    }
    if ([self isMoveBackwardEvent:aEvent])
        [self setCurentButtonIndex:[self currentButtonIndex] - 1];
    else if ([self isMoveForwardEvent:aEvent])
        [self setCurentButtonIndex:[self currentButtonIndex] + 1];
    return YES;
}

- (BOOL)isMoveBackwardEvent:(id)aEvent
{
    static NSCharacterSet *sBackwardCharacters = nil;
    if (sBackwardCharacters == nil)
        sBackwardCharacters = [[NSCharacterSet characterSetWithCharactersInString:@"2"] retain];
    NSString *characters = [aEvent charactersIgnoringModifiers];
    if (characters != nil && [characters length])
        return [characters rangeOfCharacterFromSet:sBackwardCharacters].location != NSNotFound;
    return NO;
}

- (BOOL)isMoveForwardEvent:(id)aEvent
{
    static NSCharacterSet *sForwardCharacters = nil;
    if (sForwardCharacters == nil)
        sForwardCharacters = [[NSCharacterSet characterSetWithCharactersInString:@"1 "] retain];
    NSString *characters = [aEvent charactersIgnoringModifiers];
    if (characters != nil && [characters length])
        return [characters rangeOfCharacterFromSet:sForwardCharacters].location != NSNotFound;
    return NO;
}

- (void)stop:(id)aStop
{
    [_context unregisterEventResponderAction:self];
    [_context stopAllActionsForRequestor:self];
    [_context showCursor];
    [self setCurentButtonIndex:NSNotFound];
    [_context setButtonListerAction:nil];
    [_context release];
    _context = nil;
    [super stop:aStop];
}

- (BOOL)canBeStopped
{
    return YES;
}

- (void)startInContext:(id)aContext
{
    _context = [aContext retain];
    [self setCurentButtonIndex:0];
    [_context hideCursor];
    [_context setButtonListerAction:self];
    [_context registerEventResponderAction:self];
}

- (id)activeObject
{
    if ([self currentButtonIndex] == NSNotFound)
        return nil;
    return [[self availableButtons] extraObjectAtIndex:[self currentButtonIndex]];
}

// Highlights the new button and runs its actions after the delay.
- (void)setCurentButtonIndex:(NSInteger)aIndex
{
    if ([[self availableButtons] count] == 0)
        return;
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    if (aIndex == NSNotFound) {
        _curentButtonIndex = 0x7fffffff;
    } else {
        NSInteger count = [[self availableButtons] count];
        // Wraps around at both ends.
        if (aIndex < 0)
            _curentButtonIndex = (int)count - 1;
        else if (aIndex >= count)
            _curentButtonIndex = 0;
        else
            _curentButtonIndex = (int)aIndex;
    }
    [self highlightObject:[self activeObject]];
    if ([self activeObject] != nil)
        [self performSelector:@selector(runActionsForActiveObject) withObject:nil afterDelay:[self performDelay]];
}

- (NSInteger)currentButtonIndex
{
    // The i386 ivar is an int, so NSNotFound was 0x7fffffff there.
    return _curentButtonIndex == 0x7fffffff ? NSNotFound : _curentButtonIndex;
}

- (void)runActionsForActiveObject
{
    [_context stopAllActionsForRequestor:self];
    [_context runActionsForObject:[self activeObject] forRequestor:self];
    if ([self shouldRepeat])
        [self performSelector:@selector(runActionsForActiveObject) withObject:nil afterDelay:[self performDelay]];
}

- (id)availableButtons
{
    if (_availableObjects == nil && [_buttonUIDs count]) {
        NSMutableArray *objects = [NSMutableArray new];
        id access = [[self card] queryHyperInterface:@protocol(HSUserObjectUIDBasedAccess)];
        NSEnumerator *enumerator = [_buttonUIDs objectEnumerator];
        id uid;
        while ((uid = [enumerator nextObject]) != nil) {
            id object = [access childInTreeWithUID:uid];
            if (object != nil)
                [objects addObject:object];
        }
        _availableObjects = [[NSArray alloc] initWithArray:objects];
        [objects release];
    }
    return _availableObjects;
}

- (BOOL)canUseObject:(id)aObject
{
    if (![aObject implementsHyperInterface:@protocol(HSSystemButtonInteractiveModeAttributes)])
        return NO;
    return ![[aObject queryHyperInterface:@protocol(HSCardObjectAttributes)] isLocked];
}

- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    return [[super keysForExtraStoringWithCodingContext:aContext] arrayByAddingObjectsFromArray:
                [NSArray arrayWithObjects:@"performDelay", @"shouldRepeat", [@"buttonUIDs" extraKeyForCollection], nil]];
}

- (void)setShouldRepeat:(BOOL)aRepeat
{
    if ((BOOL)_shouldRepeat == (aRepeat != NO))
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"HSButtonListerSetRepeat" value:@"" table:@"UndoManager"]];
    [(HSButtonListerAction *)[[self undoManager] prepareWithInvocationTarget:self] setShouldRepeat:[self shouldRepeat]];
    [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSButtonListerRepeatAttribute) ofObject:self withUserInfo:nil];
    _shouldRepeat = aRepeat != NO;
    [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSButtonListerRepeatAttribute) ofObject:self withUserInfo:nil];
}

- (void)setPerformDelay:(CGFloat)aDelay
{
    if (_performDelay == (float)aDelay)
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"HSButtonListerSetDelay" value:@"" table:@"UndoManager"]];
    [(HSButtonListerAction *)[[self undoManager] prepareWithInvocationTarget:self] setPerformDelay:[self performDelay]];
    [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSButtonListerDelayAttribute) ofObject:self withUserInfo:nil];
    _performDelay = (float)aDelay;
    [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSButtonListerDelayAttribute) ofObject:self withUserInfo:nil];
}

- (BOOL)shouldRepeat
{
    return _shouldRepeat;
}

- (CGFloat)performDelay
{
    return _performDelay;
}

- (void)setButtonUIDs:(id)aDs
{
    if ([_buttonUIDs isEqualTo:aDs])
        return;
    [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSButtonListerButtonsAttribute) ofObject:self withUserInfo:nil];
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"HSButtonListerSetTargetButtons" value:@"" table:@"UndoManager"]];
    [(HSButtonListerAction *)[[self undoManager] prepareWithInvocationTarget:self] setButtonUIDs:[self buttonUIDs]];
    [_buttonUIDs release];
    _buttonUIDs = [aDs retain];
    [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSButtonListerButtonsAttribute) ofObject:self withUserInfo:nil];
}

- (id)buttonUIDs
{
    return _buttonUIDs;
}

- (void)mergeInButtonListerAction:(id)aAction replacingObjectUIDs:(id)aDs sortedByPriority:(id)aPriority withImageObjectUID:(id)aUID
{
    NSMutableArray *uids = nil;
    for (id uid in [aAction buttonUIDs]) {
        if (![aDs containsObject:uid]) {
            if (uids == nil)
                uids = [[self buttonUIDs] mutableCopy];
            [uids addObject:uid];
        }
    }
    if (uids != nil) {
        [self setButtonUIDs:uids];
        [uids release];
    }
}

- (id)copyReplacingObjectUIDs:(id)aDs sortedByPriority:(id)aPriority withImageObjectUID:(id)aUID
{
    NSArray *buttonUIDs = [self buttonUIDs];
    NSUInteger count = [buttonUIDs count];
    NSMutableArray *keptUIDs = nil;
    for (NSUInteger i = 0; i < count; i++) {
        id uid = [buttonUIDs objectAtIndex:i];
        if (![aDs containsObject:uid]) {
            if (keptUIDs == nil)
                keptUIDs = [NSMutableArray new];
            [keptUIDs addObject:uid];
        }
    }
    // No copy at all when every target button is being replaced.
    if (keptUIDs == nil)
        return nil;
    id copy = [super copyReplacingObjectUIDs:aDs sortedByPriority:aPriority withImageObjectUID:aUID];
    [copy setButtonUIDs:keptUIDs];
    [keptUIDs release];
    return copy;
}

- (void)dealloc
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [_buttonUIDs release];
    [_availableObjects release];
    [_context release];
    [super dealloc];
}

@end
