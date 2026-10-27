#import "HyperPlayerBasePrefix.h"


@interface HSFrameProcessor : NSObject <HSFrameProcessor, NSObject>
{
    id _delegate;
    NSRecursiveLock *_delegateLock;
}
- (id)outputFrameForPreprocessedFrame:(id)aFrame;
- (Class)preprocessingFrameProcessorClass;
- (void)unlockDelegateForNotification;
- (void)lockDelegateForNotification;
- (void)setDelegate:(id)aDelegate;
- (id)delegate;
- (void)abandonCaptureOutput:(id)aOutput;
- (id)createCaptureOutputForCaptureInputs:(id)aInputs;
- (void)dealloc;
- (id)init;
@end

