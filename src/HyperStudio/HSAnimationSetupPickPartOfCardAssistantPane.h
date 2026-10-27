#import "HyperStudioPrefix.h"
#import "HSAnimationSetupCropSelectedGraphicAssistantPane.h"


@interface HSAnimationSetupPickPartOfCardAssistantPane : HSAnimationSetupCropSelectedGraphicAssistantPane
{
    HSButton *_selectCardObjectButton;
}
- (void)paneContinue:(id)aContinue;
- (void)selectCardObject:(id)aObject;
- (id)windowTitle;
- (void)viewDidLoad;
- (BOOL)requiresDarkBottomArea;
- (BOOL)assistantShouldBeKeyWindow;
- (id)initWithOptions:(id)aOptions;
- (void)viewWillAppear:(BOOL)aAppear;
- (void)HSAnimationSetupPickPartOfCardAssistantPane_cardsWillChange:(id)aChange;
- (void)HSAnimationSetupPickPartOfCardAssistantPane_currentCardWillChange:(id)aChange;
- (void)HSAnimationSetupPickPartOfCardAssistantPane_objectsWillChange:(id)aChange;
- (void)HSAnimationSetupPickPartOfCardAssistantPane_toolDidChange:(id)aChange;
- (void)HSAnimationSetupPickPartOfCardAssistantPane_windowDidResignMain:(id)aChange;
- (id)assistantPaneUndoManager;
- (id)cardView;
- (id)document;
- (void)viewWillDisappear:(BOOL)aDisappear;
- (void)dealloc;
@end

