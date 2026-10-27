#import "HyperPlayerBasePrefix.h"


@interface HSStoryboardAnimation : NSAnimation
{
    HSStoryboardItemsCache *_items;
}
- (id)runLoopModesForAnimating;
- (void)setCurrentProgress:(CGFloat)aProgress;
- (void)setItems:(id)aItems;
- (void)dealloc;
- (id)initWithItems:(id)aItems duration:(double)aDuration;
@end

