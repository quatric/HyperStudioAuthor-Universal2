#import "HyperStudioPrefix.h"
#import "HSActionAssistantPane.h"


@interface HSPickMovieSourceAssistantPane : HSActionAssistantPane <HSMovieRecordingAssistantPaneDelegate>
{
    NSButton *_diskFolderButton;
    NSButton *_recordVideoButton;
    NSButton *_showLiveVideoButton;
    HSMovieRecordingAssistantPane *_movieRecordingAssistantPane;
    HSObjectAssistantNavigationPaneSwitcher *_navigationPaneSwitcher;
    HSImportDialogController *_importMovieObjectDialogController;
    id<HSPickMovieSourceAssistantPaneDelegate> _pickMovieSourcePaneDelegate;
}
- (void)movieRecordingAssistantPane:(id)aPane didChooseMovieObject:(id)aObject;
- (void)openMovieRecordingAssistantPane;
- (id)movieRecordingAssistantPane;
- (id)importMovieObjectDialogController;
- (id)actionAttributes;
- (id)actionType;
- (void)setPickMovieSourcePaneDelegate:(id)aDelegate;
- (id)pickMovieSourcePaneDelegate;
- (void)liveVideoChosen:(id)aChosen;
- (void)videoRecordChosen:(id)aChosen;
- (void)diskFileChosen:(id)aChosen;
- (void)cancel:(id)aCancel;
- (void)dismissPaneIfNeeded;
- (void)processLiveObject:(id)aObject;
- (void)processMovieObject:(id)aObject isInUse:(BOOL)aUse;
- (void)restoreApplierSettings;
- (void)updateObjectWithApplier;
- (id)applier;
- (id)helpTopicKey;
- (BOOL)needsToBeSavedInHistory;
- (id)navigationPaneSwitcher;
- (void)viewDidLoad;
- (void)dealloc;
- (id)init;
@end

