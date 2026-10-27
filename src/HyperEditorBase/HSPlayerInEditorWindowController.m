#import "HSPlayerInEditorWindowController.h"

// The editor document's player mode window: tools switch back to the
// editor, and leaving the mode stops what's playing.

@implementation HSPlayerInEditorWindowController

+ (id)windowNibName
{
    return @"PlayerInEditorWindow";
}

// The stack plus a 1 point border, in a bezelled scroll view if any.
+ (NSSize)frameSizeForStackSize:(NSSize)aSize withScrollView:(BOOL)aView
{
    NSSize size = NSMakeSize(aSize.width + 2.0, aSize.height + 2.0);
    if (aView)
        size = [NSScrollView frameSizeForContentSize:size horizontalScrollerClass:[NSScroller class] verticalScrollerClass:[NSScroller class] borderType:NSBezelBorder controlSize:NSControlSizeRegular scrollerStyle:[NSScroller preferredScrollerStyle]];
    return size;
}

// No saving from the player; the browse tool (tag 2) shows as chosen.
- (BOOL)validateUserInterfaceItem:(id)aItem
{
    SEL action = [(id<NSValidatedUserInterfaceItem>)aItem action];
    if (action == @selector(saveDocument:) || action == @selector(saveDocumentAs:) || action == @selector(saveDocumentTo:) || action == @selector(revertDocumentToSaved:))
        return NO;
    if (action == @selector(toolPaletteSwitchTool:)) {
        if ([aItem respondsToSelector:@selector(setState:)])
            [(NSMenuItem *)aItem setState:[(NSMenuItem *)aItem tag] == 2 ? NSControlStateValueOn : NSControlStateValueOff];
        return YES;
    }
    if (action == @selector(togglePlayerMode:))
        return [(id)[self document] validateUserInterfaceItem:aItem];
    return [super validateUserInterfaceItem:aItem];
}

- (void)togglePlayerMode:(id)aMode
{
    [(id)[self document] togglePlayerMode:aMode];
}

- (void)documentBackgroundPatternDidChange:(id)aChange
{
    id host = [[self cardView] queryHyperInterface:@protocol(HSEditorCardViewBackgroundHost)];
    if (host != nil) {
        [host setBackgroundColor:nil];
        [[self cardView] setNeedsDisplay:YES];
    }
}

- (BOOL)canPerformNavigationOperationInPalyerView:(id)aView
{
    return !_performLeavingOperations;
}

- (void)cardView:(id)aView inPlayerView:(id)aView2 didSetCard:(id)aCard
{
    [(id)[self document] cardView:aView inWindowController:self didSetCard:aCard];
}

- (void)cardView:(id)aView inPlayerView:(id)aView2 willSetCard:(id)aCard
{
}

- (void)toolPaletteSwitchToolTypes:(id)aTypes
{
    [(id)[self document] switchToEditor];
}

- (void)switchToRectSelectionToolViaGlobalShortcut:(id)aShortcut
{
    [(id)[self document] switchToEditorWithToolTag:14];
}

- (void)toolPaletteSwitchTool:(id)aTool
{
    if ([aTool tag] != 2)
        [(id)[self document] switchToEditorWithTool:aTool];
}

- (void)windowDidBecomeVisible:(id)aVisible
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowDidUpdateNotification object:[(NSNotification *)aVisible object]];
    [self performSelectorOnMainThread:@selector(runAutomaticTimersAndArrivingActions) withObject:nil waitUntilDone:NO];
}

// Shows the editor's card (the last one if it's gone).
- (void)willBecomeWorkingInModeSwitcher:(id)aSwitcher
{
    [super willBecomeWorkingInModeSwitcher:aSwitcher];
    [[self cardView] setCard:[[aSwitcher previousModeController] activeCard]];
    if ([[[self cardView] card] hyperIndex] == NSNotFound)
        [[self cardView] setCard:[[[[self document] stack] hyperChildren] lastObject]];
    id document = [self document];
    if (![[document navigationController] isKindOfClass:[HSPlayerNavigationController class]]) {
        HSPlayerNavigationController *controller = [[HSPlayerNavigationController alloc] initWithDocument:document];
        [document setNavigationController:controller];
        [controller release];
    }
    [[self cardView] showCursor];
    [[document actionExecutionContext] activate];
}

- (void)willBecameNonWorkingInModeSwitcher:(id)aSwitcher
{
    [super willBecameNonWorkingInModeSwitcher:aSwitcher];
    [[aSwitcher activeModeController] setActiveCard:[self activeCard]];
    [[self cardView] deactivate];
}

// Runs the arriving actions now, or once the window shows.
- (void)didBecomeWorkingInModeSwitcher:(id)aSwitcher
{
    [[self window] makeFirstResponder:[self cardView]];
    [[self cardView] activate];
    [(id)[self document] setPlayerView:[self playerView]];
    [super didBecomeWorkingInModeSwitcher:aSwitcher];
    if (![self needRunArrivingActions])
        return;
    if ([[self window] isVisible])
        [self runAutomaticTimersAndArrivingActions];
    else
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowDidBecomeVisible:) name:NSWindowDidUpdateNotification object:[self window]];
}

- (void)willResignActiveInModeSwitcher:(id)aSwitcher
{
    [self exitBorderlessModeIfNeeded];
    _performLeavingOperations = YES;
    id document = [self document];
    [[document actionExecutionManager] stopAllActionQueues];
    [[self playerView] presentationWillInterrupt];
    id navigationController = [document navigationController];
    [[navigationController presentationSync] endPresentation];
    if ([navigationController currentNavigationOperation] != nil)
        [navigationController cancelNavigationOperation:[navigationController currentNavigationOperation]];
    [[document actionExecutionContext] deactivate];
    [NSObject cancelPreviousPerformRequestsWithTarget:[navigationController presentationSync]];
    _performLeavingOperations = NO;
}

- (id)modeSwitcherCardView:(id)aView
{
    return [self cardView];
}

- (BOOL)prefersToEmbedModeSwitcherViewIntoScrollViewIfPossible
{
    return NO;
}

- (BOOL)ownsScrollViewForModeSwitcherViewEmbedding
{
    return NO;
}

- (id)modeSwitcherWindowController:(id)aController
{
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

- (id)windowNibName
{
    return [[self class] windowNibName];
}

@end
