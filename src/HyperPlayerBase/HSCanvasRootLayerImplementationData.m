#import "HSCanvasRootLayerImplementationData.h"
#import "HSCanvasActionRegistry.h"
#import "HSCanvasLayerEventHandlingSupport.h"

// The state of a root canvas layer, kept apart so the layers that are not
// roots carry none.
@implementation HSCanvasRootLayerImplementationData

- (void)removeAllPendingSublayerTreeNotifications
{
    _pendingSublayerTreeNotificationsCount = 0;
}

- (void)addPendingSublayerTreeNotification
{
    _pendingSublayerTreeNotificationsCount++;
}

- (BOOL)hasPendingSublayerTreeNotifications
{
    return _pendingSublayerTreeNotificationsCount != 0;
}

- (void)decrementSublayerTreeNotificationsDelayCount
{
    _sublayerTreeNotificationsDelayCount--;
}

- (void)incrementSublayerTreeNotificationsDelayCount
{
    _sublayerTreeNotificationsDelayCount++;
}

- (BOOL)areSublayerTreeNotificationsDelayed
{
    return _sublayerTreeNotificationsDelayCount != 0;
}

- (void)setCanvasActionRegistry:(id)aRegistry
{
    if (_canvasActionRegistry == aRegistry)
        return;
    [_canvasActionRegistry release];
    _canvasActionRegistry = [aRegistry retain];
}

- (id)canvasActionRegistry
{
    return _canvasActionRegistry;
}

- (void)setActiveLayer:(id)aLayer
{
    [_activeLayer autorelease];
    _activeLayer = [aLayer retain];
}

- (id)activeLayer
{
    return _activeLayer;
}

- (void)setRepresentedObject:(id)aObject
{
    [_representedObject autorelease];
    _representedObject = [aObject retain];
}

- (id)representedObject
{
    return _representedObject;
}

- (void)setContext:(id)aContext
{
    _context = aContext;
}

- (id)context
{
    return _context;
}

- (void)dealloc
{
    [_canvasActionRegistry release];
    [_representedObject release];
    [_activeLayer release];
    [super dealloc];
}

@end

// Layers conforming to HSCanvasRootLayer get implementation data and run while
// they have a context and a represented object: they dispatch the view's events
// to their sublayers and find the targets of actions. The other layers act as
// plain composite layers, and do not respond to the root layer methods.
@implementation HSCanvasRootLayerMixin

+ (BOOL)instancesRespondToSelector:(SEL)aSelector
{
    BOOL responds = [super instancesRespondToSelector:aSelector];
    if (responds && ![self conformsToProtocol:@protocol(HSCanvasRootLayer)] && ![[HSCanvasRootLayerMixin superclass] instancesRespondToSelector:aSelector])
        responds = [self instanceMethodForSelector:aSelector] != [HSCanvasRootLayerMixin instanceMethodForSelector:aSelector];
    return responds;
}

- (void)performActionSelector:(SEL)aSelector withSender:(id)aSender
{
    if (!_rootLayerImplementationData) {
        [self doesNotRecognizeSelector:_cmd];
        return;
    }
    id target = [self targetLayerForActionSelector:aSelector];
    if (target)
        [target performSelector:aSelector withObject:aSender];
}

// Targets that do not validate items enable them all.
- (BOOL)validateActionSelector:(SEL)aSelector withUserInterfaceItem:(id)aItem
{
    if (!_rootLayerImplementationData) {
        [self doesNotRecognizeSelector:_cmd];
        return NO;
    }
    id target = [self targetLayerForActionSelector:aSelector];
    if (!target)
        return NO;
    if (![target respondsToSelector:@selector(validateUserInterfaceItem:)])
        return YES;
    return [target validateUserInterfaceItem:aItem];
}

- (BOOL)respondsToActionSelector:(SEL)aSelector
{
    if (!_rootLayerImplementationData) {
        [self doesNotRecognizeSelector:_cmd];
        return NO;
    }
    return [(HSCanvasActionRegistry *)[self canvasActionRegistry] isActionSelectorAvailable:aSelector];
}

