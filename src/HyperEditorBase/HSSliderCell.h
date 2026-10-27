#import "HyperEditorBasePrefix.h"


@interface HSSliderCell : NSSliderCell
{
    NSImage *_sliderImage;
    NSImage *_selectedSliderImage;
    NSRect _sliderImageRect;
    NSRect _selectedSliderImageRect;
    BOOL _isPressed;
}
- (BOOL)HSSliderCell_isPressed;
- (void)loadDefaultImages;
- (void)invalidateSliderImages;
- (NSRect)recalculateIfNeededDrawRect:(NSRect)aRect forImageRect:(NSRect)aRect2;
- (void)drawKnob:(NSRect)aKnob;
- (void)setSelectedSliderImage:(id)aImage;
- (id)selectedSliderImage;
- (void)setSliderImage:(id)aImage;
- (id)sliderImage;
- (void)setNumberOfTickMarks:(NSInteger)aMarks;
- (void)dealloc;
- (id)initWithCoder:(id)aCoder;
@end

