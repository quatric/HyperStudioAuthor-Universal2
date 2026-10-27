#import "HSQuartzOpenGLView.h"

// An NSEView whose extra drawing layers are borderless transparent child windows kept over the view
// (each holding one drawing view), so OpenGL surfaces can be layered above the view's own surface.
// The child windows follow the view's geometry through frame/bounds and window move notifications,
// observed through a weak proxy.
@implementation HSQuartzOpenGLView
+ (id)createDefaultOpenGLContext
{
    NSOpenGLContext *context = [super createDefaultOpenGLContext];
    if (context) {
        GLint order = -1;
        [context setValues:&order forParameter:NSOpenGLCPSurfaceOrder];
        GLint swapInterval = 1;
        [context setValues:&swapInterval forParameter:NSOpenGLCPSwapInterval];
    }
    return context;
}
- (NSRect)rectBeingDrawn
{
    return _rectBeingDrawn;
}
- (void)drawRect:(NSRect)aRect
{
    if (!NSIsEmptyRect(aRect)) {
        _rectBeingDrawn = aRect;
        [super drawRect:aRect];
        _rectBeingDrawn = NSZeroRect;
    }
    [self HSQuartzOpenGLView_displayWindowLayers];
}
- (void)drawQuartzRect:(NSRect)aRect
{
}
- (void)drawQuartzSurfaceRect:(NSRect)aRect
{
    if (![self isOpenGLSurfaceDisplayed])
        [self drawQuartzRect:aRect];
}
- (BOOL)drawOpenGLSurfaceQuartzTextureRect:(NSRect)aRect
{
    [self drawQuartzRect:aRect];
    return YES;
}
// The window layers redraw the rects being drawn in the view.
- (void)HSQuartzOpenGLView_displayWindowLayers
{
    NSWindow *window = [self window];
    if (!window)
        return;
    NSUInteger count = [_windowLayers count];
    if (!count)
        return;
    [window disableScreenUpdatesUntilFlush];
    if (!_isWindowLayersGeometryValid)
        [self HSQuartzOpenGLView_synchronizeWindowLayersGeometry];
    const NSRect *rects = NULL;
    NSInteger rectCount = 0;
    [self getRectsBeingDrawn:&rects count:&rectCount];
    for (NSUInteger i = 0; i < count; i++) {
        NSWindow *layer = [_windowLayers objectAtIndex:i];
        NSView *view = [[[layer contentView] subviews] objectAtIndex:0];
        for (NSInteger j = 0; j < rectCount; j++)
            [view setNeedsDisplayInRect:rects[j]];
        [layer displayIfNeeded];
    }
}
- (void)setNeedsDisplayInRect:(NSRect)aRect inWindowLayer:(id)aLayer
{
    if (![self window])
        return;
    if (!_isWindowLayersGeometryValid && [_windowLayers count])
        [self HSQuartzOpenGLView_synchronizeWindowLayersGeometry];
    [[[[aLayer contentView] subviews] objectAtIndex:0] setNeedsDisplayOpenGLSurfaceInRect:aRect];
}
- (void)setNeedsDisplayInViewLayerRect:(NSRect)aRect
{
    [self setNeedsDisplayOpenGLSurfaceInRect:aRect];
}
- (void)setNeedsHyperDisplayInRegion:(id)aRegion
{
    NSData *rects = [aRegion rectApproximation];
    const CGRect *rect = [rects bytes];
    const CGRect *end = (const CGRect *)((const char *)rect + [rects length]);
    for (; rect < end; rect++)
        [self setNeedsDisplayOpenGLSurfaceInRect:NSRectFromCGRect(*rect)];
}
- (id)viewForWindowLayer:(id)aLayer
{
    return [[[aLayer contentView] subviews] objectAtIndex:0];
}
- (id)windowLayers
{
    if (!_windowLayers)
        return [NSArray array];
    return [[_windowLayers copy] autorelease];
}
- (void)removeWindowLayer:(id)aLayer
{
    if (!_windowLayers)
        return;
    NSUInteger index = [_windowLayers indexOfObjectIdenticalTo:aLayer];
    if (index == NSNotFound)
        return;
    NSWindow *window = [self window];
    if (window) {
        [window removeChildWindow:aLayer];
        // The last layer stops the geometry tracking.
        if (_isRegisteredForViewGeometryChangeNotifications && [_windowLayers count] == 1) {
            [self HSQuartzOpenGLView_removeViewGeometryObservers];
            _isRegisteredForViewGeometryChangeNotifications = 0;
            if (_isRegisteredForWindowDidMoveNotification) {
                [[NSNotificationCenter defaultCenter] removeObserver:_quartzOpenGLViewProxy name:NSWindowDidMoveNotification object:[self window]];
                _isRegisteredForWindowDidMoveNotification = 0;
            }
            [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(HSQuartzOpenGLView_synchronizeWindowLayersGeometry) object:nil];
        }
    }
    [aLayer orderOut:self];
    [_windowLayers removeObjectAtIndex:index];
}
// The selector is sent to the receiver to draw the layer (with the rect as argument).
- (id)addWindowLayerWithDrawingSelector:(SEL)aSelector
{
    HSQuartzOpenGLView_HSWindowLayerDrawingView *view = [[HSQuartzOpenGLView_HSWindowLayerDrawingView alloc] initWithFrame:[self frame] parentView:self drawingSelector:aSelector];
    if (!view)
        return nil;
    id layer = [self addWindowLayerWithView:view];
    [view release];
    return layer;
}
- (id)addWindowLayerWithView:(id)aView
{
    if (![self HSQuartzOpenGLView_proxy])
        return nil;
    if (!_windowLayers) {
        _windowLayers = [[NSMutableArray alloc] init];
        if (!_windowLayers)
            return nil;
    }
    NSWindow *window = [self window];
    NSWindow *layer = [[[NSWindow alloc] initWithContentRect:NSMakeRect(0, 0, 1, 1) styleMask:NSWindowStyleMaskBorderless backing:NSBackingStoreBuffered defer:NO] autorelease];
    if (!layer)
        return nil;
    [layer setReleasedWhenClosed:NO];
    [layer setOpaque:NO];
    [layer setBackgroundColor:[NSColor clearColor]];
    [layer useOptimizedDrawing:YES];
    [layer disableCursorRects];
    [layer setIgnoresMouseEvents:YES];
    HSQuartzOpenGLView_HSFlippingView *contentView = [[HSQuartzOpenGLView_HSFlippingView alloc] initWithFrame:NSMakeRect(0, 0, 1, 1)];
    if (!contentView)
        return nil;
    [layer setContentView:contentView];
    [contentView release];
    [contentView addSubview:aView];
    [_windowLayers addObject:layer];
    if (window) {
        if (!_isRegisteredForViewGeometryChangeNotifications) {
            [self HSQuartzOpenGLView_addViewGeometryObserversStartingFromView:self];
            _isRegisteredForViewGeometryChangeNotifications = 1;
            if (!_isRegisteredForWindowDidMoveNotification) {
                [[NSNotificationCenter defaultCenter] addObserver:_quartzOpenGLViewProxy selector:@selector(HSQuartzOpenGLView_windowDidMoveDuringChildAddition:) name:NSWindowDidMoveNotification object:window];
                _isRegisteredForWindowDidMoveNotification = 1;
            }
        }
        if (_isWindowLayersGeometryValid || [_windowLayers count] == 1) {
            NSRect contentRect = NSZeroRect;
            BOOL flipped = NO;
            NSRect bounds = NSZeroRect;
            float rotation = 0;
            [self HSQuartzOpenGLView_getWindowLayerContentRect:&contentRect windowLayerContentViewFlippedFlag:&flipped windowLayerContentViewBounds:&bounds windowLayerContentViewBoundsRotation:&rotation];
            [self HSQuartzOpenGLView_synchronizeGeometryOfWindowLayer:layer withContentRect:contentRect contentViewFlippedFlag:flipped contentViewBounds:bounds contentViewBoundsRotation:rotation];
            _isWindowLayersGeometryValid = 1;
        }
        [window addChildWindow:layer ordered:NSWindowAbove];
    }
    return layer;
}
- (void)viewDidMoveToWindow
{
    [super viewDidMoveToWindow];
    NSUInteger count = [_windowLayers count];
    if (!count)
        return;
    NSWindow *window = [self window];
    if (!window) {
        [_windowLayers makeObjectsPerformSelector:@selector(orderOut:) withObject:self];
        return;
    }
    [self HSQuartzOpenGLView_addViewGeometryObserversStartingFromView:self];
    _isRegisteredForViewGeometryChangeNotifications = 1;
    [[NSNotificationCenter defaultCenter] addObserver:_quartzOpenGLViewProxy selector:@selector(HSQuartzOpenGLView_windowDidMoveDuringChildAddition:) name:NSWindowDidMoveNotification object:window];
    _isWindowLayersGeometryValid = 0;
    _isRegisteredForWindowDidMoveNotification = 1;
    [self HSQuartzOpenGLView_synchronizeWindowLayersGeometry];
    for (NSUInteger i = 0; i < count; i++)
        [window addChildWindow:[_windowLayers objectAtIndex:i] ordered:NSWindowAbove];
}
- (void)viewWillMoveToWindow:(id)aWindow
{
    if (_isRegisteredForViewGeometryChangeNotifications) {
        [self HSQuartzOpenGLView_removeViewGeometryObservers];
        _isRegisteredForViewGeometryChangeNotifications = 0;
        if (_isRegisteredForWindowDidMoveNotification) {
            [[NSNotificationCenter defaultCenter] removeObserver:_quartzOpenGLViewProxy name:NSWindowDidMoveNotification object:[self window]];
            _isRegisteredForWindowDidMoveNotification = 0;
        }
        [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(HSQuartzOpenGLView_synchronizeWindowLayersGeometry) object:nil];
        NSWindow *window = [self window];
        NSUInteger count = [_windowLayers count];
        for (NSUInteger i = 0; i < count; i++)
            [window removeChildWindow:[_windowLayers objectAtIndex:i]];
    }
    [super viewWillMoveToWindow:aWindow];
}
- (void)HSQuartzOpenGLView_removeViewGeometryObservers
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:_quartzOpenGLViewProxy name:NSViewBoundsDidChangeNotification object:nil];
    [center removeObserver:_quartzOpenGLViewProxy name:NSViewFrameDidChangeNotification object:nil];
}
// The view and all its ancestors are observed.
- (void)HSQuartzOpenGLView_addViewGeometryObserversStartingFromView:(id)aView
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    for (NSView *view = aView; view; view = [view superview]) {
        [center addObserver:_quartzOpenGLViewProxy selector:@selector(HSQuartzOpenGLView_viewDidChangeGeometry:) name:NSViewBoundsDidChangeNotification object:view];
        [center addObserver:_quartzOpenGLViewProxy selector:@selector(HSQuartzOpenGLView_viewDidChangeGeometry:) name:NSViewFrameDidChangeNotification object:view];
    }
}
- (void)HSQuartzOpenGLView_windowDidMoveDuringChildAddition:(id)aAddition
{
    [[NSNotificationCenter defaultCenter] removeObserver:_quartzOpenGLViewProxy name:NSWindowDidMoveNotification object:[self window]];
    _isWindowLayersGeometryValid = 0;
    _isRegisteredForWindowDidMoveNotification = 0;
    [self HSQuartzOpenGLView_synchronizeWindowLayersGeometry];
}
// Geometry changes are coalesced into one synchronization.
- (void)HSQuartzOpenGLView_viewDidChangeGeometry:(id)aGeometry
{
    if (_isWindowLayersGeometryValid) {
        _isWindowLayersGeometryValid = 0;
        [self performSelector:@selector(HSQuartzOpenGLView_synchronizeWindowLayersGeometry) withObject:nil afterDelay:0];
    }
}
- (void)HSQuartzOpenGLView_synchronizeWindowLayersGeometry
{
    NSUInteger count = [_windowLayers count];
    if (count) {
        NSRect contentRect = NSZeroRect;
        BOOL flipped = NO;
        NSRect bounds = NSZeroRect;
        float rotation = 0;
        [self HSQuartzOpenGLView_getWindowLayerContentRect:&contentRect windowLayerContentViewFlippedFlag:&flipped windowLayerContentViewBounds:&bounds windowLayerContentViewBoundsRotation:&rotation];
        for (NSUInteger i = 0; i < count; i++)
            [self HSQuartzOpenGLView_synchronizeGeometryOfWindowLayer:[_windowLayers objectAtIndex:i] withContentRect:contentRect contentViewFlippedFlag:flipped contentViewBounds:bounds contentViewBoundsRotation:rotation];
    }
    _isWindowLayersGeometryValid = 1;
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(HSQuartzOpenGLView_synchronizeWindowLayersGeometry) object:nil];
}
// The layer covers the visible part of the view; its drawing view gets the view's frame and bounds.
- (void)HSQuartzOpenGLView_synchronizeGeometryOfWindowLayer:(id)aLayer withContentRect:(NSRect)aRect contentViewFlippedFlag:(BOOL)aFlag contentViewBounds:(NSRect)aBounds contentViewBoundsRotation:(CGFloat)aRotation
{
    [aLayer setFrame:[aLayer frameRectForContentRect:aRect] display:NO];
    HSQuartzOpenGLView_HSFlippingView *contentView = [aLayer contentView];
    [contentView setFlipped:aFlag];
    [contentView setBounds:aBounds];
    [contentView setBoundsRotation:aRotation];
    NSView *view = [[contentView subviews] objectAtIndex:0];
    [view setFrame:[self frame]];
    [view setFrameRotation:[self frameRotation]];
    [view setBounds:[self NSE_unrotatedBounds]];
    [view setBoundsRotation:[self boundsRotation]];
}
// Screen rect of the visible part, and the bounds/rotation mapping the layer content view onto
// the superview coordinates (a negative determinant flips it).
- (void)HSQuartzOpenGLView_getWindowLayerContentRect:(NSRect *)aRect windowLayerContentViewFlippedFlag:(BOOL *)aFlag windowLayerContentViewBounds:(NSRect *)aBounds windowLayerContentViewBoundsRotation:(float *)aRotation
{
    NSRect windowRect = [self convertRect:[self visibleRect] toView:nil];
    // -convertBaseToScreen: in the original.
    aRect->origin = [[self window] convertRectToScreen:NSMakeRect(windowRect.origin.x, windowRect.origin.y, 0, 0)].origin;
    aRect->size = windowRect.size;
    CGAffineTransform t = [[self superview] NSE_affineTransformToView:nil];
    float a = t.a, b = t.b, c = t.c, d = t.d;
    float x = (float)(t.tx - windowRect.origin.x);
    float y = (float)(t.ty - windowRect.origin.y);
    BOOL flipped = a * d < b * c;
    *aFlag = flipped;
    if (flipped) {
        b = -b;
        d = -d;
        y = (float)aRect->size.height - y;
    }
    *aRotation = (float)((atan2f(b, d) * 180.0) / M_PI);
    float scaleX = hypotf(a, c);
    float scaleY = hypotf(b, d);
    aBounds->origin.x = -x / scaleX;
    aBounds->origin.y = -y / scaleY;
    aBounds->size.width = (float)aRect->size.width / scaleX;
    aBounds->size.height = (float)aRect->size.height / scaleY;
}
- (void)dealloc
{
    if (_windowLayers) {
        NSUInteger count = [_windowLayers count];
        for (NSUInteger i = 0; i < count; i++) {
            id view = [[[[_windowLayers objectAtIndex:i] contentView] subviews] objectAtIndex:0];
            if ([view isKindOfClass:[HSQuartzOpenGLView_HSWindowLayerDrawingView class]])
                [view clearParentView];
        }
        [_windowLayers release];
    }
    [[self class] NSE_invalidateWeakProxy:_quartzOpenGLViewProxy];
    [_quartzOpenGLViewProxy release];
    [super dealloc];
}
- (id)initWithFrame:(NSRect)aFrame
{
    self = [super initWithFrame:aFrame];
    if (self) {
        [super setQuartzBackingEnabled:YES];
        [super setDisablesOpenGLSurfaceInLiveResize:YES];
        [super setOpenGLRendererMinVideoMemory:0x4000000];
    }
    return self;
}
- (id)HSQuartzOpenGLView_proxy
{
    if (!_quartzOpenGLViewProxy)
        _quartzOpenGLViewProxy = [self NSE_newWeakProxy];
    return _quartzOpenGLViewProxy;
}
@end

