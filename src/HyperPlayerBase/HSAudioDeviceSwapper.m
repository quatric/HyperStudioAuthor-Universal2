#import "HSAudioDeviceSwapper.h"
#import <stdatomic.h>

// HyperCasting: the HyperCasting device (a loopback driver) is made the
// default output, and what the system plays into it is copied, through a
// ring buffer, to the device that was the default, so it can be recorded
// from the HyperCasting device's input while still being heard. The
// HyperCasting device's volume and mute follow onto the actual device.

#pragma mark Ring buffer

// CARingBuffer from Apple's PublicUtility in the original: frames kept by
// sample time, with the valid range in a queue of time bounds so the reader
// on one IO thread sees a consistent range while the writer on the other
// moves it.

enum {
    HSRingBufferOK = 0,
    HSRingBufferTooMuch = 3,
    HSRingBufferCPUOverload = 4,
    HSRingBufferTooOld = -1,
    HSRingBufferTooFar = -2
};

#define HSRingBufferTimeBoundsCount 32

typedef struct {
    SInt64 startTime;
    SInt64 endTime;
    _Atomic UInt32 updateCounter;
} HSRingBufferTimeBounds;

typedef struct {
    UInt32 bufferCount;
    UInt32 bytesPerFrame;
    UInt32 capacityFrames;
    UInt32 capacityBytes;
    Byte **buffers;
    HSRingBufferTimeBounds timeBounds[HSRingBufferTimeBoundsCount];
    _Atomic UInt32 timeBoundsCounter;
} HSRingBuffer;

static HSRingBuffer *HSRingBufferCreate(UInt32 aBufferCount, UInt32 aBytesPerFrame, UInt32 aCapacityFrames)
{
    UInt32 capacity = 1;
    while (capacity < aCapacityFrames)
        capacity <<= 1;
    HSRingBuffer *ring = calloc(1, sizeof(HSRingBuffer));
    if (ring == NULL)
        return NULL;
    ring->bufferCount = aBufferCount;
    ring->bytesPerFrame = aBytesPerFrame;
    ring->capacityFrames = capacity;
    ring->capacityBytes = capacity * aBytesPerFrame;
    ring->buffers = calloc(aBufferCount, sizeof(Byte *));
    for (UInt32 i = 0; ring->buffers != NULL && i < aBufferCount; i++)
        if ((ring->buffers[i] = calloc(1, ring->capacityBytes)) == NULL) {
            while (i-- > 0)
                free(ring->buffers[i]);
            free(ring->buffers);
            ring->buffers = NULL;
        }
    if (ring->buffers == NULL) {
        free(ring);
        return NULL;
    }
    return ring;
}

static void HSRingBufferDispose(HSRingBuffer *aRing)
{
    if (aRing == NULL)
        return;
    for (UInt32 i = 0; i < aRing->bufferCount; i++)
        free(aRing->buffers[i]);
    free(aRing->buffers);
    free(aRing);
}

static void HSRingBufferSetTimeBounds(HSRingBuffer *aRing, SInt64 aStart, SInt64 aEnd)
{
    UInt32 counter = atomic_load(&aRing->timeBoundsCounter) + 1;
    HSRingBufferTimeBounds *bounds = &aRing->timeBounds[counter % HSRingBufferTimeBoundsCount];
    bounds->startTime = aStart;
    bounds->endTime = aEnd;
    atomic_store(&bounds->updateCounter, counter);
    atomic_store(&aRing->timeBoundsCounter, counter);
}

static BOOL HSRingBufferGetTimeBounds(HSRingBuffer *aRing, SInt64 *aStart, SInt64 *aEnd)
{
    for (int i = 0; i < 8; i++) {
        UInt32 counter = atomic_load(&aRing->timeBoundsCounter);
        HSRingBufferTimeBounds *bounds = &aRing->timeBounds[counter % HSRingBufferTimeBoundsCount];
        *aStart = bounds->startTime;
        *aEnd = bounds->endTime;
        if (atomic_load(&bounds->updateCounter) == counter)
            return YES;
    }
    return NO;
}

static UInt32 HSRingBufferFrameOffset(HSRingBuffer *aRing, SInt64 aTime)
{
    return (UInt32)(aTime & (aRing->capacityFrames - 1)) * aRing->bytesPerFrame;
}

