#import "AUInputDeviceFile.h"
#import "NSString+SMKAudioFoundationEXUniqueFilename.h"

// Records the default input device into a file. The original (AIFileDevice)
// read the device with an IOProc into a buffer list queue that a file output
// AudioUnit of its own (registered by +initialize) pulled from; here an input
// audio queue hands its buffers to ExtAudioFile, which converts them to the
// file's format: 16-bit integer PCM, or the output format ID asked for. The
// file type follows the extension (AIFF by default, AIFC for compressed
// data in an AIFF file). Errors writing go to the delegate's
// handleDeviceFile:recordingError: on the main thread.

enum { kAIPrivateAudioDataBufferCount = 3 };

@interface _AIPrivateAudioData : NSObject
{
@public
    AUInputDeviceFile *_owner;          // not retained
    NSString *_filename;
    UInt32 _outputFormatID;
    AudioStreamBasicDescription _format;
    AudioQueueRef _queue;
    ExtAudioFileRef _file;
    volatile BOOL _isRecording;
    volatile BOOL _isPaused;
    float *_signalVolumes;
    UInt32 _signalVolumeCount;
}
- (id)initWithFilename:(NSString *)aFilename owner:(AUInputDeviceFile *)aOwner outputFormatID:(UInt32)aID;
- (void)startRecording;
- (void)stopRecording;
@end

static void AIPrivateAudioDataInput(void *aData, AudioQueueRef aQueue, AudioQueueBufferRef aBuffer, const AudioTimeStamp *aStartTime,
                                    UInt32 aPacketCount, const AudioStreamPacketDescription *aPacketDescriptions);

@implementation _AIPrivateAudioData

// The default input device's sample rate and channels, as interleaved floats.
static BOOL AIPrivateAudioDataInputFormat(AudioStreamBasicDescription *aFormat)
{
    AudioObjectPropertyAddress address = { kAudioHardwarePropertyDefaultInputDevice, kAudioObjectPropertyScopeGlobal, kAudioObjectPropertyElementMain };
    AudioObjectID device = kAudioObjectUnknown;
    UInt32 size = sizeof(device);
    if (AudioObjectGetPropertyData(kAudioObjectSystemObject, &address, 0, NULL, &size, &device) != noErr || device == kAudioObjectUnknown)
        return NO;
    AudioStreamBasicDescription deviceFormat = { 0 };
    address.mSelector = kAudioDevicePropertyStreamFormat;
    address.mScope = kAudioDevicePropertyScopeInput;
    size = sizeof(deviceFormat);
    if (AudioObjectGetPropertyData(device, &address, 0, NULL, &size, &deviceFormat) != noErr || deviceFormat.mSampleRate <= 0 || deviceFormat.mChannelsPerFrame == 0)
        return NO;
    UInt32 channels = deviceFormat.mChannelsPerFrame;
    AudioStreamBasicDescription format = { deviceFormat.mSampleRate, kAudioFormatLinearPCM, kAudioFormatFlagsNativeFloatPacked,
                                           4 * channels, 1, 4 * channels, channels, 32, 0 };
    *aFormat = format;
    return YES;
}

static AudioFileTypeID AIPrivateAudioDataFileType(NSString *aFilename, UInt32 aFormatID)
{
    NSString *extension = [[aFilename pathExtension] lowercaseString];
    if ([extension isEqualToString:@"wav"] || [extension isEqualToString:@"wave"])
        return kAudioFileWAVEType;
    if ([extension isEqualToString:@"caf"])
        return kAudioFileCAFType;
    if ([extension isEqualToString:@"m4a"])
        return kAudioFileM4AType;
    if ([extension isEqualToString:@"aifc"] || (aFormatID != 0 && aFormatID != kAudioFormatLinearPCM))
        return kAudioFileAIFCType;
    return kAudioFileAIFFType;
}

