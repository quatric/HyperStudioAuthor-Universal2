#import "HSMediaStripDraggingInfo.h"

@implementation HSMediaStripDraggingInfo

- (void)setDropOperation:(NSUInteger)aOperation
{
    if (_dropOperation != aOperation)
        _dropOperation = (unsigned int)aOperation;
}

- (NSUInteger)dropOperation
{
    return _dropOperation;
}

- (void)setDropIndex:(NSUInteger)aIndex
{
    if (_dropIndex != aIndex)
        _dropIndex = (unsigned int)aIndex;
}

- (NSUInteger)dropIndex
{
    return _dropIndex;
}

@end
