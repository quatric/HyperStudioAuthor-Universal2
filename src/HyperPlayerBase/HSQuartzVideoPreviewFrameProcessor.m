#import "HSQuartzVideoPreviewFrameProcessor.h"
#import "HSNativeVideoPreviewFrameProcessor.h"
#import <VideoToolbox/VideoToolbox.h>
#import <pthread.h>

// Camera frames as Quartz images, made from the frames of the native
// processors when first asked for. Frames whose pixel buffers Quartz can't
// take as they are (YUV preview frames), and compressed samples, are
// converted to 32-bit pixels first: the original decompresses either with an
// ICM decompression session made for the sample's image description; here a
// VideoToolbox pixel transfer session converts pixel buffers and a
// decompression session decodes compressed samples.
//
// Defaults: _HS_PixelFormatType (BGRA rather than ARGB pixels),
// _HS_IsAlphaPremultiplied and _HS_ShouldInterpolate.

@implementation HSQuartzVideoFrameProcessor

static void HSQuartzVideoFrameProcessorReleaseDecompressionSession(HSQuartzVideoFrameProcessor *self)
{
    if (self->_decompressionSession != NULL) {
        VTDecompressionSessionInvalidate(self->_decompressionSession);
        CFRelease(self->_decompressionSession);
        self->_decompressionSession = NULL;
    }
}

// The frame in the processor's pixel format, or NULL.
static CVPixelBufferRef HSQuartzVideoFrameProcessorCopyConvertedPixelBuffer(HSQuartzVideoFrameProcessor *self, CVPixelBufferRef aBuffer)
{
    OSType format = (OSType)[HSQuartzVideoFrameProcessor_HSCapturedVideoFrame _HS_pixelFormatType];
    if (self->_pixelTransferSession == NULL && VTPixelTransferSessionCreate(kCFAllocatorDefault, &self->_pixelTransferSession) != noErr)
        return NULL;
    NSDictionary *attributes = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:(NSString *)kCVPixelBufferCGImageCompatibilityKey];
    CVPixelBufferRef result = NULL;
    if (CVPixelBufferCreate(kCFAllocatorDefault, CVPixelBufferGetWidth(aBuffer), CVPixelBufferGetHeight(aBuffer), format,
                            (CFDictionaryRef)attributes, &result) != kCVReturnSuccess)
        return NULL;
    if (VTPixelTransferSessionTransferImage(self->_pixelTransferSession, aBuffer, result) != noErr) {
        CVPixelBufferRelease(result);
        return NULL;
    }
    CVBufferPropagateAttachments(aBuffer, result);
    return result;
}

// A compressed sample decoded, or NULL. The session is made again when the
// format changes.
static CVPixelBufferRef HSQuartzVideoFrameProcessorCopyDecodedPixelBuffer(HSQuartzVideoFrameProcessor *self, CMSampleBufferRef aSample)
{
    CMFormatDescriptionRef description = CMSampleBufferGetFormatDescription(aSample);
    if (description == NULL)
        return NULL;
    if (self->_frameImageDescription == NULL || !CMFormatDescriptionEqual(self->_frameImageDescription, description)) {
        if (self->_frameImageDescription != NULL)
            CFRelease(self->_frameImageDescription);
        self->_frameImageDescription = CFRetain(description);
        HSQuartzVideoFrameProcessorReleaseDecompressionSession(self);
    }
    if (self->_decompressionSession == NULL) {
        NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithUnsignedInt:(OSType)[HSQuartzVideoFrameProcessor_HSCapturedVideoFrame _HS_pixelFormatType]], kCVPixelBufferPixelFormatTypeKey,
            [NSNumber numberWithBool:YES], kCVPixelBufferCGImageCompatibilityKey, nil];
        if (VTDecompressionSessionCreate(kCFAllocatorDefault, (CMVideoFormatDescriptionRef)self->_frameImageDescription, NULL,
                                         (CFDictionaryRef)attributes, NULL, &self->_decompressionSession) != noErr)
            return NULL;
    }
    __block CVPixelBufferRef result = NULL;
    OSStatus status = VTDecompressionSessionDecodeFrameWithOutputHandler(self->_decompressionSession, aSample, 0, NULL,
        ^(OSStatus aStatus, VTDecodeInfoFlags aFlags, CVImageBufferRef aImage, CMTime aTime, CMTime aDuration) {
            if (aStatus == noErr && !(aFlags & kVTDecodeInfo_FrameDropped) && aImage != NULL && result == NULL)
                result = CVPixelBufferRetain(aImage);
        });
    if (status != noErr) {
        CVPixelBufferRelease(result);
        return NULL;
    }
    VTDecompressionSessionWaitForAsynchronousFrames(self->_decompressionSession);
    return result;
}

