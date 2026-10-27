#import "HyperStudioPrefix.h"
#import "HSGenericModeAssistantPane.h"


@interface HSSelectImagePartPane : HSGenericModeAssistantPane
{
    struct CGPath *_borderPath;
    id _delegate;
}
- (void)handleCancelOperationForImagePartSelectionTool:(id)aTool;
- (void)handleInsertNewlineForImagePartSelectionTool:(id)aTool;
- (BOOL)shouldShowCancelButtonInNavigationPaneSwitcher:(id)aSwitcher;
- (void)paneDidCancel:(id)aCancel;
- (void)paneDidOK:(id)aOK;
- (void)HSSelectImagePartPane_paneDidCancel;
- (void)HSSelectImagePartPane_paneDidOK;
- (id)newBackgroundImage;
- (BOOL)shouldDismissWhenDisappearedByDefault;
- (void)cropImageObject;
- (struct CGPath *)borderPath;
- (id)geometryAttributes;
- (id)hyperObject;
- (void)setDelegate:(id)aDelegate;
- (id)delegate;
- (id)modeToolTags;
- (void)viewWillDisappear:(BOOL)aDisappear;
- (id)assistantPaneUndoManager;
- (void)dealloc;
- (void)HSSelectImagePartPane_windowDidResignMain:(id)aResign;
@end

