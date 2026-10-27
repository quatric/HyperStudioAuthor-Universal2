#import "HyperPlayerBasePrefix.h"
#import "HSMovieObjectVisualization.h"


@interface HSHitTestingMovieObjectVisualization : HSMovieObjectVisualization
{
}
- (id)expandedShowHideTransitionRenderLayerSubtreeWithVisualizationOptions:(id)aOptions;
- (id)showHideTransitionRenderLayerIdentifierForVisualizationOptions:(id)aOptions;
- (BOOL)canBeHidden;
@end

