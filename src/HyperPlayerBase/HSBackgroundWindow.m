#import "HSBackgroundWindow.h"
@implementation HSBackgroundWindow
- (void)mouseDown:(id)aDown
{
    [self commintUpdateToController];
}
// Always covers the whole screen (the parent window's when none is given).
- (NSRect)constrainFrameRect:(NSRect)aRect toScreen:(id)aScreen
{
    if (aScreen == nil)
        aScreen = [[self parentWindow] screen];
    if (aScreen != nil)
        [self setFrame:[aScreen frame] display:[self isVisible]];
    return [self frame];
}
- (BOOL)canBecomeMainWindow
{
    return NO;
}
- (BOOL)canBecomeKeyWindow
{
    return NO;
}
- (void)commintUpdateToController
{
    [(id)[self delegate] updateWindowsOrder];
}
@end
