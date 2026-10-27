#import "HyperPlayerBasePrefix.h"


@interface HSOverlayView : NSView
{
    id _drawingDelegate;
}
- (void)setDrawingDelegate:(id)aDelegate;
- (id)drawingDelegate;
- (void)drawRect:(NSRect)aRect;
@end

