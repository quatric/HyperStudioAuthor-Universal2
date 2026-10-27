#import "HyperStudioPrefix.h"
#import "HSImportDialogSoundPaneViewController.h"


@interface HSImportDialogSoundiTunesPaneViewController : HSImportDialogSoundPaneViewController <NSOutlineViewDataSource, NSObject, NSOutlineViewDelegate, NSControlTextEditingDelegate>
{
    NSOutlineView *_browseOutlineView;
    NSMutableArray *_rootOutlineItems;
    NSButton *_openiTunesButton;
    HSSoundsLibraryiTunesPlaylist *_selectedMediaItem;
    HSSoundsLibraryiTunesMediaDataProvider *_mediaDataProvider;
}
+ (void)load;
- (void)reloadMediaPaths;
- (id)rootItems;
- (id)objectValueForItem:(id)aItem;
- (void)filterSounds:(id)aSounds byCategory:(id)aCategory;
- (void)filter:(id)aFilter byCategory:(id)aCategory;
- (void)selectItem:(id)aItem;
- (id)stringForSoundObject:(id)aObject forIdentifier:(id)aIdentifier lineBreakInfo:(id)aInfo;
- (id)sortedSoundItemsForIdentifier:(id)aIdentifier;
- (BOOL)outlineView:(id)aView shouldExpandItem:(id)aItem;
- (id)outlineView:(id)aView persistentObjectForItem:(id)aItem;
- (id)outlineView:(id)aView itemForPersistentObject:(id)aObject;
- (void)outlineViewSelectionDidChange:(id)aChange;
- (BOOL)outlineView:(id)aView shouldSelectItem:(id)aItem;
- (id)outlineView:(id)aView objectValueForTableColumn:(id)aColumn byItem:(id)aItem;
- (id)outlineView:(id)aView child:(NSInteger)aChild ofItem:(id)aItem;
- (BOOL)outlineView:(id)aView isItemExpandable:(id)aExpandable;
- (NSInteger)outlineView:(id)aView numberOfChildrenOfItem:(id)aItem;
- (void)openiTunesApp:(id)aApp;
- (id)paneFilePath;
- (id)paneTitle;
- (id)paneViewNibName;
- (NSInteger)paneWeight;
- (id)paneIdentifier;
- (void)awakeFromNib;
- (void)dealloc;
@end

