#import "HSPlayerNavigationController.h"
// The player's navigation: drives each operation through its stages
// (0 → 1 when requested, 2 when ready, 11 to move, 12 moving, 14
// cancelled) and reports leaving and arriving cards and stacks to the
// presentation sync (the remote-presentation mirror).
@implementation HSPlayerNavigationController
- (void)readyToPerformNavigationOperation:(id)aOperation
{
    id operation = [self currentNavigationOperation];
    if (operation == nil)
        return;
    operation = [self currentNavigationOperation];
    [operation setStage:2];
    [self continueNavigationOperation:operation];
}
- (void)readyToPerformGoToCard:(id)aCard
{
}
- (void)readyToPerformGoToStack:(id)aStack
{
}
- (id)actionExecutionContextForPresentationSync:(id)aSync
{
    return [[[self document] queryHyperInterface:@protocol(HSActionExecutionContextProvider)] actionExecutionContext];
}
- (id)actionExecutionManagerForPresentationSync:(id)aSync
{
    return [[[self document] queryHyperInterface:@protocol(HSActionExecutionManagerProvider)] actionExecutionManager];
}
- (id)currentCardForPresentationSync:(id)aSync
{
    return [[self document] currentCard];
}
- (id)currentStackForPresentationSync:(id)aSync
{
    return [[self document] stack];
}
// Staying on the same card skips the will-leave / will-arrive pair; staying
// in the same document skips leaving the stack.
- (void)finishNavigationOperation:(id)aOperation
{
    [super finishNavigationOperation:aOperation];
    [[self presentationSync] navigationOperationCompleted];
    if (_goOnTheSameCard)
        [[self presentationSync] willLeaveCard:[aOperation sourceCard]];
    [[self presentationSync] didLeaveCard:[aOperation sourceCard]];
    if (_goOnTheSameCard)
        [[self presentationSync] willArriveCard:[aOperation destinationCard]];
    [[self presentationSync] didArriveCard:[aOperation destinationCard]];
    if (([aOperation destinationStackURL] == nil || [[[self document] fileURL] isEqual:[aOperation sourceStackURL]]) && ![aOperation shouldOpenUntitledDocument])
        [[self presentationSync] didFinishArrivingCard:[aOperation destinationCard]];
    else
        [[self presentationSync] didLeaveStack:[[aOperation sourceCard] stack]];
    [[self presentationSync] didFinishNavigation];
}
- (void)continueNavigationOperation:(id)aOperation
{
    if ([aOperation stage] == 0) {
        // Requested: announce it and wait for the sync to go on.
        [aOperation setStage:1];
        if (([aOperation destinationStackURL] != nil && ![[[self document] fileURL] isEqual:[aOperation destinationStackURL]]) || [aOperation shouldOpenUntitledDocument])
            [[self presentationSync] willGoToStack];
        [[self presentationSync] willGoToCard];
        [[self presentationSync] requestNavigationOperation];
        return;
    }
    if ([aOperation stage] != 11) {
        if ([aOperation stage] == 14)
            [[self presentationSync] navigationOperationCancelled];
        [super continueNavigationOperation:aOperation];
        return;
    }
    [self disableOpenGLSurfaceIfNeeded];
    [[[self document] cardView] deactivate];
    [[[self document] actionExecutionContext] forceLeaveLimitedMode];
    if ([aOperation shouldOpenUntitledDocument]) {
        // "New stack": close this one first (the answer comes back in
        // document:shouldClose:contextInfo:).
        [[self document] canCloseDocumentWithDelegate:self shouldCloseSelector:@selector(document:shouldClose:contextInfo:) contextInfo:aOperation];
        return;
    }
    id sourceStack = [[self document] stack];
    BOOL sameDocument;
    BOOL reopen = NO;
    if ([aOperation destinationStack] != nil && [aOperation destinationStack] == sourceStack)
        sameDocument = YES;
    else if ([aOperation destinationStackURL] != nil && [[aOperation destinationStackURL] isEqual:[[self document] fileURL]])
        sameDocument = YES;
    else
        sameDocument = [aOperation destinationStack] == nil && [aOperation destinationStackURL] == nil;
    BOOL leavingStack;
    if (sameDocument && ![aOperation shouldReopenDocumentIfSoureIsDestination]) {
        [self saveHistoryForNavigationOperationIfNeeded:aOperation];
        leavingStack = NO;
    } else {
        if (sameDocument)
            reopen = YES;
        [[[self document] playerView] performNavigationOperation:aOperation];
        [self saveHistoryForNavigationOperationIfNeeded:aOperation];
        leavingStack = !reopen;
    }
    if (!leavingStack && [aOperation sourceCard] == [self destinationCardInStack:[[self document] stack] fromNavigationOperation:aOperation])
        _goOnTheSameCard = YES;
    else {
        _goOnTheSameCard = NO;
        [[self presentationSync] willLeaveCard:[aOperation sourceCard]];
        if (leavingStack)
            [[self presentationSync] willLeaveStack:sourceStack];
    }
    id windowController = [[self document] currentWindowController];
    NSWindow *window = [windowController window];
    [window disableFlushWindow];
    if (![self moveToStackWithNavigationOperation:aOperation]) {
        [self cancelNavigationOperationForSameStack:aOperation];
        [window enableFlushWindow];
        return;
    }
    if (windowController != [[self document] currentWindowController]) {
        // A new window: the transition starts from the old card's geometry.
        id cardView = [[self document] cardView];
        [aOperation setSourceCardUserSpaceToViewSpaceTransform:[cardView userSpaceToViewSpaceCGAffineTransform]];
        [aOperation setSourceCardViewTransform:[cardView NSE_affineTransformToView:nil]];
    }
    id stack = [[self document] stack];
    id card = [self destinationCardInStack:stack fromNavigationOperation:aOperation];
    if (card == nil && [[self document] stack] != sourceStack)
        card = [[[self document] stack] hyperChildAtIndex:0];
    if (card == nil) {
        [self showCannotFindCardAlert];
        [self cancelNavigationOperationForSameStack:aOperation];
        [window enableFlushWindow];
        return;
    }
    [aOperation setDestinationCard:card];
    [aOperation setDestinationStack:stack];
    [[[[self presentationSync] dataSource] actionExecutionContextForPresentationSync:[self presentationSync]] setTransitionPlaying:YES];
    if (leavingStack)
        [[self presentationSync] willArriveStack:[aOperation destinationStack]];
    if (!_goOnTheSameCard)
        [[self presentationSync] willArriveCard:[aOperation destinationCard]];
    [aOperation setStage:12];
    [[[self document] playerView] performNavigationOperation:aOperation];
    if (leavingStack)
        [[self presentationSync] didArriveStack:[aOperation destinationStack]];
    [window enableFlushWindow];
}
// By UID, else index, else HyperStudio 4 card id (0x7fffffff: none).
- (id)destinationCardInStack:(id)aStack fromNavigationOperation:(id)aOperation
{
    if ([aOperation destinationCardUID] != nil)
        return [aStack childWithUID:[aOperation destinationCardUID]];
    if ([aOperation destinationCardIndex] != 0x7fffffff)
        return [aStack hyperChildAtIndex:[aOperation destinationCardIndex]];
    if ([aOperation destinationCardIdOldFileFormat] == 0x7fffffff)
        return nil;
    NSInteger cardId = [aOperation destinationCardIdOldFileFormat];
    NSEnumerator *enumerator = [aStack hyperEnumerator];
    id card;
    while ((card = [enumerator nextObject]) != nil)
        if ([card cardIdOldFileFormat] == cardId)
            return card;
    return nil;
}
// While an operation waits for the sync (stage 1), a new one replaces it
// and ends the presentation.
- (void)startNavigationOperation:(id)aOperation
{
    if ([self currentNavigationOperation] != nil && [[self currentNavigationOperation] stage] == 1) {
        [aOperation setStage:1];
        [super setNavigationOperation:aOperation];
        if ([aOperation destinationStackURL] != nil && ![[[self document] fileURL] isEqual:[aOperation destinationStackURL]])
            [[self presentationSync] willGoToStack];
        [[self presentationSync] endPresentation];
        return;
    }
    [super startNavigationOperation:aOperation];
}
- (void)goToHome:(id)aHome
{
    id playerView = [[self document] playerView];
    [playerView interruptSlideshow];
    [playerView stopTransition];
    [super goToHome:aHome];
}
// Closing while moving to another stack keeps that operation.
- (void)willBeClosedWithDocument
{
    id operation = [self currentNavigationOperation];
    if ([operation stage] != 11 || ([[self currentNavigationOperation] destinationStack] == nil && [[self currentNavigationOperation] destinationStackURL] == nil))
        [self interruptAllNavigationOperations];
    [super willBeClosedWithDocument];
}
- (id)presentationSync
{
    if (_presentationSync == nil) {
        _presentationSync = [HSPresentationSync new];
        [_presentationSync setDataSource:self];
        [_presentationSync setDelegate:self];
    }
    return _presentationSync;
}
// "New stack": a new untitled document of this stack's card size replaces
// this one.
- (void)document:(id)aDocument shouldClose:(BOOL)aClose contextInfo:(void *)aInfo
{
    if (!aClose) {
        [self cancelNavigationOperationForSameStack:(id)aInfo];
        return;
    }
    [HSStack setNewStackCardSize:[[[self document] stack] hyperCardSize]];
    [aDocument close];
    [[NSDocumentController sharedDocumentController] openUntitledDocumentAndDisplay:YES error:NULL];
}
- (void)cancelNavigationOperationForSameStack:(id)aStack
{
    [[[self document] cardView] activate];
    [self cancelNavigationOperation:aStack];
    [[[self document] playerView] performNavigationOperation:aStack];
}
- (void)dealloc
{
    [_presentationSync setDataSource:nil];
    [_presentationSync setDelegate:nil];
    [_presentationSync release];
    [super dealloc];
}
@end
