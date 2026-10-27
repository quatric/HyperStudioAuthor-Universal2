#import "HyperPlayerBasePrefix.h"


@interface HSDocumentUndoWorkaround : NSDocument
{
    NSCountedSet *_targets;
}
- (void)undoManagerDidRemoveAllActionsForTarget:(id)aTarget;
- (void)undoManagerDidRegisterUndo:(id)aUndo;
- (id)targets;
- (void)setUndoManager:(id)aManager;
- (void)dealloc;
- (id)supportedClasses;
@end

