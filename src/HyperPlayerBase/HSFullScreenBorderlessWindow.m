#import "HSFullScreenBorderlessWindow.h"
// Borderless windows. The full screen window always covers its screen
// (or its parent window's screen). The plain borderless window is
// transparent, can be dragged by its background, and asks its document
// before closing.

@implementation HSFullScreenBorderlessWindow

// Escape is passed to the window controller as -cancelOperation, without
// an argument.
- (void)cancelOperation:(id)aOperation
{
    id controller = [self windowController];
    if ([controller respondsToSelector:@selector(cancelOperation)])
        [controller performSelector:@selector(cancelOperation)];
}

- (NSRect)constrainFrameRect:(NSRect)aRect toScreen:(id)aScreen
{
    if (!aScreen)
        aScreen = [[self parentWindow] screen];
    if (aScreen)
        [self setFrame:[aScreen frame] display:[self isVisible]];
    return [self frame];
}

- (BOOL)isExcludedFromWindowsMenu
{
    return YES;
}

- (BOOL)canBecomeMainWindow
{
    return YES;
}

- (BOOL)canBecomeKeyWindow
{
    return YES;
}

- (id)initWithContentRect:(NSRect)aRect styleMask:(NSUInteger)aMask backing:(NSUInteger)aBacking defer:(BOOL)aDefer screen:(id)aScreen
{
    self = [super initWithContentRect:aRect styleMask:aMask backing:aBacking defer:aDefer screen:aScreen];
    if (self)
        [self setMovableByWindowBackground:NO];
    return self;
}

@end

@implementation HSBorderlessWindow

- (void)document:(id)aDocument shouldClose:(BOOL)aClose contextInfo:(void *)aInfo
{
    if (aClose)
        [self close];
}

- (void)performClose:(id)aClose
{
    [[[self windowController] document] canCloseDocumentWithDelegate:self shouldCloseSelector:@selector(document:shouldClose:contextInfo:) contextInfo:NULL];
}

// Undo and redo are the window's own; everything else asks the delegate.
- (BOOL)validateUserInterfaceItem:(id)aItem
{
    SEL action = [(id<NSValidatedUserInterfaceItem>)aItem action];
    if (action == @selector(undo:) || action == @selector(redo:))
        return [super validateUserInterfaceItem:aItem];
    return [(id)[self delegate] validateUserInterfaceItem:aItem];
}

- (BOOL)isExcludedFromWindowsMenu
{
    return NO;
}

- (void)keyDown:(id)aDown
{
    [self interpretKeyEvents:[NSArray arrayWithObject:aDown]];
    [super keyDown:aDown];
}

- (BOOL)canBecomeMainWindow
{
    return YES;
}

- (BOOL)canBecomeKeyWindow
{
    return YES;
}

- (id)initWithContentRect:(NSRect)aRect styleMask:(NSUInteger)aMask backing:(NSUInteger)aBacking defer:(BOOL)aDefer screen:(id)aScreen
{
    self = [super initWithContentRect:aRect styleMask:aMask backing:aBacking defer:aDefer screen:aScreen];
    if (self) {
        [self setOpaque:NO];
        [self setMovableByWindowBackground:YES];
    }
    return self;
}

@end
