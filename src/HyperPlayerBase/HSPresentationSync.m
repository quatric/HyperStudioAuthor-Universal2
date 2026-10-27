#import "HSPresentationSync.h"
#import "HSActionEvent.h"
#import "HSActionMediaPlayer.h"

// Sequences navigation with the leave and arrive actions: going to another
// card (or stack, or closing the document) first runs the leave actions of
// the card and then of the stack, and the delegate is told when it may go on.
@implementation HSPresentationSync

// Leave actions finishing for the current card go on to the stack's (run
// later, outside this callback); once all are done, navigation or the
// pending document close proceeds.
- (void)actionsForObject:(id)aObject didFinishForEvent:(id)aEvent inActionExecutionManager:(id)aManager
{
    if (![[aEvent eventType] isEqual:kHSLeaveActionEventType])
        return;
    if ([[self dataSource] currentCardForPresentationSync:self] == aObject) {
        [[self delegate] readyToPerformGoToCard:self];
        _willGoToCard = NO;
        if (_willGoToStack) {
            id manager = [[self dataSource] actionExecutionManagerForPresentationSync:self];
            SEL selector = @selector(runActionsForObject:withEvent:inContext:forRequestor:);
            NSMethodSignature *signature = [manager methodSignatureForSelector:selector];
            if (signature != nil) {
                NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
                [invocation setTarget:manager];
                [invocation setSelector:selector];
                id stack = [[self dataSource] currentStackForPresentationSync:self];
                id event = [HSActionEvent actionEventOfType:kHSLeaveActionEventType];
                id context = [[self dataSource] actionExecutionContextForPresentationSync:self];
                id requestor = self;
                [invocation setArgument:&stack atIndex:2];
                [invocation setArgument:&event atIndex:3];
                [invocation setArgument:&context atIndex:4];
                [invocation setArgument:&requestor atIndex:5];
                [invocation retainArguments];
                [invocation performSelector:@selector(invoke) withObject:nil afterDelay:0];
            }
        }
    } else if ([[self dataSource] currentStackForPresentationSync:self] == aObject) {
        [[self delegate] readyToPerformGoToStack:self];
        _willGoToStack = NO;
    }
    if (_willGoToCard || _willGoToStack)
        return;
    if (_documentIsClosing) {
        [[_closeDocumentContextData closeDocumentDelegate] performSelector:[_closeDocumentContextData readyToCloseSelector]];
        [_closeDocumentContextData release];
        _closeDocumentContextData = nil;
        _documentIsClosing = NO;
    } else if (!_readyToPerformNavigationOperation) {
        _performingLeavingActions = NO;
        _readyToPerformNavigationOperation = YES;
        [[self delegate] readyToPerformNavigationOperation:self];
    }
}

- (void)endPresentation
{
    id manager = [[self dataSource] actionExecutionManagerForPresentationSync:self];
    [manager stopAllActionQueues];
    [[HSActionMediaPlayer sharedActionMediaPlayer] stopAllSoundsForStackUID:[[[self dataSource] currentStackForPresentationSync:self] hyperUID] andSoundAttributes:nil];
    [[[[self dataSource] actionExecutionManagerForPresentationSync:self] automaticTimerManager] stopAllAutomaticActionTimersForAllCards];
    id card = [[self dataSource] currentCardForPresentationSync:self];
    [[[card hyperChildren] queryAnyHyperInterfaces:@protocol(HSPlayableObjectAttributes)] makeObjectsPerformSelector:@selector(hyperStop)];
    [[card animationController] stopAllPlayingAnimations];
    [[[self dataSource] actionExecutionContextForPresentationSync:self] setKeyMappings:nil];
    [self willLeaveStack:[[self dataSource] currentStackForPresentationSync:self]];
}

- (BOOL)isPerformingLeaveActions
{
    return _performingLeavingActions;
}

- (BOOL)isPerformingNavigationOperation
{
    return _isPerformingNavigationOperation;
}

- (void)navigationOperationCancelled
{
    _isPerformingNavigationOperation = NO;
}

