#import "HSQTKit.h"

#define QTSTRING(name) NSString * const name = @#name

QTSTRING(QTCaptureDeviceWasConnectedNotification);
QTSTRING(QTCaptureDeviceWasDisconnectedNotification);
QTSTRING(QTCaptureDeviceFormatDescriptionsWillChangeNotification);
QTSTRING(QTCaptureDeviceFormatDescriptionsDidChangeNotification);
QTSTRING(QTCaptureDeviceAttributeWillChangeNotification);
QTSTRING(QTCaptureDeviceAttributeDidChangeNotification);
QTSTRING(QTCaptureDeviceChangedAttributeKey);
QTSTRING(QTCaptureDeviceLinkedDevicesAttribute);
QTSTRING(QTCaptureDeviceAvailableInputSourcesAttribute);
QTSTRING(QTCaptureDeviceInputSourceIdentifierAttribute);
QTSTRING(QTCaptureDeviceInputSourceIdentifierKey);
QTSTRING(QTCaptureDeviceInputSourceLocalizedDisplayNameKey);
QTSTRING(QTCaptureDeviceLegacySequenceGrabberAttribute);
QTSTRING(QTCaptureDeviceAVCTransportControlsAttribute);
QTSTRING(QTCaptureDeviceAVCTransportControlsPlaybackModeKey);
QTSTRING(QTCaptureDeviceAVCTransportControlsSpeedKey);
QTSTRING(QTCaptureDeviceSuspendedAttribute);
QTSTRING(QTCaptureSessionRuntimeErrorNotification);
QTSTRING(QTCaptureSessionErrorKey);
QTSTRING(QTCaptureConnectionFormatDescriptionWillChangeNotification);
QTSTRING(QTCaptureConnectionFormatDescriptionDidChangeNotification);
QTSTRING(QTCaptureConnectionAttributeWillChangeNotification);
QTSTRING(QTCaptureConnectionAttributeDidChangeNotification);
QTSTRING(QTCaptureConnectionChangedAttributeKey);
QTSTRING(QTCaptureConnectionAudioAveragePowerLevelsAttribute);
QTSTRING(QTCaptureConnectionAudioPeakHoldLevelsAttribute);
QTSTRING(QTCaptureConnectionAudioMasterVolumeAttribute);
QTSTRING(QTCaptureConnectionAudioVolumesAttribute);
QTSTRING(QTCaptureConnectionEnabledAudioChannelsAttribute);

static NSError *captureError(NSInteger code, NSString *description, NSError *underlying)
{
    NSMutableDictionary *info = [NSMutableDictionary dictionaryWithObject:description forKey:NSLocalizedDescriptionKey];
    if (underlying)
        [info setObject:underlying forKey:NSUnderlyingErrorKey];
    return [NSError errorWithDomain:QTKitErrorDomain code:code userInfo:info];
}

// AVFoundation's capture errors as QTKit's.
static NSError *qtErrorFromAVError(NSError *error)
{
    if (!error)
        return nil;
    NSInteger code = QTErrorUnknown;
    switch ([error code]) {
    case AVErrorDiskFull: code = QTErrorDiskFull; break;
    case AVErrorDeviceWasDisconnected: code = QTErrorDeviceWasDisconnected; break;
    case AVErrorMediaChanged: code = QTErrorMediaChanged; break;
    case AVErrorMaximumDurationReached: code = QTErrorMaximumDurationReached; break;
    case AVErrorMaximumFileSizeReached: code = QTErrorMaximumFileSizeReached; break;
    case AVErrorMediaDiscontinuity: code = QTErrorMediaDiscontinuity; break;
    case AVErrorMaximumNumberOfSamplesForFileFormatReached: code = QTErrorMaximumNumberOfSamplesForFileFormatReached; break;
    case AVErrorDeviceNotConnected: code = QTErrorDeviceNotConnected; break;
    case AVErrorDeviceInUseByAnotherApplication: code = QTErrorDeviceInUseByAnotherApplication; break;
    case AVErrorNoDataCaptured: code = QTErrorNoDataCaptured; break;
    case AVErrorSessionConfigurationChanged: code = QTErrorSessionConfigurationChanged; break;
    }
    NSMutableDictionary *info = [NSMutableDictionary dictionaryWithDictionary:[error userInfo]];
    [info setObject:error forKey:NSUnderlyingErrorKey];
    id finished = [[error userInfo] objectForKey:AVErrorRecordingSuccessfullyFinishedKey];
    if (finished)
        [info setObject:finished forKey:QTErrorRecordingSuccesfullyFinishedKey];
    return [NSError errorWithDomain:QTKitErrorDomain code:code userInfo:info];
}

static void onMainThread(dispatch_block_t block)
{
    if ([NSThread isMainThread])
        block();
    else
        dispatch_async(dispatch_get_main_queue(), block);
}

// ---- QTCaptureDevice

static NSMutableDictionary *deviceWrappers;     // uniqueID -> QTCaptureDevice
static char HSCaptureDeviceKVOContext;

// Device state that QTKit observers watched by key-value observing; the
// wrapper passes on its AVCaptureDevice's changes.
static NSArray *HSCaptureDeviceForwardedKeyPaths(void)
{
    return @[@"inUseByAnotherApplication", @"suspended", @"connected"];
}

@implementation QTCaptureDevice

+ (void)initialize
{
    if (self != [QTCaptureDevice class])
        return;
    deviceWrappers = [[NSMutableDictionary alloc] init];
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserverForName:AVCaptureDeviceWasConnectedNotification object:nil queue:[NSOperationQueue mainQueue]
                    usingBlock:^(NSNotification *note) {
        QTCaptureDevice *device = [QTCaptureDevice deviceWithAVCaptureDevice:[note object]];
        [[NSNotificationCenter defaultCenter] postNotificationName:QTCaptureDeviceWasConnectedNotification object:device];
    }];
    [center addObserverForName:AVCaptureDeviceWasDisconnectedNotification object:nil queue:[NSOperationQueue mainQueue]
                    usingBlock:^(NSNotification *note) {
        QTCaptureDevice *device = [QTCaptureDevice deviceWithAVCaptureDevice:[note object]];
        [[NSNotificationCenter defaultCenter] postNotificationName:QTCaptureDeviceWasDisconnectedNotification object:device];
    }];
}

