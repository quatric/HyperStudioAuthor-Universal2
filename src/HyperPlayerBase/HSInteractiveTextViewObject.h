#import "HyperPlayerBasePrefix.h"
#import "HSInteractiveTextItem.h"


@interface HSInteractiveTextViewObject : HSInteractiveTextItem <NSTextViewDelegate, NSTextDelegate, NSObject, HSInteractiveTextObject, HSRunTimeEditorUndoManagerDelegate, HSEditModeUndoHelperDelegate>
{
    HSRunTimeEditorUndoManager *_undoManager;
    HSEditModeUndoHelper *_undoHelper;
    NSAttributedString *_initialText;
    BOOL _deactivating;
    unsigned int _lastCursorLocation;
    HSOverlayView *_overlayView;
}
- (void)overlayViewDidDraw:(id)aDraw;
- (void)erase:(id)aErase;
- (void)deleteBackward:(id)aBackward;
- (BOOL)canBeActivated;
- (void)doCommandBySelector:(SEL)aSelector;
- (BOOL)textViewDidPerformClick:(id)aClick atLocation:(NSPoint)aLocation inInteractiveContext:(id)aContext;
- (void)textViewShouldCompleteEditing:(id)aEditing;
- (void)saveEditingState;
- (NSRange)selectedRange;
- (void)selectRange:(NSRange)aRange;
- (BOOL)hasExecutableActionsForMouseDownEvent:(id)aEvent inInteractiveContext:(id)aContext;
- (void)insertText:(id)aText;
- (void)deactivate;
- (void)activateInCanvasLayer:(id)aLayer;
- (void)setupViewFrameInCanvasLayer:(id)aLayer;
- (id)createView;
- (void)documentUndoManagerDidRemoveAllActions:(id)aActions;
- (void)documentUndoManagerWillRegisterUndo:(id)aUndo;
- (void)editModeUndoHelper:(id)aHelper didFinish:(NSInteger)aFinish;
- (void)didRegisterUndoInUndoManager:(id)aManager;
- (void)willRegisterUndoInUndoManager:(id)aManager;
- (id)undoHelper;
- (id)undoManagerForTextView:(id)aView;
- (BOOL)textView:(id)aView shouldHandlePerformKeyEquivalentOutsideOfKeyDown:(id)aDown;
- (BOOL)textView:(id)aView shouldHandleRawKeyDownEvent:(id)aEvent;
- (BOOL)textViewShouldProceedWithHandlingKeyEvent:(id)aEvent;
- (void)trackMouseWithMouseDownEvent:(id)aEvent andPerformActionIfNeededInContext:(id)aContext;
- (void)textView:(id)aView didPerformClick:(id)aClick;
- (id)textView:(id)aView willChangeSelectionFromCharacterRanges:(id)aRanges toCharacterRanges:(id)aRanges2;
- (BOOL)trackMouseWithScrollWheelEvent:(id)aEvent inInteractiveContext:(id)aContext;
- (BOOL)wantsToTrackMouseWithScrollWheelEvent:(id)aEvent inInteractiveContext:(id)aContext;
- (void)trackMouseWithMouseDownEvent:(id)aEvent inInteractiveContext:(id)aContext;
- (BOOL)wantsToTrackMouseWithMouseDownEvent:(id)aEvent inInteractiveContext:(id)aContext;
- (BOOL)wantsToPassThroughMouseDownEvent:(id)aEvent inInteractiveContext:(id)aContext;
- (void)textDidEndEditing:(id)aEditing;
- (void)textDidChange:(id)aChange;
- (void)updateHyperObjectWithVisualText;
- (void)updateHyperObjectWithText:(id)aText;
- (id)defaultCursorAtPoint:(NSPoint)aPoint inCanvasLayer:(id)aLayer;
- (id)undoManager;
- (void)enableUndoRegistration;
- (void)disableUndoRegistration;
- (id)document;
- (void)awakeInPlayer;
- (void)invalidateView;
- (void)willDisposeView:(id)aView;
- (void)setupView:(id)aView;
- (void)handleRenderingViewDidChangeUserSpaceToViewSpaceTransformNotification:(id)aNotification;
- (void)updateZoomFactor;
- (void)textViewDidEndScrolling:(id)aScrolling;
- (void)textViewDidStartScrolling:(id)aScrolling;
- (void)textViewDidScrolled:(id)aScrolled;
- (BOOL)objectCanBeActivated;
- (id)textViewAttributes;
- (void)dealloc;
- (id)initWithNode:(id)aNode;
@end

