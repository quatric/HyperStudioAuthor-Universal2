#import "HSGhostWriterAction.h"
#import "HSAutoTypeAction.h"
#import "HSAutoTypeCommand.h"
#import "HSGhostWriterActionPerformer.h"
#import "HSGhostWriterSpeedCommand.h"
#import "HSGhostWriterStuffCommand.h"
#import "HSGhostWriterTargetCommand.h"
#import "HSGhostWriterTypeTextCommand.h"
#import "HSTextViewProcessingAction.h"

// Types text into system text views through HSGhostWriterActionPerformer; _notificationObservers holds the
// text objects whose editability is observed for validation.
@implementation HSGhostWriterAction
// Converts the old "Auto Type" action: its bracketed commands become speed, target, erase and typing commands.
+ (id)ghostWriterActionFromAutoTypeAction:(id)aAction
{
    HSGhostWriterAction *action = [HSGhostWriterAction new];
    [action setSynchronous:[aAction isSynchronous]];
    [action setEvents:[aAction events]];
    NSMutableArray *commands = [NSMutableArray array];
    if ([aAction textViewUIDs] != nil) {
        id command = [[[HSGhostWriterTargetCommand alloc] initWithTargetObjectUID:[[aAction textViewUIDs] lastObject]] autorelease];
        [commands addObject:command];
    }
    NSEnumerator *autoTypeCommands = [[HSAutoTypeAction parseStringToCommands:[[aAction textToType] string]] objectEnumerator];
    HSAutoTypeCommand *autoTypeCommand;
    while ((autoTypeCommand = [autoTypeCommands nextObject]) != nil) {
        id command;
        NSInteger type = [autoTypeCommand commandType];
        switch (type) {
        case 0: case 1: case 2: case 3: case 4: case 5: case 6:
            // Fastest (0) to slowest (6) become speeds 1 to 7.
            command = [[HSGhostWriterSpeedCommand alloc] initWithSpeed:type + 1];
            break;
        case 7: {
            id textView = [[aAction textViewWithTitle:[autoTypeCommand command]] queryHyperInterface:@protocol(HSObjectAttributes)];
            command = [[HSGhostWriterTargetCommand alloc] initWithTargetObjectUID:[textView hyperUID]];
            break;
        }
        case 8:
            command = [[HSGhostWriterStuffCommand alloc] initWithStuffType:HSGhostWriterErase];
            break;
        case 9:
            command = [[HSGhostWriterTypeTextCommand alloc] initWithStringToType:[autoTypeCommand command]];
            break;
        default:
            continue;
        }
        [commands addObject:command];
        [command release];
    }
    [action setCommands:[NSArray arrayWithArray:commands]];
    return [action autorelease];
}
+ (BOOL)canUseObject:(id)aObject
{
    if ([aObject queryHyperInterface:@protocol(HSSystemTextViewAttributes)] == nil)
        return NO;
    return [[aObject queryHyperInterface:@protocol(HSSystemTextViewAttributes)] isEditable];
}
// HTML5 export: "object" is the target UID, "data" the commands as "|cmd1|cmd2|...".
- (id)HTML5DictionaryRepresentationInContext:(id)aContext
{
    NSString *uid = [[[self hyperObject] hyperUID] stringValue];
    if (![self isValid] || uid == nil)
        return nil;
    NSMutableDictionary *dictionary = [super HTML5DictionaryRepresentationInContext:aContext];
    [dictionary setObject:uid forKey:@"object"];
    NSMutableString *data = [[NSMutableString alloc] initWithString:@"|"];
    for (id command in [self commands])
        [data appendFormat:@"%@|", [command stringRepresentation]];
    [dictionary setObject:data forKey:@"data"];
    [data release];
    return dictionary;
}
- (BOOL)canBeExportedToHTML5DocumentType:(id)aType
{
    return YES;
}
- (void)validateActionWithNotification:(id)aNotification
{
    [self updateActionValidationStatus];
}
- (void)unsubscribeFromNotificationsForObject:(id)aObject
{
    [[[aObject queryHyperInterface:@protocol(HSAttributes)] attributeObservingController] removeObserver:self
                                                                                               selector:@selector(validateActionWithNotification:)
                                                                                              ofChanges:2
                                                                                            ofAttribute:@protocol(HSSystemEditableAttribute)];
}
- (void)unsubscribeFromNotifications
{
    NSEnumerator *objects = [[self notificationObservers] objectEnumerator];
    id object;
    while ((object = [objects nextObject]) != nil)
        [self unsubscribeFromNotificationsForObject:object];
    [[self notificationObservers] removeAllObjects];
}
- (void)subscribeToNotificationsForObject:(id)aObject
{
    if ([[self notificationObservers] containsObject:aObject])
        return;
    [[[aObject queryHyperInterface:@protocol(HSAttributes)] attributeObservingController] addObserver:self
                                                                                            selector:@selector(validateActionWithNotification:)
                                                                                           ofChanges:2
                                                                                         ofAttribute:@protocol(HSSystemEditableAttribute)
                                                                                        withPriority:-0.25];
    [[self notificationObservers] addObject:aObject];
}
// As in the original, every listed object is already subscribed, so this only empties the list
// (the observations themselves stay registered). The original enumerates the live array.
- (void)subscribeToNotifications
{
    NSEnumerator *objects = [[[[self notificationObservers] copy] autorelease] objectEnumerator];
    id object;
    while ((object = [objects nextObject]) != nil) {
        [self subscribeToNotificationsForObject:object];
        [[self notificationObservers] removeObject:object];
    }
}
- (id)notificationObservers
{
    if (_notificationObservers == nil)
        _notificationObservers = [[NSMutableArray alloc] init];
    return _notificationObservers;
}
- (void)insertText:(id)aText toNode:(id)aNode
{
    [_context insertText:aText toNode:aNode];
}
- (void)doCommandBySelector:(SEL)aSelector forNode:(id)aNode
{
    [_context doCommandBySelector:aSelector forNode:aNode];
}
- (void)setCommands:(id)aCommands
{
    if ([_commands isEqualToArray:aCommands])
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Set Text To Type" value:@"" table:@"UndoManager"]];
    [(HSGhostWriterAction *)[[self undoManager] prepareWithInvocationTarget:self] setCommands:_commands];
    [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSActionValidationStatusAttribute) ofObject:self withUserInfo:nil];
    [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSGhostWriterCommandsAttribute) ofObject:self withUserInfo:nil];
    [self unsubscribeFromNotifications];
    [_commands release];
    _commands = [aCommands retain];
    [self subscribeToNotifications];
    [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSGhostWriterCommandsAttribute) ofObject:self withUserInfo:nil];
    [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSActionValidationStatusAttribute) ofObject:self withUserInfo:nil];
}
- (id)commands
{
    return _commands;
}
- (void)mergeInGhostWriterAction:(id)aAction replacingObjectUIDs:(id)aDs sortedByPriority:(id)aPriority withImageObjectUID:(id)aUID
{
    NSMutableArray *commands = [[self commands] mutableCopy];
    [commands addObjectsFromArray:[aAction commands]];
    if (commands != nil) {
        [self setCommands:commands];
        [commands release];
    }
}
- (BOOL)isEqual:(id)aEqual
{
    if (aEqual == self)
        return YES;
    if (![aEqual isKindOfClass:[self class]])
        return NO;
    if (_commands == [aEqual commands])
        return YES;
    return [_commands isEqualToArray:[aEqual commands]];
}
// Valid when every targeted text object exists and is editable (always in player mode).
- (BOOL)isValid
{
    if ([[self document] isInPlayerMode])
        return YES;
    NSArray *commands = [self commands];
    if ([commands count] == 0)
        return NO;
    NSEnumerator *enumerator = [commands objectEnumerator];
    id command;
    while ((command = [enumerator nextObject]) != nil) {
        id target = [command queryHyperInterface:@protocol(HSGhostWriterTargetCommandInterface)];
        id textObject = [self textObjectWithUID:[target targetObjectUID]];
        if (textObject != nil)
            [self subscribeToNotificationsForObject:textObject];
        if (target == nil)
            continue;
        if (textObject == nil)
            return NO;
        if (![[textObject queryHyperInterface:@protocol(HSSystemEditableAttribute)] isEditable])
            return NO;
    }
    return YES;
}
- (id)textObjectWithUID:(id)aUID
{
    return [[[self stack] queryHyperInterface:@protocol(HSUserObjectUIDBasedAccess)] childInTreeWithUID:aUID];
}
- (void)stop:(id)aStop
{
    [super stop:aStop];
    [[HSGhostWriterActionPerformer sharedGhostWriterActionPerformer] actionDidStop:self];
    [self setContext:nil];
}
- (BOOL)canBeStopped
{
    if (![_context isSlideshow])
        return YES;
    return _finishedInActionPerfromer;
}
- (void)startInContext:(id)aContext
{
    _finishedInActionPerfromer = NO;
    [self setContext:aContext];
    if ([[self commands] count] == 0)
        [self stop:nil];
    else
        [(HSGhostWriterActionPerformer *)[HSGhostWriterActionPerformer sharedGhostWriterActionPerformer] performAction:self];
}
- (BOOL)canRunInContext:(id)aContext
{
    return [self stack] != nil;
}
- (void)didFinishInActionPerfromer
{
    _finishedInActionPerfromer = YES;
    [self stop:nil];
}
- (void)setContext:(id)aContext
{
    if (_context == aContext)
        return;
    [_context removeGhostWriterAction:self];
    [_context release];
    _context = [aContext retain];
    [_context addGhostWriterAction:self];
}
- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    return [[super keysForExtraStoringWithCodingContext:aContext] arrayByAddingObjectsFromArray:[NSArray arrayWithObject:[@"commands" extraKeyForCollection]]];
}
- (void)dealloc
{
    [self unsubscribeFromNotifications];
    [_notificationObservers release];
    [_commands release];
    [super dealloc];
}
@end
