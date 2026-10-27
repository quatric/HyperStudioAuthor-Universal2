#import "HyperStudioPrefix.h"


@interface HSMinimalWindowApplier : NSObject
{
    NSWindow *_window;
    HSCardView *_cardView;
    BOOL _isInMinimalWindowMode;
    BOOL _doesntSupportMinimalWindowMode;
    BOOL _isMinimalWindowModeApplied;
    BOOL _minimalWindowModeStatusIsChangingBecauseOfSupport;
    NSMutableDictionary *_fullWindowModeSettings;
    NSView *_workAreaView;
    NSView *_cardWorkAreaView;
    NSView *_statusBarContainerView;
    HSMediaStripSwitcher *_mediaStripSwitcher;
    HSScalingScrollView *_cardScrollView;
}
- (void)setSupportsMinimalWindowMode:(BOOL)aMode;
- (BOOL)supportsMinimalWindowMode;
- (void)setIsInMinimalWindowMode:(BOOL)aMode;
- (BOOL)isInMinimalWindowMode;
- (void)applyProperWindowModeIfNeeded;
- (void)setMinimalWindowModeApplied:(BOOL)aApplied;
- (BOOL)isMinimalWindowModeApplied;
- (void)applyFullWindowMode;
- (void)applyMinimalWindowMode;
- (void)replaceCardView:(id)aView;
- (void)setupWithWorkAreaView:(id)aView cardWorkAreaView:(id)aView2 statusBarContainerView:(id)aView3 cardScrollView:(id)aView4 mediaStripSwitcher:(id)aSwitcher;
- (id)cardView;
- (id)window;
- (id)fullWindowModeSettings;
- (void)dealloc;
- (id)init;
- (id)initWithWindow:(id)aWindow cardView:(id)aView;
@end

