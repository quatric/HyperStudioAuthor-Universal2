#import "HyperPlayerBasePrefix.h"


@interface HSWebCamDataProvider : NSObject
{
    NSString *_appIDStr;
}
+ (CGFloat)safariApplicationVersion;
+ (id)sharedWebCamDataProvider;
- (void)terminateUpdate:(id)aUpdate;
- (void)update:(id)aUpdate;
- (void)terminateUpdatesChecking:(id)aChecking;
- (void)checkForUpdates:(id)aUpdates;
- (id)databaseVersionError:(id *)aError;
- (void)validateClipForWebCam:(id)aCam;
- (void)webCamsForFilterPredicate:(id)aPredicate sortDescriptors:(id)aDescriptors category:(id)aCategory error:(id *)aError;
- (id)attributes:(id)aAttributes forWebCam:(id)aCam error:(id *)aError;
- (id)attributes:(id)aAttributes forCategory:(id)aCategory error:(id *)aError;
- (id)childrenOfWebCamCategory:(id)aCategory error:(id *)aError;
- (BOOL)isWebCamCategoryExpandable:(id)aExpandable error:(id *)aError;
- (id)proxyToService;
- (id)serviceApplicationBundlePath;
- (id)connectionToService;
- (void)dealloc;
- (void)setApplicationIdentifier:(id)aIdentifier;
- (id)init;
@end

