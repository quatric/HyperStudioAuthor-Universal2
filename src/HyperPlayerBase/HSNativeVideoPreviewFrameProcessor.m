#import "HSNativeVideoPreviewFrameProcessor.h"
// Camera frames from a capture session: decompressed (in formats OpenGL
// takes) or preview frames.
@implementation HSNativeVideoFrameProcessor
- (void)captureOutput:(id)aOutput didOutputVideoFrame:(struct __CVBuffer *)aFrame withSampleBuffer:(id)aBuffer fromConnection:(id)aConnection
{
    [self lockDelegateForNotification];
    id delegate = [self delegate];
    if ([delegate respondsToSelector:@selector(frameProcessor:didOutputFrame:)]) {
        HSNativeVideoFrameProcessor_HSCapturedVideoFrame *frame =
            [[HSNativeVideoFrameProcessor_HSCapturedVideoFrame alloc] initWithImageBuffer:aFrame sampleBuffer:aBuffer];
        if (frame != nil) {
            [delegate frameProcessor:self didOutputFrame:frame];
            [frame release];
        }
    }
    [self unlockDelegateForNotification];
}
- (void)abandonCaptureOutput:(id)aOutput
{
    [aOutput setDelegate:nil];
}
- (id)createCaptureOutputForCaptureInputs:(id)aInputs
{
    NSArray *formats = [NSArray arrayWithObjects:[NSNumber numberWithUnsignedLong:kCVPixelFormatType_32BGRA],
                                                 [NSNumber numberWithUnsignedLong:kCVPixelFormatType_32ARGB],
                                                 [NSNumber numberWithUnsignedLong:kCVPixelFormatType_32ABGR],
                                                 [NSNumber numberWithUnsignedLong:kCVPixelFormatType_32RGBA],
                                                 [NSNumber numberWithUnsignedLong:kCVPixelFormatType_422YpCbCr8], nil];
    QTCaptureDecompressedVideoOutput *output = [[QTCaptureDecompressedVideoOutput alloc] init];
    [output setPixelBufferAttributes:[NSDictionary dictionaryWithObjectsAndKeys:formats, (NSString *)kCVPixelBufferPixelFormatTypeKey, nil]];
    [output setDelegate:self];
    return output;
}
@end

@implementation HSNativeVideoPreviewFrameProcessor
- (id)createCaptureOutputForCaptureInputs:(id)aInputs
{
    QTCaptureVideoPreviewOutput *output = [[QTCaptureVideoPreviewOutput alloc] init];
    [output setDelegate:self];
    return output;
}
@end

// Holds its sample in use unless the frame is a chunky pixel buffer.
static BOOL HSCapturedVideoFrameUsesSample(CVImageBufferRef aBuffer)
{
    return !(CFGetTypeID(aBuffer) == CVPixelBufferGetTypeID() && !CVPixelBufferIsPlanar(aBuffer));
}

@implementation HSNativeVideoFrameProcessor_HSCapturedVideoFrame
- (id)frameRepresentation
{
    return (id)_imageBuffer;
}
- (BOOL)isFrameProcessed
{
    return YES;
}
- (id)sampleBuffer
{
    return _sampleBuffer;
}
- (void)dealloc
{
    if (HSCapturedVideoFrameUsesSample(_imageBuffer))
        [_sampleBuffer decrementSampleUseCount];
    CVBufferRelease(_imageBuffer);
    [_sampleBuffer release];
    [super dealloc];
}
- (id)initWithImageBuffer:(struct __CVBuffer *)aBuffer sampleBuffer:(id)aBuffer2
{
    self = [super init];
    if (self != nil) {
        _imageBuffer = CVBufferRetain(aBuffer);
        _sampleBuffer = [aBuffer2 retain];
        if (HSCapturedVideoFrameUsesSample(_imageBuffer))
            [_sampleBuffer incrementSampleUseCount];
    }
    return self;
}
@end
