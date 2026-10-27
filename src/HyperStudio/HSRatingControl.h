#import "HyperStudioPrefix.h"


@interface HSRatingControl : NSControl
{
}
+ (Class)cellClass;
- (void)setPointCount:(NSUInteger)aCount;
- (NSUInteger)pointsCount;
- (void)setRating:(CGFloat)aRating;
- (CGFloat)rating;
- (id)pointDimmedImage;
- (void)setPointDimmedImage:(id)aImage;
- (id)pointImage;
- (void)setPointImage:(id)aImage;
@end

