#import "HSBlueTriangleSlider.h"

@implementation HSBlueTriangleSlider

+ (Class)cellClass
{
    return [HSBlueTriangleSliderCell class];
}

- (void)setHasMultipleValues:(BOOL)aValues
{
    if ([self hasMultipleValues] != aValues) {
        [[self cell] setHasMultipleValues:aValues];
        [self setNeedsDisplay:YES];
    }
}

- (BOOL)hasMultipleValues
{
    return [[self cell] hasMultipleValues];
}

// The delegate hears when tracking starts and ends.
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
    [self setCell:[NSCell hyperCellOfClass:[HSBlueTriangleSlider cellClass] withCell:[self cell]]];
}

@end
