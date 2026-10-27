#import "HyperStudioPrefix.h"


@interface HSToolPaletteController : HSValidatedUserInterfacePaletteController <NSWindowDelegate, NSObject, HSToolSettingsViewControllerParent>
{
    NSView *_playerEditorButtonsView;
    HSToolsPaletteContentView *_contentView;
    NSButton *_closeButton;
    HSImageView *_buttonsView;
    HSDoubleActionButton *_arrowButton;
    NSButton *_collapseExpandDrawerButton;
    HSFlatLiveSlider *_flatLiveSlider;
    NSView *_flatToolButtonsView;
    NSView *_liveToolButtonsView;
    NSView *_currentToolButtonsView;
    NSDictionary *_toolSettingsViewContainers;
    HSToolSettingsViewController *_activeToolSettingsViewController;
    BOOL _lastClickDidChangeTool;
    BOOL _drawerPrefersToBeOpen;
}
- (void)assignDoubleActions;
- (id)activeToolSettingsViewController;
- (void)closeDrawer:(id)aDrawer;
- (void)openDrawer:(id)aDrawer;
- (void)switchToolTypes:(id)aTypes;
- (void)switchToolAndSelectAllArea:(id)aArea;
- (void)switchToolAndShowDrawer:(id)aDrawer;
- (void)switchTool:(id)aTool;
- (void)validatePaletteItem:(id)aItem;
- (void)changeDrawerHeightTo:(CGFloat)aTo;
- (void)activeToolDidChange:(id)aChange;
- (void)activeToolWillChange:(id)aChange;
- (void)validateToolPalette;
- (void)validateShowHideDrawerButton;
- (void)mountToolSettingsViewController:(id)aController withToolManager:(id)aManager;
- (void)unmountActiveToolSettingsViewController;
- (id)toolSettingsViewControllerForToolTag:(NSInteger)aTag;
- (id)toolSettingsViewContainerToToolIdentifierMap;
- (void)didLoadNib;
- (void)mountToolButtonsView:(id)aView;
- (id)window;
- (void)validateUserInterfaceWithView:(id)aView;
- (void)validateUserInterface;
- (void)validateView:(id)aView;
- (id)nibName;
- (void)dealloc;
- (void)appWillOpenModalWindow:(id)aWindow;
@end

