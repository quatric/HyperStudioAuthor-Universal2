#import "HyperStudioPrefix.h"
#import "HSAssistantPaneApplier.h"


@interface HSAssistantPaneMultiApplier : HSAssistantPaneApplier
{
    NSMutableArray *_appliers;
}
- (BOOL)areSettingsEqual;
- (id)undoActionName;
- (void)makeInitialEqualToCurrent;
- (void)makeCurrentEqualToInitial;
- (void)setInitialSettingsToObject;
- (void)setCurrentSettingsToObject;
- (void)addApplier:(id)aApplier;
- (id)appliers;
- (void)dealloc;
@end

