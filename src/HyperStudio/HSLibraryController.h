#import "HyperStudioPrefix.h"


@interface HSLibraryController : NSWindowController <NSWindowDelegate, NSObject, NSToolbarDelegate, NSMenuDelegate>
{
    NSBox *_mainView;
    HSSegmentedControl *_segmentedControl;
    NSImageView *_statusBarImage;
    NSButton *_playButton;
    NSSearchField *_searchField;
    NSTextField *_infoTextField;
    id _selectedToolbarItem;
    NSString *_selectedSearchCategory;
    NSMutableDictionary *_libraryPanels;
    id<HSLibraryViewContainer> _activeViewContainer;
    NSImage *_playButtonImage;
    NSImage *_playButtonAquaImage;
    NSImage *_playButtonGraphiteImage;
    NSImage *_stopButtonImage;
    NSImage *_stopButtonAquaImage;
    NSImage *_stopButtonGraphiteImage;
    HSAppearanceButtonCell *_playButtonCell;
    NSMutableArray *_storedVisibilityStates;
}
+ (id)allocWithZone:(NSZone *)aZone;
+ (id)sharedLibraryController;
+ (id)visibilityKeyForDefaults;
- (BOOL)windowShouldOrderFrontRespectingLastVisibilityState:(id)aState;
- (void)windowWillHideWithSavingVisibilityState:(id)aState;
- (id)storedVisibilityStates;
- (id)windowWillReturnUndoManager:(id)aManager;
- (BOOL)validateMenuItem:(id)aItem;
- (void)segmentedControlDidChange:(id)aChange;
- (void)libraryPlayingStateDidChange:(id)aChange;
- (void)libraryNumberOfItemsDidChange:(id)aChange;
- (void)setImagesForPlayButton:(BOOL)aButton;
- (void)updateInfoTextField;
- (void)filter:(id)aFilter;
- (void)stopPlaying;
- (void)playSelection:(id)aSelection;
- (void)panelSwitched:(id)aSwitched;
- (void)pluginSwitched:(id)aSwitched;
- (id)panelForType:(id)aType inPluginLibraryType:(id)aType2;
- (id)currentPluginLibraryPanel;
- (id)currentPluginLibraryPanelType;
- (id)currentPluginLibraryType;
- (void)switchToPluginWithLibraryType:(id)aType panelType:(id)aType2;
- (void)updatePanels;
- (BOOL)switchToNextAccessiblePanel;
- (NSInteger)tagOfPanelWithType:(id)aType forPluginIdentifier:(id)aIdentifier;
- (void)setActivePanelTag:(NSInteger)aTag forPluginIdentifier:(id)aIdentifier;
- (NSInteger)activePanelTagForPluginIdentifier:(id)aIdentifier;
- (id)toolbarSelectableItemIdentifiers:(id)aIdentifiers;
- (id)toolbarAllowedItemIdentifiers:(id)aIdentifiers;
- (id)toolbarDefaultItemIdentifiers:(id)aIdentifiers;
- (id)toolbar:(id)aToolbar itemForItemIdentifier:(id)aIdentifier willBeInsertedIntoToolbar:(BOOL)aToolbar2;
- (BOOL)isLibraryVisible;
- (void)hideLibrary;
- (void)hideLibraryWithSaveToDefaults:(BOOL)aSave;
- (void)showLibraryIfNeededByDefault:(BOOL)aDefault;
- (void)showLibrary;
- (BOOL)windowShouldClose:(id)aClose;
- (void)windowWillClose:(id)aClose;
- (void)windowDidLoad;
- (void)awakeFromNib;
- (id)autorelease;
- (void)release;
- (NSUInteger)retainCount;
- (id)retain;
- (id)copyWithZone:(NSZone *)aZone;
- (id)init;
- (void)dealloc;
- (void)documentWindowDidBecomeMain:(id)aMain;
@end

