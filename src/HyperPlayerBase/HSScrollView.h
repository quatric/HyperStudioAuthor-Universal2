#import "HyperPlayerBasePrefix.h"


@interface HSScrollView : NSScrollView
{
    NSTimer *_scrollWheelTimer;
    BOOL _isScrollingDisabled;
    BOOL _isTrackingScroller;
    BOOL _isScrollingByScrollWheel;
}
- (void)encodeWithCoder:(id)aCoder;
- (id)initWithCoder:(id)aCoder;
- (void)scrollWheel:(id)aWheel;
- (void)HSScrollView_scrollWheelDidEnd:(id)aEnd;
- (void)didFinishTrackingScroller:(id)aScroller;
- (void)willStartTrackingScroller:(id)aScroller;
- (void)updateClipViewScrollableState;
- (void)setIsScrollingByScrollWheel:(BOOL)aWheel;
- (BOOL)isScrollingByScrollWheel;
- (void)setIsTrackingScroller:(BOOL)aScroller;
- (BOOL)isTrackingScroller;
- (void)setScrollable:(BOOL)aScrollable;
- (BOOL)isScrollable;
- (id)hyperContentView;
- (void)dealloc;
@end

