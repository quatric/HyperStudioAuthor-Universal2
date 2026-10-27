#import "HyperPlayerBasePrefix.h"


@interface HSFlickAnimation : NSAnimation
{
    NSArray *_objects;
    NSPoint *_startPoints;
    NSSize *_destinationDeltas;
    float _velocity;
}
- (id)runLoopModesForAnimating;
- (void)setCurrentProgress:(CGFloat)aProgress;
- (void)prepareToStartAnimationInDirection:(NSSize)aDirection;
- (void)dealloc;
- (id)initWithObjects:(id)aObjects velocity:(CGFloat)aVelocity direction:(NSSize)aDirection;
- (id)init;
@end

