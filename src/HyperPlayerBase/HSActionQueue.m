#import "HSActionQueue.h"
#import "HSActionEvent.h"
#import "HSActionGroup.h"
#import "HSActionSynchronizer.h"
#import "HSActionExecutionContext.h"
#import "HSActor.h"
#import "HSAutomaticTimer.h"
#import "HSChangeCardAction.h"
#import "HSGraphVertex.h"
#import "HSOrientedGraph.h"
#import "HSPlaySoundAction.h"
#import "HSQuitAction.h"
#import "HSScriptAction.h"

@implementation HSActionQueue

+ (id)actionsOrderDictionary
{
    static NSDictionary *sOrder = nil;
    if (sOrder == nil) {
        NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"ActionsOrder" ofType:@"plist"];
        sOrder = [[NSDictionary alloc] initWithContentsOfFile:path];
    }
    return sOrder;
}

- (void)decreaseContextLimitedModeIfNeeded
{
    if (_shouldDecreaseContextLimitedMode) {
        if ([self isRunning] && [self shuldIncreaseContextLimitedModeCounter])
            return;
        [_context decreaseLimitedMode];
        _shouldDecreaseContextLimitedMode = NO;
    }
}

- (void)increaseContextLimitedModeIfNeeded
{
    if ([self shuldIncreaseContextLimitedModeCounter]) {
        [_context increaseLimitedMode];
        _shouldDecreaseContextLimitedMode = YES;
    }
}

- (BOOL)shuldIncreaseContextLimitedModeCounter
{
    if ([[[self actionEvent] eventType] isEqualToString:kHSLeaveActionEventType])
        return YES;

    id groups = _actionSynchronizer ? [_actionSynchronizer notFinishedActions] : _groups;
    NSEnumerator *enumerator = [groups objectEnumerator];
    BOOL result = NO;
    id group;
next_group:
    while ((group = [enumerator nextObject]) != nil) {
        id timer = [_actor automaticTimerForActionEvent:[HSActionEvent actionEventOfType:kHSDefaultActionEventType]];
        if ([group isKindOfType:[HSToGoAction actionType]] || [timer delayBetweenRepeatingActions] > 0.0)
            return YES;
        for (id action in [group subActions]) {
            if ([[action queryHyperInterface:@protocol(HSGoogleEarthActionAttributes)] quitAfterLaunch]
                || [[action queryHyperInterface:@protocol(HSOpenLocationActionAttributes)] quitAfterLaunch]
                || [action isKindOfType:[HSQuitAction actionType]]) {
                result = YES;
                goto next_group;
            }
        }
    }
    return result;
}

- (id)orderForSourceAction:(id)aAction destinationAction:(id)aAction2
{
    NSDictionary *orders = [[self class] actionsOrderDictionary];
    NSArray *sourceTypes = [self allTypesForAction:aAction];
    NSArray *destinationTypes = [self allTypesForAction:aAction2];
    id order = nil;
    BOOL reversed = NO;

    // Walks the anti-diagonals of the (source type, destination type) matrix,
    // so the most specific matching pair of types wins.
    for (NSUInteger diagonal = 0; diagonal < [sourceTypes count] + [destinationTypes count]; diagonal++) {
        NSUInteger j = diagonal;
        for (NSUInteger i = 0; i <= diagonal; i++, j--) {
            if (i < [sourceTypes count] && j < [destinationTypes count]) {
                order = [[orders objectForKey:[sourceTypes objectAtIndex:i]] objectForKey:[destinationTypes objectAtIndex:j]];
                if (order == nil) {
                    order = [[orders objectForKey:[destinationTypes objectAtIndex:j]] objectForKey:[sourceTypes objectAtIndex:i]];
                    if (order != nil)
                        reversed = YES;
                }
                if (order != nil)
                    break;
            }
        }
        if (order != nil)
            break;
    }

    if ([[order objectForKey:@"synchronous"] boolValue] && reversed) {
        order = [[order mutableCopy] autorelease];
        [order setObject:[NSNumber numberWithBool:![[order objectForKey:@"hasHigherPriority"] boolValue]] forKey:@"hasHigherPriority"];
    }
    return order;
}