+ (QTCaptureDevice *)deviceWithAVCaptureDevice:(AVCaptureDevice *)avDevice
{
    if (!avDevice)
        return nil;
    @synchronized (deviceWrappers) {
        QTCaptureDevice *device = [deviceWrappers objectForKey:[avDevice uniqueID]];
        if (!device || device->_device != avDevice) {
            device = [[[QTCaptureDevice alloc] init] autorelease];
            device->_device = [avDevice retain];
            for (NSString *keyPath in HSCaptureDeviceForwardedKeyPaths())
                [avDevice addObserver:device forKeyPath:keyPath options:NSKeyValueObservingOptionPrior context:&HSCaptureDeviceKVOContext];
            [deviceWrappers setObject:device forKey:[avDevice uniqueID]];
        }
        return device;
    }
}

+ (NSArray *)wrap:(NSArray *)avDevices
{
    NSMutableArray *result = [NSMutableArray array];
    for (AVCaptureDevice *device in avDevices)
        [result addObject:[self deviceWithAVCaptureDevice:device]];
    return result;
}

+ (NSArray *)inputDevices
{
    NSMutableArray *devices = [NSMutableArray array];
    for (NSString *type in @[AVMediaTypeVideo, AVMediaTypeAudio, AVMediaTypeMuxed])
        for (QTCaptureDevice *device in [self inputDevicesWithMediaType:HSQTMediaTypeFromAVMediaType(type)])
            if (![devices containsObject:device])
                [devices addObject:device];
    return devices;
}

+ (NSArray *)inputDevicesWithMediaType:(NSString *)mediaType
{
    return [self wrap:[AVCaptureDevice devicesWithMediaType:HSAVMediaTypeFromQTMediaType(mediaType)]];
}

+ (QTCaptureDevice *)defaultInputDeviceWithMediaType:(NSString *)mediaType
{
    return [self deviceWithAVCaptureDevice:[AVCaptureDevice defaultDeviceWithMediaType:HSAVMediaTypeFromQTMediaType(mediaType)]];
}

+ (QTCaptureDevice *)deviceWithUniqueID:(NSString *)deviceUniqueID
{
    return [self deviceWithAVCaptureDevice:[AVCaptureDevice deviceWithUniqueID:deviceUniqueID]];
}

- (id)initWithCoder:(NSCoder *)coder
{
    NSString *uniqueID = [coder allowsKeyedCoding] ? [coder decodeObjectForKey:@"uniqueID"] : [coder decodeObject];
    [self release];
    return [[QTCaptureDevice deviceWithUniqueID:uniqueID] retain];
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    if ([coder allowsKeyedCoding])
        [coder encodeObject:[self uniqueID] forKey:@"uniqueID"];
    else
        [coder encodeObject:[self uniqueID]];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context != &HSCaptureDeviceKVOContext) {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        return;
    }
    if ([[change objectForKey:NSKeyValueChangeNotificationIsPriorKey] boolValue])
        [self willChangeValueForKey:keyPath];
    else
        [self didChangeValueForKey:keyPath];
}

- (void)dealloc
{
    for (NSString *keyPath in HSCaptureDeviceForwardedKeyPaths())
        [_device removeObserver:self forKeyPath:keyPath context:&HSCaptureDeviceKVOContext];
    [_device release];
    [super dealloc];
}

- (AVCaptureDevice *)AVCaptureDevice { return _device; }
- (NSString *)uniqueID { return [_device uniqueID]; }
- (NSString *)modelUniqueID { return [_device modelID]; }
- (NSString *)localizedDisplayName { return [_device localizedName]; }
- (NSString *)description { return [self localizedDisplayName]; }
- (BOOL)isConnected { return [_device isConnected]; }
- (BOOL)isInUseByAnotherApplication { return [_device isInUseByAnotherApplication]; }
- (BOOL)isSuspended { return [_device isSuspended]; }
- (BOOL)isOpen { return _openCount > 0; }

- (BOOL)hasMediaType:(NSString *)mediaType
{
    return [_device hasMediaType:HSAVMediaTypeFromQTMediaType(mediaType)];
}

- (NSArray *)formatDescriptions
{
    CMFormatDescriptionRef format = [[_device activeFormat] formatDescription];
    QTFormatDescription *description = [[[QTFormatDescription alloc] initWithCMFormatDescription:format] autorelease];
    return description ? [NSArray arrayWithObject:description] : [NSArray array];
}

- (id)attributeForKey:(NSString *)key
{
    if ([key isEqualToString:QTCaptureDeviceSuspendedAttribute])
        return [NSNumber numberWithBool:[_device isSuspended]];
    if ([key isEqualToString:QTCaptureDeviceLinkedDevicesAttribute])
        return [QTCaptureDevice wrap:[_device linkedDevices]];
    if ([key isEqualToString:QTCaptureDeviceAvailableInputSourcesAttribute]) {
        NSMutableArray *sources = [NSMutableArray array];
        for (AVCaptureDeviceInputSource *source in [_device inputSources])
            [sources addObject:@{ QTCaptureDeviceInputSourceIdentifierKey: [source inputSourceID],
                                  QTCaptureDeviceInputSourceLocalizedDisplayNameKey: [source localizedName] }];
        return sources;
    }
    if ([key isEqualToString:QTCaptureDeviceInputSourceIdentifierAttribute])
        return [[_device activeInputSource] inputSourceID];
    return nil;
}

- (NSDictionary *)deviceAttributes
{
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    for (NSString *key in @[QTCaptureDeviceSuspendedAttribute, QTCaptureDeviceLinkedDevicesAttribute,
                            QTCaptureDeviceAvailableInputSourcesAttribute, QTCaptureDeviceInputSourceIdentifierAttribute]) {
        id value = [self attributeForKey:key];
        if (value)
            [result setObject:value forKey:key];
    }
    return result;
}

