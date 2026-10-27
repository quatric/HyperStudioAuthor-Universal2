#import "HyperStudioPrefix.h"
#import "HSTool.h"


@interface HSColorPickingTool : HSTool
{
    HSColorPickingCanvasLayer *_toolCanvasLayer;
}
- (void)finalizeBeforeDeactivateExplicitly:(BOOL)aExplicitly;
- (void)didActivateExplicitly:(BOOL)aExplicitly;
@end

