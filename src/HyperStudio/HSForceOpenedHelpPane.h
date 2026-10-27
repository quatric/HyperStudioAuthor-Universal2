#import "HyperStudioPrefix.h"
#import "HSHelpAssistantPane.h"


@interface HSForceOpenedHelpPane : HSHelpAssistantPane
{
    BOOL _shouldHideAssistantOnGoBack;
}
- (void)setShouldHideAssistantOnGoBack:(BOOL)aBack;
- (BOOL)shouldHideAssistantOnGoBack;
- (BOOL)shouldDismissWhenDisappearedByDefault;
- (void)dismiss:(BOOL)aDismiss slide:(BOOL)aSlide;
- (void)viewWillDisappear:(BOOL)aDisappear;
- (BOOL)needsToBeSavedInHistory;
@end