- (void)navigationOperationCompleted
{
    _isPerformingNavigationOperation = NO;
}

// At presentation start: automatic timers for the stack and card (unless
// already running), then the primary setup of actions and nodes.
- (void)runAutomaticTimersAndArrivingActions
{
    id card = [[self dataSource] currentCardForPresentationSync:self];
    id stack = [[self dataSource] currentStackForPresentationSync:self];
    id context = [[self dataSource] actionExecutionContextForPresentationSync:self];
    id timerManager = [[[self dataSource] actionExecutionManagerForPresentationSync:self] automaticTimerManager];
    if (![timerManager isAutomaticTimerActionsForStackRunning]) {
        [timerManager runAutomaticTimerActionsForStack:stack withContext:context actionEvent:[HSActionEvent actionEventOfType:kHSArriveActionEventType]];
        [timerManager runAutomaticTimerActionsForStack:stack withContext:context actionEvent:[HSActionEvent actionEventOfType:kHSClickActionEventType]];
    }
    [self performPrimaryActionsSetupForStack];
    for (id child in [stack hyperChildren])
        [[child animationController] presentationIsStarting];
    if (![timerManager isAutomaticTimerActionsForCardRunning]) {
        [timerManager runAutomaticActionTimersForCard:card withContext:context actionEvent:[HSActionEvent actionEventOfType:kHSArriveActionEventType]];
        [timerManager runAutomaticActionTimersForCard:card withContext:context actionEvent:[HSActionEvent actionEventOfType:kHSClickActionEventType]];
    }
    [self performPrimaryActionsSetupForCard:card];
    [self performPrimaryNodesSetupForCard:card];
}

- (void)prepareForUserInitiatedNavigationOperation
{
    id stack = [[self dataSource] currentStackForPresentationSync:self];
    [[stack document] resume];
    [[HSActionMediaPlayer sharedActionMediaPlayer] stopAllSoundsForStackUID:[stack hyperUID] andSoundAttributes:nil];
}

- (void)forceCloseDocument
{
    _willGoToCard = NO;
    _willGoToStack = NO;
    [[[self dataSource] actionExecutionManagerForPresentationSync:self] stopAllActionQueues];
}

// The leave actions run first; while they already run, the delegate is told
// at once.
- (void)documentWillCloseWithDelegate:(id)aDelegate readyToCloseSelector:(SEL)aSelector contextInfo:(void *)aInfo
{
    if (_documentIsClosing)
        return;
    if (_performingLeavingActions) {
        [aDelegate performSelector:aSelector];
        return;
    }
    _documentIsClosing = YES;
    _closeDocumentContextData = [[HSDocumentClosingInfo alloc] initWithDelegate:aDelegate readyToCloseSelector:aSelector contextInfo:aInfo];
    [self willGoToCard];
    [self willGoToStack];
    _performingLeavingActions = YES;
    id manager = [[self dataSource] actionExecutionManagerForPresentationSync:self];
    id context = [[self dataSource] actionExecutionContextForPresentationSync:self];
    id event = [HSActionEvent actionEventOfType:kHSLeaveActionEventType];
    [manager runActionsForObject:[[self dataSource] currentCardForPresentationSync:self] withEvent:event inContext:context forRequestor:self];
}

- (BOOL)isDocumentClosing
{
    return _documentIsClosing;
}

- (void)requestNavigationOperation
{
    _isPerformingNavigationOperation = YES;
    _readyToPerformNavigationOperation = NO;
    if (!_willGoToCard)
        return;
    _performingLeavingActions = YES;
    id manager = [[self dataSource] actionExecutionManagerForPresentationSync:self];
    id context = [[self dataSource] actionExecutionContextForPresentationSync:self];
    id event = [HSActionEvent actionEventOfType:kHSLeaveActionEventType];
    [manager runActionsForObject:[[self dataSource] currentCardForPresentationSync:self] withEvent:event inContext:context forRequestor:self];
}

- (void)willGoToStack
{
    _willGoToStack = YES;
}

- (void)willGoToCard
{
    _willGoToCard = YES;
}

