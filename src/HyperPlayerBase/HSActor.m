#import "HSActor.h"
#import "EXCodingContext.h"
#import "HSActionEvent.h"
#import "HSActionQueue.h"
#import "HSAttributeNotificationCenter.h"
#import "HSAutomaticTimer.h"
#import "HSAvailableActionsProvider.h"
#import "HSPlaySoundAction.h"
#import "HSScriptAction.h"
#import "NSEMutableProtocolSet.h"

@interface NSObject (HSActorUndeclared)
- (BOOL)canBeExportedToHTML5DocumentType:(id)aType;
- (BOOL)stopsAllSounds;
- (BOOL)hideOnFirstFrame;
- (BOOL)showFirstFrame;
- (BOOL)isTemporary;
- (NSUInteger)hyperIdentifier;
- (BOOL)isValid;
- (BOOL)isHyperValid;
- (BOOL)hasHyperWarnings;
- (BOOL)runActionsAutomatically;
- (double)delayBetweenRepeatingActions;
- (double)delayBeforeRunActionsAutomatically;
- (BOOL)isEmpty;
- (BOOL)runsWithActionEvent:(id)aEvent;
- (BOOL)wantsSaveAfterRemove;
- (BOOL)implementsAnyHyperInterfaces:(id)aInterfaces;
- (id)queryAnyHyperInterfaces:(id)aInterfaces;
@end

// The HTML5 export context; its class lives outside this framework.
@protocol HSActorHTML5ExportContext
- (id)documentType;
@end

@implementation HSActor

+ (id)actionEventsForObject:(id)aObject
{
    if (![aObject implementsHyperInterface:@protocol(HSCardObjectAttributes)]
        && [aObject queryHyperInterface:@protocol(HSHypertextLink)] == nil
        && ![aObject implementsHyperInterface:@protocol(HSCardAttributes)]
        && ![aObject implementsHyperInterface:@protocol(HSStackAttributes)])
        return nil;
    return [NSArray arrayWithObject:[HSActionEvent actionEventOfType:kHSClickActionEventType]];
}

- (id)nonCardObjectRepsInContext:(id)aContext
{
    NSMutableArray *reps = [NSMutableArray arrayWithArray:[self nonCardMovieObjectRepsInContext:aContext]];
    [reps addObjectsFromArray:[self nonCardAnimatedObjectRepsInContext:aContext]];
    [reps addObjectsFromArray:[self nonCardSoundRepsInContext:aContext]];
    return reps;
}

- (id)nonCardSoundRepsInContext:(id)aContext
{
    NSMutableArray *reps = [NSMutableArray array];
    for (id action in [self hyperActionsOfType:[HSPlaySoundAction actionType]]) {
        if ([action stopsAllSounds])
            continue;
        for (id sound in [action sounds]) {
            if ([sound canBeExportedToHTML5DocumentType:[(id<HSActorHTML5ExportContext>)aContext documentType]]) {
                id rep = [sound HTML5DictionaryRepresentationInContext:aContext];
                if (rep != nil)
                    [reps addObject:rep];
            }
        }
    }
    return reps;
}

- (id)nonCardAnimatedObjectRepsInContext:(id)aContext
{
    NSMutableArray *reps = [NSMutableArray array];
    for (id action in [self hyperActions]) {
        id animation = [(id<HSPlayAnimationActionAttributes>)[action queryHyperInterface:@protocol(HSPlayAnimationActionAttributes)] animation];
        id animatedObject = [animation animatedObject];
        if ([animatedObject hyperParent] != nil)
            continue;
        if ([animatedObject canBeExportedToHTML5DocumentType:[(id<HSActorHTML5ExportContext>)aContext documentType]]) {
            id rep = [animatedObject HTML5DictionaryRepresentationInContext:aContext];
            [rep setObject:([animation hideOnFirstFrame] ? @"0" : @"1") forKey:@"isVisible"];
            // The original added a nil representation unchecked.
            if (rep != nil)
                [reps addObject:rep];
        }
    }
    return reps;
}

