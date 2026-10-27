#import "HyperPlayerBasePrefix.h"
#import "HSInteractiveTextItem.h"


@interface HSInteractiveTextFieldObject : HSInteractiveTextItem <HSInteractiveTextObject, NSObject, HSRunTimeEditorUndoManagerDelegate>
{
    HSRunTimeEditorUndoManager *_undoManager;
    HSEditModeUndoHelper *_undoHelper;
    NSString *_initialText;
    BOOL _saving;
    unsigned int _lastCursorLocation;
}
- (BOOL)canBeActivated;
- (void)doCommandBySelector:(SEL)aSelector;
- (void)saveEditingState;
- (id)undoManagerForTextFiled:(id)aFiled editor:(id)aEditor;
- (void)didRegisterUndoInUndoManager:(id)aManager;
- (void)willRegisterUndoInUndoManager:(id)aManager;
- (id)undoHelper;
- (id)undoManager;
- (NSRange)selectedRange;
- (void)selectRange:(NSRange)aRange;
- (void)insertText:(id)aText;
- (void)awakeInPlayer;
- (void)activateInCanvasLayer:(id)aLayer;
- (void)deactivate;
- (void)interactiveTextFieldAction:(id)aAction;
- (void)controlTextDidEndEditing:(id)aEditing;
- (void)updateHyperObjectWithVisualStringValue;
- (void)enableUndoRegistration;
- (void)disableUndoRegistration;
- (id)document;
- (void)willDisposeView:(id)aView;
- (void)setupView:(id)aView;
- (BOOL)objectCanBeActivated;
- (id)textFieldAttributes;
- (void)dealloc;
- (id)initWithNode:(id)aNode;
@end

