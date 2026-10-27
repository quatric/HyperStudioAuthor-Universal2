#import "HyperPlayerBasePrefix.h"


@interface NSWindow (HSExtensions)
+ (id)hyperCacheWindowWithContentRect:(NSRect)aRect;
+ (void)hyperUnlockSharedCacheWindow:(id)aWindow;
+ (id)hyperLockedSharedChacheWindowWithContentSize:(NSSize)aSize;
- (NSRect)hyperTitleRect;
- (void)hyperOrderFrontRespectingLastVisibilityState:(id)aState;
- (void)hyperOrderOutWithSavingVisibilityState:(id)aState;
- (id)isHyperWindowHitByCurrentMouseLocation;
- (id)initHyperCacheWithContentRect:(NSRect)aRect;
@end