- (id)nonCardMovieObjectRepsInContext:(id)aContext
{
    NSMutableArray *reps = [NSMutableArray array];
    for (id action in [self hyperActions]) {
        id movies = [[action queryHyperInterface:@protocol(HSPlayMovieActionAttributes)] movies];
        for (id movie in movies) {
            id movieObject = [movie movieObjectForCard:nil];
            BOOL onActionCard = [[[movieObject hyperParent] hyperObject] hyperIdentifier] == [[[action card] hyperObject] hyperIdentifier];
            if (onActionCard && ![movieObject isTemporary])
                continue;
            if ([movieObject canBeExportedToHTML5DocumentType:[(id<HSActorHTML5ExportContext>)aContext documentType]]) {
                id rep = [movieObject HTML5DictionaryRepresentationInContext:aContext];
                [rep setObject:([movie showFirstFrame] ? @"1" : @"0") forKey:@"isShowFirstFrame"];
                // The original added a nil representation unchecked.
                if (rep != nil)
                    [reps addObject:rep];
            }
        }
    }
    return reps;
}

- (id)actionsHTML5RepresentationForEvent:(id)aEvent inContext:(id)aContext
{
    NSMutableArray *reps = [NSMutableArray new];
    for (id action in [self hyperActionsForEvent:aEvent]) {
        if ([action canBeExportedToHTML5DocumentType:[(id<HSActorHTML5ExportContext>)aContext documentType]]) {
            NSAutoreleasePool *pool = [NSAutoreleasePool new];
            id rep = [action HTML5DictionaryRepresentationInContext:aContext];
            if (rep != nil)
                [reps addObject:rep];
            [pool release];
        }
    }
    return [reps autorelease];
}

- (id)attributesChangedTemporary
{
    return [NSEProtocolSet protocolSet];
}

- (id)attributesBeingChangedContinuously
{
    return [NSEProtocolSet protocolSet];
}

- (void)removeObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributesFromSet:(id)aSet
{
    [[self attributeNotificationCenter] removeObserver:aObserver selector:aSelector ofChanges:aChanges ofAttributesFromSet:aSet ofObject:self];
}

- (void)addObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributesFromSet:(id)aSet withPriority:(CGFloat)aPriority
{
    [[self attributeNotificationCenter] addObserver:aObserver selector:aSelector ofChanges:aChanges ofAttributesFromSet:aSet ofObject:self withPriority:aPriority];
}

- (void)endContinuousChangeOfAttributeSet:(id)aSet
{
    [[self attributeNotificationCenter] notifyChange:0x80 ofAttributeSet:aSet ofObject:self withUserInfo:nil];
}

- (void)beginContinuousChangeOfAttributeSet:(id)aSet
{
    [[self attributeNotificationCenter] notifyChange:0x40 ofAttributeSet:aSet ofObject:self withUserInfo:nil];
}

- (void)endContinuousChangeOfAttribute:(id)aAttribute
{
    [[self attributeNotificationCenter] notifyChange:0x80 ofAttribute:aAttribute ofObject:self withUserInfo:nil];
}

- (void)beginContinuousChangeOfAttribute:(id)aAttribute
{
    [[self attributeNotificationCenter] notifyChange:0x40 ofAttribute:aAttribute ofObject:self withUserInfo:nil];
}

- (void)removeAttributeObserver:(id)aObserver
{
    [[self attributeNotificationCenter] removeObserver:aObserver selector:NULL ofChanges:HSAllAttributeChanges ofAttribute:nil ofObject:self];
}

- (void)removeAttributeObserver:(id)aObserver selector:(SEL)aSelector
{
    [[self attributeNotificationCenter] removeObserver:aObserver selector:aSelector ofChanges:HSAllAttributeChanges ofAttribute:nil ofObject:self];
}

- (void)removeObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributesOfHyperInterfaces:(id *)aInterfaces
{
    [[self attributeNotificationCenter] removeObserver:aObserver selector:aSelector ofChanges:aChanges ofAttributesOfHyperInterfaces:aInterfaces ofObject:self];
}

