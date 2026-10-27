#import "HyperPlayerBasePrefix.h"


@interface HSMediaStripAnimation : NSAnimation
{
    id<HSMediaStripAnimationDataSource> _dataSource;
}
- (id)runLoopModesForAnimating;
- (void)setCurrentProgress:(CGFloat)aProgress;
- (id)initWithDataSource:(id)aSource duration:(double)aDuration;
@end

