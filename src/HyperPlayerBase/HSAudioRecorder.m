#import "HSAudioRecorder.h"

// Records an input device into an AAC (MPEG-4 audio) file: the HAL output
// unit with input enabled renders each device buffer into a buffer list in
// the device's format, which ExtAudioFile converts and writes.

static const AudioStreamBasicDescription HSAACFormat = { 44100.0, kAudioFormatMPEG4AAC, kMPEG4Object_AAC_LC, 0, 1024, 0, 2, 0, 0 };

// The buffer list with what its buffer holds, as rendering sets the byte size
// to what it rendered.
typedef struct {
    AudioBufferList list;
    UInt32 capacity;
} HSAudioRecorderBufferList;

static OSStatus HSAudioRecorderInput(void *aRecorder, AudioUnitRenderActionFlags *aFlags, const AudioTimeStamp *aTimeStamp, UInt32 aBus, UInt32 aFrameCount, AudioBufferList *aData)
{
    HSAudioRecorder *recorder = (HSAudioRecorder *)aRecorder;
    AudioUnit unit = [recorder audioUnit];
    AudioBufferList *list = [recorder audioBufferList];
    if (unit == NULL || list == NULL)
        return noErr;
    // Fix: the original never gave the buffer its whole size back.
    list->mBuffers[0].mDataByteSize = ((HSAudioRecorderBufferList *)list)->capacity;
    OSStatus error = AudioUnitRender(unit, aFlags, aTimeStamp, aBus, aFrameCount, list);
    if (error == noErr)
        error = ExtAudioFileWrite([recorder audioFile], aFrameCount, list);
    if (error != noErr)
        [recorder cancelRecording];
    return error;
}

@implementation HSAudioRecorder

- (void)stopRecording
{
    if (!_isRecording)
        return;
    if ([_delegate respondsToSelector:@selector(audioRecorder:willFinishRecordingToFileAtURL:dueToError:)])
        [_delegate audioRecorder:self willFinishRecordingToFileAtURL:_outputFileURL dueToError:nil];
    AudioOutputUnitStop(_audioUnit);
    ExtAudioFileDispose(_audioFile);
    // Fix: the original kept the disposed file.
    _audioFile = NULL;
    _isRecording = NO;
    if ([_delegate respondsToSelector:@selector(audioRecorder:didFinishRecordingToFileAtURL:dueToError:)])
        [_delegate audioRecorder:self didFinishRecordingToFileAtURL:_outputFileURL dueToError:nil];
}

- (void)cancelRecording
{
    if (!_isRecording)
        return;
    [self stopRecording];
    NSString *path = [_outputFileURL path];
    NSFileManager *manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:path])
        [manager removeItemAtPath:path error:NULL];
}

- (BOOL)startRecordingToFileAtURL:(id)aURL
{
    if (aURL == nil && _audioDeviceID == 0)
        return NO;
    if ([_delegate respondsToSelector:@selector(audioRecorder:willStartRecordingToFileAtURL:)])
        [_delegate audioRecorder:self willStartRecordingToFileAtURL:aURL];
    [_outputFileURL release];
    _outputFileURL = [aURL copy];
    if (_outputFileURL == nil || ![self configureOutputFileWithURL:_outputFileURL] || ![self configureAU] || AudioOutputUnitStart(_audioUnit) != noErr)
        return NO;
    _isRecording = YES;
    if ([_delegate respondsToSelector:@selector(audioRecorder:didStartRecordingToFileAtURL:)])
        [_delegate audioRecorder:self didStartRecordingToFileAtURL:aURL];
    return YES;
}

// A new AAC file, written from the device's input format.
- (BOOL)configureOutputFileWithURL:(id)aURL
{
    if ([aURL isFileURL]
        && ExtAudioFileCreateWithURL((CFURLRef)aURL, kAudioFileM4AType, &HSAACFormat, NULL, 0, &_audioFile) == noErr) {
        AudioStreamBasicDescription format = { 0 };
        UInt32 size = sizeof(format);
        AudioObjectPropertyAddress address = { kAudioDevicePropertyStreamFormat, kAudioDevicePropertyScopeInput, kAudioObjectPropertyElementMain };
        if (AudioObjectGetPropertyData(_audioDeviceID, &address, 0, NULL, &size, &format) == noErr
            && ExtAudioFileSetProperty(_audioFile, kExtAudioFileProperty_ClientDataFormat, size, &format) == noErr)
            return YES;
    }
    if (_audioFile != NULL) {
        ExtAudioFileDispose(_audioFile);
        _audioFile = NULL;
    }
    return NO;
}

