#import "HyperPlayerBasePrefix.h"


@interface HSVideoCaptureDevicePlaceholderRenderer : NSObject
{
    QTCaptureDevice *_videoCaptureDevice;
    HSCaptureDeviceList *_captureVideoDeviceList;
}
+ (id)placeholderRendererForVideoCaptureDevice:(id)aDevice;
- (void)drawRect:(NSRect)aRect withBounds:(NSRect)aBounds;
- (void)HSVideoCaptureDevicePlaceholderRenderer_getPlaceholderLabel:(id *)aLabel icon:(id *)aIcon;
- (id)videoCaptureDevice;
- (void)dealloc;
- (id)HSVideoCaptureDevicePlaceholderRenderer_initWithVideoCaptureDevice:(id)aDevice;
@end

