#import "HyperStudioPrefix.h"
#import "HSHelpAssistantPane.h"


@interface HSAnimationSetupEditPathAssistantPane : HSHelpAssistantPane
{
    id<HSAnimationSetupEditPathAssistantPaneDelegate> _delegate;
    NSButton *_cancelButton;
}
- (void)paneDidCancel:(id)aCancel;
- (void)viewDidLoad;
- (void)setDelegate:(id)aDelegate;
- (id)delegate;
- (void)dealloc;
- (id)assistantPaneUndoManager;
- (id)document;
- (id)mainWindow;
- (void)HSAnimationSetupEditPathAssistantPane_windowDidResignMain:(id)aResign;
- (void)viewWillDisappear:(BOOL)aDisappear;
@end