- (void)didFinishNavigation
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HSPresentationSyncDidFinishNavigationNotification" object:self];
}

// Action queues of anything but the new card and its objects stop.
- (void)didFinishArrivingCard:(id)aCard
{
    NSMutableSet *objects = [NSMutableSet setWithObject:aCard];
    [objects addObjectsFromArray:[aCard hyperChildren]];
    [[[self dataSource] actionExecutionManagerForPresentationSync:self] stopAllActionQueuesExceptForObjectsInSet:objects];
}

- (void)didArriveCard:(id)aCard
{
    [[[[self dataSource] actionExecutionManagerForPresentationSync:self] automaticTimerManager] resumeAutomaticTimer];
}

- (void)willArriveCard:(id)aCard
{
    [[aCard animationController] presentationIsStarting];
    [self performPrimaryActionsSetupForCard:aCard];
    [self performPrimaryNodesSetupForCard:aCard];
    id timerManager = [[[self dataSource] actionExecutionManagerForPresentationSync:self] automaticTimerManager];
    id context = [[self dataSource] actionExecutionContextForPresentationSync:self];
    if (![timerManager isAutomaticTimerActionsForCardRunning]) {
        [timerManager runAutomaticActionTimersForCard:aCard withContext:context actionEvent:[HSActionEvent actionEventOfType:kHSArriveActionEventType]];
        [timerManager runAutomaticActionTimersForCard:aCard withContext:context actionEvent:[HSActionEvent actionEventOfType:kHSClickActionEventType]];
    }
}

- (void)didLeaveCard:(id)aCard
{
    [[[aCard hyperChildren] queryAnyHyperInterfaces:@protocol(HSPlayableObjectAttributes)] makeObjectsPerformSelector:@selector(hyperStop)];
    [[aCard animationController] stopAllPlayingAnimations];
    [[[self dataSource] currentStackForPresentationSync:self] removeAllTemporaryObjectsForCard:aCard];
    [[aCard animationController] removeAllTemporaryButAnimationsObjects];
}

- (void)willLeaveCard:(id)aCard
{
    id timerManager = [[[self dataSource] actionExecutionManagerForPresentationSync:self] automaticTimerManager];
    [timerManager pauseAutomaticTimer];
    [[[[self dataSource] actionExecutionManagerForPresentationSync:self] automaticTimerManager] stopAllAutomaticActionTimersForCard:aCard];
    [[[self dataSource] actionExecutionContextForPresentationSync:self] removeAllTemporaryPlayableObject];
}

- (void)didArriveStack:(id)aStack
{
    id manager = [[self dataSource] actionExecutionManagerForPresentationSync:self];
    id context = [[self dataSource] actionExecutionContextForPresentationSync:self];
    [manager runActionsForObject:aStack withEvent:[HSActionEvent actionEventOfType:kHSDefaultActionEventType] inContext:context forRequestor:self];
}

- (void)willArriveStack:(id)aStack
{
    id timerManager = [[[self dataSource] actionExecutionManagerForPresentationSync:self] automaticTimerManager];
    if (![timerManager isAutomaticTimerActionsForStackRunning]) {
        id context = [[self dataSource] actionExecutionContextForPresentationSync:self];
        [timerManager runAutomaticTimerActionsForStack:aStack withContext:context actionEvent:[HSActionEvent actionEventOfType:kHSArriveActionEventType]];
        [timerManager runAutomaticTimerActionsForStack:aStack withContext:context actionEvent:[HSActionEvent actionEventOfType:kHSClickActionEventType]];
    }
    [self performPrimaryActionsSetupForStack];
}

- (void)didLeaveStack:(id)aStack
{
    [[[aStack document] actionExecutionManager] stopAllActionQueuesForStack:aStack];
}

- (void)willLeaveStack:(id)aStack
{
    [[[[aStack document] actionExecutionManager] automaticTimerManager] stopAllAutomaticActionTimers];
    [[aStack queryHyperInterface:@protocol(HSTestingFunctions)] storeTestingInformation];
}

