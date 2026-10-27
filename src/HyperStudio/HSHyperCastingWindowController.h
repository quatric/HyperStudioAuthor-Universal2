#import "HyperStudioPrefix.h"
#import "HSDependentPlayerWindowController.h"


@interface HSHyperCastingWindowController : HSDependentPlayerWindowController <HSHyperCastingModePaneRecordingProvider, NSObject>
{
    HSRecorder *_stackRecorder;
    float _previousUserZoomFactor;
    BOOL _isRecording;
    NSString *_recordingPath;
    int _recordedMovieFormat;
    HSExportProgressSheetController *_exportProgressSheetController;
    HSHyperCastingModePane *_hyperCastingModePane;
    id _hyperCastingWindowControllerDelegate;
    BOOL _roundedCornersForMovie;
    NSSize _movieSize;
}
- (void)windowWillClose:(id)aClose;
- (BOOL)canInNavigationController:(id)aController performNavigationOperation:(id)aOperation;
- (BOOL)canGoInNavigationController:(id)aController toCardAtIndex:(NSInteger)aIndex inStackAtURL:(id)aURL;
- (BOOL)canGoToHomeInNavigationController:(id)aController;
- (void)cancelExport:(id)aExport;
- (void)operationsAfterFinishRecordingFileAtPath:(id)aPath;
- (void)operationsAfterCancelRecordingWithError:(id)aError;
- (void)recorder:(id)aRecorder didFinishRecordingToOutputFileAtPath:(id)aPath dueToError:(id)aError;
- (void)confirmHyperCastingModePane:(id)aPane;
- (void)cancelHyperCastingModePane:(id)aPane;
- (void)setOutputToInputDevice:(id)aDevice;
- (void)setVoiceInputDevice:(id)aDevice;
- (void)cancelRecording;
- (void)stopRecording;
- (BOOL)startRecording;
- (BOOL)prepareToStart;
- (BOOL)isRecording;
- (id)outputFileName;
- (id)documentName;
- (void)endHyperCastingModePane;
- (void)endExportProgressSheet;
- (id)exportProgressSheetController;
- (id)stackRecorder;
- (void)setHyperCastingWindowControllerDelegate:(id)aDelegate;
- (id)hyperCastingWindowControllerDelegate;
- (double)framesPerSecondLimit;
- (void)setFramesPerSecondLimit:(double)aLimit;
- (void)setMovieSize:(NSSize)aSize;
- (NSSize)movieSize;
- (void)setRoundedCornersForMovie:(BOOL)aMovie;
- (BOOL)roundedCornersForMovie;
- (void)setRecordedMovieFormat:(NSInteger)aFormat;
- (NSInteger)recordedMovieFormat;
- (void)setRecordingPath:(id)aPath;
- (id)recordingPath;
- (BOOL)validateUserInterfaceItem:(id)aItem;
- (id)windowWillReturnUndoManager:(id)aManager;
- (void)willBecameNonWorkingInModeSwitcher:(id)aSwitcher;
- (void)didBecomeWorkingInModeSwitcher:(id)aSwitcher;
- (BOOL)needRunArrivingActions;
- (id)modeSwitcherView:(id)aView;
- (BOOL)ownsScrollViewForModeSwitcherViewEmbedding;
- (void)dealloc;
- (id)init;
@end

