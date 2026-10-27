#import "HSImageObjectCropVisualization.h"
@implementation HSImageObjectCropVisualization
// While cropping, the image is shown plain: no show/hide transition, no
// effect, only the multi clip around the image.
- (id)expandedShowHideTransitionRenderLayerSubtreeWithVisualizationOptions:(id)aOptions
{
    return [self expandedShadowAndOpacityRenderLayerSubtreeWithVisualizationOptions:aOptions];
}
- (id)expandedEffectRenderLayerSubtreeWithVisualizationOptions:(id)aOptions
{
    id layer = [self expandableRenderLayerWithIdentifier:[self multiClipRenderLayerIdentifierForVisualizationOptions:aOptions]
                                       precreateSelector:@selector(precreateMultiClipRenderLayerForVisualizationOptions:)
                                    visualizationOptions:aOptions];
    if (layer != nil) {
        id image = [self renderLayerWithIdentifier:@"HSImageRenderLayerIdentifier"
                                 precreateSelector:@selector(precreateImageRenderLayerForVisualizationOptions:)
                              visualizationOptions:aOptions];
        if (image != nil)
            [layer addRenderSublayer:image forRole:@"HSImageRenderLayerRole" asRoot:NO addingTransparencyLayerRequirement:YES];
    }
    return layer;
}
- (id)multiClipRenderLayerIdentifierForVisualizationOptions:(id)aOptions
{
    return [[super multiClipRenderLayerIdentifierForVisualizationOptions:aOptions] stringByAppendingString:@"-HSImageObjectCropVisualization"];
}
- (id)effectPlaceholderRenderLayerIdentifierForVisualizationOptions:(id)aOptions
{
    return [[super effectPlaceholderRenderLayerIdentifierForVisualizationOptions:aOptions] stringByAppendingString:@"-HSImageObjectCropVisualization"];
}
- (id)effectRenderLayerIdentifierForVisualizationOptions:(id)aOptions
{
    return [[super effectRenderLayerIdentifierForVisualizationOptions:aOptions] stringByAppendingString:@"-HSImageObjectCropVisualization"];
}
- (BOOL)canBeHidden
{
    return NO;
}
@end
