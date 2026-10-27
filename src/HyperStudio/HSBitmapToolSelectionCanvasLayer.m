#import "HSBitmapToolSelectionCanvasLayer.h"

@implementation HSBitmapToolSelectionCanvasLayer

- (void)renderRect:(NSRect)aRect
{
    [[[self tool] bitmapTool] drawRect:aRect ofActiveFeedbackLayer:@"BTSelectionFeedbackLayer"];
}

- (void)setTool:(id)aTool
{
    _tool = aTool;
}

- (id)tool
{
    return _tool;
}

@end
