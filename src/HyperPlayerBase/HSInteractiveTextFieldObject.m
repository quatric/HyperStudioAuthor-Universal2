#import "HSInteractiveTextFieldObject.h"
#import "HSEditModeUndoHelper.h"
#import "HSInteractiveModeMouseOverInfo.h"
#import "HSRunTimeEditorUndoManager.h"

// Player-side editing of a system text field object.
@implementation HSInteractiveTextFieldObject
- (BOOL)canBeActivated
{
    return YES;
}
- (void)doCommandBySelector:(SEL)aSelector
{
    [[[self view] currentEditor] doCommandBySelector:aSelector];
}
- (void)saveEditingState
{
    [_undoManager undo];
    [_undoManager redo];
    [_undoHelper finishDuplicating:YES];
    _saving = YES;
    [self updateHyperObjectWithVisualStringValue];
    _saving = NO;
}
- (id)undoManagerForTextFiled:(id)aFiled editor:(id)aEditor
{
    return [self undoManager];
}
- (void)didRegisterUndoInUndoManager:(id)aManager
{
    [[self undoHelper] duplicateAction];
}
- (void)willRegisterUndoInUndoManager:(id)aManager
{
}
- (id)undoHelper
{
    if (_undoHelper == nil)
        _undoHelper = [[HSEditModeUndoHelper alloc] initWithDocument:[self document]
                                                 documentUndoManager:[[self document] undoManager]
                                                 editModeUndoManager:[self undoManager]
                                                            delegate:nil];
    return _undoHelper;
}
- (id)undoManager
{
    if (_undoManager == nil) {
        _undoManager = [[HSRunTimeEditorUndoManager alloc] init];
        [_undoManager setDelegate:self];
    }
    return _undoManager;
}
- (NSRange)selectedRange
{
    NSText *editor = [[self view] currentEditor];
    if (editor == nil)
        return NSMakeRange(0, 0);
    return [editor selectedRange];
}
- (void)selectRange:(NSRange)aRange
{
    NSText *editor = [[self view] currentEditor];
    if (editor != nil)
        [editor setSelectedRange:aRange];
}
// Without an active editor the text is appended to the object's value directly.
- (void)insertText:(id)aText
{
    NSText *editor = [[self view] currentEditor];
    if (editor != nil) {
        [editor insertText:aText];
        return;
    }
    id attributes = [[self node] queryHyperInterface:@protocol(HSSystemTextFieldAttributes)];
    NSMutableString *value = [[attributes hyperStringValue] mutableCopy]; // never released in the original
    [value appendString:aText];
    [attributes setHyperStringValue:value];
}
- (void)awakeInPlayer
{
    _lastCursorLocation = 0;
}
- (void)activateInCanvasLayer:(id)aLayer
{
    [super activateInCanvasLayer:aLayer];
    _initialText = [[[self textFieldAttributes] hyperStringValue] retain];
    [[[self view] currentEditor] setSelectedRange:NSMakeRange(_lastCursorLocation, 0)];
}
- (void)deactivate
{
    _lastCursorLocation = (unsigned int)[[[self view] currentEditor] selectedRange].location;
    [self updateHyperObjectWithVisualStringValue];
    [super deactivate];
}
- (void)interactiveTextFieldAction:(id)aAction
{
    [self updateHyperObjectWithVisualStringValue];
    [(HSInteractiveObjectsLayer *)[self activeItemContext] sendClickActionsForItemIfNeeded:self];
}
- (void)controlTextDidEndEditing:(id)aEditing
{
    [_undoHelper finishDuplicating:YES];
    [_undoHelper release];
    _undoHelper = nil;
    [self updateHyperObjectWithVisualStringValue];
}
// While an undo helper records the edit the value is stored without document undo; otherwise the
// object is silently reset to the initial text first, so the change registers as one undo step.
- (void)updateHyperObjectWithVisualStringValue
{
    NSString *value = [[[self view] cell] stringValue];
    if (_initialText == nil || [value isEqualToString:_initialText])
        return;
    if (_undoHelper != nil && !_saving)
        [self disableUndoRegistration];
    if (_undoHelper == nil || _saving) {
        [self disableUndoRegistration];
        [[self textFieldAttributes] setHyperStringValue:_initialText];
        [self enableUndoRegistration];
        [_initialText release];
        _initialText = [value retain];
    }
    [[self textFieldAttributes] setHyperStringValue:value];
    if (_undoHelper != nil && !_saving)
        [self enableUndoRegistration];
}
- (void)enableUndoRegistration
{
    [[[self document] undoManager] enableUndoRegistration];
}
- (void)disableUndoRegistration
{
    [[[self document] undoManager] disableUndoRegistration];
}
- (id)document
{
    return [[[self hyperObject] queryHyperInterface:@protocol(HSUserObjectSupport)] document];
}
- (void)willDisposeView:(id)aView
{
    [(NSControl *)aView setTarget:nil];
    [aView setAction:NULL];
    [aView setDelegate:nil];
    [super willDisposeView:aView];
}
- (void)setupView:(id)aView
{
    [(NSControl *)aView setTarget:self];
    [aView setAction:@selector(interactiveTextFieldAction:)];
    [aView setDelegate:self];
}
- (BOOL)objectCanBeActivated
{
    BOOL canBeActivated = [super objectCanBeActivated];
    id attributes = [self textFieldAttributes];
    BOOL selectable = [attributes isSelectable];
    BOOL editable = [attributes isEditable];
    return canBeActivated && (editable || selectable);
}
- (id)textFieldAttributes
{
    return [[self hyperObject] queryHyperInterface:@protocol(HSSystemTextFieldAttributes)];
}
- (void)dealloc
{
    [_undoManager release];
    [_undoHelper release];
    [_initialText release];
    [super dealloc];
}
- (id)initWithNode:(id)aNode
{
    if (![aNode implementsHyperInterface:@protocol(HSSystemTextFieldAttributes)]) {
        [self release];
        return nil;
    }
    return [super initWithNode:aNode];
}
@end
