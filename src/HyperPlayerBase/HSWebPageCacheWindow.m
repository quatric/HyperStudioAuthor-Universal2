#import "HSWebPageCacheWindow.h"
// An offscreen borderless window for caching web pages: it never comes
// forward.
@implementation HSWebPageCacheWindow
+ (id)webPageCacheWindowWithContentRect:(NSRect)aRect
{
    return [[[self alloc] initWebPageCacheWindowWithContentRect:aRect] autorelease];
}
- (void)orderFrontRegardless
{
}
- (void)orderWindow:(NSInteger)aWindow relativeTo:(NSInteger)aTo
{
    if (aWindow < 1)
        [super orderWindow:aWindow relativeTo:aTo];
}
- (void)orderFront:(id)aFront
{
}
- (void)makeKeyAndOrderFront:(id)aFront
{
}
- (BOOL)canBecomeMainWindow
{
    return NO;
}
- (BOOL)canBecomeKeyWindow
{
    return NO;
}
- (id)initWebPageCacheWindowWithContentRect:(NSRect)aRect
{
    self = [self initWithContentRect:aRect styleMask:NSWindowStyleMaskBorderless backing:NSBackingStoreBuffered defer:NO];
    if (self != nil) {
        [self setReleasedWhenClosed:NO];
        [self setOpaque:NO];
        [self setBackgroundColor:[NSColor clearColor]];
    }
    return self;
}
@end
