#import "HyperStudioPrefix.h"
#import "HSTool.h"


@interface HSDisabledTool : HSTool
{
    id _dummyLayer;
}
- (void)finalizeBeforeDeactivateExplicitly:(BOOL)aExplicitly;
- (void)didActivateExplicitly:(BOOL)aExplicitly;
- (id)dummyLayer;
- (BOOL)shouldResetToolOnAddObjects;
- (BOOL)allowsEditingToolView;
- (void)dealloc;
@end

