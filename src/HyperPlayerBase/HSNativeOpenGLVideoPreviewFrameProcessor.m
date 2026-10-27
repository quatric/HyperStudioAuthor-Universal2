#import "HSNativeOpenGLVideoPreviewFrameProcessor.h"
// Camera frames as OpenGL-ready pixel buffers, taken from the native
// (decompressed or preview) processors.
@implementation HSNativeOpenGLVideoFrameProcessor
- (void)captureDeviceSession:(id)aSession didReceiveFrame:(id)aFrame fromFrameProcessorOfClass:(Class)aClass
{
    [self lockDelegateForNotification];
    id delegate = [self delegate];
    if ([delegate respondsToSelector:@selector(frameProcessor:didOutputFrame:)]) {
        CVPixelBufferRef buffer = (CVPixelBufferRef)[aFrame frameRepresentation];
        if (buffer != NULL && CFGetTypeID(buffer) != CVPixelBufferGetTypeID())
            buffer = NULL;
        HSNativeOpenGLVideoFrameProcessor_HSCapturedVideoFrame *frame =
            [[HSNativeOpenGLVideoFrameProcessor_HSCapturedVideoFrame alloc] initWithPixelBuffer:buffer sampleBuffer:[aFrame sampleBuffer]];
        if (frame != nil) {
            [delegate frameProcessor:self didOutputFrame:frame];
            [frame release];
        }
    }
    [self unlockDelegateForNotification];
}
- (id)outputFrameForPreprocessedFrame:(id)aFrame
{
    CVPixelBufferRef buffer = (CVPixelBufferRef)[aFrame frameRepresentation];
    if (buffer != NULL && CFGetTypeID(buffer) != CVPixelBufferGetTypeID())
        buffer = NULL;
    return [[[HSNativeOpenGLVideoFrameProcessor_HSCapturedVideoFrame alloc] initWithPixelBuffer:buffer sampleBuffer:[aFrame sampleBuffer]] autorelease];
}
- (Class)preprocessingFrameProcessorClass
{
    return [HSNativeVideoFrameProcessor class];
}
@end

@implementation HSNativeOpenGLVideoPreviewFrameProcessor
- (Class)preprocessingFrameProcessorClass
{
    return [HSNativeVideoPreviewFrameProcessor class];
}
@end

@implementation HSNativeOpenGLVideoFrameProcessor_HSCapturedVideoFrame
- (id)frameRepresentation
{
    return (id)_pixelBuffer;
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
    CVPixelBufferRelease(_pixelBuffer);
    [_sampleBuffer release];
    [super dealloc];
}
// A buffer OpenGL can't take is replaced by the sample's OpenGL-compatible
// copy; nil without either.
- (id)initWithPixelBuffer:(struct __CVBuffer *)aBuffer sampleBuffer:(id)aBuffer2
{
    self = [super init];
    if (self != nil) {
        if (aBuffer == NULL || !CVEPixelBufferIsOpenGLCompatible(aBuffer, NULL, NULL, NULL, NULL, NULL))
            aBuffer = [aBuffer2 QTE_openGLCompatiblePixelBuffer];
        _pixelBuffer = CVPixelBufferRetain(aBuffer);
        if (_pixelBuffer != NULL) {
            _sampleBuffer = [aBuffer2 retain];
            return self;
        }
        [self release];
    }
    return nil;
}
@end
