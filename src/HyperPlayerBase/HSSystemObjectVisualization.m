#import "HSSystemObjectVisualization.h"
// The visualization of a system control object (a real NSView drawn into the
// card): its effect layer is the system view layer, and it has no show/hide
// transition layer of its own. A placeholder visualization (drawing a
// placeholder instead of the view) uses its own layer identifiers.
@implementation HSSystemObjectVisualization
- (id)expandedShowHideTransitionRenderLayerSubtreeWithVisualizationOptions:(id)aOptions
{
    return [self expandedShadowAndOpacityRenderLayerSubtreeWithVisualizationOptions:aOptions];
}
- (id)expandedEffectRenderLayerSubtreeWithVisualizationOptions:(id)aOptions
{
    return [self renderLayerWithIdentifier:[self systemViewRenderLayerIdentifierForVisualizationOptions:aOptions]
                         precreateSelector:@selector(precreateSystemViewRenderLayerForVisualizationOptions:)
                      visualizationOptions:aOptions];
}
// Returned retained, as in the original (precreated layers are owned by the
// caller).
- (id)precreateSystemViewRenderLayerForVisualizationOptions:(id)aOptions
{
    return [[HSGenericSystemViewRenderLayer alloc] initWithHyperObject:[self hyperObject] cachingPolicy:0 drawPlaceholderView:_drawsPlaceholderView];
}
- (id)systemViewRenderLayerIdentifierForVisualizationOptions:(id)aOptions
{
    return _drawsPlaceholderView ? @"HSSystemViewRenderLayerIdentifier+PlaceholderView" : @"HSSystemViewRenderLayerIdentifier";
}
- (id)effectPlaceholderRenderLayerIdentifierForVisualizationOptions:(id)aOptions
{
    NSString *identifier = [super effectPlaceholderRenderLayerIdentifierForVisualizationOptions:aOptions];
    return _drawsPlaceholderView ? [identifier stringByAppendingString:@"+PlaceholderView"] : identifier;
}
- (id)effectRenderLayerIdentifierForVisualizationOptions:(id)aOptions
{
    NSString *identifier = [super effectRenderLayerIdentifierForVisualizationOptions:aOptions];
    return _drawsPlaceholderView ? [identifier stringByAppendingString:@"+PlaceholderView"] : identifier;
}
- (id)showHideTransitionRenderLayerIdentifierForVisualizationOptions:(id)aOptions
{
    NSString *identifier = [super showHideTransitionRenderLayerIdentifierForVisualizationOptions:aOptions];
    return _drawsPlaceholderView ? [identifier stringByAppendingString:@"+PlaceholderView"] : identifier;
}
// The original returns -1 (all bits) for YES, which a bool can't hold.
- (BOOL)drawsPlaceholderView
{
    return _drawsPlaceholderView;
}
- (id)initWithHyperObject:(id)aObject visualizationProtocol:(id)aProtocol drawPlaceholderView:(BOOL)aView
{
    self = [super initWithHyperObject:aObject visualizationProtocol:aProtocol];
    if (self != nil)
        _drawsPlaceholderView = aView ? 1 : 0;
    return self;
}
- (id)initWithHyperObject:(id)aObject visualizationProtocol:(id)aProtocol
{
    return [self initWithHyperObject:aObject visualizationProtocol:aProtocol drawPlaceholderView:NO];
}
- (BOOL)ignoresTransparency
{
    return NO;
}
@end
