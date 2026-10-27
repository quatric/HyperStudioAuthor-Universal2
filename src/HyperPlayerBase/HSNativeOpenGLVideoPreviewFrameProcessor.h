#import "HyperPlayerBasePrefix.h"
#import "HSFrameProcessor.h"


@interface HSNativeOpenGLVideoFrameProcessor : HSFrameProcessor <HSCaptureDeviceSessionClient>
{
}
- (void)captureDeviceSession:(id)aSession didReceiveFrame:(id)aFrame fromFrameProcessorOfClass:(Class)aClass;
- (id)outputFrameForPreprocessedFrame:(id)aFrame;
- (Class)preprocessingFrameProcessorClass;
@end

@interface HSNativeOpenGLVideoPreviewFrameProcessor : HSNativeOpenGLVideoFrameProcessor
{
}
- (Class)preprocessingFrameProcessorClass;
@end

@interface HSNativeOpenGLVideoFrameProcessor_HSCapturedVideoFrame : NSObject <HSCapturedFrame, NSObject>
{
    struct __CVBuffer *_pixelBuffer;
    QTSampleBuffer *_sampleBuffer;
}
- (id)frameRepresentation;
- (BOOL)isFrameProcessed;
- (id)sampleBuffer;
- (void)dealloc;
- (id)initWithPixelBuffer:(struct __CVBuffer *)aBuffer sampleBuffer:(id)aBuffer2;
@end