- (BOOL)attributeIsReadOnly:(NSString *)key
{
    return ![key isEqualToString:QTCaptureDeviceInputSourceIdentifierAttribute];
}

- (void)setAttribute:(id)attribute forKey:(NSString *)key
{
    if (![key isEqualToString:QTCaptureDeviceInputSourceIdentifierAttribute])
        return;
    for (AVCaptureDeviceInputSource *source in [_device inputSources]) {
        if (![[source inputSourceID] isEqualToString:attribute])
            continue;
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        NSDictionary *info = [NSDictionary dictionaryWithObject:key forKey:QTCaptureDeviceChangedAttributeKey];
        [center postNotificationName:QTCaptureDeviceAttributeWillChangeNotification object:self userInfo:info];
        if ([_device lockForConfiguration:NULL]) {
            [_device setActiveInputSource:source];
            [_device unlockForConfiguration];
        }
        [center postNotificationName:QTCaptureDeviceAttributeDidChangeNotification object:self userInfo:info];
    }
}

- (void)setDeviceAttributes:(NSDictionary *)deviceAttributes
{
    for (NSString *key in deviceAttributes)
        [self setAttribute:[deviceAttributes objectForKey:key] forKey:key];
}

// Opening a device asks for the user's permission to use it.
- (BOOL)open:(NSError **)errorPtr
{
    if (![_device isConnected]) {
        if (errorPtr)
            *errorPtr = captureError(QTErrorDeviceNotConnected, @"The device is not connected.", nil);
        return NO;
    }
    NSMutableArray *types = [NSMutableArray array];
    if ([_device hasMediaType:AVMediaTypeVideo] || [_device hasMediaType:AVMediaTypeMuxed])
        [types addObject:AVMediaTypeVideo];
    if ([_device hasMediaType:AVMediaTypeAudio] || [_device hasMediaType:AVMediaTypeMuxed])
        [types addObject:AVMediaTypeAudio];
    for (AVMediaType type in types) {
        AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:type];
        if (status == AVAuthorizationStatusNotDetermined) {
            __block BOOL answered = NO, granted = NO;
            [AVCaptureDevice requestAccessForMediaType:type completionHandler:^(BOOL ok) {
                granted = ok;
                answered = YES;
            }];
            while (!answered)
                [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.05]];
            status = granted ? AVAuthorizationStatusAuthorized : AVAuthorizationStatusDenied;
        }
        if (status != AVAuthorizationStatusAuthorized) {
            if (errorPtr)
                *errorPtr = captureError(QTErrorDeviceExcludedByAnotherDevice,
                                         @"HyperStudio is not allowed to use this device. You can allow it in System Settings > Privacy & Security.", nil);
            return NO;
        }
    }
    _openCount++;
    return YES;
}

- (void)close
{
    if (_openCount > 0)
        _openCount--;
}

@end

// ---- QTCaptureConnection

@implementation QTCaptureConnection