- (void)registerSupportedActionSelector:(SEL)aSelector
{
    if (!_rootLayerImplementationData) {
        [self doesNotRecognizeSelector:_cmd];
        return;
    }
    [(HSCanvasActionRegistry *)[self canvasActionRegistry] registerSupportedActionSelector:aSelector];
}

// A touch sequence goes to the layer hit when it began.
- (BOOL)handleTouchesCancelled:(id)aCancelled
{
    if (!_rootLayerImplementationData) {
        [self doesNotRecognizeSelector:_cmd];
        return NO;
    }
    BOOL handled = [_gestureLayer handleTouchesCancelledWithEvent:aCancelled hitTestInfo:nil];
    [_gestureLayer release];
    _gestureLayer = nil;
    return handled;
}

- (BOOL)handleTouchesEnded:(id)aEnded
{
    if (!_rootLayerImplementationData) {
        [self doesNotRecognizeSelector:_cmd];
        return NO;
    }
    BOOL handled = [_gestureLayer handleTouchesEndedWithEvent:aEnded hitTestInfo:nil];
    [_gestureLayer release];
    _gestureLayer = nil;
    return handled;
}

- (BOOL)handleTouchesMoved:(id)aMoved
{
    if (!_rootLayerImplementationData) {
        [self doesNotRecognizeSelector:_cmd];
        return NO;
    }
    return [_gestureLayer handleTouchesMovedWithEvent:aMoved hitTestInfo:nil];
}

- (BOOL)handleTouchesBegan:(id)aBegan
{
    if (!_rootLayerImplementationData) {
        [self doesNotRecognizeSelector:_cmd];
        return NO;
    }
    NSView *view = [self renderingView];
    if (!view)
        return NO;
    NSPoint point = [view convertPoint:[(NSEvent *)aBegan locationInWindow] fromView:nil];
    BOOL inside = [view mouse:point inRect:[view visibleRect]];
    id info = nil;
    id layer = [self hitTestCanvasLayerAtPoint:point insideView:inside clickCount:1 modifierFlags:[(NSEvent *)aBegan modifierFlags] hitTestInfo:&info];
    if (_gestureLayer != layer) {
        [layer retain];
        [_gestureLayer handleTouchesCancelledWithEvent:aBegan hitTestInfo:nil];
        [_gestureLayer release];
        _gestureLayer = layer;
    }
    if ([self activeLayer] != _gestureLayer)
        [self setActiveLayer:nil];
    return [_gestureLayer handleTouchesBeganWithEvent:aBegan hitTestInfo:info];
}

- (BOOL)handleSwipeGesture:(id)aGesture
{
    return NO;
}

- (BOOL)handleRotationGesture:(id)aGesture
{
    if (!_rootLayerImplementationData) {
        [self doesNotRecognizeSelector:_cmd];
        return NO;
    }
    NSView *view = [self renderingView];
    if (!view)
        return NO;
    NSPoint point = [view convertPoint:[(NSEvent *)aGesture locationInWindow] fromView:nil];
    BOOL inside = [view mouse:point inRect:[view visibleRect]];
    id info = nil;
    id layer = [self hitTestCanvasLayerAtPoint:point insideView:inside clickCount:1 modifierFlags:[(NSEvent *)aGesture modifierFlags] hitTestInfo:&info];
    if ([self activeLayer] != layer)
        [self setActiveLayer:nil];
    if (!layer)
        return NO;
    return [layer handleRotationGestureWithEvent:aGesture hitTestInfo:info];
}

