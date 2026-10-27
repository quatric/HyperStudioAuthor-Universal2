// MacKiev's update checker (SMKCheckForUpdates.framework, version B).
#import <CoreFoundation/CoreFoundation.h>

#ifdef __cplusplus
extern "C" {
#endif

extern const CFStringRef kCFUCheckForUpdatesStartedNotificationName;
extern const CFStringRef kCFUCheckForUpdatesCompletedNotificationName;
extern const CFStringRef kCFUCheckForUpdatesFailedNotificationName;
extern const CFStringRef kCFUCheckForUpdatesTerminatedNotificationName;

// downloadURL is the app's HSUpdatesDownloadURL Info.plist value,
// identifier the updater's unique identifier.
void CFUCheckForUpdates(CFStringRef downloadURL, CFStringRef identifier);
void CFUTerminateCheckForUpdates(void);

#ifdef __cplusplus
}
#endif
