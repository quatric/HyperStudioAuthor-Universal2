#import "HyperStudioPrefix.h"
#import "HSImportDialogMoviesPaneViewController.h"


@interface HSImportDialogMoviesImportedPaneViewController : HSImportDialogMoviesPaneViewController <NSTableViewDataSource, NSObject, NSTableViewDelegate, NSControlTextEditingDelegate>
{
    NSSegmentedControl *_historyNavigationControl;
    HSImportDialogImportedPaneBrowseController *_browseTableViewDataSource;
    NSArray *_predefinedMovieLocations;
    NSMutableArray *_primaryHistory;
    NSMutableArray *_secondaryHistory;
    BOOL _switchingHistory;
}
+ (void)load;
- (void)applicationDidBecomeActive:(id)aActive;
- (void)validateHistoryNavigationControl;
- (id)gridControl:(id)aControl titleForItemAt:(NSInteger)aAt;
- (void)moviesMightDidChange;
- (id)tableViewDataSource;
- (id)customImageLocationsDefaultsKey;
- (id)predefinedMovieLocations;
- (id)createMediaPathsForKey:(id)aKey;
- (id)currentMediaPathsLocation;
- (void)tvDataSourceSelectionDidChange:(id)aChange;
- (BOOL)mediaPathConformsToFilter:(id)aFilter;
- (void)reloadMediaPaths;
- (id)secondaryHistory;
- (id)primaryHistory;
- (void)switchHistoryTo:(id)aTo;
- (void)switchHistoryForward;
- (void)switchHistoryBack;
- (void)paneDialogWillOpen;
- (id)paneTitle;
- (NSInteger)paneWeight;
- (id)paneIdentifier;
- (void)awakeFromNib;
- (void)dealloc;
- (id)init;
@end

