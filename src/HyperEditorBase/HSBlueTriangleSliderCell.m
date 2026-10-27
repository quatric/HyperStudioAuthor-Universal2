#import "HSBlueTriangleSliderCell.h"

@implementation HSBlueTriangleSliderCell

- (void)loadDefaultImages
{
    HSControlslImageProvider *provider = [HSControlslImageProvider sharedImageProvider];
    if ([self tickMarkPosition] == NSTickMarkPositionBelow) {
        [self setSliderImage:[provider sliderBelowBlueTriangleImage]];
        [self setSelectedSliderImage:[provider sliderBelowBlueTrianglePressedImage]];
    } else {
        [self setSliderImage:[provider sliderAboveBlueTriangleImage]];
        [self setSelectedSliderImage:[provider sliderAboveBlueTrianglePressedImage]];
    }
}

// No knob while the value is mixed.
- (void)drawKnob:(NSRect)aKnob
{
    if ([self hasMultipleValues])
        return;
    [NSGraphicsContext saveGraphicsState];
    NSRect knob = aKnob;
    if ([[self controlView] isFlipped]) {
        NSAffineTransform *transform = [NSAffineTransform transform];
        [transform scaleXBy:1 yBy:-1];
        [transform concat];
        knob.origin.y = -aKnob.origin.y - aKnob.size.height;
    }
    if ([self sliderType] == NSSliderTypeLinear) {
        if (![self HSSliderCell_isPressed])
            [_sliderImage drawInRect:knob fromRect:_sliderImageRect operation:NSCompositingOperationSourceOver fraction:1];
        else
            [_selectedSliderImage drawInRect:knob fromRect:_selectedSliderImageRect operation:NSCompositingOperationSourceOver fraction:1];
    } else
        [super drawKnob:aKnob];
    [NSGraphicsContext restoreGraphicsState];
}

- (void)setHasMultipleValues:(BOOL)aValues
{
    _hasMultipleValues = aValues;
}

- (BOOL)hasMultipleValues
{
    return _hasMultipleValues;
}

@end
