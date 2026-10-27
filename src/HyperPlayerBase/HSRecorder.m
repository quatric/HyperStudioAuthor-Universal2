#include <pthread.h>
#import "HSRecorder.h"

// The frames queue is a doubly linked list of captured frames (f0 the oldest, f1 the newest) with a list
// of spare items (f2) for reuse; an item without a buffer ends the recording.
struct HSFramesQueueItem {
    CVPixelBufferRef buffer;
    struct HyperStudio_anon7 duration;
    struct HSFramesQueueItem *previous;
    struct HSFramesQueueItem *next;
};

// FUN_00267c9e: puts the audio compression options on the sound connections of a movie file output.
static void HSRecorderSetSoundCompression(QTCaptureMovieFileOutput *aOutput, NSString *aIdentifier)
{
    QTCompressionOptions *options = [QTCompressionOptions compressionOptionsWithIdentifier:aIdentifier];
    if (options != nil) {
        for (QTCaptureConnection *connection in [aOutput connections]) {
            if ([[connection mediaType] isEqualToString:QTMediaTypeSound]) {
                [aOutput setCompressionOptions:options forConnection:connection];
            }
        }
    }
}

static QTTime HSRecorderQTTimeFromDuration(struct HyperStudio_anon7 aDuration)
{
    QTTime time = QTMakeTime(aDuration.f0, aDuration.f1);
    time.flags = aDuration.f2;
    return time;
}

static struct HSFramesQueueItem *HSRecorderFramesQueueAppendItem(struct HSFramesQueue *aQueue)
{
    struct HSFramesQueueItem *item = aQueue->f2;
    if (item == NULL) {
        item = malloc(sizeof(struct HSFramesQueueItem));
    } else {
        aQueue->f2 = item->next;
    }
    if (item != NULL) {
        memset(item, 0, sizeof(struct HSFramesQueueItem));
        if (aQueue->f0 == NULL) {
            aQueue->f0 = item;
        } else {
            aQueue->f1->next = item;
            item->previous = aQueue->f1;
        }
        aQueue->f1 = item;
        aQueue->f3++;
    }
    return item;
}

@implementation HSRecorder


- (id)playbackThread
{
    return [NSThread mainThread];
}

- (void)HSThreadContextDelegate_threadContext:(id)aContext didFinishFlatteningToFile:(id)aFile dueToError:(id)aError
{
    if (_currentThreadContext == aContext) {
        [_currentThreadContext release];
        _currentThreadContext = nil;
        pthread_mutex_lock(&_delegateMutex);
        if ([_delegate respondsToSelector:@selector(recorder:didFinishRecordingToOutputFileAtPath:dueToError:)]) {
            [_delegate recorder:self didFinishRecordingToOutputFileAtPath:aFile dueToError:(_error != nil) ? _error : aError];
        }
        pthread_mutex_unlock(&_delegateMutex);
        [_error autorelease];
        _error = nil;
    }
}

- (void)audioRecorder:(id)aRecorder didFinishRecordingToFileAtURL:(id)aURL dueToError:(id)aError
{
    [self performSelectorOnMainThread:@selector(HSRecorder_loadSoundMovieWithAttributes:) withObject:[NSDictionary dictionaryWithObjectsAndKeys:aURL, @"outputFileURL", aRecorder, @"captureOutput", nil] waitUntilDone:NO];
}

- (void)captureOutput:(id)aOutput didFinishRecordingToOutputFileAtURL:(id)aURL forConnections:(id)aConnections dueToError:(id)aError
{
    if (aError != nil && [[aError domain] isEqualToString:QTKitErrorDomain] && [aError code] != 0x4b0) {
        [_error release];
        _error = [aError retain];
        [self cancelRecording];
        if ([_delegate respondsToSelector:@selector(recorder:didFinishRecordingToOutputFileAtPath:dueToError:)]) {
            [_delegate recorder:self didFinishRecordingToOutputFileAtPath:[_currentThreadContext outputMovieFilePath] dueToError:aError];
        }
        return;
    }
    [_error release];
    _error = [aError retain];
    [self performSelectorOnMainThread:@selector(HSRecorder_loadSoundMovieWithAttributes:)
                           withObject:[NSDictionary dictionaryWithObjectsAndKeys:aURL, @"outputFileURL", aOutput, @"captureOutput", nil]
                        waitUntilDone:NO];
}

- (void)HSRecorder_loadSoundMovieWithAttributes:(id)aAttributes
{
    NSString *path = [[aAttributes objectForKey:@"outputFileURL"] path];
    if (path != nil) {
        // A captured audio file finished recording: its recorder is torn down and the file is deleted.
        BOOL isVoice = [path hasSuffix:@"voice.aiff"];
        id output = [aAttributes objectForKey:@"captureOutput"];
        if (!isVoice) {
            if (output == _audioOutToInRecorder || output == _audioOutToInCaptureFileOutput) {
                if (!_useAudioRecordWorkAround) {
                    [_audioOutToInCaptureSession stopRunning];
                    if ([[_audioOutToInCaptureDeviceInput device] isOpen]) {
                        [[_audioOutToInCaptureDeviceInput device] close];
                    }
                    [_audioOutToInCaptureSession removeOutput:_voiceCaptureFileOutput];
                    [_audioOutToInCaptureFileOutput setDelegate:nil];
                    [_audioOutToInCaptureFileOutput release];
                    _audioOutToInCaptureFileOutput = nil;
                } else {
                    [_audioOutToInRecorder release];
                    _audioOutToInRecorder = nil;
                }
            }
        } else if (output == _voiceRecorder || output == _voiceCaptureFileOutput) {
            if (!_useAudioRecordWorkAround) {
                [_voiceCaptureSession stopRunning];
                if ([[_voiceCaptureDeviceInput device] isOpen]) {
                    [[_voiceCaptureDeviceInput device] close];
                }
                [_voiceCaptureSession removeOutput:_voiceCaptureFileOutput];
                [_voiceCaptureFileOutput setDelegate:nil];
                [_voiceCaptureFileOutput release];
                _voiceCaptureFileOutput = nil;
            } else {
                [_voiceRecorder release];
                _voiceRecorder = nil;
            }
        }
        [[NSFileManager defaultManager] removeItemAtPath:path error:NULL];
        return;
    }
    if (_currentThreadContext == nil) {
        return;
    }
    id soundURL = [aAttributes objectForKey:@"outputFileURL"];
    NSDictionary *movieAttributes = nil;
    if (soundURL == nil) {
        if (_movieLogger != nil) {
            for (HSMoviePlaybackLogItem *item in [_movieLogger log]) {
                double startTime = [item startTime] - _capturingStartTime;
                QTMovie *movie = [[[[item movie] QTMovie] copyWithZone:NULL] autorelease];
                if ([movie detachFromCurrentThread]) {
                    id playbackItem = [[item copyWithStartTime:MAX(0.0, startTime)] autorelease];
                    NSDictionary *entry = [NSDictionary dictionaryWithObjectsAndKeys:movie, @"HSRecorderQTMovieKey", playbackItem, @"HSRecorderPlaybackAttributesKey", nil];
                    [_currentThreadContext addSoundMovieWithAttributes:entry];
                }
            }
            [_movieLogger release];
            _movieLogger = nil;
        }
    } else {
        QTMovie *movie = [QTMovie movieWithURL:soundURL error:NULL];
        if (movie != nil) {
            [movie setAttribute:[NSNumber numberWithBool:NO] forKey:QTMovieIsActiveAttribute];
            movieAttributes = [NSDictionary dictionaryWithObject:([movie detachFromCurrentThread] ? movie : [NSNull null]) forKey:@"HSRecorderQTMovieKey"];
        }
    }
    [_currentThreadContext addSoundMovieWithAttributes:movieAttributes];
    id otherRecorder;
    if (!_useAudioRecordWorkAround) {
        if (_audioOutToInCaptureFileOutput != nil) {
            return;
        }
        otherRecorder = _voiceCaptureFileOutput;
    } else {
        if (_voiceRecorder != nil) {
            return;
        }
        otherRecorder = _audioOutToInRecorder;
    }
    if (otherRecorder != nil || _movieLogger != nil) {
        return;
    }
    [_currentThreadContext setAudioCaptirungDidFinish:YES];
}

