#import "HyperStudioPrefix.h"


@interface HSCoachingTextContainer : NSTextContainer
{
    NSRect _obstacleRect;
}
- (NSRect)lineFragmentRectForProposedRect:(NSRect)aRect sweepDirection:(NSUInteger)aDirection movementDirection:(NSUInteger)aDirection2 remainingRect:(NSRect *)aRect2;
- (void)setObstacleRect:(NSRect)aRect;
- (NSRect)obstacleRect;
@end

