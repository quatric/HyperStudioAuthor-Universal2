#import "HyperStudioPrefix.h"
#import "HSObjectAssistantNavigationController.h"


@interface HSHypertextLinksRootViewController : HSObjectAssistantNavigationController
{
    id _initialObject;
}
- (void)objectLockedStateDidChange:(id)aChange;
- (void)notifyViewWillDisappear:(BOOL)aDisappear;
- (void)notifyViewWillAppear:(BOOL)aAppear;
- (void)setInitialObject:(id)aObject;
- (void)dealloc;
@end

