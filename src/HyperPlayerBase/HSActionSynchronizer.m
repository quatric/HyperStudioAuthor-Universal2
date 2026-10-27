#import "HSActionSynchronizer.h"

// Runs a list of actions in order: synchronous actions block the next one
// until they post HSHyperActionDidFinish, asynchronous ones only count as
// running. Waits for sheets and for card navigation to change-card targets.
@implementation HSActionSynchronizer
- (void)sheetDidEnd:(id)aEnd
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:[(NSNotification *)aEnd name] object:[aEnd object]];
    _waitingForSheet = NO;
    [self retain];
    [self runNextAction];
    [self release];
}
- (void)waitForSheet
{
    if (_waitingForSheet)
        return;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sheetDidEnd:) name:NSWindowDidEndSheetNotification object:[_context currentWindowWithSheet]];
    _waitingForSheet = YES;
}
- (BOOL)canRunNextAction
{
    return ![_context isAnySheetRunning];
}
// The delegate must handle actionSynchronizerDidFinishPerformActions:.
- (void)setDelegate:(id)aDelegate
{
    if (_delegate == aDelegate)
        return;
    if (aDelegate && ![aDelegate respondsToSelector:@selector(actionSynchronizerDidFinishPerformActions:)])
        return;
    _delegate = aDelegate;
}
- (id)delegate
{
    return _delegate;
}
- (void)asynchronousActionDidFinish:(id)aFinish
{
    [self removeActionFromCurrentlyRunningActions:[aFinish object]];
    if (![self isRunning])
        [self finishRunningActions];
}
- (void)actionDidFinish:(id)aFinish
{
    [self removeActionFromCurrentlyRunningActions:[aFinish object]];
    if ([self isRunning])
        [self runNextAction];
    else
        [self finishRunningActions];
}
- (void)removeActionFromCurrentlyRunningActions:(id)aActions
{
    [[self currentlyRunningActions] removeObject:aActions];
    if ([_delegate respondsToSelector:@selector(actionSynchronizer:didFinishAction:)])
        [_delegate actionSynchronizer:self didFinishAction:aActions];
}
- (void)stop:(id)aStop
{
    [_actionsEnumerator release];
    _actionsEnumerator = nil;
    [[self actionsToStart] removeAllObjects];
    NSEnumerator *enumerator = [[NSArray arrayWithArray:[self currentlyRunningActions]] objectEnumerator];
    id action;
    while ((action = [enumerator nextObject])) {
        if ([action canBeStopped])
            [action stop:self];
    }
}
// The context is not retained.
- (void)startInContext:(id)aContext
{
    _context = aContext;
    [[self actionsToStart] addObjectsFromArray:_actions];
    NSEnumerator *enumerator = [_actions objectEnumerator];
    id action;
    while ((action = [enumerator nextObject]))
        [[NSNotificationCenter defaultCenter] addObserver:self selector:([action isSynchronous] ? @selector(actionDidFinish:) : @selector(asynchronousActionDidFinish:)) name:@"HSHyperActionDidFinish" object:action];
    [_actionsEnumerator release];
    _actionsEnumerator = [[_actions objectEnumerator] retain];
    [self runNextAction];
}
// Starts actions up to and including the next synchronous one.
- (void)runNextAction
{
    [self isRunning];
    if (![self canRunNextAction]) {
        [self waitForSheet];
        return;
    }
    if ([self needsToWaitForCardNavigationToFinish]) {
        [self waitForCardNavigationToFinish];
        return;
    }
    id action;
    do {
        while (YES) {
            action = [_actionsEnumerator nextObject];
            if (!action)
                return;
            [[self actionsToStart] removeObjectIdenticalTo:action];
            if ([_context canRunAction:action])
                break;
            [_context notifyUserAboutActionRunningFailureIfNeeded:action];
            if (![self isRunning])
                [self finishRunningActions];
        }
        [[self currentlyRunningActions] addObject:action];
        [action startInContext:_context];
    } while (![action isSynchronous]);
}
- (void)waitForCardNavigationToFinish
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(presentationSyncDidFinishNavigation:) name:HSPresentationSyncDidFinishNavigationNotification object:[[_context navigationController] presentationSync]];
}
- (void)presentationSyncDidFinishNavigation:(id)aNavigation
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:[(NSNotification *)aNavigation name] object:[aNavigation object]];
    [self runNextAction];
}
// A change-card action must wait while navigation to its card is running.
- (BOOL)needsToWaitForCardNavigationToFinish
{
    id action = [[[self actionsToStart] extraFirstObject] queryHyperInterface:@protocol(HSChangeCardActionAttributes)];
    id card = [[[action hyperObject] queryHyperInterface:@protocol(HSActionSupport)] cardForAction:action];
    if (!card)
        return NO;
    return card == [[[_context navigationController] currentNavigationOperation] destinationCard];
}
- (void)finishRunningActions
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"HSHyperActionDidFinish" object:nil];
    [_actionsEnumerator release];
    _actionsEnumerator = nil;
    if (_delegate) {
        [[self retain] autorelease];
        [_delegate actionSynchronizerDidFinishPerformActions:self];
    }
}
- (BOOL)isRunning
{
    return [[self currentlyRunningActions] count] || [[self actionsToStart] count];
}
- (id)notFinishedActions
{
    NSMutableArray *actions = [NSMutableArray arrayWithArray:[self currentlyRunningActions]];
    [actions addObjectsFromArray:[self actionsToStart]];
    return actions;
}
- (id)actionsToStart
{
    if (!_actionsToStart)
        _actionsToStart = [NSMutableArray new];
    return _actionsToStart;
}
- (id)currentlyRunningActions
{
    if (!_currentlyRunningActions)
        _currentlyRunningActions = [NSMutableArray new];
    return _currentlyRunningActions;
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_actions release];
    [_currentlyRunningActions release];
    [_actionsToStart release];
    [_actionsEnumerator release];
    [super dealloc];
}
- (id)initWithActions:(id)aActions
{
    self = [super init];
    if (self)
        _actions = [aActions retain];
    return self;
}
- (id)init
{
    [self release];
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}
@end
