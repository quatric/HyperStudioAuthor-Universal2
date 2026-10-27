#import "HyperStudioPrefix.h"
#import "HSGenericModeAssistantPane.h"


@interface HSDrawButtonShapeAssistantPane : HSGenericModeAssistantPane
{
    HSButtonObjectAssistantPaneState *_paneState;
    int _toolTag;
    BOOL _behaveAsCancel;
}
- (BOOL)shouldEnableBackButtonInNavigationPaneSwitcher:(id)aSwitcher;
- (BOOL)assistantShouldBeKeyWindow;
- (BOOL)shouldShowCancelButtonInNavigationPaneSwitcher:(id)aSwitcher;
- (id)newBackgroundImage;
- (void)activateTool;
- (void)paneWillGoBack:(id)aBack;
- (void)dismiss:(BOOL)aDismiss slide:(BOOL)aSlide;
- (void)runDidDoneDelegateSelector;
- (void)setButtonIsCancel:(BOOL)aCancel;
- (BOOL)buttonIsCancel;
- (NSInteger)toolTag;
- (void)setToolTag:(NSInteger)aTag;
- (id)shapeBackgroundInterface;
- (id)buttonObjectInterface;
- (void)applyShapeBackgroundStyleWithButtonType;
- (void)toolDidCancelOperation:(id)aOperation;
- (void)alertDidEnd:(id)aEnd returnCode:(NSInteger)aCode contextInfo:(void *)aInfo;
- (void)buttonShapeCreationTool:(id)aTool didFinalizeWithEvent:(id)aEvent;
- (id)paneState;
- (void)setPaneState:(id)aState;
- (void)leaveCurrentModeWithSelectingToolWithTag:(NSInteger)aTag;
- (id)modeToolTags;
- (void)viewWillAppear:(BOOL)aAppear;
- (void)viewWillDisappear:(BOOL)aDisappear;
- (BOOL)shouldDismissWhenDisappearedByDefault;
- (id)cardView;
@end

