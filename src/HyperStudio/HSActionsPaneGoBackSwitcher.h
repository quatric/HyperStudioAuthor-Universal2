#import "HyperStudioPrefix.h"
#import "HSObjectAssistantNavigationPaneSwitcher.h"


@interface HSActionsPaneGoBackSwitcher : HSObjectAssistantNavigationPaneSwitcher
{
    NSButton *_goBackButton;
}
- (void)setCanGoBack:(BOOL)aBack;
- (id)init;
@end