- (id)allTypesForAction:(id)aAction
{
    NSMutableArray *types = nil;
    Class cls = [aAction class];
    while ([cls respondsToSelector:@selector(actionType)]) {
        id type = [cls actionType];
        if (type != nil) {
            if (types == nil)
                types = [NSMutableArray arrayWithCapacity:0];
            [types addObject:type];
        }
        cls = [cls superclass];
    }
    return types;
}

- (id)actionEvent
{
    return _actionEvent;
}

- (void)removeActionGroup:(id)aGroup
{
    [[self mutableGroups] removeObject:aGroup];
}

- (void)addActionGroup:(id)aGroup
{
    [self insertActionGroup:aGroup atIndex:[[self mutableGroups] count]];
}

- (void)insertActionGroup:(id)aGroup atIndex:(NSInteger)aIndex
{
    [[self mutableGroups] insertObject:aGroup atIndex:aIndex];
}

- (id)actionGroups
{
    return [self mutableGroups];
}

- (id)mutableGroups
{
    if (_groups == nil)
        _groups = [NSMutableArray new];
    return _groups;
}

- (void)invalidateContext
{
    [_context release];
    _context = nil;
}

- (void)invalidateSynchronizer
{
    [_actionSynchronizer setDelegate:nil];
    [_actionSynchronizer release];
    _actionSynchronizer = nil;
    [self invalidateContext];
}

- (void)stop:(id)aStop
{
    if ([_actionSynchronizer isRunning])
        [(HSActionSynchronizer *)_actionSynchronizer stop:self];
}

- (void)actionSynchronizer:(id)aSynchronizer didFinishAction:(id)aAction
{
    [self decreaseContextLimitedModeIfNeeded];
}

- (void)actionSynchronizerDidFinishPerformActions:(id)aActions
{
    [self invalidateSynchronizer];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HSActionQueueDidFinishNotification" object:self];
    [self decreaseContextLimitedModeIfNeeded];
}

- (void)readyToStartSynchronizerAfterDelay:(id)aDelay
{
    [self startSynchronizer];
}

- (void)startInContext:(id)aContext
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HSActionQueueWillStartNotification" object:self];
    _context = [aContext retain];
    [self increaseContextLimitedModeIfNeeded];
    [self startSynchronizer];
}

- (void)startSynchronizer
{
    _actionSynchronizer = [[HSActionSynchronizer alloc] initWithActions:[self actionGroups]];
    [_actionSynchronizer setDelegate:self];
    [(HSActionSynchronizer *)_actionSynchronizer startInContext:_context];
}

- (BOOL)isRunning
{
    return [_actionSynchronizer isRunning];
}

- (BOOL)isEmpty
{
    return [_groups count] == 0;
}

- (id)actor
{
    return _actor;
}

- (void)dealloc
{
    if ([_actionSynchronizer isRunning])
        [(HSActionSynchronizer *)_actionSynchronizer stop:self];
    [_actionSynchronizer setDelegate:nil];
    [_actionSynchronizer release];
    [_context release];
    [_actionEvent release];
    [_actor release];
    [_groups release];
    [super dealloc];
}

- (void)HSActionQueue_addSynchronousGroupWithAction:(id)aAction callingObject:(id)aObject
{
    if ([aAction isValid]) {
        HSActionGroup *group = [[HSActionGroup alloc] initWithCallingObject:aObject];
        [group setSynchronous:![aAction isKindOfClass:NSClassFromString([HSPlaySoundAction actionType])]];
        [group addSubActions:[NSArray arrayWithObject:aAction]];
        if ([[group subActions] count])
            [self addActionGroup:group];
        [group release];
    }
}