// Fix: the original copied a buffer for each channel of the ring, reading
// past a list with fewer (an interleaved one); only the buffers both have
// are copied, and no more bytes than the list's buffer holds.
static void HSRingBufferStoreList(HSRingBuffer *aRing, UInt32 aDestOffset, const AudioBufferList *aList, UInt32 aSourceOffset, UInt32 aBytes)
{
    UInt32 count = MIN(aRing->bufferCount, aList->mNumberBuffers);
    for (UInt32 i = 0; i < count; i++) {
        const AudioBuffer *buffer = &aList->mBuffers[i];
        if (aSourceOffset > buffer->mDataByteSize || buffer->mData == NULL)
            continue;
        memcpy(aRing->buffers[i] + aDestOffset, (Byte *)buffer->mData + aSourceOffset, MIN(aBytes, buffer->mDataByteSize - aSourceOffset));
    }
}

static void HSRingBufferFetchList(HSRingBuffer *aRing, AudioBufferList *aList, UInt32 aDestOffset, UInt32 aSourceOffset, UInt32 aBytes)
{
    UInt32 count = MIN(aRing->bufferCount, aList->mNumberBuffers);
    for (UInt32 i = 0; i < count; i++) {
        AudioBuffer *buffer = &aList->mBuffers[i];
        if (aDestOffset > buffer->mDataByteSize || buffer->mData == NULL)
            continue;
        memcpy((Byte *)buffer->mData + aDestOffset, aRing->buffers[i] + aSourceOffset, MIN(aBytes, buffer->mDataByteSize - aDestOffset));
    }
}

static void HSRingBufferZero(HSRingBuffer *aRing, UInt32 aOffset, UInt32 aBytes)
{
    for (UInt32 i = 0; i < aRing->bufferCount; i++)
        memset(aRing->buffers[i] + aOffset, 0, aBytes);
}

static int HSRingBufferStore(HSRingBuffer *aRing, const AudioBufferList *aList, UInt32 aFrames, SInt64 aStartWrite)
{
    if (aFrames == 0)
        return HSRingBufferOK;
    if (aFrames > aRing->capacityFrames)
        return HSRingBufferTooMuch;
    SInt64 endWrite = aStartWrite + aFrames, start = 0, end = 0;
    HSRingBufferGetTimeBounds(aRing, &start, &end);
    if (aStartWrite < end)
        // Going back in time: everything kept is thrown out.
        HSRingBufferSetTimeBounds(aRing, aStartWrite, aStartWrite);
    else if (endWrite - start > aRing->capacityFrames) {
        // The start moves past what's about to be overwritten.
        SInt64 newStart = endWrite - aRing->capacityFrames;
        HSRingBufferSetTimeBounds(aRing, newStart, MAX(newStart, end));
    }
    HSRingBufferGetTimeBounds(aRing, &start, &end);
    if (aStartWrite > end) {
        // A gap is silence.
        UInt32 offset0 = HSRingBufferFrameOffset(aRing, end), offset1 = HSRingBufferFrameOffset(aRing, aStartWrite);
        if (offset0 < offset1)
            HSRingBufferZero(aRing, offset0, offset1 - offset0);
        else {
            HSRingBufferZero(aRing, offset0, aRing->capacityBytes - offset0);
            HSRingBufferZero(aRing, 0, offset1);
        }
    }
    UInt32 offset0 = HSRingBufferFrameOffset(aRing, aStartWrite), offset1 = HSRingBufferFrameOffset(aRing, endWrite);
    if (offset0 < offset1)
        HSRingBufferStoreList(aRing, offset0, aList, 0, offset1 - offset0);
    else {
        UInt32 bytes = aRing->capacityBytes - offset0;
        HSRingBufferStoreList(aRing, offset0, aList, 0, bytes);
        HSRingBufferStoreList(aRing, 0, aList, bytes, offset1);
    }
    HSRingBufferSetTimeBounds(aRing, start, endWrite);
    return HSRingBufferOK;
}

// With aAheadOK, reading past the end is allowed.
static int HSRingBufferCheckTimeBounds(HSRingBuffer *aRing, SInt64 aStartRead, SInt64 aEndRead, BOOL aAheadOK)
{
    SInt64 start = 0, end = 0;
    if (!HSRingBufferGetTimeBounds(aRing, &start, &end))
        return HSRingBufferCPUOverload;
    if (aStartRead < start)
        return HSRingBufferTooOld;
    if (!aAheadOK && aEndRead > end)
        return HSRingBufferTooFar;
    return HSRingBufferOK;
}

