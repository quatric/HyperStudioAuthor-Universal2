#import "HyperStudioPrefix.h"


@interface HSCaptureImageController : HSGenericModalController <HSCaptureDeviceSessionClient>
{
    HSCaptureDeviceSession *_captureSession;
    NSImage *_capturedImage;
    NSButton *_captureButton;
    HSCaptureView *_captureView;
    HSImageView *_imageView;
    NSImageView *_capturedImageView;
    NSPopUpButton *_videoCaptureDevicesPopUp;
    NSButton *_OKButton;
    QTCaptureDevice *_videoDevice;
    HSCaptureDeviceList *_videoCaptureDeviceList;
}
- (void)ok:(id)aOk;
- (void)videoDeviceDidChange:(id)aChange;
- (void)captureDeviceSession:(id)aSession didReceiveFrame:(id)aFrame fromFrameProcessorOfClass:(Class)aClass;
- (NSSize)capturePreviewSize;
- (id)capturedImage;
- (void)prepareCaptureSession;
- (void)capture:(id)aCapture;
- (void)prepareForCapturing;
- (void)validateUI;
- (void)stopPreviewingAndDisableScreenUpdates:(BOOL)aUpdates;
- (void)startPreviewing;
- (void)deviceStateDidChange;
- (void)sessionErrorDidReceive:(id)aReceive;
- (void)observeValueForKeyPath:(id)aPath ofObject:(id)aObject change:(id)aChange context:(void *)aContext;
- (id)deviceValidationKeys;
- (id)videoCaptureDeviceList;
- (void)changePreviewingVideoDeviceTo:(id)aTo;
- (void)setVideoDevice:(id)aDevice;
- (id)videoDevice;
- (BOOL)isInputDeviceValid:(id)aValid;
- (BOOL)isPreviewing;
- (void)selectDefaultVideoDevice;
- (BOOL)selectVideoDeviceFromUserDefaults;
- (void)setOKButtonTitle:(id)aTitle;
- (void)willCloseWindow;
- (void)willShowWindow;
- (void)didLoadNib;
- (id)nibName;
- (void)dealloc;
@end

