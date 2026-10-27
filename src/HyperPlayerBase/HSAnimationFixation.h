#import "HyperPlayerBasePrefix.h"


@interface HSAnimationFixation : NSObject <NSCopying>
{
    NSPoint _objectPositionAtZeroTime;
}
- (id)copyWithZone:(NSZone *)aZone;
- (void)setObjectPositionAtZeroTime:(NSPoint)aTime;
- (NSPoint)objectPositionAtZeroTime;
- (id)init;
@end

