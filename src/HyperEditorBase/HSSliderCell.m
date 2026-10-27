#import "HSSliderCell.h"

// A slider whose knob is an image (pressed or not). NSSliderCell's private
// pressed flag the original read is kept here instead, set while tracking.

@implementation HSSliderCell

- (BOOL)HSSliderCell_isPressed
{
    return _isPressed;
}

- (BOOL)startTrackingAt:(NSPoint)aPoint inView:(NSView *)aView
{
    _isPressed = YES;
    [aView setNeedsDisplay:YES];
    return [super startTrackingAt:aPoint inView:aView];
}

- (void)stopTracking:(NSPoint)aPoint at:(NSPoint)aPoint2 inView:(NSView *)aView mouseIsUp:(BOOL)aUp
{
    _isPressed = NO;
    [aView setNeedsDisplay:YES];
    [super stopTracking:aPoint at:aPoint2 inView:aView mouseIsUp:aUp];
}

- (void)loadDefaultImages
{
    HSControlslImageProvider *provider = [HSControlslImageProvider sharedImageProvider];
    if ([self numberOfTickMarks] == 0) {
        [self setSliderImage:[provider sliderWithoutMarksImage]];
        [self setSelectedSliderImage:[provider sliderPressedWithoutMarksImage]];
    } else {
        [self setSliderImage:[provider sliderWithMarksImage]];
        [self setSelectedSliderImage:[provider sliderPressedWithMarksImage]];
    }
}

- (void)invalidateSliderImages
{
    [_sliderImage release];
    _sliderImage = nil;
    [_selectedSliderImage release];
    _selectedSliderImage = nil;
    [self loadDefaultImages];
}

// The image's rect centred in the draw rect where the image is smaller.
- (NSRect)recalculateIfNeededDrawRect:(NSRect)aRect forImageRect:(NSRect)aRect2
{
    NSRect rect = aRect;
    if (aRect2.size.width < rect.size.width)
        rect = NSInsetRect(rect, (rect.size.width - aRect2.size.width) * 0.5, 0);
    if (aRect2.size.height < aRect.size.height)
        rect = NSInsetRect(rect, 0, (aRect.size.height - aRect2.size.height) * 0.5);
    return rect;
}

- (void)drawKnob:(NSRect)aKnob
{
    [NSGraphicsContext saveGraphicsState];
    NSRect knob = aKnob;
    // Original quirk kept: only a slider with its tick marks below is
    // unflipped.
    if ([self tickMarkPosition] == NSTickMarkPositionBelow && [[self controlView] isFlipped]) {
        NSAffineTransform *transform = [NSAffineTransform transform];
        [transform scaleXBy:1 yBy:-1];
        [transform concat];
        knob.origin.y = -aKnob.origin.y - aKnob.size.height;
    }
    if ([self sliderType] == NSSliderTypeLinear) {
        if (!_isPressed)
            [_sliderImage drawInRect:[self recalculateIfNeededDrawRect:knob forImageRect:_sliderImageRect] fromRect:_sliderImageRect operation:NSCompositingOperationSourceOver fraction:1];
        else
            [_selectedSliderImage drawInRect:[self recalculateIfNeededDrawRect:knob forImageRect:_selectedSliderImageRect] fromRect:_selectedSliderImageRect operation:NSCompositingOperationSourceOver fraction:1];
    } else
        [super drawKnob:aKnob];
    [NSGraphicsContext restoreGraphicsState];
}

- (void)setSelectedSliderImage:(id)aImage
{
    if (_selectedSliderImage != aImage) {
        [_selectedSliderImage release];
        _selectedSliderImage = [aImage retain];
        NSSize size = [_selectedSliderImage size];
        _selectedSliderImageRect = NSMakeRect(0, 0, size.width, size.height);
    }
}

- (id)selectedSliderImage
{
    return _selectedSliderImage;
}

- (void)setSliderImage:(id)aImage
{
    if (_sliderImage != aImage) {
        [_sliderImage release];
        _sliderImage = [aImage retain];
        NSSize size = [_sliderImage size];
        _sliderImageRect = NSMakeRect(0, 0, size.width, size.height);
    }
}

- (id)sliderImage
{
    return _sliderImage;
}

- (void)setNumberOfTickMarks:(NSInteger)aMarks
{
    [self invalidateSliderImages];
    [super setNumberOfTickMarks:aMarks];
}

- (void)dealloc
{
    [_sliderImage release];
    [_selectedSliderImage release];
    [super dealloc];
}

- (id)initWithCoder:(id)aCoder
{
    if ((self = [super initWithCoder:aCoder]))
        [self loadDefaultImages];
    return self;
}

@end
