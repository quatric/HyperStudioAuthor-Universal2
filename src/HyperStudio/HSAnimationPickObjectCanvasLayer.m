#import "HSAnimationPickObjectCanvasLayer.h"

@implementation HSAnimationPickObjectCanvasLayer

- (id)cursorForPoint:(NSPoint)aPoint insideView:(BOOL)aView modifierFlags:(NSUInteger)aFlags hitTestInfo:(id)aInfo event:(id)aEvent
{
    return nil;
}

- (BOOL)handleMouseMovedAtPoint:(NSPoint)aPoint insideView:(BOOL)aView event:(id)aEvent
{
    id object = [[[[self context] canvasHitTester] queryHyperInterface:@protocol(HSCanvasEditorHitTesting)] hitTestNodeAtPoint:aPoint];

    [_delegate animationPickObjectCanvasLayer:self pickedObject:object final:NO event:aEvent];
    return YES;
}

- (BOOL)handleMouseDownAtPoint:(NSPoint)aPoint event:(id)aEvent hitTestInfo:(id)aInfo
{
    id object = [[[[self context] canvasHitTester] queryHyperInterface:@protocol(HSCanvasEditorHitTesting)] hitTestNodeAtPoint:aPoint];

    [_delegate animationPickObjectCanvasLayer:self pickedObject:object final:object != nil event:aEvent];
    return YES;
}

- (id)hitTestCanvasLayerAtPoint:(NSPoint)aPoint insideView:(BOOL)aView clickCount:(NSUInteger)aCount modifierFlags:(NSUInteger)aFlags hitTestInfo:(id *)aInfo
{
    return self;
}

- (BOOL)handleKeyEventSelector:(SEL)aSelector
{
    if (aSelector != @selector(cancel:) && aSelector != @selector(cancelOperation:))
        return NO;
    [_delegate cancelFromPickObjectCanvasLayer:self];
    return YES;
}

- (void)setDelegate:(id)aDelegate
{
    _delegate = aDelegate;
}

- (id)delegate
{
    return _delegate;
}

@end
