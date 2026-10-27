#import "HSButtonObjectVisualization.h"
// A button's visualization: a group render layer holding the button's
// background layer and its content cell. Its layer identifiers carry the
// visualization protocol's name, so the button's layers aren't shared with
// other visualizations of the same object.
@implementation HSButtonObjectVisualization
- (Class)backgroundRenderLayerClass
{
    return [HSButtonObjectBackgroundRenderLayer class];
}
// Buttons have no show/hide transition layer.
- (id)expandedShowHideTransitionRenderLayerSubtreeWithVisualizationOptions:(id)aOptions
{
    return [self expandedShadowAndOpacityRenderLayerSubtreeWithVisualizationOptions:aOptions];
}
// The button group with its background and content cell. (The content cell's
// identifier isn't made per protocol, as in the original.)
- (id)expandedEffectRenderLayerSubtreeWithVisualizationOptions:(id)aOptions
{
    id group = [self expandableRenderLayerWithIdentifier:[self buttonGroupRenderLayerIdentifierForVisualizationOptions:aOptions]
                                        precreateSelector:@selector(precreateButtonGroupRenderLayerForVisualizationOptions:)
                                     visualizationOptions:aOptions];
    if (group == nil)
        return nil;
    id background = [self renderLayerWithIdentifier:[self HSButtonObjectVisualization_visualizationIdentifierWithGenericIdentifier:@"HSButtonObjectBackgroundRenderLayerIdentifier"]
                                   precreateSelector:@selector(precreateButtonObjectBackgroundRenderLayerForVisualizationOptions:)
                                visualizationOptions:aOptions];
    if (background != nil)
        [group addRenderSublayer:background forRole:@"HSButtonBackgroundRenderLayerRole" asRoot:NO addingTransparencyLayerRequirement:YES];
    id cell = [self renderLayerWithIdentifier:@"HSContentCellRenderLayerIdentifier"
                             precreateSelector:@selector(precreateContentCellRenderLayerForVisualizationOptions:)
                          visualizationOptions:aOptions];
    if (cell != nil)
        [group addRenderSublayer:cell forRole:@"HSContentCellRenderLayerRole" asRoot:NO addingTransparencyLayerRequirement:YES];
    return group;
}
// The precreate methods return retained layers.
- (id)precreateContentCellRenderLayerForVisualizationOptions:(id)aOptions
{
    return [[HSContentCellRenderLayer alloc] initWithHyperObject:[self hyperObject]];
}
- (id)precreateButtonObjectBackgroundRenderLayerForVisualizationOptions:(id)aOptions
{
    return [[[self backgroundRenderLayerClass] alloc] initWithHyperObject:[self hyperObject]];
}
- (id)precreateButtonGroupRenderLayerForVisualizationOptions:(id)aOptions
{
    return [[HSGenericGroupRenderLayer alloc] initWithHyperObject:[self hyperObject]];
}
- (id)buttonGroupRenderLayerIdentifierForVisualizationOptions:(id)aOptions
{
    return [self HSButtonObjectVisualization_visualizationIdentifierWithGenericIdentifier:@"HSButtonGroupRenderLayerIdentifier"];
}
- (id)effectPlaceholderRenderLayerIdentifierForVisualizationOptions:(id)aOptions
{
    return [self HSButtonObjectVisualization_visualizationIdentifierWithGenericIdentifier:
                     [super effectPlaceholderRenderLayerIdentifierForVisualizationOptions:aOptions]];
}
- (id)effectRenderLayerIdentifierForVisualizationOptions:(id)aOptions
{
    return [self HSButtonObjectVisualization_visualizationIdentifierWithGenericIdentifier:
                     [super effectRenderLayerIdentifierForVisualizationOptions:aOptions]];
}
- (id)showHideTransitionRenderLayerIdentifierForVisualizationOptions:(id)aOptions
{
    return [self HSButtonObjectVisualization_visualizationIdentifierWithGenericIdentifier:
                     [super showHideTransitionRenderLayerIdentifierForVisualizationOptions:aOptions]];
}
// "<identifier>-<protocol name>". (The original asked a Tiger Protocol object
// for its -name; protocol_getName does it since 10.5.)
- (id)HSButtonObjectVisualization_visualizationIdentifierWithGenericIdentifier:(id)aIdentifier
{
    return [NSString stringWithFormat:@"%@-%s", aIdentifier, protocol_getName([self visualizationProtocol])];
}
- (BOOL)ignoresTransparency
{
    return NO;
}
@end