- (void)audioRecorder:(id)aRecorder willStartRecordingToFileAtURL:(id)aURL
{
    pthread_mutex_lock(&_capturingPreviousTimeMutex);
    if (_capturingPreviousTime == -1.0) {
        _capturingPreviousTime = [NSDate timeIntervalSinceReferenceDate];
    }
    pthread_mutex_unlock(&_capturingPreviousTimeMutex);
}

- (void)captureOutput:(id)aOutput willStartRecordingToOutputFileAtURL:(id)aURL forConnections:(id)aConnections
{
    pthread_mutex_lock(&_capturingPreviousTimeMutex);
    if (_capturingPreviousTime == -1.0) {
        _capturingPreviousTime = [NSDate timeIntervalSinceReferenceDate];
    }
    pthread_mutex_unlock(&_capturingPreviousTimeMutex);
}

- (void)capturingDataSource:(id)aSource didOutputFrame:(struct __CVBuffer *)aFrame atTime:(double)aTime
{
    if (aFrame == NULL) {
        return;
    }
    CVPixelBufferRetain(aFrame);
    if (_capturingStartTime == -1.0) {
        _capturingStartTime = aTime;
        _currentFrameBuffer = aFrame;
        _framesCounter = 0;
        if (_voiceCaptureFileOutput == nil) {
            _capturingPreviousTime = aTime;
        }
        return;
    }
    pthread_mutex_lock(&_capturingPreviousTimeMutex);
    double previousTime = _capturingPreviousTime;
    pthread_mutex_unlock(&_capturingPreviousTimeMutex);
    if (previousTime == -1.0) {
        CVPixelBufferRelease(_currentFrameBuffer);
        _currentFrameBuffer = aFrame;
        return;
    }
    BOOL addFrame = YES;
    if ((aTime - _capturingStartTime) * _framesPerSecondLimit <= (double)(_framesCounter + 2)) {
        // Frames come in faster than the limit allows: drop the shortest queued frame to make room.
        if (aTime - previousTime < 1.0 / _framesPerSecondLimit) {
            addFrame = NO;
        } else {
            double removedLastFrameDuration = 0.0;
            if ([_currentThreadContext removeFrameItemWithSmallestDuration:1.0 / _framesPerSecondLimit removedLastFrameDuration:&removedLastFrameDuration]) {
                previousTime -= removedLastFrameDuration;
            }
        }
    }
    if (addFrame) {
        struct HyperStudio_anon7 duration = { llroundf((float)((aTime - previousTime) * 600.0)), 600, 0 };
        [_currentThreadContext addNewItemWithFrameBuffer:_currentFrameBuffer duration:duration isLastFrame:NO];
        pthread_mutex_lock(&_capturingPreviousTimeMutex);
        _capturingPreviousTime = aTime;
        pthread_mutex_unlock(&_capturingPreviousTimeMutex);
        _framesCounter++;
    }
    CVPixelBufferRelease(_currentFrameBuffer);
    _currentFrameBuffer = aFrame;
}

- (void)setAudioOutToInCaptureDevice:(id)aDevice
{
    if (_audioOutToInCaptureDevice != aDevice) {
        [_audioOutToInCaptureDevice release];
        _audioOutToInCaptureDevice = [aDevice retain];
    }
}

- (id)audioOutToInCaptureDevice:(id)aDevice
{
    return [_audioOutToInCaptureDeviceInput device];
}

- (void)setAudioVoiceCaptureDevice:(id)aDevice
{
    if (_voiceCaptureDevice != aDevice) {
        [_voiceCaptureDevice release];
        _voiceCaptureDevice = [aDevice retain];
    }
}

- (id)audioVoiceCaptureDevice
{
    return [_voiceCaptureDeviceInput device];
}

- (void)setMovieSize:(NSSize)aSize
{
    (_movieSize).width = aSize.width;
    (_movieSize).height = aSize.height;
}

- (NSSize)movieSize
{
    return _movieSize;
}

- (void)setRoundedCornersForMovie:(BOOL)aMovie
{
    _roundedCornersForMovie = aMovie;
}

- (BOOL)roundedCornersForMovie
{
    return _roundedCornersForMovie;
}

- (void)cancelRecording
{
    if (_currentThreadContext != nil) {
        [self HSRecorder_cancelRecording];
    }
}