- (void)removeObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributesOfHyperInterface:(id)aInterface
{
    [[self attributeNotificationCenter] removeObserver:aObserver selector:aSelector ofChanges:aChanges ofAttributesOfHyperInterface:aInterface ofObject:self];
}

- (void)removeObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributes:(id *)aAttributes
{
    [[self attributeNotificationCenter] removeObserver:aObserver selector:aSelector ofChanges:aChanges ofAttributes:aAttributes ofObject:self];
}

- (void)removeObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttribute:(id)aAttribute
{
    [[self attributeNotificationCenter] removeObserver:aObserver selector:aSelector ofChanges:aChanges ofAttribute:aAttribute ofObject:self];
}

- (void)addObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributesOfHyperInterfaces:(id *)aInterfaces withPriority:(CGFloat)aPriority
{
    [[self attributeNotificationCenter] addObserver:aObserver selector:aSelector ofChanges:aChanges ofAttributesOfHyperInterfaces:aInterfaces ofObject:self withPriority:aPriority];
}

- (void)addObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributesOfHyperInterface:(id)aInterface withPriority:(CGFloat)aPriority
{
    [[self attributeNotificationCenter] addObserver:aObserver selector:aSelector ofChanges:aChanges ofAttributesOfHyperInterface:aInterface ofObject:self withPriority:aPriority];
}

- (void)addObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributes:(id *)aAttributes withPriority:(CGFloat)aPriority
{
    [[self attributeNotificationCenter] addObserver:aObserver selector:aSelector ofChanges:aChanges ofAttributes:aAttributes ofObject:self withPriority:aPriority];
}

- (void)addObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttribute:(id)aAttribute withPriority:(CGFloat)aPriority
{
    [[self attributeNotificationCenter] addObserver:aObserver selector:aSelector ofChanges:aChanges ofAttribute:aAttribute ofObject:self withPriority:aPriority];
}

- (id)attributeObservingController
{
    return self;
}

- (id)attributeNotificationCenter
{
    return [HSAttributeNotificationCenter defaultCenter];
}

- (void)notifyActionsDidChange
{
    if (_processingNotification)
        return;
    id otherActors = nil;
    if ([(id)[self owner] respondsToSelector:@selector(otherActorsFromGroup:)])
        otherActors = [(id)[self owner] otherActorsFromGroup:self];
    [otherActors makeObjectsPerformSelector:@selector(actionsChanged:) withObject:self];
}

- (void)actionsChanged:(id)aChanged
{
    _processingNotification = YES;
    if (aChanged != nil)
        [self setHyperActions:[[[aChanged hyperActions] copy] autorelease]];
    _processingNotification = NO;
}

- (void)updateActionValidationStatus
{
    [[self hyperActions] makeObjectsPerformSelector:@selector(updateActionValidationStatus)];
}

- (BOOL)isAbleToStartInInvalidState
{
    return NO;
}

- (BOOL)isValid
{
    for (id action in [self hyperActions]) {
        if ([action implementsHyperInterface:@protocol(HSActionValidation)]
            && ![[action queryHyperInterface:@protocol(HSActionValidation)] isValid])
            return NO;
    }
    return YES;
}

- (void)validateActorWithNotification:(id)aNotification
{
    [[self attributeNotificationCenter] notifyChange:[aNotification attributeChange] ofAttributeSet:[aNotification attributeProtocolSet] ofObject:self withUserInfo:[aNotification userInfo]];
    [self notifyUserObject];
}

- (id)unrefreshingUIDs
{
    NSMutableSet *uids = [NSMutableSet set];
    NSArray *actions = [self hyperActions];
    if ([actions implementsAnyHyperInterfaces:@protocol(HSActionCopySupport)]) {
        for (id action in [[self hyperActions] queryAnyHyperInterfaces:@protocol(HSActionCopySupport)]) {
            id actionUIDs = [[action queryHyperInterface:@protocol(HSActionCopySupport)] unrefreshingUIDs];
            if (actionUIDs != nil)
                [uids unionSet:actionUIDs];
        }
    }
    return [NSSet setWithSet:uids];
}

- (id)mediaUIDs
{
    return [NSSet setWithSet:[self ownedMediaUIDs]];
}

