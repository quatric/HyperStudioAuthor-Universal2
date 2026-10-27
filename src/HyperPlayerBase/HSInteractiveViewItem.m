#import "HSInteractiveViewItem.h"

@implementation HSInteractiveViewItem

- (void)geometryWillChange:(id)aChange
{
    if ([self isActive])
        [_activeItemContext deactivateInteractiveItem:self];
}

- (void)setHandlingMouseEvent:(BOOL)aEvent
{
    if (_isHandlingMouseEvent != aEvent)
        _isHandlingMouseEvent = aEvent;
}

- (BOOL)isHandlingMouseEvent
{
    return _isHandlingMouseEvent;
}

- (id)cursorAtPoint:(NSPoint)aPoint modifierFlags:(NSUInteger)aFlags inCanvasLayer:(id)aLayer
{
    id cursorAttributes = [self queryHyperInterface:@protocol(HSCursorAttributes)];
    if (cursorAttributes == nil)
        return nil;
    return [cursorAttributes hyperCursor];
}

- (BOOL)hitTestPoint:(NSPoint)aPoint inCanvasLayer:(id)aLayer
{
    id hitTester = [[[aLayer context] canvasHitTester] hitTesterForNode:[self node] point:aPoint];
    if (hitTester == nil)
        return NO;
    NSPoint userPoint = [[[aLayer context] renderingView] convertPointFromViewSpaceToUserSpace:aPoint];
    return [hitTester hitTestUserPoint:userPoint];
}

- (void)nodeVisibilityDidChange:(id)aChange
{
    if ([[[self node] queryHyperInterface:@protocol(HSCardObjectAttributes)] isHiddenInPlayer])
        [[self activeItemContext] deactivateInteractiveItem:self];
}

- (BOOL)trackMouseWithScrollWheelEvent:(id)aEvent inInteractiveContext:(id)aContext
{
    return NO;
}

- (BOOL)wantsToTrackMouseWithScrollWheelEvent:(id)aEvent inInteractiveContext:(id)aContext
{
    return NO;
}

- (void)awakeInPlayer
{
}

- (BOOL)wantsToInterceptSendingClickActionsInInteractiveContext:(id)aContext
{
    return NO;
}

- (BOOL)sendingActionsIsDisabled
{
    return NO;
}

- (void)trackMouseWithMouseUpEvent:(id)aEvent inInteractiveContext:(id)aContext
{
}

- (BOOL)wantsToTrackMouseWithMouseUpEvent:(id)aEvent inInteractiveContext:(id)aContext
{
    return NO;
}

- (void)trackMouseWithMouseDownEvent:(id)aEvent inInteractiveContext:(id)aContext
{
    if (![self isActive] || _isHandlingMouseEvent)
        return;
    // Forward the click to the embedded view.
    NSPoint point = [[[self view] superview] convertPoint:[aEvent locationInWindow] fromView:nil];
    NSView *hitView = [[self view] hitTest:point];
    if (hitView != nil) {
        _isHandlingMouseEvent = YES;
        [hitView mouseDown:aEvent];
        _isHandlingMouseEvent = NO;
    }
    [_activeItemContext sendClickActionsForItemIfNeeded:self];
}

- (BOOL)hasExecutableActionsForMouseDownEvent:(id)aEvent inInteractiveContext:(id)aContext
{
    return NO;
}

- (BOOL)wantsToPassThroughMouseDownEvent:(id)aEvent inInteractiveContext:(id)aContext
{
    return NO;
}

- (BOOL)wantsToTrackMouseWithMouseDownEvent:(id)aEvent inInteractiveContext:(id)aContext
{
    return [self isActive];
}

- (id)activeItemContext
{
    return _activeItemContext;
}

- (BOOL)objectCanBeActivated
{
    return NO;
}

- (void)invalidateParentCanvasLayer
{
    [super invalidateParentCanvasLayer];
    _activeItemContext = nil;
}

- (void)deactivate
{
    [[[self node] attributeObservingController] removeObserver:self selector:@selector(nodeVisibilityDidChange:)
                                                     ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSCardObjectHiddenAttribute)];
    id nodeChild = [[self node] queryHyperInterface:@protocol(HSNodeChild)];
    if ([nodeChild hyperParent] != nil)
        [[_activeItemContext nodeVisualizationDisabling] endViewBasedInteractionForNodeChild:nodeChild];
    _activeItemContext = nil;
    [super deactivate];
}

- (void)activateInCanvasLayer:(id)aLayer
{
    [super activateInCanvasLayer:aLayer];
    // Weak: the context outlives its active item.
    _activeItemContext = [[self activeParentCanvasLayer] queryHyperInterface:@protocol(HSInteractiveCanvasContext)];
    id node = [self node];
    id nodeChild = [node queryHyperInterface:@protocol(HSNodeChild)];
    [[_activeItemContext nodeVisualizationDisabling] beginViewBasedInteractionForNodeChild:nodeChild];
    [[node attributeObservingController] addObserver:self selector:@selector(nodeVisibilityDidChange:)
                                           ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSCardObjectHiddenAttribute) withPriority:0.25];
}

- (void)setupViewFrameInCanvasLayer:(id)aLayer
{
    id renderingView = [[[self activeParentCanvasLayer] context] renderingView];
    id geometry = [[self hyperObject] queryHyperInterface:@protocol(HSGeometryAttributes)];
    if (geometry != nil) {
        NSRect frame = [renderingView viewBoundingRectForUserRect:[geometry frameBoundingRect]];
        [[self view] setFrame:frame];
    }
}

- (void)invalidateView
{
    [super invalidateView];
}

- (id)createView
{
    return nil;
}

- (BOOL)wantsToActivateImplicitlyInInteractiveContext:(id)aContext
{
    return [self objectCanBeActivated];
}

- (BOOL)wantsToActivateWithMouseInInteractiveContext:(id)aContext
{
    return [self objectCanBeActivated];
}

- (id)node
{
    return [self hyperObject];
}

- (id)implementationForHyperObject:(id)aObject
{
    id node = [aObject queryHyperInterface:@protocol(HSNodeAttributes)];
    if ([self hyperObject] != aObject && _node != node) {
        if (node == nil)
            return nil;
        return [[[[self class] alloc] initWithNode:node] autorelease];
    }
    return self;
}

- (id)hyperObject
{
    return _node;
}

- (void)dealloc
{
    [[[self hyperObject] attributeObservingController] removeObserver:self selector:@selector(geometryWillChange:)
                                                            ofChanges:1 ofAttribute:@protocol(HSGeometryAttribute)];
    [(id)_node release];
    [super dealloc];
}

- (id)initWithNode:(id)aNode
{
    self = [super init];
    if (self != nil) {
        _node = [aNode retain];
        [[[self hyperObject] attributeObservingController] addObserver:self selector:@selector(geometryWillChange:)
                                                             ofChanges:1 ofAttribute:@protocol(HSGeometryAttribute) withPriority:-0.25];
    }
    return self;
}

@end
