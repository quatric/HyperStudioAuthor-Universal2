#import "HyperStudioPrefix.h"
#import "HSExportAccessoryViewController.h"


@interface HSImageSequenceExportAccessoryViewController : HSExportAccessoryViewController
{
    NSButton *_exportOnlySelectedCardsCheckBox;
}
- (void)toggleExportSelectedCards:(id)aCards;
- (void)viewWillAppear:(BOOL)aAppear;
- (void)setExportPanelController:(id)aController;
- (id)init;
@end

