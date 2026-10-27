#import "HyperPlayerBasePrefix.h"


@interface HSEditModeUndoHelper : NSObject
{
    NSDocument *_document;
    NSUndoManager *_documentUndoManager;
    NSUndoManager *_editModeUndoManager;
    id<HSEditModeUndoHelperDelegate> _delegate;
    BOOL _isChagingDocument;
}
- (void)documentDidRemoveAllActions:(id)aActions;
- (void)documentUndoManagerWillRegisterUndo:(id)aUndo;
- (void)finishDuplicating:(BOOL)aDuplicating;
- (void)documentDidRegisterUndo;
- (void)forwardUndoActionToDocument;
- (void)dummyAction;
- (void)duplicateAction;
- (void)dealloc;
- (id)initWithDocument:(id)aDocument documentUndoManager:(id)aManager editModeUndoManager:(id)aManager2 delegate:(id)aDelegate;
@end