// Draws a window layer by sending the drawing selector to the parent view.
@implementation HSQuartzOpenGLView_HSWindowLayerDrawingView
+ (id)createDefaultOpenGLContext
{
    NSOpenGLContext *context = [super createDefaultOpenGLContext];
    if (context) {
        GLint opacity = 0;
        [context setValues:&opacity forParameter:NSOpenGLCPSurfaceOpacity];
        GLint swapInterval = 1;
        [context setValues:&swapInterval forParameter:NSOpenGLCPSwapInterval];
    }
    return context;
}
- (void)drawQuartzSurfaceRect:(NSRect)aRect
{
    if (![self isOpenGLSurfaceDisplayed])
        [self drawQuartzRect:aRect];
}
- (BOOL)drawOpenGLSurfaceQuartzTextureRect:(NSRect)aRect
{
    [self drawQuartzRect:aRect];
    return YES;
}
- (BOOL)drawOpenGLSurfaceRect:(NSRect)aRect
{
    glClearColor(0, 0, 0, 0);
    glClear(GL_COLOR_BUFFER_BIT);
    return [super drawOpenGLSurfaceRect:aRect];
}
- (void)drawQuartzRect:(NSRect)aRect
{
    id target = [_drawingInvocation target];
    [_drawingInvocation setArgument:&aRect atIndex:2];
    [_drawingInvocation invoke];
    [_drawingInvocation setTarget:target];
}
// Quirk: the original also asks the superview, which never changes the answer.
- (BOOL)isFlipped
{
    id target = [_drawingInvocation target];
    return target ? [target isFlipped] : [super isFlipped];
}
- (void)clearParentView
{
    [_drawingInvocation release];
    _drawingInvocation = nil;
}
- (void)dealloc
{
    [_drawingInvocation release];
    [super dealloc];
}
- (id)initWithFrame:(NSRect)aFrame parentView:(id)aView drawingSelector:(SEL)aSelector
{
    self = [super initWithFrame:aFrame];
    if (!self)
        return nil;
    NSMethodSignature *signature = [aView methodSignatureForSelector:aSelector];
    if (signature)
        _drawingInvocation = [[NSInvocation invocationWithMethodSignature:signature] retain];
    if (!_drawingInvocation) {
        [self release];
        return nil;
    }
    [_drawingInvocation setTarget:aView];
    [_drawingInvocation setSelector:aSelector];
    [super setQuartzBackingEnabled:YES];
    [super setOpenGLRendererMinVideoMemory:0x4000000];
    [super setDisablesOpenGLSurfaceInLiveResize:YES];
    [super setOpenGLSurfaceAutodisplayMode:1];
    if ([[HSSystem sharedSystem] isOpenGLEnabled])
        [super enableOpenGLSurface];
    return self;
}
@end

@implementation HSQuartzOpenGLView_HSFlippingView
- (void)setFlipped:(BOOL)aFlipped
{
    _isFlipped = aFlipped;
}
// Quirk: the original also asks the superview, which never changes the answer.
- (BOOL)isFlipped
{
    return _isFlipped;
}
@end