- (BOOL)handleMagnificationGesture:(id)aGesture
{
    if (!_rootLayerImplementationData) {
        [self doesNotRecognizeSelector:_cmd];
        return NO;
    }
    NSView *view = [self renderingView];
    if (!view)
        return NO;
    NSPoint point = [view convertPoint:[(NSEvent *)aGesture locationInWindow] fromView:nil];
    BOOL inside = [view mouse:point inRect:[view visibleRect]];
    id info = nil;
    id layer = [self hitTestCanvasLayerAtPoint:point insideView:inside clickCount:1 modifierFlags:[(NSEvent *)aGesture modifierFlags] hitTestInfo:&info];
    if ([self activeLayer] != layer)
        [self setActiveLayer:nil];
    if (!layer)
        return NO;
    return [layer handleMagnificationGestureWithEvent:aGesture hitTestInfo:info];
}

- (id)cursorForPoint:(NSPoint)aPoint insideView:(BOOL)aView modifierFlags:(NSUInteger)aFlags event:(id)aEvent
{
    if (!_rootLayerImplementationData) {
        [self doesNotRecognizeSelector:_cmd];
        return nil;
    }
    if (![self renderingView])
        return nil;
    id info = nil;
    id layer = [self hitTestCanvasLayerAtPoint:aPoint insideView:aView clickCount:1 modifierFlags:aFlags hitTestInfo:&info];
    if (!layer)
        return nil;
    return [layer cursorForPoint:aPoint insideView:aView modifierFlags:aFlags hitTestInfo:info event:aEvent];
}

- (BOOL)handleKeyEventSelector:(SEL)aSelector
{
    if (!_rootLayerImplementationData) {
        [self doesNotRecognizeSelector:_cmd];
        return NO;
    }
    return [self handleRootLayerKeyEventSelector:aSelector];
}

- (BOOL)handleRawKeyUpEvent:(id)aEvent
{
    if (!_rootLayerImplementationData)
        return NO;
    return [self handleRootLayerEventInvocation:[HSCanvasLayerEventHandlingSupport rawKeyUpHandlerInvocationWithEvent:aEvent]];
}

- (BOOL)handleRawKeyDownEvent:(id)aEvent
{
    if (!_rootLayerImplementationData) {
        [self doesNotRecognizeSelector:_cmd];
        return NO;
    }
    return [self handleRootLayerEventInvocation:[HSCanvasLayerEventHandlingSupport rawKeyDownHandlerInvocationWithEvent:aEvent]];
}

- (BOOL)handleKeyEquivalent:(id)aEquivalent
{
    if (!_rootLayerImplementationData) {
        [self doesNotRecognizeSelector:_cmd];
        return NO;
    }
    return [self handleRootLayerEventInvocation:[HSCanvasLayerEventHandlingSupport keyEquivalentHandlerInvocationWithEvent:aEquivalent]];
}

// Handled at where the mouse is.
- (BOOL)handleFlagsChanged:(id)aChanged
{
    if (!_rootLayerImplementationData) {
        [self doesNotRecognizeSelector:_cmd];
        return NO;
    }
    NSView *view = [self renderingView];
    if (!view)
        return NO;
    NSPoint point = [view convertPoint:[[view window] mouseLocationOutsideOfEventStream] fromView:nil];
    return [self handleRootLayerEventInvocation:[HSCanvasLayerEventHandlingSupport flagsChangedHandlerInvocationWithEvent:aChanged point:point]];
}

- (BOOL)handleScrollWheel:(id)aWheel
{
    if (!_rootLayerImplementationData) {
        [self doesNotRecognizeSelector:_cmd];
        return NO;
    }
    NSView *view = [self renderingView];
    if (!view)
        return NO;
    NSPoint point = [view convertPoint:[(NSEvent *)aWheel locationInWindow] fromView:nil];
    BOOL inside = [view mouse:point inRect:[view visibleRect]];
    id info = nil;
    id layer = [self hitTestCanvasLayerAtPoint:point insideView:inside clickCount:1 modifierFlags:[(NSEvent *)aWheel modifierFlags] hitTestInfo:&info];
    if ([self activeLayer] != layer)
        [self setActiveLayer:nil];
    if (!layer)
        return NO;
    return [layer handleScrollWheelAtPoint:point event:aWheel hitTestInfo:info];
}

