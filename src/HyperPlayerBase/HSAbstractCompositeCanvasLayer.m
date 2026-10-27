#import "HSAbstractCompositeCanvasLayer.h"

// A canvas layer made of sublayers (the storage is the subclass's): events
// go to the sublayers from the top one down, rendering from the bottom one
// up, and running/context/represented object changes are passed on.
@implementation HSAbstractCompositeCanvasLayer

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

- (id)cursorForPoint:(NSPoint)aPoint insideView:(BOOL)aView modifierFlags:(NSUInteger)aFlags hitTestInfo:(id)aInfo event:(id)aEvent
{
    NSUInteger index = [self numberOfSublayers];
    while (index != 0) {
        id cursor = [[self sublayerAtIndex:--index] cursorForPoint:aPoint insideView:aView modifierFlags:aFlags hitTestInfo:aInfo event:aEvent];
        if (cursor != nil)
            return cursor;
    }
    return nil;
}

- (BOOL)handleMouseUpAtPoint:(NSPoint)aPoint event:(id)aEvent hitTestInfo:(id)aInfo
{
    NSUInteger index = [self numberOfSublayers];
    while (index != 0) {
        if ([[self sublayerAtIndex:--index] handleMouseUpAtPoint:aPoint event:aEvent hitTestInfo:aInfo])
            return YES;
    }
    return NO;
}

- (BOOL)handleMouseDownAtPoint:(NSPoint)aPoint event:(id)aEvent hitTestInfo:(id)aInfo
{
    NSUInteger index = [self numberOfSublayers];
    while (index != 0) {
        if ([[self sublayerAtIndex:--index] handleMouseDownAtPoint:aPoint event:aEvent hitTestInfo:aInfo])
            return YES;
    }
    return NO;
}

- (id)hitTestCanvasLayerAtPoint:(NSPoint)aPoint insideView:(BOOL)aView clickCount:(NSUInteger)aCount modifierFlags:(NSUInteger)aFlags hitTestInfo:(id *)aInfo
{
    id info = nil;
    id layer = nil;
    NSUInteger index = [self numberOfSublayers];
    while (index != 0) {
        layer = [[self sublayerAtIndex:--index] hitTestCanvasLayerAtPoint:aPoint insideView:aView clickCount:aCount modifierFlags:aFlags hitTestInfo:&info];
        if (layer != nil)
            break;
    }
    if (aInfo != NULL)
        *aInfo = info;
    return layer;
}

- (id)hitTestNextInteractiveItemAfterItem:(id)aItem atPoint:(NSPoint)aPoint insideView:(BOOL)aView clickCount:(NSUInteger)aCount modifierFlags:(NSUInteger)aFlags hitTestInfo:(id *)aInfo
{
    id info = nil;
    id item = nil;
    NSUInteger index = [self numberOfSublayers];
    while (index != 0) {
        item = [[self sublayerAtIndex:--index] hitTestNextInteractiveItemAfterItem:aItem atPoint:aPoint insideView:aView clickCount:aCount modifierFlags:aFlags hitTestInfo:&info];
        if (item != nil)
            break;
    }
    if (aInfo != NULL)
        *aInfo = info;
    return item;
}

- (NSRect)boundingRectOccupiedByLayer
{
    NSRect rect = NSZeroRect;
    NSUInteger count = [self numberOfSublayers];
    for (NSUInteger i = 0; i < count; i++)
        rect = NSUnionRect(rect, [[self sublayerAtIndex:i] boundingRectOccupiedByLayer]);
    return rect;
}

- (void)renderRect:(NSRect)aRect
{
    [self renderSublayersInRange:NSMakeRange(0, [self numberOfSublayers]) inRect:aRect];
}

- (void)renderSublayersInRange:(NSRange)aRange inRect:(NSRect)aRect
{
    for (NSUInteger i = aRange.location; i < NSMaxRange(aRange); i++)
        [[self sublayerAtIndex:i] renderRect:aRect];
}

- (void)invalidateDisplay
{
    NSUInteger count = [self numberOfSublayers];
    for (NSUInteger i = 0; i < count; i++)
        [[self sublayerAtIndex:i] invalidateDisplay];
}

- (BOOL)isRunningInWindow
{
    return [[self parentLayer] isRunningInWindow];
}

- (BOOL)isRunning
{
    return [[self parentLayer] isRunning];
}

- (id)representedObject
{
    return [[self parentLayer] representedObject];
}

- (id)context
{
    return [[self parentLayer] context];
}

- (void)willResignActiveLayer
{
}

- (void)didBecomeActiveLayer
{
}

- (void)renderingViewTransformDidChange
{
    NSUInteger index = [self numberOfSublayers];
    while (index != 0)
        [[self sublayerAtIndex:--index] renderingViewTransformDidChange];
}

- (void)representedObjectDidChange
{
    NSUInteger index = [self numberOfSublayers];
    while (index != 0)
        [[self sublayerAtIndex:--index] representedObjectDidChange];
}

