#import "HyperStudioPrefix.h"


@interface HSViewController : NSObject
{
    NSString *_nibName;
    NSBundle *_nibBundle;
    NSString *_title;
    NSImage *_icon;
    NSSize _originalSize;
    NSSize _presentationSize;
    BOOL _layoutIsValid;
    NSView *_view;
    HSViewController *_parentViewController;
    HSViewController *_modalViewController;
    HSImageView *_presentationView;
    NSView *_headerView;
    NSView *_footerView;
}
- (id)nameTextfField;
- (id)initialKeyView;
- (void)viewDidDisappear:(BOOL)aDisappear;
- (void)viewWillDisappear:(BOOL)aDisappear;
- (void)viewDidAppear:(BOOL)aAppear;
- (void)viewWillAppear:(BOOL)aAppear;
- (void)viewDidLoad;
- (void)notifyViewDidDisappear:(BOOL)aDisappear;
- (void)notifyViewWillDisappear:(BOOL)aDisappear;
- (void)notifyViewDidAppear:(BOOL)aAppear;
- (void)notifyViewWillAppear:(BOOL)aAppear;
- (void)setFooterView:(id)aView;
- (id)footerView;
- (void)setHeaderView:(id)aView;
- (id)headerView;
- (void)dismissModalViewControllerAnimated:(BOOL)aAnimated;
- (void)presentModalViewController:(id)aController animated:(BOOL)aAnimated;
- (void)startAnimationWithoutHeartBeating:(id)aBeating;
- (id)modalViewController;
- (BOOL)isModalViewController;
- (id)assistantPaneUndoManager;
- (BOOL)isVisible;
- (void)layout;
- (void)layoutIfNeeded;
- (void)invalidateLayout;
- (NSSize)presentationSize;
- (NSSize)originalSize;
- (id)view;
- (id)contentView;
- (void)loadViewIfNeeded;
- (void)loadView;
- (void)createPresentationView;
- (void)setIcon:(id)aIcon;
- (id)icon;
- (void)setTitle:(id)aTitle;
- (id)title;
- (id)nibBundle;
- (id)nibName;
- (void)setParentViewController:(id)aController;
- (id)parentViewController;
- (id)rootViewController;
- (void)dealloc;
- (id)initWithNibName:(id)aName bundle:(id)aBundle;
- (id)initWithNibName:(id)aName;
@end

