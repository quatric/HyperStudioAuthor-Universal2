#import "HyperPlayerBasePrefix.h"
#import "HSDocumentUndoWorkaround.h"


@interface HSDocument : HSDocumentUndoWorkaround <HSActionExecutionContextProvider, HyperInterface, NSObject, HSActionExecutionManagerProvider>
{
    HSStack *_stack;
    NSFileWrapper *_resourcesWrapper;
    NSDictionary *_attributes;
    HSJavaScriptController *_scriptController;
    NSString *_fileNameSource;
    NSString *_typeOfAcceptedFile;
    SEL _printingSelector;
    BOOL _dontCenterPrintout;
    BOOL _printAllPages;
    HSNavigationController *_navigationController;
    HSHistoryStack *_historyStack;
    BOOL _needsUpdateSlideshowCache;
    NSString *_imageCachePath;
    NSString *_requiredSlideshowItemType;
    BOOL _loading;
    HSMainWindowController *_mainWindowController;
    HSActionExecutionContext *_actionExecutionContext;
    HSActionExecutionManager *_actionExecutionManager;
    BOOL _suppressAlerts;
    BOOL _isNewAndNotChanged;
    BOOL _isCanceledByUser;
    HSDefaultSavePanelAccessoryViewController *_defaultSavePanelAccessoryViewController;
    NSArray *_documentMedia;
    NSMutableDictionary *_cardThumbnailImages;
    NSMutableDictionary *_cardPreviewImages;
    HSGoToSpecificCardController *_goToCardController;
    unsigned int _isModelDestroyed:1;
    unsigned int _isUndoManagerCreated:1;
}
+ (void)openURL:(id)aURL versionString:(id)aString addPlatformInfo:(BOOL)aInfo addProductName:(BOOL)aName;
+ (id)completeURLStringWithString:(id)aString versionString:(id)aString2 addPlatformInfo:(BOOL)aInfo addProductName:(BOOL)aName;
+ (id)platformInformation;
+ (id)currentDocumentCompatibilityVersion;
+ (id)currentDocumentVersion;
+ (id)minDocumentVersion;
+ (id)maxDocumentCompatibilityVersion;
- (void)openUpdaterLinkAndQuit;
- (id)defaultSavePanelAccessoryViewController;
- (void)awakeFromImporting;
- (void)cleanTemporaryFileAtPath:(id)aPath;
- (void)printOperationDidRun:(id)aRun success:(BOOL)aSuccess contextInfo:(void *)aInfo;
- (NSSize)documentSize;
- (void)setAttributes:(id)aAttributes;
- (void)setResourcesWrapper:(id)aWrapper;
- (void)reloadDocumentMedia;
- (void)clearCaches;
- (id)filenamesMapping;
- (void)hyperDocumentDidRemoveFromDocumentController:(id)aController;
- (void)cleanupResources;
- (void)hyperDocumentWillRemoveFromDocumentController:(id)aController;
- (void)setSuppressAlerts:(BOOL)aAlerts;
- (BOOL)suppressAlerts;
- (id)actionExecutionManager;
- (id)actionExecutionContext;
- (id)newActionExecutionContext;
- (void)goToSpecificCardController:(id)aController goToCardAtIndex:(NSUInteger)aIndex context:(void *)aContext;
- (void)goToHomeWithoutLeaveActions:(id)aActions;
- (void)goToHome:(id)aHome;
- (void)goToSpecificCardWithoutLeaveActions:(id)aActions;
- (void)goToSpecificCard:(id)aCard;
- (void)advanceToNextCardWithoutLeaveActions:(id)aActions;
- (void)goToFirstCardWithoutLeaveActions:(id)aActions;
- (void)goToFirstCard:(id)aCard;
- (void)goToLastCardWithoutLeaveActions:(id)aActions;
- (void)goToLastCard:(id)aCard;
- (void)goToPreviousCardWithoutLeaveActions:(id)aActions;
- (void)goToPreviousCard:(id)aCard;
- (void)goToNextCardWithoutLeaveActions:(id)aActions;
- (void)goToNextCard:(id)aCard;
- (void)goForwardWithoutLeaveActions:(id)aActions;
- (void)goForward:(id)aForward;
- (void)goBackWithoutLeaveActions:(id)aActions;
- (void)goBack:(id)aBack;
- (void)performNavigationWithoutLeaveActions:(SEL)aActions sender:(id)aSender;
- (BOOL)validateUserInterfaceItem:(id)aItem;
- (id)anyCard;
- (id)selectedCards;
- (void)setCurrentCard:(id)aCard;
- (id)currentCard;
- (id)attributeNotificationCenter;
- (void)updateChangeCount:(NSUInteger)aCount;
- (BOOL)isNewAndNotChanged;
- (void)clearChanges;
- (id)auxillaryPath;
- (id)fileNameSource;
- (void)setStack:(id)aStack;
- (void)setStack:(id)aStack notify:(BOOL)aNotify;
- (void)setStack:(id)aStack notify:(BOOL)aNotify clearChanges:(BOOL)aChanges;
- (void)stackProtectionDidChange:(id)aChange;
- (void)postDocumentProtectionDidChange;
- (id)scriptableObjectsIncludingPseudoObjects:(BOOL)aObjects;
- (id)scriptableObjects;
- (void)setTypeOfAcceptedFile:(id)aFile;
- (id)typeOfAcceptedFile;
- (BOOL)loadStackWrapper:(id)aWrapper error:(id *)aError;
- (BOOL)loadResourcesWrapper:(id)aWrapper error:(id *)aError;
- (BOOL)loadProjectAttributesWrapper:(id)aWrapper error:(id *)aError;
- (BOOL)attemptRecoveryFromError:(id)aError optionIndex:(NSUInteger)aIndex;
- (void)attemptRecoveryFromError:(id)aError optionIndex:(NSUInteger)aIndex delegate:(id)aDelegate didRecoverSelector:(SEL)aSelector contextInfo:(void *)aInfo;
- (BOOL)reopenDocumentIgnoringVersioning;
- (BOOL)checkDocumentVersion:(id)aVersion compatibilityVersion:(id)aVersion2 creatorVersion:(id)aVersion3 error:(id *)aError;
- (void)setIgnoreVersioning:(BOOL)aVersioning;
- (BOOL)ignoreVersioning;
- (id)documentCreatorVersion;
- (id)documentCompatibilityVersion;
- (id)documentVersion;
- (BOOL)loadContentsWrapper:(id)aWrapper error:(id *)aError;
- (void)loadCardPreviewImagesWrapper:(id)aWrapper;
- (id)quickLookImageFromFileWrappers:(id)aWrappers cardDictionary:(id)aDictionary forKey:(id)aKey;
- (id)selectedHyperObject;
- (id)stack;
- (id)attributes;
- (id)createDefaultStack;
- (id)createStackNodeWithWrapper:(id)aWrapper error:(id *)aError;
- (id)willPresentError:(id)aError;
- (void)readyToCloseDocument;
- (void)closePlayer;
- (BOOL)isDocumentClosing;
- (void)close;
- (void)loadWindows;
- (void)removeWindowControllers;
- (void)createWindowControllers;
- (void)cleanupWindowControllers;
- (void)showWindows;
- (void)refreshMoviesHiddenStateForCard:(id)aCard;
- (void)canCloseDocumentWithDelegate:(id)aDelegate shouldCloseSelector:(SEL)aSelector contextInfo:(void *)aInfo;
- (void)printShowingPrintPanel:(BOOL)aPanel;
- (void)printDocumentWithSettings:(id)aSettings showPrintPanel:(BOOL)aPanel delegate:(id)aDelegate didPrintSelector:(SEL)aSelector contextInfo:(void *)aInfo;
- (BOOL)hyperReadFromFileWrapper:(id)aWrapper ofType:(id)aType error:(id *)aError;
- (id)hyperFileWrapperOfType:(id)aType error:(id *)aError;
- (void)setFileNameSource:(id)aSource;
- (id)mainDocumentExtensionForType:(id)aType;
- (id)displayName;
- (BOOL)readFromURL:(id)aURL ofType:(id)aType error:(id *)aError;
- (BOOL)revertToContentsOfURL:(id)aURL ofType:(id)aType error:(id *)aError;
- (BOOL)isLoading;
- (void)setLoading:(BOOL)aLoading;
- (void)saveToURL:(id)aURL ofType:(id)aType forSaveOperation:(NSUInteger)aOperation delegate:(id)aDelegate didSaveSelector:(SEL)aSelector contextInfo:(void *)aInfo;
- (void)saveDocumentWithDelegate:(id)aDelegate didSaveSelector:(SEL)aSelector contextInfo:(void *)aInfo;
- (BOOL)prepareSavePanel:(id)aPanel;
- (void)removeWindowController:(id)aController;
- (void)makeWindowControllers;
- (void)loadPrintInfo;
- (id)minimalWindowApplier;
- (id)mainWindowController;
- (void)setMainWindowController:(id)aController;
- (BOOL)isCanceledByUser;
- (BOOL)isModalSessionPresent;
- (BOOL)isWebPlayerDocument;
- (BOOL)isInPurePlayerMode;
- (BOOL)isInPresentationMode;
- (BOOL)isStackProtected;
- (BOOL)isInAnimationMode;
- (BOOL)isInPlayerMode;
- (id)currentWindowController;
- (void)setNavigationController:(id)aController;
- (id)navigationController;
- (id)resourcesWrapper;
- (id)playerCardView;
- (id)cardViewForNavigation;
- (id)cardView;
- (void)takeDataFromDocument:(id)aDocument;
- (void)destoyModel;
- (void)destoryModelIfNeeded;
- (void)dealloc;
- (id)init;
- (id)historyStack;
- (BOOL)isDefaultHomeStack;
- (BOOL)isInViewingMode;
- (BOOL)isPaused;
- (BOOL)isTutorialStack;
- (void)pause;
- (void)resume;
- (void)setHistoryStack:(id)aStack;
+ (BOOL)forceShowSystemErrorForNSError:(id)aError;
@end

