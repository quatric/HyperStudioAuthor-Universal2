#import "HyperStudioPrefix.h"


@interface HSDontShowAgainAlert : HSAlert
{
    NSString *_showAlertKey;
    NSButton *_showAgain;
}
- (void)setShowAlertKey:(id)aKey;
- (id)showAlertKey;
- (void)dealloc;
- (id)init;
@end

@interface HSDontShowAgainAlert (IBActions)
- (void)firstButtonPressed:(id)aPressed;
@end

