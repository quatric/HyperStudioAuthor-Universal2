#import "HSObjectAssistantWindow.h"

@implementation HSObjectAssistantWindow

- (void)doCommandBySelector:(SEL)aSelector
{
    if ([[self delegate] respondsToSelector:@selector(window:doCommandBySelector:)])
        _didHandleKeyDown = [(id)[self delegate] window:self doCommandBySelector:aSelector];
}

// Key commands go to the delegate first, through the key bindings.
- (void)keyDown:(id)aDown
{
    _didHandleKeyDown = NO;
    [self interpretKeyEvents:[NSArray arrayWithObject:aDown]];
    if (!_didHandleKeyDown)
        [super keyDown:aDown];
}

- (void)keyUp:(id)aUp
{
    [[[[NSApplication sharedApplication] mainWindow] firstResponder] keyUp:aUp];
}

// Escape is offered to the content view's key equivalents first.
- (void)sendEvent:(id)aEvent
{
    if ([(NSEvent *)aEvent type] == NSEventTypeKeyDown && [(NSEvent *)aEvent keyCode] == 0x35 && [[self contentView] performKeyEquivalent:aEvent])
        return;
    [super sendEvent:aEvent];
}

- (NSUInteger)styleMask
{
    return [super styleMask] | NSWindowStyleMaskNonactivatingPanel;
}

- (BOOL)canBecomeKeyWindow
{
    return YES;
}

@end
