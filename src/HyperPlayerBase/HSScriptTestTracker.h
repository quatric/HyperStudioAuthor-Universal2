#import "HyperPlayerBasePrefix.h"


@interface HSScriptTestTracker : NSObject
{
    NSString *_contextScriptFilePath;
    unsigned int _contextLine;
    BOOL _failed;
    NSString *_failedCondition;
    NSString *_failureDescription;
    unsigned int _failureLine;
    BOOL _allowAlerts;
}
+ (id)defaultTestTracker;
- (id)invokeUndefinedMethodFromWebScript:(id)aScript withArguments:(id)aArguments;
- (id)onExceptionFromScript:(id)aScript;
- (id)onAssertionFailureFromScript:(id)aScript;
- (id)allowAlertsFromScript:(id)aScript;
- (void)setAllowAlerts:(BOOL)aAlerts;
- (BOOL)allowAlerts;
- (void)setExceptionInfo:(id)aInfo;
- (void)setAssertionInfo:(id)aInfo;
- (NSUInteger)failureLine;
- (id)assertionString;
- (BOOL)success;
- (void)reset;
- (id)trackableScriptForScript:(id)aScript;
- (void)setContextWithScriptFilePath:(id)aPath andLine:(NSUInteger)aLine;
- (NSUInteger)contextLine;
- (id)contextScriptFilePath;
- (void)setContextWithScriptFilePath:(id)aPath;
- (void)dealloc;
- (id)init;
@end

