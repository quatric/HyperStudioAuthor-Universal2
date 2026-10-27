#import "HyperStudioPrefix.h"
#import "HSTool.h"


@interface HSMagnifyingTool : HSTool
{
    HSMagnifyingCanvasLayer *_layer;
}
- (id)layer;
- (void)didActivateExplicitly:(BOOL)aExplicitly;
- (void)finalizeBeforeDeactivateExplicitly:(BOOL)aExplicitly;
- (void)dealloc;
@end