static int HSRingBufferFetch(HSRingBuffer *aRing, AudioBufferList *aList, UInt32 aFrames, SInt64 aStartRead, BOOL aAheadOK)
{
    SInt64 endRead = aStartRead + aFrames;
    int error = HSRingBufferCheckTimeBounds(aRing, aStartRead, endRead, aAheadOK);
    if (error != HSRingBufferOK)
        return error;
    UInt32 offset0 = HSRingBufferFrameOffset(aRing, aStartRead), offset1 = HSRingBufferFrameOffset(aRing, endRead), bytes;
    if (offset0 < offset1) {
        bytes = offset1 - offset0;
        HSRingBufferFetchList(aRing, aList, 0, offset0, bytes);
    } else {
        bytes = aRing->capacityBytes - offset0;
        HSRingBufferFetchList(aRing, aList, 0, offset0, bytes);
        HSRingBufferFetchList(aRing, aList, bytes, 0, offset1);
        bytes += offset1;
    }
    for (UInt32 i = 0; i < aList->mNumberBuffers; i++)
        aList->mBuffers[i].mDataByteSize = MIN(aList->mBuffers[i].mDataByteSize, bytes);
    return HSRingBufferCheckTimeBounds(aRing, aStartRead, endRead, aAheadOK);
}

#pragma mark Device properties

static OSStatus HSAudioDeviceSwapperGet(AudioObjectID aObject, AudioObjectPropertySelector aSelector, AudioObjectPropertyScope aScope, AudioObjectPropertyElement aElement, UInt32 aSize, void *aData)
{
    AudioObjectPropertyAddress address = { aSelector, aScope, aElement };
    return AudioObjectGetPropertyData(aObject, &address, 0, NULL, &aSize, aData);
}

static OSStatus HSAudioDeviceSwapperSet(AudioObjectID aObject, AudioObjectPropertySelector aSelector, AudioObjectPropertyScope aScope, AudioObjectPropertyElement aElement, UInt32 aSize, const void *aData)
{
    AudioObjectPropertyAddress address = { aSelector, aScope, aElement };
    return AudioObjectSetPropertyData(aObject, &address, 0, NULL, aSize, aData);
}

static AudioObjectPropertySelector HSAudioDeviceSwapperDefaultDeviceSelector(BOOL aOutput)
{
    return aOutput ? kAudioHardwarePropertyDefaultOutputDevice : kAudioHardwarePropertyDefaultInputDevice;
}

static OSStatus HSAudioDeviceSwapperProvider(AudioObjectID aDevice, const AudioTimeStamp *aNow, const AudioBufferList *aInputData, const AudioTimeStamp *aInputTime, AudioBufferList *aOutputData, const AudioTimeStamp *aOutputTime, void *aSwapper)
{
    [(HSAudioDeviceSwapper *)aSwapper processProviderCallWithTimeStampInput:(AudioTimeStamp *)aInputTime buffersList:(AudioBufferList *)aInputData];
    return noErr;
}

static OSStatus HSAudioDeviceSwapperClient(AudioObjectID aDevice, const AudioTimeStamp *aNow, const AudioBufferList *aInputData, const AudioTimeStamp *aInputTime, AudioBufferList *aOutputData, const AudioTimeStamp *aOutputTime, void *aSwapper)
{
    [(HSAudioDeviceSwapper *)aSwapper processClientCallWithOutputTime:(AudioTimeStamp *)aOutputTime outputData:aOutputData];
    return noErr;
}

static OSStatus HSAudioDeviceSwapperPropertyListener(AudioObjectID aDevice, UInt32 aCount, const AudioObjectPropertyAddress *aAddresses, void *aSwapper)
{
    for (UInt32 i = 0; i < aCount; i++)
        [(HSAudioDeviceSwapper *)aSwapper processPropertyChange:aAddresses[i].mSelector];
    return noErr;
}

static const AudioObjectPropertyAddress kHSAudioDeviceSwapperVolumeAddress = { kAudioDevicePropertyVolumeDecibels, kAudioDevicePropertyScopeOutput, kAudioObjectPropertyElementMain };
static const AudioObjectPropertyAddress kHSAudioDeviceSwapperMuteAddress = { kAudioDevicePropertyMute, kAudioDevicePropertyScopeOutput, kAudioObjectPropertyElementMain };

@implementation HSAudioDeviceSwapper

// Neither the default output nor the default input left on the
// HyperCasting device.
+ (void)selectAnotherDeviceIfHSDeviceIsDefault
{
    [self selectAnotherDeviceIfHSDeviceIsDefaultByType:YES];
    [self selectAnotherDeviceIfHSDeviceIsDefaultByType:NO];
}

