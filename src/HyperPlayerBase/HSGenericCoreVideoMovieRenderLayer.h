#import "HyperPlayerBasePrefix.h"
#import "HSGenericRenderLayer.h"


@interface HSGenericCoreVideoMovieRenderLayer : HSGenericRenderLayer
{
    id<HSMovieAttributes> _movieAttributes;
    id<HSMovieObjectAttributes> _movieObjectAttributes;
    id<HSTransparentColorAttributes> _transparentColorAttributes;
}
- (BOOL)willCacheRenderingInRegion:(id)aRegion withTransformationIntent:(struct HyperPlayerBase_anon12 *)aIntent countOnRenderSublayersInfluence:(NSInteger)aInfluence force:(BOOL)aForce;
- (BOOL)willCacheRenderingInRegion:(id)aRegion force:(BOOL)aForce;
- (void)predrawRegion:(id)aRegion withDelegate:(id)aDelegate;
- (id)calculateBoundingRegion;
- (void)fillBoundingRegionAttributesSet:(id)aSet;
- (BOOL)requiresTransparencyLayer;
- (BOOL)isEmpty;
- (void)HSGenericCoreVideoMovieRenderLayer_transparentColorEnablementDidChange:(id)aChange;
- (void)HSGenericCoreVideoMovieRenderLayer_mediaDidChange:(id)aChange;
- (void)fillVisualizationMaskAttributesSet:(id)aSet;
- (void)fillVisualizationAttributesSet:(id)aSet;
- (void)dealloc;
- (id)initWithHyperObject:(id)aObject cachingPolicy:(NSInteger)aPolicy;
@end

