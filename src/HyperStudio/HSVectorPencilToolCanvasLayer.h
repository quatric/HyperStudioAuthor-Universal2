#import "HyperStudioPrefix.h"
#import "HSDrawPathCanvasLayer.h"


@interface HSVectorPencilToolCanvasLayer : HSDrawPathCanvasLayer
{
}
- (id)cursorForPoint:(NSPoint)aPoint insideView:(BOOL)aView modifierFlags:(NSUInteger)aFlags hitTestInfo:(id)aInfo event:(id)aEvent;
@end

