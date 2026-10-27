#import "HyperStudioPrefix.h"
#import "HSImportDialogGraphicsPaneViewController.h"


@interface HSImportDialogGraphicsiPhotoPaneViewController : HSImportDialogGraphicsPaneViewController <NSOutlineViewDataSource, NSObject, NSOutlineViewDelegate, NSControlTextEditingDelegate>
{
    NSDictionary *_lineBreakInfo;
    NSMutableArray *_rootOutlineItems;
    HSGraphicsLibraryiPhotoAlbum *_selectedAlbum;
    HSGraphicsLibraryiPhotoMediaDataProvider *_mediaDataProvider;
    unsigned int _selectedPhotoIndex;
    NSImage *_invalidPhotoImage;
    NSArray *_filteredPhotosHash;
    NSRecursiveLock *_filteredPhotosHashLock;
    NSButton *_openiPhotoButton;
    NSOutlineView *_browseOutlineView;
}
+ (void)load;
- (void)openiPhotoApp:(id)aApp;
- (void)iPhotoLibraryMightDidChange;
- (id)rootItems;
- (id)objectValueForItem:(id)aItem;
- (id)gridControl:(id)aControl imageForItemAt:(NSInteger)aAt;
- (id)gridControl:(id)aControl titleForItemAt:(NSInteger)aAt;
- (NSInteger)numberOfItemsInGridControl:(id)aControl;
- (void)reloadMediaPaths;
- (void)selectionDidChangeInGridControl:(id)aControl;
- (id)outlineView:(id)aView persistentObjectForItem:(id)aItem;
- (id)outlineView:(id)aView itemForPersistentObject:(id)aObject;
- (void)outlineViewSelectionDidChange:(id)aChange;
- (BOOL)outlineView:(id)aView shouldSelectItem:(id)aItem;
- (id)outlineView:(id)aView objectValueForTableColumn:(id)aColumn byItem:(id)aItem;
- (id)outlineView:(id)aView child:(NSInteger)aChild ofItem:(id)aItem;
- (BOOL)outlineView:(id)aView isItemExpandable:(id)aExpandable;
- (NSInteger)outlineView:(id)aView numberOfChildrenOfItem:(id)aItem;
- (void)invalidateMediaPaths;
- (id)filteredPhotosForAlbum:(id)aAlbum;
- (id)currentSelectedAlbum;
- (id)currentSelectedPhoto;
- (void)applicationDidBecomeActive:(id)aActive;
- (void)willMountToDialogController:(id)aController;
- (void)paneDialogWillOpen;
- (void)paneDialogWillClose;
- (id)paneFileDisplayName;
- (id)paneFilePath;
- (id)paneTitle;
- (id)paneViewNibName;
- (NSInteger)paneWeight;
- (id)paneIdentifier;
- (id)invalidPhotoImage;
- (void)awakeFromNib;
- (void)dealloc;
- (id)init;
@end

