#import "HyperStudioPrefix.h"


@interface HSMediaStripSwitcher : NSObject
{
    id _stripScrollView;
    id _delegate;
    NSView *_stripContainerView;
    NSButton *_stripButton;
    NSView *_topmostSuperview;
    NSView *_cardViewContainerView;
    HSScalingScrollView *_containerScrollView;
    HSEditorCardView *_cardView;
    float _windowFrameDeltaBetweenShownAndHiddenStrip;
    BOOL _isStripVisible;
    float _stripWidth;
}
- (void)mediaStripViewDidFinishRolling:(id)aRolling;
- (void)hideStripAndEnable:(BOOL)aEnable moveFrame:(BOOL)aFrame;
- (void)hideStripAndEnable:(BOOL)aEnable;
- (void)showStripAndEnable:(BOOL)aEnable;
- (void)hideStrip:(id)aStrip;
- (void)showStrip:(id)aStrip;
- (void)makeStripVisible:(BOOL)aVisible animate:(BOOL)aAnimate moveFrame:(BOOL)aFrame;
- (void)makeStripVisible:(BOOL)aVisible animate:(BOOL)aAnimate;
- (void)notifyDidShowStrip;
- (void)notifyWillHideStrip;
- (BOOL)isStripVisible;
- (void)awakeFromNib;
- (void)setDelegate:(id)aDelegate;
- (id)delegate;
- (void)dealloc;
@end

