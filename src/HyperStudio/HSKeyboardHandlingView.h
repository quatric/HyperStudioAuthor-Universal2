#import "HyperStudioPrefix.h"


@interface HSKeyboardHandlingView : NSView
{
    id _delegate;
    BOOL _didHandleKeyEvent;
}
- (void)doCommandBySelector:(SEL)aSelector;
- (void)keyDown:(id)aDown;
- (void)setDelegate:(id)aDelegate;
- (id)delegate;
@end