- (id)initWithOwner:(id)owner inputPort:(AVCaptureInputPort *)port
{
    if ((self = [super init])) {
        _owner = owner;
        _port = [port retain];
        _attributes = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (id)initWithOwner:(id)owner connection:(AVCaptureConnection *)connection
{
    if ((self = [super init])) {
        _owner = owner;
        _connection = [connection retain];
        _attributes = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [_port release];
    [_connection release];
    [_attributes release];
    [super dealloc];
}

- (id)owner { return _owner; }
- (AVCaptureInputPort *)AVCaptureInputPort { return _port ? _port : [[_connection inputPorts] firstObject]; }
- (AVCaptureConnection *)AVCaptureConnection { return _connection; }

- (NSString *)mediaType
{
    return HSQTMediaTypeFromAVMediaType([[self AVCaptureInputPort] mediaType]);
}

- (QTFormatDescription *)formatDescription
{
    return [[[QTFormatDescription alloc] initWithCMFormatDescription:[[self AVCaptureInputPort] formatDescription]] autorelease];
}

- (BOOL)isEnabled { return _connection ? [_connection isEnabled] : [_port isEnabled]; }

- (void)setEnabled:(BOOL)enabled
{
    if (_connection)
        [_connection setEnabled:enabled];
    else
        [_port setEnabled:enabled];
}

// The session connections that carry this one's port: the levels are theirs.
- (NSArray *)sessionConnections
{
    if (_connection)
        return [NSArray arrayWithObject:_connection];
    NSMutableArray *result = [NSMutableArray array];
    QTCaptureSession *session = nil;
    if ([_owner isKindOfClass:[QTCaptureInput class]])
        session = ((QTCaptureInput *)_owner)->_session;
    for (AVCaptureConnection *connection in [[session AVCaptureSession] connections])
        if ([[connection inputPorts] containsObject:_port])
            [result addObject:connection];
    return result;
}

- (NSArray *)levels:(BOOL)peak
{
    for (AVCaptureConnection *connection in [self sessionConnections]) {
        NSArray *channels = [connection audioChannels];
        if (![channels count])
            continue;
        NSMutableArray *levels = [NSMutableArray array];
        for (AVCaptureAudioChannel *channel in channels)
            [levels addObject:[NSNumber numberWithFloat:peak ? [channel peakHoldLevel] : [channel averagePowerLevel]]];
        return levels;
    }
    return nil;
}

- (id)attributeForKey:(NSString *)key
{
    if ([key isEqualToString:QTCaptureConnectionAudioAveragePowerLevelsAttribute])
        return [self levels:NO];
    if ([key isEqualToString:QTCaptureConnectionAudioPeakHoldLevelsAttribute])
        return [self levels:YES];
    if ([key isEqualToString:QTCaptureConnectionAudioMasterVolumeAttribute]) {
        id volume = [_attributes objectForKey:key];
        return volume ? volume : [NSNumber numberWithFloat:1.0];
    }
    return [_attributes objectForKey:key];
}

- (void)setAttribute:(id)attribute forKey:(NSString *)key
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    NSDictionary *info = [NSDictionary dictionaryWithObject:key forKey:QTCaptureConnectionChangedAttributeKey];
    [center postNotificationName:QTCaptureConnectionAttributeWillChangeNotification object:self userInfo:info];
    if (attribute)
        [_attributes setObject:attribute forKey:key];
    else
        [_attributes removeObjectForKey:key];
    // capture has no input gain any more: the master volume sets the monitor's
    if ([key isEqualToString:QTCaptureConnectionAudioMasterVolumeAttribute] && [_owner isKindOfClass:[QTCaptureInput class]]) {
        QTCaptureSession *session = ((QTCaptureInput *)_owner)->_session;
        for (AVCaptureOutput *output in [[session AVCaptureSession] outputs])
            if ([output isKindOfClass:[AVCaptureAudioPreviewOutput class]])
                [(AVCaptureAudioPreviewOutput *)output setVolume:[attribute floatValue]];
    }
    [center postNotificationName:QTCaptureConnectionAttributeDidChangeNotification object:self userInfo:info];
}

- (BOOL)attributeIsReadOnly:(NSString *)key
{
    return [key isEqualToString:QTCaptureConnectionAudioAveragePowerLevelsAttribute]
        || [key isEqualToString:QTCaptureConnectionAudioPeakHoldLevelsAttribute];
}

- (NSDictionary *)connectionAttributes
{
    NSMutableDictionary *result = [NSMutableDictionary dictionaryWithDictionary:_attributes];
    NSArray *levels = [self levels:NO];
    if (levels)
        [result setObject:levels forKey:QTCaptureConnectionAudioAveragePowerLevelsAttribute];
    return result;
}

- (void)setConnectionAttributes:(NSDictionary *)connectionAttributes
{
    for (NSString *key in connectionAttributes)
        [self setAttribute:[connectionAttributes objectForKey:key] forKey:key];
}

@end

// ---- inputs

@implementation QTCaptureInput

- (NSArray *)connections { return [NSArray array]; }

@end

@implementation QTCaptureDeviceInput

+ (id)deviceInputWithDevice:(QTCaptureDevice *)device
{
    return [[[self alloc] initWithDevice:device] autorelease];
}

- (id)initWithDevice:(QTCaptureDevice *)device
{
    if (!device) {
        [self release];
        return nil;
    }
    if ((self = [super init])) {
        _device = [device retain];
        _connections = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [_device release];
    [_input release];
    [_connections release];
    [super dealloc];
}

- (QTCaptureDevice *)device { return _device; }

- (AVCaptureDeviceInput *)AVCaptureInput
{
    if (!_input)
        _input = [[AVCaptureDeviceInput alloc] initWithDevice:[_device AVCaptureDevice] error:NULL];
    return _input;
}

- (NSArray *)connections
{
    NSArray *ports = [[self AVCaptureInput] ports];
    BOOL same = [ports count] == [_connections count];
    for (NSUInteger i = 0; same && i < [ports count]; i++)
        same = [[_connections objectAtIndex:i] AVCaptureInputPort] == [ports objectAtIndex:i];
    if (!same) {
        [_connections removeAllObjects];
        for (AVCaptureInputPort *port in ports)
            [_connections addObject:[[[QTCaptureConnection alloc] initWithOwner:self inputPort:port] autorelease]];
    }
    return [[_connections copy] autorelease];
}

@end

// ---- outputs

// AVFoundation's delegate for a QTCaptureOutput: it calls the output, which
// it doesn't retain (the output clears it when it goes).
@interface HSCaptureOutputBridge : NSObject <AVCaptureVideoDataOutputSampleBufferDelegate,
                                             AVCaptureAudioDataOutputSampleBufferDelegate,
                                             AVCaptureFileOutputRecordingDelegate>
{
@public
    QTCaptureOutput *_owner;
}
@end

@interface QTCaptureOutput (HSQTKitPrivate)
- (void)setSession:(QTCaptureSession *)session;
- (void)didOutputSampleBuffer:(CMSampleBufferRef)buffer fromConnection:(AVCaptureConnection *)connection;
- (void)didDropSampleBuffer:(CMSampleBufferRef)buffer fromConnection:(AVCaptureConnection *)connection;
@end

@implementation HSCaptureOutputBridge

- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    @autoreleasepool {
        QTCaptureOutput *owner = [_owner retain];
        [owner didOutputSampleBuffer:sampleBuffer fromConnection:connection];
        [owner release];
    }
}

- (void)captureOutput:(AVCaptureOutput *)output didDropSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    @autoreleasepool {
        QTCaptureOutput *owner = [_owner retain];
        [owner didDropSampleBuffer:sampleBuffer fromConnection:connection];
        [owner release];
    }
}

- (NSArray *)qtConnections:(NSArray *)connections
{
    NSMutableArray *result = [NSMutableArray array];
    for (AVCaptureConnection *connection in connections) {
        QTCaptureConnection *c = [_owner connectionForAVCaptureConnection:connection];
        if (c)
            [result addObject:c];
    }
    return result;
}

- (void)captureOutput:(AVCaptureFileOutput *)output didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray *)connections
{
    QTCaptureFileOutput *owner = (QTCaptureFileOutput *)[_owner retain];
    NSArray *qtConnections = [[self qtConnections:connections] retain];
    onMainThread(^{
        id delegate = [owner delegate];
        if ([delegate respondsToSelector:@selector(captureOutput:willStartRecordingToOutputFileAtURL:forConnections:)])
            [delegate captureOutput:owner willStartRecordingToOutputFileAtURL:fileURL forConnections:qtConnections];
        if ([delegate respondsToSelector:@selector(captureOutput:didStartRecordingToOutputFileAtURL:forConnections:)])
            [delegate captureOutput:owner didStartRecordingToOutputFileAtURL:fileURL forConnections:qtConnections];
        [qtConnections release];
        [owner release];
    });
}

