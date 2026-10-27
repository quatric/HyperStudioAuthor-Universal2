#import "HyperPlayerBasePrefix.h"


@interface HSYouTubeCacheWindow : NSWindow
{
}
+ (id)youTubeCacheWindowWithContentRect:(NSRect)aRect;
- (void)orderFrontRegardless;
- (void)orderWindow:(NSInteger)aWindow relativeTo:(NSInteger)aTo;
- (void)orderFront:(id)aFront;
- (void)makeKeyAndOrderFront:(id)aFront;
- (BOOL)canBecomeMainWindow;
- (BOOL)canBecomeKeyWindow;
- (id)initYouTubeCacheWindowWithContentRect:(NSRect)aRect;
@end

