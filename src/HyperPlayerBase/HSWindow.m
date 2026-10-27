#import "HSWindow.h"
#import <objc/message.h>
@implementation HSWindow
- (void)toggleToolbarShown:(id)aShown
{
    [super toggleToolbarShown:aShown];
    [self HSWindow_notifyToggleToolbarShown];
}
// The toolbar pill button (gone since macOS 11; kept for any private caller).
// Before Leopard it didn't go through -toggleToolbarShown:, so the delegate
// was told here; HSSystem's isLeopardOrGreater is always true now.
- (void)_toolbarPillButtonClicked:(id)aClicked
{
    if ([NSEWindow instancesRespondToSelector:_cmd]) {
        struct objc_super superclass = { self, [NSEWindow class] };
        ((void (*)(struct objc_super *, SEL, id))objc_msgSendSuper)(&superclass, _cmd, aClicked);
    }
    if (![[HSSystem sharedSystem] isLeopardOrGreater])
        [self HSWindow_notifyToggleToolbarShown];
}
// The delegate can veto mouse/tablet events (-hyperWindow:shouldSendLocationEvent:,
// checked to have the BOOL (id, id) signature).
- (void)sendEvent:(id)aEvent
{
    if ([aEvent BT_hasLocation]) {
        id delegate = [self delegate];
        SEL selector = @selector(hyperWindow:shouldSendLocationEvent:);
        NSMethodSignature *signature = [delegate respondsToSelector:selector] ? [delegate methodSignatureForSelector:selector] : nil;
        if (signature != nil && strcmp([signature methodReturnType], @encode(BOOL)) == 0
            && strcmp([signature getArgumentTypeAtIndex:2], "@") == 0
            && strcmp([signature getArgumentTypeAtIndex:3], "@") == 0
            && ![delegate hyperWindow:self shouldSendLocationEvent:aEvent])
            return;
    }
    [super sendEvent:aEvent];
}
// Undo/redo are validated by the delegate; Minimize only while the menu bar
// shows.
- (BOOL)validateUserInterfaceItem:(id)aItem
{
    BOOL valid = [super validateUserInterfaceItem:aItem];
    if (!valid)
        return NO;
    SEL action = [(id<NSValidatedUserInterfaceItem>)aItem action];
    if (action == @selector(undo:) || action == @selector(redo:))
        return [(id)[self delegate] validateUserInterfaceItem:aItem];
    if (action == @selector(miniaturize:))
        return [[HSSystemUI sharedSystemUI] menuBarVisible];
    return valid;
}
- (void)HSWindow_notifyToggleToolbarShown
{
    id delegate = [self delegate];
    NSMethodSignature *signature = [delegate methodSignatureForSelector:@selector(hyperWindowDidToggleToolbar:)];
    if (signature != nil && strcmp([signature getArgumentTypeAtIndex:2], "@") == 0)
        [delegate hyperWindowDidToggleToolbar:self];
}
@end
