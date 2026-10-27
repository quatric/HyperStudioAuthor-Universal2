#import "HyperStudioPrefix.h"


@interface HSFlatLiveSliderAnimation : NSAnimation
{
    HSFlatLiveSlider *_slider;
    BOOL _isCanceling;
    BOOL _isLeftToRight;
    double _changingDuration;
    double _cancelingDuration;
}
- (double)duration;
- (void)invertProgress;
- (void)invertCanceling;
- (BOOL)isCanceling;
- (void)invertAnimationDirection;
- (void)setCurrentProgress:(CGFloat)aProgress;
- (id)initWithFlatLiveSlider:(id)aSlider duration:(double)aDuration cancelingDuration:(double)aDuration2 isLeftToRight:(BOOL)aRight;
@end

