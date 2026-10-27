#import "HSFlatLiveSliderAnimation.h"

@implementation HSFlatLiveSliderAnimation

- (double)duration
{
    return [self isCanceling] ? _cancelingDuration : _changingDuration;
}

- (void)invertProgress
{
    [self setCurrentProgress:1.0f - [self currentProgress]];
}

- (void)invertCanceling
{
    _isCanceling = !_isCanceling;
}

- (BOOL)isCanceling
{
    return _isCanceling;
}

- (void)invertAnimationDirection
{
    [self stopAnimation];
    [self invertCanceling];
    [self invertProgress];
    [self setDuration:[self duration]];
    [super startAnimation];
}

- (void)setCurrentProgress:(CGFloat)aProgress
{
    CGFloat progress = aProgress;

    [super setCurrentProgress:aProgress];
    if (_isCanceling == _isLeftToRight)
        progress = 1.0f - aProgress;
    [_slider animateWithProgress:progress];
}

- (id)initWithFlatLiveSlider:(id)aSlider duration:(double)aDuration cancelingDuration:(double)aDuration2 isLeftToRight:(BOOL)aRight
{
    self = [super initWithDuration:aDuration animationCurve:NSAnimationEaseInOut];
    if (self != nil) {
        _slider = aSlider;
        _changingDuration = aDuration;
        _cancelingDuration = aDuration2;
        _isLeftToRight = aRight;
    }
    return self;
}

@end
