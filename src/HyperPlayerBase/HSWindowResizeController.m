#import "HSWindowResizeController.h"
// Animates a window to a new frame. The controllers of windows being resized
// are kept in a map table by window (which keeps them alive while animating);
// a new resize stops the window's current one.
@implementation HSWindowResizeController
static NSMapTable *sResizingControllers;
+ (id)resizeControllerForWindow:(id)aWindow
{
    return [[[self alloc] initWithWindow:aWindow] autorelease];
}
- (void)animationDidEnd:(id)aEnd
{
    [self removeSelfFromMapTable];
}
- (void)animationDidStop:(id)aStop
{
    [self removeSelfFromMapTable];
}
// Only when the window's entry is this controller (the original removes the
// window's entry whoever it belongs to).
- (void)removeSelfFromMapTable
{
    if (sResizingControllers == nil || NSMapGet(sResizingControllers, _window) != self)
        return;
    NSMapRemove(sResizingControllers, _window);
    if (NSCountMapTable(sResizingControllers) == 0) {
        NSFreeMapTable(sResizingControllers);
        sResizingControllers = nil;
    }
}
- (void)invalidateTimer
{
    [_resizeTimer invalidate];
    [_resizeTimer release];
    _resizeTimer = nil;
}
// The step of the original's resizing before Tiger (timer-driven, without
// NSViewAnimation); never scheduled now.
- (void)resizeWithTimer:(id)aTimer
{
}
// The original inserts this controller with an extra retain (the map retains
// its values too: a leak), and keeps the stopped controller's entry when there
// was one; the entry is replaced here. Pre-Tiger timer resizing dropped.
- (void)resizeToFrame:(NSRect)aFrame
{
    if (sResizingControllers == nil)
        sResizingControllers = NSCreateMapTableWithZone(NSNonOwnedPointerMapKeyCallBacks, NSObjectMapValueCallBacks, 0, [self zone]);
    HSWindowResizeController *current = [[(id)NSMapGet(sResizingControllers, _window) retain] autorelease];
    if (current != nil)
        [current stopResize:self];
    if (sResizingControllers == nil)
        sResizingControllers = NSCreateMapTableWithZone(NSNonOwnedPointerMapKeyCallBacks, NSObjectMapValueCallBacks, 0, [self zone]);
    NSMapInsert(sResizingControllers, _window, self);
    NSDictionary *animation = [NSDictionary dictionaryWithObjectsAndKeys:[NSValue valueWithRect:aFrame], NSViewAnimationEndFrameKey,
                                                                         [NSValue valueWithRect:[_window frame]], NSViewAnimationStartFrameKey,
                                                                         _window, NSViewAnimationTargetKey, nil];
    _animation = [[NSViewAnimation alloc] initWithViewAnimations:[NSArray arrayWithObject:animation]];
    [_animation setDuration:[_window animationResizeTime:aFrame]];
    [_animation setDelegate:self];
    [_animation startAnimation];
}
- (void)stopResize:(id)aResize
{
    if ([_animation isAnimating])
        [_animation stopAnimation];
    [_animation setDelegate:nil];
    [_animation release];
    _animation = nil;
}
- (void)setWindow:(id)aWindow
{
    if (_window != aWindow) {
        [_window release];
        _window = [aWindow retain];
    }
}
- (void)dealloc
{
    [_window release];
    [_animation setDelegate:nil];
    [_animation release];
    [super dealloc];
}
- (id)initWithWindow:(id)aWindow
{
    self = [super init];
    if (self != nil)
        [self setWindow:aWindow];
    return self;
}
@end
