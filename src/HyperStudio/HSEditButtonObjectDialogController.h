#import "HyperStudioPrefix.h"


@interface HSEditButtonObjectDialogController : HSGenericModalController <NSTextFieldDelegate, NSControlTextEditingDelegate, NSObject>
{
    HSEditObjectDialogContext *_context;
    HSEditObjectDialogNodeSupport *_nodeSupport;
    HSButtonObject *_createdButtonObject;
    HSCardObjectView *_prototypeObjectView;
    NSMatrix *_buttonTypeMatrix;
    NSButton *_showTitleSwitch;
    HSGradientColorWell *_titleColorWell;
    HSGradientColorWell *_backgroundColorWell;
    NSTextField *_titleTextField;
    NSButton *_cancelButton;
    NSTextField *_invisibleLabelTextField;
    NSString *_defaultButtonStyle;
    NSString *_defaultButtonType;
    BOOL _defaultNotShowTitle;
    NSColor *_defaultTitleColor;
    NSColor *_defaultBackgroundColor;
}
- (void)finishDialog:(BOOL)aDialog;
- (void)applyShapeBackgrounStyleWithButtonType:(id)aType;
- (void)applySystemBackgrounStyleWithButtonType:(id)aType;
- (NSInteger)tagForButtonType:(id)aType;
- (id)shapeBackgroundInterface;
- (id)systemBackgroundInterface;
- (id)buttonObjectInterface;
- (void)controlTextDidChange:(id)aChange;
- (void)backgroundColorChanged:(id)aChanged;
- (void)titleColorChanged:(id)aChanged;
- (void)showTitleStateChanged:(id)aChanged;
- (void)lassoAreaShapeButtonTypeChosen:(id)aChosen;
- (void)expandingAreaShapeButtonTypeChosen:(id)aChosen;
- (void)freehandAreaButtonTypeChosen:(id)aChosen;
- (void)invisibleShapeButtonTypeChosen:(id)aChosen;
- (void)dropShadowRectangleSystemButtonTypeChosen:(id)aChosen;
- (void)rectangleSystemButtonTypeChosen:(id)aChosen;
- (void)defaultSystemButtonTypeChosen:(id)aChosen;
- (void)regularSystemButtonTypeChosen:(id)aChosen;
- (void)willCloseWindow;
- (void)willShowWindow;
- (void)updateUI;
- (id)nibName;
- (id)createdButtonObject;
- (void)setContext:(id)aContext;
- (id)context;
- (void)removeAllObjectsFromNodeSupport;
- (void)removeObjectFromNodeSupport:(id)aSupport;
- (void)addObjectToNodeSupport:(id)aSupport;
- (id)nodeSupport;
- (void)runForWindow:(id)aWindow delegate:(id)aDelegate didEndSelector:(SEL)aSelector;
- (NSInteger)runModal;
- (void)didLoadNib;
- (void)dealloc;
- (void)createNewButtonObject;
- (id)defaultButtonBorderPath;
@end

