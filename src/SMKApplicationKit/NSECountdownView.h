#import "SMKApplicationKitPrefix.h"
#import "NSEBackgroundView.h"


@interface NSECountdownView : NSEBackgroundView
{
    NSColor *_inactiveTextColor;
    NSColor *_activeTextColor;
    NSTextField * _labels[3];
    id<NSECountdownViewDelegate> _delegate;
    NSTimer *_timer;
    unsigned int _activeLabelIndex;
}
- (BOOL)isCountingDown;
- (void)stopCountdown;
- (void)NSECountdownView_timerDidFire:(id)aFire;
- (void)startCountdown;
- (void)viewWillMoveToSuperview:(id)aSuperview;
- (void)setDelegate:(id)aDelegate;
- (id)delegate;
- (void)setActiveTextColor:(id)aColor;
- (id)activeTextColor;
- (void)setInactiveTextColor:(id)aColor;
- (id)inactiveTextColor;
- (void)setFont:(id)aFont;
- (id)font;
- (BOOL)NSECountdownView_setFont:(id)aFont;
- (void)dealloc;
- (id)initWithCoder:(id)aCoder;
- (id)initWithFrame:(NSRect)aFrame;
@end