- (void)handleMouseMoved:(id)aMoved
{
    if (!_rootLayerImplementationData) {
        [self doesNotRecognizeSelector:_cmd];
        return;
    }
    NSView *view = [self renderingView];
    if (!view)
        return;
    NSPoint point = [view convertPoint:[(NSEvent *)aMoved locationInWindow] fromView:nil];
    BOOL inside = [view mouse:point inRect:[view visibleRect]];
    [self handleRootLayerEventInvocation:[HSCanvasLayerEventHandlingSupport mouseMovedHandlerInvocationWithPoint:point insideView:inside event:aMoved]];
}

// Unlike a mouse down, a mouse up leaves the active layer as it is.
- (BOOL)handleMouseUp:(id)aUp
{
    if (!_rootLayerImplementationData) {
        [self doesNotRecognizeSelector:_cmd];
        return NO;
    }
    NSView *view = [self renderingView];
    if (!view)
        return NO;
    NSPoint point = [view convertPoint:[(NSEvent *)aUp locationInWindow] fromView:nil];
    BOOL inside = [view mouse:point inRect:[view visibleRect]];
    id info = nil;
    id layer = [self hitTestCanvasLayerAtPoint:point insideView:inside clickCount:[(NSEvent *)aUp clickCount] modifierFlags:[(NSEvent *)aUp modifierFlags] hitTestInfo:&info];
    if (!layer)
        return NO;
    return [layer handleMouseUpAtPoint:point event:aUp hitTestInfo:info];
}

- (BOOL)handleMouseDown:(id)aDown
{
    if (!_rootLayerImplementationData) {
        [self doesNotRecognizeSelector:_cmd];
        return NO;
    }
    NSView *view = [self renderingView];
    if (!view)
        return NO;
    NSPoint point = [view convertPoint:[(NSEvent *)aDown locationInWindow] fromView:nil];
    BOOL inside = [view mouse:point inRect:[view visibleRect]];
    id info = nil;
    id layer = [self hitTestCanvasLayerAtPoint:point insideView:inside clickCount:[(NSEvent *)aDown clickCount] modifierFlags:[(NSEvent *)aDown modifierFlags] hitTestInfo:&info];
    if ([self activeLayer] != layer)
        [self setActiveLayer:nil];
    if (!layer)
        return NO;
    return [layer handleMouseDownAtPoint:point event:aDown hitTestInfo:info];
}

// Changes made while delayed are notified once, at the outermost end.
- (void)endSublayerTreeChanging
{
    if (!_rootLayerImplementationData) {
        [self doesNotRecognizeSelector:_cmd];
        return;
    }
    [_rootLayerImplementationData decrementSublayerTreeNotificationsDelayCount];
    if ([_rootLayerImplementationData areSublayerTreeNotificationsDelayed])
        return;
    BOOL hasPending = [_rootLayerImplementationData hasPendingSublayerTreeNotifications];
    [_rootLayerImplementationData removeAllPendingSublayerTreeNotifications];
    if (hasPending)
        [self sublayerTreeDidChange];
}

- (void)beginSublayerTreeChanging
{
    if (!_rootLayerImplementationData) {
        [self doesNotRecognizeSelector:_cmd];
        return;
    }
    [_rootLayerImplementationData incrementSublayerTreeNotificationsDelayCount];
}

// An active layer no longer in the tree is dropped, and the actions are
// available anew.
- (void)sublayerTreeDidChange
{
    if (!_rootLayerImplementationData) {
        [self doesNotRecognizeSelector:_cmd];
        return;
    }
    if ([_rootLayerImplementationData areSublayerTreeNotificationsDelayed]) {
        [_rootLayerImplementationData addPendingSublayerTreeNotification];
        return;
    }
    if ([self activeLayer] && [[[self activeLayer] parentLayer] rootLayer] != self)
        [self setActiveLayer:nil];
    [(HSCanvasActionRegistry *)[self canvasActionRegistryCreateIfNeeded:NO] invalidateActionSelectorAvailability];
}

