#import "HyperStudioPrefix.h"


@interface HSWebCamImageLoader : NSObject
{
    NSMutableArray *_webcamUIDQueue;
    NSMutableArray *_webcamInvalidUIDs;
    NSDictionary *_webcamClipInfo;
    NSConditionLock *_webcamLoadedConditionalLock;
    BOOL _running;
    id _delegate;
}
- (void)reportError:(id)aError;
- (id)previewImageForWebCamUID:(id)aUID;
- (void)webCamClipInfoValidatingFailed:(id)aFailed;
- (void)webCamClipInfoValidatingComplete:(id)aComplete;
- (void)cancelAllRequests;
- (void)requestImageForWebCamUID:(id)aUID URL:(id)aURL;
- (void)webCamImageOffline:(id)aOffline;
- (void)webCamImageReady:(id)aReady;
- (void)loadQueuedImages:(id)aImages;
- (id)webcamLoadedConditionalLock;
- (void)setDelegate:(id)aDelegate;
- (id)delegate;
- (void)dealloc;
- (id)initWithDelegate:(id)aDelegate;
@end

