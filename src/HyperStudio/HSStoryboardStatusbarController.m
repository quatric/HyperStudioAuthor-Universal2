#import "HSStoryboardStatusbarController.h"

@implementation HSStoryboardStatusbarController

- (void)setZoomControlsEnabled:(BOOL)aEnabled
{
}

- (id)nibName
{
    return @"StoryboardStatusbar";
}

- (void)setZoomFactor:(CGFloat)aFactor
{
    [super setZoomFactor:HSLinearValueForSliderFromNonLinear(_zoomSlider, aFactor)];
}

@end
