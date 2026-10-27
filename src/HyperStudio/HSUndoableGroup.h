#import "HyperStudioPrefix.h"


@interface HSUndoableGroup : NSObject
{
    NSUndoManager *_internalUndoManager;
    NSUndoManager *_outerUndoManager;
    BOOL _isClosed;
    id<HSUndoableModelDelegate> _modelDelegate;
    NSString *_actionName;
    BOOL _cancelsEditingAfterLastUndoOperation;
}
+ (id)createOpenedWithModelDelegate:(id)aDelegate;
- (void)setActionName:(id)aName;
- (id)actionName;
- (void)transferActionsToOuterUndoManager;
- (void)undoLimitSentinel;
- (void)setCancelsEditingAfterLastUndoOperation:(BOOL)aOperation;
- (BOOL)cancelsEditingAfterLastUndoOperation;
- (void)setModelDelegate:(id)aDelegate;
- (id)modelDelegate;
- (BOOL)isOpened;
- (void)setOuterUndoManager:(id)aManager;
- (id)outerUndoManager;
- (void)setInternalUndoManager:(id)aManager;
- (id)internalUndoManager;
- (void)cancelChanges;
- (void)acceptChanges;
- (void)start:(id)aStart;
- (void)dealloc;
- (id)init;
- (id)initWithModelDelegate:(id)aDelegate;
@end

