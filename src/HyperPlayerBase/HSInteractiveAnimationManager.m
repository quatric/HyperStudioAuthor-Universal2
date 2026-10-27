#import "HSInteractiveAnimationManager.h"
#import "HSMovingCardObjectAnimation.h"
// Singleton tracking the interactive animations being played, keyed by
// the animated object's UID string.

static HSInteractiveAnimationManager *HSInteractiveAnimationManagerShared = nil;

@implementation HSInteractiveAnimationManager

+ (id)allocWithZone:(NSZone *)aZone
{
    @synchronized(self) {
        if (!HSInteractiveAnimationManagerShared)
            HSInteractiveAnimationManagerShared = [super allocWithZone:aZone];
    }
    return HSInteractiveAnimationManagerShared;
}

+ (id)sharedAnimationManager
{
    @synchronized(self) {
        if (!HSInteractiveAnimationManagerShared)
            [[self alloc] init];
    }
    return HSInteractiveAnimationManagerShared;
}

- (void)animationDidFinishForAnimatedObject:(id)aObject
{
    [[self currentlyPlayingAnimations] removeObjectForKey:[[aObject hyperUID] stringValue]];
}

- (id)animationForAnimatedObject:(id)aObject
{
    return [[self currentlyPlayingAnimations] objectForKey:[[aObject hyperUID] stringValue]];
}

- (BOOL)hasCurrentlyPlayedAnimations
{
    return [[self currentlyPlayingAnimations] count] != 0;
}

- (BOOL)hasCurrentlyPlayedAnimationForObject:(id)aObject
{
    return [[self currentlyPlayingAnimations] objectForKey:[[aObject hyperUID] stringValue]] != nil;
}

- (void)stopAnimationForAnimatedObject:(id)aObject
{
    [(HSMovingCardObjectAnimation *)[[self currentlyPlayingAnimations] objectForKey:[[aObject hyperUID] stringValue]] stop];
}

- (void)stopAllRunningAnimations
{
    [[[self currentlyPlayingAnimations] allValues] makeObjectsPerformSelector:@selector(stop)];
}

- (void)startAnimation:(id)aAnimation forAnimatedObject:(id)aObject
{
    [[self currentlyPlayingAnimations] setObject:aAnimation forKey:[[aObject hyperUID] stringValue]];
    HSMovingCardObjectAnimation *animation = aAnimation;
    [animation setAnimatedObject:aObject];
    [animation setOwner:self];
    [animation start];
}

- (id)currentlyPlayingAnimations
{
    if (!_currentlyPlayingAnimations)
        _currentlyPlayingAnimations = [[NSMutableDictionary alloc] init];
    return _currentlyPlayingAnimations;
}

- (void)dealloc
{
    [_currentlyPlayingAnimations release];
    [super dealloc];
}

- (id)autorelease
{
    return self;
}

- (void)release
{
}

- (NSUInteger)retainCount
{
    return NSUIntegerMax;
}

- (id)retain
{
    return self;
}

- (id)copyWithZone:(NSZone *)aZone
{
    return self;
}

@end
