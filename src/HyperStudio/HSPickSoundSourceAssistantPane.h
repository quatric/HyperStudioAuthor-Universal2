#import "HyperStudioPrefix.h"
#import "HSActionAssistantPane.h"


@interface HSPickSoundSourceAssistantPane : HSActionAssistantPane <HSSoundRecordingAssistantPaneDelegate>
{
    NSButton *_diskFolderButton;
    NSButton *_recordSoundButton;
    NSButton *_stopSoundButton;
    id<HSPickSoundSourceAssistantPaneDelegate> _pickSoundSourcePaneDelegate;
    HSObjectAssistantNavigationPaneSwitcher *_navigationPaneSwitcher;
    HSImportDialogController *_importSoundObjectDialogController;
    HSSoundRecordingAssistantPane *_soundRecordingAssistantPane;
}
- (void)soundRecordingAssistantPane:(id)aPane didRecordSoundItem:(id)aItem;
- (void)openSoundRecordingAssistantPane;
- (id)soundRecordingAssistantPane;
- (id)importSoundObjectDialogController;
- (id)actor;
- (id)actionType;
- (void)stopSound:(id)aSound;
- (void)soundRecordChosen:(id)aChosen;
- (void)diskFileChosen:(id)aChosen;
- (void)cancel:(id)aCancel;
- (void)dismissPaneIfNeeded;
- (void)processSoundItem:(id)aItem;
- (void)restoreApplierSettings;
- (void)updateObjectWithApplier;
- (id)applier;
- (id)helpTopicKey;
- (BOOL)needsToBeSavedInHistory;
- (id)navigationPaneSwitcher;
- (void)viewDidLoad;
- (void)setPickSoundSourcePaneDelegate:(id)aDelegate;
- (id)pickSoundSourcePaneDelegate;
- (void)dealloc;
- (id)init;
- (void)importSoundObjectDialogDidEnd:(id)aDialog returnedCode:(NSInteger)aCode contextInfo:(void *)aInfo;
@end

