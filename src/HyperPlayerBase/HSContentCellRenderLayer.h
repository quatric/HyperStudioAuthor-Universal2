#import "HyperPlayerBasePrefix.h"
#import "HSGenericRenderLayer.h"


@interface HSContentCellRenderLayer : HSGenericRenderLayer
{
    id<HSGeometryAttributes> _geometryAttributes;
    id<HSButtonObjectAttributes> _buttonAttributes;
    id<HSTextAttributes> _textAttributes;
    id<HSSystemButtonInteractiveModeAttributes> _highlightingAttributes;
    id<HSButtonObjectSystemStyleBackgroundAttributes> _systemStyleBackgroundAttributes;
    id<HSButtonObjectShapeBackgroundAttributes> _shapeBackgroundAttributes;
    id<HSCardObjectAttributes> _cardObjectAttributes;
    HSCellVisualizationView *_contentCellVisualizationView;
    NSSize _contentCellSize;
    unsigned int _areContentCellIconAttributesValid:1;
    unsigned int _areContentCellTitleAndHighlightAttributesValid:1;
}
- (BOOL)cacheRenderingInRegion:(id)aRegion withAffineTransform:(CGAffineTransform)aTransform validness:(CGFloat)aValidness validnessEvaluator:(id)aEvaluator delegate:(id)aDelegate force:(BOOL)aForce share:(BOOL)aShare resultCache:(id *)aCache;
- (void)getRenderCacheValidness:(float *)aValidness validnessEvaluator:(id *)aEvaluator includeScaling:(BOOL *)aScaling includeSkewing:(BOOL *)aSkewing includeRotation:(BOOL *)aRotation includeDevicePointAligning:(BOOL *)aAligning forRegion:(id)aRegion affineTransform:(CGAffineTransform)aTransform transformationIntent:(struct HyperPlayerBase_anon12 *)aIntent;
- (BOOL)willCacheRenderingInRegion:(id)aRegion force:(BOOL)aForce;
- (id)calculateBoundingRegion;
- (void)fillBoundingRegionAttributesSet:(id)aSet;
- (BOOL)isEmpty;
- (void)predrawRegion:(id)aRegion withDelegate:(id)aDelegate;
- (BOOL)HSContentCellRenderLayer_prepareContentCellVisualizationViewToDrawRegion:(id)aRegion sourceRect:(NSRect *)aRect destinationRect:(NSRect *)aRect2;
- (NSRect)HSContentCellRenderLayer_viewDestinationRectAndContentCellFrame:(NSRect *)aFrame;
- (void)HSContentCellRenderLayer_validateContentCell;
- (void)HSContentCellRenderLayer_buttonTitleAndHighlightAttributeDidChange:(id)aChange;
- (void)HSContentCellRenderLayer_buttonIconAttributeDidChange:(id)aChange;
- (void)fillVisualizationAttributesSet:(id)aSet;
- (void)dealloc;
- (id)initWithHyperObject:(id)aObject cachingPolicy:(NSInteger)aPolicy;
@end

@interface HSContentCellRenderLayer_ButtonCell : NSButtonCell
{
}
- (NSRect)drawTitle:(id)aTitle withFrame:(NSRect)aFrame inView:(id)aView;
@end

