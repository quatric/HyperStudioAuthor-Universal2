#import "HSHitTestingMovieObjectVisualization.h"
@implementation HSHitTestingMovieObjectVisualization
- (id)expandedShowHideTransitionRenderLayerSubtreeWithVisualizationOptions:(id)aOptions
{
    // hit testing draws no show/hide transitions
    return [self expandedShadowAndOpacityRenderLayerSubtreeWithVisualizationOptions:aOptions];
}
- (id)showHideTransitionRenderLayerIdentifierForVisualizationOptions:(id)aOptions
{
    return [[super showHideTransitionRenderLayerIdentifierForVisualizationOptions:aOptions]
        stringByAppendingString:@"-HSHitTestingVisualization"];
}
- (BOOL)canBeHidden
{
    return !protocol_conformsToProtocol([self visualizationProtocol], @protocol(HSEditorHitTestingVisualization));
}
@end
