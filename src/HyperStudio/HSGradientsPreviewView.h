#import "HyperStudioPrefix.h"


@interface HSGradientsPreviewView : NSView
{
    id<HSDrawingDlegate> _drawingDelegate;
}
- (void)dealloc;
- (id)drawingDelegate;
- (void)setDrawingDelegate:(id)aDelegate;
- (void)drawRect:(NSRect)aRect;
- (id)initWithFrame:(NSRect)aFrame;
@end

