#import "HSTextObjectFrameResizeSelectionTracker.h"

@implementation HSTextObjectFrameResizeSelectionTracker

// Dragging a side fixes that dimension (left/right: width, top/bottom: height).
- (void)willResizeCardObject
{
    id sizing = [[self trackingObject] queryHyperInterface:@protocol(HSTextObjectSizingAttributes)];
    if ([self modifyingEdges] & 5)
        [sizing setHyperWidthSetByUser:YES];
    if ([self modifyingEdges] & 10)
        [sizing setHyperHeightSetByUser:YES];
}

@end
