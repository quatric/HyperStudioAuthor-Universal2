#import "HyperPlayerBasePrefix.h"


@interface HSJavaScriptBridge : NSObject
{
    id _javaScriptObject;
    id _delegate;
    NSString *_mainHTMLPath;
}
+ (id)allocWithZone:(NSZone *)aZone;
+ (BOOL)_isJaguar;
- (void)setMainHTMLPath:(id)aPath;
- (id)mainHTMLPath;
- (void)setDelegate:(id)aDelegate;
- (id)delegate;
- (void)setJavaScriptObject:(id)aObject;
- (id)javaScriptObject;
- (void)dealloc;
- (id)init;
@end

