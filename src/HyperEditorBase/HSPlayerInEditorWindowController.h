#import "HyperEditorBasePrefix.h"


@interface HSPlayerInEditorWindowController : HSPlayerWindowController <HSModeController>
{
    BOOL _performLeavingOperations;
    HSPauseView *_pauseView;
}
+ (id)windowNibName;
+ (NSSize)frameSizeForStackSize:(NSSize)aSize withScrollView:(BOOL)aView;
- (BOOL)validateUserInterfaceItem:(id)aItem;
- (void)togglePlayerMode:(id)aMode;
- (void)documentBackgroundPatternDidChange:(id)aChange;
- (BOOL)canPerformNavigationOperationInPalyerView:(id)aView;
- (void)cardView:(id)aView inPlayerView:(id)aView2 didSetCard:(id)aCard;
- (void)cardView:(id)aView inPlayerView:(id)aView2 willSetCard:(id)aCard;
- (void)toolPaletteSwitchToolTypes:(id)aTypes;
- (void)switchToRectSelectionToolViaGlobalShortcut:(id)aShortcut;
- (void)toolPaletteSwitchTool:(id)aTool;
- (void)windowDidBecomeVisible:(id)aVisible;
- (void)willBecomeWorkingInModeSwitcher:(id)aSwitcher;
- (void)willBecameNonWorkingInModeSwitcher:(id)aSwitcher;
- (void)didBecomeWorkingInModeSwitcher:(id)aSwitcher;
- (void)willResignActiveInModeSwitcher:(id)aSwitcher;
- (id)modeSwitcherCardView:(id)aView;
- (BOOL)prefersToEmbedModeSwitcherViewIntoScrollViewIfPossible;
- (BOOL)ownsScrollViewForModeSwitcherViewEmbedding;
- (id)modeSwitcherWindowController:(id)aController;
- (void)dealloc;
- (id)windowNibName;
- (id)cardView;
- (NSRect)frameForDisplayingPause;
- (void)hidePause;
- (BOOL)isFullScreen;
- (void)resumeButtonDidClick;
- (void)showPause;
- (id)targetForScalePopUpButton:(id)aButton inStatusbarController:(id)aController;
- (id)textForStatusBarController:(id)aController;
- (NSApplicationPresentationOptions)window:(id)aWindow willUseFullScreenPresentationOptions:(NSApplicationPresentationOptions)aOptions;
- (void)windowWillMiniaturize:(id)aNotification;
- (void)zoomSliderDidFinishTracking:(id)aSlider inStatusbarController:(id)aController;
- (void)zoomSliderDidStartTracking:(id)aSlider inStatusbarController:(id)aController;
@end

