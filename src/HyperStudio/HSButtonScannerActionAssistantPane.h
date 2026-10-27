#import "HyperStudioPrefix.h"
#import "HSActionAssistantSettingsApplier.h"
#import "HSNBAAssistantPane.h"


@interface HSButtonScannerActionAssistantPane : HSNBAAssistantPane <HSMovieDelegate>
{
    NSTextField *_scanDelayTextField;
    NSStepper *_scanDelayStepper;
    NSTextField *_resetDelayTextField;
    NSStepper *_resetDelayStepper;
    NSTextField *_scanCyclesTextField;
    NSStepper *_scanCyclesStepper;
    NSMatrix *_scanCyclesMatrix;
    NSMatrix *_audioCueTypeMatrix;
    NSTextField *_audioMediaNameTextField;
    NSButton *_chooseAudioMediaButton;
    NSButton *_hideCursorCheckBox;
    HSAppearanceButtonCell *_playButtonCell;
    NSView *_audioMediaNameContainer;
    HSMovie *_previewSoundObject;
    HSImportDialogController *_importSoundObjectDialogController;
}
+ (id)stopButtonGraphiteImage;
+ (id)stopButtonAquaImage;
+ (id)stopButtonImage;
+ (id)playButtonGraphiteImage;
+ (id)playButtonAquaImage;
+ (id)playButtonImage;
- (void)hideCursorChanged:(id)aChanged;
- (void)playAudioMedia:(id)aMedia;
- (void)audioMediaChanged:(id)aChanged;
- (void)audioCueTypeChanged:(id)aChanged;
- (void)scanCyclesCountChanged:(id)aChanged;
- (void)resetDelayChanged:(id)aChanged;
- (void)scanDelayChanged:(id)aChanged;
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
- (id)initialKeyView;
- (void)viewWillDisappear:(BOOL)aDisappear;
- (void)viewWillAppear:(BOOL)aAppear;
- (id)actionAttribute;
- (id)actionAttributes;
- (id)buttonScannerActionAssistantPaneApplier;
- (Class)applierClass;
- (id)actionType;
- (void)dealloc;
- (id)init;
@end

@interface HSButtonScannerActionAssistantPaneApplier : HSActionAssistantSettingsApplier
{
    float _initialScanDelay;
    float _scanDelay;
    float _initialResetDelay;
    float _resetDelay;
    unsigned int _initialScanCyclesCount;
    unsigned int _scanCyclesCount;
    int _initialAudioCueType;
    int _audioCueType;
    HSNewMedia *_initialAudioMedia;
    HSNewMedia *_audioMedia;
    BOOL _hidesCursor;
    BOOL _initialHidesCursor;
}
- (void)setHidesCursor:(BOOL)aCursor;
- (void)setAudioMedia:(id)aMedia;
- (void)setAudioCueType:(NSInteger)aType;
- (void)setScanCyclesCount:(NSUInteger)aCount;
- (void)setResetDelay:(CGFloat)aDelay;
- (void)setScanDelay:(CGFloat)aDelay;
- (BOOL)areSettingsEqual;
- (void)makeCurrentEqualToInitial;
- (void)makeInitialEqualToCurrent;
- (void)setInitialSettingsToObject;
- (void)setCurrentSettingsToObject;
- (void)setUpInitialSettings;
- (id)buttonScannerActionAttributes;
- (void)dealloc;
@end

