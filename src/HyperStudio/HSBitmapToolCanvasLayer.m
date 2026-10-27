#import "HSBitmapToolCanvasLayer.h"

@implementation HSBitmapToolCanvasLayer

- (id)hitTestCanvasLayerAtPoint:(NSPoint)aPoint insideView:(BOOL)aView clickCount:(NSUInteger)aCount modifierFlags:(NSUInteger)aFlags hitTestInfo:(id *)aInfo
{
    return aView ? self : nil;
}

- (void)renderRect:(NSRect)aRect
{
    [[[self tool] bitmapTool] drawRect:aRect ofActiveFeedbackLayersExcludingLayer:@"BTSelectionFeedbackLayer"];
}

- (void)setTool:(id)aTool
{
    [super setTool:aTool];
}

- (id)tool
{
    return [super tool];
}

@end
