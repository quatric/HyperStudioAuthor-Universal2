#import "HSHitTestingVectorGraphicsObjectVisualization.h"
// The editor's hit testing look of a vector graphics object: no show/hide
// transition, its own layer and identifiers.
@implementation HSHitTestingVectorGraphicsObjectVisualization
- (id)expandedShowHideTransitionRenderLayerSubtreeWithVisualizationOptions:(id)aOptions
{
    return [self expandedShadowAndOpacityRenderLayerSubtreeWithVisualizationOptions:aOptions];
}
- (id)precreateVectorGraphicsRenderLayerForVisualizationOptions:(id)aOptions
{
    return [[HSHitTestingVectorGraphicsObjectRenderLayer alloc] initWithHyperObject:[self hyperObject]];
}
- (id)vectorGraphicsRenderLayerIdentifierForVisualizationOptions:(id)aOptions
{
    return [[super vectorGraphicsRenderLayerIdentifierForVisualizationOptions:aOptions] stringByAppendingString:@"-HSHitTestingVisualization"];
}
- (id)effectPlaceholderRenderLayerIdentifierForVisualizationOptions:(id)aOptions
{
    return [[super effectPlaceholderRenderLayerIdentifierForVisualizationOptions:aOptions] stringByAppendingString:@"-HSHitTestingVisualization"];
}
- (id)effectRenderLayerIdentifierForVisualizationOptions:(id)aOptions
{
    return [[super effectRenderLayerIdentifierForVisualizationOptions:aOptions] stringByAppendingString:@"-HSHitTestingVisualization"];
}
- (id)showHideTransitionRenderLayerIdentifierForVisualizationOptions:(id)aOptions
{
    return [[super showHideTransitionRenderLayerIdentifierForVisualizationOptions:aOptions] stringByAppendingString:@"-HSHitTestingVisualization"];
}
// (The original asked the Protocol object with -conformsTo: before 10.5.)
- (BOOL)canBeHidden
{
    return !protocol_conformsToProtocol([self visualizationProtocol], @protocol(HSEditorHitTestingVisualization));
}
@end
