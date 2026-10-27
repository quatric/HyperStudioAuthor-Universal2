#import "HyperStudioPrefix.h"


@interface KeynoteBezierPathsBuilder : NSObject
{
}
+ (id)starPathWithNumberOfCorners:(NSInteger)aCorners inscribedToCircumscribedCirclesRatio:(CGFloat)aRatio size:(NSSize)aSize;
+ (id)polygonPathWithNumberOfCorners:(NSInteger)aCorners size:(NSSize)aSize;
+ (id)doubleArrowPathWithFlippedControlPointX:(CGFloat)aX controlPointVerticalOffsetToPathHeightRatio:(CGFloat)aRatio size:(NSSize)aSize;
+ (id)rightArrowPathWithFlippedControlPointX:(CGFloat)aX controlPointVerticalOffsetToPathHeightRatio:(CGFloat)aRatio size:(NSSize)aSize;
+ (id)roundedRectPathWithScalar:(NSInteger)aScalar size:(NSSize)aSize;
@end

