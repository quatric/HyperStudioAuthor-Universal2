#import "HyperPlayerBasePrefix.h"
#import "HSObject.h"


@interface HSActionSynchronizer : HSObject
{
    NSArray *_actions;
    NSEnumerator *_actionsEnumerator;
    id _delegate;
    HSActionExecutionContext *_context;
    BOOL _waitingForSheet;
    NSMutableArray *_currentlyRunningActions;
    NSMutableArray *_actionsToStart;
}
- (void)sheetDidEnd:(id)aEnd;
- (void)waitForSheet;
- (BOOL)canRunNextAction;
- (void)setDelegate:(id)aDelegate;
- (id)delegate;
- (void)asynchronousActionDidFinish:(id)aFinish;
- (void)actionDidFinish:(id)aFinish;
- (void)removeActionFromCurrentlyRunningActions:(id)aActions;
- (void)stop:(id)aStop;
- (void)startInContext:(id)aContext;
- (void)runNextAction;
- (void)waitForCardNavigationToFinish;
- (void)presentationSyncDidFinishNavigation:(id)aNavigation;
- (BOOL)needsToWaitForCardNavigationToFinish;
- (void)finishRunningActions;
- (BOOL)isRunning;
- (id)notFinishedActions;
- (id)actionsToStart;
- (id)currentlyRunningActions;
- (void)dealloc;
- (id)initWithActions:(id)aActions;
- (id)init;
- (void)pause;
- (void)resume;
@end

