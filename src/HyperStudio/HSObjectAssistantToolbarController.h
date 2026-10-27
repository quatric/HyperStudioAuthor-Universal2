#import "HyperStudioPrefix.h"
#import "HSCommentsTextView.h"


@interface HSObjectAssistantToolbarController : HSObjectAssistantPane <NSAnimationDelegate, NSObject>
{
    NSDictionary *_viewControllers;
    NSMutableArray *_identifiers;
    HSObjectAssistantPane *_selectedViewController;
    NSString *_defaultPaneIdentifier;
    BOOL _isVisible;
    NSAnimation *_animation;
    NSView *_containerView;
    NSMatrix *_toolbarMatrix;
}
- (void)objectAssistantPaneAvailabilityDidChange:(id)aChange;
- (void)openPreviousPane:(id)aPane;
- (void)openNextPane:(id)aPane;
- (void)switchPane:(id)aPane;
- (void)animationDidEnd:(id)aEnd;
- (void)animationDidStop:(id)aStop;
- (void)selectViewController:(id)aController animate:(BOOL)aAnimate;
- (id)assistantPaneUndoManager;
- (void)invalidateAnimation;
- (id)selectedViewController;
- (void)openPaneWithIdentifier:(id)aIdentifier;
- (id)identifierForSelectedViewController;
- (BOOL)isEditingTextAttribute;
- (void)layout;
- (BOOL)needToRelayoutAssistant;
- (void)removeDisposablePanes;
- (BOOL)assistantShouldBeKeyWindow;
- (id)windowTitle;
- (id)initialKeyView;
- (void)viewDidDisappear:(BOOL)aDisappear;
- (void)viewWillDisappear:(BOOL)aDisappear;
- (void)viewDidAppear:(BOOL)aAppear;
- (void)viewWillAppear:(BOOL)aAppear;
- (void)setAssistant:(id)aAssistant;
- (void)viewDidLoad;
- (BOOL)validatePanesAvailability;
- (void)setObject:(id)aObject;
- (void)dealloc;
- (id)initWithViewControllers:(id)aControllers withDefaultPaneIdentifier:(id)aIdentifier;
- (id)init;
@end