- (struct CGImage *)HSQuartzVideoFrameProcessor_createImageWithPixelBuffer:(struct __CVBuffer *)aBuffer sampleBuffer:(id)aBuffer2
{
    pthread_mutex_lock(_decompressionMutex);
    CVPixelBufferRef pixels = NULL;
    if (aBuffer != NULL && CVEPixelBufferGetDataSize(aBuffer) != 0) {
        pixels = HSQuartzVideoFrameProcessorCopyConvertedPixelBuffer(self, aBuffer);
    } else {
        CMSampleBufferRef sample = [aBuffer2 CMSampleBuffer];
        CVImageBufferRef image = sample != NULL ? CMSampleBufferGetImageBuffer(sample) : NULL;
        if (image != NULL && CFGetTypeID(image) == CVPixelBufferGetTypeID())
            pixels = HSQuartzVideoFrameProcessorCopyConvertedPixelBuffer(self, image);
        else if (sample != NULL)
            pixels = HSQuartzVideoFrameProcessorCopyDecodedPixelBuffer(self, sample);
    }
    CGImageRef result = NULL;
    if (pixels != NULL) {
        if ([HSQuartzVideoFrameProcessor_HSCapturedVideoFrame _HS_isAlphaPremultiplied])
            CVBufferSetAttachment(pixels, (CFStringRef)kCVEPixelBufferAlphaInfoKey, [NSNumber numberWithInt:1], kCVAttachmentMode_ShouldNotPropagate);
        result = CGEImageCreateWithPixelBuffer(pixels, kCVPixelBufferLock_ReadOnly, NULL,
                                               [HSQuartzVideoFrameProcessor_HSCapturedVideoFrame _HS_shouldInterpolate], kCGRenderingIntentDefault);
        CVPixelBufferRelease(pixels);
    }
    pthread_mutex_unlock(_decompressionMutex);
    return result;
}

- (void)captureDeviceSession:(id)aSession didReceiveFrame:(id)aFrame fromFrameProcessorOfClass:(Class)aClass
{
    [self lockDelegateForNotification];
    id delegate = [self delegate];
    if ([delegate respondsToSelector:@selector(frameProcessor:didOutputFrame:)]) {
        HSQuartzVideoFrameProcessor_HSCapturedVideoFrame *frame = [[HSQuartzVideoFrameProcessor_HSCapturedVideoFrame alloc]
            initWithImageBuffer:(CVImageBufferRef)[aFrame frameRepresentation] sampleBuffer:[aFrame sampleBuffer] frameProcessor:self];
        if (frame != nil) {
            [delegate frameProcessor:self didOutputFrame:frame];
            [frame release];
        }
    }
    [self unlockDelegateForNotification];
}

- (id)outputFrameForPreprocessedFrame:(id)aFrame
{
    return [[[HSQuartzVideoFrameProcessor_HSCapturedVideoFrame alloc] initWithImageBuffer:(CVImageBufferRef)[aFrame frameRepresentation]
                                                                             sampleBuffer:[aFrame sampleBuffer] frameProcessor:self] autorelease];
}

- (Class)preprocessingFrameProcessorClass
{
    return [HSNativeVideoFrameProcessor class];
}

- (void)abandonCaptureOutput:(id)aOutput
{
}

- (id)createCaptureOutputForCaptureInputs:(id)aInputs
{
    return nil;
}

- (void)dealloc
{
    HSQuartzVideoFrameProcessorReleaseDecompressionSession(self);
    if (_pixelTransferSession != NULL) {
        VTPixelTransferSessionInvalidate(_pixelTransferSession);
        CFRelease(_pixelTransferSession);
    }
    if (_frameImageDescription != NULL)
        CFRelease(_frameImageDescription);
    if (_decompressionMutex != NULL) {
        pthread_mutex_destroy(_decompressionMutex);
        NSZoneFree([super zone], _decompressionMutex);
    }
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self == nil)
        return nil;
    NSZone *zone = [super zone];
    _decompressionMutex = NSZoneMalloc(zone, sizeof(pthread_mutex_t));
    if (_decompressionMutex != NULL) {
        if (pthread_mutex_init(_decompressionMutex, NULL) == 0)
            return self;
        NSZoneFree(zone, _decompressionMutex);
        _decompressionMutex = NULL;
    }
    [super release];
    return nil;
}