// When the HyperCasting device is the default output (aType YES) or input,
// the default goes back to the one before it, or else to the first other
// device that can be the default.
+ (void)selectAnotherDeviceIfHSDeviceIsDefaultByType:(BOOL)aType
{
    unsigned int *list = NULL;
    NSUInteger count = [HSAudioDeviceSwapper createDeviceList:&list];
    AudioObjectID hsDevice;
    if (list != NULL && (hsDevice = (AudioObjectID)[HSAudioDeviceSwapper findHyperCastingDeviceByName:list listLength:count]) != kAudioObjectUnknown) {
        AudioObjectID defaultDevice = kAudioObjectUnknown;
        AudioObjectPropertySelector selector = HSAudioDeviceSwapperDefaultDeviceSelector(aType);
        if (HSAudioDeviceSwapperGet(kAudioObjectSystemObject, selector, kAudioObjectPropertyScopeGlobal, kAudioObjectPropertyElementMain, sizeof(defaultDevice), &defaultDevice) == noErr
            && defaultDevice == hsDevice) {
            AudioObjectID device = (AudioObjectID)[HSAudioDeviceSwapper findPreviousDefaultDeviceFromHSPreferencesByUIDKey:aType ? @"kHSLastDefaultDeviceUIDKey" : @"kHSLastDefaultInputDeviceUIDKey"];
            for (NSUInteger i = 0; device == kAudioObjectUnknown && i < count; i++) {
                UInt32 canBeDefault = 0;
                // Fix: the original asked whether an input could be the
                // default output.
                if (list[i] != hsDevice
                    && HSAudioDeviceSwapperGet(list[i], kAudioDevicePropertyDeviceCanBeDefaultDevice, aType ? kAudioDevicePropertyScopeOutput : kAudioDevicePropertyScopeInput, kAudioObjectPropertyElementMain, sizeof(canBeDefault), &canBeDefault) == noErr
                    && canBeDefault != 0)
                    device = list[i];
            }
            if (device != kAudioObjectUnknown)
                HSAudioDeviceSwapperSet(kAudioObjectSystemObject, selector, kAudioObjectPropertyScopeGlobal, kAudioObjectPropertyElementMain, sizeof(device), &device);
        }
    }
    free(list);
}

+ (NSUInteger)findPreviousDefaultDeviceFromHSPreferencesByUIDKey:(id)aKey
{
    CFStringRef uid = (CFStringRef)[[NSUserDefaults standardUserDefaults] objectForKey:aKey];
    if (uid == NULL)
        return 0;
    AudioObjectID device = kAudioObjectUnknown;
    AudioValueTranslation translation = { &uid, sizeof(uid), &device, sizeof(device) };
    if (HSAudioDeviceSwapperGet(kAudioObjectSystemObject, kAudioHardwarePropertyDeviceForUID, kAudioObjectPropertyScopeGlobal, kAudioObjectPropertyElementMain, sizeof(translation), &translation) != noErr)
        return 0;
    return device;
}

// All the devices, in a list the caller frees.
+ (NSUInteger)createDeviceList:(unsigned int **)aList
{
    if (aList == NULL)
        return 0;
    AudioObjectPropertyAddress address = { kAudioHardwarePropertyDevices, kAudioObjectPropertyScopeGlobal, kAudioObjectPropertyElementMain };
    UInt32 size = 0;
    if (AudioObjectGetPropertyDataSize(kAudioObjectSystemObject, &address, 0, NULL, &size) != noErr || size / sizeof(AudioObjectID) == 0)
        return 0;
    unsigned int *list = malloc(size);
    if (list == NULL || AudioObjectGetPropertyData(kAudioObjectSystemObject, &address, 0, NULL, &size, list) != noErr) {
        free(list);
        *aList = NULL;
        return 0;
    }
    *aList = list;
    return size / sizeof(AudioObjectID);
}

// The device named as the HyperCasting device is in this localization.
+ (NSUInteger)findHyperCastingDeviceByName:(unsigned int *)aName listLength:(NSUInteger)aLength
{
    if (aName == NULL)
        return 0;
    NSString *hsName = [[NSBundle bundleForClass:[self class]] localizedStringForKey:@"HSDeviceName" value:@"" table:@"HyperPlayerBase"];
    for (NSUInteger i = 0; i < aLength; i++) {
        CFStringRef name = NULL;
        if (HSAudioDeviceSwapperGet(aName[i], kAudioObjectPropertyName, kAudioObjectPropertyScopeGlobal, kAudioObjectPropertyElementMain, sizeof(name), &name) != noErr || name == NULL)
            continue;
        BOOL found = [(NSString *)name isEqualToString:hsName];
        CFRelease(name);
        if (found)
            return aName[i];
    }
    return 0;
}