// The HAL output unit on the device, input only, calling back for each
// buffer, with a buffer list for one buffer of the device's input format.
- (BOOL)configureAU
{
    OSStatus error = noErr;
    if (_audioUnit == NULL) {
        AudioComponentDescription description = { kAudioUnitType_Output, kAudioUnitSubType_HALOutput, kAudioUnitManufacturer_Apple, 0, 0 };
        AudioComponent component = AudioComponentFindNext(NULL, &description);
        if (component == NULL)
            return NO;
        if ((error = AudioComponentInstanceNew(component, &_audioUnit)) != noErr) {
            _audioUnit = NULL;
            return NO;
        }
    }
    UInt32 enable = 1;
    if ((error = AudioUnitSetProperty(_audioUnit, kAudioOutputUnitProperty_EnableIO, kAudioUnitScope_Input, 1, &enable, sizeof(enable))) == noErr) {
        enable = 0;
        error = AudioUnitSetProperty(_audioUnit, kAudioOutputUnitProperty_EnableIO, kAudioUnitScope_Output, 0, &enable, sizeof(enable));
    }
    if (error == noErr)
        error = AudioUnitSetProperty(_audioUnit, kAudioOutputUnitProperty_CurrentDevice, kAudioUnitScope_Global, 0, &_audioDeviceID, sizeof(_audioDeviceID));
    if (error == noErr) {
        AURenderCallbackStruct callback = { HSAudioRecorderInput, self };
        AudioUnitSetProperty(_audioUnit, kAudioOutputUnitProperty_SetInputCallback, kAudioUnitScope_Global, 0, &callback, sizeof(callback));
        AudioStreamBasicDescription format = { 0 };
        UInt32 size = sizeof(format);
        if ((error = AudioUnitGetProperty(_audioUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, 1, &format, &size)) == noErr
            && (error = AudioUnitSetProperty(_audioUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output, 1, &format, size)) == noErr) {
            UInt32 frameSize = 0;
            size = sizeof(frameSize);
            if ((error = AudioUnitGetProperty(_audioUnit, kAudioDevicePropertyBufferFrameSize, kAudioUnitScope_Global, 0, &frameSize, &size)) == noErr
                && (error = AudioUnitInitialize(_audioUnit)) == noErr
                && [self allocateAuidoBufferListWithNumberOfChannels:format.mChannelsPerFrame andAudioBufferSize:format.mBytesPerFrame * frameSize])
                return YES;
        }
    }
    AudioUnitUninitialize(_audioUnit);
    AudioComponentInstanceDispose(_audioUnit);
    _audioUnit = NULL;
    return NO;
}

- (BOOL)allocateAuidoBufferListWithNumberOfChannels:(NSUInteger)aChannels andAudioBufferSize:(NSUInteger)aSize
{
    // Fix: the original made a new list only when the old one was the same,
    // keeping a list of another size.
    if (_audioBufferList != NULL && _audioBufferList->mBuffers[0].mNumberChannels == aChannels && ((HSAudioRecorderBufferList *)_audioBufferList)->capacity == aSize)
        return YES;
    [self freeAudioBufferList];
    HSAudioRecorderBufferList *list = calloc(1, sizeof(HSAudioRecorderBufferList));
    if (list == NULL)
        return NO;
    list->list.mNumberBuffers = 1;
    list->list.mBuffers[0].mNumberChannels = (UInt32)aChannels;
    list->list.mBuffers[0].mDataByteSize = (UInt32)aSize;
    list->list.mBuffers[0].mData = calloc(1, aSize);
    list->capacity = (UInt32)aSize;
    if (list->list.mBuffers[0].mData == NULL) {
        free(list);
        return NO;
    }
    _audioBufferList = &list->list;
    return YES;
}

- (void)freeAudioBufferList
{
    if (_audioBufferList != NULL) {
        free(_audioBufferList->mBuffers[0].mData);
        free(_audioBufferList);
        _audioBufferList = NULL;
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

- (BOOL)isRecording
{
    return _isRecording;
}

- (NSUInteger)fileSize
{
    return 0;
}

- (double)duration
{
    return 0;
}

- (struct ComponentInstanceRecord *)audioUnit
{
    return _audioUnit;
}

- (struct AudioBufferList *)audioBufferList
{
    return _audioBufferList;
}

- (struct OpaqueExtAudioFile *)audioFile
{
    return _audioFile;
}

- (NSUInteger)audioDeviceID
{
    return _audioDeviceID;
}

- (void)dealloc
{
    [_outputFileURL release];
    if (_audioUnit != NULL) {
        AudioOutputUnitStop(_audioUnit);
        AudioUnitUninitialize(_audioUnit);
        AudioComponentInstanceDispose(_audioUnit);
    }
    if (_audioFile != NULL)
        ExtAudioFileDispose(_audioFile);
    [self freeAudioBufferList];
    [super dealloc];
}

static BOOL HSAudioRecorderDeviceHasInput(AudioObjectID aDevice)
{
    AudioObjectPropertyAddress address = { kAudioDevicePropertyStreams, kAudioDevicePropertyScopeInput, kAudioObjectPropertyElementMain };
    UInt32 size = 0;
    return AudioObjectGetPropertyDataSize(aDevice, &address, 0, NULL, &size) == noErr && size != 0;
}

// Devices with input only.
- (id)initWithAudioDeviceID:(NSUInteger)aID
{
    if ((self = [super init])) {
        if (HSAudioRecorderDeviceHasInput((AudioObjectID)aID))
            _audioDeviceID = (unsigned int)aID;
        else {
            [super release];
            self = nil;
        }
    }
    return self;
}

- (id)initWithAudioDeviceUID:(id)aUID
{
    if ((self = [super init])) {
        AudioObjectID device = kAudioObjectUnknown;
        CFStringRef uid = (CFStringRef)aUID;
        AudioValueTranslation translation = { &uid, sizeof(uid), &device, sizeof(device) };
        UInt32 size = sizeof(translation);
        AudioObjectPropertyAddress address = { kAudioHardwarePropertyDeviceForUID, kAudioObjectPropertyScopeGlobal, kAudioObjectPropertyElementMain };
        // Fix: the original took an unknown UID (no device) as a device.
        if (AudioObjectGetPropertyData(kAudioObjectSystemObject, &address, 0, NULL, &size, &translation) == noErr && device != kAudioObjectUnknown
            && HSAudioRecorderDeviceHasInput(device))
            _audioDeviceID = device;
        else {
            [super release];
            self = nil;
        }
    }
    return self;
}

// A recorder needs a device.
- (id)init
{
    [super release];
    return nil;
}

@end
