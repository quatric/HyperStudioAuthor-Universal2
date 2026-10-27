#import "HyperPlayerBasePrefix.h"
#import "HSObject.h"


@interface HSActionQueue : HSObject
{
    HSActionEvent *_actionEvent;
    HSActor *_actor;
    NSMutableArray *_groups;
    HSActionExecutionContext *_context;
    HSActionSynchronizer *_actionSynchronizer;
    BOOL _shouldDecreaseContextLimitedMode;
}
+ (id)actionsOrderDictionary;
- (void)decreaseContextLimitedModeIfNeeded;
- (void)increaseContextLimitedModeIfNeeded;
- (BOOL)shuldIncreaseContextLimitedModeCounter;
- (id)orderForSourceAction:(id)aAction destinationAction:(id)aAction2;
- (id)allTypesForAction:(id)aAction;
- (id)actionEvent;
- (void)removeActionGroup:(id)aGroup;
- (void)addActionGroup:(id)aGroup;
- (void)insertActionGroup:(id)aGroup atIndex:(NSInteger)aIndex;
- (id)actionGroups;
- (id)mutableGroups;
- (void)invalidateContext;
- (void)invalidateSynchronizer;
- (void)stop:(id)aStop;
- (void)actionSynchronizer:(id)aSynchronizer didFinishAction:(id)aAction;
- (void)actionSynchronizerDidFinishPerformActions:(id)aActions;
- (void)readyToStartSynchronizerAfterDelay:(id)aDelay;
- (void)startInContext:(id)aContext;
- (void)startSynchronizer;
- (BOOL)isRunning;
- (BOOL)isEmpty;
- (id)actor;
- (void)dealloc;
- (void)HSActionQueue_addSynchronousGroupWithAction:(id)aAction callingObject:(id)aObject;
- (id)initWithActionEvent:(id)aEvent andActor:(id)aActor callingObject:(id)aObject;
- (id)init;
@end

