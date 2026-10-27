#import "HSPurePlayerInEditorWindowController.h"

// The player mode window of the pure player (and presentation) mode,
// set up by the player settings and kept on its screen.

@implementation HSPurePlayerInEditorWindowController

- (void)preferencesSettingsDidChange:(id)aChange
{
    [super adjustWindowFrame];
    [self setupUIMode];
}

- (BOOL)isBackgroundGraphics
{
    BOOL isBackgroundGraphics = [super isBackgroundGraphics];
    if (_playerSettingsDataSource != nil)
        isBackgroundGraphics = [[self playerSettingsDataSource] backgroundGraphics] != nil;
    return isBackgroundGraphics;
}

- (BOOL)isMenuShown
{
    BOOL isMenuShown = [super isMenuShown];
    if (_playerSettingsDataSource != nil)
        isMenuShown = [[self playerSettingsDataSource] isMenuShown];
    return isMenuShown;
}

- (BOOL)isTitlebarDisabled
{
    BOOL isTitlebarDisabled = [super isTitlebarDisabled];
    if (_playerSettingsDataSource != nil)
        isTitlebarDisabled = [[self playerSettingsDataSource] isTitlebarDisabled];
    return isTitlebarDisabled;
}

- (BOOL)isFullScreen
{
    BOOL isFullScreen = [super isFullScreen];
    if (_playerSettingsDataSource != nil)
        isFullScreen = [[self playerSettingsDataSource] isFullScreen];
    return isFullScreen;
}

- (id)playerSettingsDataSource
{
    return _playerSettingsDataSource;
}

- (void)setPlayerSettingsDataSource:(id)aSource
{
    if (_playerSettingsDataSource == aSource)
        return;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:HSUIModeSettingsDidChangeNotification object:nil];
    [_playerSettingsDataSource release];
    _playerSettingsDataSource = [aSource retain];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(preferencesSettingsDidChange:) name:HSUIModeSettingsDidChangeNotification object:[HSUI sharedUI]];
}

- (void)handleWindowDidLoad
{
    [self verifyWindowScreen];
    [super handleWindowDidLoad];
}

// Fits the window in its screen, centered.
- (void)verifyWindowScreen
{
    NSWindow *window = [self window];
    NSRect visibleFrame = [[self windowScreen] visibleFrame];
    NSRect frame = [window frame];
    frame.size.width = MIN(frame.size.width, visibleFrame.size.width);
    frame.size.height = MIN(frame.size.height, visibleFrame.size.height);
    frame.origin.x = visibleFrame.origin.x + (visibleFrame.size.width - frame.size.width) * 0.5;
    frame.origin.y = visibleFrame.origin.y + (visibleFrame.size.height - frame.size.height) * 0.5;
    [window setFrame:frame display:YES];
}

// Escape leaves the pure player (or presentation) mode.
- (void)cancelOperation:(id)aOperation
{
    id document = [self document];
    if ([document isInPurePlayerMode] || [document isInPresentationMode])
        [document exitPurePlayerModeWithAnimation:YES];
}

- (BOOL)cancelOperation
{
    [self cancelOperation:nil];
    return YES;
}

- (void)showStackOptionsDialog:(id)aDialog
{
    [(id)[self document] performActionThatRequiresSwitchToEditMode:_cmd sender:aDialog];
}

// A protected stack allows the stack options only.
- (BOOL)validateUserInterfaceItemThatRequiresSwitchToEditMode:(id)aMode
{
    id document = [self document];
    if ([document isStackProtected])
        return [(id<NSValidatedUserInterfaceItem>)aMode action] == @selector(showStackOptionsDialog:);
    return [document validateUserInterfaceItemThatRequiresSwitchToEditMode:aMode];
}

- (BOOL)validateUserInterfaceItem:(id)aItem
{
    SEL action = [(id<NSValidatedUserInterfaceItem>)aItem action];
    if (action == @selector(showStackOptionsDialog:))
        return [(id)[self document] isStackProtected];
    if (action == @selector(hideShowToolbar:) || action == @selector(customizeToolbar:))
        return NO;
    return [super validateUserInterfaceItem:aItem];
}

- (void)didBecomeWorkingInModeSwitcher:(id)aSwitcher
{
    [super didBecomeWorkingInModeSwitcher:aSwitcher];
    if ([self window] != nil) {
        [self verifyWindowScreen];
        [self adjustWindowFrame];
    }
    [self setupUIMode];
    [[HSBackgroundWindowController backgroundWindowController] validateAndDisplay:YES onScreen:[self windowScreen]];
}

- (void)willBecomeWorkingInModeSwitcher:(id)aSwitcher
{
    if (NSAppKitVersionNumber >= 1138.0)
        [self setupUIMode];
    [self verifyWindowScreen];
    [super willBecomeWorkingInModeSwitcher:aSwitcher];
}

- (void)stackDidChangeBackgroundAttributes:(id)aAttributes
{
    if ([self window] != nil)
        [[HSBackgroundWindowController backgroundWindowController] validateAndDisplay:YES onScreen:[self windowScreen]];
}

// Hides the system UI unless the pure player shows the menu.
- (void)setupUIMode
{
    id document = [self document];
    if ([document currentWindowController] != self)
        return;
    BOOL hides = ![document isInPurePlayerMode] || ![self isMenuShown];
    [[HSSystemUI sharedSystemUI] setupWithMode:hides ? 3 : 0 options:hides ? 1 : 0];
}

- (void)coverDesktopAttributesDidChange
{
    if ([(id)[self document] currentWindowController] == self)
        [super coverDesktopAttributesDidChange];
}

- (void)verifyWindowMode
{
    if ([(id)[self document] currentWindowController] == self)
        [super verifyWindowMode];
}

- (void)attachToStack
{
    [super attachToStack];
    [[(id)[self document] stack] addObserver:self selector:@selector(stackDidChangeBackgroundAttributes:) ofChanges:HSActualDidAttributeChanges ofAttributesOfHyperInterface:@protocol(HSBackgroundAttributes) withPriority:-0.25];
}

- (void)detachFromStack
{
    [[(id)[self document] stack] removeObserver:self selector:@selector(stackDidChangeBackgroundAttributes:) ofChanges:HSActualDidAttributeChanges ofAttributesOfHyperInterface:@protocol(HSBackgroundAttributes)];
    [super detachFromStack];
}

// The screen of the other mode's window (the main one if none).
- (id)windowScreen
{
    id switcher = [(id)[self document] modeSwitcher];
    NSWindow *window;
    if ([switcher activeModeController] == self)
        window = [[switcher previousModeController] window];
    else
        window = [[switcher activeModeController] window];
    NSScreen *screen = [window screen];
    if (screen == nil)
        screen = [NSScreen mainScreen];
    return screen;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_playerSettingsDataSource release];
    [super dealloc];
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    [[self window] setCollectionBehavior:0];
}

- (void)windowWillClose:(id)aNotification
{
    [super windowWillClose:aNotification];
}

- (NSRect)frameForDisplayingPause
{
    return [[[self window] contentView] frame];
}

@end
