#import "HyperPlayerBasePrefix.h"
#import "HSFrameProcessor.h"


@interface HSNativeVideoFrameProcessor : HSFrameProcessor
{
}
- (void)captureOutput:(id)aOutput didOutputVideoFrame:(struct __CVBuffer *)aFrame withSampleBuffer:(id)aBuffer fromConnection:(id)aConnection;
- (void)abandonCaptureOutput:(id)aOutput;
- (id)createCaptureOutputForCaptureInputs:(id)aInputs;
@end

@interface HSNativeVideoPreviewFrameProcessor : HSNativeVideoFrameProcessor
{
}
- (id)createCaptureOutputForCaptureInputs:(id)aInputs;
@end

@interface HSNativeVideoFrameProcessor_HSCapturedVideoFrame : NSObject <HSCapturedFrame, NSObject>
{
    struct __CVBuffer *_imageBuffer;
    QTSampleBuffer *_sampleBuffer;
}
- (id)frameRepresentation;
- (BOOL)isFrameProcessed;
- (id)sampleBuffer;
- (void)dealloc;
- (id)initWithImageBuffer:(struct __CVBuffer *)aBuffer sampleBuffer:(id)aBuffer2;
@end

