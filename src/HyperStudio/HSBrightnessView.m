#import "HSBrightnessView.h"

@implementation HSBrightnessView

+ (id)defaultColor
{
    return [NSColor whiteColor];
}

- (id)color
{
    if (_color == nil)
        [self initializeColor];
    return [_color hyperStartColor];
}

- (void)setColor:(id)aColor
{
    if ([aColor isEqualTo:[_color hyperStartColor]])
        return;
    if (_color == nil)
        [self initializeColor];
    [_color setStartColor:aColor];
}

- (void)initializeColor
{
    _color = [[HSColor alloc] init];
    [_color setStartColor:[[self class] defaultColor]];
    [_color setEndColor:[NSColor blackColor]];
    [_color setAngle:90.0f];
}

// Original quirk kept: draws the plain start colour, not the gradient.
- (void)drawRect:(NSRect)aRect
{
    [[self color] drawSwatchInRect:aRect];
}

- (id)initWithFrame:(NSRect)aFrame
{
    return [super initWithFrame:aFrame];
}

// Fix: the original sent -dealloc straight to the colour instead of releasing it.
- (void)dealloc
{
    [_color release];
    [super dealloc];
}

@end
