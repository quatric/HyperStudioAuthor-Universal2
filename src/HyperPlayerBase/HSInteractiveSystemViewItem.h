#import "HyperPlayerBasePrefix.h"
#import "HSInteractiveViewItem.h"


@interface HSInteractiveSystemViewItem : HSInteractiveViewItem <HSInteractiveSystemViewItemInterface, HyperInterface, NSObject>
{
    id<HSSystemViewDuplicatingInterface> _systemViewInterface;
}
- (void)doCommandBySelector:(SEL)aSelector;
- (void)invalidateView;
- (id)createView;
- (void)dealloc;
@end

