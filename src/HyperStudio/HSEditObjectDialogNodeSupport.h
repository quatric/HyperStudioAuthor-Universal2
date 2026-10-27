#import "HyperStudioPrefix.h"


@interface HSEditObjectDialogNodeSupport : HSGenericNodeSupport
{
    id _originalObject;
    NSUndoManager *_undoManager;
}
- (id)hyperUID;
- (id)childInTreeWithUID:(id)aUID;
- (id)childWithUID:(id)aUID;
- (id)uniqueNameGenerator;
- (id)document;
- (id)stack;
- (id)card;
- (id)cardGroupController;
- (id)undoManager;
- (void)invalidateUndoManager;
- (void)createUndoManager;
- (id)cardForAction:(id)aAction ofObject:(id)aObject;
- (void)setOriginalObject:(id)aObject;
- (void)dealloc;
@end

