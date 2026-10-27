#import "HyperPlayerBasePrefix.h"


@interface HSGenericRenderDelegate : NSObject <HSRenderDelegate, NSObject>
{
    id _drawable;
    id<HSRenderCacheController> _renderCacheController;
    unsigned int _isCreatingRenderCacheCounter;
    unsigned int _isRenderCacheControllerSet:1;
}
+ (id)delegateWithDrawable:(id)aDrawable;
- (void)renderer:(id)aRenderer didRenderRegion:(id)aRegion ofRenderLayerAtIndexPath:(id)aPath;
- (void)renderer:(id)aRenderer didCacheDrawingInRegion:(id)aRegion forRenderLayerAtIndexPath:(id)aPath intoRenderCache:(id)aCache;
- (void)renderer:(id)aRenderer didDrawRegion:(id)aRegion ofRenderLayerAtIndexPath:(id)aPath intoRenderCache:(BOOL)aCache;
- (void)renderer:(id)aRenderer didCacheDrawingInRegion:(id)aRegion ofRenderLayerAtIndexPath:(id)aPath intoRenderCache:(id)aCache;
- (id)renderer:(id)aRenderer willCacheDrawingInRegion:(id)aRegion ofRenderLayerAtIndexPath:(id)aPath;
- (BOOL)renderer:(id)aRenderer shouldDrawRegion:(id)aRegion ofRenderLayerAtIndexPath:(id)aPath intoRenderCache:(BOOL)aCache;
- (id)renderer:(id)aRenderer willCacheDrawingInRegion:(id)aRegion forRenderLayerAtIndexPath:(id)aPath;
- (id)HSGenericRenderDelegate_renderCacheForRegion:(id)aRegion ofRenderLayerAtIndexPath:(id)aPath inRenderLayerTreeOfRenderer:(id)aRenderer blockingCreation:(BOOL)aCreation;
- (BOOL)renderer:(id)aRenderer shouldRenderRegion:(id)aRegion ofRenderLayerAtIndexPath:(id)aPath;
- (void)setRenderCacheController:(id)aController;
- (id)renderCacheController;
- (void)clearDrawable;
- (id)drawable;
- (void)dealloc;
- (id)initWithDrawable:(id)aDrawable;
- (id)init;
@end

@interface NSObject (HSRenderDelegateDrawable)
- (BOOL)renderDelegate:(id)aDelegate willQueryRenderCacheForRegion:(id)aRegion ofRenderLayerAtIndexPath:(id)aPath inRenderer:(id)aRenderer withOptions:(int *)aOptions acceptableValidnessLimit:(float *)aLimit;
- (void)renderer:(id)aRenderer didRenderRegion:(id)aRegion ofRenderLayerAtIndexPath:(id)aPath withRenderDelegate:(id)aDelegate;
- (void)renderer:(id)aRenderer didDrawRegion:(id)aRegion ofRenderLayerAtIndexPath:(id)aPath withRenderDelegate:(id)aDelegate;
- (BOOL)renderer:(id)aRenderer shouldDrawRegion:(id)aRegion ofRenderLayerAtIndexPath:(id)aPath withRenderDelegate:(id)aDelegate;
- (BOOL)renderer:(id)aRenderer shouldRenderRegion:(id)aRegion ofRenderLayerAtIndexPath:(id)aPath withRenderDelegate:(id)aDelegate;
@end

