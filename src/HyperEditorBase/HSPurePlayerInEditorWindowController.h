#import "HyperEditorBasePrefix.h"
#import "HSPlayerInEditorWindowController.h"


@interface HSPurePlayerInEditorWindowController : HSPlayerInEditorWindowController
{
    HSPlayerSettingsDataSource *_playerSettingsDataSource;
}
- (void)preferencesSettingsDidChange:(id)aChange;
- (BOOL)isBackgroundGraphics;
- (BOOL)isMenuShown;
- (BOOL)isTitlebarDisabled;
- (BOOL)isFullScreen;
- (id)playerSettingsDataSource;
- (void)setPlayerSettingsDataSource:(id)aSource;
- (void)handleWindowDidLoad;
- (void)verifyWindowScreen;
- (void)cancelOperation:(id)aOperation;
- (BOOL)cancelOperation;
- (void)showStackOptionsDialog:(id)aDialog;
- (BOOL)validateUserInterfaceItemThatRequiresSwitchToEditMode:(id)aMode;
- (BOOL)validateUserInterfaceItem:(id)aItem;
- (void)didBecomeWorkingInModeSwitcher:(id)aSwitcher;
- (void)willBecomeWorkingInModeSwitcher:(id)aSwitcher;
- (void)stackDidChangeBackgroundAttributes:(id)aAttributes;
- (void)setupUIMode;
- (void)coverDesktopAttributesDidChange;
- (void)verifyWindowMode;
- (void)attachToStack;
- (void)detachFromStack;
- (id)windowScreen;
- (void)dealloc;
- (void)windowDidLoad;
@end

