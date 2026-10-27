#import "HyperPlayerBasePrefix.h"


@interface HSAutomaticTimerActionsExecutionManager : NSObject
{
    struct __CFDictionary *_objectToArriveTimerMap;
    struct __CFDictionary *_objectToTimerMap;
    NSMutableSet *_actionQueuesToStopIfNeeded;
    unsigned int _isAutomaticTimerActionsForCardRunning:1;
    unsigned int _isAutomaticTimerActionsForStackRunning:1;
    unsigned int _isPaused:1;
}
- (void)actionQueueDidStop:(id)aStop;
- (void)actionQueue:(id)aQueue didSetupDelayTimer:(id)aTimer;
- (void)HSAutomaticTimerActionsExecutionManager_automaticTimerFired:(id)aFired;
- (void)HSAutomaticTimerActionsExecutionManager_objectVisibilityDidChange:(id)aChange;
- (BOOL)isAutomaticTimerActionsForStackRunning;
- (BOOL)isAutomaticTimerActionsForCardRunning;
- (BOOL)isRunningAutomaticTimer;
- (void)resumeAutomaticTimer;
- (void)pauseAutomaticTimer;
- (void)stopAllAutomaticActionTimers;
- (void)stopAllAutomaticActionTimersForAllCards;
- (void)stopAllAutomaticActionTimersForCard:(id)aCard;
- (void)runAutomaticTimerActionsForStack:(id)aStack withContext:(id)aContext actionEvent:(id)aEvent;
- (void)runAutomaticActionTimersForCard:(id)aCard withContext:(id)aContext actionEvent:(id)aEvent;
- (void)startAutomaticTimerActionsForObject:(id)aObject withContext:(id)aContext delay:(double)aDelay actionEvent:(id)aEvent;
- (void)startAutomaticTimerActionsForObject:(id)aObject withContext:(id)aContext delay:(double)aDelay actionEvent:(id)aEvent requestor:(id)aRequestor;
- (id)HSAutomaticTimerActionsExecutionManager_automaticTimerForObject:(id)aObject actionEvent:(id)aEvent inContext:(id)aContext paused:(BOOL)aPaused withDelay:(double)aDelay requestor:(id)aRequestor;
- (void)dealloc;
@end

@interface __HSAutomaticTimerInfo : NSObject
{
    id<HSNodeChild> _object;
    HSActionEvent *_actionEvent;
    HSActionExecutionContext *_actionExecutionContext;
    id _requestor;
    double _timeLeft;
    double _timeLeftAfterResume;
    BOOL _isBusy;
    BOOL _isRepeats;
}
- (void)__HSAutomaticTimer_actionsForObjectDidFinish:(id)aFinish;
- (void)runActionsIfNeeded;
- (void)setRepeats:(BOOL)aRepeats;
- (BOOL)repeats;
- (void)setTimeLeftAfterResume:(double)aResume;
- (double)timeLeftAfterResume;
- (void)setTimeLeft:(double)aLeft;
- (double)timeLeft;
- (id)actionEvent;
- (id)object;
- (void)dealloc;
- (id)initWithObject:(id)aObject actionEvent:(id)aEvent executionContext:(id)aContext requestor:(id)aRequestor;
- (id)init;
@end

