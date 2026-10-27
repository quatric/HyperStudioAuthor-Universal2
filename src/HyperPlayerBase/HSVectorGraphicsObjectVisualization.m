#import "HSVectorGraphicsObjectVisualization.h"
@implementation HSVectorGraphicsObjectVisualization
- (id)expandedEffectRenderLayerSubtreeWithVisualizationOptions:(id)aOptions
{
    return [self renderLayerWithIdentifier:[self vectorGraphicsRenderLayerIdentifierForVisualizationOptions:aOptions]
                         precreateSelector:@selector(precreateVectorGraphicsRenderLayerForVisualizationOptions:)
                      visualizationOptions:aOptions];
}
- (id)precreateVectorGraphicsRenderLayerForVisualizationOptions:(id)aOptions
{
    return [[HSVectorGraphicsObjectRenderLayer alloc] initWithHyperObject:[self hyperObject]];
}
- (id)vectorGraphicsRenderLayerIdentifierForVisualizationOptions:(id)aOptions
{
    return @"HSVectorGraphicsObjectRenderLayerIdentifier";
}
@end
