#import "HSToolPaletteWindow.h"

@implementation HSToolPaletteWindow

- (void)performClose:(id)aClose
{
    id delegate = [self delegate];
    if ([delegate respondsToSelector:@selector(windowShouldClose:)] && ![delegate windowShouldClose:self])
        return;
    [self close];
}

- (BOOL)canBecomeKeyWindow
{
    return YES;
}

@end