- (id)initWithFilename:(NSString *)aFilename owner:(AUInputDeviceFile *)aOwner outputFormatID:(UInt32)aID
{
    if (aFilename == nil) {
        [self release];
        return nil;
    }
    if ((self = [super init])) {
        _owner = aOwner;
        _filename = [aFilename copy];
        _outputFormatID = aID;
        if (!AIPrivateAudioDataInputFormat(&_format)
            || AudioQueueNewInput(&_format, AIPrivateAudioDataInput, self, NULL, kCFRunLoopCommonModes, 0, &_queue) != noErr) {
            [self release];
            return nil;
        }
        _signalVolumeCount = _format.mChannelsPerFrame;
        _signalVolumes = calloc(_signalVolumeCount, sizeof(float));
        UInt32 bufferSize = (UInt32)(_format.mSampleRate / 10) * _format.mBytesPerFrame;
        for (int i = 0; i < kAIPrivateAudioDataBufferCount; i++) {
            AudioQueueBufferRef buffer = NULL;
            if (AudioQueueAllocateBuffer(_queue, bufferSize, &buffer) == noErr)
                AudioQueueEnqueueBuffer(_queue, buffer, 0, NULL);
        }
    }
    return self;
}

- (void)dealloc
{
    [self stopRecording];
    if (_queue != NULL)
        AudioQueueDispose(_queue, true);
    free(_signalVolumes);
    [_filename release];
    [super dealloc];
}

- (void)reportError:(NSNumber *)aError
{
    id delegate = [_owner delegate];
    if ([delegate respondsToSelector:@selector(handleDeviceFile:recordingError:)])
        [delegate handleDeviceFile:_owner recordingError:[aError integerValue]];
}

- (void)reportErrorFromAnyThread:(OSStatus)aError
{
    [self performSelectorOnMainThread:@selector(reportError:) withObject:[NSNumber numberWithInt:aError] waitUntilDone:NO];
}

- (AudioStreamBasicDescription)fileFormatForType:(AudioFileTypeID)aType
{
    AudioStreamBasicDescription format = { _format.mSampleRate, _outputFormatID, 0, 0, 0, 0, _format.mChannelsPerFrame, 0, 0 };
    if (_outputFormatID == 0 || _outputFormatID == kAudioFormatLinearPCM) {
        UInt32 bigEndian = aType == kAudioFileAIFFType || aType == kAudioFileAIFCType ? kAudioFormatFlagIsBigEndian : 0;
        format.mFormatID = kAudioFormatLinearPCM;
        format.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked | bigEndian;
        format.mBitsPerChannel = 16;
        format.mBytesPerFrame = format.mBytesPerPacket = 2 * format.mChannelsPerFrame;
        format.mFramesPerPacket = 1;
    } else {
        UInt32 size = sizeof(format);
        AudioFormatGetProperty(kAudioFormatProperty_FormatInfo, 0, NULL, &size, &format);
    }
    return format;
}

- (void)startRecording
{
    if (_isRecording)
        return;
    AudioFileTypeID type = AIPrivateAudioDataFileType(_filename, _outputFormatID);
    AudioStreamBasicDescription fileFormat = [self fileFormatForType:type];
    NSURL *url = [NSURL fileURLWithPath:_filename];
    OSStatus error = ExtAudioFileCreateWithURL((CFURLRef)url, type, &fileFormat, NULL, kAudioFileFlags_EraseFile, &_file);
    if (error == noErr)
        error = ExtAudioFileSetProperty(_file, kExtAudioFileProperty_ClientDataFormat, sizeof(_format), &_format);
    // Sets up the asynchronous writer outside the audio queue's thread.
    if (error == noErr)
        error = ExtAudioFileWriteAsync(_file, 0, NULL);
    if (error == noErr) {
        _isRecording = YES;
        _isPaused = NO;
        error = AudioQueueStart(_queue, NULL);
    }
    if (error != noErr) {
        _isRecording = NO;
        if (_file != NULL) {
            ExtAudioFileDispose(_file);
            _file = NULL;
        }
        [self reportErrorFromAnyThread:error];
    }
}

- (void)stopRecording
{
    if (!_isRecording)
        return;
    _isPaused = YES;
    AudioQueueStop(_queue, true);
    _isRecording = NO;
    if (_file != NULL) {
        OSStatus error = ExtAudioFileDispose(_file);
        _file = NULL;
        if (error != noErr)
            [self reportErrorFromAnyThread:error];
    }
}

