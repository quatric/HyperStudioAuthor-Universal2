#import "HSQuickCaptureImageController.h"
#import "HSCaptureDeviceSession.h"
#import "HSQuartzVideoPreviewFrameProcessor.h"
#import "NSImage+HSImageSize.h"
#import "QTCaptureDevice+QTECaptureDevice.h"

// Takes a single picture from the preferred video device: a request starts a
// capture session, the first frame is skipped (cameras tend to deliver a dark
// one while warming up) and the second frame goes to the requestor, after
// which the session is torn down again.

@protocol HSImageRequestor <NSObject>
- (void)quickCaptureImageController:(HSQuickCaptureImageController *)aController didProduceImage:(NSImage *)aImage;
@end

static HSQuickCaptureImageController *sSharedQuickCaptureImageController = nil;

@implementation HSQuickCaptureImageController

+ (Class)frameProcessorClass
{
    return [HSQuartzVideoFrameProcessor class];
}

// Original quirk kept: once the shared controller exists, further
// allocations return nil rather than the shared instance.
+ (id)allocWithZone:(NSZone *)aZone
{
    @synchronized (self) {
        if (sSharedQuickCaptureImageController == nil) {
            sSharedQuickCaptureImageController = [super allocWithZone:aZone];
            return sSharedQuickCaptureImageController;
        }
    }
    return nil;
}

+ (id)sharedQuickCaptureImageController
{
    @synchronized (self) {
        if (sSharedQuickCaptureImageController == nil)
            [[self alloc] init];
    }
    return sSharedQuickCaptureImageController;
}

- (void)captureDeviceSessionRuntimeErrorNotification:(id)aNotification
{
    [self deactivateCapturingSession];
    [self destroyCapturingSession];
    if (_consumer != nil) {
        [_consumer quickCaptureImageController:self didProduceImage:nil];
        _consumer = nil;
    }
    _didReceiveFirstFrame = NO;
}

- (void)didReceiveFrame:(id)aFrame
{
    if (!_didReceiveFirstFrame) {
        _didReceiveFirstFrame = YES;
        return;
    }
    if (_consumer != nil) {
        [self deactivateCapturingSession];
        [self destroyCapturingSession];
        id representation = [aFrame frameRepresentation];
        NSImage *image = nil;
        if (representation != nil)
            image = [NSImage hyperImageWithCGImage:(CGImageRef)representation];
        [_consumer quickCaptureImageController:self didProduceImage:image];
        _consumer = nil;
    }
    _didReceiveFirstFrame = NO;
}

- (void)captureDeviceSession:(id)aSession didReceiveFrame:(id)aFrame fromFrameProcessorOfClass:(Class)aClass
{
    [self performSelectorOnMainThread:@selector(didReceiveFrame:) withObject:aFrame waitUntilDone:NO];
}

- (BOOL)requestImageFor:(id)aFor
{
    if (_consumer != nil)
        return NO;
    BOOL started = NO;
    if (aFor != nil) {
        [self updateVideoDevice];
        if ([self videoDevice] != nil) {
            [self createCapturingSession];
            if (_captureSession != nil) {
                [self activateCapturingSession];
                started = YES;
            }
        }
    }
    _consumer = started ? aFor : nil;
    return started;
}

// The device chosen in the preferences, else the default video device, else
// the first usable one.
- (void)updateVideoDevice
{
    QTCaptureDevice *device = nil;
    NSString *uniqueID = [[NSUserDefaults standardUserDefaults] stringForKey:HSVideoDeviceUniqueIDKey];
    if (uniqueID != nil) {
        device = [QTCaptureDevice deviceWithUniqueID:uniqueID];
        if (![self isInputDeviceValid:device])
            device = nil;
    }
    if (device == nil) {
        device = [QTCaptureDevice defaultInputDeviceWithMediaType:QTMediaTypeVideo];
        if (![self isInputDeviceValid:device]) {
            device = nil;
            for (QTCaptureDevice *candidate in [QTCaptureDevice inputDevicesWithMediaType:QTMediaTypeVideo]) {
                if ([self isInputDeviceValid:candidate]) {
                    device = candidate;
                    break;
                }
            }
        }
    }
    if (_videoDevice != device) {
        [_videoDevice release];
        _videoDevice = [device retain];
    }
}

- (id)videoDevice
{
    return _videoDevice;
}

- (BOOL)isInputDeviceValid:(id)aValid
{
    if (![aValid isConnected] || [aValid QTE_isInUseByAnotherApplication])
        return NO;
    return ![[aValid attributeForKey:QTCaptureDeviceSuspendedAttribute] boolValue];
}

- (void)dealloc
{
    if (_captureSession != nil) {
        [self deactivateCapturingSession];
        [self destroyCapturingSession];
    }
    [_videoDevice release];
    [super dealloc];
}

- (void)destroyCapturingSession
{
    if (_captureSession != nil) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"HSCaptureDeviceSessionRuntimeErrorNotification" object:nil];
        [_captureSession release];
        _captureSession = nil;
    }
}

- (void)deactivateCapturingSession
{
    [_captureSession deactivateForClient:self withFrameProcessorClass:[HSQuickCaptureImageController frameProcessorClass]];
}

- (void)activateCapturingSession
{
    [_captureSession activateForClient:self withFrameProcessorClass:[HSQuickCaptureImageController frameProcessorClass]];
}

- (void)createCapturingSession
{
    if (_captureSession == nil && _videoDevice != nil) {
        _captureSession = [[HSCaptureDeviceSession captureDeviceSessionForDevice:_videoDevice] retain];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(captureDeviceSessionRuntimeErrorNotification:) name:@"HSCaptureDeviceSessionRuntimeErrorNotification" object:_captureSession];
    }
}

- (id)autorelease
{
    return self;
}

- (void)release
{
}

- (NSUInteger)retainCount
{
    return NSUIntegerMax;
}

- (id)retain
{
    return self;
}

- (id)copyWithZone:(NSZone *)aZone
{
    return self;
}

@end
