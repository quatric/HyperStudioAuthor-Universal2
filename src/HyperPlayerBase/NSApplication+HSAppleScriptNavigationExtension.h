#import "HyperPlayerBasePrefix.h"


@interface NSApplication (HSAppleScriptNavigationExtension)
- (void)handleHyperGoToSpecificCardScriptCommand:(id)aCommand;
- (void)handleHyperGoToPreviousCardScriptCommand:(id)aCommand;
- (void)handleHyperGoToNextCardScriptCommand:(id)aCommand;
- (void)handleHyperGoToLastCardScriptCommand:(id)aCommand;
- (void)handleHyperGoToFirstCardScriptCommand:(id)aCommand;
- (void)handleHyperGoForwardScriptCommand:(id)aCommand;
- (void)handleHyperGoBackScriptCommand:(id)aCommand;
@end