- (id)ownedMediaUIDs
{
    NSCountedSet *uids = [NSCountedSet set];
    NSArray *actions = [self hyperActions];
    if ([actions implementsAnyHyperInterfaces:@protocol(HSMediaCopySupport)]) {
        for (id action in [[self hyperActions] queryAnyHyperInterfaces:@protocol(HSMediaCopySupport)])
            [uids unionSet:[[action queryHyperInterface:@protocol(HSMediaCopySupport)] ownedMediaUIDs]];
    }
    return uids;
}

- (id)actionEqualTo:(id)aTo
{
    for (id action in [self hyperActions]) {
        if ([action isEqual:aTo])
            return action;
    }
    return nil;
}

- (void)willDisconnectFromDocument
{
    [[self hyperActions] makeObjectsPerformSelector:_cmd];
}

- (void)didConnectToDocument
{
    [[self hyperActions] makeObjectsPerformSelector:_cmd];
}

- (void)willRemoveFromDocument
{
    [[self hyperActions] makeObjectsPerformSelector:_cmd];
}

- (void)didAddToDocument
{
    [[self hyperActions] makeObjectsPerformSelector:_cmd];
}

- (BOOL)isRepeating
{
    return YES;
}

- (double)delayBetweenRepeatingActions
{
    return _automaticTimer == nil ? 0.0 : [_automaticTimer delayBetweenRepeatingActions];
}

- (double)delayBeforeRunActionsAutomatically
{
    return _automaticTimer == nil ? 0.0 : [_automaticTimer delayBeforeRunActionsAutomatically];
}

- (BOOL)runActionsAutomatically
{
    return [_automaticTimer runActionsAutomatically];
}

- (void)loadExtraDictionaryRepresentation:(id)aRepresentation withCodingContext:(id)aContext
{
    [super loadExtraDictionaryRepresentation:aRepresentation withCodingContext:aContext];
    [[self automaticTimerForActionEvent:[HSActionEvent actionEventOfType:kHSDefaultActionEventType]] loadExtraDictionaryRepresentation:aRepresentation withCodingContext:aContext];
}

- (id)keysForExtraLoadingWithCodingContext:(id)aContext
{
    return [NSArray arrayWithObjects:[@"hyperActions" extraKeyForCollection], @"arriveAutomaticTimer", @"delay", nil];
}

- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    NSMutableArray *keys = [NSMutableArray arrayWithObjects:[@"hyperActions" extraKeyForCollection], @"runActionsAutomatically", @"delayBeforeRunActionsAutomatically", @"delayBetweenRepeatingActions", @"arriveAutomaticTimer", nil];
    if (_automaticTimer != nil) {
        double between = [_automaticTimer delayBetweenRepeatingActions];
        if (between > 0.0 && between == [_automaticTimer delayBeforeRunActionsAutomatically])
            [keys addObject:@"repeating"];
    }
    return keys;
}

- (void)setActionsOwner:(id)aOwner
{
    [[self hyperActions] makeObjectsPerformSelector:@selector(setOwner:) withObject:aOwner];
}

- (BOOL)isInDocument
{
    return [[self hyperObject] document] != nil;
}

- (id)undoManager
{
    if ([[self hyperObject] respondsToSelector:@selector(undoManager)])
        return [[self hyperObject] undoManager];
    return nil;
}

- (void)notifyUserObject
{
    if ([[self hyperObject] respondsToSelector:@selector(actorDidChange:)])
        [[self hyperObject] actorDidChange:self];
    [self notifyActionsDidChange];
}

- (void)setDelay:(double)aDelay
{
    if (_delay != aDelay) {
        [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSActionsDelayAttribute) ofObject:self withUserInfo:nil];
        _delay = aDelay;
        [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSActionsDelayAttribute) ofObject:self withUserInfo:nil];
    }
}

- (double)delay
{
    return _delay;
}

