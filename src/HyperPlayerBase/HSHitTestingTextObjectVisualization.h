#import "HyperPlayerBasePrefix.h"
#import "HSTextObjectVisualization.h"


@interface HSHitTestingTextObjectVisualization : HSTextObjectVisualization
{
}
- (id)expandedShowHideTransitionRenderLayerSubtreeWithVisualizationOptions:(id)aOptions;
- (id)showHideTransitionRenderLayerIdentifierForVisualizationOptions:(id)aOptions;
- (BOOL)canBeHidden;
@end

