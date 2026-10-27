#import "HSWheelColorView.h"

@implementation HSWheelColorView

+ (id)defaultColor
{
    return [NSColor greenColor];
}

- (BOOL)acceptsFirstResponder
{
    return YES;
}

- (id)wheelImage
{
    if (_wheelImage == nil)
        _wheelImage = [[NSImage imageNamed:@"HSColorWheelImage"] retain];
    return _wheelImage;
}

// A click must land on the wheel; dragging keeps picking even outside it.
- (void)mouseDown:(id)aDown
{
    NSWindow *window = [self window];
    NSEvent *event = aDown;
    while (YES) {
        NSPoint point = [self convertPoint:[event locationInWindow] fromView:nil];
        NSEventType type = [event type];
        if (type == NSEventTypeLeftMouseDragged || type == NSEventTypeLeftMouseDown) {
            NSColor *color = [self colorAtLocation:point useWheelPath:type == NSEventTypeLeftMouseDown];
            if (color != nil)
                [self setColor:color];
        }
        event = [window nextEventMatchingMask:NSEventMaskLeftMouseUp | NSEventMaskLeftMouseDragged];
        if ([event type] == NSEventTypeLeftMouseUp) {
            [window discardEventsMatchingMask:NSEventMaskAny beforeEvent:event];
            return;
        }
    }
}

// Hue is the angle around the center, saturation the distance relative to the wheel radius.
- (id)colorAtLocation:(NSPoint)aLocation useWheelPath:(BOOL)aPath
{
    NSRect wheelRect = [self wheelRect];
    if (![[self wheelPath] containsPoint:aLocation] && aPath)
        return nil;
    NSRect bounds = [self bounds];
    float dy = aLocation.y - (bounds.size.height * 0.5f + bounds.origin.y);
    float dx = aLocation.x - (bounds.size.width * 0.5f + bounds.origin.x);
    float sign, base;
    if (dy >= 0.0f && dx < 0.0f) {
        dx = -dx;
        sign = -1.0f;
        base = 180.0f;
    }
    else if (dy < 0.0f && dx < 0.0f) {
        dy = -dy;
        dx = -dx;
        sign = 1.0f;
        base = 180.0f;
    }
    else if (dy < 0.0f) {
        dy = -dy;
        sign = -1.0f;
        base = 360.0f;
    }
    else {
        sign = 1.0f;
        base = 0.0f;
    }
    float distance = sqrtf(dx * dx + dy * dy);
    double angle = asin((double)(dy / distance));
    float saturation = MIN(distance / (wheelRect.size.width * 0.5f), 1.0f);
    return [NSColor colorWithCalibratedHue:(float)((angle * 180.0 / M_PI) * sign + base) / 360.0f saturation:saturation brightness:[[self color] brightnessComponent] alpha:[[self color] alphaComponent]];
}

- (id)wheelPath
{
    NSRect wheelRect = [self wheelRect];
    float inset = wheelRect.size.width / [(NSImage *)[self wheelImage] size].width;
    return [NSBezierPath bezierPathWithOvalInRect:NSInsetRect(wheelRect, -inset, -inset)];
}

- (NSRect)wheelRect
{
    NSRect rect = [self bounds];
    if (rect.size.width > rect.size.height) {
        rect.origin.x += (rect.size.width - rect.size.height) * 0.5f;
        rect.size.width = rect.size.height;
    }
    else if (rect.size.width < rect.size.height) {
        rect.origin.y += (rect.size.height - rect.size.width) * 0.5f;
        rect.size.height = rect.size.width;
    }
    return rect;
}

- (void)setColor:(id)aColor
{
    [_controller setColor:aColor sender:self];
}

- (id)color
{
    return [[_controller color] colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
}

- (void)drawSelectionInWheelWithRadius:(CGFloat)aRadius
{
    CGFloat hue = 0.0, saturation = 1.0, brightness, alpha;
    [[self color] getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
    float distance = saturation * aRadius;
    double angle = hue * 2.0 * M_PI;
    NSRect bounds = [self bounds];
    [[NSColor blackColor] set];
    NSFrameRect(NSMakeRect(bounds.size.width * 0.5f + (float)cos(angle) * distance + bounds.origin.x - 2.0f, (float)sin(angle) * distance + bounds.origin.y + bounds.size.height * 0.5f - 2.0f, 4.0, 4.0));
}

- (void)drawRect:(NSRect)aRect
{
    NSRect wheelRect = [self wheelRect];
    NSImage *image = [self wheelImage];
    NSSize imageSize = [image size];
    NSBezierPath *path = [NSBezierPath bezierPathWithOvalInRect:wheelRect];
    [[NSGraphicsContext currentContext] saveGraphicsState];
    [path setClip];
    [[NSColor blackColor] set];
    [path fill];
    float inset = wheelRect.size.width / imageSize.width;
    [image drawInRect:NSInsetRect(wheelRect, -inset, -inset) fromRect:NSMakeRect(0.0, 0.0, imageSize.width, imageSize.height) operation:NSCompositingOperationSourceOver fraction:[[self color] brightnessComponent]];
    [[NSGraphicsContext currentContext] restoreGraphicsState];
    [self drawSelectionInWheelWithRadius:wheelRect.size.width * 0.5f];
}

- (id)initWithFrame:(NSRect)aFrame
{
    return [super initWithFrame:aFrame];
}

// Fix: the wheel image is released, not sent dealloc directly.
- (void)dealloc
{
    [_wheelImage release];
    [super dealloc];
}

@end
