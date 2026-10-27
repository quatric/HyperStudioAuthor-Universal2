#import "HyperStudioPrefix.h"
#import "HSImportDialogMoviesPaneViewController.h"


@interface HSImportDialogMoviesiTunesPaneViewController : HSImportDialogMoviesPaneViewController
{
    HSSoundsLibraryiTunesPlaylist *_moviesPlaylist;
}
+ (void)load;
- (id)moviesPlaylist;
- (id)currentMediaPathsLocation;
- (id)createMediaPathsForKey:(id)aKey;
- (id)paneTitle;
- (NSInteger)paneWeight;
- (id)paneView;
- (id)paneIdentifier;
- (id)paneViewNibName;
- (void)dealloc;
@end

