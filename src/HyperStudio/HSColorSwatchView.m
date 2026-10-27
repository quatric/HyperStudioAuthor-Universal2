#import "HSColorSwatchView.h"

@implementation HSColorSwatchView

- (void)setColor:(id)aColor
{
    if (_color != aColor) {
        [_color release];
        _color = [aColor retain];
        [self setNeedsDisplay:YES];
    }
}

- (id)color
{
    return _color;
}

- (void)drawRect:(NSRect)aRect
{
    [_color drawSwatchInRect:aRect];
}

- (BOOL)isOpaque
{
    return YES;
}

@end
