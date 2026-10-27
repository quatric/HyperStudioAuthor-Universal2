#import "HSCanvasItemsSublayer.h"
#import "NSView+HSExtensions.h"

// An abstract canvas sublayer of indexed items: subclasses supply the items
// and hit testing support. Items are hit tested top (last) down, rendered
// with the active item last, and invalidated by rect or by region as each
// prefers. An item adopting HSCanvasItemActivation is activated while it is
// the active item.
@implementation HSCanvasItemsSublayer

- (void)didActivateItem:(id)aItem
{
    if ([aItem conformsToProtocol:@protocol(HSCanvasItemActivation)]) {
        [self invalidateDisplayForCanvasItem:aItem];
        _activeItemActivationInterface = [aItem retain];
        [_activeItemActivationInterface activateInCanvasLayer:self];
    }
    [self invalidateDisplayForCanvasItem:aItem];
}

- (void)willDeactivateItem:(id)aItem
{
    [self invalidateDisplayForCanvasItem:aItem];
    if (_activeItemActivationInterface) {
        [_activeItemActivationInterface deactivate];
        [_activeItemActivationInterface release];
        _activeItemActivationInterface = nil;
        [self invalidateDisplayForCanvasItem:aItem];
    }
}

- (void)willResignActiveLayer
{
    [self privateSetActiveItem:nil];
}

- (void)didBecomeActiveLayer
{
}

// Having an active item makes this the root layer's active layer.
- (void)setActiveItem:(id)aItem
{
    id oldItem = _activeItem;
    [self privateSetActiveItem:aItem];
    id newItem = _activeItem;
    if ((newItem != nil) == (oldItem != nil))
        return;
    if (oldItem && [[[self parentLayer] rootLayer] activeLayer] == self)
        [[[self parentLayer] rootLayer] setActiveLayer:nil];
    if (newItem && [[[self parentLayer] rootLayer] activeLayer] != self)
        [[[self parentLayer] rootLayer] setActiveLayer:self];
}

- (void)privateSetActiveItem:(id)aItem
{
    if (_activeItem == aItem)
        return;
    if (_activeItem)
        [self willDeactivateItem:_activeItem];
    [_activeItem release];
    _activeItem = [aItem retain];
    if (_activeItem)
        [self didActivateItem:_activeItem];
}

- (id)activeItem
{
    return _activeItem;
}

- (BOOL)handleTouchesCancelledWithEvent:(id)aEvent hitTestInfo:(id)aInfo
{
    return NO;
}

- (BOOL)handleTouchesEndedWithEvent:(id)aEvent hitTestInfo:(id)aInfo
{
    return NO;
}

- (BOOL)handleTouchesMovedWithEvent:(id)aEvent hitTestInfo:(id)aInfo
{
    return NO;
}

- (BOOL)handleTouchesBeganWithEvent:(id)aEvent hitTestInfo:(id)aInfo
{
    return NO;
}

- (BOOL)handleSwipeGesture:(id)aGesture hitTestInfo:(id)aInfo
{
    return NO;
}

- (BOOL)handleRotationGestureWithEvent:(id)aEvent hitTestInfo:(id)aInfo
{
    return NO;
}

- (BOOL)handleMagnificationGestureWithEvent:(id)aEvent hitTestInfo:(id)aInfo
{
    return NO;
}

- (BOOL)handleScrollWheelAtPoint:(NSPoint)aPoint event:(id)aEvent hitTestInfo:(id)aInfo
{
    return NO;
}

- (BOOL)handleMouseUpAtPoint:(NSPoint)aPoint event:(id)aEvent hitTestInfo:(id)aInfo
{
    return NO;
}

- (BOOL)handleMouseDownAtPoint:(NSPoint)aPoint event:(id)aEvent hitTestInfo:(id)aInfo
{
    return NO;
}

// The hit item is the hit test info.
- (id)hitTestCanvasLayerAtPoint:(NSPoint)aPoint insideView:(BOOL)aView clickCount:(NSUInteger)aCount modifierFlags:(NSUInteger)aFlags hitTestInfo:(id *)aInfo
{
    if (!aView)
        return nil;
    id item = [self hitTestItem:aPoint];
    if (!item)
        return nil;
    if (aInfo)
        *aInfo = item;
    return self;
}

