#import "HyperStudioPrefix.h"
#import "HSImportDialogBasePaneViewController.h"


@interface HSImportDialogGraphicsPaneViewController : HSImportDialogBasePaneViewController <NSTextFieldDelegate, NSControlTextEditingDelegate, NSObject>
{
    NSView *_paneView;
    NSView *_paneAccessoryView;
    NSSegmentedControl *_historyNavigationControl;
    NSPopUpButton *_itemsFilterPopUp;
    NSSearchField *_searchField;
    NSTableView *_browseTableView;
    SMKGridControl *_imageGrid;
    NSImageView *_cardPreviewBackground;
    HSBackgroundPreviewView *_cardPreview;
    NSBox *_objectTypeSeparator;
    NSTextField *_objectTypeLabelField;
    NSSlider *_thumbnailSizeSlider;
    NSTextField *_itemsCountTextField;
    NSBox *_layoutOptionsView;
    NSView *_backgroundOptionsView;
    NSMatrix *_backgroundOptionsMatrix;
    NSView *_objectOptionsView;
    NSMatrix *_objectOptionsMatrix;
    NSView *_getAnotherPictureOptionsView;
    NSMatrix *_getAnotherPictureOptionsMatrix;
    NSButton *_runCropImageButton;
    NSButton *_captureImageButton;
    NSString *_filterString;
    int _defaultObjectLayoutTag;
    int _userSelectedObjectLayoutTag;
    int _defaultBackgroundLayoutTag;
    BOOL _disableCropImage;
    BOOL _wasCropped;
    BOOL _tempObjectLayoutTagChange;
    NSImage *_croppedImage;
    NSMutableArray *_cropPaths;
    NSDictionary *_croppedImageSourceInfo;
    unsigned int _storedGridSelection;
}
- (void)updateCardPreviewSize;
- (void)updateCardPreviewForLayoutOption:(NSInteger)aOption;
- (void)invalidateSearch;
- (void)setupDisableCropImage:(id)aImage;
- (void)setupDefaultBackgroundLayout:(id)aLayout;
- (void)setupDefaultObjectLayout:(id)aLayout;
- (id)optionsKeyToProcessingSelectorMap;
- (BOOL)mediaPathConformsToFilter:(id)aFilter;
- (void)itemsFilterPopUpDidChange:(id)aChange;
- (void)controlTextDidChange:(id)aChange;
- (void)selectionDidChangeInGridControl:(id)aControl;
- (id)gridControl:(id)aControl additionalInfoForItemAt:(NSInteger)aAt;
- (id)gridControl:(id)aControl imageForItemAt:(NSInteger)aAt;
- (id)gridControl:(id)aControl titleForItemAt:(NSInteger)aAt;
- (NSInteger)numberOfItemsInGridControl:(id)aControl;
- (BOOL)isImageRectangular:(id)aRectangular;
- (id)helpTopicKey;
- (id)currentMediaPathsLocation;
- (void)restoreSelection;
- (void)storeSelection;
- (void)reloadMediaPaths;
- (id)supportedMediaTypes;
- (id)paneUserOptions;
- (id)paneFilePath;
- (void)validateRunCropImageButton;
- (void)captureImage:(id)aImage;
- (void)cropImage:(id)aImage;
- (void)onDoubleClick:(id)aClick;
- (void)layoutChanged:(id)aChanged;
- (void)zoomMax:(id)aMax;
- (void)zoomMin:(id)aMin;
- (void)zoomThumbnailSizeSliderToValue:(double)aValue;
- (void)sliderMoved:(id)aMoved;
- (void)setMode:(NSInteger)aMode forGridControl:(id)aControl;
- (void)switchHistoryTo:(id)aTo;
- (id)paneViewNibName;
- (id)paneAccessoryView;
- (id)paneView;
- (id)paneIdentifier;
- (void)willUnmountFromDialogController:(id)aController;
- (void)willMountToDialogController:(id)aController;
- (void)paneDialogWillOpen;
- (void)paneDialogWillCancel;
- (void)awakeFromNib;
- (void)dealloc;
@end

