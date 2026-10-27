#import "HSFrameProcessor.h"
// Base of the capture frame processors: a delegate guarded by a lock that
// subclasses hold while notifying it.
@implementation HSFrameProcessor
- (id)outputFrameForPreprocessedFrame:(id)aFrame
{
    return nil;
}
- (Class)preprocessingFrameProcessorClass
{
    return Nil;
}
- (void)unlockDelegateForNotification
{
    [_delegateLock unlock];
}
- (void)lockDelegateForNotification
{
    [_delegateLock lock];
}
- (void)setDelegate:(id)aDelegate
{
    if (_delegate != aDelegate) {
        [_delegateLock lock];
        _delegate = aDelegate;
        [_delegateLock unlock];
    }
}
- (id)delegate
{
    return _delegate;
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
    [_delegateLock release];
    [super dealloc];
}
- (id)init
{
    self = [super init];
    if (self != nil) {
        _delegateLock = [[NSRecursiveLock alloc] init];
        if (_delegateLock == nil) {
            [self release];
            return nil;
        }
    }
    return self;
}
@end
