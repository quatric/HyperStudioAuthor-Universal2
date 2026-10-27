#import "HSEnvironmentJSObject.h"
// The "Environment" object scripts see: the stack's document and the test
// tracker. A method the script calls that isn't defined goes to the
// "<name>FromScript:" method, with the arguments.
@implementation HSEnvironmentJSObject
+ (id)webScriptNameForSelector:(SEL)aSelector
{
    return nil;
}
+ (BOOL)isSelectorExcludedFromWebScript:(SEL)aScript
{
    return NO;
}
// Keeps the document's stack.
- (void)setDocument:(id)aDocument
{
    if (_stack != [aDocument stack]) {
        [_stack release];
        _stack = [[aDocument stack] retain];
    }
}
- (id)document
{
    return [_stack document];
}
- (id)testTracker
{
    return [HSScriptTestTracker defaultTestTracker];
}
- (id)invokeUndefinedMethodFromWebScript:(id)aScript withArguments:(id)aArguments
{
    SEL selector = NSSelectorFromString([aScript stringByAppendingString:@"FromScript:"]);
    if (![self respondsToSelector:selector])
        return nil;
    return [self performSelector:selector withObject:aArguments];
}
- (void)setScriptFilePath:(id)aPath
{
    [[self testTracker] setContextWithScriptFilePath:aPath];
}
- (id)scriptFilePath
{
    return [[self testTracker] contextScriptFilePath];
}
- (id)hyperScriptKind
{
    return @"Environment";
}
- (id)hyperScriptName
{
    return [NSString stringWithFormat:@"$$__%@", @"Environment"];
}
- (id)hyperScriptDisplayName
{
    return @"Environment";
}
- (void)dealloc
{
    [_stack release];
    [super dealloc];
}
@end
