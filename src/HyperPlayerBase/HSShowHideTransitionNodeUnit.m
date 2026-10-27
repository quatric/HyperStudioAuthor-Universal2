#import "HSShowHideTransitionNodeUnit.h"
// The transition that shows or hides an object: setting one plays it (its
// player's frames update the transition time attribute), and it's cleared
// when it finishes.
@implementation HSShowHideTransitionNodeUnit
- (id)description
{
    id transition = [self transition];
    return [NSString stringWithFormat:@"%@ - %@", [super description], transition != nil ? transition : @"nil"];
}
- (void)transitionPlayerDidFinish:(id)aFinish
{
    if (_transitionPlayer == aFinish) {
        [_transitionPlayer setTransitionEffect:nil];
        [self notifyChange:0x80 ofAttribute:@protocol(HSShowHideTransitionFrameAttribute) withUserInfo:nil];
        [self notifyChange:1 ofAttribute:@protocol(HSShowHideTransitionAttribute) withUserInfo:nil];
        [_transition release];
        _transition = nil;
        [self notifyChange:2 ofAttribute:@protocol(HSShowHideTransitionAttribute) withUserInfo:nil];
    }
    [super transitionPlayerDidFinish:aFinish];
}
- (void)transitionPlayerDidPlayNewFrame:(id)aFrame
{
    if (_transitionPlayer == aFrame) {
        [self notifyChange:1 ofAttribute:@protocol(HSShowHideTransitionFrameAttribute) withUserInfo:nil];
        _transitionTime = [_transitionPlayer transitionTime];
        [self notifyChange:2 ofAttribute:@protocol(HSShowHideTransitionFrameAttribute) withUserInfo:nil];
    }
    [super transitionPlayerDidPlayNewFrame:aFrame];
}
- (double)transitionTime
{
    return _transitionTime;
}
// The player is created on first use. Clearing the transition while it plays
// jumps to its end and stops it (0x80: the frames ended). A new transition
// starts playing (0x40: frames begin) unless the player is busy; if it can't
// start, the transition is cleared again.
- (void)setTransition:(id)aTransition
{
    if (_transition == aTransition)
        return;
    if (_transitionPlayer == nil) {
        _transitionPlayer = [[HSTransitionPlayer alloc] init];
        if (_transitionPlayer == nil)
            return;
        [_transitionPlayer setDelegate:self];
    } else if (aTransition == nil) {
        if ([_transitionPlayer isPlaying]) {
            [_transitionPlayer setTransitionTime:1.0];
            if ([_transitionPlayer isPlaying])
                [_transitionPlayer stop];
            [_transitionPlayer setTransitionEffect:nil];
        }
        [self notifyChange:0x80 ofAttribute:@protocol(HSShowHideTransitionFrameAttribute) withUserInfo:nil];
    }
    [self notifyChange:1 ofAttribute:@protocol(HSShowHideTransitionAttribute) withUserInfo:nil];
    [_transition release];
    _transition = [aTransition retain];
    [self notifyChange:2 ofAttribute:@protocol(HSShowHideTransitionAttribute) withUserInfo:nil];
    if (_transition == nil || [_transitionPlayer isPlaying])
        return;
    [_transitionPlayer setTransitionEffect:[_transition effect]];
    [_transitionPlayer setDuration:[_transition duration]];
    if (![_transitionPlayer start]) {
        [_transitionPlayer setTransitionEffect:nil];
        [self notifyChange:1 ofAttribute:@protocol(HSShowHideTransitionAttribute) withUserInfo:nil];
        [_transition release];
        _transition = nil;
        [self notifyChange:2 ofAttribute:@protocol(HSShowHideTransitionAttribute) withUserInfo:nil];
    } else {
        [self notifyChange:0x40 ofAttribute:@protocol(HSShowHideTransitionFrameAttribute) withUserInfo:nil];
        [self notifyChange:1 ofAttribute:@protocol(HSShowHideTransitionFrameAttribute) withUserInfo:nil];
        _transitionTime = 0;
        [self notifyChange:2 ofAttribute:@protocol(HSShowHideTransitionFrameAttribute) withUserInfo:nil];
    }
}
- (id)transition
{
    return _transition;
}
- (Class)hyperImplementationClassForHyperInterface:(id)aInterface
{
    if (HSProtocolsAreEqual(@protocol(HSShowHideTransitionAttributes), aInterface)
        || HSProtocolsAreEqual(@protocol(HSMutableShowHideTransitionAttributes), aInterface))
        return [HSShowHideTransitionAttributesImplementation class];
    return Nil;
}
- (BOOL)implementsHyperInterface:(id)aInterface
{
    return HSProtocolsAreEqual(@protocol(HSShowHideTransitionAttributes), aInterface)
        || HSProtocolsAreEqual(@protocol(HSMutableShowHideTransitionAttributes), aInterface);
}
- (id)implementedHyperInterfaces
{
    return [NSSet setWithObjects:[HSProtocolIdentifier identifierForProtocol:@protocol(HSShowHideTransitionAttributes)],
                                 [HSProtocolIdentifier identifierForProtocol:@protocol(HSMutableShowHideTransitionAttributes)], nil];
}
- (id)attributes
{
    return [NSEProtocolSet protocolSetWithProtocols:@protocol(HSShowHideTransitionAttribute), @protocol(HSShowHideTransitionFrameAttribute), nil];
}
- (void)dealloc
{
    [_transitionPlayer setDelegate:nil];
    [_transitionPlayer release];
    [_transition release];
    [super dealloc];
}
- (void)pauseTransition
{
    [_transitionPlayer pause];
}

- (void)resumeTransition
{
    [_transitionPlayer resume];
}

@end
