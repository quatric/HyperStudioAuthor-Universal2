#import "HSColorPickingTool.h"

@implementation HSColorPickingTool

- (void)finalizeBeforeDeactivateExplicitly:(BOOL)aExplicitly
{
    [[[self view] rootCanvasLayer] removeSublayer:_toolCanvasLayer];
    [super finalizeBeforeDeactivateExplicitly:aExplicitly];
}

// Original quirk kept: the layer from +new is never released.
- (void)didActivateExplicitly:(BOOL)aExplicitly
{
    [super didActivateExplicitly:aExplicitly];
    id root = [[self view] rootCanvasLayer];
    _toolCanvasLayer = [HSColorPickingCanvasLayer new];
    [root addSublayer:_toolCanvasLayer];
}

@end
