#import "HyperPlayerBasePrefix.h"


@interface HSCaptureView : NSEView <HSCaptureDeviceSessionClient>
{
    HSCaptureDeviceSession *_captureDeviceSession;
    HSVideoCaptureDevicePlaceholderRenderer *_placeholderRenderer;
    struct __CVDisplayLink *_displayLink;
    NSLock *_currentFrameLock;
    id<HSCapturedFrame> _currentFrame;
    id<NSEOpenGLTexture> _currentFrameTexture;
    unsigned int _isPreviewing:1;
    unsigned int _isActive:1;
    unsigned int _isDisplayLinkUpdateScheduled:1;
    unsigned int _isNewFrameCaptured:1;
}
+ (id)createDefaultOpenGLContext;
- (void)viewWillMoveToWindow:(id)aWindow;
- (void)observeValueForKeyPath:(id)aPath ofObject:(id)aObject change:(id)aChange context:(void *)aContext;
- (void)HSCaptureView_captureDeviceDidChangeState:(id)aState;
- (void)drawQuartzSurfaceRect:(NSRect)aRect;
- (BOOL)drawOpenGLSurfaceRect:(NSRect)aRect;
- (BOOL)shouldDisplayOpenGLSurface;
- (BOOL)isOpenGLSurfaceOpaque;
- (void)HSCaptureView_displayFrame;
- (void)updateOpenGLContext;
- (void)disassociateOpenGLContext;
- (BOOL)associateOpenGLContext;
- (void)captureDeviceSession:(id)aSession didReceiveFrame:(id)aFrame fromFrameProcessorOfClass:(Class)aClass;
- (void)stopPreviewing;
- (void)startPreviewing;
- (BOOL)isPreviewing;
- (void)setCaptureDeviceSession:(id)aSession;
- (id)captureDeviceSession;
- (BOOL)HSCaptureView_hasActiveVideoDevice;
- (void)HSCaptureView_invalidateCurrentFrame;
- (void)HSCaptureView_deactivateCaptureDeviceSession;
- (BOOL)HSCaptureView_activateCaptureDeviceSession;
- (void)HSCaptureView_startDisplayLink;
- (void)HSCaptureView_updateDisplayLink;
- (void)release;
- (void)dealloc;
@end

