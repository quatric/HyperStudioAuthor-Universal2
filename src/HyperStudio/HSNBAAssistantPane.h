#import "HyperStudioPrefix.h"
#import "HSActionAssistantPane.h"


@interface HSNBAAssistantPane : HSActionAssistantPane
{
    NSView *_actionHelpView;
    NSTextView *_helpTextView;
    HSObjectAssistantDrawer *_helpDrawer;
    BOOL _helpIsActive;
}
- (void)hideHelp:(id)aHelp;
- (void)helpViewDidEndLiveResize:(id)aResize;
- (void)showHelp:(id)aHelp;
- (void)hideHelpNeedsRelayout:(BOOL)aRelayout;
- (id)helpDrawer;
- (BOOL)isHelpVisible;
- (id)helpActionType;
- (id)actionHelpView;
- (void)applySettingsOnOK;
- (void)paneDidCancel:(id)aCancel;
- (void)paneDidOK:(id)aOK;
- (void)viewWillDisappear:(BOOL)aDisappear;
- (void)viewWillAppear:(BOOL)aAppear;
- (id)navigationPaneSwitcher;
- (void)dealloc;
@end

