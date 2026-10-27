#import "HSGradientsPreviewView.h"

@implementation HSGradientsPreviewView

- (void)dealloc
{
    [_drawingDelegate release];
    [super dealloc];
}

- (id)drawingDelegate
{
    return _drawingDelegate;
}

- (void)setDrawingDelegate:(id)aDelegate
{
    if (_drawingDelegate != aDelegate) {
        [_drawingDelegate release];
        _drawingDelegate = nil;
        if ([aDelegate conformsToProtocol:@protocol(HSDrawingDlegate)])
            _drawingDelegate = [aDelegate retain];
    }
}

- (void)drawRect:(NSRect)aRect
{
    [super drawRect:aRect];
    if (_drawingDelegate != nil) {
        NSGraphicsContext *context = [NSGraphicsContext currentContext];
        [context saveGraphicsState];
        [_drawingDelegate redrawViewInContext:context rect:[super bounds]];
        [context restoreGraphicsState];
    }
}

- (id)initWithFrame:(NSRect)aFrame
{
    return [super initWithFrame:aFrame];
}

@end
