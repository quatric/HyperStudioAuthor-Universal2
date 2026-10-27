#import "HSDocumentUndoWorkaround.h"
@implementation HSDocumentUndoWorkaround
// Edit mode undo actions (registered on HSEditModeUndoHelper targets) are
// counted, so that when they're all removed the document's change count is
// taken back by as many changes.
- (void)undoManagerDidRemoveAllActionsForTarget:(id)aTarget
{
    id target = [[aTarget userInfo] valueForKey:HSUndoManagerTargetForActionKey];
    if (![target isKindOfClass:[HSEditModeUndoHelper class]])
        return;
    NSInteger count = [_targets countForObject:target];
    for (NSInteger i = 0; i < count; i++) {
        [self updateChangeCount:NSChangeUndone];
        [_targets removeObject:target];
    }
}
- (void)undoManagerDidRegisterUndo:(id)aUndo
{
    id target = [[aUndo userInfo] valueForKey:HSUndoManagerTargetForActionKey];
    if (![target isKindOfClass:[HSEditModeUndoHelper class]])
        return;
    if ([[self undoManager] isUndoing])
        [_targets removeObject:target];
    else
        [[self targets] addObject:target];
}
- (id)targets
{
    if (_targets == nil)
        _targets = [NSCountedSet new];
    return _targets;
}
- (void)setUndoManager:(id)aManager
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self name:HSUndoManagerDidRegisterUndoActionNotification object:nil];
    [center removeObserver:self name:HSUndoManagerDidRemoveAllActionsForTargetNotification object:nil];
    [super setUndoManager:aManager];
    if (aManager != nil) {
        [center addObserver:self selector:@selector(undoManagerDidRegisterUndo:)
                       name:HSUndoManagerDidRegisterUndoActionNotification object:aManager];
        [center addObserver:self selector:@selector(undoManagerDidRemoveAllActionsForTarget:)
                       name:HSUndoManagerDidRemoveAllActionsForTargetNotification object:aManager];
    }
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_targets release];
    [super dealloc];
}
@end
