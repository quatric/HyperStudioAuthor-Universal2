#import "HyperStudioPrefix.h"


@interface HSObjectListPaletteController : HSValidatedUserInterfacePaletteController
{
    HSKeyboardHandlingView *_containerView;
    id<HSObjectListDataProvider> _dataProvider;
    BOOL _needsDataProvider;
    HSStackObjectListController *_objectListController;
}
- (void)togglePalette;
- (void)showCoachingHintIfNeeded;
- (NSRect)windowWillUseStandardFrame:(id)aFrame defaultFrame:(NSRect)aFrame2;
- (void)mountObjectListController;
- (id)objectListController;
- (void)objectListDataProviderDidChangeTopLevelParent:(id)aParent;
- (BOOL)paletteShouldBecomeKeyOnlyWhenNeeded;
- (void)willCloseWindow;
- (void)didShowWindow;
- (void)setNeedsDataProvider:(BOOL)aProvider;
- (void)setDataProvider:(id)aProvider;
- (id)dataProvider;
- (void)validateUserInterface;
- (void)orderFrontPaletteWindow:(id)aWindow;
- (void)documentDidRemoveFromDocumentController:(id)aController;
- (void)documentWindowDidBecomeMain:(id)aMain;
- (void)documentDidActivateObjectListDataProvider:(id)aProvider;
- (void)windowDidBecomeKey:(id)aKey;
- (void)applicationWillResignActive:(id)aActive;
- (void)applicationDidBecomeActive:(id)aActive;
- (void)didLoadNib;
- (id)nibName;
- (void)dealloc;
@end

