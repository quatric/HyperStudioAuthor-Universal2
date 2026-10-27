#import "HyperStudioPrefix.h"
#import "HSImportDialogSoundPaneViewController.h"


@interface HSImportDialogSoundHyperStudioPaneViewController : HSImportDialogSoundPaneViewController <NSOutlineViewDataSource, NSObject, NSOutlineViewDelegate, NSControlTextEditingDelegate>
{
    NSOutlineView *_browseOutlineView;
    NSMutableArray *_rootOutlineItems;
    HSSoundsLibraryBuiltInMediaItem *_selectedMediaItem;
    HSSoundsLibraryBuiltInMediaDataProvider *_mediaDataProvider;
}
+ (void)load;
- (void)reloadMediaPaths;
- (id)rootItems;
- (id)objectValueForItem:(id)aItem;
- (void)filterSounds:(id)aSounds byCategory:(id)aCategory;
- (void)filter:(id)aFilter byCategory:(id)aCategory;
- (void)selectItem:(id)aItem;
- (void)tableView:(id)aView didClickTableColumn:(id)aColumn;
- (id)valueForSoundObject:(id)aObject forIdentifier:(id)aIdentifier lineBreakInfo:(id)aInfo;
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
- (id)optionsKeyToProcessingSelectorMap;
- (BOOL)isPaneValid;
- (id)paneFilePath;
- (id)paneTitle;
- (void)paneDialogWillClose;
- (id)paneViewNibName;
- (NSInteger)paneWeight;
- (id)paneIdentifier;
- (void)awakeFromNib;
- (void)dealloc;
@end

