#import "HSInteractiveYouTubeObject.h"
// Interactive item showing a YouTube object's web view over the card. The
// object's renderer is detached while it is active; an overlay view tells
// the rendering view when the web view redraws. Mouse events go to the
// web page's document view.

@implementation HSInteractiveYouTubeObject

- (void)overlayViewDidDraw:(id)aDraw
{
    [[[[self activeParentCanvasLayer] context] renderingView] interactiveSubviewDidUpdate];
}

- (id)youTubeInteractiveAttribute
{
    return [[self hyperObject] queryHyperInterface:@protocol(HSYouTubeInteractiveAttribute)];
}

- (void)trackMouseWithMouseUpEvent:(id)aEvent inInteractiveContext:(id)aContext
{
    id view = [self view];
    if (view)
        [[[[view mainFrame] frameView] documentView] performSelector:@selector(mouseUp:) withObject:aEvent afterDelay:0.01];
}

- (BOOL)wantsToTrackMouseWithMouseUpEvent:(id)aEvent inInteractiveContext:(id)aContext
{
    return [self isActive];
}

- (void)trackMouseWithMouseDownEvent:(id)aEvent inInteractiveContext:(id)aContext
{
    if (![self isActive] || [self isHandlingMouseEvent])
        return;
    id view = [self view];
    if (view) {
        [self setHandlingMouseEvent:YES];
        [[[[view mainFrame] frameView] documentView] performSelector:@selector(mouseDown:) withObject:aEvent afterDelay:0];
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

// The web view belongs to the YouTube attribute and stays where it is.
- (void)removeViewFromSuperview
{
}

- (void)deactivate
{
    [[self view] setFrame:_originalViewFrame];
    [_overlayView setDrawingDelegate:nil];
    [_overlayView removeFromSuperviewWithoutNeedingDisplay];
    [[[[self activeParentCanvasLayer] context] renderingView] stopRenderInteractiveSubview];
    [super deactivate];
    [self invalidateView];
    [[self youTubeInteractiveAttribute] reattachRenderer];
}

- (void)activateInCanvasLayer:(id)aLayer
{
    id renderingView = [[aLayer context] renderingView];
    [renderingView beginRenderInteractiveSubview];
    [[self youTubeInteractiveAttribute] detachRenderer];
    [super activateInCanvasLayer:aLayer];
    [_overlayView setDrawingDelegate:self];
    [renderingView addSubview:_overlayView];
}

- (void)invalidateView
{
    [super invalidateView];
    [_overlayView release];
    _overlayView = nil;
}

- (void)setupViewFrameInCanvasLayer:(id)aLayer
{
    id renderingView = [[[self activeParentCanvasLayer] context] renderingView];
    id geometry = [[self hyperObject] queryHyperInterface:@protocol(HSGeometryAttributes)];
    if (geometry) {
        NSRect frame = [renderingView viewBoundingRectForUserRect:[geometry frameBoundingRect]];
        [[self view] setFrame:frame];
        [_overlayView setFrame:frame];
    }
}

- (void)setupView:(id)aView
{
    _originalViewFrame = [[self view] frame];
}

- (id)createView
{
    _overlayView = [[HSOverlayView alloc] initWithFrame:NSZeroRect];
    return [[[self youTubeInteractiveAttribute] youTubeInteractiveView] retain];
}

- (BOOL)objectCanBeActivated
{
    return [[self youTubeInteractiveAttribute] youTubeInteractiveView] != nil;
}

- (void)dealloc
{
    [_overlayView release];
    [super dealloc];
}

@end
