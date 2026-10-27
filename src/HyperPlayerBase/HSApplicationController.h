#import "HyperPlayerBasePrefix.h"
#import "EXDocumentController.h"


@interface HSApplicationController : EXDocumentController <HSAnythingSelectionAccessor, HSStackSelectionAccessor, HSSelectionAccessor, NSObject, HSCardSelectionAccessor, HSCardObjectSelectionAccessor, NSMenuDelegate>
{
    id _toggleBrowseEditModeMenuItem;
    id _storyboardView;
    id _bringToFrontMenuItem;
    id _sendToBackMenuItem;
    id _backMenuItem;
    id _forwardMenuItem;
    id _nextCardMenuItem;
    id _previousCardMenuItem;
    BOOL _ignoreVersioning;
    BOOL _resolvingError;
    BOOL _wasWindowRestoration:1;
    HSMainWindowController *_sharedMainWindowController;
    BOOL _appModalEULADialogIsShowing;
    HSAHTML5ExportCompatibilityChecker *_exportCompatibilityChecker;
}
+ (id)buildVersionString;
+ (void)restoreWindowWithIdentifier:(id)aIdentifier state:(id)aState completionHandler:(id /* block */)aHandler;
- (BOOL)hasPlayerDocuments;
- (BOOL)shouldCancelWindowRestoration;
- (BOOL)applicationOpenUntitledFile:(id)aFile;
- (BOOL)applicationShouldOpenUntitledFile:(id)aFile;
- (BOOL)isModalSessionPresent;
- (BOOL)resolvingError;
- (void)setResolvingError:(BOOL)aError;
- (BOOL)ignoreVersioning;
- (void)setIgnoreVersioning:(BOOL)aVersioning;
- (void)presentError:(id)aError modalForWindow:(id)aWindow delegate:(id)aDelegate didPresentSelector:(SEL)aSelector contextInfo:(void *)aInfo;
- (BOOL)presentError:(id)aError;
- (void)document:(id)aDocument shouldClose:(BOOL)aClose contextInfo:(void *)aInfo;
- (void)applicationWillTerminate:(id)aTerminate;
- (void)applicationDidFinishLaunching:(id)aLaunching;
- (void)applicationWillFinishLaunching:(id)aLaunching;
- (id)applicationDefaults;
- (void)HSApplicationController_unregister3IVXComponent;
- (void)HSApplicationController_initializeQuartzComposerFramework;
- (BOOL)isStackToGoController;
- (id)openDocument:(id)aDocument inWindowOfDocument:(id)aDocument2 error:(id *)aError;
- (id)openDocumentWithContentsOfURL:(id)aURL inWindowOfDocument:(id)aDocument error:(id *)aError;
- (void)applicationDidReplaceDocumentWithDocument:(id)aDocument;
- (id)sharedMainWindowController;
- (void)sharedMainWindowControllerHandled;
- (void)removeDocument:(id)aDocument;
- (id)typeForContentsOfURL:(id)aURL error:(id *)aError;
- (id)readableFileExtensions;
- (BOOL)areDocumentSpecificPresentationSettingsActive;
- (BOOL)supportsHomeStack;
- (BOOL)isMultiDocument;
- (void)validateMenuShortcuts;
- (NSInteger)runModalOpenPanel:(id)aPanel forTypes:(id)aTypes;
- (id)selectedHyperObject;
- (Class)defaultNavigationControllerClass;
- (void)dealloc;
- (id)exportCompatibilityChecker;
- (BOOL)isPauseResumeEnabled;
- (void)setWasWindowRestoration:(BOOL)aRestoration;
- (void)startHTML5CompatibilityCheckForDocument:(id)aDocument;
- (void)stopHTML5CompatibilityCheckForDocument;
- (BOOL)wasWindowRestoration;
@end

@interface HSApplicationController (IBActions)
- (void)techSupportForHyperStudio:(id)aStudio;
- (void)registerHyperStudio:(id)aStudio;
- (void)provideHyperStudioFeedback:(id)aFeedback;
- (void)showEULAAppModalDialog;
- (BOOL)restoreParentFolder:(id)aFolder attributes:(id)aAttributes;
- (BOOL)isEULAWasAcceptedInApplicationWithIdentifier:(id)aIdentifier;
- (BOOL)shouldShowEULA;
- (id)EULAStartupStateKey;
- (id)sharedPreferencesWithIdentifier:(id)aIdentifier mutabilityOption:(NSUInteger)aOption path:(id *)aPath;
- (id)pathToSharedPreferencesWithIdentifier:(id)aIdentifier;
- (id)EULAAttributedString;
- (id)EULAVersion;
- (id)EULATitle;
- (id)EULAWindowTitle;
- (id)productName;
- (BOOL)allowProvideHyperStudioFeedback;
- (BOOL)allowOpenDocument;
- (BOOL)allowNewDocument;
- (void)goToHome:(id)aHome;
- (id)openDocumentWithContentsOfURL:(id)aURL display:(BOOL)aDisplay error:(id *)aError;
- (void)performCloseAll:(id)aAll;
- (void)performMiniaturizeAll:(id)aAll;
- (void)showPreferences:(id)aPreferences;
- (void)showHyperAboutBox:(id)aBox;
- (BOOL)validateUserInterfaceItem:(id)aItem;
@end

@interface EXDocumentController (HSExtension)
- (void)setLastDocument:(id)aDocument;
@end