- (id)automaticTimerForActionEvent:(id)aEvent
{
    if ([aEvent isEqual:[HSActionEvent actionEventOfType:kHSDefaultActionEventType]]) {
        if (_automaticTimer == nil) {
            _automaticTimer = [HSAutomaticTimer new];
            [_automaticTimer setActor:self];
        }
        return _automaticTimer;
    }
    if ([aEvent isEqual:[HSActionEvent actionEventOfType:kHSArriveActionEventType]]) {
        if (_arriveAutomaticTimer == nil) {
            _arriveAutomaticTimer = [[HSAutomaticTimer alloc] initActive:YES];
            [_arriveAutomaticTimer setActor:self];
        }
        return _arriveAutomaticTimer;
    }
    return nil;
}

- (BOOL)isHyperValid
{
    for (id action in [self hyperActions]) {
        id validation = [action queryHyperInterface:@protocol(HSRunScriptActionValidation)];
        if (validation != nil && ![validation isHyperValid])
            return NO;
    }
    return YES;
}

- (BOOL)hasHyperWarnings
{
    for (id action in [self hyperActions]) {
        id validation = [action queryHyperInterface:@protocol(HSRunScriptActionValidation)];
        if (validation != nil && [validation hasHyperWarnings])
            return YES;
    }
    return NO;
}

- (id)hyperOwner
{
    return [self hyperObject];
}

- (id)actionQueueForEvent:(id)aEvent callingObject:(id)aObject
{
    if ([[self hyperActionsForEvent:aEvent] count] == 0)
        return nil;
    HSActionQueue *queue = [[HSActionQueue alloc] initWithActionEvent:aEvent andActor:self callingObject:aObject];
    if ([queue isEmpty]) {
        [queue release];
        return nil;
    }
    return [queue autorelease];
}

- (BOOL)hasActionsMatchingProtocol:(id)aProtocol
{
    for (id action in [self hyperActions]) {
        if ([action implementsHyperInterface:aProtocol])
            return YES;
    }
    return NO;
}

- (void)removeHyperActionsOfType:(id)aType forEvent:(id)aEvent
{
    NSArray *actions = [self hyperActionsOfType:aType forEvent:aEvent];
    if ([actions count] != 0)
        [self removeActions:actions];
}

- (void)removeHyperActionsOfType:(id)aType
{
    [self removeActions:[self hyperActionsOfType:aType]];
}

- (void)removeActions:(id)aActions
{
    NSArray *actions = [NSArray arrayWithArray:aActions];
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Set None Action" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] addActions:actions];
    [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSActionsAttribute) ofObject:self withUserInfo:nil];
    for (id action in aActions)
        [self removeAction:action forEvents:[action events]];
    [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSActionsAttribute) ofObject:self withUserInfo:nil];
    [self notifyUserObject];
}

- (void)removeHyperActionOfType:(id)aType forEvent:(id)aEvent
{
    [self removeHyperAction:[self hyperActionOfType:aType] forEvent:aEvent];
}

- (void)addActions:(id)aActions
{
    NSArray *actions = [NSArray arrayWithArray:aActions];
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Set None Action" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] removeActions:actions];
    [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSActionsAttribute) ofObject:self withUserInfo:nil];
    for (id action in aActions)
        [self addAction:action];
    [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSActionsAttribute) ofObject:self withUserInfo:nil];
    [self notifyUserObject];
}

- (id)addHyperActionOfType:(id)aType forEvent:(id)aEvent
{
    id action = [[self createActionOfType:aType forEvent:aEvent] autorelease];
    return [self addHyperAction:action forEvent:aEvent];
}

- (id)addHyperAction:(id)aAction forEvent:(id)aEvent
{
    return [self insertHyperAction:aAction atIndex:[[self hyperActions] count] forEvent:aEvent];
}

- (id)hyperActionsOfType:(id)aType forEvent:(id)aEvent
{
    NSMutableArray *actions = [NSMutableArray new];
    for (id action in [self hyperActionsOfType:aType]) {
        if ([action runsWithActionEvent:aEvent])
            [actions addObject:action];
    }
    id result = [[actions copy] autorelease];
    [actions release];
    return result;
}

