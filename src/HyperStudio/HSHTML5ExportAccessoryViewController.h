#import "HyperStudioPrefix.h"
#import "HSExportAccessoryViewController.h"


@interface HSHTML5ExportAccessoryViewController : HSExportAccessoryViewController
{
    NSButton *_exportWithDepthCheckbox;
    NSTextField *_linkedStacksDepthTextField;
    NSStepper *_linkedStacksDepthStepper;
    NSTextField *_explanationText;
}
- (void)controlTextDidChange:(id)aChange;
- (void)linkedStacksDepthChanged:(id)aChanged;
- (void)exportWithDepthChanged:(id)aChanged;
- (void)viewWillDisappear:(BOOL)aDisappear;
- (void)viewWillAppear:(BOOL)aAppear;
- (void)viewDidLoad;
- (void)dealloc;
- (id)init;
- (id)stack;
@end

