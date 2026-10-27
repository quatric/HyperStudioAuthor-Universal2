#import "HyperPlayerBasePrefix.h"


@interface HSGenericRenderLayerDelegate : NSObject <HSRenderLayerDelegate, NSObject>
{
    id<HSRenderDelegate> _renderDelegate;
    id<HSRenderer> _renderer;
    HSIndexPath *_renderLayerIndexPath;
    id<HSRenderLayer> _renderLayer;
}
+ (id)delegateWithRenderDelegate:(id)aDelegate renderer:(id)aRenderer renderLayerIndexPath:(id)aPath;
+ (id)delegateWithRenderDelegate:(id)aDelegate renderer:(id)aRenderer;
- (void)renderLayerIsRenderedInRegion:(id)aRegion;
- (void)renderLayerDrawingIsCachedInRegion:(id)aRegion intoRenderCache:(id)aCache;
- (void)renderLayerIsDrawnInRegion:(id)aRegion intoRenderCache:(BOOL)aCache;
- (void)renderLayerDidCacheDrawingInRegion:(id)aRegion intoRenderCache:(id)aCache;
- (id)renderLayerWillCacheDrawingInRegion:(id)aRegion;
- (BOOL)renderLayerShouldBeDrawnInRegion:(id)aRegion intoRenderCache:(BOOL)aCache;
- (id)renderLayerDrawingWillBeCachedInRegion:(id)aRegion;
- (BOOL)renderLayerShouldBeRenderedInRegion:(id)aRegion;
- (id)delegateForRenderSublayerAtIndex:(NSUInteger)aIndex;
- (id)renderLayer;
- (void)dealloc;
- (id)initWithRenderDelegate:(id)aDelegate renderer:(id)aRenderer renderLayerIndexPath:(id)aPath;
- (id)initWithRenderDelegate:(id)aDelegate renderer:(id)aRenderer;
- (id)init;
@end

