#import "HSScriptTestTracker.h"

static HSScriptTestTracker *HSScriptTestTrackerDefault = nil;

@implementation HSScriptTestTracker
+ (id)defaultTestTracker
{
    if (!HSScriptTestTrackerDefault)
        HSScriptTestTrackerDefault = [HSScriptTestTracker new];
    return HSScriptTestTrackerDefault;
}
// Script calls "name(args)" map to -nameFromScript:.
- (id)invokeUndefinedMethodFromWebScript:(id)aScript withArguments:(id)aArguments
{
    SEL selector = NSSelectorFromString([aScript stringByAppendingString:@"FromScript:"]);
    if (![self respondsToSelector:selector])
        return nil;
    return [self performSelector:selector withObject:aArguments];
}
- (id)onExceptionFromScript:(id)aScript
{
    if ([aScript count])
        [self setExceptionInfo:[aScript objectAtIndex:0]];
    return nil;
}
- (id)onAssertionFailureFromScript:(id)aScript
{
    NSUInteger count = [aScript count];
    [self setAssertionInfo:nil];
    if (count)
        [self setAssertionInfo:[aScript objectAtIndex:0]];
    return nil;
}
- (id)allowAlertsFromScript:(id)aScript
{
    return [NSNumber numberWithBool:[self allowAlerts]];
}
- (void)setAllowAlerts:(BOOL)aAlerts
{
    _allowAlerts = aAlerts;
}
- (BOOL)allowAlerts
{
    return _allowAlerts;
}
// Line numbers are relative to the context line.
- (void)setExceptionInfo:(id)aInfo
{
    _failed = aInfo != nil;
    [_failedCondition release];
    _failedCondition = nil;
    [_failureDescription release];
    _failureDescription = nil;
    _failureLine = 0;
    if (aInfo) {
        _failureDescription = [[aInfo valueForKey:@"message"] retain];
        id line = [aInfo valueForKey:@"line"];
        if ([line respondsToSelector:@selector(unsignedIntValue)])
            _failureLine = [line unsignedIntValue] + _contextLine;
    }
}
- (void)setAssertionInfo:(id)aInfo
{
    _failed = aInfo != nil;
    [_failedCondition release];
    _failedCondition = nil;
    [_failureDescription release];
    _failureDescription = nil;
    _failureLine = 0;
    if (aInfo) {
        _failedCondition = [[aInfo valueForKey:@"conditionStr"] retain];
        _failureDescription = [[aInfo valueForKey:@"description"] retain];
        id line = [aInfo valueForKey:@"line"];
        if ([line respondsToSelector:@selector(unsignedIntValue)])
            _failureLine = [line unsignedIntValue] + _contextLine;
    }
}
- (NSUInteger)failureLine
{
    return _failureLine;
}
- (id)assertionString
{
    NSBundle *bundle = [NSBundle mainBundle];
    if (!_failureDescription)
        return [NSString stringWithFormat:[bundle localizedStringForKey:@"Assertion failed for condition \"%@\"." value:@"" table:nil], _failedCondition, nil];
    if (!_failedCondition)
        return [NSString stringWithFormat:[bundle localizedStringForKey:@"Script failed. %@" value:@"" table:nil], _failureDescription, nil];
    return [NSString stringWithFormat:[bundle localizedStringForKey:@"Assertion failed for condition \"%@\". %@" value:@"" table:nil], _failedCondition, _failureDescription];
}
- (BOOL)success
{
    return !_failed;
}
- (void)reset
{
    _failed = NO;
    [self setAssertionInfo:nil];
}
- (id)trackableScriptForScript:(id)aScript
{
    return aScript;
}
// The original leaked the previous path.
- (void)setContextWithScriptFilePath:(id)aPath andLine:(NSUInteger)aLine
{
    NSString *path = [aPath copy];
    [_contextScriptFilePath release];
    _contextScriptFilePath = path;
    _contextLine = (unsigned int)aLine;
}
- (NSUInteger)contextLine
{
    return _contextLine;
}
- (id)contextScriptFilePath
{
    return _contextScriptFilePath;
}
- (void)setContextWithScriptFilePath:(id)aPath
{
    [self setContextWithScriptFilePath:aPath andLine:0];
}
- (void)dealloc
{
    _contextLine = 0;
    [_contextScriptFilePath release];
    [_failedCondition release];
    [_failureDescription release];
    [super dealloc];
}
- (id)init
{
    self = [super init];
    if (self) {
        _allowAlerts = YES;
        _failed = NO;
        [self reset];
    }
    return self;
}
@end
