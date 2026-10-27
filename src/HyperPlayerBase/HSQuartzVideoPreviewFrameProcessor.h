#import "HyperPlayerBasePrefix.h"
#import "HSFrameProcessor.h"


@interface HSQuartzVideoFrameProcessor : HSFrameProcessor <HSCaptureDeviceSessionClient>
{
    pthread_mutex_t *_decompressionMutex;
    struct OpaqueVTDecompressionSession *_decompressionSession;     // an ICM decompression session in the original
    const struct opaqueCMFormatDescription *_frameImageDescription; // the ImageDescription handle in the original
    struct OpaqueVTPixelTransferSession *_pixelTransferSession;
}
- (struct CGImage *)HSQuartzVideoFrameProcessor_createImageWithPixelBuffer:(struct __CVBuffer *)aBuffer sampleBuffer:(id)aBuffer2;
- (void)captureDeviceSession:(id)aSession didReceiveFrame:(id)aFrame fromFrameProcessorOfClass:(Class)aClass;
- (id)outputFrameForPreprocessedFrame:(id)aFrame;
- (Class)preprocessingFrameProcessorClass;
- (void)abandonCaptureOutput:(id)aOutput;
- (id)createCaptureOutputForCaptureInputs:(id)aInputs;
- (void)dealloc;
- (id)init;
@end

@interface HSQuartzVideoPreviewFrameProcessor : HSQuartzVideoFrameProcessor
{
}
- (Class)preprocessingFrameProcessorClass;
@end

@interface HSQuartzVideoFrameProcessor_HSCapturedVideoFrame : NSObject <HSCapturedFrame, NSObject>
{
    struct CGImage *_image;
    QTSampleBuffer *_sampleBuffer;
    struct __CVBuffer *_pixelBuffer;
    HSQuartzVideoFrameProcessor *_frameProcessor;
}
+ (NSUInteger)_HS_pixelFormatType;
+ (BOOL)_HS_isAlphaPremultiplied;
+ (BOOL)_HS_shouldInterpolate;
- (id)frameRepresentation;
- (BOOL)isFrameProcessed;
- (id)sampleBuffer;
- (void)dealloc;
- (id)initWithImageBuffer:(struct __CVBuffer *)aBuffer sampleBuffer:(id)aBuffer2 frameProcessor:(id)aProcessor;
@end

