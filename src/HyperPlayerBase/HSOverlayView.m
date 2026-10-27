#import "HSOverlayView.h"
@implementation HSOverlayView
- (void)setDrawingDelegate:(id)aDelegate
{
    _drawingDelegate = aDelegate;
}
- (id)drawingDelegate
{
    return _drawingDelegate;
}
- (void)drawRect:(NSRect)aRect
{
    [super drawRect:aRect];
    if ([_drawingDelegate respondsToSelector:@selector(overlayViewDidDraw:)])
        [_drawingDelegate overlayViewDidDraw:self];
}
@end
