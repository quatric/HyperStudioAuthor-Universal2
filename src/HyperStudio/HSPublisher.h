#import "HyperStudioPrefix.h"


@interface HSPublisher : NSObject
{
    NSString *_publishLocation;
    id _delegate;
    HSExportPanelController *_exportPanelController;
    unsigned int _shouldTerminatePublish:1;
}
- (void)notifyPublishDidTerminate;
- (void)notifyPublishDidEnd;
- (void)notifyPublishWillEnd;
- (void)notifyPublishDidStart;
- (void)notifyPublishWillStart;
- (void)notifyPublishAlertInProgress:(id)aProgress;
- (void)notifyPublishErrorInProgress:(id)aProgress;
- (void)notifyPublishProgressDidChangeWithProgress:(double)aProgress;
- (void)terminatePublish;
- (void)publish:(id)aPublish;
- (void)setDelegate:(id)aDelegate;
- (id)delegate;
- (id)progressSheetDescription;
- (id)exportPanelController;
- (void)setPublishLocation:(id)aLocation;
- (id)publishLocation;
- (void)dealloc;
@end

