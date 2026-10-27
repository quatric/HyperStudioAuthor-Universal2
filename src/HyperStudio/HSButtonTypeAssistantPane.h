#import "HyperStudioPrefix.h"
#import "HSHelpAssistantPane.h"


@interface HSButtonTypeAssistantPane : HSHelpAssistantPane
{
    NSMatrix *_buttonTypeMatrix;
    HSButtonObjectAssistantPaneState *_paneState;
    HSObjectAssistantNavigationPaneSwitcher *_navigationPaneSwitcher;
    HSButtonObjectAssistantPaneState *_storedPaneState;
    NSRect _storedInvisibleButtonBounds;
}
- (BOOL)shouldShowCancelButtonInNavigationPaneSwitcher:(id)aSwitcher;
- (id)currentButtonBorderPath;
- (id)defaultButtonBorderPath;
- (void)drawPaneDidDone:(id)aDone contextInfo:(void *)aInfo;
- (void)restoreSizeOfInvisibleButton;
- (void)assistDrawShapeBackground;
- (void)paneDidOK:(id)aOK;
- (void)paneDidCancel:(id)aCancel;
- (void)applyShapeBackgroundStyleWithButtonType;
- (void)applySystemBackgroundStyleWithButtonType;
- (void)applyPaneStateToButtonObject;
- (void)selectToolWithTag:(NSInteger)aTag;
- (NSUInteger)toolTagForShapeButtonType:(id)aType;
- (NSInteger)tagForButtonType:(id)aType;
- (id)systemBackgroundInterface;
- (void)storePreviousState;
- (void)lassoAreaShapeButtonTypeChosen:(id)aChosen;
- (void)expandingAreaShapeButtonTypeChosen:(id)aChosen;
- (void)freehandAreaButtonTypeChosen:(id)aChosen;
- (void)invisibleShapeButtonTypeChosen:(id)aChosen;
- (void)dropShadowRectangleSystemButtonTypeChosen:(id)aChosen;
- (void)rectangleSystemButtonTypeChosen:(id)aChosen;
- (void)defaultSystemButtonTypeChosen:(id)aChosen;
- (void)regularSystemButtonTypeChosen:(id)aChosen;
- (void)setInformativeTextForCoachingKey:(id)aKey;
- (id)shapeBackgroundInterface;
- (id)buttonObjectInterface;
- (id)undoManager;
- (void)viewDidLoad;
- (id)navigationPaneSwitcher;
- (void)dealloc;
- (id)init;
- (id)cardGroupController;
- (id)delegate;
- (BOOL)isAttributesNotificationPostingDisabled;
- (id)scriptController;
- (void)viewWillAppear:(BOOL)aAppear;
- (void)dismiss:(BOOL)aDismiss slide:(BOOL)aSlide;
@end