- (void)representedObjectWillChange
{
    NSUInteger index = [self numberOfSublayers];
    while (index != 0)
        [[self sublayerAtIndex:--index] representedObjectWillChange];
}

- (void)willStopRunningInWindow
{
    NSUInteger index = [self numberOfSublayers];
    while (index != 0)
        [[self sublayerAtIndex:--index] willStopRunningInWindow];
}

- (void)willStopRunning
{
    NSUInteger index = [self numberOfSublayers];
    while (index != 0)
        [[self sublayerAtIndex:--index] willStopRunning];
}

- (void)didStartRunningInWindow
{
    NSUInteger index = [self numberOfSublayers];
    while (index != 0)
        [[self sublayerAtIndex:--index] didStartRunningInWindow];
}

- (void)didStartRunning
{
    NSUInteger index = [self numberOfSublayers];
    while (index != 0)
        [[self sublayerAtIndex:--index] didStartRunning];
}

- (void)contextDidChange
{
    NSUInteger index = [self numberOfSublayers];
    while (index != 0)
        [[self sublayerAtIndex:--index] contextDidChange];
}

- (void)contextWillChange
{
    NSUInteger index = [self numberOfSublayers];
    while (index != 0)
        [[self sublayerAtIndex:--index] contextWillChange];
}

- (id)parentLayer
{
    return _parentLayer;
}

- (void)setParentLayer:(id)aLayer
{
    _parentLayer = aLayer;
}

- (id)rootLayer
{
    return [[self parentLayer] rootLayer];
}

- (void)willRemoveSublayer:(id)aSublayer
{
    [aSublayer invalidateDisplay];
    if ([self isRunningInWindow])
        [aSublayer willStopRunningInWindow];
    if ([self isRunning])
        [aSublayer willStopRunning];
    [aSublayer contextWillChange];
    [aSublayer representedObjectWillChange];
    [aSublayer setParentLayer:nil];
    [aSublayer contextDidChange];
    [aSublayer representedObjectDidChange];
}

- (void)didAddSublayer:(id)aSublayer
{
    [aSublayer contextWillChange];
    [aSublayer representedObjectWillChange];
    [aSublayer setParentLayer:self];
    [aSublayer contextDidChange];
    [aSublayer representedObjectDidChange];
    if ([self isRunning])
        [aSublayer didStartRunning];
    if ([self isRunningInWindow])
        [aSublayer didStartRunningInWindow];
    [aSublayer invalidateDisplay];
}

- (void)removeAllSublayers
{
    NSUInteger index = [self numberOfSublayers];
    while (index != 0)
        [self removeSublayerAtIndex:--index];
}

- (void)removeSublayerAtIndex:(NSUInteger)aIndex
{
    [self removeSublayer:[self sublayerAtIndex:aIndex] atIndex:aIndex];
}

- (void)removeSublayer:(id)aSublayer
{
    [self removeSublayer:aSublayer atIndex:[self indexOfSublayer:aSublayer]];
}

- (void)removeSublayer:(id)aSublayer atIndex:(NSUInteger)aIndex
{
    [self willRemoveSublayer:aSublayer];
    [self removeSublayerFromStorage:aSublayer atIndex:aIndex];
    [[self rootLayer] sublayerTreeDidChange];
}

- (void)addSublayer:(id)aSublayer
{
    [self addSublayer:aSublayer atIndex:[self numberOfSublayers]];
}

- (void)addSublayer:(id)aSublayer atIndex:(NSUInteger)aIndex
{
    [self insertSublayerInStorage:aSublayer atIndex:aIndex];
    [self didAddSublayer:aSublayer];
    [[self rootLayer] sublayerTreeDidChange];
}

- (NSUInteger)indexOfSublayer:(id)aSublayer
{
    NSUInteger count = [self numberOfSublayers];
    for (NSUInteger i = 0; i < count; i++) {
        if ([self sublayerAtIndex:i] == aSublayer)
            return i;
    }
    return NSNotFound;
}

// The storage, for subclasses.
- (void)removeSublayerFromStorage:(id)aStorage atIndex:(NSUInteger)aIndex
{
    [self doesNotRecognizeSelector:_cmd];
}

- (void)insertSublayerInStorage:(id)aStorage atIndex:(NSUInteger)aIndex
{
    [self doesNotRecognizeSelector:_cmd];
}

- (id)sublayerAtIndex:(NSUInteger)aIndex
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (NSUInteger)numberOfSublayers
{
    [self doesNotRecognizeSelector:_cmd];
    return 0;
}

- (id)allSublayers
{
    NSUInteger count = [self numberOfSublayers];
    NSMutableArray *sublayers = [NSMutableArray arrayWithCapacity:count];
    for (NSUInteger i = 0; i < count; i++)
        [sublayers addObject:[self sublayerAtIndex:i]];
    return sublayers;
}

- (id)renderingView
{
    return [[self context] renderingView];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

@end
