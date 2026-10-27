#import "HSVectorBrushVisualization.h"
@implementation HSVectorBrushVisualization
- (id)expandedEffectRenderLayerSubtreeWithVisualizationOptions:(id)aOptions
{
    return [self renderLayerWithIdentifier:@"HSGenericVectorBrushRenderLayerIdentifier"
                         precreateSelector:@selector(precreateVectorBrushRenderLayerForVisualizationOptions:)
                      visualizationOptions:aOptions];
}
- (id)precreateVectorBrushRenderLayerForVisualizationOptions:(id)aOptions
{
    return [[HSGenericVectorBrushRenderLayer alloc] initWithHyperObject:[self hyperObject]];
}
@end
