#import "HyperStudioPrefix.h"
#import "HSObjectAssistantNavigationPaneSwitcher.h"


@interface HSLockStackAssistantPaneSwitcher : HSObjectAssistantNavigationPaneSwitcher
{
    NSButton *_lockButton;
    BOOL _isLocking;
}
- (void)viewDidAppear:(BOOL)aAppear;
- (void)updateLockButtonTitle;
- (void)setLocking:(BOOL)aLocking;
- (BOOL)isLocking;
- (void)viewDidLoad;
- (id)init;
@end

