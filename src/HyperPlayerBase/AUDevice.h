#import "HyperPlayerBasePrefix.h"


@interface AUDevice : NSObject
{
    NSString *_deviceIdentifier;
}
+ (id)defaultOutputDevice;
+ (id)defaultInputDevice;
- (id)deviceIdentifier;
- (void)dealloc;
- (id)initWithDeviceIdentifier:(id)aIdentifier;
@end

@interface AUOutputDevice : AUDevice
{
}
- (void *)deviceMonitor;
@end

@interface AUInputDevice : AUDevice
{
}
- (void *)deviceMonitor;
@end

@interface AUDevice (AUDeviceAttributes)
- (id)hogProcessName;
- (BOOL)isInHogMode;
- (BOOL)isAlive;
- (BOOL)isAccessible;
- (void)disableNotifications;
- (void)enableNotifications;
@end