- (id)hitTestNextInteractiveItemAfterItem:(id)aItem atPoint:(NSPoint)aPoint insideView:(BOOL)aView clickCount:(NSUInteger)aCount modifierFlags:(NSUInteger)aFlags hitTestInfo:(id *)aInfo
{
    if (!aView)
        return nil;
    id item = [self hitTestItem:aPoint afterItem:aItem];
    if (!item)
        return nil;
    if (aInfo)
        *aInfo = item;
    return self;
}

// Both the area the item covered before updating and the one after are
// redisplayed.
- (void)updateCanvasItemIfNeeded:(id)aNeeded
{
    NSRect bounds = NSZeroRect;
    id region = nil;
    BOOL prefersRegion = NO;
    if ([self renderingView]) {
        prefersRegion = [aNeeded prefersRegionInvalidation];
        if (prefersRegion)
            region = [[aNeeded renderingRegionInCanvasLayer:self] retain];
        else
            bounds = [aNeeded renderingBoundsInCanvasLayer:self];
    }
    if ([aNeeded updateIfNeededInCanvasLayer:self] && [self renderingView]) {
        if (prefersRegion) {
            if (![region isEmpty])
                [[self renderingView] setNeedsHyperDisplayInRegion:region];
        } else if (!NSIsEmptyRect(bounds)) {
            [[self renderingView] setNeedsDisplayOpenGLSurfaceInRect:bounds];
        }
        [self invalidateDisplayForCanvasItem:aNeeded];
    }
    [region release];
}

- (void)updateCanvasItemsIfNeeded
{
    NSUInteger count = [self numberOfCanvasItems];
    for (NSUInteger i = 0; i < count; i++)
        [self updateCanvasItemIfNeeded:[self canvasItemAtIndex:i]];
}

- (void)invalidateDisplayForCanvasItem:(id)aItem
{
    if (![self renderingView])
        return;
    if ([aItem prefersRegionInvalidation]) {
        id region = [aItem renderingRegionInCanvasLayer:self];
        if (![region isEmpty])
            [[self renderingView] setNeedsHyperDisplayInRegion:region];
    } else {
        NSRect bounds = [aItem renderingBoundsInCanvasLayer:self];
        if (!NSIsEmptyRect(bounds))
            [[self renderingView] setNeedsDisplayOpenGLSurfaceInRect:bounds];
    }
}

- (void)invalidateDisplayForItemsInRange:(NSRange)aRange
{
    for (NSUInteger i = aRange.location; i < NSMaxRange(aRange); i++) {
        id item = [self canvasItemAtIndex:i];
        if (item)
            [self invalidateDisplayForCanvasItem:item];
    }
}

- (BOOL)supportsHitTesting
{
    return NO;
}

- (id)canvasItemAtIndex:(NSUInteger)aIndex
{
    return nil;
}

- (NSUInteger)numberOfCanvasItems
{
    return 0;
}

- (void)representedObjectDidChange
{
}

- (void)representedObjectWillChange
{
}

- (NSUInteger)indexOfCanvasItem:(id)aItem
{
    NSUInteger count = [self numberOfCanvasItems];
    for (NSUInteger i = 0; i < count; i++) {
        if ([aItem isEqual:[self canvasItemAtIndex:i]])
            return i;
    }
    return NSNotFound;
}

- (id)cursorAtPoint:(NSPoint)aPoint modifierFlags:(NSUInteger)aFlags inHitItem:(id)aItem
{
    return [aItem cursorAtPoint:aPoint modifierFlags:aFlags inCanvasLayer:self];
}

- (id)cursorForPoint:(NSPoint)aPoint insideView:(BOOL)aView modifierFlags:(NSUInteger)aFlags hitTestInfo:(id)aInfo event:(id)aEvent
{
    if (!aInfo)
        return nil;
    return [self cursorAtPoint:aPoint modifierFlags:aFlags inHitItem:aInfo];
}

- (BOOL)hitTestRect:(NSRect)aRect inItem:(id)aItem
{
    return [aItem hitTestRect:aRect inCanvasLayer:self];
}

