#import "HSHitTestingVectorGraphicsObjectRenderLayer.h"
@implementation HSHitTestingVectorGraphicsObjectRenderLayer
- (void)drawBackground:(id)aBackground inRect:(NSRect)aRect
{
    // for hit testing a coloured background is just a filled rectangle
    if ([aBackground conformsToProtocol:@protocol(HSColor)]) {
        [(NSColor *)[self strokeColor] set];
        NSRectFillUsingOperation(aRect, NSCompositingOperationCopy);
    } else
        [super drawBackground:aBackground inRect:aRect];
}
- (id)strokeColor
{
    return [NSColor whiteColor];
}
@end
