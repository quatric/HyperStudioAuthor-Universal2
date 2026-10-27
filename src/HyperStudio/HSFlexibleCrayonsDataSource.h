#import "HyperStudioPrefix.h"


@interface HSFlexibleCrayonsDataSource : NSObject
{
}
- (id)crayonsView:(id)aView colorForRow:(NSInteger)aRow column:(NSInteger)aColumn;
- (BOOL)managesRowsAndColumnsCountForCrayonsView:(id)aView;
@end

