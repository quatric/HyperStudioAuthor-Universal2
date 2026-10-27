#import "HyperStudioPrefix.h"
#import "HSActionAssistantSettingsApplier.h"
#import "HSNBAAssistantPane.h"


@interface HSButtonStepperActionAssistantPane : HSNBAAssistantPane <NSTableViewDataSource, NSObject, HSMovieDelegate>
{
    NSTableView *_buttonsTableView;
    NSPopUpButton *_addButtonPopUpButton;
    NSButton *_removeSelectedButtonButton;
    NSButton *_moveSelectedButtonUpButton;
    NSButton *_moveSelectedButtonDownButton;
    NSMatrix *_audioCueTypeMatrix;
    HSButton *_chooseAudioMediaButton;
    NSTextField *_audioMediaNameTextField;
    NSBox *_audioMediaNameBox;
    HSAppearanceButtonCell *_playButtonCell;
    HSMovie *_previewSoundObject;
    HSImportDialogController *_importSoundObjectDialogController;
    NSMutableArray *_availableButtonObjects;
    HSStack *_stack;
}
+ (id)stopButtonGraphiteImage;
+ (id)stopButtonAquaImage;
+ (id)stopButtonImage;
+ (id)playButtonGraphiteImage;
+ (id)playButtonAquaImage;
+ (id)playButtonImage;
- (void)availableCardObjectsDidChange:(id)aChange;
- (void)setStack:(id)aStack;
- (id)stack;
- (BOOL)tableView:(id)aView acceptDrop:(id)aDrop row:(NSInteger)aRow dropOperation:(NSUInteger)aOperation;
- (NSUInteger)tableView:(id)aView validateDrop:(id)aDrop proposedRow:(NSInteger)aRow proposedDropOperation:(NSUInteger)aOperation;
- (BOOL)tableView:(id)aView writeRowsWithIndexes:(id)aIndexes toPasteboard:(id)aPasteboard;
- (void)tableView:(id)aView setObjectValue:(id)aValue forTableColumn:(id)aColumn row:(NSInteger)aRow;
- (id)tableView:(id)aView objectValueForTableColumn:(id)aColumn row:(NSInteger)aRow;
- (NSInteger)numberOfRowsInTableView:(id)aView;
- (void)tableViewSelectionDidChange:(id)aChange;
- (void)menuNeedsUpdate:(id)aUpdate;
- (void)playAudioMedia:(id)aMedia;
- (void)chooseMedia:(id)aMedia;
- (void)audioCueTypeChanged:(id)aChanged;
- (void)moveSelectedButtonDown:(id)aDown;
- (void)moveSelectedButtonUp:(id)aUp;
- (void)removeSelectedButton:(id)aButton;
- (void)addButton:(id)aButton;
- (void)movieDidStop:(id)aStop;
- (void)movieDidPlayOnce:(id)aOnce;
- (void)movieDidChangeImage:(id)aImage;
- (void)movieDidEnd:(id)aEnd;
- (id)actionAttributesAudioMediaFileURL;
- (void)invalidatePreviewSoundObject;
- (id)previewSoundObject;
- (id)importSoundObjectDialogController;
- (void)validateUIWithNotification:(id)aNotification;
- (void)stopPlaying;
- (BOOL)isPlaying;
- (void)validateUserInterface;
- (void)validateButtonsOrginizingControls;
- (void)updateButtonsPopUpButtonCellMenu;
- (void)updateAddButtonPopUpButtonMenu;
- (id)availableButtonObjects;
- (void)invalidateAvailableButtonObjects;
- (BOOL)areAvailableButtonObjectsInvalidated;
- (id)initialKeyView;
- (void)viewWillDisappear:(BOOL)aDisappear;
- (void)viewWillAppear:(BOOL)aAppear;
- (id)actionAttribute;
- (id)actionAttributes;
- (id)buttonStepperActionAssistantPaneApplier;
- (Class)applierClass;
- (id)actionType;
- (void)awakeFromNib;
- (void)dealloc;
- (id)init;
@end

@interface HSButtonStepperActionAssistantPaneApplier : HSActionAssistantSettingsApplier
{
    NSArray *_initialButtonUIDs;
    int _initialAudioCueType;
    HSNewMedia *_initialAudioMedia;
    NSArray *_buttonUIDs;
    int _audioCueType;
    HSNewMedia *_audioMedia;
}
- (void)setAudioMedia:(id)aMedia;
- (void)setAudioCueType:(NSInteger)aType;
- (void)setButtonUIDs:(id)aDs;
- (BOOL)areSettingsEqual;
- (void)makeCurrentEqualToInitial;
- (void)makeInitialEqualToCurrent;
- (void)setInitialSettingsToObject;
- (void)setCurrentSettingsToObject;
- (void)setUpInitialSettings;
- (id)buttonStepperActionAttributes;
- (void)dealloc;
@end