- (id)hyperActionsOfType:(id)aType
{
    NSMutableArray *actions = [NSMutableArray new];
    Class actionClass = NSClassFromString(aType);
    for (id action in [self hyperActions]) {
        if ([action isKindOfClass:actionClass])
            [actions addObject:action];
    }
    id result = [[actions copy] autorelease];
    [actions release];
    return result;
}

- (id)hyperActionOfType:(id)aType forEvent:(id)aEvent
{
    return [[self hyperActionsOfType:aType forEvent:aEvent] extraFirstObject];
}

- (id)hyperActionOfType:(id)aType
{
    return [[self hyperActionsOfType:aType] extraFirstObject];
}

- (id)hyperActionsForEvent:(id)aEvent
{
    NSMutableArray *actions = [NSMutableArray array];
    for (id action in [self hyperActions]) {
        if ([action runsWithActionEvent:aEvent])
            [actions addObject:action];
    }
    return actions;
}

- (id)hyperActions
{
    return [[[self mutableHyperActions] copy] autorelease];
}

- (id)replaceHyperActionsForEvent:(id)aEvent withAction:(id)aAction
{
    NSArray *actions = [self hyperActionsForEvent:aEvent];
    NSUInteger count = [actions count];
    if (count == 0)
        return [self insertHyperAction:aAction atIndex:0 forEvent:aEvent];
    if (count == 1)
        return [self replaceHyperAction:[actions lastObject] withAction:aAction forEvents:[NSArray arrayWithObject:aEvent]];
    [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSActionsAttribute) ofObject:self withUserInfo:nil];
    for (NSUInteger index = 0; index < count - 1; index++) {
        id action = [actions objectAtIndex:index];
        // Undo reinserts each action at the front, as the original did.
        [[[self undoManager] prepareWithInvocationTarget:self] insertHyperAction:action atIndex:0 forEvent:aEvent];
        [self removeAction:action forEvent:aEvent];
    }
    [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSActionsAttribute) ofObject:self withUserInfo:nil];
    id result = [self replaceHyperAction:[actions lastObject] withAction:aAction forEvents:[NSArray arrayWithObject:aEvent]];
    [self notifyUserObject];
    return result;
}

- (id)replaceHyperAction:(id)aAction withAction:(id)aAction2 forEvents:(id)aEvents
{
    if (aAction == aAction2)
        return aAction2;
    NSInteger index = [self indexOfAction:aAction];
    if (index == NSNotFound)
        return aAction2;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change Action" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] replaceHyperAction:aAction2 withAction:aAction forEvents:[NSArray arrayWithArray:aEvents]];
    [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSActionsAttribute) ofObject:self withUserInfo:nil];
    [self removeAction:[[aAction retain] autorelease] forEvents:aEvents];
    id result = [self insertAction:aAction2 atIndex:index forEvents:aEvents];
    [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSActionsAttribute) ofObject:self withUserInfo:nil];
    [self notifyUserObject];
    return result;
}

- (void)removeHyperAction:(id)aAction forEvent:(id)aEvent
{
    if (![[self hyperActions] containsObject:aAction])
        return;
    id action = [self actionEqualTo:aAction];
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Remove Action" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] insertHyperAction:action atIndex:[self indexOfAction:action] forEvent:aEvent];
    [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSActionsAttribute) ofObject:self withUserInfo:nil];
    [self removeAction:action forEvent:aEvent];
    [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSActionsAttribute) ofObject:self withUserInfo:nil];
    [self notifyUserObject];
}

- (id)insertHyperAction:(id)aAction atIndex:(NSInteger)aIndex forEvent:(id)aEvent
{
    // Only one go-to or navigation action may run per event; a new one
    // replaces the existing one.
    Class exclusiveClass = Nil;
    if ([aAction isKindOfClass:[HSToGoAction class]]
        && [[self hyperActionsOfType:[HSToGoAction actionType] forEvent:aEvent] count] != 0)
        exclusiveClass = [HSToGoAction class];
    else if ([aAction isKindOfClass:[HSNBAAction class]]
             && [[self hyperActionsOfType:[HSNBAAction actionType] forEvent:aEvent] count] != 0)
        exclusiveClass = [HSNBAAction class];
    if (exclusiveClass != Nil) {
        NSArray *events = [NSArray arrayWithObject:aEvent];
        id existing = [[self hyperActionsOfType:[exclusiveClass actionType]] extraFirstObject];
        return [self replaceHyperAction:existing withAction:aAction forEvents:events];
    }
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Add Action" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] removeHyperAction:aAction forEvent:aEvent];
    [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSActionsAttribute) ofObject:self withUserInfo:nil];
    id result = [self insertAction:aAction atIndex:aIndex forEvent:aEvent];
    [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSActionsAttribute) ofObject:self withUserInfo:nil];
    [self notifyUserObject];
    return result;
}

