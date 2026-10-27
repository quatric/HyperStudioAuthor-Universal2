#import "HyperStudioPrefix.h"
#import "HSMovieExportAccessoryViewController.h"


@interface HSQuickTimeExportAccessoryViewController : HSMovieExportAccessoryViewController
{
    NSMutableArray *_movieSizesInfo;
}
- (void)changeMovieSize:(id)aSize;
- (void)viewDidLoad;
- (id)movieSizesInfo;
- (void)setExportPanelController:(id)aController;
- (void)dealloc;
- (id)init;
@end

