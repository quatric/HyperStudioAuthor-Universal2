#import "HSBlueCircleSlider.h"

@implementation HSBlueCircleSlider

+ (Class)cellClass
{
    return [HSBlueCircleSliderCell class];
}

- (void)mouseDown:(id)aDown
{
    if ([[self delegate] respondsToSelector:@selector(hyperCustomSliderDidStartTracking:)])
        [[self delegate] hyperCustomSliderDidStartTracking:self];
    [super mouseDown:aDown];
    if ([[self delegate] respondsToSelector:@selector(hyperCustomSliderDidFinishTracking:)])
        [[self delegate] hyperCustomSliderDidFinishTracking:self];
}

- (void)setDelegate:(id)aDelegate
{
    _delegate = aDelegate;
}

- (id)delegate
{
    return _delegate;
}

- (void)awakeFromNib
{
    [self setCell:[NSCell hyperCellOfClass:[HSBlueCircleSlider cellClass] withCell:[self cell]]];
}

@end
