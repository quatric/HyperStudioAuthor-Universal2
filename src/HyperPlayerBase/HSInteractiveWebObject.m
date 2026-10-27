#import "HSInteractiveWebObject.h"
// A web object while active: its web view (ejected from the web element and
// given back when invalidated) lives in the rendering view under an overlay
// view, and mouse events go to the page's document view.
@implementation HSInteractiveWebObject
- (void)overlayViewDidDraw:(id)aDraw
{
    [[[[self activeParentCanvasLayer] context] renderingView] interactiveSubviewDidUpdate];
}
// Delivered a moment later (0.01 s) so the page sees the mouse down first.
- (void)trackMouseWithMouseUpEvent:(id)aEvent inInteractiveContext:(id)aContext
{
    [[[[(WebView *)[self view] mainFrame] frameView] documentView] performSelector:@selector(mouseUp:)
                                                                       withObject:aEvent
                                                                       afterDelay:0.01];
}
- (BOOL)wantsToTrackMouseWithMouseUpEvent:(id)aEvent inInteractiveContext:(id)aContext
{
    return [self isActive];
}
- (void)trackMouseWithMouseDownEvent:(id)aEvent inInteractiveContext:(id)aContext
{
    if (![self isActive] || [self isHandlingMouseEvent])
        return;
    WebView *view = [self view];
    if (view != nil) {
        [self setHandlingMouseEvent:YES];
        [[[[view mainFrame] frameView] documentView] performSelector:@selector(mouseDown:)
                                                          withObject:aEvent
                                                          afterDelay:0];
        [self setHandlingMouseEvent:NO];
    }
    [[self activeItemContext] sendClickActionsForItemIfNeeded:self];
}
- (BOOL)wantsToTrackMouseWithMouseDownEvent:(id)aEvent inInteractiveContext:(id)aContext
{
    return YES;
}
- (BOOL)wantsToPassThroughMouseDownEvent:(id)aEvent inInteractiveContext:(id)aContext
{
    return NO;
}
- (void)deactivate
{
    [_overlayView setDrawingDelegate:nil];
    [_overlayView removeFromSuperviewWithoutNeedingDisplay];
    [_overlayView release];
    _overlayView = nil;
    [[[[self activeParentCanvasLayer] context] renderingView] stopRenderInteractiveSubview];
    [super deactivate];
    [self invalidateView];
}
- (void)activateInCanvasLayer:(id)aLayer
{
    id renderingView = [[aLayer context] renderingView];
    [renderingView beginRenderInteractiveSubview];
    [super activateInCanvasLayer:aLayer];
    _overlayView = [[HSOverlayView alloc] initWithFrame:NSZeroRect];
    if (_overlayView != nil) {
        [_overlayView setDrawingDelegate:self];
        [renderingView addSubview:_overlayView];
    }
}
- (void)setupViewFrameInCanvasLayer:(id)aLayer
{
    id renderingView = [[[self activeParentCanvasLayer] context] renderingView];
    id geometry = [[self hyperObject] queryHyperInterface:@protocol(HSGeometryAttributes)];
    if (geometry == nil)
        return;
    NSRect frame = [renderingView viewBoundingRectForUserRect:[geometry frameBoundingRect]];
    [(NSView *)[self view] setFrame:frame];
    [_overlayView setFrame:frame];
}
- (void)invalidateView
{
    [_webElementAttributes reclaimWebView];
    [super invalidateView];
    [_webElementAttributes release];
    _webElementAttributes = nil;
}
// Returns the web view retained.
- (id)createView
{
    _webElementAttributes = [[[self hyperObject] queryHyperInterface:@protocol(HSWebElementAttributes)] retain];
    return [[_webElementAttributes ejectWebView] retain];
}
- (BOOL)objectCanBeActivated
{
    return YES;
}
- (void)dealloc
{
    [_overlayView release];
    [_webElementAttributes release];
    [super dealloc];
}
@end
