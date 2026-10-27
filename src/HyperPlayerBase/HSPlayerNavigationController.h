#import "HyperPlayerBasePrefix.h"
#import "HSNavigationController.h"


@interface HSPlayerNavigationController : HSNavigationController <HSPresentationSyncDataSource, HSPresentationSyncDelegate>
{
    HSPresentationSync *_presentationSync;
    BOOL _goOnTheSameCard;
}
- (void)readyToPerformNavigationOperation:(id)aOperation;
- (void)readyToPerformGoToCard:(id)aCard;
- (void)readyToPerformGoToStack:(id)aStack;
- (id)actionExecutionContextForPresentationSync:(id)aSync;
- (id)actionExecutionManagerForPresentationSync:(id)aSync;
- (id)currentCardForPresentationSync:(id)aSync;
- (id)currentStackForPresentationSync:(id)aSync;
- (void)finishNavigationOperation:(id)aOperation;
- (void)continueNavigationOperation:(id)aOperation;
- (id)destinationCardInStack:(id)aStack fromNavigationOperation:(id)aOperation;
- (void)startNavigationOperation:(id)aOperation;
- (void)goToHome:(id)aHome;
- (void)willBeClosedWithDocument;
- (id)presentationSync;
- (void)document:(id)aDocument shouldClose:(BOOL)aClose contextInfo:(void *)aInfo;
- (void)cancelNavigationOperationForSameStack:(id)aStack;
- (void)dealloc;
@end

