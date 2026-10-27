#import "HyperStudioPrefix.h"


@interface HSTrialCDCheckerController : NSWindowController
{
    NSButton *_linkButton;
    NSButton *_learnMoreButton;
}
+ (id)sharedInstance;
- (void)purchaseOnline:(id)aOnline;
- (void)enterRegistrationKey:(id)aKey;
- (void)continueWorking:(id)aWorking;
- (void)learnMoreButtonPressed:(id)aPressed;
- (void)linkButtonPressed:(id)aPressed;
- (NSInteger)runModal;
- (void)windowDidLoad;
- (id)init;
- (id)HSTrialCDCheckerController_init;
@end

