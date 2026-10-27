#import "HSHeadlineObjectVisualization.h"
@implementation HSHeadlineObjectVisualization
- (id)expandedEffectRenderLayerSubtreeWithVisualizationOptions:(id)aOptions
{
    return [self renderLayerWithIdentifier:@"HSVectorRenderLayerIdentifier"
                         precreateSelector:@selector(precreateVectorRenderLayerForVisualizationOptions:)
                      visualizationOptions:aOptions];
}
- (id)precreateVectorRenderLayerForVisualizationOptions:(id)aOptions
{
    return [[HSGenericVectorRenderLayer alloc] initWithHyperObject:[self hyperObject]];
}
- (BOOL)ignoresTransparency
{
    return NO;
}
@end
