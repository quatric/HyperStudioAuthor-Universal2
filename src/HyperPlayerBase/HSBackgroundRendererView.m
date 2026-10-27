#import "HSBackgroundRendererView.h"
@implementation HSBackgroundRendererView
- (void)drawRect:(NSRect)aRect
{
    [[NSColor clearColor] set];
    NSRectFill(aRect);
    [_backgroundRendererInterface hyperDrawBackgroundInROI:aRect ofBounds:[self bounds]];
}
- (void)setBackgroundRenderer:(id)aRenderer
{
    if (_backgroundRendererInterface != aRenderer) {
        [_backgroundRendererInterface release];
        _backgroundRendererInterface = [aRenderer retain];
    }
}
- (id)backgroundRenderer
{
    return _backgroundRendererInterface;
}
- (void)dealloc
{
    [_backgroundRendererInterface release];
    [super dealloc];
}
@end
