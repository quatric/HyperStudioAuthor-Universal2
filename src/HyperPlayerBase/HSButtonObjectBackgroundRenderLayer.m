#import "HSButtonObjectBackgroundRenderLayer.h"
// A button's background: forwards everything to the layer for its style
// (system cell or bordered shape; none otherwise), switching layers when
// the style changes.
@implementation HSButtonObjectBackgroundRenderLayer
- (void)renderLayerWantsToReexpand:(id)aReexpand
{
    [self notifyObserversWithSelector:@selector(renderLayerWantsToReexpand:)];
}
- (void)renderLayerDidChangeBoundingRegion:(id)aRegion
{
    [self boundingRegionDidChange];
}
- (void)renderLayerDidChangeVisualizationMaskAttributesSet:(id)aSet
{
    [self visualizationMaskAttributesSetDidChange:nil];
}
- (void)renderLayerDidChangeVisualizationAttributesSet:(id)aSet
{
    [self visualizationAttributesSetDidChange:nil];
}
- (void)getRenderCacheValidness:(float *)aValidness validnessEvaluator:(id *)aEvaluator includeScaling:(BOOL *)aScaling includeSkewing:(BOOL *)aSkewing includeRotation:(BOOL *)aRotation includeDevicePointAligning:(BOOL *)aAligning forRegion:(id)aRegion affineTransform:(CGAffineTransform)aTransform transformationIntent:(struct HyperPlayerBase_anon12 *)aIntent
{
    [[self currentBackgroundRenderLayer] getRenderCacheValidness:aValidness validnessEvaluator:aEvaluator includeScaling:aScaling includeSkewing:aSkewing includeRotation:aRotation includeDevicePointAligning:aAligning forRegion:aRegion affineTransform:aTransform transformationIntent:aIntent];
}
- (BOOL)willCacheRenderingInRegion:(id)aRegion withTransformationIntent:(struct HyperPlayerBase_anon12 *)aIntent countOnRenderSublayersInfluence:(NSInteger)aInfluence force:(BOOL)aForce
{
    return [[self currentBackgroundRenderLayer] willCacheRenderingInRegion:aRegion withTransformationIntent:aIntent countOnRenderSublayersInfluence:aInfluence force:aForce];
}
- (BOOL)unionBoundingRegionOfLocalVisualAttributeSet:(id)aSet ofHyperObject:(id)aObject withInfo:(id)aInfo withRegion:(id *)aRegion
{
    return [[self currentBackgroundRenderLayer] unionBoundingRegionOfConcreteAttributeSet:aSet ofHyperObject:aObject withInfo:aInfo withRegion:aRegion];
}
- (id)calculateBoundingRegion
{
    return [[self currentBackgroundRenderLayer] boundingRegion];
}
- (BOOL)requiresTransparencyLayer
{
    return [[self currentBackgroundRenderLayer] requiresTransparencyLayer];
}
- (BOOL)isEmpty
{
    return [[self currentBackgroundRenderLayer] isEmpty];
}
- (void)predrawRegion:(id)aRegion withDelegate:(id)aDelegate
{
    [[self currentBackgroundRenderLayer] predrawRegion:aRegion withDelegate:aDelegate];
}
// Plus the style itself.
- (void)fillVisualizationMaskAttributesSet:(id)aSet
{
    id object = [self hyperObject];
    [[self currentBackgroundRenderLayer] fillVisualizationMaskAttributesSet:aSet];
    [aSet addAttribute:@protocol(HSButtonObjectBackgroundStyleIdentifierAttribute) forObject:object];
}
- (void)fillVisualizationAttributesSet:(id)aSet
{
    id object = [self hyperObject];
    [[self currentBackgroundRenderLayer] fillVisualizationAttributesSet:aSet];
    [aSet addAttribute:@protocol(HSButtonObjectBackgroundStyleIdentifierAttribute) forObject:object];
}
- (id)currentBackgroundRenderLayer
{
    if (![_currentBackgroundStyle isEqualToString:[_buttonAttributes backgroundStyle]]) {
        [_currentBackgroundStyle release];
        _currentBackgroundStyle = [[_buttonAttributes backgroundStyle] copy];
        [_currentBackgroundRenderLayer removeObserver:self];
        [_currentBackgroundRenderLayer release];
        _currentBackgroundRenderLayer = [[self preferredBackgroundRenderLayer] retain];
        [_currentBackgroundRenderLayer addObserver:self];
        [self visualizationAttributesSetDidChange:nil];
        [self boundingRegionDidChange];
    }
    return _currentBackgroundRenderLayer;
}
- (id)preferredBackgroundRenderLayer
{
    NSString *style = [_buttonAttributes backgroundStyle];
    if ([style isEqualToString:@"HSButtonObjectSystemBackgroundStyle"])
        return [[[HSBackgroundCellRenderLayer alloc] initWithHyperObject:[self hyperObject]] autorelease];
    if ([style isEqualToString:@"HSButtonObjectShapeBackgroundStyle"])
        return [[[HSBorderedBackgroundRenderLayer alloc] initWithHyperObject:[self hyperObject]] autorelease];
    return nil;
}
- (id)buttonAttributes
{
    return _buttonAttributes;
}
- (void)dealloc
{
    [_buttonAttributes release];
    [_currentBackgroundRenderLayer removeObserver:self];
    [_currentBackgroundRenderLayer release];
    [_currentBackgroundStyle release];
    [super dealloc];
}
- (id)initWithHyperObject:(id)aObject cachingPolicy:(NSInteger)aPolicy
{
    self = [super initWithHyperObject:aObject cachingPolicy:aPolicy];
    if (self == nil)
        return nil;
    _buttonAttributes = [[aObject queryHyperInterface:@protocol(HSButtonObjectAttributes)] retain];
    if (_buttonAttributes == nil) {
        [self release];
        return nil;
    }
    return self;
}
@end
