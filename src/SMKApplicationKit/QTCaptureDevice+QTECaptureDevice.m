#import "QTCaptureDevice+QTECaptureDevice.h"

@implementation QTCaptureDevice (QTECaptureDevice)

// (Before 10.6 it opened the device and looked at the error.)
- (BOOL)QTE_isInUseByAnotherApplication
{
    return [self isInUseByAnotherApplication];
}

@end