- (void)stopRecording
{
    [_dataSource stopCapturingForConsumer:self];
    double now = [NSDate timeIntervalSinceReferenceDate];
    if (!_useAudioRecordWorkAround) {
        if (_voiceCaptureFileOutput != nil) {
            [_voiceCaptureFileOutput recordToOutputFileURL:nil bufferDestination:QTCaptureFileOutputBufferDestinationOldFile];
        }
        if (_audioOutToInCaptureFileOutput != nil) {
            [_audioOutToInCaptureFileOutput recordToOutputFileURL:nil bufferDestination:QTCaptureFileOutputBufferDestinationOldFile];
        }
    } else {
        if ([_voiceRecorder isRecording]) {
            [_voiceRecorder stopRecording];
        }
        if ([_audioOutToInRecorder isRecording]) {
            [_audioOutToInRecorder stopRecording];
        }
    }
    if (_movieLogger != nil) {
        [_movieLogger stopLogging];
        [self HSRecorder_loadSoundMovieWithAttributes:nil];
    }
    pthread_mutex_lock(&_capturingPreviousTimeMutex);
    double lastFrameTime = (_capturingPreviousTime == -1.0) ? _capturingStartTime : _capturingPreviousTime;
    _capturingPreviousTime = -1.0;
    pthread_mutex_unlock(&_capturingPreviousTimeMutex);
    if (lastFrameTime != -1.0) {
        struct HyperStudio_anon7 duration = { llroundf((float)((now - lastFrameTime) * 600.0)), 600, 0 };
        [_currentThreadContext addNewItemWithFrameBuffer:_currentFrameBuffer duration:duration isLastFrame:YES];
        CVPixelBufferRelease(_currentFrameBuffer);
        _currentFrameBuffer = NULL;
    }
    if ([_delegate respondsToSelector:@selector(recorder:willFinishRecordingToOutputFileAtPath:dueToError:)]) {
        [_delegate recorder:self willFinishRecordingToOutputFileAtPath:[_currentThreadContext outputMovieFilePath] dueToError:nil];
    }
}

- (BOOL)restartRecording
{
    [_dataSource stopCapturingForConsumer:self];
    if (!_useAudioRecordWorkAround) {
        if (_voiceCaptureFileOutput != nil) {
            [_voiceCaptureFileOutput recordToOutputFileURL:nil bufferDestination:QTCaptureFileOutputBufferDestinationOldFile];
            [_voiceCaptureSession removeOutput:_voiceCaptureFileOutput];
            [_voiceCaptureFileOutput setDelegate:nil];
            [_voiceCaptureFileOutput release];
            _voiceCaptureFileOutput = nil;
        }
        if (_audioOutToInCaptureFileOutput != nil) {
            [_audioOutToInCaptureFileOutput recordToOutputFileURL:nil bufferDestination:QTCaptureFileOutputBufferDestinationOldFile];
            [_audioOutToInCaptureSession removeOutput:_audioOutToInCaptureFileOutput];
            [_audioOutToInCaptureFileOutput setDelegate:nil];
            [_audioOutToInCaptureFileOutput release];
            _audioOutToInCaptureFileOutput = nil;
        }
    } else {
        if (_voiceRecorder != nil) {
            [_voiceRecorder stopRecording];
            [_voiceRecorder setDelegate:nil];
            [_voiceRecorder release];
            _voiceRecorder = nil;
        }
        if (_audioOutToInRecorder != nil) {
            [_audioOutToInRecorder stopRecording];
            [_audioOutToInRecorder setDelegate:nil];
            [_audioOutToInRecorder release];
            _audioOutToInRecorder = nil;
        }
    }
    if (_movieLogger != nil) {
        [_movieLogger stopLogging];
        [_movieLogger release];
        _movieLogger = nil;
    }
    [_currentThreadContext cancelProcessing];
    NSString *outputPath = [[_currentThreadContext outputMovieFilePath] retain];
    NSDictionary *attributes = [[_currentThreadContext videoFramesAttributes] retain];
    [_currentThreadContext release];
    _currentThreadContext = nil;
    pthread_mutex_lock(&_capturingPreviousTimeMutex);
    _capturingPreviousTime = -1.0;
    pthread_mutex_unlock(&_capturingPreviousTimeMutex);
    CVPixelBufferRelease(_currentFrameBuffer);
    _currentFrameBuffer = NULL;
    _capturingStartTime = -1.0;
    BOOL restarted = NO;
    if ([self HSRecorder_prepareForRecordingWithAttributes:attributes openAudioDevice:NO]) {
        restarted = [self startRecordingToOutputFilePath:outputPath];
    }
    [outputPath release];
    [attributes release];
    return restarted;
}

- (BOOL)startRecordingToOutputFilePath:(id)aPath
{
    if (aPath == nil || _dataSource == nil) {
        return NO;
    }
    _capturingStartTime = -1.0;
    _capturingPreviousTime = -1.0;
    [_dataSource startCapturingForConsumer:self];
    BOOL voiceUsed = NO;
    if (_voiceRecorder != nil || _voiceCaptureFileOutput != nil) {
        NSURL *url = [NSURL fileURLWithPath:[[_currentThreadContext workFolderPath] stringByAppendingPathComponent:@"voice.aiff"]];
        if (url != nil) {
            if (_useAudioRecordWorkAround) {
                [_voiceRecorder startRecordingToFileAtURL:url];
            } else {
                [_voiceCaptureFileOutput recordToOutputFileURL:url];
            }
            voiceUsed = YES;
        }
    }
    BOOL audioOutToInUsed = NO;
    if (_audioOutToInRecorder != nil || _audioOutToInCaptureFileOutput != nil) {
        NSURL *url = [NSURL fileURLWithPath:[[_currentThreadContext workFolderPath] stringByAppendingPathComponent:@"audioOutToIn.aiff"]];
        if (url != nil) {
            if (_useAudioRecordWorkAround) {
                [_audioOutToInRecorder startRecordingToFileAtURL:url];
            } else {
                [_audioOutToInCaptureFileOutput recordToOutputFileURL:url];
            }
            audioOutToInUsed = YES;
        }
    } else if (_movieLogger != nil) {
        [_movieLogger startLogging];
        audioOutToInUsed = YES;
    }
    [_currentThreadContext capturingDidStartForOutputFilePath:aPath isAudioCapturingUsed:(voiceUsed || audioOutToInUsed) isRoundedCorners:_roundedCornersForMovie movieSize:[self movieSize]];
    return YES;
}

- (BOOL)prepareToRecordWithAttributes:(id)aAttributes
{
    id pvVar1;

    if ((_currentThreadContext != nil) && (pvVar1 = [_currentThreadContext outputMovieFilePath], pvVar1 == nil )) {
        [_currentThreadContext setVideoFramesQueueLimit:_framesQueueLimit]
        ;
        return YES;
    }
    return (BOOL)[self HSRecorder_prepareForRecordingWithAttributes:aAttributes openAudioDevice:YES];
}

