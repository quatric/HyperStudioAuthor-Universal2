#import "HSGenericOpacityRenderLayer.h"
@implementation HSGenericOpacityRenderLayer
// An opacity change of the object grows the region by this layer's bounds.
- (BOOL)unionBoundingRegionOfSublayersVisualAttributeSet:(id)aSet ofHyperObject:(id)aObject withInfo:(id)aInfo withRegion:(id *)aRegion
{
    if ([aObject hyperIdentifier] == [[self hyperObject] hyperIdentifier]
        && [aSet containsProtocol:@protocol(HSOpacityAttribute)]) {
        if (*aRegion == nil)
            *aRegion = [HSMutableRegion region];
        return [self unionBoundingRegionWithRegion:*aRegion];
    }
    return [super unionBoundingRegionOfSublayersVisualAttributeSet:aSet ofHyperObject:aObject withInfo:aInfo withRegion:aRegion];
}
// Invisible below 1/512, drawn directly above 511/512, otherwise through a
// transparency layer at that alpha.
- (void)drawRenderSublayersInRegion:(id)aRegion withDelegate:(id)aDelegate
{
    float opacity = [_opacityAttributes hyperOpacity];
    if (opacity <= 0.001953125f)
        return;
    NSGraphicsContext *context = [NSGraphicsContext currentContext];
    if (opacity >= 0.9980469f) {
        [super drawRenderSublayersInRegion:aRegion withDelegate:aDelegate];
        return;
    }
    CGContextSetAlpha([context CGContext], opacity);
    [context beginHyperTransparencyLayerRequest];
    [super drawRenderSublayersInRegion:aRegion withDelegate:aDelegate];
    [context endHyperTransparencyLayerRequest];
}
- (void)fillVisualizationMaskAttributesSet:(id)aSet
{
    [aSet addAttribute:@protocol(HSOpacityAttribute) forObject:[self hyperObject]];
    [super fillVisualizationMaskAttributesSet:aSet];
}
- (void)fillVisualizationAttributesSet:(id)aSet
{
    [aSet addAttribute:@protocol(HSOpacityAttribute) forObject:[self hyperObject]];
    [super fillVisualizationAttributesSet:aSet];
}
- (void)dealloc
{
    [_opacityAttributes release];
    [super dealloc];
}
- (id)initWithHyperObject:(id)aObject renderSublayerCapacity:(NSUInteger)aCapacity cachingPolicy:(NSInteger)aPolicy
{
    self = [super initWithHyperObject:aObject renderSublayerCapacity:aCapacity cachingPolicy:aPolicy];
    if (self != nil) {
        _opacityAttributes = [[aObject queryHyperInterface:@protocol(HSOpacityAttributes)] retain];
        if (_opacityAttributes == nil) {
            [self release];
            return nil;
        }
    }
    return self;
}
@end
