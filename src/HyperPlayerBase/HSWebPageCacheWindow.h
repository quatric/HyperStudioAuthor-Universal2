#import "HyperPlayerBasePrefix.h"


@interface HSWebPageCacheWindow : NSWindow
{
}
+ (id)webPageCacheWindowWithContentRect:(NSRect)aRect;
- (void)orderFrontRegardless;
- (void)orderWindow:(NSInteger)aWindow relativeTo:(NSInteger)aTo;
- (void)orderFront:(id)aFront;
- (void)makeKeyAndOrderFront:(id)aFront;
- (BOOL)canBecomeMainWindow;
- (BOOL)canBecomeKeyWindow;
- (id)initWebPageCacheWindowWithContentRect:(NSRect)aRect;
@end

