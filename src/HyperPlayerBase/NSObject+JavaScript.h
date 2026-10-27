#import "HyperPlayerBasePrefix.h"


@interface NSObject (JavaScript)
- (BOOL)hyperSupportsScripting;
- (id)invokeUndefinedMethodFromWebScript:(id)aScript withArguments:(id)aArguments;
- (id)hasMethodFromScript:(id)aScript;
- (id)toStringFromScript:(id)aScript;
- (SEL)selectorForJavaScriptMethod:(id)aMethod;
@end

