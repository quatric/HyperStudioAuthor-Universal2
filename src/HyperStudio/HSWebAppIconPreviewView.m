#import "HSWebAppIconPreviewView.h"

@implementation HSWebAppIconPreviewView

- (void)dealloc
{
    [_icon release];
    [super dealloc];
}

- (id)icon
{
    return _icon;
}

- (void)setIcon:(id)aIcon
{
    [_icon release];
    _icon = [aIcon retain];
    [self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)aRect
{
    NSRect bounds = self != nil ? [self bounds] : NSZeroRect;
    NSBezierPath *outline = [NSBezierPath bezierPathWithRoundedRect:bounds xRadius:bounds.size.width * 0.1754386f yRadius:bounds.size.height * 0.1754386f];
    [[NSGraphicsContext currentContext] saveGraphicsState];
    [outline addClip];
    [_icon drawInRect:bounds fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0f];
    [[NSColor controlColor] set];
    [outline stroke];
    [[NSGraphicsContext currentContext] restoreGraphicsState];
}

@end
