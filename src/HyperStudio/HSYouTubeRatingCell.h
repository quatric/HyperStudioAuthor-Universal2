#import "HyperStudioPrefix.h"


@interface HSYouTubeRatingCell : NSCell
{
    HSRatingCell *_ratingCell;
}
- (id)raitingCell;
- (id)copyWithZone:(NSZone *)aZone;
- (void)drawWithFrame:(NSRect)aFrame inView:(id)aView;
- (void)drawInteriorWithFrame:(NSRect)aFrame inView:(id)aView;
- (void)dealloc;
@end

