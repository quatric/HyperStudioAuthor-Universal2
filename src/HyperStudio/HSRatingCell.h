#import "HyperStudioPrefix.h"


@interface HSRatingCell : NSCell
{
    NSImage *_pointDimmedImage;
    NSImage *_pointImage;
    unsigned int _pointsCount;
    float _rating;
}
- (void)setPointsCount:(NSUInteger)aCount;
- (NSUInteger)pointsCount;
- (void)setRating:(CGFloat)aRating;
- (CGFloat)rating;
- (id)pointDimmedImage;
- (void)setPointDimmedImage:(id)aImage;
- (id)pointImage;
- (void)setPointImage:(id)aImage;
- (id)copyWithZone:(NSZone *)aZone;
- (void)drawWithFrame:(NSRect)aFrame inView:(id)aView;
- (void)drawInteriorWithFrame:(NSRect)aFrame inView:(id)aView;
- (void)dealloc;
- (id)init;
@end

