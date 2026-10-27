#import "HyperPlayerBasePrefix.h"


@interface HSGestureRecognizer : NSObject
{
    id _target;
    SEL _action;
    int _state;
    NSView *_view;
}
- (BOOL)touchesCancelledWithEvent:(id)aEvent;
- (BOOL)touchesEndedWithEvent:(id)aEvent;
- (BOOL)touchesMovedWithEvent:(id)aEvent;
- (BOOL)touchesBeganWithEvent:(id)aEvent;
- (void)setView:(id)aView;
- (id)view;
- (void)setAction:(SEL)aAction;
- (SEL)action;
- (void)setTarget:(id)aTarget;
- (id)target;
- (id)initWithTarget:(id)aTarget action:(SEL)aAction view:(id)aView;
- (id)init;
@end

