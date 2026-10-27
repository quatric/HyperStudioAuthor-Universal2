#import "HyperPlayerBasePrefix.h"


@interface HSUpdater : NSObject
{
    NSString *_uniqueIdentifier;
    BOOL _isInAutoUpdate;
    NSWindow *_webCamProgressPanel;
    NSTextField *_webCamStatusTextField;
    NSTextField *_webCamProgressTextField;
    NSProgressIndicator *_webCamProgressBar;
    double _webCamProgressStartTime;
    NSImage *_webCamServiceImage;
}
+ (id)sharedUpdater;
- (void)cancelWebCamProgressPanel:(id)aPanel;
- (void)webCamUpdateNotificationProgress:(id)aProgress;
- (void)webCamUpdateNotificationTerminated:(id)aTerminated;
- (void)webCamUpdateNotificationFailed:(id)aFailed;
- (void)webCamUpdateNotificationComplete:(id)aComplete;
- (void)startWebCamUpdate;
- (void)webCamUpdateCheckingNotificationCompleteWithUpdatePresent:(id)aPresent;
- (void)showUpdatesPanelWithDictionary:(id)aDictionary;
- (id)checkedProductUpdatesDictionary:(id)aDictionary;
- (id)checkedDictionary:(id)aDictionary;
- (void)updateCheckingNotificationTerminated:(id)aTerminated;
- (void)updateCheckingNotificationFailed:(id)aFailed;
- (void)updateCheckingNotificationComplete:(id)aComplete;
- (void)terminateUpdatesChecking;
- (void)checkForUpdates;
- (void)automaticCheckForUpdates;
- (id)uniqueIdentifier;
- (void)startCheckForProductUpdates;
- (void)dealloc;
- (id)init;
@end

