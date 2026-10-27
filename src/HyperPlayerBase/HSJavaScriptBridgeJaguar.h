#import "HyperPlayerBasePrefix.h"
#import "HSJavaScriptBridge.h"


@interface HSJavaScriptBridgeJaguar : HSJavaScriptBridge
{
}
+ (id)SMKWebCoreFramework;
- (void)dealloc;
- (id)init;
- (void)setValue:(id)aValue forKey:(id)aKey;
- (id)evaluateWebScript:(id)aScript;
- (void)load;
- (id)_libraryScript;
@end

