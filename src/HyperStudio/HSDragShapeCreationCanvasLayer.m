#import "HSDragShapeCreationCanvasLayer.h"

@implementation HSDragShapeCreationCanvasLayer

- (void)cancelCreatingObject
{
    if ([_delegate respondsToSelector:@selector(dragShapeCreationLayer:willCancelEditingObject:)])
        [_delegate dragShapeCreationLayer:self willCancelEditingObject:_creatingObject];
    [self setCreatingObject:nil];
}

- (void)finishCreatingObject
{
    if ([_delegate respondsToSelector:@selector(dragShapeCreationLayer:willFinishEditingObject:)])
        [_delegate dragShapeCreationLayer:self willFinishEditingObject:_creatingObject];
    [self setCreatingObject:nil];
}

- (void)startCreatingShapeWithMouseEvent:(id)aEvent
{
    NSPoint point = [[self renderingView] convertPoint:[aEvent locationInWindow] fromView:nil];
    point = [[self renderingView] convertPointFromViewSpaceToUserSpace:point];
    id object = [[[self prototypeObject] localCopyIncludingNodeUnits:YES] autorelease];
    if ([_delegate respondsToSelector:@selector(dragShapeCreationLayer:shouldStartEditingObject:atUserPoint:)] && ![_delegate dragShapeCreationLayer:self shouldStartEditingObject:object atUserPoint:point])
        return;
    [self setCreatingObject:object];
    if ([_delegate respondsToSelector:@selector(dragShapeCreationLayer:didStartEditingObject:atUserPoint:)])
        [_delegate dragShapeCreationLayer:self didStartEditingObject:object atUserPoint:point];
}

- (id)cursorForPoint:(NSPoint)aPoint insideView:(BOOL)aView modifierFlags:(NSUInteger)aFlags hitTestInfo:(id)aInfo event:(id)aEvent
{
    if (!aView)
        return nil;
    return [HSCursor cursorNamed:@"HSCrossCursor"];
}

// The new object is sized by its default knob's tracker; without one a plain mouse tracker swallows the drag.
- (BOOL)handleMouseDownAtPoint:(NSPoint)aPoint event:(id)aEvent hitTestInfo:(id)aInfo
{
    [self startCreatingShapeWithMouseEvent:aEvent];
    id knob = nil;
    if (_creatingObject != nil)
        knob = [[_creatingObject queryHyperInterface:@protocol(HSSelectionKnobsProvider)] buildDefaultKnob];
    if (knob != nil) {
        id tracker = [knob querySelectionTrackerForModifierFlags:[aEvent modifierFlags]];
        [tracker setTrackingObject:_creatingObject];
        [[HSTrackingLoop trackingLoopWithView:[self renderingView] client:tracker] runWithMouseDownEvent:aEvent];
        [tracker setTrackingObject:nil];
    }
    else {
        id tracker = [[HSMouseTracker new] autorelease];
        [[HSTrackingLoop nonAutoscrollingTrackingLoopWithView:[self renderingView] client:tracker] runWithMouseDownEvent:aEvent];
    }
    if (_creatingObject != nil)
        [self finishCreatingObject];
    return YES;
}

- (id)hitTestCanvasLayerAtPoint:(NSPoint)aPoint insideView:(BOOL)aView clickCount:(NSUInteger)aCount modifierFlags:(NSUInteger)aFlags hitTestInfo:(id *)aInfo
{
    return self;
}

- (void)setCreatingObject:(id)aObject
{
    if (_creatingObject != aObject) {
        [_creatingObject release];
        _creatingObject = [aObject retain];
    }
}

- (id)creatingObject
{
    return _creatingObject;
}

- (void)setPrototypeObject:(id)aObject
{
    if (_prototypeObject != aObject) {
        [_prototypeObject release];
        _prototypeObject = [aObject retain];
    }
}

- (id)prototypeObject
{
    return _prototypeObject;
}

- (void)setDelegate:(id)aDelegate
{
    _delegate = aDelegate;
}

- (id)delegate
{
    return _delegate;
}

- (void)dealloc
{
    [_prototypeObject release];
    [_creatingObject release];
    [super dealloc];
}

@end
