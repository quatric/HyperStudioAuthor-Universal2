#import "HyperPlayerBasePrefix.h"


@interface HSQuickCaptureImageController : NSObject <HSCaptureDeviceSessionClient>
{
    HSCaptureDeviceSession *_captureSession;
    id<HSImageRequestor> _consumer;
    QTCaptureDevice *_videoDevice;
    BOOL _didReceiveFirstFrame;
}
+ (Class)frameProcessorClass;
+ (id)allocWithZone:(NSZone *)aZone;
+ (id)sharedQuickCaptureImageController;
- (void)captureDeviceSessionRuntimeErrorNotification:(id)aNotification;
- (void)didReceiveFrame:(id)aFrame;
- (void)captureDeviceSession:(id)aSession didReceiveFrame:(id)aFrame fromFrameProcessorOfClass:(Class)aClass;
- (BOOL)requestImageFor:(id)aFor;
- (void)updateVideoDevice;
- (id)videoDevice;
- (BOOL)isInputDeviceValid:(id)aValid;
- (void)dealloc;
- (void)destroyCapturingSession;
- (void)deactivateCapturingSession;
- (void)activateCapturingSession;
- (void)createCapturingSession;
- (id)autorelease;
- (void)release;
- (NSUInteger)retainCount;
- (id)retain;
- (id)copyWithZone:(NSZone *)aZone;
@end

