// MacKiev's update service is gone, so a check never starts: callers see no
// notifications, as when the original found no network.
#include "SMKCheckForUpdates.h"

const CFStringRef kCFUCheckForUpdatesStartedNotificationName = CFSTR("CFUCheckForUpdatesStartedNotification");
const CFStringRef kCFUCheckForUpdatesCompletedNotificationName = CFSTR("CFUCheckForUpdatesCompletedNotification");
const CFStringRef kCFUCheckForUpdatesFailedNotificationName = CFSTR("CFUCheckForUpdatesFailedNotification");
const CFStringRef kCFUCheckForUpdatesTerminatedNotificationName = CFSTR("CFUCheckForUpdatesTerminatedNotification");

void CFUCheckForUpdates(CFStringRef downloadURL, CFStringRef identifier)
{
	(void)downloadURL;
	(void)identifier;
}

void CFUTerminateCheckForUpdates(void)
{
}
