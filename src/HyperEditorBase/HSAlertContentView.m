#import "HSAlertContentView.h"

@implementation HSAlertContentView

// Escape presses the default button (whatever it is) instead of cancelling.
- (BOOL)performKeyEquivalent:(id)aEquivalent
{
    NSEvent *event = aEquivalent;
    if ([event type] == NSEventTypeKeyDown && [event keyCode] == 0x35) {
        NSButtonCell *cell = [[self window] defaultButtonCell];
        [(NSControl *)[cell controlView] sendAction:[cell action] to:[cell target]];
        return NO;
    }
    return [super performKeyEquivalent:aEquivalent];
}

@end
