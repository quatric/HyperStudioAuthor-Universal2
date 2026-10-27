#import "HSAnimationSetupEditPathCanvasLayer.h"

@implementation HSAnimationSetupEditPathCanvasLayer

- (void)setPoint:(NSPoint)aPoint atIndex:(NSUInteger)aIndex forPath:(id)aPath
{
    NSPoint points[1];
    points[0] = aPoint;
    [aPath setAssociatedPoints:points atIndex:aIndex];
}

- (NSPoint)pointAtIndex:(NSUInteger)aIndex forPath:(id)aPath
{
    NSPoint points[3];
    [aPath elementAtIndex:aIndex associatedPoints:points];
    return points[0];
}

- (BOOL)prefersRegionInvalidation
{
    return YES;
}

// Moves the selected knobs (or all of them when dragging the whole path)
// from their pre-drag positions, in both the path and the try-it path.
- (void)dragToUserPoint:(NSPoint)aPoint
{
    [[self rootLayer] invalidateDisplay];
    id path = [_owner pathForEditPathCanvasLayer:self];
    id tryItPath = [_owner tryItPathForEditPathCanvasLayer:self];
    CGFloat downX = _mouseDownUserPoint.x;
    CGFloat downY = _mouseDownUserPoint.y;
    NSUInteger count = [_owner knobCountForEditPathCanvasLayer:self];
    id owner = _owner;
    for (NSUInteger i = 0; i < count; ) {
        NSUInteger index = i++;
        if ([owner editPathCanvasLayer:self isKnobSelected:index] || _draggingPath) {
            NSPoint point = [self pointAtIndex:index forPath:_pathBeforeDrag];
            point.x += aPoint.x - downX;
            point.y += aPoint.y - downY;
            if (index == 0)
                [_owner editPathCanvasLayer:self firstPathPointWillChangeTo:point];
            [self setPoint:point atIndex:index forPath:path];
            [self setPoint:point atIndex:index forPath:tryItPath];
        }
        count = [_owner knobCountForEditPathCanvasLayer:self];
        owner = _owner;
    }
    [owner updateTryItAnimatedObjectFromEditPathCanvasLayer:self];
    [[self rootLayer] invalidateDisplay];
}

- (NSPoint)userPointFromEvent:(id)aEvent
{
    NSPoint viewPoint = [[self renderingView] convertPoint:[aEvent locationInWindow] fromView:nil];
    return [[self renderingView] convertPointFromViewSpaceToUserSpace:viewPoint];
}

- (NSPoint)viewPointFromEvent:(id)aEvent
{
    return [[self renderingView] convertPoint:[aEvent locationInWindow] fromView:nil];
}

- (void)handleFlagsChanged:(id)aChanged inTrackingLoop:(id)aLoop
{
}

// A click without a drag changes the selection: plain click selects only this
// knob, Command toggles it, Shift extends the selection from the nearest
// selected knob (backwards first, then forwards).
- (void)handleMouseUp:(id)aUp inTrackingLoop:(id)aLoop
{
    if (!_didDrag) {
        if (!_draggingPath && !_mouseDownWithCommand && !_mouseDownWithShift) {
            BOOL onSelectedKnob = _mouseDownOnSelectedKnob;
            [_owner deselectAllKnobsForEditPathCanvasLayer:self];
            if (!onSelectedKnob)
                [_owner editPathCanvasLayer:self setSelected:YES knob:_mouseDownKnobIndex];
        }
        if (_mouseDownWithCommand && !_mouseDownWithShift) {
            BOOL selected = [_owner editPathCanvasLayer:self isKnobSelected:_mouseDownKnobIndex];
            [_owner editPathCanvasLayer:self setSelected:!selected knob:_mouseDownKnobIndex];
        }
        if (_mouseDownWithShift) {
            if (_mouseDownOnSelectedKnob) {
                [_owner editPathCanvasLayer:self setSelected:NO knob:_mouseDownKnobIndex];
            } else {
                NSUInteger anchor = _mouseDownKnobIndex;
                BOOL found = NO;
                NSUInteger back;
                for (back = 1; back <= _mouseDownKnobIndex; back++) {
                    if ([_owner editPathCanvasLayer:self isKnobSelected:_mouseDownKnobIndex - back]) {
                        anchor = _mouseDownKnobIndex - back;
                        found = YES;
                        break;
                    }
                }
                if (!found) {
                    NSUInteger forward = _mouseDownKnobIndex;
                    for (;;) {
                        forward++;
                        if (forward >= [_owner knobCountForEditPathCanvasLayer:self]) {
                            [_owner editPathCanvasLayer:self setSelected:YES knob:_mouseDownKnobIndex];
                            goto done;
                        }
                        if ([_owner editPathCanvasLayer:self isKnobSelected:forward]) {
                            anchor = forward;
                            break;
                        }
                    }
                }
                NSUInteger low = anchor < _mouseDownKnobIndex ? anchor : _mouseDownKnobIndex;
                NSUInteger high = anchor > _mouseDownKnobIndex ? anchor : _mouseDownKnobIndex;
                for (NSUInteger i = low; i <= high; i++)
                    [_owner editPathCanvasLayer:self setSelected:YES knob:i];
            }
        }
    } else {
        [_owner didEndEditingFromEditPathCanvasLayer:self];
    }
done:
    [_pathBeforeDrag release];
    _pathBeforeDrag = nil;
    _tracking = NO;
}

