#import "HyperPlayerBasePrefix.h"


@interface HSSystemViewManager : NSObject
{
    id _synchronizedSystemView;
    NSSet *_duplicateSystemViews;
    id _delegate;
}
+ (id)duplicateObject:(id)aObject withSubstituteClasses:(id)aClasses;
- (void)removeDuplicateHyperSystemView:(id)aView;
- (id)addDuplicateHyperSystemView;
- (id)systemViewForSetAccessor;
- (id)systemViewForGetAccessor;
- (id)hyperSystemView;
- (id)systemViewCreateIfNeeded:(BOOL)aNeeded;
- (void)setDelegate:(id)aDelegate;
- (id)delegate;
- (void)dealloc;
@end

