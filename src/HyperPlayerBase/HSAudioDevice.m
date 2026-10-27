#import "HSAudioDevice.h"
@implementation HSAudioDevice
+ (id)deviceDidChangeNotification
{
    return AUDeviceDidChangeNotification;
}
+ (id)hogModeDidChangeNotificationName
{
    return AUDeviceHogModeDidChangeNotification;
}
+ (id)aliveDidChangeNotificationName
{
    return AUDeviceAliveDidChange;
}
@end
