#import "HyperPlayerBasePrefix.h"


@interface HSErrorManager : NSObject
{
    BOOL _isErrorPresent;
    int _lastResult;
}
+ (id)sharedErrorManager;
- (id)missingWebCamDatabaseErrorAlert;
- (id)genericWebCamServiceErrorAlert;
- (void)alertDidEnd:(id)aEnd returnCode:(NSInteger)aCode contextInfo:(void *)aInfo;
- (BOOL)isCorrectIPadDocumentFileWrapper:(id)aWrapper;
- (BOOL)isCorrectDocumentFileWrapper:(id)aWrapper;
- (NSInteger)lastResult;
- (BOOL)presentError:(id)aError;
- (BOOL)presentError:(id)aError inWindow:(id)aWindow;
- (BOOL)presentError:(id)aError inWindow:(id)aWindow delegate:(id)aDelegate didPresentSelector:(SEL)aSelector contextInfo:(void *)aInfo;
@end

@interface HSErrorManagerContextInfo : NSObject
{
    HSError *_error;
    id _errorDelegate;
    SEL _didPresentSelector;
    void *_contextInfo;
}
- (void *)contextInfo;
- (SEL)didPresentSelector;
- (id)errorDelegate;
- (id)error;
- (void)dealloc;
- (id)initWithError:(id)aError delegate:(id)aDelegate didPresentSelector:(SEL)aSelector contextInfo:(void *)aInfo;
@end

