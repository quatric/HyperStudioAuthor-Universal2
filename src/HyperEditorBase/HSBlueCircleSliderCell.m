#import "HSBlueCircleSliderCell.h"

@implementation HSBlueCircleSliderCell

- (void)loadDefaultImages
{
    HSControlslImageProvider *provider = [HSControlslImageProvider sharedImageProvider];
    [self setSliderImage:[provider sliderBlueCircleImage]];
    [self setSelectedSliderImage:[provider sliderBlueCirclePressedImage]];
}

@end
