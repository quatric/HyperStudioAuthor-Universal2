#import "HSRatingControl.h"

@implementation HSRatingControl

+ (Class)cellClass
{
    return [HSRatingCell class];
}

- (void)setPointCount:(NSUInteger)aCount
{
    [[self cell] setPointsCount:aCount];
}

- (NSUInteger)pointsCount
{
    return [[self cell] pointsCount];
}

- (void)setRating:(CGFloat)aRating
{
    [[self cell] setRating:aRating];
}

- (CGFloat)rating
{
    return [[self cell] rating];
}

- (id)pointDimmedImage
{
    return [[self cell] pointDimmedImage];
}

- (void)setPointDimmedImage:(id)aImage
{
    [[self cell] setPointDimmedImage:aImage];
}

- (id)pointImage
{
    return [[self cell] pointImage];
}

- (void)setPointImage:(id)aImage
{
    [[self cell] setPointImage:aImage];
}

@end