- (BOOL)hitTestPoint:(NSPoint)aPoint inItem:(id)aItem
{
    return [aItem hitTestPoint:aPoint inCanvasLayer:self];
}

// The first hit item below aItem2, nil when aItem2 is not hit.
- (id)hitTestItem:(NSPoint)aItem afterItem:(id)aItem2
{
    NSUInteger count = [self numberOfCanvasItems];
    if (count == 0 || ![self supportsHitTesting])
        return nil;
    BOOL foundItem = NO;
    for (NSUInteger i = count; i-- > 0;) {
        id item = [self canvasItemAtIndex:i];
        if (!item || ![self hitTestPoint:aItem inItem:item])
            continue;
        if (foundItem)
            return item;
        if ([item isEqual:aItem2])
            foundItem = YES;
    }
    return nil;
}

- (id)hitTestItem:(NSPoint)aItem
{
    return [self hitTestItem:aItem totalCount:[self numberOfCanvasItems]];
}

// Among the first aCount items.
- (id)hitTestItem:(NSPoint)aItem totalCount:(NSUInteger)aCount
{
    if (aCount == 0 || ![self supportsHitTesting])
        return nil;
    for (NSUInteger i = aCount; i-- > 0;) {
        id item = [self canvasItemAtIndex:i];
        if (item && [self hitTestPoint:aItem inItem:item])
            return item;
    }
    return nil;
}

- (NSRect)boundingRectOccupiedByLayer
{
    NSRect rect = NSZeroRect;
    NSUInteger count = [self numberOfCanvasItems];
    for (NSUInteger i = 0; i < count; i++)
        rect = NSUnionRect(rect, [self boundingRectForItem:[self canvasItemAtIndex:i]]);
    return rect;
}

- (void)renderRect:(NSRect)aRect
{
    NSUInteger count = [self numberOfCanvasItems];
    for (NSUInteger i = 0; i < count; i++) {
        id item = [self canvasItemAtIndex:i];
        if (item && item != _activeItem)
            [self renderItem:item invalidRect:aRect isActive:NO];
    }
    if (_activeItem)
        [self renderItem:_activeItem invalidRect:aRect isActive:YES];
}

- (void)renderItem:(id)aItem invalidRect:(NSRect)aRect isActive:(BOOL)aActive
{
    if ([aItem prefersRegionInvalidation]) {
        if (![[aItem renderingRegionInCanvasLayer:self] intersectsRect:aRect])
            return;
    } else {
        if (!aItem || !NSIntersectsRect([aItem renderingBoundsInCanvasLayer:self], aRect))
            return;
    }
    [aItem renderRect:aRect inCanvasLayer:self isActive:aActive];
}

- (NSRect)boundingRectForItem:(id)aItem
{
    if ([aItem prefersRegionInvalidation])
        return [[aItem renderingRegionInCanvasLayer:self] boundingRect];
    return [aItem renderingBoundsInCanvasLayer:self];
}

- (void)invalidateDisplay
{
    [self invalidateDisplayForItemsInRange:NSMakeRange(0, [self numberOfCanvasItems])];
}

- (id)renderingView
{
    return [[self context] renderingView];
}

- (void)renderingViewTransformDidChange
{
    [self updateCanvasItemsIfNeeded];
}

- (BOOL)isRunningInWindow
{
    return [_parentLayer isRunningInWindow];
}

- (BOOL)isRunning
{
    return [_parentLayer isRunning];
}

- (void)willStopRunningInWindow
{
}

- (void)didStartRunningInWindow
{
}

- (void)willStopRunning
{
}

- (void)didStartRunning
{
}

- (void)contextWillChange
{
}

- (void)contextDidChange
{
    if ([self context])
        [self updateCanvasItemsIfNeeded];
}

- (id)representedObject
{
    return [_parentLayer representedObject];
}

- (id)context
{
    return [_parentLayer context];
}

- (id)parentLayer
{
    return _parentLayer;
}

- (void)setParentLayer:(id)aLayer
{
    _parentLayer = aLayer;
}

- (void)dealloc
{
    if (_activeItemActivationInterface) {
        [_activeItemActivationInterface invalidateParentCanvasLayer];
        [_activeItemActivationInterface release];
    }
    [_activeItem release];
    [super dealloc];
}

@end
