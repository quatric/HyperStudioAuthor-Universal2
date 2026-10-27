#import "HyperStudioPrefix.h"
#import "HSExtraModalController.h"


@interface HSEasyLinkDialogController : HSExtraModalController <NSOpenSavePanelDelegate, NSObject>
{
    NSTextField *_fileNameTextField;
    NSButton *_doneButton;
}
- (void)fileNameDidChange:(id)aChange;
- (void)applyChanges;
- (void)chooseFile:(id)aFile;
- (void)addButtonWithOpenLoactionAction:(id)aAction;
- (id)nibName;
@end

