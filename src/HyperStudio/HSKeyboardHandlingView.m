#import "HSKeyboardHandlingView.h"

@implementation HSKeyboardHandlingView

- (void)doCommandBySelector:(SEL)aSelector
{
    if ([_delegate respondsToSelector:@selector(keyboardHandlingView:doCommandBySelector:)])
        _didHandleKeyEvent = [_delegate keyboardHandlingView:self doCommandBySelector:aSelector];
}

- (void)keyDown:(id)aDown
{
    _didHandleKeyEvent = NO;
    [self interpretKeyEvents:[NSArray arrayWithObject:aDown]];
    if (!_didHandleKeyEvent)
        [super keyDown:aDown];
}

- (void)setDelegate:(id)aDelegate
{
    _delegate = aDelegate;
}

- (id)delegate
{
    return _delegate;
}

@end