- (void)performPrimaryNodesSetupForCard:(id)aCard
{
    NSEnumerator *enumerator = [aCard hyperEnumerator];
    id node;
    while ((node = [enumerator nextObject]) != nil)
        [[node queryHyperInterface:@protocol(HSNodePrimarySetup)] performPrimarySetupOnCard:aCard];
}

- (void)performPrimaryActionsSetupForStack
{
    [self performPrimaryActionsSetupForActor:[[[self dataSource] currentStackForPresentationSync:self] queryHyperInterface:@protocol(HSActor)]];
}

// The card's objects first, then the card itself.
- (void)performPrimaryActionsSetupForCard:(id)aCard
{
    id card = aCard;
    if (card == nil)
        card = [[[self dataSource] currentCardForPresentationSync:self] queryHyperInterface:@protocol(HSNodeContainer)];
    for (id child in [NSArray arrayWithArray:[card hyperChildren]])
        [self performPrimaryActionsSetupForActor:[child queryHyperInterface:@protocol(HSActor)]];
    [self performPrimaryActionsSetupForActor:[card queryHyperInterface:@protocol(HSActor)]];
}

- (void)performPrimaryActionsSetupForActor:(id)aActor
{
    for (id action in [aActor hyperActions]) {
        id context = [[self dataSource] actionExecutionContextForPresentationSync:self];
        [action performPrimarySetupOnCard:[[self dataSource] currentCardForPresentationSync:self] actionExecutionContext:context];
    }
}

- (void)setDataSource:(id)aSource
{
    _dataSource = aSource;
}

- (id)dataSource
{
    return _dataSource;
}

- (void)setDelegate:(id)aDelegate
{
    _delegate = aDelegate;
}

- (id)delegate
{
    return _delegate;
}

- (void)dealloc
{
    [_closeDocumentContextData release];
    [super dealloc];
}

- (void)pause
{
    id dataSource = [self dataSource];
    [[dataSource actionExecutionManagerForPresentationSync:self] pauseAllActionQueues];
    [[HSActionMediaPlayer sharedActionMediaPlayer] pauseAllSoundsForStackUID:[[dataSource currentStackForPresentationSync:self] hyperUID]];
    [[[dataSource actionExecutionManagerForPresentationSync:self] automaticTimerManager] pauseAutomaticTimer];
    id card = [dataSource currentCardForPresentationSync:self];
    [[[card hyperChildren] queryAnyHyperInterfaces:@protocol(HSPlayableObjectAttributes)] makeObjectsPerformSelector:@selector(hyperPause)];
    [[card animationController] pauseAllPlayingAnimations];
}

- (void)resume
{
    id dataSource = [self dataSource];
    id card = [dataSource currentCardForPresentationSync:self];
    [[[card hyperChildren] queryAnyHyperInterfaces:@protocol(HSPlayableObjectAttributes)] makeObjectsPerformSelector:@selector(hyperResume)];
    [[card animationController] resumeAllPlayingAnimations];
    [[[dataSource actionExecutionManagerForPresentationSync:self] automaticTimerManager] resumeAutomaticTimer];
    [[HSActionMediaPlayer sharedActionMediaPlayer] resumeAllSoundsForStackUID:[[dataSource currentStackForPresentationSync:self] hyperUID]];
    [[dataSource actionExecutionManagerForPresentationSync:self] resumeAllActionQueues];
}

@end

// What to tell once the document may close.
@implementation HSDocumentClosingInfo

- (void *)closeDocumentContextInfo
{
    return _closeDocumentContextInfo;
}

- (SEL)readyToCloseSelector
{
    return _readyToCloseSelector;
}

- (id)closeDocumentDelegate
{
    return _closeDocumentDelegate;
}

- (id)initWithDelegate:(id)aDelegate readyToCloseSelector:(SEL)aSelector contextInfo:(void *)aInfo
{
    self = [super init];
    if (self != nil) {
        _closeDocumentDelegate = aDelegate;
        _readyToCloseSelector = aSelector;
        _closeDocumentContextInfo = aInfo;
    }
    return self;
}

@end
