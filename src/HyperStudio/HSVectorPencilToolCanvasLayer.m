#import "HSVectorPencilToolCanvasLayer.h"

@implementation HSVectorPencilToolCanvasLayer

- (id)cursorForPoint:(NSPoint)aPoint insideView:(BOOL)aView modifierFlags:(NSUInteger)aFlags hitTestInfo:(id)aInfo event:(id)aEvent
{
    if (!aView)
        return nil;
    return [HSCursor cursorNamed:HSPencilCursor];
}

@end
