#import "HyperPlayerBasePrefix.h"
#import "HSObject.h"


@interface HSPresentationSync : HSObject
{
    id<HSPresentationSyncDataSource> _dataSource;
    id<HSPresentationSyncDelegate> _delegate;
    BOOL _willGoToStack;
    BOOL _willGoToCard;
    BOOL _readyToPerformNavigationOperation;
    BOOL _isPerformingNavigationOperation;
    BOOL _performingLeavingActions;
    BOOL _documentIsClosing;
    id _closeDocumentContextData;
}
- (void)actionsForObject:(id)aObject didFinishForEvent:(id)aEvent inActionExecutionManager:(id)aManager;
- (void)endPresentation;
- (BOOL)isPerformingLeaveActions;
- (BOOL)isPerformingNavigationOperation;
- (void)navigationOperationCancelled;
- (void)navigationOperationCompleted;
- (void)runAutomaticTimersAndArrivingActions;
- (void)prepareForUserInitiatedNavigationOperation;
- (void)forceCloseDocument;
- (void)documentWillCloseWithDelegate:(id)aDelegate readyToCloseSelector:(SEL)aSelector contextInfo:(void *)aInfo;
- (BOOL)isDocumentClosing;
- (void)requestNavigationOperation;
- (void)willGoToStack;
- (void)willGoToCard;
- (void)didFinishNavigation;
- (void)didFinishArrivingCard:(id)aCard;
- (void)didArriveCard:(id)aCard;
- (void)willArriveCard:(id)aCard;
- (void)didLeaveCard:(id)aCard;
- (void)willLeaveCard:(id)aCard;
- (void)didArriveStack:(id)aStack;
- (void)willArriveStack:(id)aStack;
- (void)didLeaveStack:(id)aStack;
- (void)willLeaveStack:(id)aStack;
- (void)performPrimaryNodesSetupForCard:(id)aCard;
- (void)performPrimaryActionsSetupForStack;
- (void)performPrimaryActionsSetupForCard:(id)aCard;
- (void)performPrimaryActionsSetupForActor:(id)aActor;
- (void)setDataSource:(id)aSource;
- (id)dataSource;
- (void)setDelegate:(id)aDelegate;
- (id)delegate;
- (void)dealloc;
- (void)pause;
- (void)resume;
@end

@interface HSDocumentClosingInfo : NSObject
{
    id _closeDocumentDelegate;
    SEL _readyToCloseSelector;
    void *_closeDocumentContextInfo;
}
- (void *)closeDocumentContextInfo;
- (SEL)readyToCloseSelector;
- (id)closeDocumentDelegate;
- (id)initWithDelegate:(id)aDelegate readyToCloseSelector:(SEL)aSelector contextInfo:(void *)aInfo;
@end

