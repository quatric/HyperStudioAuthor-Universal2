#import "HyperStudioPrefix.h"
#import "HSImportDialogSoundPaneViewController.h"


@interface HSImportDialogSoundImportedPaneViewController : HSImportDialogSoundPaneViewController <NSTableViewDataSource, NSObject, NSTableViewDelegate, NSControlTextEditingDelegate>
{
    HSImportDialogImportedPaneBrowseController *_browseTableViewDataSource;
    BOOL _cancelAllThreads;
    NSString *_locationForThreads;
    NSArray *_predefinedSoundLocations;
    NSMutableArray *_primaryHistory;
    NSMutableArray *_secondaryHistory;
    BOOL _switchingHistory;
    NSDictionary *_mediaDurationsHash;
}
+ (void)load;
- (void)applicationDidBecomeActive:(id)aActive;
- (void)validateHistoryNavigationControl;
- (void)fileOrFolderStructureMightDidChange;
- (id)tableViewDataSource;
- (id)predefinedSoundLocations;
- (id)customImageLocationsDefaultsKey;
- (id)desktopLastPathComponent;
- (void)readMovieDurationInMainThread:(id)aThread;
- (void)addMediaDurations:(id)aDurations;
- (void)scaningThreadFunction:(id)aFunction;
- (void)updateFilteredMedia;
- (void)invalidateSearch;
- (void)tableView:(id)aView didClickTableColumn:(id)aColumn;
- (id)valueForSoundObject:(id)aObject forIdentifier:(id)aIdentifier lineBreakInfo:(id)aInfo;
- (id)stringForSoundObject:(id)aObject forIdentifier:(id)aIdentifier lineBreakInfo:(id)aInfo;
- (id)sortedSoundItemsForIdentifier:(id)aIdentifier;
- (BOOL)mediaPathConformsToFilter:(id)aFilter;
- (id)currentMediaPathsLocation;
- (void)reloadMediaPaths;
- (void)tvDataSourceSelectionDidChange:(id)aChange;
- (id)createMediaPathsForKey:(id)aKey;
- (id)secondaryHistory;
- (id)primaryHistory;
- (void)switchHistoryTo:(id)aTo;
- (void)switchHistoryForward;
- (void)switchHistoryBack;
- (id)paneFilePath;
- (void)paneDialogWillOpen;
- (void)paneDialogWillClose;
- (id)paneTitle;
- (NSInteger)paneWeight;
- (id)paneIdentifier;
- (void)awakeFromNib;
- (void)dealloc;
@end

