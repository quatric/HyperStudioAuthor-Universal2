#import "HyperStudioPrefix.h"
#import "HSHelpAssistantPane.h"


@interface HSGenericModeAssistantPane : HSHelpAssistantPane
{
    BOOL _shouldNotLeavePaneOnToolChange;
    BOOL _initialSupportSettingsOnTheSpotMode;
}
- (void)toolWillChange:(id)aChange;
- (void)undoManagerWillUndoOrRedo:(id)aRedo;
- (id)modeToolTags;
- (BOOL)shouldDismissWhenDisappearedByDefault;
- (void)setShouldLeavePaneOnToolChange:(BOOL)aChange;
- (BOOL)shouldLeavePaneOnToolChange;
- (void)leaveCurrentModeWithSelectingToolWithTag:(NSInteger)aTag;
- (id)document;
- (void)viewWillDisappear:(BOOL)aDisappear;
- (void)viewDidLoad;
- (void)viewWillAppear:(BOOL)aAppear;
@end