- (id)activeLayer
{
    if (!_rootLayerImplementationData) {
        [self doesNotRecognizeSelector:_cmd];
        return nil;
    }
    return [_rootLayerImplementationData activeLayer];
}

- (void)setActiveLayer:(id)aLayer
{
    if (!_rootLayerImplementationData) {
        [self doesNotRecognizeSelector:_cmd];
        return;
    }
    [_rootLayerImplementationData setActiveLayer:aLayer];
}

- (void)setRunningDisabled:(BOOL)aDisabled
{
    if (!_rootLayerImplementationData) {
        [self doesNotRecognizeSelector:_cmd];
        return;
    }
    [self setRootLayerRunningDisabled:aDisabled];
}

- (void)setRepresentedObject:(id)aObject
{
    if (!_rootLayerImplementationData) {
        [self doesNotRecognizeSelector:_cmd];
        return;
    }
    if ([_rootLayerImplementationData representedObject] == aObject)
        return;
    [self representedObjectWillChange];
    [_rootLayerImplementationData setRepresentedObject:aObject];
    [self representedObjectDidChange];
}

- (void)setContext:(id)aContext
{
    if (!_rootLayerImplementationData) {
        [self doesNotRecognizeSelector:_cmd];
        return;
    }
    if ([_rootLayerImplementationData context] == aContext)
        return;
    if ([self renderingView])
        [self invalidateDisplay];
    [self contextWillChange];
    [_rootLayerImplementationData setContext:aContext];
    [self contextDidChange];
    if ([self renderingView])
        [self invalidateDisplay];
}

- (id)rootLayer
{
    if (!_rootLayerImplementationData)
        return [super rootLayer];
    return self;
}

- (void)setParentLayer:(id)aLayer
{
    if (!_rootLayerImplementationData)
        [super setParentLayer:aLayer];
}

- (id)parentLayer
{
    if (!_rootLayerImplementationData)
        return [super parentLayer];
    return nil;
}

- (void)representedObjectDidChange
{
    [super representedObjectDidChange];
    if (_rootLayerImplementationData)
        [self activateRootLayerIfNeeded];
}

- (void)representedObjectWillChange
{
    if (_rootLayerImplementationData)
        [self setRootLayerActive:NO];
    [super representedObjectWillChange];
}

- (void)contextDidChange
{
    if (_rootLayerImplementationData)
        [self observeRenderingViewNotifications];
    [super contextDidChange];
    if (_rootLayerImplementationData)
        [self activateRootLayerIfNeeded];
}

- (void)contextWillChange
{
    if (_rootLayerImplementationData) {
        [self setRootLayerActive:NO];
        [self stopObservingRenderingViewNotifications];
    }
    [super contextWillChange];
}

- (BOOL)isRunningInWindow
{
    if (!_rootLayerImplementationData)
        return [super isRunningInWindow];
    return [self isRootLayerRunningInWindow];
}

- (BOOL)isRunning
{
    if (!_rootLayerImplementationData)
        return [super isRunning];
    return [self isRootLayerActive];
}

- (id)representedObject
{
    if (!_rootLayerImplementationData)
        return [super representedObject];
    return [_rootLayerImplementationData representedObject];
}

- (id)context
{
    if (!_rootLayerImplementationData)
        return [super context];
    return [_rootLayerImplementationData context];
}

// The active layer first, then the tree from the topmost sublayer down.
- (BOOL)handleRootLayerKeyEventSelector:(SEL)aSelector
{
    if ([self activeLayer] && [self handleKeyEventSelector:aSelector inCanvasLayer:[self activeLayer]])
        return YES;
    return [self handleKeyEventSelector:aSelector andTraverseCanvasLayer:self isRootLayer:YES];
}

