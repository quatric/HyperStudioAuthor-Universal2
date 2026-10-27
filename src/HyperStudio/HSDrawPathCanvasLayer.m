#import "HSDrawPathCanvasLayer.h"

@implementation HSDrawPathCanvasLayer

- (NSPoint)userPointFromEvent:(id)aEvent
{
    NSPoint location = [(NSEvent *)aEvent locationInWindow];
    if ([aEvent window] != nil)
        location = [[aEvent window] convertPointToScreen:location];
    id view = [self renderingView];
    location = [[view window] convertPointFromScreen:location];
    location = [view convertPoint:location fromView:nil];
    location = [view convertPointFromViewSpaceToUserSpace:location];
    return NSMakePoint(roundf(location.x), roundf(location.y));
}

- (void)handleFlagsChanged:(id)aChanged inTrackingLoop:(id)aLoop
{
}

- (void)handleMouseUp:(id)aUp inTrackingLoop:(id)aLoop
{
    if (![_owner didStartPathForDrawPathCanvasLayer:self])
        return;
    if (_pathCreationMode == 1)
        [_owner drawPathCanvasLayer:self finishPathPartAtPoint:[self userPointFromEvent:aUp]];
    else
        [_owner finishPathCreationForDrawPathCanvasLayer:self];
}

- (void)handleMouseDragged:(id)aDragged inTrackingLoop:(id)aLoop
{
    if ([_owner didStartPathForDrawPathCanvasLayer:self])
        [_owner drawPathCanvasLayer:self addPointToPath:[self userPointFromEvent:aDragged]];
}

- (void)handleMouseDown:(id)aDown inTrackingLoop:(id)aLoop
{
    BOOL started = [_owner didStartPathForDrawPathCanvasLayer:self];
    NSPoint point = [self userPointFromEvent:aDown];
    if (started)
        [_owner drawPathCanvasLayer:self continuePathAtPoint:point];
    else
        [_owner drawPathCanvasLayer:self startPathCreationAtPoint:point];
}

- (BOOL)handleRawKeyDownEvent:(id)aEvent
{
    if ([(NSEvent *)aEvent keyCode] != 0x31)
        return NO;
    [_owner finishPathCreationForDrawPathCanvasLayer:self];
    return YES;
}

- (BOOL)handleKeyEventSelector:(SEL)aSelector
{
    if (aSelector == @selector(cancel:) || aSelector == @selector(cancelOperation:))
        [_owner cancelPathCreationForDrawPathCanvasLayer:self];
    else if (aSelector == @selector(insertNewline:))
        [_owner finishPathCreationForDrawPathCanvasLayer:self];
    else
        return NO;
    return YES;
}

- (BOOL)handleMouseMovedAtPoint:(NSPoint)aPoint insideView:(BOOL)aView event:(id)aEvent
{
    [_owner drawPathCanvasLayer:self mouseMovedToPoint:[self userPointFromEvent:aEvent]];
    return YES;
}

- (BOOL)handleMouseDownAtPoint:(NSPoint)aPoint event:(id)aEvent hitTestInfo:(id)aInfo
{
    [[HSTrackingLoop trackingLoopWithView:[self renderingView] client:self] runWithMouseDownEvent:aEvent];
    return YES;
}

- (id)hitTestCanvasLayerAtPoint:(NSPoint)aPoint insideView:(BOOL)aView clickCount:(NSUInteger)aCount modifierFlags:(NSUInteger)aFlags hitTestInfo:(id *)aInfo
{
    return self;
}

- (NSInteger)pathCreationMode
{
    return _pathCreationMode;
}

- (void)setOwner:(id)aOwner
{
    _owner = aOwner;
}

- (id)owner
{
    return _owner;
}

- (id)initWithPathCreationMode:(NSInteger)aMode
{
    self = [super init];
    if (self != nil)
        _pathCreationMode = (int)aMode;
    return self;
}

@end
