#import "HyperStudioPrefix.h"


@interface HSTextToolObjectEditingCanvasLayer : HSSimpleCanvasSublayer
{
    id<HSTextToolObjectEditingCanvasLayerClient> _client;
}
- (id)cursorForPoint:(NSPoint)aPoint insideView:(BOOL)aView modifierFlags:(NSUInteger)aFlags hitTestInfo:(id)aInfo event:(id)aEvent;
- (BOOL)handleMouseDownAtPoint:(NSPoint)aPoint event:(id)aEvent hitTestInfo:(id)aInfo;
- (id)hitTestCanvasLayerAtPoint:(NSPoint)aPoint insideView:(BOOL)aView clickCount:(NSUInteger)aCount modifierFlags:(NSUInteger)aFlags hitTestInfo:(id *)aInfo;
- (void)setClient:(id)aClient;
@end

