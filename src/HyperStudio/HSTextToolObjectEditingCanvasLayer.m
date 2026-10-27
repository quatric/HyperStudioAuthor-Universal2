#import "HSTextToolObjectEditingCanvasLayer.h"

@implementation HSTextToolObjectEditingCanvasLayer

- (id)cursorForPoint:(NSPoint)aPoint insideView:(BOOL)aView modifierFlags:(NSUInteger)aFlags hitTestInfo:(id)aInfo event:(id)aEvent
{
    if (aInfo == nil)
        return nil;
    return [HSCursor textCursor];
}

- (BOOL)handleMouseDownAtPoint:(NSPoint)aPoint event:(id)aEvent hitTestInfo:(id)aInfo
{
    if (aInfo != nil)
        [_client handleMouseDownInNode:aInfo atPoint:aPoint event:aEvent inTextToolObjectEditingCanvasLayer:self];
    return aInfo != nil;
}

// Hits unlocked text objects; the node is handed back as the hit-test info.
- (id)hitTestCanvasLayerAtPoint:(NSPoint)aPoint insideView:(BOOL)aView clickCount:(NSUInteger)aCount modifierFlags:(NSUInteger)aFlags hitTestInfo:(id *)aInfo
{
    id node = nil;
    if (aView) {
        id hit = [[[self context] canvasHitTester] hitTestNodeAtPoint:aPoint];
        if ([hit implementsHyperInterface:@protocol(HSTextObjectAttributes)]) {
            id object = [hit queryHyperInterface:@protocol(HSCardObjectAttributes)];
            if (object != nil && ![object isLocked])
                node = object;
        }
    }
    if (aInfo != NULL)
        *aInfo = node;
    return node != nil ? self : nil;
}

- (void)setClient:(id)aClient
{
    _client = aClient;
}

@end
