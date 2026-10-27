#import "HyperPlayerBasePrefix.h"


@interface HSInteractiveAnimationManager : NSObject <HSInteractiveAnimationOwner, NSObject>
{
    NSMutableDictionary *_currentlyPlayingAnimations;
}
+ (id)allocWithZone:(NSZone *)aZone;
+ (id)sharedAnimationManager;
- (void)animationDidFinishForAnimatedObject:(id)aObject;
- (id)animationForAnimatedObject:(id)aObject;
- (BOOL)hasCurrentlyPlayedAnimations;
- (BOOL)hasCurrentlyPlayedAnimationForObject:(id)aObject;
- (void)stopAnimationForAnimatedObject:(id)aObject;
- (void)stopAllRunningAnimations;
- (void)startAnimation:(id)aAnimation forAnimatedObject:(id)aObject;
- (id)currentlyPlayingAnimations;
- (void)dealloc;
- (id)autorelease;
- (void)release;
- (NSUInteger)retainCount;
- (id)retain;
- (id)copyWithZone:(NSZone *)aZone;
@end

