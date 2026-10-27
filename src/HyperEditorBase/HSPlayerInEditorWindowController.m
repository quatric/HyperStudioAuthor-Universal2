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
        return ![(id)[self document] isTutorialStack];
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
    id document = [self document];
    if ([[HSApplicationController sharedDocumentController] isPauseResumeEnabled])
        [document resume];
    [self exitBorderlessModeIfNeeded];
    _performLeavingOperations = YES;
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
    [_pauseView setDelegate:nil];
    [_pauseView release];
    [super dealloc];
}

- (id)windowNibName
{
    return [[self class] windowNibName];
}

- (id)cardView
{
    return [super cardView];
}

- (NSRect)frameForDisplayingPause
{
    [self doesNotRecognizeSelector:_cmd];
    return NSZeroRect;
}

- (void)hidePause
{
    [_pauseView setDelegate:nil];
    [_pauseView removeFromSuperview];
    _pauseView = nil;
}

- (BOOL)isFullScreen
{
    return [[self document] isInPresentationMode];
}

- (void)resumeButtonDidClick
{
    [[self document] resume];
}

- (void)showPause
{
    _pauseView = [[HSPauseView alloc] initWithFrame:self != nil ? [self frameForDisplayingPause] : NSZeroRect];
    [_pauseView setDelegate:self];
    NSWindow *window = [self window];
    [[window contentView] addSubview:_pauseView positioned:NSWindowAbove relativeTo:nil];
    [window makeFirstResponder:_pauseView];
    [window discardCursorRects];
    [window invalidateCursorRectsForView:[window contentView]];
}

- (id)targetForScalePopUpButton:(id)aButton inStatusbarController:(id)aController
{
    return [self cardView];
}

- (id)textForStatusBarController:(id)aController
{
    NSString *format = [[NSBundle mainBundle] localizedStringForKey:@"Card %u of %u" value:@"" table:nil];
    id card = [[[self document] cardView] card];
    if (card == nil) {
        return nil;
    }
    NSUInteger index = [card hyperIndex];
    NSUInteger count = [[[card stack] queryHyperInterface:@protocol(HSNodeContainer)] hyperCount];
    NSString *string = [NSString stringWithFormat:format, (unsigned)(index + 1), (unsigned)count];
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:[NSParagraphStyle hyperParagraphStyleWithAlignment:2 lineBreakMode:5], NSParagraphStyleAttributeName, nil];
    return [[[NSAttributedString alloc] initWithString:string attributes:attributes] autorelease];
}

- (NSApplicationPresentationOptions)window:(id)aWindow willUseFullScreenPresentationOptions:(NSApplicationPresentationOptions)aOptions
{
    if ([[self document] isInPresentationMode]) {
        return aOptions | 0x800;
    }
    return aOptions;
}

- (void)windowWillMiniaturize:(id)aNotification
{
    if ([[HSApplicationController sharedDocumentController] isPauseResumeEnabled]) {
        [[self document] pause];
    }
    [super windowWillMiniaturize:aNotification];
}

- (void)zoomSliderDidFinishTracking:(id)aSlider inStatusbarController:(id)aController
{
    [[self cardView] declineDrawingQualityLoss:0.9999];
    [[self cardView] setNeedsDisplay:YES];
}

- (void)zoomSliderDidStartTracking:(id)aSlider inStatusbarController:(id)aController
{
    [[self cardView] acceptDrawingQualityLoss:0.9999];
}

@end
