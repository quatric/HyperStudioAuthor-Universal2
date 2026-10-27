#import "HyperPlayerBasePrefix.h"


@interface HSBackgroundWindow : NSPanel
{
}
- (void)mouseDown:(id)aDown;
- (NSRect)constrainFrameRect:(NSRect)aRect toScreen:(id)aScreen;
- (BOOL)canBecomeMainWindow;
- (BOOL)canBecomeKeyWindow;
- (void)commintUpdateToController;
@end

