#import "HSStackToGoExportAccessoryViewController.h"

@implementation HSStackToGoExportAccessoryViewController

- (void)setExportPanelController:(id)aController
{
    [super setExportPanelController:aController];
    [[self exportPanelController] setRequiredFileType:@"app"];
}

- (id)init
{
    return [super initWithNibName:@"ExportToStackToGoAccessoryView"];
}

@end
