#import "HyperPlayerBasePrefix.h"
#import "HSObject.h"


@interface HSActionExecutionManager : HSObject
{
    NSMapTable *_objectsToEventsMap;
    NSMapTable *_objectsToRequestorsMap;
    BOOL _isLeaveActionsDisabled;
    HSAutomaticTimerActionsExecutionManager *_automaticTimerManager;
}
- (id)automaticTimerManager;
- (void)actionQueueDidFinish:(id)aFinish;
- (void)removeActionQueue:(id)aQueue;
- (void)notifyRequestor:(id)aRequestor actionsForObject:(id)aObject didFinishForEvent:(id)aEvent;
- (void)setLeaveActionsDisabled:(BOOL)aDisabled;
- (BOOL)isLeaveActionsDisabled;
- (BOOL)areAnyActionsRunningForEvent:(id)aEvent;
- (BOOL)areAnyActionsRunning;
- (void)stopAllActionQueues;
- (void)stopAllActionQueuesForStack:(id)aStack;
- (void)stopAllActionsQueuesForRequestor:(id)aRequestor;
- (void)stopAllActionQueuesExceptForObjectsInSet:(id)aSet;
- (void)runActionsForObject:(id)aObject withEvent:(id)aEvent inContext:(id)aContext forRequestor:(id)aRequestor;
- (id)requestorForObject:(id)aObject;
- (id)objectsToRequestorsMap;
- (id)objectsToEventsMap;
- (void)dealloc;
- (void)pauseAllActionQueues;
- (void)resumeAllActionQueues;
@end