// Original quirk kept: a channel's signal volume is its sample in the
// buffer's second frame.
static void AIPrivateAudioDataInput(void *aData, AudioQueueRef aQueue, AudioQueueBufferRef aBuffer, const AudioTimeStamp *aStartTime,
                                    UInt32 aPacketCount, const AudioStreamPacketDescription *aPacketDescriptions)
{
    _AIPrivateAudioData *data = (_AIPrivateAudioData *)aData;
    UInt32 frames = aBuffer->mAudioDataByteSize / data->_format.mBytesPerFrame;
    const float *samples = aBuffer->mAudioData;
    if (frames > 1)
        for (UInt32 channel = 0; channel < data->_signalVolumeCount; channel++)
            data->_signalVolumes[channel] = samples[data->_format.mChannelsPerFrame + channel];
    if (data->_isRecording && !data->_isPaused && frames > 0 && data->_file != NULL) {
        AudioBufferList list = { 1, { { data->_format.mChannelsPerFrame, aBuffer->mAudioDataByteSize, aBuffer->mAudioData } } };
        OSStatus error = ExtAudioFileWriteAsync(data->_file, frames, &list);
        if (error != noErr)
            [data reportErrorFromAnyThread:error];
    }
    if (data->_isRecording)
        AudioQueueEnqueueBuffer(aQueue, aBuffer, 0, NULL);
}

@end

@implementation AUInputDeviceFile

// The original registered its file output AudioUnit here.
+ (void)initialize
{
}

- (void)setFilename:(id)aFilename
{
    if (_filename != aFilename) {
        [_filename release];
        _filename = [aFilename retain];
    }
}

- (void)setDelegate:(id)aDelegate
{
    _delegate = aDelegate;
}

- (id)delegate
{
    return _delegate;
}

- (id)filename
{
    return _filename;
}

- (void)invalidate
{
    [self createEmptyFile];
}

// Moves the recording away; recording again starts a new file.
- (BOOL)writeToFile:(id)aFile atomically:(BOOL)aAtomically
{
    if (![[NSFileManager defaultManager] moveItemAtPath:_filename toPath:aFile error:NULL])
        return NO;
    return [self createEmptyFile];
}

- (BOOL)createEmptyFile
{
    if (_filename != nil)
        [[NSFileManager defaultManager] createFileAtPath:_filename contents:nil attributes:nil];
    return YES;
}

- (BOOL)hasData
{
    return [[NSData dataWithContentsOfFile:_filename options:NSDataReadingMappedIfSafe error:NULL] length] != 0;
}

- (CGFloat)signalVolumeForChannel:(NSUInteger)aChannel
{
    if (aChannel >= [self channelCount])
        return 0;
    _AIPrivateAudioData *data = _privateAudioData;
    return data->_signalVolumes[aChannel];
}

- (NSUInteger)channelCount
{
    return ((_AIPrivateAudioData *)_privateAudioData)->_signalVolumeCount;
}

- (BOOL)isPaused
{
    return ((_AIPrivateAudioData *)_privateAudioData)->_isPaused;
}

- (void)resume
{
    ((_AIPrivateAudioData *)_privateAudioData)->_isPaused = NO;
}

- (void)pause
{
    ((_AIPrivateAudioData *)_privateAudioData)->_isPaused = YES;
}

- (BOOL)isRunning
{
    return ((_AIPrivateAudioData *)_privateAudioData)->_isRecording;
}

- (void)stop
{
    [(_AIPrivateAudioData *)_privateAudioData stopRecording];
}

- (void)start
{
    [self invalidate];
    [(_AIPrivateAudioData *)_privateAudioData startRecording];
}

- (void)dealloc
{
    [(_AIPrivateAudioData *)_privateAudioData release];
    _privateAudioData = NULL;
    [[NSFileManager defaultManager] removeItemAtPath:_filename error:NULL];
    [_filename release];
    [super dealloc];
}

- (id)init
{
    return [self initWithFilename:[NSTemporaryDirectory() stringByAppendingPathComponent:@"AUInputDeviceFile.aiff"] outputFormatID:0];
}

// A unique file next to the name asked for.
- (id)initWithFilename:(id)aFilename outputFormatID:(NSUInteger)aID
{
    if ((self = [super init])) {
        NSString *filename = [NSString _audioCreateUniqueFilename:[aFilename stringByDeletingPathExtension] extension:[aFilename pathExtension]];
        [self setFilename:filename];
        _privateAudioData = [[_AIPrivateAudioData alloc] initWithFilename:filename owner:self outputFormatID:(UInt32)aID];
        if (_privateAudioData != NULL)
            return self;
        [self release];
    }
    return nil;
}

- (id)initWithFilename:(id)aFilename
{
    return [self initWithFilename:aFilename outputFormatID:0];
}

@end