- (NSInteger)processPropertyChange:(NSUInteger)aChange
{
    if (aChange == kAudioDevicePropertyMute)
        // Fix: the original passed no devices.
        [self translateMuteFrom:_hyperCastingDevice to:_actualDevice];
    else if (aChange == kAudioDevicePropertyVolumeDecibels)
        [self translateVolumeFromHSDeviceToDefaultDevice];
    else
        return kAudioHardwareUnknownPropertyError;
    return noErr;
}

// The actual device plays what the HyperCasting device was given its
// latency ago; the delta between their sample times is taken on the first
// call after the HyperCasting device's.
- (NSInteger)processClientCallWithOutputTime:(struct AudioTimeStamp *)aTime outputData:(struct AudioBufferList *)aData
{
    if (!_clientCallbackIsRunning) {
        if (!_providerCallbackIsRunning)
            return noErr;
        // Fix: the original replaced the delta with this, losing the
        // latency getSyncData added to it.
        _inputToOutputSampleDelta = aTime->mSampleTime - _lastInputSampleTime + _actualLatency;
        _clientCallbackIsRunning = YES;
    }
    if (_status == 1)
        HSRingBufferFetch(_loopingStorage, aData, _actualDeviceBufferFrameSize, (SInt64)round(aTime->mSampleTime - _inputToOutputSampleDelta), YES);
    return noErr;
}

- (NSInteger)processProviderCallWithTimeStampInput:(struct AudioTimeStamp *)aInput buffersList:(struct AudioBufferList *)aList
{
    if (!_providerCallbackIsRunning)
        _providerCallbackIsRunning = YES;
    _lastInputSampleTime = aInput->mSampleTime;
    HSRingBufferStore(_loopingStorage, aList, _hyperCastingDeviceBufferFrameSize, (SInt64)round(aInput->mSampleTime));
    return noErr;
}

- (id)errorDescription
{
    if (_status != -1)
        return nil;
    switch (_errorCode) {
    case 1:
        return HSCantFindHSDeviceErrorString;
    case 2:
        return HSDefaultDeviceIsHSDeviceErrorString;
    case 3:
        return HSHyperCastingDeviceDoesNotSupportStreamFormatErrorString;
    case 4:
        return HSFailedToSetHSDeviceAsDefaultErrorString;
    case 5:
        return HSFailedToCreateAppropriateRingBufferErrorString;
    case 6:
        return HSFailedToGetSyncDataErrorString;
    case 7:
        return HSFailedToStartDataExchangeErrorString;
    case 8:
    case 9:
        return HSFailedToRestoreActualDeviceErrorString;
    }
    return @"Unknown Error";
}

- (NSInteger)status
{
    return _status;
}

// Undoes what run did before it failed; NO when the actual device can't be
// made the default again.
- (BOOL)recoverFromError
{
    if (_status != -1)
        return YES;
    switch (_errorCode) {
    case 7:
        _errorCode = [self endDataExchange] ? 6 : 8;
        return [self recoverFromError];
    case 5:
    case 6:
        [self finishListenToHSDevicePropertiesChanges];
        if (![self setActualDeviceBackAsDefault]) {
            _errorCode = 9;
            return [self recoverFromError];
        }
        break;
    default:
        if (_errorCode > 4)
            return NO;
    }
    _errorCode = 0;
    _status = 0;
    return YES;
}

- (void)stop
{
    if (_status != 1)
        return;
    _status = 2;
    [self endDataExchange];
    if (!_providerCallbackIsRunning && !_clientCallbackIsRunning) {
        [self releaseLoopingStorage];
        if ([self setActualDeviceBackAsDefault]) {
            [self finishListenToHSDevicePropertiesChanges];
            _status = 0;
        } else {
            _status = -1;
            _errorCode = 9;
        }
    } else {
        _status = -1;
        _errorCode = 8;
    }
}

