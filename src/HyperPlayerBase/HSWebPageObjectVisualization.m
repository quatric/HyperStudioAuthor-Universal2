#import "HSWebPageObjectVisualization.h"
@implementation HSWebPageObjectVisualization
- (id)expandedEffectRenderLayerSubtreeWithVisualizationOptions:(id)aOptions
{
    return [self renderLayerWithIdentifier:@"HSWebPageRenderLayerIdentifier"
                         precreateSelector:@selector(precreateWebPageObjectRenderLayerForVisualizationOptions:)
                      visualizationOptions:aOptions];
}
- (id)precreateWebPageObjectRenderLayerForVisualizationOptions:(id)aOptions
{
    return [[HSGenericWebPageObjectRenderLayer alloc] initWithHyperObject:[self hyperObject]];
}
- (BOOL)ignoresTransparency
{
    return NO;
}
@end
