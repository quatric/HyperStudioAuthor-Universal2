#import "HyperPlayerBasePrefix.h"
#import "HSWindow.h"


@interface HSFullScreenBorderlessWindow : HSWindow
{
}
- (void)cancelOperation:(id)aOperation;
- (NSRect)constrainFrameRect:(NSRect)aRect toScreen:(id)aScreen;
- (BOOL)isExcludedFromWindowsMenu;
- (BOOL)canBecomeMainWindow;
- (BOOL)canBecomeKeyWindow;
- (id)initWithContentRect:(NSRect)aRect styleMask:(NSUInteger)aMask backing:(NSUInteger)aBacking defer:(BOOL)aDefer screen:(id)aScreen;
@end

@interface HSBorderlessWindow : NSWindow <NSUserInterfaceValidations>
{
}
- (void)document:(id)aDocument shouldClose:(BOOL)aClose contextInfo:(void *)aInfo;
- (void)performClose:(id)aClose;
- (BOOL)validateUserInterfaceItem:(id)aItem;
- (BOOL)isExcludedFromWindowsMenu;
- (void)keyDown:(id)aDown;
- (BOOL)canBecomeMainWindow;
- (BOOL)canBecomeKeyWindow;
- (id)initWithContentRect:(NSRect)aRect styleMask:(NSUInteger)aMask backing:(NSUInteger)aBacking defer:(BOOL)aDefer screen:(id)aScreen;
@end

