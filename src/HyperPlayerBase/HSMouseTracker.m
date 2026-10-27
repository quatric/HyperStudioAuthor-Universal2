#import "HSMouseTracker.h"
// Base of the canvas mouse trackers: tracking-loop events become
// mouse…:inView: calls (with the view's content changes accumulated), and
// down / drag are split into pre-, main and post-processing steps for
// subclasses.
@implementation HSMouseTracker
- (void)handleFlagsChanged:(id)aChanged inTrackingLoop:(id)aLoop
{
    id view = [aLoop view];
    [view beginContentChangeAccumulation];
    [self flagsChanged:aChanged inView:view];
    [view endContentChangeAccumulation];
}
- (void)handleMouseUp:(id)aUp inTrackingLoop:(id)aLoop
{
    id view = [aLoop view];
    [view beginContentChangeAccumulation];
    [self mouseUp:aUp inView:view];
    [view endContentChangeAccumulation];
}
- (void)handleMouseDragged:(id)aDragged inTrackingLoop:(id)aLoop
{
    id view = [aLoop view];
    [view beginContentChangeAccumulation];
    [self mouseDragged:aDragged inView:view];
    [view endContentChangeAccumulation];
}
- (void)handleMouseDown:(id)aDown inTrackingLoop:(id)aLoop
{
    id view = [aLoop view];
    [view beginContentChangeAccumulation];
    [self mouseDown:aDown inView:view];
    [view endContentChangeAccumulation];
}
- (void)flagsChanged:(id)aChanged inView:(id)aView
{
}
- (void)mouseUp:(id)aUp inView:(id)aView
{
}
- (void)postprocessMouseDragged:(id)aDragged inView:(id)aView
{
}
- (void)processMouseDragged:(id)aDragged inView:(id)aView
{
}
- (void)preprocessMouseDragged:(id)aDragged inView:(id)aView
{
}
- (void)mouseDragged:(id)aDragged inView:(id)aView
{
    [self preprocessMouseDragged:aDragged inView:aView];
    [self processMouseDragged:aDragged inView:aView];
    [self postprocessMouseDragged:aDragged inView:aView];
}
- (void)postprocessMouseDown:(id)aDown inView:(id)aView
{
}
- (void)processMouseDown:(id)aDown inView:(id)aView
{
}
- (void)preprocessMouseDown:(id)aDown inView:(id)aView
{
}
- (void)mouseDown:(id)aDown inView:(id)aView
{
    [self preprocessMouseDown:aDown inView:aView];
    [self processMouseDown:aDown inView:aView];
    [self postprocessMouseDown:aDown inView:aView];
}
- (void)setLayoutGuidingContext:(id)aContext
{
    if (_layoutGuidingContext == aContext)
        return;
    [_layoutGuidingContext release];
    _layoutGuidingContext = [aContext retain];
}
- (id)layoutGuidingContext
{
    return _layoutGuidingContext;
}
- (void)dealloc
{
    [_layoutGuidingContext release];
    [super dealloc];
}
@end
