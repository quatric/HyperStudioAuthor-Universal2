#import "HSImageSequenceExportAccessoryViewController.h"

@implementation HSImageSequenceExportAccessoryViewController

- (void)toggleExportSelectedCards:(id)aCards
{
    [_exporter setExportOnlySelectedCards:[_exportOnlySelectedCardsCheckBox state] == NSControlStateValueOn];
    [[self exportPanelController] setRequiredFileType:[_exporter countExportedCards] == 1 ? @"png" : @"images"];
}

- (void)viewWillAppear:(BOOL)aAppear
{
    [super viewWillAppear:aAppear];
    NSString *title = [[NSBundle mainBundle] localizedStringForKey:@"Export only the current card" value:@"" table:nil];
    if ([_exporter isActiveStoryboardMode]) {
        NSString *key = [_exporter countExportedCards] < 2 ? @"Export only selected card" : @"Export only selected cards";
        title = [[NSBundle mainBundle] localizedStringForKey:key value:@"" table:nil];
    }
    [_exportOnlySelectedCardsCheckBox setTitle:title];
    BOOL oneCard = [_exporter isExportOnlyOneCard];
    [_exportOnlySelectedCardsCheckBox setState:oneCard ? NSControlStateValueOn : NSControlStateValueOff];
    [_exportOnlySelectedCardsCheckBox setEnabled:!oneCard];
}

- (void)setExportPanelController:(id)aController
{
    [super setExportPanelController:aController];
    [[self exportPanelController] setRequiredFileType:[_exporter countExportedCards] == 1 ? @"png" : @"images"];
}

- (id)init
{
    return [super initWithNibName:@"ExportToImageSequenceAccessoryView"];
}

@end
