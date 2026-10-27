#import "HSWebObjectPreviewVisualization.h"
@implementation HSWebObjectPreviewVisualization
- (id)expandedShowHideTransitionRenderLayerSubtreeWithVisualizationOptions:(id)aOptions
{
    return [self renderLayerWithIdentifier:@"HSWebElementPreviewRenderLayerIdentifier"
                         precreateSelector:@selector(precreateWebElementPreviewRenderLayerForVisualizationOptions:)
                      visualizationOptions:aOptions];
}
- (id)precreateWebElementPreviewRenderLayerForVisualizationOptions:(id)aOptions
{
    return [[HSWebElementPreviewRenderLayer alloc] initWithHyperObject:[self hyperObject]];
}
- (id)showHideTransitionRenderLayerIdentifierForVisualizationOptions:(id)aOptions
{
    return @"HSShowHideTransitionRenderLayerIdentifier-Preview";
}
@end
