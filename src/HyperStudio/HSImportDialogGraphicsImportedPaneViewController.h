#import "HyperStudioPrefix.h"
#import "HSImportDialogGraphicsPaneViewController.h"


@interface HSImportDialogGraphicsImportedPaneViewController : HSImportDialogGraphicsPaneViewController <NSTableViewDataSource, NSObject, NSTableViewDelegate, NSControlTextEditingDelegate>
{
    HSImportDialogImportedPaneBrowseController *_browseTableViewDataSource;
    NSDictionary *_concreteMediaTypesDictionary;
    NSArray *_predefinedImageLocations;
    NSMutableArray *_primaryHistory;
    NSMutableArray *_secondaryHistory;
    BOOL _switchingHistory;
}
+ (void)load;
- (void)validateHistoryNavigationControl;
- (void)fileOrFolderStructureMightDidChange;
- (id)tableViewDataSource;
- (id)predefinedImageLocations;
- (id)customImageLocationsDefaultsKey;
- (id)concreteMediaTypesDictionary;
- (id)gridControl:(id)aControl titleForItemAt:(NSInteger)aAt;
- (BOOL)mediaPathConformsToFilter:(id)aFilter;
- (id)currentMediaPathsLocation;
- (void)tvDataSourceSelectionDidChange:(id)aChange;
- (id)createMediaPathsForKey:(id)aKey;
- (void)reloadMediaPaths;
- (void)applicationDidBecomeActive:(id)aActive;
- (void)paneDialogWillOpen;
- (void)paneDialogWillClose;
- (id)paneTitle;
- (NSInteger)paneWeight;
- (id)paneIdentifier;
- (id)secondaryHistory;
- (id)primaryHistory;
- (void)switchHistoryTo:(id)aTo;
- (void)switchHistoryForward;
- (void)switchHistoryBack;
- (void)awakeFromNib;
- (void)dealloc;
@end

