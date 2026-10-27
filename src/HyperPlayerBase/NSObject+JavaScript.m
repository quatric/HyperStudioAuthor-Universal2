#import "NSObject+JavaScript.h"
@implementation NSObject (JavaScript)
- (BOOL)hyperSupportsScripting
{
    return [self respondsToSelector:@selector(invokeUndefinedMethodFromWebScript:withArguments:)];
}
// Script method "name" calls -nameFromScript: with the arguments array.
- (id)invokeUndefinedMethodFromWebScript:(id)aScript withArguments:(id)aArguments
{
    SEL selector = [self selectorForJavaScriptMethod:aScript];
    if (selector == NULL)
        return nil;
    return [self performSelector:selector withObject:aArguments];
}
- (id)hasMethodFromScript:(id)aScript
{
    BOOL hasMethod = NO;
    if ([aScript count] != 0 && [[aScript objectAtIndex:0] isKindOfClass:[NSString class]])
        hasMethod = [self selectorForJavaScriptMethod:[aScript objectAtIndex:0]] != NULL;
    return [NSNumber numberWithBool:hasMethod];
}
- (id)toStringFromScript:(id)aScript
{
    return [self description];
}
- (SEL)selectorForJavaScriptMethod:(id)aMethod
{
    SEL selector = NSSelectorFromString([aMethod stringByAppendingString:@"FromScript:"]);
    if (selector != NULL && ![self respondsToSelector:selector])
        selector = NULL;
    return selector;
}
@end