- (BOOL)HSRecorder_prepareForRecordingWithAttributes:(id)aAttributes openAudioDevice:(BOOL)aDevice
{
    id codecType = [aAttributes objectForKey:@"HSVideoCodecTypeAttribute"];
    NSString *codec = @"mp4v";
    if ([codecType isKindOfClass:[NSNumber class]] && [codecType unsignedIntValue] != 0) {
        codec = [NSString extraStringWithFourCharCode:[codecType unsignedIntValue]];
    }
    id codecQuality = [aAttributes objectForKey:@"HSVideoCodecQualityAttribute"];
    if (![codecQuality isKindOfClass:[NSNumber class]] || [codecQuality unsignedIntValue] == 0) {
        codecQuality = [NSNumber numberWithUnsignedInt:0x300];
    }
    NSDictionary *videoAttributes = [NSDictionary dictionaryWithObjectsAndKeys:codec, QTAddImageCodecType, codecQuality, QTAddImageCodecQuality, nil];
    HSThreadContext *context = [[HSThreadContext alloc] initWithVideoFramesAttributes:videoAttributes delegate:self];
    if (context == nil) {
        return NO;
    }
    [NSThread detachNewThreadSelector:@selector(processingThreadRoutine:) toTarget:context withObject:nil];
    if (![context isProcessingThreadRoutineStarted]) {
        [context release];
        return NO;
    }
    _currentThreadContext = context;
    [_currentThreadContext setVideoFramesQueueLimit:_framesQueueLimit];
    if (!_useAudioRecordWorkAround) {
        NSString *audioCompression = [aAttributes objectForKey:@"HSAudioCompressionTypeAttribute"];
        if (![audioCompression isKindOfClass:[NSString class]] || [audioCompression length] == 0) {
            audioCompression = @"QTCompressionOptionsHighQualityAACAudio";
        }
        QTCaptureSession *voiceSession = _voiceCaptureSession;
        if (voiceSession == nil) {
            voiceSession = _voiceCaptureSession = [QTCaptureSession new];
        }
        if (voiceSession != nil && [self HSRecorder_setupAudioDeviceInputForSession:voiceSession device:_voiceCaptureDevice openDevice:aDevice]) {
            QTCaptureMovieFileOutput *output = [QTCaptureMovieFileOutput new];
            if (output != nil) {
                if ([voiceSession addOutput:output error:NULL]) {
                    HSRecorderSetSoundCompression(output, audioCompression);
                    _voiceCaptureFileOutput = output;
                    [output setDelegate:self];
                    [voiceSession startRunning];
                } else {
                    [output release];
                }
            }
        }
        if (_audioOutToInCaptureDevice != nil) {
            QTCaptureSession *outToInSession = _audioOutToInCaptureSession;
            if (outToInSession == nil) {
                outToInSession = _audioOutToInCaptureSession = [QTCaptureSession new];
            }
            if (outToInSession == nil) {
                return NO;
            }
            if (![self HSRecorder_setupAudioDeviceInputForSession:outToInSession device:_audioOutToInCaptureDevice openDevice:aDevice]) {
                return NO;
            }
            QTCaptureMovieFileOutput *output = [QTCaptureMovieFileOutput new];
            if (output == nil) {
                return NO;
            }
            if ([outToInSession addOutput:output error:NULL]) {
                HSRecorderSetSoundCompression(output, audioCompression);
                _audioOutToInCaptureFileOutput = output;
                [output setDelegate:self];
                [outToInSession startRunning];
            } else {
                [output release];
            }
        }
    } else {
        if (_voiceCaptureDevice != nil) {
            _voiceRecorder = [[HSAudioRecorder alloc] initWithAudioDeviceUID:[_voiceCaptureDevice uniqueID]];
            if (_voiceRecorder == nil) {
                return YES;
            }
            [_voiceRecorder setDelegate:self];
        }
        if (_audioOutToInCaptureDevice != nil) {
            _audioOutToInRecorder = [[HSAudioRecorder alloc] initWithAudioDeviceUID:[_audioOutToInCaptureDevice uniqueID]];
            if (_audioOutToInRecorder == nil) {
                return YES;
            }
            [_audioOutToInRecorder setDelegate:self];
        }
    }
    if (_audioOutToInCaptureDevice == nil) {
        [_movieLogger release];
        _movieLogger = [HSMoviePlaybackLogger new];
    }
    return YES;
}

- (BOOL)HSRecorder_setupAudioDeviceInputForSession:(id)aSession device:(id)aDevice openDevice:(BOOL)aDevice2
{
    if (aSession == nil || aDevice == nil) {
        return NO;
    }
    NSError *error = nil;
    QTCaptureDeviceInput **inputPointer;
    if (_voiceCaptureDevice == aDevice) {
        inputPointer = &_voiceCaptureDeviceInput;
    } else if (_audioOutToInCaptureDevice == aDevice) {
        inputPointer = &_audioOutToInCaptureDeviceInput;
    } else {
        return NO;
    }
    QTCaptureDeviceInput *input = *inputPointer;
    if (input != nil) {
        QTCaptureDevice *device = [input device];
        if (!aDevice2) {
            if (![device isConnected] || ![device QTE_isInUseByAnotherApplication]) {
                return NO;
            }
        } else if ([device open:&error]) {
            return YES;
        }
        [input release];
        *inputPointer = nil;
    }
    input = nil;
    if ([aDevice open:&error]) {
        input = [[QTCaptureDeviceInput alloc] initWithDevice:aDevice];
    }
    if (input == nil) {
        return NO;
    }
    // The original left the new input out of the ivar, leaving it dangling after the release above.
    *inputPointer = input;
    return [aSession addInput:input error:&error];
}

- (NSUInteger)framesQueueLimit
{
    return _framesQueueLimit;
}

- (void)setFramesQueueLimit:(NSUInteger)aLimit
{
    _framesQueueLimit = aLimit;
}

- (double)framesPerSecondLimit
{
    return _framesPerSecondLimit;
}

- (void)setFramesPerSecondLimit:(double)aLimit
{
    _framesPerSecondLimit = aLimit;
}

- (id)dataSource
{
    return _dataSource;
}

- (void)setDataSource:(id)aSource
{
    if (_dataSource != aSource) {
        if ([_currentThreadContext outputMovieFilePath] != nil) {
            if (aSource != nil) {
                [_dataSource stopCapturingForConsumer:self];
                [aSource startCapturingForConsumer:self];
            } else {
                [self HSRecorder_cancelRecording];
            }
        }
        [_dataSource release];
        _dataSource = [aSource retain];
    }
}

- (id)delegate
{
    return _delegate;
}

- (void)setDelegate:(id)aDelegate
{
    pthread_mutex_lock((pthread_mutex_t *)&_delegateMutex);
    _delegate = aDelegate;
    pthread_mutex_unlock((pthread_mutex_t *)&_delegateMutex);
}

- (void)release
{
    if (([self retainCount] == 0x1) && (_currentThreadContext != nil)) {
        [self HSRecorder_cancelRecording];
    }
    [super release];
}

