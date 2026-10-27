#import "HyperPlayerBasePrefix.h"
#import "HSGenericRenderLayer.h"


@interface HSBackgroundCellRenderLayer : HSGenericRenderLayer
{
    id<HSGeometryAttributes> _geometryAttributes;
    id<HSButtonObjectAttributes> _buttonAttributes;
    id<HSCardObjectAttributes> _cardObjectAttributes;
    id<HSSystemButtonInteractiveModeAttributes> _highlightingInterface;
    HSTexturedView *_backgroundView;
    HSOldstyleButtonBackgroundView *_oldStyleBackgroundView;
    BOOL _isBackgroundViewResourcesValid;
}
- (void)interactiveHighlightChanged:(id)aChanged;
- (void)systemButtonTypeChanged:(id)aChanged;
- (void)setUpResourcesForView:(id)aView forButtonType:(id)aType;
- (void)setupTexturedBackgroundSystemButtonResourcesForView:(id)aView;
- (void)setupDropShadowSystemButtonResourcesForView:(id)aView;
- (void)setupRectangleSystemButtonResourcesForView:(id)aView;
- (void)setupDefaultSystemButtonResourcesForView:(id)aView;
- (void)setupRegularSystemButtonResourcesForView:(id)aView;
- (BOOL)willCacheRenderingInRegion:(id)aRegion force:(BOOL)aForce;
- (id)calculateBoundingRegion;
- (void)fillBoundingRegionAttributesSet:(id)aSet;
- (void)predrawRegion:(id)aRegion withDelegate:(id)aDelegate;
- (void)fillVisualizationAttributesSet:(id)aSet;
- (id)buttonAttributes;
- (void)dealloc;
- (id)initWithHyperObject:(id)aObject cachingPolicy:(NSInteger)aPolicy;
@end

@interface HSBackgroundCellRenderLayerInEditor : HSBackgroundCellRenderLayer
{
}
- (id)calculateBoundingRegion;
- (void)fillBoundingRegionAttributesSet:(id)aSet;
- (BOOL)requiresTransparencyLayer;
- (BOOL)isEmpty;
- (void)predrawRegion:(id)aRegion withDelegate:(id)aDelegate;
- (void)fillVisualizationAttributesSet:(id)aSet;
@end