@interface HSDocument (CardPreviewImages)
- (void)setPreviewImage:(id)aImage forCard:(id)aCard;
- (id)previewImageForCard:(id)aCard;
- (void)setThumbnailImage:(id)aImage forCard:(id)aCard;
- (id)thumbnailImageForCard:(id)aCard;
- (void)invalidatePreviewImages;
- (id)cardPreviewImages;
- (id)cardThumbnailImages;
@end

@interface HSDocument (HSSlideshowDataSource)
- (void)setRequiredSlideshowItemType:(id)aType;
- (id)requiredSlideshowItemType;
- (void)setNeedsUpdateSlideshowCache:(BOOL)aCache;
- (BOOL)needsUpdateSlideshowCache;
- (void)slideshowDidChangeCurrentIndex:(NSUInteger)aIndex;
- (void)slideshowDidStop;
- (void)slideshowWillStart;
- (BOOL)canExportSlideshowItemAtIndex:(NSUInteger)aIndex toApplication:(id)aApplication;
- (id)nameOfSlideshowItemAtIndex:(NSUInteger)aIndex;
- (id)slideshowItemAtIndex:(NSUInteger)aIndex;
- (NSUInteger)numberOfSlideshowItems;
- (id)imageCachePath;
- (void)setImageCachePath:(id)aPath;
@end

