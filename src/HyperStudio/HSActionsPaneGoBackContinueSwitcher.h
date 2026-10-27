#import "HyperStudioPrefix.h"
#import "HSActionsPaneGoBackSwitcher.h"


@interface HSActionsPaneGoBackContinueSwitcher : HSActionsPaneGoBackSwitcher
{
    NSButton *_continueButton;
}
- (void)assistantContinue:(id)aContinue;
- (void)setCanContinue:(BOOL)aContinue;
- (id)init;
@end

