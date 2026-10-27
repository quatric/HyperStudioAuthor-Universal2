#import "HyperStudioPrefix.h"
#import "HSCommentsTextView.h"


@interface HSHyperCastingModePane : HSObjectAssistantPane
{
    HSImageView *_contentView;
    NSView *_userInformationContentView;
    NSTextField *_currentModeInformationTextField;
    NSTextField *_recordedTimeTextField;
    HSDiscreteIndicatorView *_volumeLevelIndicator;
    NSPopUpButton *_audioDevicePopUpButton;
    NSTimer *_timerForObservingInputAudioLevel;
    NSTimer *_timerForMeasurementRecordMovieTime;
    HSCountDownViewController *_countDownViewController;
    HSHyperCastingModePaneSwitcher *_navigationPaneSwitcher;
    HSCaptureDeviceList *_audioDeviceList;
    NSMenuItem *_noneAudioDeviceMenuItem;
    id<HSHyperCastingModePaneRecordingProvider> _recordingProvider;
    id _hyperCastingModePaneDelegate;
    QTCaptureSession *_soundCaptureSession;
    QTCaptureDeviceInput *_soundCaptureInput;
    QTCaptureMovieFileOutput *_soundCaptureOutput;
}
- (void)captureDeviceListDidUpdate:(id)aUpdate;
- (void)currentAudioDeviceDidChange:(id)aChange;
- (void)cancelRecording;
- (void)stopRecording;
- (BOOL)startRecording;
- (BOOL)isRecording;
- (void)updateIndicatorState:(id)aState;
- (void)installTimerForObservingInputAudioLevel;
- (void)removeTimerForObservingInputAudioLevel;
- (void)setSoundCaptureDevice:(id)aDevice;
- (void)destroySoundCaptureSession;
- (id)soundCaptureSession;
- (void)storeSelectedDeviceInUserDefaults;
- (void)warnUserDeviceNotFound;
- (void)addNoneAudioDeviceMenuItem;
- (BOOL)findInDefaultsAndSetupInputDevices;
- (id)audioDeviceList;
- (void)updateSoundDuration:(id)aDuration;
- (void)countDownDidEnd:(id)aEnd;
- (void)setMovieDuration:(double)aDuration forTextField:(id)aField;
- (double)movieDurationForTextField:(id)aField;
- (void)installTimerForMeasurementMovieDuration;
- (void)removeTimerForMeasurementMovieDuration;
- (void)validateUserInterface;
- (id)countDownViewController;
- (void)setHyperCastingModePaneDelegate:(id)aDelegate;
- (id)hyperCastingModePaneDelegate;
- (void)setRecordingProvider:(id)aProvider;
- (id)recordingProvider;
- (void)paneDidOK:(id)aOK;
- (void)paneDidCancel:(id)aCancel;
- (BOOL)shouldEnableOKButtonInNavigationPaneSwitcher:(id)aSwitcher;
- (void)viewDidDisappear:(BOOL)aDisappear;
- (void)viewDidAppear:(BOOL)aAppear;
- (void)viewWillAppear:(BOOL)aAppear;
- (void)viewDidLoad;
- (void)awakeFromNib;
- (BOOL)needsToBeSavedInHistory;
- (id)hyperCastingNavigationPaneSwitcher;
- (id)navigationPaneSwitcher;
- (id)windowTitle;
- (BOOL)requiresDarkBottomArea;
- (void)dealloc;
- (id)init;
@end

