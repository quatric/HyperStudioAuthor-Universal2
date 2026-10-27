#import "HyperStudioPrefix.h"
#import "HSImportDialogBasePaneViewController.h"


@interface HSImportDialogSoundPaneViewController : HSImportDialogBasePaneViewController <NSTableViewDataSource, NSObject, HSSoundsLibraryTableViewDelegate, NSTableViewDelegate, NSControlTextEditingDelegate, NSTextFieldDelegate, HSMovieDelegate>
{
    NSView *_paneAccessoryView;
    NSSearchField *_searchField;
    NSImage *_playButtonImage;
    NSImage *_playButtonAquaImage;
    NSImage *_playButtonGraphiteImage;
    NSImage *_stopButtonImage;
    NSImage *_stopButtonAquaImage;
    NSImage *_stopButtonGraphiteImage;
    HSAppearanceButtonCell *_playButtonCell;
    HSMovie *_previewMovie;
    NSTimer *_previewMovieTimer;
    NSView *_paneView;
    NSSegmentedControl *_historyNavigationControl;
    NSTableView *_browseTableView;
    HSSoundsLibraryTableView *_soundsTableView;
    NSTextField *_itemsCountTextField;
    NSSlider *_volumeSlider;
    NSButton *_volumeMin;
    NSButton *_volumeMax;
    NSTextField *_currentSoundProgressField;
    NSButton *_testButton;
    NSDictionary *_lineBreakInfo;
    NSArray *_filteredItems;
    NSString *_filterString;
    NSString *_categoryString;
    BOOL _sortAscending;
    NSString *_sortedIdentifier;
    NSData *_sortedArrayHint;
    NSString *_filePath;
    NSImage *_defaultSoundIcon;
}
- (void)previewMovieTimerFireMethod:(id)aMethod;
- (void)startPreviewMovieTimer;
- (void)stopPreviewMovieTimer;
- (void)setImagesForPlayButton:(BOOL)aButton;
- (void)updatePreviewMovie;
- (void)updatePreviewMovieVolume;
- (void)setPreviewMovie:(id)aMovie;
- (id)previewMovie;
- (BOOL)mediaPathConformsToFilter:(id)aFilter;
- (void)filter:(id)aFilter byCategory:(id)aCategory;
- (void)invalidateSearch;
- (void)movieDidStop:(id)aStop;
- (void)movieDidPlayOnce:(id)aOnce;
- (void)movieDidEnd:(id)aEnd;
- (void)movieDidChangeImage:(id)aImage;
- (void)tableView:(id)aView didClickTableColumn:(id)aColumn;
- (void)tableViewSelectionDidChange:(id)aChange;
- (id)tableView:(id)aView objectValueForTableColumn:(id)aColumn row:(NSInteger)aRow;
- (NSInteger)numberOfRowsInTableView:(id)aView;
- (id)valueForSoundObject:(id)aObject forIdentifier:(id)aIdentifier lineBreakInfo:(id)aInfo;
- (id)stringForSoundObject:(id)aObject forIdentifier:(id)aIdentifier lineBreakInfo:(id)aInfo;
- (id)sortedSoundItemsForIdentifier:(id)aIdentifier;
- (id)defaultSoundIcon;
- (void)setSortAscending:(id)aAscending;
- (void)setSortedIdentifier:(id)aIdentifier;
- (void)setFilteredItems:(id)aItems;
- (id)filteredItems;
- (void)setFilePath:(id)aPath;
- (id)filePath;
- (void)switchHistoryTo:(id)aTo;
- (void)onDoubleClick:(id)aClick;
- (void)controlTextDidChange:(id)aChange;
- (void)startPreviewMovie:(id)aMovie;
- (void)volumeChangedToMaximum:(id)aMaximum;
- (void)volumeChangedToMinimum:(id)aMinimum;
- (void)volumeChanged:(id)aChanged;
- (void)setPreviewMovieVolume:(CGFloat)aVolume;
- (void)filter:(id)aFilter;
- (id)helpTopicKey;
- (void)willUnmountFromDialogController:(id)aController;
- (void)willMountToDialogController:(id)aController;
- (void)paneDialogWillClose;
- (void)paneDialogWillOpen;
- (id)currentMediaPathsLocation;
- (void)reloadMediaPaths;
- (id)supportedMediaTypes;
- (id)paneFilePath;
- (id)paneAccessoryView;
- (id)paneView;
- (id)paneIdentifier;
- (id)paneViewNibName;
- (void)awakeFromNib;
- (void)dealloc;
@end

