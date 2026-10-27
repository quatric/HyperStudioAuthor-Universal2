#import "HyperPlayerBasePrefix.h"
#import "HSGenericGroupRenderLayer.h"


@interface HSHighlightRenderLayer : HSGenericGroupRenderLayer
{
    id<HSHighlightAttributes> _highlightAttributes;
    id<HSSizeAttributes> _sizeAttributes;
}
- (void)drawRenderSublayersInRegion:(id)aRegion withDelegate:(id)aDelegate;
- (id)createBitmapRenderCacheWithAffineTransform:(CGAffineTransform)aTransform cacheRect:(NSRect)aRect temporaryValidness:(CGFloat)aValidness persistentValidness:(CGFloat)aValidness2 validnessEvaluator:(id)aEvaluator delegate:(id)aDelegate share:(BOOL)aShare;
- (BOOL)willCacheRenderingInRegion:(id)aRegion force:(BOOL)aForce;
- (void)fillVisualizationAttributesSet:(id)aSet;
- (void)dealloc;
- (id)initWithHyperObject:(id)aObject cachingPolicy:(NSInteger)aPolicy;
@end

