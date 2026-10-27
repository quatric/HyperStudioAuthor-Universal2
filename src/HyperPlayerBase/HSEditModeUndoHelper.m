#import "HSEditModeUndoHelper.h"
// Links an edit mode's own undo manager (text editing, say) to the
// document's: each edit-mode action is mirrored by a placeholder action in
// the document, so undoing or redoing either undoes or redoes the other.
@implementation HSEditModeUndoHelper
- (void)documentDidRemoveAllActions:(id)aActions
{
    [_delegate documentUndoManagerDidRemoveAllActions:self];
}
// Something else registered in the document.
- (void)documentUndoManagerWillRegisterUndo:(id)aUndo
{
    if ([[aUndo userInfo] valueForKey:HSUndoManagerTargetForActionKey] != self && !_isChagingDocument)
        [_delegate documentUndoManagerWillRegisterUndo:self];
}
- (void)finishDuplicating:(BOOL)aDuplicating
{
    _isChagingDocument = YES;
    if ([_documentUndoManager groupingLevel] > 0) {
        [_documentUndoManager endUndoGrouping];
        [_documentUndoManager removeAllActionsWithTarget:self];
        [_documentUndoManager beginUndoGrouping];
    } else
        [_documentUndoManager removeAllActionsWithTarget:self];
    _isChagingDocument = NO;
}
- (void)documentDidRegisterUndo
{
    [[_editModeUndoManager prepareWithInvocationTarget:self] forwardUndoActionToDocument];
}
// Registered in the edit mode's manager: undoes (or redoes) the document's
// placeholder as the edit mode's action is undone (or redone).
- (void)forwardUndoActionToDocument
{
    [_documentUndoManager setMultipleActionsNameEnabled:NO];
    _isChagingDocument = YES;
    [[_editModeUndoManager prepareWithInvocationTarget:self] forwardUndoActionToDocument];
    if ([_editModeUndoManager isUndoing])
        [_documentUndoManager undo];
    else if ([_editModeUndoManager isRedoing])
        [_documentUndoManager redo];
    [_documentUndoManager setMultipleActionsNameEnabled:YES];
    _isChagingDocument = NO;
}
// The document's placeholder (registers itself again for redo).
- (void)dummyAction
{
    _isChagingDocument = YES;
    [_documentUndoManager setMultipleActionsNameEnabled:NO];
    [[_documentUndoManager prepareWithInvocationTarget:self] dummyAction];
    [_documentUndoManager setMultipleActionsNameEnabled:YES];
    _isChagingDocument = NO;
}
- (void)duplicateAction
{
    if (![_documentUndoManager isUndoRegistrationEnabled])
        return;
    [_documentUndoManager setMultipleActionsNameEnabled:NO];
    _isChagingDocument = YES;
    if ([_editModeUndoManager isUndoing])
        [_documentUndoManager undo];
    else if ([_editModeUndoManager isRedoing])
        [_documentUndoManager redo];
    else
        [[_documentUndoManager prepareWithInvocationTarget:self] dummyAction];
    [_documentUndoManager setMultipleActionsNameEnabled:YES];
    _isChagingDocument = NO;
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_editModeUndoManager release];
    [_documentUndoManager release];
    [_document release];
    [super dealloc];
}
- (id)initWithDocument:(id)aDocument documentUndoManager:(id)aManager editModeUndoManager:(id)aManager2 delegate:(id)aDelegate
{
    self = [super init];
    if (self != nil) {
        _document = [aDocument retain];
        _documentUndoManager = [aManager retain];
        _editModeUndoManager = [aManager2 retain];
        _delegate = aDelegate;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(documentUndoManagerWillRegisterUndo:)
                                                     name:HSUndoManagerWillRegisterUndoActionNotification object:_documentUndoManager];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(documentDidRemoveAllActions:)
                                                     name:HSUndoManagerDidRemoveAllActionsNotification object:_documentUndoManager];
    }
    return self;
}
@end
