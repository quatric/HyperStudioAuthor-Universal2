#import "HyperPlayerBasePrefix.h"


@interface HSPreferencesController : NSObject <NSToolbarDelegate, NSObject>
{
    NSWindow *_window;
    NSArray *_registeredPaneIdentifiers;
    NSPreferencePane *_selectedPane;
    id _lastSelectedPaneIdentifier;
    unsigned int _indexOfPaneToSwitch;
    BOOL _waitingForClose;
}
+ (id)sharedPreferencesController;
- (BOOL)windowShouldClose:(id)aClose;
- (id)toolbarSelectableItemIdentifiers:(id)aIdentifiers;
- (id)toolbarAllowedItemIdentifiers:(id)aIdentifiers;
- (id)toolbarDefaultItemIdentifiers:(id)aIdentifiers;
- (id)toolbar:(id)aToolbar itemForItemIdentifier:(id)aIdentifier willBeInsertedIntoToolbar:(BOOL)aToolbar2;
- (id)iconForPaneFromBundle:(id)aBundle;
- (void)updateWindowTitle;
- (id)labelForPaneFromBundle:(id)aBundle;
- (void)preferencePaneCancelUnselect:(id)aUnselect;
- (void)preferencePaneDoUnselect:(id)aUnselect;
- (void)showPreferencePaneHelp:(id)aHelp;
- (void)switchPane:(id)aPane;
- (void)showWindow:(id)aWindow;
- (void)orderFront:(id)aFront;
- (void)loadUI;
- (void)setupUI;
- (void)switchToPaneWithIdentifier:(id)aIdentifier;
- (BOOL)deselectPaneForSwitchingToPaneWithBundle:(id)aBundle;
- (void)selectAndMountPreferencePane:(id)aPane;
- (id)preferencesControllerWindow;
- (id)contentView;
- (id)window;
- (void)registerPreferencePanes;
- (id)orderedPanes;
- (id)preferencePaneResourceFolder;
- (id)preferencePaneExtension;
- (id)toolbarIdentifier;
- (id)windowNibName;
- (id)localizedWindowTitle;
- (id)localizedPreferencePaneNamesTable;
- (id)nameForPreferencePanesOrderResource;
- (void)dealloc;
- (id)init;
@end

