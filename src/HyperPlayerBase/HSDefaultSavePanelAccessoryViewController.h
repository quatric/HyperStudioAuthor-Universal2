#import "HyperPlayerBasePrefix.h"
#import "HSSavePanelAccessoryViewController.h"


@interface HSDefaultSavePanelAccessoryViewController : HSSavePanelAccessoryViewController
{
    NSButton *_changeHomeStackURLSwitch;
}
- (void)setShouldChangeHomeStackURL:(BOOL)aURL;
- (BOOL)shouldChangeHomeStackURL;
- (id)init;
@end

