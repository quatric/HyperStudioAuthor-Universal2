#import "NSException+EXOSStatusError.h"
@implementation NSException (EXOSStatusError)
+ (void)extraRaiseError:(NSInteger)aError name:(id)aName format:(id)aFormat arguments:(va_list)aArguments
{
    // the original passed the va_list on as a single variadic argument
    // (formatting garbage); the arguments are used here
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithLong:aError]
                                                         forKey:@"_EXExceptionStatusErrorKey"];
    NSString *reason = [[[NSString allocWithZone:[aFormat zone]] initWithFormat:aFormat arguments:aArguments] autorelease];
    [[self exceptionWithName:aName reason:reason userInfo:userInfo] raise];
}
+ (void)extraRaiseError:(NSInteger)aError name:(id)aName format:(id)aFormat, ...
{
    va_list arguments;
    va_start(arguments, aFormat);
    [self extraRaiseError:aError name:aName format:aFormat arguments:arguments];
    va_end(arguments);
}
- (NSInteger)extraStatusError
{
    return [[[self userInfo] objectForKey:@"_EXExceptionStatusErrorKey"] longValue];
}
@end
