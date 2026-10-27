#import "HyperPlayerBasePrefix.h"
#import "HSScriptAction.h"


@interface HSRunAppleScriptAction : HSNBAAction <HSRunAppleScriptActionAttributes, HSActionAttributes, HSAttributes, HyperInterface, NSObject, HSAction, HSActionSynchronousAttribute, HSAttribute, HSActionEventsAttribute, HSActionLocalizedNameAttribute, HSUseCustomAppleScriptSourceAttribute, HSAppleScriptURLAttribute, HSAppleScriptSourceAttribute>
{
    BOOL _useCustomScriptSource;
    NSURL *_scriptURL;
    NSString *_scriptSource;
}
- (BOOL)isValid;
- (void)setAppleScriptSource:(id)aSource;
- (id)appleScriptSource;
- (void)setAppleScriptURL:(id)aURL;
- (id)appleScriptURL;
- (void)setUseCustomAppleScriptSource:(BOOL)aSource;
- (BOOL)useCustomAppleScriptSource;
- (void)startInContext:(id)aContext;
- (id)keysForExtraStoringWithCodingContext:(id)aContext;
- (void)dealloc;
@end

