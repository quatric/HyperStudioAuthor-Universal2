#import "HyperStudioPrefix.h"
#import "HSGenericPasswordAssistantPane.h"


@interface HSUnlockStackAssistantPane : HSGenericPasswordAssistantPane
{
    HSLockStackAssistantPaneSwitcher *_navigationPaneSwitcher;
}
- (id)navigationPaneSwitcher;
- (void)paneDidCancel:(id)aCancel;
- (void)rejectPassword;
- (void)acceptPassword;
- (BOOL)isPasswordValid;
- (void)hideUnlockStackPane;
- (BOOL)requiresDarkBottomArea;
- (void)dealloc;
- (id)init;
@end

