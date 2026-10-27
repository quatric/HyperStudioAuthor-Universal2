#import "HyperStudioPrefix.h"


@interface HSExtensionAlertController : NSWindowController
{
    NSButton *_linkButton;
    NSButton *_orderInfoButton;
    NSButton *_OKButton;
    NSTextField *_message;
    NSTextField *_explanation;
}
+ (id)sharedInstance;
- (void)orderInfoPressed:(id)aPressed;
- (void)OKPressed:(id)aPressed;
- (void)linkButtonPressed:(id)aPressed;
- (NSInteger)runModalForMode:(NSInteger)aMode;
- (void)setAlertTextForExtensionMode:(NSInteger)aMode;
- (void)windowDidLoad;
- (void)configureLinkButton;
- (id)init;
- (id)HSExtensionAlertController_init;
@end

