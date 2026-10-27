#import "HyperPlayerBasePrefix.h"


@interface HSWebCamRendererRegister : NSObject <HSWeakReferencer>
{
    NSMutableDictionary *_renderersInfo;
    NSMutableArray *_unregisterTimers;
}
+ (id)sharedWebCamRendererRegister;
- (void)dealloc;
- (void)dereferenceObject:(id)aObject;
- (NSRect)clipRectForWebCamWithID:(id)aID;
- (NSSize)pageSizeForWebCamWithID:(id)aID;
- (void)reportError:(id)aError;
- (void)webCamClipInfoValidatingFailed:(id)aFailed;
- (void)webCamClipInfoValidatingComplete:(id)aComplete;
- (void)validateWebCamWithID:(id)aID pageSize:(NSSize)aSize clipRect:(NSRect)aRect;
- (NSInteger)validityStateForWebCamWithID:(id)aID;
- (void)rendererDidLiveEnough:(id)aEnough;
- (void)cancelScheduledRemovalOfWebPageRendererForCamID:(id)aID;
- (void)scheduleRemovalOfWebPageRendererForCamID:(id)aID;
- (void)unregisterWebPageRenderer:(id)aRenderer user:(id)aUser;
- (void)rendererDidUpdate:(id)aUpdate;
- (void)refreshOnTimer:(id)aTimer;
- (void)reloadWebCamWithID:(id)aID;
- (void)setNewRefreshRate:(CGFloat)aRate user:(id)aUser webPageRendererWithCamID:(id)aID;
- (id)registeredWebPageRendererForCamID:(id)aID pageURL:(id)aURL pageSize:(NSSize)aSize refreshRate:(CGFloat)aRate user:(id)aUser;
- (id)init;
@end