// Makes the HyperCasting device the default output and starts copying it to
// the device that was; returns the HyperCasting device, 0 on failure.
- (NSUInteger)run
{
    if (_status == 1)
        return _hyperCastingDevice;
    if (_status != 0)
        return 0;
    _status = 3;
    HSAudioDeviceSwapperGet(kAudioObjectSystemObject, kAudioHardwarePropertyDefaultOutputDevice, kAudioObjectPropertyScopeGlobal, kAudioObjectPropertyElementMain, sizeof(_actualDevice), &_actualDevice);
    HSAudioDeviceSwapperGet(kAudioObjectSystemObject, kAudioHardwarePropertyDefaultInputDevice, kAudioObjectPropertyScopeGlobal, kAudioObjectPropertyElementMain, sizeof(_actualInputDevice), &_actualInputDevice);
    if (_hyperCastingDevice == 0)
        _hyperCastingDevice = (unsigned int)[self findHyperCastingDevice];
    int error = 0;
    if (_hyperCastingDevice == 0)
        error = 1;
    else if (_hyperCastingDevice == _actualDevice)
        error = 2;
    else if (![self translateStreamFormatFromActualDeviceToHSDevice])
        error = 3;
    else {
        [self translatePropertiesFromDefaultDeviceToHSDevice];
        [self storeAudioDevicesUIDsInUserDefaults];
        if (HSAudioDeviceSwapperSet(kAudioObjectSystemObject, kAudioHardwarePropertyDefaultOutputDevice, kAudioObjectPropertyScopeGlobal, kAudioObjectPropertyElementMain, sizeof(_hyperCastingDevice), &_hyperCastingDevice) != noErr)
            error = 4;
        else {
            [self startListenToHSDevicePropertiesChanges];
            if (![self createLoopingStorage])
                error = 5;
            else if (![self getSyncData])
                error = 6;
            else if (![self beginDataExchange])
                error = 7;
            else {
                _status = 1;
                return _hyperCastingDevice;
            }
        }
    }
    _status = -1;
    _errorCode = error;
    return 0;
}

- (void)finishListenToHSDevicePropertiesChanges
{
    AudioObjectRemovePropertyListener(_hyperCastingDevice, &kHSAudioDeviceSwapperVolumeAddress, HSAudioDeviceSwapperPropertyListener, self);
    AudioObjectRemovePropertyListener(_hyperCastingDevice, &kHSAudioDeviceSwapperMuteAddress, HSAudioDeviceSwapperPropertyListener, self);
}

- (void)startListenToHSDevicePropertiesChanges
{
    AudioObjectAddPropertyListener(_hyperCastingDevice, &kHSAudioDeviceSwapperVolumeAddress, HSAudioDeviceSwapperPropertyListener, self);
    AudioObjectAddPropertyListener(_hyperCastingDevice, &kHSAudioDeviceSwapperMuteAddress, HSAudioDeviceSwapperPropertyListener, self);
}

// The HyperCasting device's volume onto both channels of the actual device.
- (BOOL)translateVolumeFromHSDeviceToDefaultDevice
{
    Float32 volume = 0;
    return HSAudioDeviceSwapperGet(_hyperCastingDevice, kAudioDevicePropertyVolumeDecibels, kAudioDevicePropertyScopeOutput, kAudioObjectPropertyElementMain, sizeof(volume), &volume) == noErr
        && HSAudioDeviceSwapperSet(_actualDevice, kAudioDevicePropertyVolumeDecibels, kAudioDevicePropertyScopeOutput, 1, sizeof(volume), &volume) == noErr
        && HSAudioDeviceSwapperSet(_actualDevice, kAudioDevicePropertyVolumeDecibels, kAudioDevicePropertyScopeOutput, 2, sizeof(volume), &volume) == noErr;
}

// So the default devices can be put back after a crash.
- (void)storeAudioDevicesUIDsInUserDefaults
{
    CFStringRef actualUID = NULL, inputUID = NULL, hsUID = NULL;
    if (HSAudioDeviceSwapperGet(_actualDevice, kAudioDevicePropertyDeviceUID, kAudioObjectPropertyScopeGlobal, kAudioObjectPropertyElementMain, sizeof(actualUID), &actualUID) == noErr
        && HSAudioDeviceSwapperGet(_actualInputDevice, kAudioDevicePropertyDeviceUID, kAudioObjectPropertyScopeGlobal, kAudioObjectPropertyElementMain, sizeof(inputUID), &inputUID) == noErr
        && HSAudioDeviceSwapperGet(_hyperCastingDevice, kAudioDevicePropertyDeviceUID, kAudioObjectPropertyScopeGlobal, kAudioObjectPropertyElementMain, sizeof(hsUID), &hsUID) == noErr) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:(NSString *)actualUID forKey:@"kHSLastDefaultDeviceUIDKey"];
        [defaults setObject:(NSString *)inputUID forKey:@"kHSLastDefaultInputDeviceUIDKey"];
        [defaults setObject:(NSString *)hsUID forKey:@"kHSHyperCastingDeviceUIDKey"];
        [defaults synchronize];
    }
    if (hsUID != NULL)
        CFRelease(hsUID);
    if (inputUID != NULL)
        CFRelease(inputUID);
    if (actualUID != NULL)
        CFRelease(actualUID);
}

- (void)translatePropertiesFromDefaultDeviceToHSDevice
{
    [self translateMuteFrom:_actualDevice to:_hyperCastingDevice];
    [self translateVolumeFromDefaultDeviceToHSDevice];
}

