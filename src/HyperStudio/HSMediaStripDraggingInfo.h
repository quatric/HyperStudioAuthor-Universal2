#import "HyperStudioPrefix.h"


@interface HSMediaStripDraggingInfo : NSObject
{
    unsigned int _dropIndex;
    unsigned int _dropOperation;
}
- (void)setDropOperation:(NSUInteger)aOperation;
- (NSUInteger)dropOperation;
- (void)setDropIndex:(NSUInteger)aIndex;
- (NSUInteger)dropIndex;
@end

