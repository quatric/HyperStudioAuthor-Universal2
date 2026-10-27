#import "HyperPlayerBasePrefix.h"
#import "AUDevice.h"


@interface HSAudioDevice : AUDevice
{
}
+ (id)deviceDidChangeNotification;
+ (id)hogModeDidChangeNotificationName;
+ (id)aliveDidChangeNotificationName;
@end

