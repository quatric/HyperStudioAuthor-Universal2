#import "HyperPlayerBasePrefix.h"


@interface HSAnimationPositioning : NSObject
{
    id<HSAnimationPositioningDataSource> _dataSource;
    HSAnimationFixation *_fixation;
}
+ (void)setPosition:(NSPoint)aPosition ofObject:(id)aObject;
+ (NSPoint)positionOfObject:(id)aObject;
- (void)updateObjectPosition;
- (void)updateObjectAttributes;
- (double)pathTime;
- (id)structure;
- (id)object;
- (void)replaceFixationWith:(id)aWith;
- (id)fixation;
- (NSPoint)objectPositionAtZeroTime;
- (void)setObjectPosition:(NSPoint)aPosition;
- (NSPoint)objectPosition;
- (void)updateObject;
- (void)updateFixation;
- (void)setDataSource:(id)aSource;
- (id)dataSource;
- (void)dealloc;
- (id)init;
@end

