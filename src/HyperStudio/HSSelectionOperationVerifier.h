#import "HyperStudioPrefix.h"


@interface HSSelectionOperationVerifier : NSObject
{
    id<HSNodeSelectionInterface> _selection;
}
- (BOOL)verifyCanPerformOperation:(id)aOperation onNodesInArray:(id *)aArray;
- (BOOL)verifyCanPerformOperation:(id)aOperation onNodesInArray:(id *)aArray proceedWithOperation:(BOOL *)aOperation2 neverAskUser:(BOOL)aUser;
- (BOOL)shouldUseUniqueMessageForOperation:(id)aOperation;
- (id)filteredUnlockedItemsInNodesArray:(id)aArray;
- (BOOL)hasLockedItemsInObject:(id)aObject multipleLockedItems:(BOOL *)aItems allLocked:(BOOL *)aLocked multipleObjects:(BOOL *)aObjects;
- (BOOL)displayAlertWithTitle:(id)aTitle message:(id)aMessage proceedButtonTitle:(id)aTitle2;
- (BOOL)displayAlertWithTitle:(id)aTitle message:(id)aMessage proceedButtonTitle:(id)aTitle2 skipLockedButtonTitle:(id)aTitle3 shouldSkipLocked:(BOOL *)aLocked;
- (BOOL)isOperationAllowedNoSelect:(id)aSelect;
- (id)selectedNodesArrayForRestoreOperation;
- (id)selectedNodesArrayForOrderOperation;
- (id)selectedNodesArrayForMergeOperation;
- (id)selectedNodesArrayForFlatOperation;
- (id)selectedNodesArrayForEditingOperationWithImplicitCheck:(BOOL)aCheck;
- (id)selectedNodesArrayForCutOperation;
- (id)selectedNodesArrayForDeleteOperation;
- (id)selectedNodesArrayForMoveOperation;
- (void)getSelectedNodesArrayForDragOperation:(id *)aOperation canProceed:(BOOL *)aProceed modifySelectionIfNeeded:(BOOL)aNeeded;
- (void)getSelectedNodesArrayForMoveOperation:(id *)aOperation canProceed:(BOOL *)aProceed modifySelectionIfNeeded:(BOOL)aNeeded;
- (BOOL)verifyCanSelectNodesInArray:(id *)aArray;
- (id)selectedNodesArrayForOperation:(id)aOperation;
- (id)selectedNodesArrayForOperation:(id)aOperation proceedWithOperation:(BOOL *)aOperation2 neverAskUser:(BOOL)aUser modifySelectionIfNeeded:(BOOL)aNeeded;
- (id)selection;
- (void)dealloc;
- (id)init;
- (id)initWithSelection:(id)aSelection;
@end

