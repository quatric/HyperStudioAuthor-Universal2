#import "HyperPlayerBasePrefix.h"


@interface HSMainWindowController : NSWindowController <NSWindowDelegate, NSObject, HSSheetHandler, HSPreferedUndoManagerOwner, HSCommentsAndAttributionsDataProvider>
{
    EXToolbarController *_toolbarController;
    NSUndoManager *_preferedUndoManager;
    BOOL _activated;
    BOOL _pendingRequestToRefreshMinimalWindowModeSupport;
    BOOL _isNibLoaded;
    BOOL _isBottomToolbarVisible;
}
- (void)updateContentMinSize:(NSSize)aSize forWindow:(id)aWindow animated:(BOOL)aAnimated;
- (NSSize)mainWindowMinCardAreaSize;
- (void)setBottomToolbarVisible:(BOOL)aVisible;
- (BOOL)isBottomToolbarVisible;
- (id)currentActiveStack;
- (id)currentActiveCard;
- (void)saveEditingState;
- (void)runMakeEveryCardNextCardExtra:(id)aExtra;
- (void)alertOnMakeEveryCardNextCardExtraDidEnd:(id)aEnd returnCode:(NSInteger)aCode contextInfo:(void *)aInfo;
- (void)titleCard:(id)aCard;
- (void)documentDidCreateMinimalWindowApplier;
- (void)applyMinimalWindowModeAttributeIfNeeded;
- (id)minimalWindowApplier;
- (BOOL)supportsMinimalWindowMode;
- (void)windowControllerDidBindToWindowInModeSwitcher:(id)aSwitcher;
- (BOOL)shouldDisableAnimationInModeSwitcher:(id)aSwitcher;
- (void)didBecomeNonWorkingInModeSwitcher:(id)aSwitcher;
- (void)didBecomeWorkingInModeSwitcher:(id)aSwitcher;
- (void)willBecomeWorkingInModeSwitcher:(id)aSwitcher;
- (void)willBecameNonWorkingInModeSwitcher:(id)aSwitcher;
- (BOOL)modeControllerSupportsMinimalWindowMode:(id)aMode withModeSwitcher:(id)aSwitcher;
- (id)secondaryModeSwitcherWindows:(id)aWindows;
- (id)mainModeSwitcherWindow:(id)aWindow;
- (id)sheetWindow;
- (BOOL)isSheetRunning;
- (NSRect)windowWillUseStandardFrame:(id)aFrame defaultFrame:(NSRect)aFrame2;
- (NSSize)windowFrameSizeAdjustedToCurrentContent;
- (void)windowWillClose:(id)aClose;
- (void)windowDidResize:(id)aResize;
- (void)windowDidBecomeMain:(id)aMain;
- (void)notifyWillClose:(id)aClose;
- (void)notifyDidBecomeMain:(id)aMain;
- (void)documentCurrentStackDidChange:(id)aChange;
- (void)documentCurrentStackWillChange:(id)aChange;
- (void)setDocument:(id)aDocument;
- (void)attachToStackAndUpdateView;
- (void)attachToStack;
- (void)detachFromStack;
- (id)cardViewContainer;
- (NSRect)constrainSizeOfWindowFrame:(NSRect)aFrame forScreen:(id)aScreen;
- (void)adjustWindowFrame;
- (NSRect)bestWindowFrameForCurrentStack;
- (void)didEndModalWindow:(id)aWindow;
- (void)willRunModalWindow:(id)aWindow;
- (void)windowDidEndSheet:(id)aSheet;
- (void)windowWillBeginSheet:(id)aSheet;
- (void)updateAlternateGoToHomeMenuItemToTemporaryKeyEquivalent:(BOOL)aEquivalent;
- (BOOL)cancelOperation;
- (id)playerSettingsDataSource;
- (id)windowTitleForDocumentDisplayName:(id)aName;
- (void)synchronizeWindowTitleWithDocumentName;
- (void)activateOnLoad;
- (void)windowDidLoad;
- (void)loadWindow;
- (void)didBindToModelOnLoad;
- (void)bindToModelOnLoad;
- (void)willBindToModelOnLoad;
- (void)stackDidChangeAttributes:(id)aAttributes;
- (BOOL)needsHelpCoachingHintForObject:(id)aObject;
- (void)nodeContainer:(id)aContainer didRemoveChildren:(id)aChildren;
- (void)nodeContainer:(id)aContainer didAddChild:(id)aChild;
- (void)nodeContentsDidChange:(id)aChange affectedChildren:(id)aChildren;
- (void)setCardViewFrame:(NSRect)aFrame;
- (void)setActiveCard:(id)aCard;
- (id)activeCard;
- (id)cardView;
- (id)stackView;
- (id)preferedUndoManager;
- (void)setPreferedUndoManager:(id)aManager;
- (id)windowNibName;
- (void)dealloc;
- (void)awakeFromNib;
- (id)init;
- (void)setupBottomToolbar;
- (void)setToolbarController:(id)aController;
- (id)toolbarController;
@end

@interface HSMainWindowController (HSSelectionHolderDelegate)
- (id)stackView;
- (void)cardView:(id)aView :(id)aArg;
@end

@interface HSMainWindowController (HSMainWindowControllerCreation)
+ (id)mainWindowController;
@end

@interface HSMainWindowController (IBActions)
- (void)toggleContinuousSpellChecking:(id)aChecking;
- (void)customizeToolbar:(id)aToolbar;
- (void)hideShowToolbar:(id)aToolbar;
- (BOOL)validateUserInterfaceItem:(id)aItem;
- (id)navigationController;
@end

@interface NSWindow (NSWindowPrivate)
- (void)hyperMakeNonTransparent;
- (void)hyperMakeTransparent;
@end

