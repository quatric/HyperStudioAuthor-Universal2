#import "HyperPlayerBasePrefix.h"
#import "HSScriptAction.h"


@interface HSTestingFunctionsAction : HSNBAAction <HSTestingFunctionsActionAttributes, HSActionAttributes, HSAttributes, HyperInterface, NSObject, HSAction, HSActionSynchronousAttribute, HSAttribute, HSActionEventsAttribute, HSActionLocalizedNameAttribute, HSTestingFunctionTypeAttribute>
{
    int _testingFunctionType;
    NSWindow *_askUserNameWindow;
    NSTextField *_userNameField;
    NSButton *_defaultButton;
}
- (void)setTestingFunctionType:(NSInteger)aType;
- (NSInteger)testingFunctionType;
- (BOOL)canChangeSynchronousFlag;
- (BOOL)isSynchronous;
- (void)sheetDidEnd:(id)aEnd returnCode:(NSInteger)aCode contextInfo:(void *)aInfo;
- (void)userNameEntered:(id)aEntered;
- (void)startInContext:(id)aContext;
- (void)alertDidEnd:(id)aEnd returnCode:(NSInteger)aCode contextInfo:(void *)aInfo;
- (void)continueInContext:(id)aContext;
- (id)askUserNameWindow;
- (id)keysForExtraStoringWithCodingContext:(id)aContext;
@end

