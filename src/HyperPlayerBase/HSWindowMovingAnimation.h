#import "HyperPlayerBasePrefix.h"


@interface HSWindowMovingAnimation : NSViewAnimation
{
    NSWindow *_sourceWindow;
    NSRect _destinationRect;
}
- (void)startAnimation;
- (void)dealloc;
- (id)initWithWindow:(id)aWindow destinationRect:(NSRect)aRect;
- (id)initWithViewAnimations:(id)aAnimations;
- (id)init;
@end

