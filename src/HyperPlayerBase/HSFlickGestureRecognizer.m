#import "HSFlickGestureRecognizer.h"
// A quick one-finger swipe on the trackpad: moved at least 0.15 of the pad
// within 0.07 s of touching. The action gets the direction and speed (in
// view points per second).
enum { HSFlickStatePossible = 0, HSFlickStateRecognized = 3, HSFlickStateFailed = 5 };

@implementation HSFlickGestureRecognizer
- (BOOL)touchesCancelledWithEvent:(id)aEvent
{
    _state = HSFlickStateFailed;
    [self invalidateTouches];
    return NO;
}
- (BOOL)touchesEndedWithEvent:(id)aEvent
{
    [self invalidateTouches];
    return _state == HSFlickStateRecognized;
}
- (BOOL)touchesMovedWithEvent:(id)aEvent
{
    if (_state == HSFlickStatePossible) {
        NSSet *touches = [aEvent touchesMatchingPhase:NSTouchPhaseMoved inView:nil];
        NSTouch *touch = [touches count] == 1 ? [touches anyObject] : nil;
        NSTimeInterval start = [_initialEvent timestamp], now = [(NSEvent *)aEvent timestamp];
        if (touch == nil || [_initialTouch device] != [touch device] || now - start > 0.07)
            _state = HSFlickStateFailed;
        else {
            NSPoint from = [_initialTouch normalizedPosition], to = [touch normalizedPosition];
            if (hypotf((float)(from.x - to.x), (float)(from.y - to.y)) >= 0.15f) {
                NSPoint startPoint = [_view convertPoint:[_initialEvent locationInWindow] fromView:nil];
                NSPoint endPoint = [_view convertPoint:[aEvent locationInWindow] fromView:nil];
                float distance = hypotf((float)(startPoint.x - endPoint.x), (float)(startPoint.y - endPoint.y));
                if (distance != 0) {
                    _velocity = (float)(distance / (now - start));
                    _direction = NSMakeSize(endPoint.x - startPoint.x, endPoint.y - startPoint.y);
                    [NSApp sendAction:[self action] to:[self target] from:self];
                    _state = HSFlickStateRecognized;
                }
            }
        }
    }
    return _state == HSFlickStatePossible || _state == HSFlickStateRecognized;
}
// One finger only.
- (BOOL)touchesBeganWithEvent:(id)aEvent
{
    if (_state == HSFlickStateFailed)
        return NO;
    if (_initialTouch != nil) {
        _state = HSFlickStateFailed;
        [self invalidateTouches];
        return NO;
    }
    NSSet *touches = [aEvent touchesMatchingPhase:NSTouchPhaseBegan inView:_view];
    if ([touches count] != 1) {
        _state = HSFlickStateFailed;
        return NO;
    }
    _initialTouch = [[touches anyObject] retain];
    _initialEvent = [aEvent retain];
    return YES;
}
- (void)invalidateTouches
{
    [_initialTouch release];
    _initialTouch = nil;
    [_initialEvent release];
    _initialEvent = nil;
}
- (id)initialTouch
{
    return _initialTouch;
}
- (CGFloat)velocity
{
    return _velocity;
}
- (NSSize)direction
{
    return _direction;
}
- (void)dealloc
{
    [_initialTouch release];
    [_initialEvent release];
    [super dealloc];
}
@end
