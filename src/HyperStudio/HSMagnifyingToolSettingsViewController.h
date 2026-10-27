#import "HyperStudioPrefix.h"
#import "HSToolSettingsViewController.h"


@interface HSMagnifyingToolSettingsViewController : HSToolSettingsViewController
{
}
- (void)cardSizeDidChange:(id)aChange;
- (void)cardDidChange:(id)aChange;
- (void)visibleRectDidChange:(id)aChange;
- (id)cardViewForCardNavigatorView:(id)aView;
- (void)scrollCardViewToRect:(NSRect)aRect cardNavigatorView:(id)aView;
- (NSRect)userVisibleCardRectForCardNavigatorView:(id)aView;
- (void)willUnMount;
- (void)willMount;
- (id)cardNavigatorView;
- (id)nibName;
- (void)dealloc;
- (void)validateUserInterface;
@end

