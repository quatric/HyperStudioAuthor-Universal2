#import "HyperPlayerBasePrefix.h"
#import "HSScriptAction.h"


@interface HSQuitAnotherApplicationAction : HSNBAAction <HSQuitAnotherApplicationActionAttributes, HSActionAttributes, HSAttributes, HyperInterface, NSObject, HSAction, HSActionSynchronousAttribute, HSAttribute, HSActionEventsAttribute, HSActionLocalizedNameAttribute, HSApplicationToQuitAttribute>
{
    NSString *_applicationToQuit;
}
- (BOOL)isValid;
- (void)setApplicationToQuit:(id)aQuit;
- (id)applicationToQuit;
- (void)startInContext:(id)aContext;
- (id)keysForExtraStoringWithCodingContext:(id)aContext;
- (void)dealloc;
@end

