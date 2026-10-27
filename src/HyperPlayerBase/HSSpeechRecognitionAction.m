#import "HSSpeechRecognitionAction.h"
// Listens for the names of the chosen objects as spoken commands (none:
// stops listening).
@implementation HSSpeechRecognitionAction
// Actors only.
- (id)objectWithUID:(id)aUID
{
    id object = [[[self stack] queryHyperInterface:@protocol(HSUserObjectUIDBasedAccess)] childInTreeWithUID:aUID];
    if (![object implementsHyperInterface:@protocol(HSActor)])
        return nil;
    return [object queryHyperInterface:@protocol(HSObjectAttributes)];
}
- (void)setObjectUIDs:(id)aDs
{
    if ([[self objectUIDs] isEqualToArray:aDs])
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Set Objects" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setObjectUIDs:[self objectUIDs]];
    [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSActionValidationStatusAttribute) ofObject:self withUserInfo:nil];
    [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSObjectUIDsAttribute) ofObject:self withUserInfo:nil];
    [_objectUIDs release];
    _objectUIDs = [aDs retain];
    [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSObjectUIDsAttribute) ofObject:self withUserInfo:nil];
    [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSActionValidationStatusAttribute) ofObject:self withUserInfo:nil];
}
- (id)objectUIDs
{
    return _objectUIDs;
}
// During a card change only actions run on arrival take effect.
- (void)startInContext:(id)aContext
{
    if (![[[aContext navigationController] presentationSync] isPerformingNavigationOperation]
        || [[self events] containsObject:[HSActionEvent actionEventOfType:kHSArriveActionEventType]]) {
        NSMutableArray *names = [NSMutableArray array];
        for (id uid in [self objectUIDs]) {
            NSString *name = [[self objectWithUID:uid] hyperName];
            if ([name length] != 0)
                [names addObject:name];
        }
        if ([names count] != 0)
            [aContext addSpeechCommands:names];
        else
            [aContext shutDownSpeechRecognition];
    }
    [self notifyDidFinish];
}
- (BOOL)canChangeSynchronousFlag
{
    return NO;
}
- (BOOL)isSynchronous
{
    return YES;
}
// Objects of the merged action are added; the first of those being replaced
// brings in the image object instead (once).
- (void)mergeInSpeechRecognitionAction:(id)aAction replacingObjectUIDs:(id)aDs sortedByPriority:(id)aPriority withImageObjectUID:(id)aUID
{
    BOOL hasImageObject = [[self objectUIDs] containsObject:aUID];
    NSMutableArray *merged = nil;
    for (id uid in [aAction objectUIDs]) {
        if (![aDs containsObject:uid]) {
            if (merged == nil)
                merged = [[self objectUIDs] mutableCopy];
            [merged addObject:uid];
        } else if (!hasImageObject) {
            if (merged == nil)
                merged = [[self objectUIDs] mutableCopy];
            [merged addObject:aUID];
            hasImageObject = YES;
        }
    }
    if (merged != nil) {
        [self setObjectUIDs:merged];
        [merged release];
    }
}
- (id)copyReplacingObjectUIDs:(id)aDs sortedByPriority:(id)aPriority withImageObjectUID:(id)aUID
{
    id copy = [super copyReplacingObjectUIDs:aDs sortedByPriority:aPriority withImageObjectUID:aUID];
    NSArray *uids = [copy objectUIDs];
    NSUInteger count = [uids count];
    NSMutableArray *replaced = nil;
    NSUInteger removed = 0;
    for (NSUInteger i = 0; i < count; i++) {
        if ([aDs containsObject:[uids objectAtIndex:i]]) {
            if (replaced == nil)
                replaced = [uids mutableCopy];
            [replaced removeObjectAtIndex:i - removed];
            removed++;
        }
    }
    if (replaced != nil) {
        [replaced addObject:aUID];
        [copy setObjectUIDs:replaced];
        [replaced release];
    }
    return copy;
}
- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    NSArray *keys = [NSArray arrayWithObjects:[@"objectUIDs" extraKeyForCollection], nil];
    return [[super keysForExtraStoringWithCodingContext:aContext] arrayByAddingObjectsFromArray:keys];
}
- (void)dealloc
{
    [_objectUIDs release];
    [super dealloc];
}
@end
