#import "HSAuxiliaryIconsCardCanvasItem.h"

@implementation HSAuxiliaryIconsCardCanvasItem

- (CGAffineTransform)transformForTraitRectsInView:(id)aView
{
    if (aView == nil)
        return CGAffineTransformIdentity;
    return [aView userSpaceToViewSpaceCGAffineTransform];
}

- (NSRect)boundsForTraitRectsInView:(id)aView
{
    id<HSStackAttributes> stack = [[[self userObject] stack] queryHyperInterface:@protocol(HSStackAttributes)];
    NSRect bounds = NSZeroRect;
    if (stack != nil)
        bounds.size = [stack hyperCardSize];
    return bounds;
}

@end
