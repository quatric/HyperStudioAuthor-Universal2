#import "HSWebObjectVisualization.h"
@implementation HSWebObjectVisualization
- (id)expandedShowHideTransitionRenderLayerSubtreeWithVisualizationOptions:(id)aOptions
{
    return [self renderLayerWithIdentifier:@"HSWebElementRenderLayerIdentifier"
                         precreateSelector:@selector(precreateWebElementRenderLayerForVisualizationOptions:)
                      visualizationOptions:aOptions];
}
- (id)precreateWebElementRenderLayerForVisualizationOptions:(id)aOptions
{
    return [[HSWebElementRenderLayer alloc] initWithHyperObject:[self hyperObject]];
}
- (id)showHideTransitionRenderLayerIdentifierForVisualizationOptions:(id)aOptions
{
    return @"HSShowHideTransitionRenderLayerIdentifier";
}
- (void)dealloc
{
    [_webElementAttributes release];
    [super dealloc];
}
// Only for objects with web element attributes.
- (id)initWithHyperObject:(id)aObject visualizationProtocol:(id)aProtocol
{
    self = [super initWithHyperObject:aObject visualizationProtocol:aProtocol];
    if (self == nil)
        return nil;
    _webElementAttributes = [[aObject queryHyperInterface:@protocol(HSWebElementAttributes)] retain];
    if (_webElementAttributes == nil) {
        [self release];
        return nil;
    }
    return self;
}
@end