// Sublayers before their superlayer; the root itself is left out.
- (BOOL)handleKeyEventSelector:(SEL)aSelector andTraverseCanvasLayer:(id)aLayer isRootLayer:(BOOL)aLayer2
{
    BOOL handled = NO;
    if ([aLayer queryHyperInterface:@protocol(HSCanvasSuperlayer)]) {
        NSUInteger count = [aLayer numberOfSublayers];
        for (NSUInteger index = count; index > 0 && !handled; index--)
            handled = [self handleKeyEventSelector:aSelector andTraverseCanvasLayer:[aLayer sublayerAtIndex:index - 1] isRootLayer:NO];
    }
    if (!aLayer2 && !handled)
        handled = [self handleKeyEventSelector:aSelector inCanvasLayer:aLayer];
    return handled;
}

- (BOOL)handleKeyEventSelector:(SEL)aSelector inCanvasLayer:(id)aLayer
{
    if ([aLayer respondsToSelector:@selector(handleKeyEventSelector:)])
        return [aLayer handleKeyEventSelector:aSelector];
    if (![aLayer respondsToSelector:aSelector])
        return NO;
    [aLayer performSelector:aSelector withObject:nil];
    return YES;
}

- (BOOL)handleRootLayerEventInvocation:(id)aInvocation
{
    if ([self activeLayer] && [self handleEventInvocation:aInvocation inCanvasLayer:[self activeLayer]])
        return YES;
    return [self handleEventInvocation:aInvocation andTraverseCanvasLayer:self isRootLayer:YES];
}

- (BOOL)handleEventInvocation:(id)aInvocation andTraverseCanvasLayer:(id)aLayer isRootLayer:(BOOL)aLayer2
{
    BOOL handled = NO;
    if ([aLayer queryHyperInterface:@protocol(HSCanvasSuperlayer)]) {
        NSUInteger count = [aLayer numberOfSublayers];
        for (NSUInteger index = count; index > 0 && !handled; index--)
            handled = [self handleEventInvocation:aInvocation andTraverseCanvasLayer:[aLayer sublayerAtIndex:index - 1] isRootLayer:NO];
    }
    if (!aLayer2 && !handled)
        handled = [self handleEventInvocation:aInvocation inCanvasLayer:aLayer];
    return handled;
}

- (BOOL)handleEventInvocation:(id)aInvocation inCanvasLayer:(id)aLayer
{
    BOOL handled = NO;
    if ([aLayer respondsToSelector:[(NSInvocation *)aInvocation selector]]) {
        [(NSInvocation *)aInvocation invokeWithTarget:aLayer];
        [(NSInvocation *)aInvocation getReturnValue:&handled];
    }
    return handled;
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
    BOOL responds = [super respondsToSelector:aSelector];
    if (responds && !_rootLayerImplementationData)
        responds = [[self class] instancesRespondToSelector:aSelector];
    return responds;
}

- (BOOL)canvasActionRegistry:(id)aRegistry isAvailableActionSelector:(SEL)aSelector
{
    return [self targetLayerForActionSelector:aSelector] != nil;
}

- (id)targetLayerForActionSelector:(SEL)aSelector
{
    if ([[self activeLayer] respondsToSelector:aSelector])
        return [self activeLayer];
    return [self targetLayerForActionSelector:aSelector inCompositeLayer:self];
}

- (id)canvasActionRegistry
{
    return [self canvasActionRegistryCreateIfNeeded:YES];
}

- (id)canvasActionRegistryCreateIfNeeded:(BOOL)aNeeded
{
    HSCanvasActionRegistry *registry = [_rootLayerImplementationData canvasActionRegistry];
    if (!registry && aNeeded) {
        registry = [[[HSCanvasActionRegistry alloc] init] autorelease];
        [registry setAvailabilityInformationSource:self];
        [_rootLayerImplementationData setCanvasActionRegistry:registry];
    }
    return registry;
}

// The topmost sublayer responding, searched deepest first.
- (id)targetLayerForActionSelector:(SEL)aSelector inCompositeLayer:(id)aLayer
{
    NSUInteger count = [aLayer numberOfSublayers];
    id target = nil;
    for (NSUInteger index = count; index > 0 && !target; index--) {
        id sublayer = [aLayer sublayerAtIndex:index - 1];
        id superlayer = [sublayer queryHyperInterface:@protocol(HSCanvasSuperlayer)];
        if (superlayer)
            target = [self targetLayerForActionSelector:aSelector inCompositeLayer:superlayer];
        if (!target && [sublayer respondsToSelector:aSelector])
            target = sublayer;
    }
    return target;
}

