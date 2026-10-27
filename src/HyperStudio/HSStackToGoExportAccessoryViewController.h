#import "HyperStudioPrefix.h"
#import "HSExportAccessoryViewController.h"


@interface HSStackToGoExportAccessoryViewController : HSExportAccessoryViewController
{
    NSMatrix *_platformMatrix;
}
- (void)setExportPanelController:(id)aController;
- (id)init;
@end