// The louder of the actual device's channels onto the HyperCasting device.
- (BOOL)translateVolumeFromDefaultDeviceToHSDevice
{
    if (HSAudioDeviceSwapperGet(_actualDevice, kAudioDevicePropertyVolumeDecibels, kAudioDevicePropertyScopeOutput, 1, sizeof(_actualDeviceFirstChannelVolume), &_actualDeviceFirstChannelVolume) != noErr
        || HSAudioDeviceSwapperGet(_actualDevice, kAudioDevicePropertyVolumeDecibels, kAudioDevicePropertyScopeOutput, 2, sizeof(_actualDeviceSecondChannelVolume), &_actualDeviceSecondChannelVolume) != noErr)
        return NO;
    Float32 volume = MAX(_actualDeviceFirstChannelVolume, _actualDeviceSecondChannelVolume);
    return HSAudioDeviceSwapperSet(_hyperCastingDevice, kAudioDevicePropertyVolumeDecibels, kAudioDevicePropertyScopeOutput, kAudioObjectPropertyElementMain, sizeof(volume), &volume) == noErr;
}

- (BOOL)setMaximumGainToHSDeviceInput
{
    Float32 gain = 1.0f;
    return HSAudioDeviceSwapperSet(_hyperCastingDevice, kAudioDevicePropertyVolumeScalar, kAudioDevicePropertyScopeInput, kAudioObjectPropertyElementMain, sizeof(gain), &gain) == noErr;
}

- (BOOL)translateMuteFrom:(NSUInteger)aFrom to:(NSUInteger)aTo
{
    UInt32 mute = 0;
    return HSAudioDeviceSwapperGet((AudioObjectID)aFrom, kAudioDevicePropertyMute, kAudioDevicePropertyScopeOutput, kAudioObjectPropertyElementMain, sizeof(mute), &mute) == noErr
        && HSAudioDeviceSwapperSet((AudioObjectID)aTo, kAudioDevicePropertyMute, kAudioDevicePropertyScopeOutput, kAudioObjectPropertyElementMain, sizeof(mute), &mute) == noErr;
}

// The HyperCasting device's input stream gets the actual device's output
// format, so what comes in can go straight out.
- (BOOL)translateStreamFormatFromActualDeviceToHSDevice
{
    if (HSAudioDeviceSwapperGet(_actualDevice, kAudioDevicePropertyStreamFormat, kAudioDevicePropertyScopeOutput, 0, sizeof(_actualDeviceStreamFormat), &_actualDeviceStreamFormat) != noErr)
        HSAudioDeviceSwapperGet(_actualDevice, kAudioDevicePropertyStreamFormat, kAudioDevicePropertyScopeOutput, 1, sizeof(_actualDeviceStreamFormat), &_actualDeviceStreamFormat);
    if (_actualDeviceStreamFormat.mFormatID == 0)
        return NO;
    AudioObjectID stream = kAudioObjectUnknown;
    if (HSAudioDeviceSwapperGet(_hyperCastingDevice, kAudioDevicePropertyStreams, kAudioDevicePropertyScopeInput, kAudioObjectPropertyElementMain, sizeof(stream), &stream) != noErr)
        return NO;
    return HSAudioDeviceSwapperSet(stream, kAudioStreamPropertyVirtualFormat, kAudioObjectPropertyScopeGlobal, kAudioObjectPropertyElementMain, sizeof(_actualDeviceStreamFormat), &_actualDeviceStreamFormat) == noErr;
}

// Undoes beginDataExchange's stages, last first.
- (BOOL)endDataExchange
{
    OSStatus error = noErr;
    while (_dataExchangeSetupStage > 0) {
        switch (_dataExchangeSetupStage) {
        case 1:
            if ((error = AudioDeviceDestroyIOProcID(_actualDevice, _clientIOProcID)) == noErr)
                _clientIOProcID = NULL;
            break;
        case 2:
            if ((error = AudioDeviceStop(_actualDevice, _clientIOProcID)) == noErr)
                _clientCallbackIsRunning = NO;
            break;
        case 3:
            if ((error = AudioDeviceDestroyIOProcID(_hyperCastingDevice, _providerIOProcID)) == noErr)
                _providerIOProcID = NULL;
            break;
        case 4:
            if ((error = AudioDeviceStop(_hyperCastingDevice, _providerIOProcID)) == noErr)
                _providerCallbackIsRunning = NO;
            break;
        }
        if (error != noErr)
            break;
        _dataExchangeSetupStage--;
    }
    return error == noErr;
}

