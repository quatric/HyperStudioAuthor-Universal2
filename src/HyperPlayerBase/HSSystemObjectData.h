#import "HyperPlayerBasePrefix.h"
#import "HSConcreteCardObjectData.h"


@interface HSSystemObjectData : HSConcreteCardObjectData
{
    HSSystemViewManager *_viewManager;
    id _systemView;
}
- (id)systemViewManager:(id)aManager viewCreateIfNeeded:(BOOL)aNeeded;
- (id)systemViewForSetAccessor;
- (id)systemViewForGetAccessor;
- (id)viewManager;
- (BOOL)wantsSystemView;
- (void)dealloc;
- (id)templateCocoaView;
@end