- (NSInteger)indexOfHyperAction:(id)aAction
{
    return [[self hyperActions] indexOfObject:aAction];
}

- (id)createActionOfType:(id)aType forEvent:(id)aEvent
{
    id action = [[self savedActions] objectForKey:[self keyForSavingForActionOfType:aType forEvent:aEvent]];
    if (action == nil)
        action = [[HSAvailableActionsProvider sharedAvailableActionsProvider] createDefaultActionOfType:aType];
    return [action retain];
}

- (void)removeAction:(id)aAction forEvents:(id)aEvents
{
    for (id event in aEvents)
        [self removeAction:aAction forEvent:event];
}

- (void)removeAction:(id)aAction forEvent:(id)aEvent
{
    [aEvent retain];
    [aAction removeActionEvent:aEvent];
    if ([[aAction events] count] == 0) {
        [self removeAction:aAction];
        if ([aAction wantsSaveAfterRemove])
            [self saveAction:aAction forEvent:aEvent];
    }
    [aEvent release];
}

- (void)removeAction:(id)aAction
{
    if ([self isInDocument]) {
        [aAction willRemoveFromDocument];
        [aAction willDisconnectFromDocument];
    }
    [aAction setOwner:nil];
    [[self mutableHyperActions] removeObject:aAction];
    if ([aAction implementsHyperInterface:@protocol(HSActionValidation)])
        [[aAction attributeObservingController] removeObserver:self selector:@selector(validateActorWithNotification:) ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSActionValidationStatusAttribute)];
    if ([aAction wantsSaveAfterRemove]) {
        id events = [[aAction events] retain];
        [aAction setEvents:[NSArray array]];
        [self saveAction:aAction forEvents:events];
        [events release];
    }
}

- (void)addAction:(id)aAction forEvent:(id)aEvent
{
    [self insertAction:aAction atIndex:[[self hyperActions] count] forEvent:aEvent];
}

- (void)addAction:(id)aAction
{
    [self insertAction:aAction atIndex:[[self hyperActions] count]];
}

- (id)insertAction:(id)aAction atIndex:(NSInteger)aIndex forEvents:(id)aEvents
{
    id result = nil;
    for (id event in aEvents)
        result = [self insertAction:aAction atIndex:aIndex forEvent:event];
    return result;
}

- (id)insertAction:(id)aAction atIndex:(NSInteger)aIndex forEvent:(id)aEvent
{
    [aAction addActionEvent:aEvent];
    return [self insertAction:aAction atIndex:aIndex];
}

- (id)insertAction:(id)aAction atIndex:(NSInteger)aIndex
{
    if ([aAction implementsHyperInterface:@protocol(HSActionValidation)]
        && ![[self mutableHyperActions] containsObject:aAction])
        [[aAction attributeObservingController] addObserver:self selector:@selector(validateActorWithNotification:) ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSActionValidationStatusAttribute) withPriority:0.0];
    [[self mutableHyperActions] insertObject:aAction atIndex:aIndex];
    [[aAction queryHyperInterface:@protocol(HSActionAttributes)] setOwner:self];
    if ([self isInDocument]) {
        [aAction didConnectToDocument];
        [aAction didAddToDocument];
    }
    return aAction;
}

- (NSInteger)indexOfAction:(id)aAction
{
    return [[self hyperActions] indexOfObject:aAction];
}