- (void)captureOutput:(AVCaptureFileOutput *)output didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error
{
    QTCaptureFileOutput *owner = (QTCaptureFileOutput *)[_owner retain];
    NSArray *qtConnections = [[self qtConnections:connections] retain];
    NSError *qtError = [qtErrorFromAVError(error) retain];
    onMainThread(^{
        id delegate = [owner delegate];
        if (qtError && [delegate respondsToSelector:@selector(captureOutput:mustChangeOutputFileAtURL:forConnections:dueToError:)])
            [delegate captureOutput:owner mustChangeOutputFileAtURL:outputFileURL forConnections:qtConnections dueToError:qtError];
        if ([delegate respondsToSelector:@selector(captureOutput:willFinishRecordingToOutputFileAtURL:forConnections:dueToError:)])
            [delegate captureOutput:owner willFinishRecordingToOutputFileAtURL:outputFileURL forConnections:qtConnections dueToError:qtError];
        if ([delegate respondsToSelector:@selector(captureOutput:didFinishRecordingToOutputFileAtURL:forConnections:dueToError:)])
            [delegate captureOutput:owner didFinishRecordingToOutputFileAtURL:outputFileURL forConnections:qtConnections dueToError:qtError];
        [qtError release];
        [qtConnections release];
        [owner release];
    });
}

- (void)captureOutput:(AVCaptureFileOutput *)output didPauseRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray *)connections
{
    QTCaptureFileOutput *owner = (QTCaptureFileOutput *)[_owner retain];
    NSArray *qtConnections = [[self qtConnections:connections] retain];
    onMainThread(^{
        id delegate = [owner delegate];
        if ([delegate respondsToSelector:@selector(captureOutput:didPauseRecordingToOutputFileAtURL:forConnections:)])
            [delegate captureOutput:owner didPauseRecordingToOutputFileAtURL:fileURL forConnections:qtConnections];
        [qtConnections release];
        [owner release];
    });
}

- (void)captureOutput:(AVCaptureFileOutput *)output didResumeRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray *)connections
{
    QTCaptureFileOutput *owner = (QTCaptureFileOutput *)[_owner retain];
    NSArray *qtConnections = [[self qtConnections:connections] retain];
    onMainThread(^{
        id delegate = [owner delegate];
        if ([delegate respondsToSelector:@selector(captureOutput:didResumeRecordingToOutputFileAtURL:forConnections:)])
            [delegate captureOutput:owner didResumeRecordingToOutputFileAtURL:fileURL forConnections:qtConnections];
        [qtConnections release];
        [owner release];
    });
}

@end

@implementation QTCaptureOutput