- (void)stopObservingRenderingViewNotifications
{
    HSCanvasRootLayerImplementationData *data = _rootLayerImplementationData;
    if (!data->flags.observesRenderingViewNotifications)
        return;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:HSViewDidChangeUserSpaceToViewSpaceTransformNotification object:[self renderingView]];
    data->flags.observesRenderingViewNotifications = NO;
}

- (void)observeRenderingViewNotifications
{
    if (![self renderingView])
        return;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rootLayerViewDidChangeUserSpaceToViewSpaceTransform:) name:HSViewDidChangeUserSpaceToViewSpaceTransformNotification object:[self renderingView]];
    ((HSCanvasRootLayerImplementationData *)_rootLayerImplementationData)->flags.observesRenderingViewNotifications = YES;
}

- (void)rootLayerViewDidChangeUserSpaceToViewSpaceTransform:(id)aTransform
{
    [self renderingViewTransformDidChange];
}

// While disabled, the layer seems stopped to its sublayers.
- (void)setRootLayerRunningDisabled:(BOOL)aDisabled
{
    if (!_rootLayerImplementationData) {
        [self doesNotRecognizeSelector:_cmd];
        return;
    }
    HSCanvasRootLayerImplementationData *data = _rootLayerImplementationData;
    if (data->flags.isRunningDisabled == (aDisabled != NO))
        return;
    if (!data->flags.isRunningDisabled) {
        if (data->flags.isRunningInWindow)
            [self rootLayerNotifyWillStopRunningInWindow];
        if (data->flags.isActive)
            [self rootLayerNotifyWillStopRunning];
    }
    data->flags.isRunningDisabled = aDisabled != NO;
    if (data->flags.isRunningDisabled)
        return;
    if (data->flags.isActive)
        [self rootLayerNotifyDidStartRunning];
    if (data->flags.isRunningInWindow)
        [self rootLayerNotifyDidStartRunningInWindow];
}

- (void)rootLayerViewDidMountIntoWindow:(id)aWindow
{
    [self setRootLayerObservesViewMountNotifications:NO];
    [self setRootLayerRunningInWindow:YES];
}

- (void)rootLayerViewWillUnmountFromWindow:(id)aWindow
{
    [self setRootLayerRunningInWindow:NO];
    [self setRootLayerObservesViewMountNotifications:YES];
}

// Running in a window lasts until the rendering view leaves it.
- (void)setRootLayerRunningInWindow:(BOOL)aWindow
{
    if (!_rootLayerImplementationData) {
        [self doesNotRecognizeSelector:_cmd];
        return;
    }
    HSCanvasRootLayerImplementationData *data = _rootLayerImplementationData;
    if (data->flags.isRunningInWindow == (aWindow != NO))
        return;
    if (data->flags.isRunningInWindow) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:HSViewWillUnmountFromWindowNotification object:[self renderingView]];
        [self rootLayerNotifyWillStopRunningInWindow];
    }
    data->flags.isRunningInWindow = aWindow != NO;
    if (!data->flags.isRunningInWindow)
        return;
    [self rootLayerNotifyDidStartRunningInWindow];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rootLayerViewWillUnmountFromWindow:) name:HSViewWillUnmountFromWindowNotification object:[self renderingView]];
}

- (BOOL)isRootLayerRunningInWindow
{
    if (!_rootLayerImplementationData) {
        [self doesNotRecognizeSelector:_cmd];
        return NO;
    }
    HSCanvasRootLayerImplementationData *data = _rootLayerImplementationData;
    return data->flags.isRunningInWindow && !data->flags.isRunningDisabled;
}

- (void)activateRootLayerIfNeeded
{
    if (!_rootLayerImplementationData) {
        [self doesNotRecognizeSelector:_cmd];
        return;
    }
    if ([self context] && [self representedObject])
        [self setRootLayerActive:YES];
}

