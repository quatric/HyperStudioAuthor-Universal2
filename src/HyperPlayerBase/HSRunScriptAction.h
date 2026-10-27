#import "HyperPlayerBasePrefix.h"
#import "HSScriptAction.h"


@interface HSRunScriptAction : HSScriptAction <HSRunScriptActionAttributes, HSActionAttributes, HSAttributes, HyperInterface, NSObject, HSAction, HSActionSynchronousAttribute, HSAttribute, HSActionEventsAttribute, HSActionLocalizedNameAttribute, HSScriptAttribute, HSRunScriptActionValidation>
{
    HSUserScript *_script;
}
- (BOOL)isHyperValid;
- (BOOL)hasHyperWarnings;
- (void)startInContext:(id)aContext;
- (void)showInvalidScriptAlert;
- (void)scriptDidFinish:(id)aFinish;
- (id)keysForExtraStoringWithCodingContext:(id)aContext;
- (void)setHyperScript:(id)aScript;
- (id)hyperScript;
- (void)dealloc;
@end

