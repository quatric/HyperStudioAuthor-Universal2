#import "NSWindow+HSExtensions.h"
@implementation NSWindow (HSExtensions)
+ (id)hyperCacheWindowWithContentRect:(NSRect)aRect
{
    return [[[self alloc] initHyperCacheWithContentRect:aRect] autorelease];
}
+ (void)hyperUnlockSharedCacheWindow:(id)aWindow
{
}
// One shared offscreen window, grown as needed, for drawing visualizations
// (never shown, at the main screen's origin).
+ (id)hyperLockedSharedChacheWindowWithContentSize:(NSSize)aSize
{
    static NSWindow *window = nil;
    if (window == nil) {
        window = [[NSWindow alloc] initHyperCacheWithContentRect:NSMakeRect(0, 0, aSize.width, aSize.height)];
        [window setContentView:[[[HSVisualizationAuxiliaryView alloc] init] autorelease]];
    } else {
        NSRect frame = [window frame];
        if (aSize.width > frame.size.width || aSize.height > frame.size.height)
            [window setContentSize:NSMakeSize(MAX(aSize.width, frame.size.width), MAX(aSize.height, frame.size.height))];
    }
    [window setFrameOrigin:[[NSScreen mainScreen] frame].origin];
    return window;
}
// Above the content view (window coordinates).
- (NSRect)hyperTitleRect
{
    NSRect content = [[self contentView] frame];
    NSRect frame = [self frame];
    return NSMakeRect(0, content.size.height, content.size.width, frame.size.height - content.size.height);
}
// The delegate may veto, and hears before and after it's shown.
- (void)hyperOrderFrontRespectingLastVisibilityState:(id)aState
{
    id delegate = [self delegate];
    if ([delegate respondsToSelector:@selector(windowShouldOrderFrontRespectingLastVisibilityState:)]
        && ![delegate windowShouldOrderFrontRespectingLastVisibilityState:self])
        return;
    if ([self isVisible])
        return;
    if ([[self delegate] respondsToSelector:@selector(windowWillShowRespectingLastVisibilityState:)])
        [[self delegate] windowWillShowRespectingLastVisibilityState:self];
    [self orderFront:aState];
    if ([[self delegate] respondsToSelector:@selector(windowDidShowRespectingLastVisibilityState:)])
        [[self delegate] windowDidShowRespectingLastVisibilityState:self];
}
- (void)hyperOrderOutWithSavingVisibilityState:(id)aState
{
    if ([[self delegate] respondsToSelector:@selector(windowWillHideWithSavingVisibilityState:)])
        [[self delegate] windowWillHideWithSavingVisibilityState:self];
    [self orderOut:aState];
}
// @YES when the mouse is over the window (and it takes mouse events), nil
// otherwise.
- (id)isHyperWindowHitByCurrentMouseLocation
{
    if ([self ignoresMouseEvents])
        return nil;
    NSPoint point = [self convertPointToScreen:[self BT_effectiveMouseLocation]];
    if (NSPointInRect(point, [self frame]))
        return [NSNumber numberWithBool:YES];
    return nil;
}
- (id)initHyperCacheWithContentRect:(NSRect)aRect
{
    self = [self initWithContentRect:aRect styleMask:NSWindowStyleMaskBorderless backing:NSBackingStoreBuffered defer:NO];
    if (self != nil) {
        [self setReleasedWhenClosed:NO];
        [self setOpaque:NO];
        [self setBackgroundColor:[NSColor clearColor]];
        [self disableCursorRects];
    }
    return self;
}
@end