// An active layer runs in the window as soon as its rendering view is in one.
- (void)setRootLayerActive:(BOOL)aActive
{
    if (!_rootLayerImplementationData) {
        [self doesNotRecognizeSelector:_cmd];
        return;
    }
    HSCanvasRootLayerImplementationData *data = _rootLayerImplementationData;
    if (data->flags.isActive == (aActive != NO))
        return;
    [self setRootLayerRunningInWindow:NO];
    [self setRootLayerObservesViewMountNotifications:NO];
    if (data->flags.isActive)
        [self rootLayerNotifyWillStopRunning];
    data->flags.isActive = aActive != NO;
    if (!data->flags.isActive)
        return;
    [self rootLayerNotifyDidStartRunning];
    if ([[self renderingView] window])
        [self setRootLayerRunningInWindow:YES];
    else
        [self setRootLayerObservesViewMountNotifications:YES];
}

- (void)rootLayerNotifyWillStopRunningInWindow
{
    if (!_rootLayerImplementationData) {
        [self doesNotRecognizeSelector:_cmd];
        return;
    }
    if (!((HSCanvasRootLayerImplementationData *)_rootLayerImplementationData)->flags.isRunningDisabled)
        [self willStopRunningInWindow];
}

- (void)rootLayerNotifyWillStopRunning
{
    if (!_rootLayerImplementationData) {
        [self doesNotRecognizeSelector:_cmd];
        return;
    }
    if (!((HSCanvasRootLayerImplementationData *)_rootLayerImplementationData)->flags.isRunningDisabled)
        [self willStopRunning];
}

- (void)rootLayerNotifyDidStartRunningInWindow
{
    if (!_rootLayerImplementationData) {
        [self doesNotRecognizeSelector:_cmd];
        return;
    }
    if (!((HSCanvasRootLayerImplementationData *)_rootLayerImplementationData)->flags.isRunningDisabled)
        [self didStartRunningInWindow];
}

- (void)rootLayerNotifyDidStartRunning
{
    if (!_rootLayerImplementationData) {
        [self doesNotRecognizeSelector:_cmd];
        return;
    }
    if (!((HSCanvasRootLayerImplementationData *)_rootLayerImplementationData)->flags.isRunningDisabled)
        [self didStartRunning];
}

- (void)setRootLayerObservesViewMountNotifications:(BOOL)aNotifications
{
    if (!_rootLayerImplementationData) {
        [self doesNotRecognizeSelector:_cmd];
        return;
    }
    HSCanvasRootLayerImplementationData *data = _rootLayerImplementationData;
    if (data->flags.observesViewMountNotifications == (aNotifications != NO))
        return;
    if (data->flags.observesViewMountNotifications)
        [[NSNotificationCenter defaultCenter] removeObserver:self name:HSViewDidMountIntoWindowNotification object:[self renderingView]];
    data->flags.observesViewMountNotifications = aNotifications != NO;
    if (data->flags.observesViewMountNotifications)
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rootLayerViewDidMountIntoWindow:) name:HSViewDidMountIntoWindowNotification object:[self renderingView]];
}

- (BOOL)isRootLayerActive
{
    if (!_rootLayerImplementationData) {
        [self doesNotRecognizeSelector:_cmd];
        return NO;
    }
    HSCanvasRootLayerImplementationData *data = _rootLayerImplementationData;
    return data->flags.isActive && !data->flags.isRunningDisabled;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [(HSCanvasActionRegistry *)[_rootLayerImplementationData canvasActionRegistry] setAvailabilityInformationSource:nil];
    [_rootLayerImplementationData release];
    // The original leaked the layer of an unfinished touch sequence.
    [_gestureLayer release];
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self && [self conformsToProtocol:@protocol(HSCanvasRootLayer)])
        _rootLayerImplementationData = [[HSCanvasRootLayerImplementationData alloc] init];
    return self;
}

@end
