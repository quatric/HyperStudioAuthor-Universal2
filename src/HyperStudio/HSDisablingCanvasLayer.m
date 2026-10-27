#import "HSDisablingCanvasLayer.h"

@implementation HSDisablingCanvasLayer

- (void)willResignActiveLayer
{
}

- (void)didBecomeActiveLayer
{
}

- (BOOL)handleKeyEventSelector:(SEL)aSelector
{
    return YES;
}

- (BOOL)handleFlagsChanged:(id)aChanged atPoint:(NSPoint)aPoint
{
    return YES;
}

- (BOOL)handleMouseMovedAtPoint:(NSPoint)aPoint insideView:(BOOL)aView event:(id)aEvent
{
    return YES;
}

- (id)cursorForPoint:(NSPoint)aPoint insideView:(BOOL)aView modifierFlags:(NSUInteger)aFlags hitTestInfo:(id)aInfo event:(id)aEvent
{
    return [HSCursor defaultCursor];
}

- (BOOL)handleMouseDownAtPoint:(NSPoint)aPoint event:(id)aEvent hitTestInfo:(id)aInfo
{
    return YES;
}

- (id)hitTestCanvasLayerAtPoint:(NSPoint)aPoint insideView:(BOOL)aView clickCount:(NSUInteger)aCount modifierFlags:(NSUInteger)aFlags hitTestInfo:(id *)aInfo
{
    return self;
}

- (void)renderRect:(NSRect)aRect
{
    [[NSColor colorWithCalibratedRed:0.6 green:0.8 blue:1.0 alpha:0.5] set];
    [NSBezierPath fillRect:NSInsetRect(aRect, -2.0, -2.0)];
}

- (void)invalidateDisplay
{
    [[[self context] renderingView] setNeedsDisplayOpenGLSurface:YES];
}

@end
