#import "HyperPlayerBasePrefix.h"
#import "HSJavaScriptBridge.h"


@interface HSJavaScriptBridgeTiger : HSJavaScriptBridge
{
}
- (void)dealloc;
- (id)init;
- (void)setValue:(id)aValue forKey:(id)aKey;
- (id)evaluateWebScript:(id)aScript;
- (void)webViewProgressFinishedNotification:(id)aNotification;
- (void)load;
@end

