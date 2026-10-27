#import "HyperPlayerBasePrefix.h"


@interface NSException (EXOSStatusError)
+ (void)extraRaiseError:(NSInteger)aError name:(id)aName format:(id)aFormat arguments:(va_list)aArguments;
+ (void)extraRaiseError:(NSInteger)aError name:(id)aName format:(id)aFormat, ...;
- (NSInteger)extraStatusError;
@end

