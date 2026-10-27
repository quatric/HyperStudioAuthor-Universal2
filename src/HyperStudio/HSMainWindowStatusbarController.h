#import "HyperStudioPrefix.h"


@interface HSMainWindowStatusbarController : NSObject
{
    HSSegmentedControl *_cardNavigationControl;
    HSSlider *_zoomSlider;
    NSButton *_toggleCardIndexButton;
    NSButton *_toggleStoryboardButton;
    NSButton *_togglePresentationModeButton;
    NSButton *_goToHomeStackButton;
    NSView *_statusbarView;
    NSTextField *_stausbarTextField;
    id _delegate;
}
- (void)setZoomControlsEnabled:(BOOL)aEnabled;
- (void)refreshStatusbarText;
- (void)hyperCustomSliderDidFinishTracking:(id)aTracking;
- (void)hyperCustomSliderDidStartTracking:(id)aTracking;
- (void)setMinZoomFactor:(CGFloat)aFactor;
- (void)setMaxZoomFactor:(CGFloat)aFactor;
- (void)setZoomFactor:(CGFloat)aFactor;
- (id)delegate;
- (void)setDelegate:(id)aDelegate;
- (void)applicationWillUpdate:(id)aUpdate;
- (void)validateUI;
- (void)validateActionCell:(id)aCell;
- (void)didLoadNib;
- (void)loadNibIfNeeded;
- (id)nibName;
- (id)statusbarView;
- (void)dealloc;
@end

