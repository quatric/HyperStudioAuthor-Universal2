#import "HSWebAppIconShadowView.h"

@implementation HSWebAppIconShadowView

- (void)dealloc
{
    [_path release];
    [super dealloc];
}

- (BOOL)isFlipped
{
    return YES;
}

- (id)path
{
    return _path;
}

// The shadow covers the view except for the icon shape.
- (void)setPath:(id)aPath
{
    [_path release];
    _path = [[NSBezierPath bezierPathWithRect:[self bounds]] retain];
    [_path setWindingRule:NSEvenOddWindingRule];
    [_path appendBezierPath:aPath];
    [self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)aRect
{
    if (_path == nil) {
        return;
    }
    [[NSGraphicsContext currentContext] saveGraphicsState];
    [_path addClip];
    [[NSColor colorWithCalibratedWhite:0.4f alpha:0.6f] set];
    NSRectFillUsingOperation(aRect, NSCompositeSourceOver);
    [[NSGraphicsContext currentContext] restoreGraphicsState];
}

@end
