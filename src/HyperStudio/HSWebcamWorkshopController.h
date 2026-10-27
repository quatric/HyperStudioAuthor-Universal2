#import "HyperStudioPrefix.h"


@interface HSWebcamWorkshopController : NSObject <HSControlWebCamViewDelegateProtocol, NSTableViewDelegate, NSControlTextEditingDelegate, NSObject>
{
    id _delegate;
    NSWindow *_sheetPanel;
    NSSegmentedControl *_segmentedControl;
    NSButton *_confirmButton;
    NSButton *_cancelButton;
    NSSearchField *_filterField;
    NSMenu *_filterRulesMenu;
    NSTextField *_sheetPanelTitleTextField;
    HSColoredDividerSplitView *_splitView;
    NSOutlineView *_outlineView;
    NSTableView *_webCamContainerView;
    NSTextField *_webCamContainerViewCounterTextField;
    NSTextField *_webCamInfoNameTextField;
    NSTextField *_webCamInfoExactLocationTextField;
    NSTextField *_webCamInfoGeneralLocationTextField;
    NSTextField *_webCamInfoFrameRateTextField;
    NSTextField *_webCamInfoSizeTextField;
    NSTextField *_webCamInfoTimeTextField;
    NSTextField *_webCamInfoCopyrightTextField;
    HSControlWebCamView *_webCamPreviewView;
    NSButton *_addToFavouritesButton;
    NSMutableDictionary *_categoryItemsCache;
    NSArray *_selectedCamIDs;
    NSAttributedString *_shortInfoTemplate;
    NSRect _webCamContainerViewFrame;
    NSTimer *_outlineSelectionChangeTimer;
    NSTimer *_webCamViewSelectionChangeTimer;
    NSTimer *_webCamViewScrollTimer;
    NSSet *_webCamViewVisibleCams;
    HSWebCamImageLoader *_webCamImageLoader;
    HSProgressPlaceholderView *_placeholderView;
    int _currentFilterRuleTag;
}
- (void)performReportError:(id)aError;
- (void)reportError:(id)aError;
- (id)applicationSupportFolder;
- (void)webcamImageLoaded:(id)aLoaded;
- (id)webCamImageLoader;
- (id)tableView:(id)aView toolTipForCell:(id)aCell rect:(NSRect *)aRect tableColumn:(id)aColumn row:(NSInteger)aRow mouseLocation:(NSPoint)aLocation;
- (id)tableView:(id)aView objectValueForTableColumn:(id)aColumn row:(NSInteger)aRow;
- (NSInteger)numberOfRowsInTableView:(id)aView;
- (void)tableViewDidScrolled:(id)aScrolled;
- (void)tableViewSelectionDidChange:(id)aChange;
- (void)updatePreviewImagesForVisibleWebCams:(id)aCams;
- (void)newPreviewIsDoneForWebCamView:(id)aView;
- (void)redisplayInfo:(id)aInfo;
- (void)displayInfoForCam:(id)aCam;
- (void)webCamsFilterRequestDidExecute:(id)aExecute;
- (void)cacheWebcamsWithRootItem:(id)aItem filterString:(id)aString;
- (void)reloadWebCams:(id)aCams;
- (void)hideLoading;
- (void)showLoading;
- (void)outlineViewSelectionDidChange:(id)aChange;
- (void)outlineView:(id)aView willDisplayCell:(id)aCell forTableColumn:(id)aColumn item:(id)aItem;
- (id)outlineView:(id)aView toolTipForCell:(id)aCell rect:(NSRect *)aRect tableColumn:(id)aColumn item:(id)aItem mouseLocation:(NSPoint)aLocation;
- (id)outlineView:(id)aView objectValueForTableColumn:(id)aColumn byItem:(id)aItem;
- (NSInteger)outlineView:(id)aView numberOfChildrenOfItem:(id)aItem;
- (BOOL)outlineView:(id)aView isItemExpandable:(id)aExpandable;
- (id)outlineView:(id)aView child:(NSInteger)aChild ofItem:(id)aItem;
- (void)setNeedToReloadCams;
- (void)onFilter:(id)aFilter;
- (void)onHelp:(id)aHelp;
- (void)onCloseSheet:(id)aSheet;
- (void)removeFromFavouriteWebCams:(id)aCams;
- (void)addToFavouritesWebcam:(id)aWebcam;
- (void)addToCardWebcam:(id)aWebcam;
- (void)changeTab:(id)aTab;
- (void)panelDidEnd:(id)aEnd returnCode:(NSInteger)aCode contextInfo:(void *)aInfo;
- (void)runModal;
- (void)setDelegate:(id)aDelegate;
- (id)delegate;
- (void)filterRuleChanged:(id)aChanged;
- (void)awakeFromNib;
- (void)dealloc;
@end

@interface NSObject (HSRefreshRateDisplayMapping)
+ (id)localizedRefreshRateStringForRate:(double)aRate;
@end

