#import "HSColorPickingCanvasLayer.h"

@implementation HSColorPickingCanvasLayer

- (BOOL)handleKeyEventSelector:(SEL)aSelector
{
    if (aSelector != @selector(cancel:) && aSelector != @selector(cancelOperation:))
        return NO;
    [self finalizeWithColor:nil];
    return YES;
}

- (id)captureColorAtCardLocation:(NSPoint)aLocation
{
    NSPoint userPoint = [_toolView convertPointFromViewSpaceToUserSpace:aLocation];
    float x = floorf(userPoint.x);
    float y = floorf(userPoint.y);
    // Fix: the original read the display's ColorSync profile (CMGetDefaultProfileByUse), which is gone; the main display's color space is used instead.
    CGColorSpaceRef colorSpace = CGDisplayCopyColorSpace(CGMainDisplayID());
    NSColorSpace *nsColorSpace = [[NSScreen mainScreen] colorSpace];
    if (colorSpace == NULL || CGColorSpaceGetModel(colorSpace) != kCGColorSpaceModelRGB || nsColorSpace == nil || [nsColorSpace colorSpaceModel] != NSColorSpaceModelRGB) {
        if (colorSpace != NULL)
            CGColorSpaceRelease(colorSpace);
        colorSpace = CGColorSpaceCreateDeviceRGB();
        nsColorSpace = [NSColorSpace deviceRGBColorSpace];
    }
    unsigned char pixel[4] = { 0, 0, 0, 0 };
    CGContextRef context = CGBitmapContextCreate(pixel, 1, 1, 8, 4, colorSpace, (CGBitmapInfo)kCGImageAlphaPremultipliedFirst);
    CGColorSpaceRelease(colorSpace);
    [NSGraphicsContext saveGraphicsState];
    [NSGraphicsContext setCurrentContext:[NSGraphicsContext graphicsContextWithCGContext:context flipped:NO]];
    CGContextTranslateCTM(context, -x, -y);
    id renderer = [[[_toolView card] queryHyperInterface:@protocol(HSVisualization)] queryRenderer];
    id delegate = [HSGenericRenderDelegate delegateWithDrawable:nil];
    [renderer drawRegion:[HSRegion regionWithRect:NSMakeRect(x, y, 1.0, 1.0)] withDelegate:delegate];
    [NSGraphicsContext restoreGraphicsState];
    CGContextRelease(context);
    CGFloat components[4];
    float divisor = pixel[0] != 0 ? (float)pixel[0] : 255.0f;
    components[3] = pixel[0] / 255.0f;
    components[0] = pixel[1] / divisor;
    components[1] = pixel[2] / divisor;
    components[2] = pixel[3] / divisor;
    return [NSColor colorWithColorSpace:nsColorSpace components:components count:4];
}

- (id)cursorForPoint:(NSPoint)aPoint insideView:(BOOL)aView modifierFlags:(NSUInteger)aFlags hitTestInfo:(id)aInfo event:(id)aEvent
{
    if (![self isPointInCardRect:[(NSEvent *)aEvent locationInWindow]] || !aView)
        return nil;
    return [HSCursor cursorNamed:HSEyeDropperCursor];
}

- (BOOL)handleMouseDownAtPoint:(NSPoint)aPoint event:(id)aEvent hitTestInfo:(id)aInfo
{
    NSPoint location = [(NSEvent *)aEvent locationInWindow];
    BOOL inside = [self isPointInCardRect:location];
    id color = nil;
    if (inside)
        color = [self captureColorAtCardLocation:[_toolView convertPoint:location fromView:nil]];
    [self finalizeWithColor:color];
    return inside;
}

- (id)hitTestCanvasLayerAtPoint:(NSPoint)aPoint insideView:(BOOL)aView clickCount:(NSUInteger)aCount modifierFlags:(NSUInteger)aFlags hitTestInfo:(id *)aInfo
{
    return self;
}

- (BOOL)isPointInCardRect:(NSPoint)aRect
{
    NSPoint point = [_toolView convertPointFromViewSpaceToUserSpace:[_toolView convertPoint:aRect fromView:nil]];
    NSSize cardSize = [_toolView cardSize];
    return NSPointInRect(point, NSMakeRect(NSZeroPoint.x, NSZeroPoint.y, cardSize.width, cardSize.height));
}

- (void)finalizeWithColor:(id)aColor
{
    [_toolView release];
    _toolView = nil;
    if ([_delegate respondsToSelector:@selector(colorPickingDidFinishInLayer:withColor:)])
        [_delegate colorPickingDidFinishInLayer:self withColor:aColor];
}

- (void)startPickingColorInView:(id)aView withDelegate:(id)aDelegate
{
    _delegate = aDelegate;
    _toolView = [aView retain];
}

- (void)dealloc
{
    [_toolView release];
    [super dealloc];
}

@end
