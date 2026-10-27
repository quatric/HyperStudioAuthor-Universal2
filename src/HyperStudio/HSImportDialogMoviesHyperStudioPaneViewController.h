#import "HyperStudioPrefix.h"
#import "HSImportDialogMoviesPaneViewController.h"


@interface HSImportDialogMoviesHyperStudioPaneViewController : HSImportDialogMoviesPaneViewController <NSOutlineViewDataSource, NSObject, NSOutlineViewDelegate, NSControlTextEditingDelegate>
{
    NSDictionary *_lineBreakInfo;
    NSMutableArray *_rootOutlineItems;
    id<HSLibraryMediaItem, HSLibraryMediaDataFolder, NSCopying> _selectedMediaItem;
    HSGraphicsLibraryBuiltinMoviesDataProvider *_mediaDataProvider;
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
- (BOOL)isPaneValid;
- (id)paneTitle;
- (NSInteger)paneWeight;
- (id)paneIdentifier;
- (id)paneViewNibName;
- (void)willMountToDialogController:(id)aController;
- (void)awakeFromNib;
- (void)dealloc;
@end

@interface HSImportDialogBuiltinMoviesDataProvider : HSGraphicsLibraryBuiltinMoviesDataProvider
{
}
- (id)builtinMoviesFolders;
@end

