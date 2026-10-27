#import "HyperStudioPrefix.h"
#import "HSCommentsTextView.h"


@interface HSPresentationAssistantPane : HSObjectAssistantPane <NSAnimationDelegate, NSObject>
{
    NSView *_fillTypeControllerView;
    NSButton *_coverDesktopSwitch;
    NSButton *_hideMenuBarSwitch;
    NSButton *_hideWindowTitleBarSwitch;
    NSButton *_playInFullScreenModeSwitch;
    NSPopUpButton *_fillTypePopUpButton;
    NSView *_gradientColorView;
    NSView *_imageView;
    NSView *_solidColorView;
    HSStackBackgroundGradientColorController *_fillTypeGradientColorController;
    HSStackBackgroundSolidColorController *_fillTypeSolidColorController;
    HSStackBackgroundImageController *_fillTypeImageController;
    id<HSStackBackgroundController> _fillTypeController;
    NSViewAnimation *_animation;
    HSObjectAssistantNavigationPaneSwitcher *_paneSwitcher;
    HSPresentationAssistantPaneApplier *_applier;
    BOOL _userMadeDecision;
}
- (void)defaultBackgroundAttributesDidChange:(id)aChange;
- (void)animationDidEnd:(id)aEnd;
- (void)animationDidStop:(id)aStop;
- (id)animationForView:(id)aView andView:(id)aView2;
- (void)hideMenuBarStateChanged:(id)aChanged;
- (void)coverDesktopStateChanged:(id)aChanged;
- (void)hideWindowTitleBarChanged:(id)aChanged;
- (void)playInFullScreenModeStateChanged:(id)aChanged;
- (void)fillTypeChanged:(id)aChanged;
- (void)mountController:(id)aController;
- (void)validateFillTypeController;
- (void)validateUI;
- (id)backgroundAttributes;
- (id)applier;
- (void)setApplier:(id)aApplier;
- (id)navigationPaneSwitcher;
- (void)paneDidCancel:(id)aCancel;
- (void)paneDidOK:(id)aOK;
- (void)viewWillDisappear:(BOOL)aDisappear;
- (void)viewWillAppear:(BOOL)aAppear;
- (void)dealloc;
- (id)init;
@end

