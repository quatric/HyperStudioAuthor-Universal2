#import "HSAnimationFixation.h"
@implementation HSAnimationFixation
- (id)copyWithZone:(NSZone *)aZone
{
    HSAnimationFixation *copy = [[[self class] allocWithZone:aZone] init];
    [copy setObjectPositionAtZeroTime:[self objectPositionAtZeroTime]];
    return copy;
}
- (void)setObjectPositionAtZeroTime:(NSPoint)aTime
{
    _objectPositionAtZeroTime = aTime;
}
- (NSPoint)objectPositionAtZeroTime
{
    return _objectPositionAtZeroTime;
}
- (id)init
{
    self = [super init];
    if (self != nil)
        _objectPositionAtZeroTime = NSZeroPoint;
    return self;
}
@end
