#import "HSMovieObjectVisualization.h"
@implementation HSMovieObjectVisualization
// A group of the effect subtree and, on top, the movie controller. Without the
// effect subtree there is none; a missing controller is left out.
- (id)expandedShadowAndOpacityRenderLayerSubtreeWithVisualizationOptions:(id)aOptions
{
    id groupLayer = [self expandableRenderLayerWithIdentifier:@"HSMovieGroupRenderLayerIdentifier"
                                            precreateSelector:@selector(precreateMovieGroupRenderLayerForVisualizationOptions:)
                                         visualizationOptions:aOptions];
    if (groupLayer == nil)
        return nil;
    id effectLayer = [super expandedShadowAndOpacityRenderLayerSubtreeWithVisualizationOptions:aOptions];
    if (effectLayer == nil)
        return nil;
    [groupLayer addRenderSublayer:effectLayer forRole:@"HSEffectRenderLayerRole" asRoot:NO addingTransparencyLayerRequirement:YES];
    id controllerLayer = [self renderLayerWithIdentifier:@"HSMovieControllerRenderLayerIdentifier"
                                       precreateSelector:@selector(precreateMovieControllerRenderLayerForVisualizationOptions:)
                                    visualizationOptions:aOptions];
    if (controllerLayer != nil)
        [groupLayer addRenderSublayer:controllerLayer forRole:@"HSMovieControllerRenderLayerRole" asRoot:NO addingTransparencyLayerRequirement:YES];
    return groupLayer;
}
- (id)expandedEffectRenderLayerSubtreeWithVisualizationOptions:(id)aOptions
{
    return [self renderLayerWithIdentifier:@"HSMovieRenderLayerIdentifier"
                         precreateSelector:@selector(precreateMovieRenderLayerForVisualizationOptions:)
                      visualizationOptions:aOptions];
}
- (id)precreateMovieControllerRenderLayerForVisualizationOptions:(id)aOptions
{
    return [[HSMovieControllerRenderLayer alloc] initWithHyperObject:[self hyperObject]];
}
- (id)precreateMovieRenderLayerForVisualizationOptions:(id)aOptions
{
    return [[HSGenericCoreVideoMovieRenderLayer alloc] initWithHyperObject:[self hyperObject]];
}
- (id)precreateMovieGroupRenderLayerForVisualizationOptions:(id)aOptions
{
    return [[HSGenericGroupRenderLayer alloc] initWithHyperObject:[self hyperObject]];
}
@end
