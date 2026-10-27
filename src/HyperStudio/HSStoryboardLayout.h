#import "HyperStudioPrefix.h"


@interface HSStoryboardLayout : NSObject <NSAnimationDelegate, NSObject>
{
    HSStoryboardItemsCache *_items;
    HSStoryboardCell *_cell;
    NSAnimation *_animation;
    id _delegate;
}
- (void)animationDidEnd:(id)aEnd;
- (void)animationDidStop:(id)aStop;
- (void)invalidateLayoutWithAnimation:(BOOL)aAnimation;
- (void)invalidateLayout;
- (NSUInteger)itemIndexAtPoint:(NSPoint)aPoint;
- (NSRect)frameForItemAtIndex:(NSInteger)aIndex;
- (id)newAnimation;
- (void)setCell:(id)aCell;
- (void)setItems:(id)aItems;
- (void)dealloc;
- (id)initWithItems:(id)aItems cell:(id)aCell delegate:(id)aDelegate;
@end

