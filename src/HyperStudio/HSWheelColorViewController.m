#import "HSWheelColorViewController.h"

@implementation HSWheelColorViewController

+ (id)defaultColor
{
    return [NSColor whiteColor];
}

- (void)setAction:(SEL)aAction
{
    _action = aAction;
}

- (void)setTarget:(id)aTarget
{
    _target = aTarget;
}

- (void)updateSliderWithColor:(id)aColor
{
    NSColor *color = [aColor colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
    [_slider setTopColor:[NSColor colorWithDeviceHue:[color hueComponent] saturation:[color saturationComponent] brightness:1.0 alpha:[color alphaComponent]]];
    [_slider setFloatValue:[color brightnessComponent]];
}

- (void)brightnessChanged:(id)aChanged
{
    NSColor *color = [self color];
    [self setColor:[NSColor colorWithDeviceHue:[color hueComponent] saturation:[color saturationComponent] brightness:[aChanged floatValue] alpha:[color alphaComponent]] sender:aChanged];
}

- (id)color
{
    if (_color == nil)
        [self setColor:[[self class] defaultColor]];
    return _color;
}

- (void)setColor:(id)aColor
{
    [self setColor:aColor sender:nil];
}

- (void)setColor:(id)aColor sender:(id)aSender
{
    if (_color == aColor)
        return;
    if (aColor != nil && [_color isEqualTo:aColor])
        return;
    [_color release];
    // Original quirk kept: the color is always converted to device RGB (the calibrated check can never pass).
    if ([[aColor colorSpaceName] isEqualTo:NSDeviceRGBColorSpace] && [[aColor colorSpaceName] isEqualTo:NSCalibratedRGBColorSpace])
        _color = [aColor retain];
    else
        _color = [[aColor colorUsingColorSpaceName:NSDeviceRGBColorSpace] retain];
    [_colorView setNeedsDisplay:YES];
    if (_slider != aSender)
        [self updateSliderWithColor:aColor];
    if ((_colorView == aSender || _slider == aSender) && [_target respondsToSelector:_action])
        [_target performSelector:_action withObject:self];
}

- (void)awakeFromNib
{
    [_slider setTarget:self];
    [_slider setAction:@selector(brightnessChanged:)];
    [_slider setBottomColor:[NSColor blackColor]];
}

- (void)dealloc
{
    // Fix: the original sent -dealloc to the color instead of -release.
    [_color release];
    [super dealloc];
}

@end