- (void)setHyperActions:(id)aActions
{
    if ([[self hyperActions] isEqualToArray:aActions])
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Set Actions" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setHyperActions:[self hyperActions]];
    [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSActionsAttribute) ofObject:self withUserInfo:nil];
    for (id action in _hyperActions) {
        if ([action implementsHyperInterface:@protocol(HSActionValidation)])
            [[action attributeObservingController] removeObserver:self selector:@selector(validateActorWithNotification:) ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSActionValidationStatusAttribute)];
    }
    [_hyperActions makeObjectsPerformSelector:@selector(setOwner:) withObject:nil];
    [_hyperActions release];
    _hyperActions = [[NSMutableArray alloc] initWithArray:aActions];
    [_hyperActions makeObjectsPerformSelector:@selector(setOwner:) withObject:self];
    for (id action in _hyperActions) {
        if ([action implementsHyperInterface:@protocol(HSActionValidation)])
            [[action attributeObservingController] addObserver:self selector:@selector(validateActorWithNotification:) ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSActionValidationStatusAttribute) withPriority:0.0];
    }
    [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSActionsAttribute) ofObject:self withUserInfo:nil];
    [self notifyUserObject];
}

- (id)mutableHyperActions
{
    if (_hyperActions == nil)
        _hyperActions = [NSMutableArray new];
    return _hyperActions;
}

- (void)setOwner:(id)aOwner
{
    _owner = aOwner;
    [self setActionsOwner:self];
}

- (id)owner
{
    return _owner;
}

- (void)saveAction:(id)aAction forEvents:(id)aEvents
{
    for (id event in aEvents)
        [self saveAction:aAction forEvent:event];
}

- (void)saveAction:(id)aAction forEvent:(id)aEvent
{
    [[self savedActions] setObject:aAction forKey:[self keyForSavingForActionOfType:NSStringFromClass([aAction class]) forEvent:aEvent]];
}

- (id)keyForSavingForActionOfType:(id)aType forEvent:(id)aEvent
{
    return [NSString stringWithFormat:@"%@_%@", aType, [aEvent eventTypeForSave]];
}

- (void)invalidateSavedActions
{
    [_savedActions release];
    _savedActions = nil;
}

- (id)savedActions
{
    if (_savedActions == nil)
        _savedActions = [NSMutableDictionary new];
    return _savedActions;
}

- (id)hyperObjectForAction:(id)aAction
{
    return [self hyperObject];
}

- (id)hyperObject
{
    return [(id)[self owner] hyperObjectForActor:self];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    for (id action in _hyperActions) {
        if ([action implementsHyperInterface:@protocol(HSActionValidation)])
            [[action attributeObservingController] removeObserver:self selector:@selector(validateActorWithNotification:) ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSActionValidationStatusAttribute)];
    }
    [self setActionsOwner:nil];
    [_hyperActions release];
    [_savedActions release];
    [_automaticTimer release];
    [_arriveAutomaticTimer release];
    [super dealloc];
}

- (id)copyWithZone:(NSZone *)aZone
{
    return [[[self class] objectWithExtraDictionary:[self extraDictionaryRepresentation] zone:aZone] retain];
}

// Drops the actions the HTML5 and iBooks players cannot run (iBooks home
// stacks only keep their allowed actions), and the clear-changes shuffle option.
- (void)removeUnsupportedActions
{
    NSArray *actions = [[self hyperActions] copy];
    for (id action in actions) {
        [action removeUnsupportedFeatures];
        BOOL remove = [action shouldBeRemoved];
        if (!remove) {
            if ([[HSAvailableActionsProvider allowediBooksHomeStackActionTypes] containsObject:NSStringFromClass([action class])])
                remove = ![action canBeExportedToHTML5DocumentType:@"HSHTML5DocumentType"];
            if (!remove) {
                id stack = [[self hyperObject] queryHyperInterface:@protocol(HSMutableStackAttributes)];
                if (stack != nil && [self hyperActionOfType:[HSClearChangeFlagAction actionType] forEvent:[HSActionEvent actionEventOfType:kHSLeaveActionEventType]] != nil)
                    [stack setShouldSaveChangesMadeInBrowseMode:NO];
            }
        }
        if (remove)
            [self removeAction:action];
    }
    [actions release];
}

@end
