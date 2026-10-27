#import "HSGestureRecognizer.h"
// The base of the touch gesture recognizers: a target and action, and the
// view (none of them retained). Subclasses handle the touches.
@implementation HSGestureRecognizer
- (BOOL)touchesCancelledWithEvent:(id)aEvent
{
    return NO;
}
- (BOOL)touchesEndedWithEvent:(id)aEvent
{
    return NO;
}
- (BOOL)touchesMovedWithEvent:(id)aEvent
{
    return NO;
}
- (BOOL)touchesBeganWithEvent:(id)aEvent
{
    return NO;
}
- (void)setView:(id)aView
{
    _view = aView;
}
- (id)view
{
    return _view;
}
- (void)setAction:(SEL)aAction
{
    _action = aAction;
}
- (SEL)action
{
    return _action;
}
- (void)setTarget:(id)aTarget
{
    _target = aTarget;
}
- (id)target
{
    return _target;
}
- (id)initWithTarget:(id)aTarget action:(SEL)aAction view:(id)aView
{
    self = [super init];
    if (self != nil) {
        _target = aTarget;
        _action = aAction;
        _view = aView;
        _state = 0;
    }
    return self;
}
// Needs a target.
- (id)init
{
    [self release];
    return nil;
}
@end
