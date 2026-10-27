#import "HyperStudioPrefix.h"


@interface HSStoryboardController : HSMainWindowController <HSModeController, HSStoredMenuItemTitleValidationSupport>
{
    NSView *_storyboardContainerView;
    HSStoryboardView *_storyboardView;
    HSTintedView *_bottomAreaTintedView;
    HSStoryboardStatusbarController *_statusbarController;
    BOOL _userDoubleClickedOnCard;
    NSSize _prevWindowMinContentSize;
}
- (void)stackTitleDidChanged:(id)aChanged;
- (void)revertWindowMinContentSize;
- (void)adjustWindowMinContentSize;
- (NSSize)windowFrameSizeAdjustedToCurrentContent;
- (id)cardView;
- (void)setActiveCard:(id)aCard;
- (id)activeCard;
- (BOOL)needsDeleteSelectedCardInStoryboardView:(id)aView;
- (void)storyboardView:(id)aView didSelectCard:(id)aCard;
- (void)zoomFactorDidChange:(id)aChange;
- (void)zoomToMinScaleFactor:(id)aFactor;
- (void)zoomToMaxScaleFactor:(id)aFactor;
- (void)textFieldTamer:(id)aTamer;
- (void)sameBackground:(id)aBackground;
- (void)makeGroupCard:(id)aCard;
- (BOOL)supportMenuItemStoredTitleValidation;
- (BOOL)validateUserInterfaceItem:(id)aItem;
- (void)documentBackgroundPatternDidChange:(id)aChange;
- (void)zoomSliderDidFinishTracking:(id)aTracking inStatusbarController:(id)aController;
- (void)zoomSliderDidStartTracking:(id)aTracking inStatusbarController:(id)aController;
- (id)textForStatusBarController:(id)aController;
- (void)selectionDidChange:(id)aChange;
- (BOOL)canGoToPreviousCardInStatusbarController:(id)aController;
- (BOOL)canGoToNextCardInStatusbarController:(id)aController;
- (void)didLoadNib;
- (void)didBecomeNonWorkingInModeSwitcher:(id)aSwitcher;
- (void)windowControllerWillUnbindFromWindowInModeSwitcher:(id)aSwitcher;
- (BOOL)shouldDisableAnimationInModeSwitcher:(id)aSwitcher;
- (void)willBecameNonWorkingInModeSwitcher:(id)aSwitcher;
- (void)HSStoryboardController_modeSwitcherDidEndModeSwitching:(id)aSwitching;
- (void)didBecomeWorkingInModeSwitcher:(id)aSwitcher;
- (void)willBecomeWorkingInModeSwitcher:(id)aSwitcher;
- (id)storyboardView;
- (void)setStack:(id)aStack;
- (void)setStack:(id)aStack andSelectCard:(id)aCard;
- (BOOL)prefersToEmbedModeSwitcherViewIntoScrollViewIfPossible;
- (BOOL)ownsScrollViewForModeSwitcherViewEmbedding;
- (id)secondaryModeSwitcherWindows:(id)aWindows;
- (id)modeSwitcherWindowController:(id)aController;
- (id)modeSwitcherView:(id)aView;
- (void)windowDidLoad;
- (void)prepareUI;
- (id)windowNibName;
- (void)loadNibIfNeeded;
- (void)dealloc;
@end

