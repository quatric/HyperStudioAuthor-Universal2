#import "HSSegmentViewSliderCell.h"

static float HSSegmentSliderScale(float aValue)
{
    return aValue != 0.0f ? fabsf(aValue) : 1.0f;
}

@implementation HSSegmentViewSliderCell

- (void)onSlider:(id)aSlider
{
    if (_isTracking)
        return;
    if ([_delegate respondsToSelector:@selector(startChangingCurrentValue:)])
        [_delegate startChangingCurrentValue:[self floatValue]];
    if ([_delegate respondsToSelector:@selector(continueChangingCurrentValue:)])
        [_delegate continueChangingCurrentValue:[self floatValue]];
    if ([_delegate respondsToSelector:@selector(stopChangingCurrentValue:)])
        [_delegate stopChangingCurrentValue:[self floatValue]];
}

- (void)stopTracking:(NSPoint)aTracking at:(NSPoint)aAt inView:(id)aView mouseIsUp:(BOOL)aUp
{
    [super stopTracking:aTracking at:aAt inView:aView mouseIsUp:aUp];
    if ([_delegate respondsToSelector:@selector(stopChangingCurrentValue:)])
        [_delegate stopChangingCurrentValue:[self floatValue]];
    _isTracking = NO;
}

- (BOOL)continueTracking:(NSPoint)aTracking at:(NSPoint)aAt inView:(id)aView
{
    BOOL result = [super continueTracking:aTracking at:aAt inView:aView];
    if ([_delegate respondsToSelector:@selector(continueChangingCurrentValue:)])
        [_delegate continueChangingCurrentValue:[self floatValue]];
    return result;
}

- (BOOL)startTrackingAt:(NSPoint)aAt inView:(id)aView
{
    _isTracking = YES;
    if ([_delegate respondsToSelector:@selector(startChangingCurrentValue:)])
        [_delegate startChangingCurrentValue:[self floatValue]];
    return [super startTrackingAt:aAt inView:aView];
}

- (void)drawWithFrame:(NSRect)aFrame inView:(id)aView
{
    float xScale = MAX(HSSegmentSliderScale(fabs(aFrame.origin.x) + aFrame.size.width), HSSegmentSliderScale(fabs(_oldFrame.origin.x) + _oldFrame.size.width));
    float yScale = MAX(HSSegmentSliderScale(fabs(aFrame.origin.y) + aFrame.size.height), HSSegmentSliderScale(fabs(_oldFrame.origin.y) + _oldFrame.size.height));
    if (fabs(_oldFrame.origin.x - aFrame.origin.x) > xScale * 0.0005f
        || fabs(_oldFrame.origin.y - aFrame.origin.y) > yScale * 0.0005f
        || fabs(_oldFrame.size.width - aFrame.size.width) > xScale * 0.0005f
        || fabs(_oldFrame.size.height - aFrame.size.height) > yScale * 0.0005f) {
        [super drawWithFrame:aFrame inView:aView];
        _oldFrame = aFrame;
        [(NSView *)aView display];
    } else {
        [self drawKnob];
    }
}

- (void)setDelegate:(id)aDelegate
{
    _delegate = aDelegate;
}

- (id)delegate
{
    return _delegate;
}

- (id)init
{
    self = [super init];
    if (self != nil) {
        _isTracking = NO;
        [self setTarget:self];
        [self setAction:@selector(onSlider:)];
    }
    return self;
}

@end