// In stages, so a failure can be undone: the actual device's IO proc
// added and started, then the HyperCasting device's.
- (BOOL)beginDataExchange
{
    OSStatus error = noErr;
    while (_dataExchangeSetupStage < 4) {
        switch (_dataExchangeSetupStage) {
        case 0:
            error = AudioDeviceCreateIOProcID(_actualDevice, HSAudioDeviceSwapperClient, self, &_clientIOProcID);
            break;
        case 1:
            error = AudioDeviceStart(_actualDevice, _clientIOProcID);
            break;
        case 2:
            error = AudioDeviceCreateIOProcID(_hyperCastingDevice, HSAudioDeviceSwapperProvider, self, &_providerIOProcID);
            break;
        case 3:
            error = AudioDeviceStart(_hyperCastingDevice, _providerIOProcID);
            break;
        }
        if (error != noErr)
            break;
        _dataExchangeSetupStage++;
    }
    return error == noErr;
}

// The buffer sizes, and the latency through both devices.
- (BOOL)getSyncData
{
    UInt32 hsSafetyOffset = 0, actualSafetyOffset = 0;
    // Fix: the original read the HyperCasting device's safety offset and
    // buffer size again for the actual device's.
    if (HSAudioDeviceSwapperGet(_hyperCastingDevice, kAudioDevicePropertySafetyOffset, kAudioDevicePropertyScopeOutput, kAudioObjectPropertyElementMain, sizeof(hsSafetyOffset), &hsSafetyOffset) != noErr
        || HSAudioDeviceSwapperGet(_hyperCastingDevice, kAudioDevicePropertyBufferFrameSize, kAudioDevicePropertyScopeOutput, kAudioObjectPropertyElementMain, sizeof(_hyperCastingDeviceBufferFrameSize), &_hyperCastingDeviceBufferFrameSize) != noErr
        || HSAudioDeviceSwapperGet(_actualDevice, kAudioDevicePropertySafetyOffset, kAudioDevicePropertyScopeOutput, kAudioObjectPropertyElementMain, sizeof(actualSafetyOffset), &actualSafetyOffset) != noErr
        || HSAudioDeviceSwapperGet(_actualDevice, kAudioDevicePropertyBufferFrameSize, kAudioDevicePropertyScopeOutput, kAudioObjectPropertyElementMain, sizeof(_actualDeviceBufferFrameSize), &_actualDeviceBufferFrameSize) != noErr)
        return NO;
    _actualLatency = _hyperCastingDeviceBufferFrameSize + hsSafetyOffset + actualSafetyOffset + _actualDeviceBufferFrameSize;
    _inputToOutputSampleDelta += _actualLatency;
    return YES;
}

- (void)releaseLoopingStorage
{
    HSRingBufferDispose(_loopingStorage);
    // Fix: the original kept the freed buffer.
    _loopingStorage = NULL;
}

// Two seconds of the actual device's format.
- (BOOL)createLoopingStorage
{
    if (_actualDeviceStreamFormat.mChannelsPerFrame == 0 || _actualDeviceStreamFormat.mBytesPerFrame == 0 || _actualDeviceStreamFormat.mSampleRate <= 0.0)
        return NO;
    // Fix: the original made a buffer per channel for interleaved formats
    // too, whose frames are all in one.
    UInt32 buffers = (_actualDeviceStreamFormat.mFormatFlags & kAudioFormatFlagIsNonInterleaved) ? _actualDeviceStreamFormat.mChannelsPerFrame : 1;
    _loopingStorage = HSRingBufferCreate(buffers, _actualDeviceStreamFormat.mBytesPerFrame, (UInt32)(_actualDeviceStreamFormat.mSampleRate * 2));
    return _loopingStorage != NULL;
}

- (BOOL)setActualDeviceBackAsDefault
{
    if (HSAudioDeviceSwapperSet(kAudioObjectSystemObject, kAudioHardwarePropertyDefaultOutputDevice, kAudioObjectPropertyScopeGlobal, kAudioObjectPropertyElementMain, sizeof(_actualDevice), &_actualDevice) == noErr) {
        _actualDevice = 0;
        return YES;
    }
    return _actualDevice == 0;
}

- (NSUInteger)findHyperCastingDevice
{
    unsigned int *list = NULL;
    NSUInteger count = [HSAudioDeviceSwapper createDeviceList:&list];
    if (list == NULL)
        return 0;
    NSUInteger device = [HSAudioDeviceSwapper findHyperCastingDeviceByName:list listLength:count];
    free(list);
    return device;
}

- (void)dealloc
{
    [self stop];
    [super dealloc];
}

@end
