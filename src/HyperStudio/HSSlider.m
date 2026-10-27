#import "HSSlider.h"

@implementation HSSlider

+ (Class)cellClass
{
    return [HSSliderCell class];
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
    [self setCell:[NSCell hyperCellOfClass:[HSSlider cellClass] withCell:[self cell]]];
}

@end