- (void)dealloc
{
    [_voiceCaptureFileOutput setDelegate:0];
    [_voiceCaptureFileOutput release];
    [_voiceCaptureSession release];
    [_voiceCaptureDeviceInput release];
    [_voiceCaptureDevice release];
    [_audioOutToInCaptureFileOutput setDelegate:0];
    [_audioOutToInCaptureFileOutput release];
    [_audioOutToInCaptureSession release];
    [_audioOutToInCaptureDeviceInput release];
    [_audioOutToInCaptureDevice release];
    [_voiceRecorder release];
    [_audioOutToInRecorder release];
    [_movieLogger release];
    [_error release];
    CVPixelBufferRelease(_currentFrameBuffer);
    pthread_mutex_destroy((pthread_mutex_t *)&_capturingPreviousTimeMutex);
    pthread_mutex_destroy((pthread_mutex_t *)&_delegateMutex);
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self == nil) {
        return nil;
    }
    pthread_mutexattr_t attributes;
    if (pthread_mutex_init(&_capturingPreviousTimeMutex, NULL) == 0 && pthread_mutexattr_init(&attributes) == 0) {
        // The delegate mutex is recursive: delegate callbacks may call back into the recorder.
        if (pthread_mutexattr_settype(&attributes, PTHREAD_MUTEX_RECURSIVE) == 0 && pthread_mutex_init(&_delegateMutex, &attributes) == 0) {
            pthread_mutexattr_destroy(&attributes);
            _framesPerSecondLimit = 25.0;
            _framesQueueLimit = 50;
            _capturingPreviousTime = -1.0;
            _capturingStartTime = -1.0;
            if ([[HSSystem sharedSystem] quickTimeVersion] < 0x07210001) {
                _useAudioRecordWorkAround = YES;
            }
            return self;
        }
        pthread_mutexattr_destroy(&attributes);
    }
    [super release];
    return nil;
}

- (void)HSRecorder_cancelRecording
{
    if ([_currentThreadContext outputMovieFilePath] != nil) {
        [_dataSource stopCapturingForConsumer:self];
        [_currentThreadContext setAudioCaptirungDidFinish:YES];
        [_currentThreadContext cancelProcessing];
        if (!_useAudioRecordWorkAround) {
            if (_voiceCaptureFileOutput != nil) {
                [_voiceCaptureFileOutput recordToOutputFileURL:nil bufferDestination:QTCaptureFileOutputBufferDestinationOldFile];
                [_voiceCaptureSession stopRunning];
                if ([[_voiceCaptureDeviceInput device] isOpen]) {
                    [[_voiceCaptureDeviceInput device] close];
                }
            }
            if (_audioOutToInCaptureFileOutput != nil) {
                [_audioOutToInCaptureFileOutput recordToOutputFileURL:nil bufferDestination:QTCaptureFileOutputBufferDestinationOldFile];
                [_audioOutToInCaptureSession stopRunning];
                if ([[_audioOutToInCaptureDeviceInput device] isOpen]) {
                    [[_audioOutToInCaptureDeviceInput device] close];
                }
            }
        } else {
            if (_voiceRecorder != nil) {
                [_voiceRecorder stopRecording];
            }
            if (_audioOutToInRecorder != nil) {
                [_audioOutToInRecorder stopRecording];
            }
        }
        if (_movieLogger != nil) {
            [_movieLogger stopLogging];
            [self HSRecorder_loadSoundMovieWithAttributes:nil];
        }
        [_dataSource release];
        _dataSource = nil;
    }
    [_currentThreadContext removeAllSoundMovies];
    pthread_mutex_lock(&_capturingPreviousTimeMutex);
    _capturingPreviousTime = -1.0;
    pthread_mutex_unlock(&_capturingPreviousTimeMutex);
    CVPixelBufferRelease(_currentFrameBuffer);
    _currentFrameBuffer = NULL;
    [_currentThreadContext release];
    _currentThreadContext = nil;
}

@end

@implementation HSThreadContext


