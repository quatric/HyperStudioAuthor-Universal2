#import "HyperPlayerBasePrefix.h"
#import "HSCard.h"


@interface HSAnimationController : NSObject
{
    id<HSAnimationControllerOwner, HSNodeAttributes> _owner;
    struct __CFDictionary *_playingAnimations;
    NSMutableDictionary *_preparedObjects;
    NSMutableDictionary *_finishedObjects;
    int _continiousActionsStartingCount;
    NSMutableArray *_pausedAnimations;
    NSMutableSet *_temporaryAnimationsObjects;
    unsigned int _bottomAnimationsCountOnAbsoluteLayerTop;
    unsigned int _bottomAnimationsCountOnAbsoluteLayerBottom;
}
- (void)removeAllTemporaryButAnimationsObjects;
- (void)removeAllTemporaryObjects;
- (void)removeTemporaryObjects:(id)aObjects;
- (void)animationDirectionDidChange:(id)aChange;
- (void)animationPlaybackDidEnd:(id)aEnd;
- (void)changeObjectIndexOnStartingAnimation:(id)aAnimation inAbsoluteLayer:(NSInteger)aLayer forActingObject:(id)aObject;
- (NSUInteger)indexForObjectReplacementForAnimation:(id)aAnimation inAbsoluteLayer:(NSInteger)aLayer forActingObject:(id)aObject;
- (NSUInteger)indexForObjectInsertionForAnimation:(id)aAnimation inAbsoluteLayer:(NSInteger)aLayer forActingObject:(id)aObject;
- (void)addAnimatedObject:(id)aObject toCardForAnimation:(id)aAnimation forActingObject:(id)aObject2;
- (void)addAnimatedObject:(id)aObject toCardForAnimation:(id)aAnimation atIndex:(NSInteger)aIndex;
- (BOOL)isPlayingAnimationWithUID:(id)aUID;
- (id)playingAnimationAnimatingObject:(id)aObject;
- (id)playingAnimations;
- (void)resumeAllPlayingAnimations;
- (void)pauseAllPlayingAnimations;
- (void)stopAllPlayingAnimations;
- (void)stopAnimation:(id)aAnimation;
- (id)startAnimationWithoutCopyingAnimatedObject:(id)aObject;
- (id)prepareToStartAnimation:(id)aAnimation forActingObject:(id)aObject;
- (id)startAnimation:(id)aAnimation forActingObject:(id)aObject;
- (void)endContiniousPlayAnimationActionsStarting;
- (void)beginContiniousPlayAnimationActionsStarting;
- (BOOL)isInContiniousPlayAnimationActionsStarting;
- (void)cleanUpAfterTryIt;
- (void)prepareForTryItAnimation:(id)aAnimation;
- (void)presentationIsStarting;
- (void)addAllShowFirstFrameAnimatedObjectsToCard:(BOOL)aCard toPreparedObjects:(BOOL)aObjects playLiveVideo:(BOOL)aVideo;
- (id)temporaryAnimationsObjects;
- (void)setOwner:(id)aOwner;
- (id)owner;
- (void)dealloc;
- (id)init;
@end

@interface HSCard (HSAnimationControllerOwner)
- (id)undoManagerForAnimationController:(id)aController;
- (id)allPlayAnimationActionsForAnimationController:(id)aController;
- (void)removeTemporaryObjects:(id)aObjects;
- (void)removeAllTemporaryObjectsForAnimationController:(id)aController exceptObjects:(id)aObjects;
- (void)animationController:(id)aController moveObject:(id)aObject toIndex:(NSUInteger)aIndex;
- (void)animationController:(id)aController removeObject:(id)aObject;
- (void)animationController:(id)aController addTemporaryObject:(id)aObject atIndex:(NSUInteger)aIndex;
- (NSRange)rangeOfTemporaryObjectsBelowForAnimationController:(id)aController;
- (NSRange)rangeOfTemporaryObjectsOverForAnimationController:(id)aController;
- (NSRange)rangeOfTemporaryObjectsOverActingObject:(id)aObject forAnimationController:(id)aController;
- (BOOL)isAnimatedObject:(id)aObject;
- (NSUInteger)indexOfObject:(id)aObject forAnimationController:(id)aController;
- (NSUInteger)objectCountForAnimationController:(id)aController;
@end