@end

@implementation HSQuartzVideoPreviewFrameProcessor

- (Class)preprocessingFrameProcessorClass
{
    return [HSNativeVideoPreviewFrameProcessor class];
}

@end

@implementation HSQuartzVideoFrameProcessor_HSCapturedVideoFrame

+ (NSUInteger)_HS_pixelFormatType
{
    static OSType sPixelFormatType = 0;
    if (sPixelFormatType == 0)
        sPixelFormatType = [[NSUserDefaults standardUserDefaults] boolForKey:@"_HS_PixelFormatType"] ? kCVPixelFormatType_32BGRA : kCVPixelFormatType_32ARGB;
    return sPixelFormatType;
}

+ (BOOL)_HS_isAlphaPremultiplied
{
    static BOOL sIsInitialized = NO;
    static BOOL sIsAlphaPremultiplied = NO;
    if (!sIsInitialized) {
        sIsInitialized = YES;
        sIsAlphaPremultiplied = [[NSUserDefaults standardUserDefaults] boolForKey:@"_HS_IsAlphaPremultiplied"];
    }
    return sIsAlphaPremultiplied;
}

+ (BOOL)_HS_shouldInterpolate
{
    static BOOL sIsInitialized = NO;
    static BOOL sShouldInterpolate = YES;
    if (!sIsInitialized) {
        sIsInitialized = YES;
        id value = [[NSUserDefaults standardUserDefaults] objectForKey:@"_HS_ShouldInterpolate"];
        if (value != nil)
            sShouldInterpolate = [value boolValue];
    }
    return sShouldInterpolate;
}

// Made when first asked for; the pixel buffer (or the sample) and the
// processor are kept until then.
- (id)frameRepresentation
{
    if (_image == NULL) {
        _image = [_frameProcessor HSQuartzVideoFrameProcessor_createImageWithPixelBuffer:_pixelBuffer sampleBuffer:_sampleBuffer];
        if (_image == NULL)
            return nil;
        if (_pixelBuffer == NULL) {
            [_sampleBuffer decrementSampleUseCount];
        } else {
            CVPixelBufferRelease(_pixelBuffer);
            _pixelBuffer = NULL;
        }
        [_frameProcessor release];
        _frameProcessor = nil;
    }
    return (id)_image;
}

- (BOOL)isFrameProcessed
{
    return _image != NULL;
}

- (id)sampleBuffer
{
    return _sampleBuffer;
}

- (void)dealloc
{
    if (_image == NULL) {
        if (_pixelBuffer == NULL)
            [_sampleBuffer decrementSampleUseCount];
        else
            CVPixelBufferRelease(_pixelBuffer);
        [_frameProcessor release];
    } else {
        CGImageRelease(_image);
    }
    [_sampleBuffer release];
    [super dealloc];
}

// Chunky pixel buffers Quartz takes become images right away.
- (id)initWithImageBuffer:(struct __CVBuffer *)aBuffer sampleBuffer:(id)aBuffer2 frameProcessor:(id)aProcessor
{
    self = [super init];
    if (self == nil)
        return nil;
    if (aBuffer != NULL && CFGetTypeID(aBuffer) == CVPixelBufferGetTypeID()) {
        if ([HSQuartzVideoFrameProcessor_HSCapturedVideoFrame _HS_isAlphaPremultiplied])
            CVBufferSetAttachment(aBuffer, (CFStringRef)kCVEPixelBufferAlphaInfoKey, [NSNumber numberWithInt:1], kCVAttachmentMode_ShouldNotPropagate);
        _image = CGEImageCreateWithPixelBuffer(aBuffer, kCVPixelBufferLock_ReadOnly, NULL,
                                               [HSQuartzVideoFrameProcessor_HSCapturedVideoFrame _HS_shouldInterpolate], kCGRenderingIntentDefault);
        if (_image == NULL && !CVPixelBufferIsPlanar(aBuffer))
            _pixelBuffer = CVPixelBufferRetain(aBuffer);
    }
    if (_image == NULL) {
        if (_pixelBuffer == NULL)
            [aBuffer2 incrementSampleUseCount];
        _frameProcessor = [aProcessor retain];
    }
    _sampleBuffer = [aBuffer2 retain];
    return self;
}

@end