- (id)initWithActionEvent:(id)aEvent andActor:(id)aActor callingObject:(id)aObject
{
    self = [super init];
    if (self == nil)
        return nil;

    _actionEvent = [aEvent retain];
    _actor = [aActor retain];
    HSOrientedGraph *graph = [HSOrientedGraph new];
    id changeCardAction = nil;
    id playSoundAction = nil;
    id googleEarthQuitAction = nil;
    id openLocationQuitAction = nil;
    id quitAction = nil;

    // Card changes, sounds and quitting actions get their own groups; the rest
    // are ordered by the ActionsOrder table.
    NSEnumerator *enumerator = [[aActor hyperActionsForEvent:aEvent] objectEnumerator];
    id action;
    while ((action = [enumerator nextObject]) != nil) {
        if ([action isKindOfClass:NSClassFromString([HSChangeCardAction actionType])])
            changeCardAction = action;
        else if ([action isKindOfClass:NSClassFromString([HSPlaySoundAction actionType])])
            playSoundAction = action;
        else if ([[action queryHyperInterface:@protocol(HSGoogleEarthActionAttributes)] quitAfterLaunch])
            googleEarthQuitAction = action;
        else if ([[action queryHyperInterface:@protocol(HSOpenLocationActionAttributes)] quitAfterLaunch])
            openLocationQuitAction = action;
        else if ([action isKindOfType:[HSQuitAction actionType]])
            quitAction = action;
        else {
            if ([action implementsHyperInterface:@protocol(HSActionValidation)]) {
                id validation = [action queryHyperInterface:@protocol(HSActionValidation)];
                if (![validation isValid] && ![validation isAbleToStartInInvalidState])
                    continue;
            }
            HSGraphVertex *vertex = [[HSGraphVertex alloc] initWithRepresentedObject:action];
            [graph addVertex:vertex];
            [vertex release];
        }
    }

    NSArray *vertices = [graph vertices];
    NSUInteger count = [vertices count];
    if (count > 1) {
        for (NSUInteger i = 0; i < count - 1; i++) {
            for (NSUInteger j = i + 1; j < count; j++) {
                HSGraphVertex *vertex = [vertices objectAtIndex:i];
                HSGraphVertex *vertex2 = [vertices objectAtIndex:j];
                id action1 = [vertex representedObject];
                id action2 = [vertex2 representedObject];
                id order = [self orderForSourceAction:action1 destinationAction:action2];
                if (order == nil)
                    continue;
                BOOL synchronous = [[order objectForKey:@"synchronous"] boolValue];
                BOOL hasHigherPriority = [[order objectForKey:@"hasHigherPriority"] boolValue];
                Class changeCardClass = NSClassFromString([HSChangeCardAction actionType]);
                if ([action1 isKindOfClass:changeCardClass] || [action2 isKindOfClass:changeCardClass]) {
                    if ([action1 canChangeSynchronousFlag])
                        [action1 setSynchronous:synchronous];
                    if ([action2 canChangeSynchronousFlag])
                        [action2 setSynchronous:synchronous];
                }
                if (synchronous) {
                    if (hasHigherPriority)
                        [graph connectVertex:vertex toVertex:vertex2];
                    else
                        [graph connectVertex:vertex2 toVertex:vertex];
                }
            }
        }
    }

    NSArray *sortedActions = [graph topologicalSort];
    [graph release];

    if (playSoundAction)
        [self HSActionQueue_addSynchronousGroupWithAction:playSoundAction callingObject:aObject];

    HSActionGroup *group = [[HSActionGroup alloc] initWithCallingObject:aObject];
    [group setSynchronous:YES];
    [group addSubActions:sortedActions];
    if ([[group subActions] count])
        [self addActionGroup:group];

    if (changeCardAction)
        [self HSActionQueue_addSynchronousGroupWithAction:changeCardAction callingObject:aObject];

    id lastAction = googleEarthQuitAction ? googleEarthQuitAction : (openLocationQuitAction ? openLocationQuitAction : quitAction);
    if (lastAction)
        [self HSActionQueue_addSynchronousGroupWithAction:lastAction callingObject:aObject];

    [group release];
    return self;
}

- (id)init
{
    [self release];
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

@end
