#import "HSQCView.h"
@implementation HSQCView
- (void)setDelegate:(id)aDelegate
{
    _delegate = aDelegate;
}
- (id)delegate
{
    return _delegate;
}
- (void)mouseDown:(id)aDown
{
    [super mouseDown:aDown];
    if ([[self delegate] respondsToSelector:@selector(mouseDownInCompositionView:)])
        [[self delegate] mouseDownInCompositionView:self];
}
- (void)keyDown:(id)aDown
{
    [super keyDown:aDown];
    if ([[self delegate] respondsToSelector:@selector(keyDownInCompositionView:theEvent:)])
        [[self delegate] keyDownInCompositionView:self theEvent:aDown];
}
@end
