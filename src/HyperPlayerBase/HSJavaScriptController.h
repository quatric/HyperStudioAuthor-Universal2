#import "HyperPlayerBasePrefix.h"


@interface HSJavaScriptController : NSObject <HSScriptController, NSObject>
{
    id _delegate;
    id _dataSource;
    id _scriptObject;
    NSString *_script;
    BOOL _isScriptReady;
    BOOL _isWebKitSupportJavaScript;
    BOOL _isStartPreloading;
    HSJavaScriptBridge *_javaScriptBridge;
    NSSet *_mappedUIDs;
    BOOL _isStartupScriptLoadedValid;
    BOOL _isStartupScriptLoaded;
    NSMutableDictionary *_locals;
}
+ (id)buildUIDSetFromObjects:(id)aObjects;
- (void)setIsMapped:(BOOL)aMapped;
- (BOOL)isMapped;
- (void)setJavaScriptBridge:(id)aBridge;
- (id)javaScriptBridge;
- (void)setIsWebKitSupportJavaScript:(BOOL)aScript;
- (BOOL)isWebKitSupportJavaScript;
- (void)setIsScriptReady:(BOOL)aReady;
- (BOOL)isScriptReady;
- (void)setScript:(id)aScript;
- (id)script;
- (void)setScriptObject:(id)aObject;
- (id)scriptObject;
- (void)setDataSource:(id)aSource;
- (id)dataSource;
- (void)setDelegate:(id)aDelegate;
- (id)delegate;
- (void)dealloc;
- (id)init;
- (void)scriptFinish:(id)aFinish;
- (void)scriptStart:(id)aStart;
- (void)processAbortApplication:(id)aApplication;
- (void)processAbortTransite:(id)aTransite;
- (void)processAbortDocument:(id)aDocument;
- (void)processAbortScript:(id)aScript;
- (void)processAbortAction:(id)aAction;
- (BOOL)isAbortResult:(id)aResult;
- (id)evaluateScript:(id)aScript withSender:(id)aSender;
- (id)evaluateScript:(id)aScript;
- (BOOL)isStartupScriptLoaded;
- (id)internalEvaluateScript:(id)aScript;
- (void)mapGlobals;
- (void)unmapLocals;
- (void)mapLocal:(id)aLocal withName:(id)aName;
- (BOOL)isScriptable:(id)aScriptable;
- (id)locals;
- (void)errorScript:(id)aScript;
- (void)javaScriptBridgeDidReady:(id)aReady;
- (void)reload;
- (BOOL)waitUntilLoad;
- (void)beginPreloading;
@end