+ (id)HSThreadContext_createWorkFolder
{
    NSString *basePath = [[[HSPathsProvider sharedPathsProvider] temporaryFolder] stringByAppendingPathComponent:@"Hypercast"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDirectory = NO;
    if (![fileManager fileExistsAtPath:basePath isDirectory:&isDirectory] || !isDirectory) {
        [fileManager createDirectoryAtPath:basePath withIntermediateDirectories:YES attributes:nil error:NULL];
    }
    NSString *path;
    do {
        path = [basePath stringByAppendingPathComponent:[[HSUID UID] stringValue]];
        if (![fileManager fileExistsAtPath:path isDirectory:&isDirectory]) {
            break;
        }
    } while (isDirectory);
    return [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:NULL] ? path : nil;
}

- (void)processingThreadRoutine:(id)aRoutine
{
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    [QTMovie enterQTKitOnThread];
    _isThreadRoutineStarted = [_movie attachToCurrentThread];
    pthread_mutex_lock(&_processingThreadMutex);
    _isWaitingForActivation = YES;
    pthread_cond_signal(&_processingThreadCondition);
    if (!_isThreadRoutineStarted) {
        pthread_mutex_unlock(&_processingThreadMutex);
    } else {
        while (!_isProcessingCanceled && _outputMovieFilePath == nil) {
            pthread_cond_wait(&_processingThreadCondition, &_processingThreadMutex);
        }
        pthread_mutex_unlock(&_processingThreadMutex);
        if (!_isProcessingCanceled && _outputMovieFilePath != nil) {
            // HSQTKit builds the video track from images, so every frame takes the CGImage path.
            for (;;) {
                pthread_mutex_lock(&_processingThreadMutex);
                struct HSFramesQueueItem *item = NULL;
                while (!_isProcessingCanceled && (item = _videoFramesQueue->f0) == NULL) {
                    pthread_cond_wait(&_processingThreadCondition, &_processingThreadMutex);
                }
                pthread_mutex_unlock(&_processingThreadMutex);
                if (_isProcessingCanceled || item->buffer == NULL) {
                    break;
                }
                NSAutoreleasePool *framePool = [NSAutoreleasePool new];
                CVPixelBufferRef buffer = CVPixelBufferRetain(item->buffer);
                struct HyperStudio_anon7 itemDuration = item->duration;
                pthread_mutex_lock(&_processingThreadMutex);
                struct HSFramesQueue *queue = _videoFramesQueue;
                item = queue->f0;
                if (item != NULL) {
                    // The item moves to the free list.
                    queue->f0 = item->next;
                    if (item->next != NULL) {
                        item->next->previous = NULL;
                    }
                    item->next = queue->f2;
                    if (queue->f2 != NULL) {
                        queue->f2->previous = item;
                    }
                    queue->f2 = item;
                    if (queue->f1 == item) {
                        queue->f1 = NULL;
                    }
                    CVPixelBufferRelease(item->buffer);
                    queue->f3--;
                }
                if (_isWaitingForVideo && _videoFramesQueue->f3 < _videoFramesQueueLimit) {
                    pthread_cond_signal(&_processingThreadCondition);
                }
                pthread_mutex_unlock(&_processingThreadMutex);
                if (buffer == NULL) {
                    break;
                }
                CGImageRef cgImage = (CGImageRef)CVBufferGetAttachment(buffer, CFSTR("HSPixelBufferCGImage"), NULL);
                if (cgImage == NULL) {
                    cgImage = CGEImageCreateWithPixelBuffer(buffer, kCVPixelBufferLock_ReadOnly, NULL, true, kCGRenderingIntentDefault);
                } else {
                    CGImageRetain(cgImage);
                }
                if (cgImage == NULL) {
                    break;
                }
                CGFloat imageWidth = CGImageGetWidth(cgImage);
                CGFloat imageHeight = CGImageGetHeight(cgImage);
                NSSize frameSize = NSEqualSizes(_movieSize, NSZeroSize) ? NSMakeSize(imageWidth, imageHeight) : _movieSize;
                NSRect drawRect = NSMakeRect(0.0, 0.0, imageWidth, imageHeight);
                NSImage *image = [[NSImage alloc] initWithSize:frameSize];
                if (!NSEqualSizes(frameSize, NSMakeSize(imageWidth, imageHeight))) {
                    CGFloat scale = imageHeight / frameSize.height;
                    if (scale <= imageWidth / frameSize.width) {
                        scale = imageWidth / frameSize.width;
                    }
                    drawRect.size = NSMakeSize(floor(imageWidth / scale), floor(imageHeight / scale));
                    drawRect.origin = NSMakePoint((frameSize.width - drawRect.size.width) * 0.5, (frameSize.height - drawRect.size.height) * 0.5);
                }
                [image lockFocus];
                if (_roundedCornersForMovie) {
                    if (_cornersClipPath == nil) {
                        _cornersClipPath = [[NSBezierPath smkRoundedBorderPathWithRect:drawRect cornerRadius:16.0] retain];
                    }
                    [[NSColor blackColor] set];
                    NSRectFill(drawRect);
                    [_cornersClipPath setClip];
                }
                CGContextDrawImage((CGContextRef)[[NSGraphicsContext currentContext] graphicsPort], NSRectToCGRect(drawRect), cgImage);
                [image unlockFocus];
                CGImageRelease(cgImage);
                QTTime duration = HSRecorderQTTimeFromDuration(itemDuration);
                [_movie addImage:image forDuration:duration withAttributes:_videoFramesAttributes];
                [image release];
                CVPixelBufferRelease(buffer);
                [framePool release];
            }
            pthread_mutex_lock(&_processingThreadMutex);
            _isWaitingForAudio = YES;
            if (_isAudioCapturingUsed && !_isAudioCaptirungDidFinish) {
                pthread_cond_wait(&_processingThreadCondition, &_processingThreadMutex);
            }
            _isWaitingForAudio = NO;
            QTTime movieDuration = [_movie duration];
            double movieSeconds = (movieDuration.timeScale != 0) ? (double)movieDuration.timeValue / (double)movieDuration.timeScale : 0.0;
            NSMutableArray *soundMovies = _soundMovies;
            _soundMovies = nil;
            pthread_mutex_unlock(&_processingThreadMutex);
            for (NSDictionary *entry in soundMovies) {
                QTMovie *soundMovie = [entry objectForKey:@"HSRecorderQTMovieKey"];
                if (soundMovie == nil) {
                    continue;
                }
                HSMoviePlaybackLogItem *playbackItem = [entry objectForKey:@"HSRecorderPlaybackAttributesKey"];
                [soundMovie attachToCurrentThread];
                NSArray *soundTracks = [soundMovie tracksOfMediaType:QTMediaTypeSound];
                NSUInteger trackCount = (movieSeconds != 0.0) ? [soundTracks count] : 0;
                long soundScale = [soundMovie duration].timeScale;
                short volume = (playbackItem == nil) ? 0x100 : (short)(int)([playbackItem volume] * 256.0);
                double currentPlaybackTime = [playbackItem currentPlaybackTime];
                for (NSUInteger i = trackCount; i > 0 && !_isProcessingCanceled; i--) {
                    QTTrack *soundTrack = [soundTracks objectAtIndex:i - 1];
                    double startTime = 0.0;
                    double length;
                    if (playbackItem != nil) {
                        startTime = [playbackItem startTime];
                    }
                    if (playbackItem != nil && [playbackItem duration] > 0.0) {
                        length = [playbackItem duration];
                    } else {
                        NSTimeInterval soundSeconds = 0.0;
                        QTGetTimeInterval([soundMovie duration], &soundSeconds);
                        length = soundSeconds;
                    }
                    if (movieSeconds < startTime + length) {
                        length = movieSeconds - startTime;
                    }
                    // InsertTrackSegment on a new movie track in the original; HSQTKit inserts the segment itself.
                    QTTimeRange source = QTMakeTimeRange(QTMakeTime((long long)(currentPlaybackTime * soundScale), soundScale), QTMakeTime((long long)(length * soundScale), soundScale));
                    QTTrack *inserted = [_movie insertSegmentOfTrack:soundTrack timeRange:source atTime:QTMakeTime((long long)(startTime * 600.0), 600)];
                    [inserted setVolume:(float)volume / 256.0f];
                    if ([[(id)[playbackItem movie] valueForKey:@"soundFadeOutTime"] doubleValue] > 0.0005 && inserted != nil) {
                        [self scheduleAddingNotThreadSafeComponentForTrackWithID:[[inserted attributeForKey:QTTrackIDAttribute] longValue] attributes:entry];
                    }
                }
                [soundMovie detachFromCurrentThread];
            }
            [soundMovies release];
            if (_scheduledProcessing != nil) {
                // The fade-outs are applied on the playback thread (QuickTime tween tracks are not thread safe).
                _isThreadRoutineStarted = ![_movie detachFromCurrentThread];
                [self performSelector:@selector(processNotThreadSafeComponent) onThread:[_delegate playbackThread] withObject:nil waitUntilDone:NO];
            } else {
                [self writeMovieToFile];
            }
        }
    }
    if (_isThreadRoutineStarted) {
        [_movie detachFromCurrentThread];
    }
    [QTMovie exitQTKitOnThread];
    [pool release];
}

- (void)writeMovieToFile
{
    NSMutableDictionary *exportAttributes = [NSMutableDictionary new];
    if ([_videoFramesAttributes objectForKey:QTAddImageCodecType] != nil) {
        [exportAttributes setObject:[NSNumber numberWithBool:YES] forKey:QTMovieExport];
        [exportAttributes setObject:[NSNumber numberWithLong:'MooV'] forKey:QTMovieExportType];
    }
    [_movie updateMovieFile];
    NSError *error = nil;
    if (!_isProcessingCanceled) {
        if (![_movie writeToFile:_outputMovieFilePath withAttributes:exportAttributes]) {
            error = [HSError fileErrorWithHSCode:0x200 filePath:_outputMovieFilePath];
        }
    }
    [exportAttributes release];
    pthread_mutex_lock(&_delegateMutex);
    if (!_isProcessingCanceled) {
        [_delegate HSThreadContextDelegate_threadContext:self didFinishFlatteningToFile:_outputMovieFilePath dueToError:error];
    }
    pthread_mutex_unlock(&_delegateMutex);
}

- (void)processNotThreadSafeComponent
{
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    [QTMovie enterQTKitOnThread];
    [_movie attachToCurrentThread];
    // The original also added a fade-out (a QuickTime tween track, FUN_002a3e08) to the sound tracks scheduled
    // in _scheduledProcessing whose movie has a sound fade-out time; HSQTKit tracks have no volume ramp, so
    // the sounds are written without it.
    [self writeMovieToFile];
    [QTMovie exitQTKitOnThread];
    [pool drain];
}

- (void)scheduleAddingNotThreadSafeComponentForTrackWithID:(NSInteger)aID attributes:(id)aAttributes
{
    id self_00;

    self_00 = _scheduledProcessing;
    if (self_00 == nil) {
        self_00 = [NSMutableDictionary new];
        _scheduledProcessing = self_00;
    }
    if (aAttributes != nil) {
        [self_00 setObject:aAttributes forKey:[NSNumber numberWithLong:aID]];
    }
}

- (BOOL)isProcessingThreadRoutineStarted
{
    pthread_mutex_lock(&_processingThreadMutex);
    // Wait until the processing thread has either started or given up; the wait is retried every 10 seconds.
    do {
        if (_isWaitingForActivation) {
            break;
        }
        struct timespec timeout;
        timeout.tv_sec = time(NULL) + 10;
        timeout.tv_nsec = 0;
        if (pthread_cond_timedwait(&_processingThreadCondition, &_processingThreadMutex, &timeout) != 0) {
            break;
        }
    } while (YES);
    pthread_mutex_unlock(&_processingThreadMutex);
    return _isThreadRoutineStarted;
}

- (BOOL)removeFrameItemWithSmallestDuration:(double)aDuration removedLastFrameDuration:(double *)aDuration2
{
    BOOL removed = NO;
    pthread_mutex_lock(&_processingThreadMutex);
    if (_videoFramesQueue != NULL && _videoFramesQueue->f1 != NULL) {
        QTTime threshold = QTMakeTime(llroundf((float)(aDuration * 600.0)), 600);
        struct HSFramesQueueItem *smallest = NULL;
        // Walk from the newest frame back to the oldest, keeping the shortest one under the threshold.
        for (struct HSFramesQueueItem *item = _videoFramesQueue->f1; item != NULL; item = item->previous) {
            QTTime limit = (smallest != NULL) ? HSRecorderQTTimeFromDuration(smallest->duration) : threshold;
            if (QTTimeCompare(HSRecorderQTTimeFromDuration(item->duration), limit) == NSOrderedAscending) {
                smallest = item;
            }
        }
        if (smallest != NULL) {
            if (_videoFramesQueue->f0 == _videoFramesQueue->f1) {
                if (aDuration2 != NULL) {
                    QTGetTimeInterval(HSRecorderQTTimeFromDuration(smallest->duration), aDuration2);
                }
            } else {
                // The dropped frame's time goes to its neighbour (the previous frame, else the next one).
                struct HSFramesQueueItem *neighbour = (smallest->previous != NULL) ? smallest->previous : smallest->next;
                if (neighbour != NULL) {
                    QTTime merged = QTTimeIncrement(HSRecorderQTTimeFromDuration(neighbour->duration), HSRecorderQTTimeFromDuration(smallest->duration));
                    neighbour->duration.f0 = merged.timeValue;
                    neighbour->duration.f1 = (int)merged.timeScale;
                    neighbour->duration.f2 = (int)merged.flags;
                }
            }
            struct HSFramesQueue *queue = _videoFramesQueue;
            if (queue->f0 != NULL) {
                struct HSFramesQueueItem *previous = smallest->previous;
                struct HSFramesQueueItem *next = smallest->next;
                if (previous == NULL) {
                    queue->f0 = next;
                } else {
                    previous->next = next;
                }
                if (next == NULL) {
                    queue->f1 = previous;
                } else {
                    next->previous = previous;
                }
                // The item goes to the free list for reuse.
                smallest->next = queue->f2;
                if (queue->f2 != NULL) {
                    queue->f2->previous = smallest;
                }
                queue->f2 = smallest;
                CVPixelBufferRelease(smallest->buffer);
                queue->f3--;
            }
            removed = YES;
        }
    }
    pthread_mutex_unlock(&_processingThreadMutex);
    return removed;
}

- (void)addNewItemWithFrameBuffer:(struct __CVBuffer *)aBuffer duration:(struct HyperStudio_anon7)aDuration isLastFrame:(BOOL)aFrame
{
    pthread_mutex_lock(&_processingThreadMutex);
    _isWaitingForVideo = YES;
    struct HSFramesQueue *queue = _videoFramesQueue;
    while (_videoFramesQueueLimit <= queue->f3) {
        pthread_cond_wait(&_processingThreadCondition, &_processingThreadMutex);
        queue = _videoFramesQueue;
    }
    _isWaitingForVideo = NO;
    struct HSFramesQueueItem *item = HSRecorderFramesQueueAppendItem(queue);
    if (item != NULL) {
        item->buffer = CVPixelBufferRetain(aBuffer);
        item->duration = aDuration;
    }
    if (_videoFramesQueue->f3 == 1) {
        pthread_cond_signal(&_processingThreadCondition);
    }
    if (aFrame) {
        // An item without a buffer marks the end of the recording.
        HSRecorderFramesQueueAppendItem(_videoFramesQueue);
    }
    pthread_mutex_unlock(&_processingThreadMutex);
}

- (void)cancelProcessing
{
    pthread_mutex_lock(&_delegateMutex);
    _delegate = nil;
    pthread_mutex_unlock(&_delegateMutex);
    pthread_mutex_lock(&_processingThreadMutex);
    _isProcessingCanceled = YES;
    if (_videoFramesQueue->f3 == 0) {
        pthread_cond_signal(&_processingThreadCondition);
    }
    pthread_mutex_unlock(&_processingThreadMutex);
}

- (void)setAudioCaptirungDidFinish:(BOOL)aFinish
{
    if (_isAudioCapturingUsed) {
        pthread_mutex_lock(&_processingThreadMutex);
        _isAudioCaptirungDidFinish = aFinish;
        if (_isWaitingForAudio) {
            pthread_cond_signal(&_processingThreadCondition);
        }
        pthread_mutex_unlock(&_processingThreadMutex);
    }
}

- (void)removeAllSoundMovies
{
    pthread_mutex_lock((pthread_mutex_t *)&_processingThreadMutex);
    [_soundMovies release];
    _soundMovies = nil;
    pthread_mutex_unlock((pthread_mutex_t *)&_processingThreadMutex);
}

- (void)addSoundMovieWithAttributes:(id)aAttributes
{
    if (_isAudioCapturingUsed) {
        pthread_mutex_lock(&_processingThreadMutex);
        if (_soundMovies == nil) {
            _soundMovies = [NSMutableArray new];
        }
        if (aAttributes != nil) {
            [_soundMovies addObject:aAttributes];
        }
        pthread_mutex_unlock(&_processingThreadMutex);
    }
}

- (id)videoFramesAttributes
{
    return _videoFramesAttributes;
}

- (void)setVideoFramesQueueLimit:(NSUInteger)aLimit
{
    unsigned int uVar1;

    uVar1 = 1;
    if (aLimit != 0) {
        uVar1 = aLimit;
    }
    _videoFramesQueueLimit = uVar1;
}

- (NSUInteger)videoFramesQueueLimit
{
    return _videoFramesQueueLimit;
}

- (id)outputMovieFilePath
{
    return _outputMovieFilePath;
}

- (id)workFolderPath
{
    return _workFolderPath;
}

- (void)capturingDidStartForOutputFilePath:(id)aPath isAudioCapturingUsed:(BOOL)aUsed isRoundedCorners:(BOOL)aCorners movieSize:(NSSize)aSize
{
    _isAudioCapturingUsed = aUsed;
    _roundedCornersForMovie = aCorners;
    _movieSize = aSize;
    pthread_mutex_lock(&_processingThreadMutex);
    _outputMovieFilePath = [aPath copy];
    pthread_cond_signal(&_processingThreadCondition);
    pthread_mutex_unlock(&_processingThreadMutex);
}

- (void)dealloc
{
    NSURL *movieURL = [[_movie attributeForKey:QTMovieURLAttribute] retain];
    [_cornersClipPath release];
    // CloseMovieStorage(_movieStorage) in the original; HSQTKit movies have no separate storage.
    [_scheduledProcessing release];
    [_movie release];
    if (movieURL != nil) {
        [[NSFileManager defaultManager] removeItemAtPath:[movieURL path] error:NULL];
        [movieURL release];
    }
    [_soundMovies release];
    struct HSFramesQueue *queue = _videoFramesQueue;
    if (queue != NULL) {
        while (queue->f0 != NULL) {
            struct HSFramesQueueItem *item = queue->f0;
            queue->f1 = item;
            queue->f0 = item->next;
            CVPixelBufferRelease(item->buffer);
            free(queue->f1);
        }
        while (queue->f2 != NULL) {
            struct HSFramesQueueItem *item = queue->f2;
            queue->f1 = item;
            queue->f2 = item->next;
            free(item);
        }
        free(queue);
    }
    pthread_cond_destroy(&_processingThreadCondition);
    pthread_mutex_destroy(&_processingThreadMutex);
    pthread_mutex_destroy(&_delegateMutex);
    [_outputMovieFilePath release];
    [_videoFramesAttributes release];
    if (_workFolderPath != nil) {
        BOOL isDirectory = NO;
        if ([[NSFileManager defaultManager] fileExistsAtPath:_workFolderPath isDirectory:&isDirectory] && isDirectory) {
            [[NSFileManager defaultManager] removeItemAtPath:_workFolderPath error:NULL];
        }
        [_workFolderPath release];
    }
    if (_packedPixelsBuffer != NULL) {
        free(_packedPixelsBuffer);
    }
    [super dealloc];
}

- (id)initWithVideoFramesAttributes:(id)aAttributes delegate:(id)aDelegate
{
    self = [super init];
    if (self == nil) {
        return nil;
    }
    if (aAttributes != nil
        && pthread_mutex_init(&_delegateMutex, NULL) == 0
        && pthread_mutex_init(&_processingThreadMutex, NULL) == 0
        && pthread_cond_init(&_processingThreadCondition, NULL) == 0) {
        _videoFramesQueue = malloc(sizeof(struct HSFramesQueue));
        if (_videoFramesQueue != NULL) {
            _videoFramesQueue->f0 = NULL;
            _videoFramesQueue->f1 = NULL;
            _videoFramesQueue->f2 = NULL;
            _videoFramesQueue->f3 = 0;
            _workFolderPath = [[[self class] HSThreadContext_createWorkFolder] retain];
            if (_workFolderPath != nil) {
                NSString *moviePath = [_workFolderPath stringByAppendingPathComponent:@"video.mov"];
                // The original made the movie with QTNewDataReferenceFromFullPathCFString and CreateMovieStorage;
                // HSQTKit writes the movie to the file directly.
                _movie = [[QTMovie alloc] initToWritableFile:moviePath error:NULL];
                if (_movie != nil) {
                    [_movie setAttribute:[NSNumber numberWithBool:YES] forKey:QTMovieEditableAttribute];
                    [_movie setAttribute:[NSNumber numberWithLong:600] forKey:QTMovieTimeScaleAttribute];
                    [_movie setAttribute:[NSNumber numberWithBool:NO] forKey:QTMovieDontInteractWithUserAttribute];
                    [_movie setAttribute:@"video.mov" forKey:QTMovieFileNameAttribute];
                    NSURL *url = [NSURL fileURLWithPath:moviePath];
                    if (url != nil) {
                        [_movie setAttribute:url forKey:QTMovieURLAttribute];
                    }
                    if ([_movie detachFromCurrentThread]) {
                        _videoFramesQueueLimit = 50;
                        _videoFramesAttributes = [aAttributes copy];
                        _delegate = aDelegate;
                        return self;
                    }
                }
            }
        }
    }
    [super release];
    return nil;
}

@end

