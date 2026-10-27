#import "HSGenericRenderer.h"

// Draws a visualization through a lazily built render layer tree.
@implementation HSGenericRenderer
- (void)renderLayerWantsToReexpand:(id)aReexpand
{
    [self invalidateRenderLayerTree];
}
- (void)renderLayerDidChangeBoundingRegion:(id)aRegion
{
}
- (void)renderLayerDidChangeVisualizationMaskAttributesSet:(id)aSet
{
}
- (void)renderLayerDidChangeVisualizationAttributesSet:(id)aSet
{
}
- (void)invalidateRenderLayerTree
{
    _isRenderLayerTreeValid = 0;
}
// The delegate, when given, is wrapped for the root layer and may veto or
// observe rendering and drawing.
- (void)drawRegion:(id)aRegion withDelegate:(id)aDelegate
{
    id layerDelegate = nil;
    if (aDelegate) {
        HSIndexPath *indexPath = [[[HSIndexPath alloc] init] autorelease];
        if (!indexPath)
            return;
        layerDelegate = [HSGenericRenderLayerDelegate delegateWithRenderDelegate:aDelegate renderer:self renderLayerIndexPath:indexPath];
        if (!layerDelegate)
            return;
        if (![layerDelegate renderLayerShouldBeRenderedInRegion:aRegion])
            return;
    }
    id root = [self rootRenderLayer];
    if (!root)
        return;
    HSMutableRegion *region = [HSMutableRegion region];
    if (!region)
        return;
    [root unionBoundingRegionWithRegion:region];
    [region intersectRegion:aRegion];
    [NSGraphicsContext saveGraphicsState];
    if (!layerDelegate || [layerDelegate renderLayerShouldBeDrawnInRegion:region intoRenderCache:NO]) {
        [NSGraphicsContext saveGraphicsState];
        [root drawRegion:region withDelegate:layerDelegate];
        [NSGraphicsContext restoreGraphicsState];
        [layerDelegate renderLayerIsDrawnInRegion:region intoRenderCache:NO];
    }
    [NSGraphicsContext restoreGraphicsState];
    [layerDelegate renderLayerIsRenderedInRegion:region];
}
- (id)description
{
    return [NSString stringWithFormat:@"<%@: 0x%x> {visualization = %@; visualization options = %@; render layer tree = %@}", NSStringFromClass([self class]), (unsigned int)(uintptr_t)self, _visualization, _visualizationOptions, [self rootRenderLayer]];
}
- (BOOL)unionBoundingRegionOfAttribute:(id)aAttribute ofHyperObject:(id)aObject withInfo:(id)aInfo withRegion:(id)aRegion
{
    return [[self rootRenderLayer] unionBoundingRegionOfAttribute:aAttribute ofHyperObject:aObject withInfo:aInfo withRegion:aRegion];
}
- (id)boundingRegionOfAttribute:(id)aAttribute ofHyperObject:(id)aObject withInfo:(id)aInfo
{
    return [[self rootRenderLayer] boundingRegionOfAttribute:aAttribute ofHyperObject:aObject withInfo:aInfo];
}
- (BOOL)unionBoundingRegionOfAttributeSet:(id)aSet ofHyperObject:(id)aObject withInfo:(id)aInfo withRegion:(id)aRegion
{
    return [[self rootRenderLayer] unionBoundingRegionOfAttributeSet:aSet ofHyperObject:aObject withInfo:aInfo withRegion:aRegion];
}
- (id)boundingRegionOfAttributeSet:(id)aSet ofHyperObject:(id)aObject withInfo:(id)aInfo
{
    return [[self rootRenderLayer] boundingRegionOfAttributeSet:aSet ofHyperObject:aObject withInfo:aInfo];
}
- (BOOL)unionBoundingRegionWithRegion:(id)aRegion
{
    return [[self rootRenderLayer] unionBoundingRegionWithRegion:aRegion];
}
- (id)boundingRegion
{
    return [[self rootRenderLayer] boundingRegion];
}
// Rebuilds the tree when it was invalidated.
- (id)rootRenderLayer
{
    if (!_rootRenderLayer || !_isRenderLayerTreeValid) {
        [_rootRenderLayer removeObserver:self];
        [_rootRenderLayer autorelease];
        _rootRenderLayer = [[_visualization buildRenderLayerTreeWithVisualizationOptions:_visualizationOptions] retain];
        [_rootRenderLayer addObserver:self];
        _isRenderLayerTreeValid = _rootRenderLayer != nil;
    }
    return _rootRenderLayer;
}
- (BOOL)drawsOnlySubobjects
{
    return [[_visualizationOptions objectForKey:@"HSSubobjectsOnlyVisualizationOption"] boolValue];
}
- (id)ignoredSubobjects
{
    id ignored = [_visualizationOptions objectForKey:@"HSIgnoredSubobjectsVisualizationOption"];
    return ignored ? ignored : [NSSet set];
}
- (id)visualizationOptions
{
    return _visualizationOptions;
}
- (id)visualization
{
    return _visualization;
}
- (void)dealloc
{
    [_rootRenderLayer removeObserver:self];
    [_rootRenderLayer release];
    [_visualizationOptions release];
    [_visualization release];
    [super dealloc];
}
// A renderer needs a visualization.
- (id)init
{
    [super release];
    return nil;
}
- (id)initWithVisualization:(id)aVisualization options:(id)aOptions
{
    self = [super init];
    if (!self)
        return nil;
    if (aOptions) {
        _visualizationOptions = [aOptions NSE_deepCopy];
        if (!_visualizationOptions) {
            [super release];
            return nil;
        }
    }
    _visualization = [aVisualization retain];
    return self;
}
@end
