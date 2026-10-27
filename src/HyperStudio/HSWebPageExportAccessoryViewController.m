#import "HSWebPageExportAccessoryViewController.h"

@implementation HSWebPageExportAccessoryViewController

- (void)setExportPanelController:(id)aController
{
    [super setExportPanelController:aController];
    [[self exportPanelController] setRequiredFileType:@""];
}

- (id)init
{
    return [super initWithNibName:@"ExportToWebPageAccessoryView"];
}

@end
