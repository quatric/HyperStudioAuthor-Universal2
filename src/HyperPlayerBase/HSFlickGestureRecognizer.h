#import "HyperPlayerBasePrefix.h"
#import "HSGestureRecognizer.h"


@interface HSFlickGestureRecognizer : HSGestureRecognizer
{
    NSTouch *_initialTouch;
    NSEvent *_initialEvent;
    NSSize _direction;
    float _velocity;
}
- (BOOL)touchesCancelledWithEvent:(id)aEvent;
- (BOOL)touchesEndedWithEvent:(id)aEvent;
- (BOOL)touchesMovedWithEvent:(id)aEvent;
- (BOOL)touchesBeganWithEvent:(id)aEvent;
- (void)invalidateTouches;
- (id)initialTouch;
- (CGFloat)velocity;
- (NSSize)direction;
- (void)dealloc;
@end

