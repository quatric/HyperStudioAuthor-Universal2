#import "HSTextObjectVisualization.h"
@implementation HSTextObjectVisualization
- (id)expandedEffectRenderLayerSubtreeWithVisualizationOptions:(id)aOptions
{
    return [self renderLayerWithIdentifier:@"HSTextRenderLayerIdentifier"
                         precreateSelector:@selector(precreateTextRenderLayerForVisualizationOptions:)
                      visualizationOptions:aOptions];
}
- (id)precreateTextRenderLayerForVisualizationOptions:(id)aOptions
{
    return [[HSGenericTextRenderLayer alloc] initWithHyperObject:[self hyperObject]];
}
- (BOOL)ignoresTransparency
{
    return NO;
}
@end