@interface HSDocument (HSMediaAccess)
+ (id)getMediaNameFromItem:(id)aItem;
+ (id)keyForMadiaGroup:(NSInteger)aGroup;
+ (id)userObjectWithMedia:(id)aMedia;
+ (id)userObjectWithMedia:(id)aMedia error:(id *)aError;
+ (id)userObjectWithMedia:(id)aMedia animation:(BOOL)aAnimation error:(id *)aError;
+ (id)userObjectWithAttributedString:(id)aString;
+ (id)imageObjectsWithPDFMedia:(id)aMedia firstPageOnly:(BOOL)aOnly error:(id *)aError;
- (id)userActionWithMedia:(id)aMedia;
- (id)userActionWithMedia:(id)aMedia error:(id *)aError;
@end

@interface HSDocument (IBActions)
- (void)printText:(id)aText;
- (void)printCard:(id)aCard;
@end

@interface HSDocument (HSJavaScriptSupport)
- (id)scriptControllerAllScriptObjects:(id)aObjects;
- (void)scriptController:(id)aController didErrorWithScript:(id)aScript;
- (void)scriptController:(id)aController didFinishWithScript:(id)aScript;
- (void)scriptController:(id)aController didStartWithScript:(id)aScript;
- (void)scriptControllerDidReady:(id)aReady;
- (void)scriptControllerApplicationClose:(id)aClose;
- (void)scriptControllerDocumentClose:(id)aClose;
- (void)scriptController:(id)aController transiteToURL:(id)aURL;
- (void)runNonOwnedAction:(id)aAction;
@end

@interface HSDocument (HSNodeSupport)
- (BOOL)isAttributesNotificationPostingDisabled;
- (id)cardGroupController;
- (id)scriptController;
- (id)delegate;
- (id)undoManager;
@end

