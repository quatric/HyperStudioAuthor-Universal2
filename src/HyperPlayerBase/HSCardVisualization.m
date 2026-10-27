#import "HSCardVisualization.h"
@implementation HSCardVisualization
// The card root group: background image, then the visual subobjects group,
// whose sublayers are expanded from there. With
// HSSubobjectsOnlyVisualizationOption the plain group tree is used.
- (id)expandedRenderLayerTreeWithVisualizationOptions:(id)aOptions
{
    if ([[aOptions objectForKey:@"HSSubobjectsOnlyVisualizationOption"] boolValue])
        return [super expandedRenderLayerTreeWithVisualizationOptions:aOptions];
    id rootIdentifier = [self cardRootRenderLayerIdentifierForVisualizationOptions:aOptions];
    if (rootIdentifier == nil)
        return nil;
    id root = [self expandableRenderLayerWithIdentifier:rootIdentifier
                                      precreateSelector:@selector(precreateCardRootRenderLayerForVisualizationOptions:)
                                   visualizationOptions:aOptions];
    if (root == nil)
        return nil;
    id background = [self renderLayerWithIdentifier:@"HSBackgroundRenderLayerIdentifier"
                                  precreateSelector:@selector(precreateBackgroundRenderLayerForVisualizationOptions:)
                               visualizationOptions:aOptions];
    if (background != nil)
        [root addRenderSublayer:background forRole:@"HSBackgroundRenderLayerRole" asRoot:NO addingTransparencyLayerRequirement:YES];
    id subobjectsIdentifier = [self visualSubobjectsRenderLayerIdentifierForVisualizationOptions:aOptions];
    id subobjects = subobjectsIdentifier != nil
        ? [self expandableRenderLayerWithIdentifier:subobjectsIdentifier
                                  precreateSelector:@selector(precreateVisualSubobjectsRenderLayerForVisualizationOptions:)
                               visualizationOptions:aOptions] : nil;
    if (subobjects != nil) {
        [root addRenderSublayer:subobjects forRole:@"HSVisualSubobjectsRenderLayerRole" asRoot:NO addingTransparencyLayerRequirement:YES];
        NSUInteger count = [root renderSublayerCount];
        id path = count != 0 ? [HSIndexPath indexPathWithIndex:count - 1] : nil;
        if (path != nil)
            [self expandWithVisualSubobjectsRenderLayersRenderLayerTreeWithRoot:root fromRenderLayerAtPath:path withVisualizationOptions:aOptions];
    }
    return root;
}
- (id)precreateCardRootRenderLayerForVisualizationOptions:(id)aOptions
{
    return [[HSGenericGroupRenderLayer alloc] initWithHyperObject:[self hyperObject]];
}
- (id)precreateBackgroundRenderLayerForVisualizationOptions:(id)aOptions
{
    return [[HSGenericImageRenderLayer alloc] initWithHyperObject:[self hyperObject] cachingPolicy:1];
}
- (id)precreateVisualSubobjectsRenderLayerForVisualizationOptions:(id)aOptions
{
    id layer = [[HSGenericInternalGroupRenderLayer alloc] initWithHyperObject:[self hyperObject]];
    [layer setAutogroupsRenderSublayersForEfficientCaching:YES];
    return layer;
}
// Identifiers are per visualization protocol. (The original asked a Tiger
// Protocol object for its -name; protocol_getName does it since 10.5.)
- (id)visualSubobjectsRenderLayerIdentifierForVisualizationOptions:(id)aOptions
{
    NSString *identifier = [NSString stringWithFormat:@"HSVisualSubobjectsRenderLayerIdentifier-%s",
                            protocol_getName([self visualizationProtocol])];
    return identifier != nil ? [self renderLayerIdentifierAppendingSuffixForVisualizationOptions:aOptions toBaseIdentifier:identifier] : nil;
}
- (id)cardRootRenderLayerIdentifierForVisualizationOptions:(id)aOptions
{
    NSString *identifier = [NSString stringWithFormat:@"HSCardRootRenderLayerIdentifier-%s",
                            protocol_getName([self visualizationProtocol])];
    return identifier != nil ? [self renderLayerIdentifierAppendingSuffixForVisualizationOptions:aOptions toBaseIdentifier:identifier] : nil;
}
@end