- (void)handleMouseDragged:(id)aDragged inTrackingLoop:(id)aLoop
{
    if (!_didDrag) {
        if (!_mouseDownOnSelectedKnob && !_draggingPath) {
            [_owner deselectAllKnobsForEditPathCanvasLayer:self];
            [_owner editPathCanvasLayer:self setSelected:YES knob:_mouseDownKnobIndex];
        }
        _pathBeforeDrag = [[_owner pathForEditPathCanvasLayer:self] copy];
    }
    _didDrag = YES;
    [self dragToUserPoint:[self userPointFromEvent:aDragged]];
}

- (void)handleMouseDown:(id)aDown inTrackingLoop:(id)aLoop
{
    _mouseDownUserPoint = [self userPointFromEvent:aDown];
    _didDrag = NO;
    _tracking = YES;
}

- (BOOL)handleKeyEventSelector:(SEL)aSelector
{
    if (aSelector == @selector(deleteBackward:) || aSelector == @selector(deleteForward:)) {
        [_owner removeSelectedKnobsForEditPathCanvasLayer:self];
        return YES;
    }
    return NO;
}

- (id)cursorForPoint:(NSPoint)aPoint insideView:(BOOL)aView modifierFlags:(NSUInteger)aFlags hitTestInfo:(id)aInfo event:(id)aEvent
{
    NSUInteger knob = [[_owner canvasItemForEditPathCanvasLayer:self] knobAtViewPoint:aPoint];
    if (knob == NSNotFound && !_tracking)
        return nil;
    return [HSCursor cursorNamed:HSArrowMoveCursor];
}

// A hit on a knob selects/toggles it on mouse-up; Option on the path inserts
// a new knob, a plain hit on the path drags the whole path.
- (BOOL)handleMouseDownAtPoint:(NSPoint)aPoint event:(id)aEvent hitTestInfo:(id)aInfo
{
    NSPoint viewPoint = [self viewPointFromEvent:aEvent];
    _mouseDownKnobIndex = (unsigned int)[_owner editPathCanvasLayer:self knobAtViewPoint:viewPoint];
    HSTrackingLoop *loop;
    if (_mouseDownKnobIndex == NSNotFound) {
        id path = [_owner transformedPathForEditPathCanvasLayer:self];
        if (!([aEvent modifierFlags] & NSAlternateKeyMask)) {
            if (![path hyperPathContainsPoint:viewPoint tolerance:3.0f index:NULL relativeDistance:NULL]) {
                [_owner editPathCanvasLayer:self didNotHandleMouseDownAtPoint:aPoint event:aEvent hitTestInfo:aInfo];
                return NO;
            }
            [_owner willBeginEditingFromEditPathCanvasLayer:self];
            _mouseDownWithCommand = NO;
            _mouseDownWithShift = NO;
            _mouseDownOnSelectedKnob = NO;
            _draggingPath = YES;
            loop = [HSTrackingLoop trackingLoopWithView:[self renderingView] client:self];
        } else {
            int index = -1;
            float relativeDistance = -1.0f;
            if (![path hyperPathContainsPoint:viewPoint tolerance:3.0f index:&index relativeDistance:&relativeDistance]) {
                [_owner editPathCanvasLayer:self didNotHandleMouseDownAtPoint:aPoint event:aEvent hitTestInfo:aInfo];
                return NO;
            }
            [_owner editPathCanvasLayer:self addPointAfterPoint:index relativeDistance:relativeDistance];
            [[self renderingView] setNeedsDisplayOpenGLSurface:YES];
            [_owner willBeginEditingFromEditPathCanvasLayer:self];
            _mouseDownWithCommand = ([aEvent modifierFlags] >> 20) & 1;
            _mouseDownWithShift = ([aEvent modifierFlags] >> 17) & 1;
            _mouseDownOnSelectedKnob = YES;
            _mouseDownKnobIndex = index + 1;
            _draggingPath = NO;
            loop = [HSTrackingLoop trackingLoopWithView:[self renderingView] client:self];
        }
    } else {
        _mouseDownWithCommand = ([aEvent modifierFlags] >> 20) & 1;
        _mouseDownWithShift = ([aEvent modifierFlags] >> 17) & 1;
        _mouseDownOnSelectedKnob = [_owner editPathCanvasLayer:self isKnobSelected:_mouseDownKnobIndex];
        _draggingPath = NO;
        [_owner willBeginEditingFromEditPathCanvasLayer:self];
        loop = [HSTrackingLoop trackingLoopWithView:[self renderingView] client:self];
    }
    [loop runWithMouseDownEvent:aEvent];
    return YES;
}

- (id)hitTestCanvasLayerAtPoint:(NSPoint)aPoint insideView:(BOOL)aView clickCount:(NSUInteger)aCount modifierFlags:(NSUInteger)aFlags hitTestInfo:(id *)aInfo
{
    return self;
}

- (void)setOwner:(id)aOwner
{
    _owner = aOwner;
}

- (id)owner
{
    return _owner;
}

- (void)dealloc
{
    [_pathBeforeDrag release];
    [super dealloc];
}

@end
