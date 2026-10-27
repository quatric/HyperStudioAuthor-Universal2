#import "HyperStudioPrefix.h"
#import "HSCommentsTextView.h"


@interface HSObjectAssistantNavigationController : HSObjectAssistantPane
{
    NSMutableArray *_navigationStack;
    NSView *_containerView;
    HSObjectAssistantNavigationPaneSwitcher *_navigationPaneSwitcher;
}
- (void)doubleClickDidDone;
- (BOOL)isViewControllerInStack:(id)aStack;
- (id)viewControllersForPaneIdentifier:(id)aIdentifier;
- (void)changeIdentifierForViewController:(id)aController toIdentifier:(id)aIdentifier;
- (BOOL)assistantShouldBeKeyWindow;
- (BOOL)canClosePane;
- (void)layout;
- (void)invalidateLayout;
- (void)removeAllViewControllersWithIdentifier:(id)aIdentifier;
- (id)popAllTopViewControllersWithIdentifier:(id)aIdentifier animate:(BOOL)aAnimate;
- (id)popViewControllerAnimated:(BOOL)aAnimated;
- (id)initialKeyView;
- (id)popViewControllerAnimated:(BOOL)aAnimated slide:(BOOL)aSlide;
- (void)removeDisposablePanes;
- (void)pushViewController:(id)aController withIdentifier:(id)aIdentifier animate:(BOOL)aAnimate replacePrevious:(BOOL)aPrevious;
- (void)pushViewController:(id)aController animate:(BOOL)aAnimate;
- (id)assistantPaneUndoManager;
- (void)setNavigationPaneSwitcher:(id)aSwitcher animate:(BOOL)aAnimate;
- (id)navigationPaneSwitcher;
- (id)paneIdentifierForTopViewController;
- (id)viewControllers;
- (id)topViewController;
- (void)setNavigationStack:(id)aStack;
- (id)navigationStack;
- (id)windowTitle;
- (void)viewDidDisappear:(BOOL)aDisappear;
- (void)viewWillDisappear:(BOOL)aDisappear;
- (void)viewDidAppear:(BOOL)aAppear;
- (void)viewWillAppear:(BOOL)aAppear;
- (void)setAssistant:(id)aAssistant;
- (NSSize)originalSize;
- (void)dealloc;
- (id)copyWithZone:(NSZone *)aZone;
- (id)initWithRootViewController:(id)aController;
- (id)initWithRootViewController:(id)aController identifier:(id)aIdentifier;
@end

@interface HSObjectAssistantPane (HSObjectAssistantNavigationControllerItem)
- (id)navigationPaneSwitcher;
- (void)setObjectAssistantNavigationController:(id)aController;
- (id)objectAssistantNavigationController;
@end

