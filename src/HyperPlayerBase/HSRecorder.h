#import "HyperPlayerBasePrefix.h"


@interface HSRecorder : NSObject <HSCapturingConsumer, NSObject>
{
    pthread_mutex_t _delegateMutex;
    id _delegate;
    id<HSCapturingDataSource> _dataSource;
    HSThreadContext *_currentThreadContext;
    double _capturingStartTime;
    pthread_mutex_t _capturingPreviousTimeMutex;
    double _capturingPreviousTime;
    QTCaptureSession *_voiceCaptureSession;
    QTCaptureMovieFileOutput *_voiceCaptureFileOutput;
    QTCaptureSession *_audioOutToInCaptureSession;
    QTCaptureMovieFileOutput *_audioOutToInCaptureFileOutput;
    QTCaptureDeviceInput *_voiceCaptureDeviceInput;
    QTCaptureDevice *_voiceCaptureDevice;
    QTCaptureDeviceInput *_audioOutToInCaptureDeviceInput;
    QTCaptureDevice *_audioOutToInCaptureDevice;
    struct __CVBuffer *_currentFrameBuffer;
    double _framesPerSecondLimit;
    unsigned int _framesCounter;
    unsigned int _framesQueueLimit;
    BOOL _roundedCornersForMovie;
    NSSize _movieSize;
    HSAudioRecorder *_voiceRecorder;
    HSAudioRecorder *_audioOutToInRecorder;
    HSMoviePlaybackLogger *_movieLogger;
    BOOL _useAudioRecordWorkAround;
    NSError *_error;
}
- (id)playbackThread;
- (void)HSThreadContextDelegate_threadContext:(id)aContext didFinishFlatteningToFile:(id)aFile dueToError:(id)aError;
- (void)audioRecorder:(id)aRecorder didFinishRecordingToFileAtURL:(id)aURL dueToError:(id)aError;
- (void)captureOutput:(id)aOutput didFinishRecordingToOutputFileAtURL:(id)aURL forConnections:(id)aConnections dueToError:(id)aError;
- (void)HSRecorder_loadSoundMovieWithAttributes:(id)aAttributes;
- (void)audioRecorder:(id)aRecorder willStartRecordingToFileAtURL:(id)aURL;
- (void)captureOutput:(id)aOutput willStartRecordingToOutputFileAtURL:(id)aURL forConnections:(id)aConnections;
- (void)capturingDataSource:(id)aSource didOutputFrame:(struct __CVBuffer *)aFrame atTime:(double)aTime;
- (void)setAudioOutToInCaptureDevice:(id)aDevice;
- (id)audioOutToInCaptureDevice:(id)aDevice;
- (void)setAudioVoiceCaptureDevice:(id)aDevice;
- (id)audioVoiceCaptureDevice;
- (void)setMovieSize:(NSSize)aSize;
- (NSSize)movieSize;
- (void)setRoundedCornersForMovie:(BOOL)aMovie;
- (BOOL)roundedCornersForMovie;
- (void)cancelRecording;
- (void)stopRecording;
- (BOOL)restartRecording;
- (BOOL)startRecordingToOutputFilePath:(id)aPath;
- (BOOL)prepareToRecordWithAttributes:(id)aAttributes;
- (BOOL)HSRecorder_prepareForRecordingWithAttributes:(id)aAttributes openAudioDevice:(BOOL)aDevice;
- (BOOL)HSRecorder_setupAudioDeviceInputForSession:(id)aSession device:(id)aDevice openDevice:(BOOL)aDevice2;
- (NSUInteger)framesQueueLimit;
- (void)setFramesQueueLimit:(NSUInteger)aLimit;
- (double)framesPerSecondLimit;
- (void)setFramesPerSecondLimit:(double)aLimit;
- (id)dataSource;
- (void)setDataSource:(id)aSource;
- (id)delegate;
- (void)setDelegate:(id)aDelegate;
- (void)release;
- (void)dealloc;
- (id)init;
- (void)HSRecorder_cancelRecording;
@end

@interface HSThreadContext : NSObject
{
    NSString *_workFolderPath;
    QTMovie *_movie;
    struct ComponentInstanceRecord *_movieStorage;
    NSMutableArray *_soundMovies;
    NSMutableDictionary *_scheduledProcessing;
    NSString *_outputMovieFilePath;
    NSDictionary *_videoFramesAttributes;
    pthread_mutex_t _delegateMutex;
    id<HSThreadContextDelegate> _delegate;
    struct HSFramesQueue *_videoFramesQueue;
    unsigned int _videoFramesQueueLimit;
    pthread_mutex_t _processingThreadMutex;
    pthread_cond_t _processingThreadCondition;
    NSBezierPath *_cornersClipPath;
    unsigned int _packedPixelsBufferSize;
    void *_packedPixelsBuffer;
    unsigned int _roundedCornersForMovie:1;
    unsigned int _isWaitingForActivation:1;
    unsigned int _isThreadRoutineStarted:1;
    unsigned int _isProcessingCanceled:1;
    unsigned int _isAudioCapturingUsed:1;
    unsigned int _isWaitingForAudio:1;
    unsigned int _isWaitingForVideo:1;
    unsigned int _isAudioCaptirungDidFinish:1;
    NSSize _movieSize;
}
+ (id)HSThreadContext_createWorkFolder;
- (void)processingThreadRoutine:(id)aRoutine;
- (void)writeMovieToFile;
- (void)processNotThreadSafeComponent;
- (void)scheduleAddingNotThreadSafeComponentForTrackWithID:(NSInteger)aID attributes:(id)aAttributes;
- (BOOL)isProcessingThreadRoutineStarted;
- (BOOL)removeFrameItemWithSmallestDuration:(double)aDuration removedLastFrameDuration:(double *)aDuration2;
- (void)addNewItemWithFrameBuffer:(struct __CVBuffer *)aBuffer duration:(struct HyperStudio_anon7)aDuration isLastFrame:(BOOL)aFrame;
- (void)cancelProcessing;
- (void)setAudioCaptirungDidFinish:(BOOL)aFinish;
- (void)removeAllSoundMovies;
- (void)addSoundMovieWithAttributes:(id)aAttributes;
- (id)videoFramesAttributes;
- (void)setVideoFramesQueueLimit:(NSUInteger)aLimit;
- (NSUInteger)videoFramesQueueLimit;
- (id)outputMovieFilePath;
- (id)workFolderPath;
- (void)capturingDidStartForOutputFilePath:(id)aPath isAudioCapturingUsed:(BOOL)aUsed isRoundedCorners:(BOOL)aCorners movieSize:(NSSize)aSize;
- (void)dealloc;
- (id)initWithVideoFramesAttributes:(id)aAttributes delegate:(id)aDelegate;
@end

