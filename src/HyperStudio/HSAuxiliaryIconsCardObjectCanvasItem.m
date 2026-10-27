#import "HSAuxiliaryIconsCardObjectCanvasItem.h"

@implementation HSAuxiliaryIconsCardObjectCanvasItem

- (CGAffineTransform)transformForTraitRectsInView:(id)aView
{
    id<HSGeometryAttributes> geometry = [[self userObject] queryHyperInterface:@protocol(HSGeometryAttributes)];
    if (geometry == nil || aView == nil)
        return CGAffineTransformIdentity;
    return CGAffineTransformConcat([geometry affineTransform], [aView userSpaceToViewSpaceCGAffineTransform]);
}

- (NSRect)boundsForTraitRectsInView:(id)aView
{
    id<HSSizeAttributes> attributes = [[self userObject] queryHyperInterface:@protocol(HSSizeAttributes)];
    NSRect bounds = NSZeroRect;
    if (attributes != nil)
        bounds.size = [attributes size];
    return bounds;
}

@end
