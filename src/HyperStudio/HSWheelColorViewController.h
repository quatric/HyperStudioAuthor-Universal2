#import "HyperStudioPrefix.h"


@interface HSWheelColorViewController : NSObject
{
    HSWheelColorView *_colorView;
    HSColorSlider *_slider;
    NSColor *_color;
    id _target;
    SEL _action;
}
+ (id)defaultColor;
- (void)setAction:(SEL)aAction;
- (void)setTarget:(id)aTarget;
- (void)updateSliderWithColor:(id)aColor;
- (void)brightnessChanged:(id)aChanged;
- (id)color;
- (void)setColor:(id)aColor;
- (void)setColor:(id)aColor sender:(id)aSender;
- (void)awakeFromNib;
- (void)dealloc;
@end

