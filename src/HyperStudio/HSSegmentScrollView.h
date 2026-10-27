#import "HyperStudioPrefix.h"


@interface HSSegmentScrollView : NSScrollView
{
    NSSlider *_valueScaleSlider;
}
+ (id)valueScaleSliderBorderColor;
+ (NSSize)valueScaleSliderSize;
- (void)drawRect:(NSRect)aRect;
- (void)tile;
- (void)awakeFromNib;
- (id)valueScaleSlider;
- (void)dealloc;
@end

