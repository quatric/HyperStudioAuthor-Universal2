#import "HyperPlayerBasePrefix.h"


@interface HSWindow : NSEWindow
{
}
- (void)toggleToolbarShown:(id)aShown;
- (void)_toolbarPillButtonClicked:(id)aClicked;
- (void)sendEvent:(id)aEvent;
- (BOOL)validateUserInterfaceItem:(id)aItem;
- (void)HSWindow_notifyToggleToolbarShown;
@end

