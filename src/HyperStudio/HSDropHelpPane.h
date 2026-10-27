#import "HyperStudioPrefix.h"
#import "HSHelpAssistantPane.h"


@interface HSDropHelpPane : HSHelpAssistantPane
{
    id<HSDropHelpPaneDelegate> _dropDelegate;
    BOOL _useDragPreferences;
}
- (void)setUseDragPreferences:(BOOL)aPreferences;
- (BOOL)useDragPreferences;
- (void)setDropDelegate:(id)aDelegate;
- (id)dropDelegate;
- (id)dropHelpPaneIdentifier;
- (BOOL)shouldDismissWhenDisappearedByDefault;
@end

