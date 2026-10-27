#import "HyperEditorBasePrefix.h"


@interface HSPaletteController : NSObject <NSWindowDelegate, NSObject>
{
    NSPanel *_window;
    NSMutableArray *_storedVisibilityStates;
    BOOL _paletteLocked;
}
+ (id)visibilityKeyForDefaults;
+ (NSRect)adjustFrameToFitVisibleScreenFrame:(NSRect)aFrame;
+ (id)frameAutosaveName;
+ (id)sharedInstance;
+ (void)registerSharedInstanceIfNeeded:(id)aNeeded;
+ (id)cachedSharedInstance;
+ (id)sharedInstancesByClass;
- (void)panel:(id)aPanel saveFrameUsingName:(id)aName;
- (BOOL)panel:(id)aPanel setFrameUsingName:(id)aName;
- (void)windowDidShowRespectingLastVisibilityState:(id)aState;
- (void)windowWillShowRespectingLastVisibilityState:(id)aState;
- (BOOL)windowShouldOrderFrontRespectingLastVisibilityState:(id)aState;
- (void)windowWillHideWithSavingVisibilityState:(id)aState;
- (id)storedVisibilityStates;
- (void)togglePalette;
- (void)setHyperPaletteLocked:(BOOL)aLocked;
- (BOOL)isHyperPaletteLocked;
- (BOOL)validateTogglePaletteUserInterfaceItem:(id)aItem;
- (void)loadNibIfNeeded;
- (void)willCloseWindow;
- (void)didShowWindow;
- (void)willShowWindow;
- (void)didLoadNib;
- (id)nibName;
- (id)windowWillReturnUndoManager:(id)aManager;
- (id)window;
- (void)createWindowIfNeeded;
- (BOOL)paletteShouldBecomeKeyOnlyWhenNeeded;
- (BOOL)windowShouldClose:(id)aClose;
- (BOOL)isPaletteVisible;
- (BOOL)isWindowLoaded;
- (void)windowWillClose:(id)aClose;
- (void)hidePalette;
- (void)showPaletteIfNeededByDefault:(BOOL)aDefault;
- (void)showPalette;
- (void)adjustWindowPositionIfNeeded;
- (void)orderFrontPaletteWindow:(id)aWindow;
- (void)dealloc;
- (id)init;
@end

