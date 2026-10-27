#import "HSInteractiveFlatObject.h"
@implementation HSInteractiveFlatObject
- (BOOL)hitTestPoint:(NSPoint)aPoint inCanvasLayer:(id)aLayer
{
    NSSize size;
    id<HSSizeAttributes> sizeAttributes = [[self node] queryHyperInterface:@protocol(HSSizeAttributes)];
    if (sizeAttributes != nil)
        size = [sizeAttributes size];
    else {
        id<HSStackAttributes> stackAttributes = [[self node] queryHyperInterface:@protocol(HSStackAttributes)];
        size = stackAttributes != nil ? [stackAttributes hyperCardSize] : NSZeroSize;
    }
    NSRect rect = {NSZeroPoint, size};
    if (NSIsEmptyRect(rect))
        return NO;
    NSRect viewRect = [(HSView *)[[aLayer context] renderingView] viewBoundingRectForUserRect:rect];
    return NSPointInRect(aPoint, viewRect);
}
@end
