#import "HyperStudioPrefix.h"


@interface HSObjectAssistantWindow : NSPanel
{
    BOOL _didHandleKeyDown;
}
- (void)doCommandBySelector:(SEL)aSelector;
- (void)keyDown:(id)aDown;
- (void)keyUp:(id)aUp;
- (void)sendEvent:(id)aEvent;
- (NSUInteger)styleMask;
- (BOOL)canBecomeKeyWindow;
- (void)setLevel:(NSInteger)aLevel;
@end

