#import "HSPodcastExportAccessoryViewController.h"

@implementation HSPodcastExportAccessoryViewController

- (void)changeExportDevice:(id)aDevice
{
    [_exporter setExportSettingsValue:[NSNumber numberWithInt:[[_exportDevicePopUpButton selectedItem] tag]] forKey:HSVideoExportDeviceKey];
    [[self exportPanelController] setRequiredFileType:@"m4v"];
}

- (void)viewDidLoad
{
    BOOL canExportWithNarration;
    NSInteger device;

    [super viewDidLoad];
    [_exporter setExportSettingsValue:[NSNumber numberWithInt:1] forKey:HSVideoExportDeviceKey];
    canExportWithNarration = [[_exporter exportSettingsValueForKey:HSVideoExportAllowsNarrationKey] boolValue];
    [_exportOptionMatrix selectCellWithTag:canExportWithNarration];
    [_exporter setExportSettingsValue:[NSNumber numberWithInt:canExportWithNarration] forKey:HSVideoExportOptionKey];
    [_exportOptionMatrix setEnabled:canExportWithNarration];
    [_exportDevicePopUpButton removeAllItems];
    for (device = 0; device < 5; device++) {
        id title = [self titleOfPopUpItemForDevice:device];
        if (title != nil) {
            [_exportDevicePopUpButton addItemWithTitle:title];
            [[_exportDevicePopUpButton itemWithTitle:title] setTag:device];
        }
    }
    [_exportDevicePopUpButton selectItemWithTag:[[_exporter exportSettingsValueForKey:HSVideoExportDeviceKey] intValue]];
}

- (id)titleOfPopUpItemForDevice:(NSInteger)aDevice
{
    NSString *key;

    switch (aDevice) {
    case 1: key = @"HSVideoExportDeviceIPod"; break;
    case 2: key = @"HSVideoExportDeviceIPhone"; break;
    case 3: key = @"HSVideoExportDeviceIPhone4"; break;
    case 4: key = @"HSVideoExportDeviceIPad"; break;
    default: return nil;
    }
    return [[NSBundle mainBundle] localizedStringForKey:key value:@"" table:@"Export"];
}

- (void)setExportPanelController:(id)aController
{
    [super setExportPanelController:aController];
    [[self exportPanelController] setRequiredFileType:@"m4v"];
}

- (id)init
{
    return [super initWithNibName:@"ExportToPodcastAccessoryView"];
}

@end
