#import "HyperStudioPrefix.h"
#import "HSImportDialogGraphicsPaneViewController.h"


@interface HSImportDialogGraphicsHyperStudioPaneViewController : HSImportDialogGraphicsPaneViewController <NSOutlineViewDataSource, NSObject, NSOutlineViewDelegate, NSControlTextEditingDelegate>
{
    NSDictionary *_lineBreakInfo;
    NSMutableArray *_rootOutlineItems;
    HSGraphicsLibraryBuiltInMediaItem *_selectedMediaItem;
    HSGraphicsLibraryBuiltInMediaDataProvider *_mediaDataProvider;
}
+ (void)load;
- (id)rootItems;
- (id)objectValueForItem:(id)aItem;
- (BOOL)outlineView:(id)aView shouldExpandItem:(id)aItem;
- (id)outlineView:(id)aView persistentObjectForItem:(id)aItem;
- (id)outlineView:(id)aView itemForPersistentObject:(id)aObject;
- (void)outlineViewSelectionDidChange:(id)aChange;
- (BOOL)outlineView:(id)aView shouldSelectItem:(id)aItem;
- (id)outlineView:(id)aView objectValueForTableColumn:(id)aColumn byItem:(id)aItem;
- (id)outlineView:(id)aView child:(NSInteger)aChild ofItem:(id)aItem;
- (BOOL)outlineView:(id)aView isItemExpandable:(id)aExpandable;
- (NSInteger)outlineView:(id)aView numberOfChildrenOfItem:(id)aItem;
- (BOOL)mediaPathConformsToFilter:(id)aFilter;
- (id)currentMediaPathsLocation;
- (id)createMediaPathsForKey:(id)aKey;
- (id)paneFileDisplayName;
- (BOOL)isPaneValid;
- (id)paneTitle;
- (id)paneViewNibName;
- (NSInteger)paneWeight;
- (id)paneIdentifier;
- (void)willMountToDialogController:(id)aController;
- (void)awakeFromNib;
- (void)dealloc;
@end

