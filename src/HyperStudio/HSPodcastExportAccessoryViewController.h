#import "HyperStudioPrefix.h"
#import "HSMovieExportAccessoryViewController.h"


@interface HSPodcastExportAccessoryViewController : HSMovieExportAccessoryViewController
{
    NSPopUpButton *_exportDevicePopUpButton;
}
- (void)changeExportDevice:(id)aDevice;
- (void)viewDidLoad;
- (id)titleOfPopUpItemForDevice:(NSInteger)aDevice;
- (void)setExportPanelController:(id)aController;
- (id)init;
@end

