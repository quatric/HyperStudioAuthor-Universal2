#import "HyperPlayerBasePrefix.h"


@interface HSWindowResizeController : NSObject <NSAnimationDelegate, NSObject>
{
    NSWindow *_window;
    NSViewAnimation *_animation;
    NSTimer *_resizeTimer;
}
+ (id)resizeControllerForWindow:(id)aWindow;
- (void)animationDidEnd:(id)aEnd;
- (void)animationDidStop:(id)aStop;
- (void)removeSelfFromMapTable;
- (void)invalidateTimer;
- (void)resizeWithTimer:(id)aTimer;
- (void)resizeToFrame:(NSRect)aFrame;
- (void)stopResize:(id)aResize;
- (void)setWindow:(id)aWindow;
- (void)dealloc;
- (id)initWithWindow:(id)aWindow;
@end