- (id)init
{
    if ((self = [super init])) {
        HSCaptureOutputBridge *bridge = [[HSCaptureOutputBridge alloc] init];
        bridge->_owner = self;
        _bridge = bridge;
        _connections = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc
{
    ((HSCaptureOutputBridge *)_bridge)->_owner = nil;
    [_bridge release];
    [_output release];
    [_connections release];
    [super dealloc];
}

- (AVCaptureOutput *)AVCaptureOutput { return _output; }
- (void)setSession:(QTCaptureSession *)session { _session = session; }
- (void)didOutputSampleBuffer:(CMSampleBufferRef)buffer fromConnection:(AVCaptureConnection *)connection {}
- (void)didDropSampleBuffer:(CMSampleBufferRef)buffer fromConnection:(AVCaptureConnection *)connection {}

- (QTCaptureConnection *)connectionForAVCaptureConnection:(AVCaptureConnection *)connection
{
    @synchronized (_connections) {
        for (QTCaptureConnection *c in _connections)
            if ([c AVCaptureConnection] == connection)
                return c;
        if (!connection)
            return nil;
        QTCaptureConnection *c = [[[QTCaptureConnection alloc] initWithOwner:self connection:connection] autorelease];
        [_connections addObject:c];
        return c;
    }
}

- (NSArray *)connections
{
    NSMutableArray *result = [NSMutableArray array];
    for (AVCaptureConnection *connection in [_output connections])
        [result addObject:[self connectionForAVCaptureConnection:connection]];
    @synchronized (_connections) {
        [_connections setArray:result];
    }
    return result;
}

@end

@implementation QTCaptureFileOutput

- (id)init
{
    if ((self = [super init])) {
        _compressionOptions = [[NSMutableDictionary alloc] init];
        _maximumRecordedDuration = QTZeroTime;
    }
    return self;
}

- (void)dealloc
{
    [_outputFileURL release];
    [_compressionOptions release];
    [super dealloc];
}

- (AVCaptureFileOutput *)fileOutput { return (AVCaptureFileOutput *)_output; }
- (NSURL *)outputFileURL { return [[self fileOutput] outputFileURL]; }
- (id)delegate { return _delegate; }
- (void)setDelegate:(id)delegate { _delegate = delegate; }

- (void)recordToOutputFileURL:(NSURL *)url
{
    [self recordToOutputFileURL:url bufferDestination:QTCaptureFileOutputBufferDestinationNewFile];
}

- (void)recordToOutputFileURL:(NSURL *)url bufferDestination:(QTCaptureFileOutputBufferDestination)bufferDestination
{
    AVCaptureFileOutput *output = [self fileOutput];
    if (!url) {
        if ([output isRecording])
            [output stopRecording];
        return;
    }
    [[NSFileManager defaultManager] removeItemAtURL:url error:NULL];
    [output startRecordingToOutputFileURL:url recordingDelegate:_bridge];
}

- (BOOL)isRecordingPaused { return [[self fileOutput] isRecordingPaused]; }
- (void)pauseRecording { [[self fileOutput] pauseRecording]; }
- (void)resumeRecording { [[self fileOutput] resumeRecording]; }

- (QTCompressionOptions *)compressionOptionsForConnection:(QTCaptureConnection *)connection
{
    return [_compressionOptions objectForKey:[NSValue valueWithNonretainedObject:[connection AVCaptureConnection]]];
}

- (void)setCompressionOptions:(QTCompressionOptions *)compressionOptions forConnection:(QTCaptureConnection *)connection
{
    NSValue *key = [NSValue valueWithNonretainedObject:[connection AVCaptureConnection]];
    if (compressionOptions)
        [_compressionOptions setObject:compressionOptions forKey:key];
    else
        [_compressionOptions removeObjectForKey:key];
    if (![_output isKindOfClass:[AVCaptureMovieFileOutput class]] || ![connection AVCaptureConnection])
        return;
    AVCaptureMovieFileOutput *output = (AVCaptureMovieFileOutput *)_output;
    NSDictionary *settings = [compressionOptions AVOutputSettings];
    @try {
        [output setOutputSettings:settings forConnection:[connection AVCaptureConnection]];
    }
    @catch (NSException *e) {
        // a size the device can't scale to: the codec alone
        NSString *codec = [settings objectForKey:AVVideoCodecKey];
        @try {
            [output setOutputSettings:codec ? [NSDictionary dictionaryWithObject:codec forKey:AVVideoCodecKey] : nil
                        forConnection:[connection AVCaptureConnection]];
        }
        @catch (NSException *e) {
        }
    }
}

- (QTTime)maximumRecordedDuration { return _maximumRecordedDuration; }

- (void)setMaximumRecordedDuration:(QTTime)maximumRecordedDuration
{
    _maximumRecordedDuration = maximumRecordedDuration;
    [[self fileOutput] setMaxRecordedDuration:maximumRecordedDuration.timeValue ? HSCMTimeFromQTTime(maximumRecordedDuration) : kCMTimeInvalid];
}

- (UInt64)maximumRecordedFileSize { return _maximumRecordedFileSize; }

- (void)setMaximumRecordedFileSize:(UInt64)maximumRecordedFileSize
{
    _maximumRecordedFileSize = maximumRecordedFileSize;
    [[self fileOutput] setMaxRecordedFileSize:(int64_t)maximumRecordedFileSize];
}

- (QTTime)recordedDuration { return HSQTTimeFromCMTime([[self fileOutput] recordedDuration]); }
- (UInt64)recordedFileSize { return (UInt64)[[self fileOutput] recordedFileSize]; }

@end

@implementation QTCaptureMovieFileOutput

- (id)init
{
    if ((self = [super init])) {
        AVCaptureMovieFileOutput *output = [[AVCaptureMovieFileOutput alloc] init];
        [output setMovieFragmentInterval:kCMTimeInvalid];
        _output = output;
    }
    return self;
}

@end

@implementation QTCaptureDecompressedVideoOutput

- (id)init
{
    if ((self = [super init])) {
        AVCaptureVideoDataOutput *output = [[AVCaptureVideoDataOutput alloc] init];
        [output setAlwaysDiscardsLateVideoFrames:NO];
        _queue = dispatch_queue_create("QTCaptureDecompressedVideoOutput", DISPATCH_QUEUE_SERIAL);
        [output setSampleBufferDelegate:_bridge queue:_queue];
        _output = output;
    }
    return self;
}

- (void)dealloc
{
    [(AVCaptureVideoDataOutput *)_output setSampleBufferDelegate:nil queue:NULL];
    [_pixelBufferAttributes release];
    if (_queue)
        dispatch_release(_queue);
    [super dealloc];
}

- (id)delegate { return _delegate; }
- (void)setDelegate:(id)delegate { _delegate = delegate; }
- (NSDictionary *)pixelBufferAttributes { return _pixelBufferAttributes; }

// AVFoundation takes one pixel format it can make, and a size.
- (void)setPixelBufferAttributes:(NSDictionary *)pixelBufferAttributes
{
    [_pixelBufferAttributes autorelease];
    _pixelBufferAttributes = [pixelBufferAttributes copy];
    AVCaptureVideoDataOutput *output = (AVCaptureVideoDataOutput *)_output;
    NSMutableDictionary *settings = [NSMutableDictionary dictionary];
    id formats = [pixelBufferAttributes objectForKey:(id)kCVPixelBufferPixelFormatTypeKey];
    if (formats && ![formats isKindOfClass:[NSArray class]])
        formats = [NSArray arrayWithObject:formats];
    NSArray *available = [output availableVideoCVPixelFormatTypes];
    NSNumber *format = nil;
    for (NSNumber *f in formats)
        if ([available containsObject:f]) {
            format = f;
            break;
        }
    if (!format && [formats count])
        format = [NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA];
    if (format)
        [settings setObject:format forKey:(id)kCVPixelBufferPixelFormatTypeKey];
    for (id key in @[(id)kCVPixelBufferWidthKey, (id)kCVPixelBufferHeightKey]) {
        id value = [pixelBufferAttributes objectForKey:key];
        if (value)
            [settings setObject:value forKey:key];
    }
    @try {
        [output setVideoSettings:[settings count] ? settings : nil];
    }
    @catch (NSException *e) {
        [settings removeObjectForKey:(id)kCVPixelBufferWidthKey];
        [settings removeObjectForKey:(id)kCVPixelBufferHeightKey];
        [output setVideoSettings:[settings count] ? settings : nil];
    }
}

- (NSTimeInterval)minimumVideoFrameInterval { return _minimumVideoFrameInterval; }
- (void)setMinimumVideoFrameInterval:(NSTimeInterval)interval { _minimumVideoFrameInterval = interval; }
- (BOOL)automaticallyDropsLateVideoFrames { return [(AVCaptureVideoDataOutput *)_output alwaysDiscardsLateVideoFrames]; }
- (void)setAutomaticallyDropsLateVideoFrames:(BOOL)drops { [(AVCaptureVideoDataOutput *)_output setAlwaysDiscardsLateVideoFrames:drops]; }

- (void)didOutputSampleBuffer:(CMSampleBufferRef)buffer fromConnection:(AVCaptureConnection *)connection
{
    if (_minimumVideoFrameInterval > 0) {
        NSTimeInterval t = CMTimeGetSeconds(CMSampleBufferGetPresentationTimeStamp(buffer));
        if (_lastFrameTime && t - _lastFrameTime < _minimumVideoFrameInterval)
            return;
        _lastFrameTime = t;
    }
    QTSampleBuffer *sample = [[[QTSampleBuffer alloc] initWithCMSampleBuffer:buffer connection:connection] autorelease];
    [self outputVideoFrame:CMSampleBufferGetImageBuffer(buffer) withSampleBuffer:sample
            fromConnection:[self connectionForAVCaptureConnection:connection]];
}

- (void)didDropSampleBuffer:(CMSampleBufferRef)buffer fromConnection:(AVCaptureConnection *)connection
{
    id delegate = _delegate;
    if ([delegate respondsToSelector:@selector(captureOutput:didDropVideoFrameWithSampleBuffer:fromConnection:)])
        [delegate captureOutput:self
                  didDropVideoFrameWithSampleBuffer:[[[QTSampleBuffer alloc] initWithCMSampleBuffer:buffer connection:connection] autorelease]
                  fromConnection:[self connectionForAVCaptureConnection:connection]];
}

- (void)outputVideoFrame:(CVImageBufferRef)videoFrame withSampleBuffer:(QTSampleBuffer *)sampleBuffer fromConnection:(QTCaptureConnection *)connection
{
    id delegate = _delegate;
    if ([delegate respondsToSelector:@selector(captureOutput:didOutputVideoFrame:withSampleBuffer:fromConnection:)])
        [delegate captureOutput:self didOutputVideoFrame:videoFrame withSampleBuffer:sampleBuffer fromConnection:connection];
}

@end

@implementation QTCaptureVideoPreviewOutput

- (id)init
{
    if ((self = [super init]))
        [self setAutomaticallyDropsLateVideoFrames:YES];
    return self;
}

@end

@implementation QTCaptureDecompressedAudioOutput

- (id)init
{
    if ((self = [super init])) {
        AVCaptureAudioDataOutput *output = [[AVCaptureAudioDataOutput alloc] init];
        // QTKit's: 32-bit float, non-interleaved, at the device's rate
        [output setAudioSettings:@{ AVFormatIDKey: @(kAudioFormatLinearPCM), AVLinearPCMBitDepthKey: @32,
                                    AVLinearPCMIsFloatKey: @YES, AVLinearPCMIsNonInterleaved: @YES,
                                    AVLinearPCMIsBigEndianKey: @NO }];
        _queue = dispatch_queue_create("QTCaptureDecompressedAudioOutput", DISPATCH_QUEUE_SERIAL);
        [output setSampleBufferDelegate:_bridge queue:_queue];
        _output = output;
    }
    return self;
}

- (void)dealloc
{
    [(AVCaptureAudioDataOutput *)_output setSampleBufferDelegate:nil queue:NULL];
    if (_queue)
        dispatch_release(_queue);
    [super dealloc];
}

- (id)delegate { return _delegate; }
- (void)setDelegate:(id)delegate { _delegate = delegate; }

- (void)didOutputSampleBuffer:(CMSampleBufferRef)buffer fromConnection:(AVCaptureConnection *)connection
{
    QTSampleBuffer *sample = [[[QTSampleBuffer alloc] initWithCMSampleBuffer:buffer connection:connection] autorelease];
    [self outputAudioSampleBuffer:sample fromConnection:[self connectionForAVCaptureConnection:connection]];
}

- (void)outputAudioSampleBuffer:(QTSampleBuffer *)sampleBuffer fromConnection:(QTCaptureConnection *)connection
{
    id delegate = _delegate;
    if ([delegate respondsToSelector:@selector(captureOutput:didOutputAudioSampleBuffer:fromConnection:)])
        [delegate captureOutput:self didOutputAudioSampleBuffer:sampleBuffer fromConnection:connection];
}

@end

@implementation QTCaptureAudioPreviewOutput

- (id)init
{
    if ((self = [super init]))
        _output = [[AVCaptureAudioPreviewOutput alloc] init];
    return self;
}

- (NSString *)outputDeviceUniqueID { return [(AVCaptureAudioPreviewOutput *)_output outputDeviceUniqueID]; }
- (void)setOutputDeviceUniqueID:(NSString *)uniqueID { [(AVCaptureAudioPreviewOutput *)_output setOutputDeviceUniqueID:uniqueID]; }
- (float)volume { return [(AVCaptureAudioPreviewOutput *)_output volume]; }
- (void)setVolume:(float)volume { [(AVCaptureAudioPreviewOutput *)_output setVolume:volume]; }

@end

// ---- QTCaptureSession

@implementation QTCaptureSession

- (id)init
{
    if ((self = [super init])) {
        _session = [[AVCaptureSession alloc] init];
        _inputs = [[NSMutableArray alloc] init];
        _outputs = [[NSMutableArray alloc] init];
        _errorObserver = [[[NSNotificationCenter defaultCenter] addObserverForName:AVCaptureSessionRuntimeErrorNotification
                                                                            object:_session queue:[NSOperationQueue mainQueue]
                                                                        usingBlock:^(NSNotification *note) {
            NSError *error = qtErrorFromAVError([[note userInfo] objectForKey:AVCaptureSessionErrorKey]);
            [[NSNotificationCenter defaultCenter] postNotificationName:QTCaptureSessionRuntimeErrorNotification object:self
                                                              userInfo:error ? [NSDictionary dictionaryWithObject:error forKey:QTCaptureSessionErrorKey] : nil];
        }] retain];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:_errorObserver];
    [_errorObserver release];
    if ([_session isRunning])
        [_session stopRunning];
    for (QTCaptureInput *input in _inputs)
        input->_session = nil;
    for (QTCaptureOutput *output in _outputs)
        [output setSession:nil];
    [_session release];
    [_inputs release];
    [_outputs release];
    [super dealloc];
}

- (AVCaptureSession *)AVCaptureSession { return _session; }
- (NSArray *)inputs { return [[_inputs copy] autorelease]; }
- (NSArray *)outputs { return [[_outputs copy] autorelease]; }

- (BOOL)addInput:(QTCaptureInput *)input error:(NSError **)errorPtr
{
    if (![input isKindOfClass:[QTCaptureDeviceInput class]]) {
        if (errorPtr)
            *errorPtr = captureError(QTErrorIncompatibleInput, @"The input is not a device input.", nil);
        return NO;
    }
    QTCaptureDevice *device = [(QTCaptureDeviceInput *)input device];
    NSError *error = nil;
    AVCaptureDeviceInput *avInput = [(QTCaptureDeviceInput *)input AVCaptureInput];
    if (!avInput) {
        avInput = [AVCaptureDeviceInput deviceInputWithDevice:[device AVCaptureDevice] error:&error];
        if (!avInput) {
            if (errorPtr)
                *errorPtr = qtErrorFromAVError(error);
            return NO;
        }
    }
    [_session beginConfiguration];
    BOOL ok = [_session canAddInput:avInput];
    if (ok)
        [_session addInput:avInput];
    [_session commitConfiguration];
    if (!ok) {
        if (errorPtr)
            *errorPtr = captureError([device isInUseByAnotherApplication] ? QTErrorDeviceInUseByAnotherApplication : QTErrorInvalidInputsOrOutputs,
                                     @"The device can't be added to the capture session.", nil);
        return NO;
    }
    input->_session = self;
    [_inputs addObject:input];
    return YES;
}

- (void)removeInput:(QTCaptureInput *)input
{
    if (![_inputs containsObject:input])
        return;
    [_session beginConfiguration];
    [_session removeInput:[(QTCaptureDeviceInput *)input AVCaptureInput]];
    [_session commitConfiguration];
    input->_session = nil;
    [_inputs removeObject:input];
}

- (BOOL)addOutput:(QTCaptureOutput *)output error:(NSError **)errorPtr
{
    AVCaptureOutput *avOutput = [output AVCaptureOutput];
    [_session beginConfiguration];
    BOOL ok = avOutput && [_session canAddOutput:avOutput];
    if (ok)
        [_session addOutput:avOutput];
    [_session commitConfiguration];
    if (!ok) {
        if (errorPtr)
            *errorPtr = captureError(QTErrorIncompatibleOutput, @"The output can't be added to the capture session.", nil);
        return NO;
    }
    [output setSession:self];
    [_outputs addObject:output];
    return YES;
}

- (void)removeOutput:(QTCaptureOutput *)output
{
    if (![_outputs containsObject:output])
        return;
    [_session beginConfiguration];
    [_session removeOutput:[output AVCaptureOutput]];
    [_session commitConfiguration];
    [output setSession:nil];
    [_outputs removeObject:output];
}

- (void)startRunning { [_session startRunning]; }
- (void)stopRunning { [_session stopRunning]; }
- (BOOL)isRunning { return [_session isRunning]; }

@end

// ---- QTCaptureView

@implementation QTCaptureView

- (void)setUp
{
    [self setWantsLayer:YES];
    _previewLayer = [[AVCaptureVideoPreviewLayer alloc] init];
    [_previewLayer setVideoGravity:AVLayerVideoGravityResizeAspect];
    [_previewLayer setFrame:NSRectToCGRect([self bounds])];
    [_previewLayer setAutoresizingMask:kCALayerWidthSizable | kCALayerHeightSizable];
    [[self layer] addSublayer:_previewLayer];
    _preservesAspectRatio = YES;
    _fillColor = [[NSColor blackColor] retain];
    [[self layer] setBackgroundColor:[_fillColor CGColor]];
}

- (id)initWithFrame:(NSRect)frame
{
    if ((self = [super initWithFrame:frame]))
        [self setUp];
    return self;
}

- (id)initWithCoder:(NSCoder *)coder
{
    if ((self = [super initWithCoder:coder]))
        [self setUp];
    return self;
}

- (void)dealloc
{
    [_previewLayer setSession:nil];
    [_previewLayer release];
    [_captureSession release];
    [_videoPreviewConnection release];
    [_fillColor release];
    [super dealloc];
}

- (QTCaptureSession *)captureSession { return _captureSession; }

- (void)setCaptureSession:(QTCaptureSession *)captureSession
{
    if (captureSession == _captureSession)
        return;
    [_captureSession release];
    _captureSession = [captureSession retain];
    [_previewLayer setSession:[captureSession AVCaptureSession]];
}

- (NSArray *)availableVideoPreviewConnections
{
    NSMutableArray *result = [NSMutableArray array];
    for (QTCaptureInput *input in [_captureSession inputs])
        for (QTCaptureConnection *connection in [input connections])
            if ([[connection mediaType] isEqualToString:QTMediaTypeVideo] || [[connection mediaType] isEqualToString:QTMediaTypeMuxed])
                [result addObject:connection];
    return result;
}

- (QTCaptureConnection *)videoPreviewConnection
{
    return _videoPreviewConnection ? _videoPreviewConnection : [[self availableVideoPreviewConnections] firstObject];
}

- (void)setVideoPreviewConnection:(QTCaptureConnection *)videoPreviewConnection
{
    [_videoPreviewConnection autorelease];
    _videoPreviewConnection = [videoPreviewConnection retain];
}

- (NSColor *)fillColor { return _fillColor; }

- (void)setFillColor:(NSColor *)fillColor
{
    [_fillColor autorelease];
    _fillColor = [fillColor retain];
    [[self layer] setBackgroundColor:[fillColor CGColor]];
}

- (BOOL)preservesAspectRatio { return _preservesAspectRatio; }

- (void)setPreservesAspectRatio:(BOOL)preservesAspectRatio
{
    _preservesAspectRatio = preservesAspectRatio;
    [_previewLayer setVideoGravity:preservesAspectRatio ? AVLayerVideoGravityResizeAspect : AVLayerVideoGravityResize];
}

- (NSRect)previewBounds
{
    NSRect bounds = [self bounds];
    if (!_preservesAspectRatio)
        return bounds;
    QTFormatDescription *format = [[self videoPreviewConnection] formatDescription];
    NSSize size = [[format attributeForKey:QTFormatDescriptionVideoCleanApertureDisplaySizeAttribute] sizeValue];
    if (size.width <= 0 || size.height <= 0)
        return bounds;
    return NSRectFromCGRect(AVMakeRectWithAspectRatioInsideRect(NSSizeToCGSize(size), NSRectToCGRect(bounds)));
}

- (id)delegate { return _delegate; }
- (void)setDelegate:(id)delegate { _delegate = delegate; }

@end
