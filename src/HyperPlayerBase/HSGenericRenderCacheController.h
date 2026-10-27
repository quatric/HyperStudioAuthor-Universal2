#import "HyperPlayerBasePrefix.h"


@interface HSGenericRenderCacheController : NSObject <HSRenderCacheController, NSObject, HSWeakReferencer>
{
    NSMapTable *_renderCaches;
    NSMapTable *_storableValidnessLimits;
    NSMapTable *_renderCacheRegionMisses;
    NSMapTable *_renderCacheValidnessMisses;
    unsigned int _renderCacheRegionMissLimit;
    unsigned int _renderCacheValidnessMissLimit;
    float _storableValidnessLimit;
    NSMapTable *_renderCashesList;
    struct HSGenericRenderCacheController_orderedRenderCash *_orderedRenderCashListHead;
    struct HSGenericRenderCacheController_orderedRenderCash *_orderedRenderCashListLast;
    unsigned int _totalRenderCashesSize;
    unsigned int _mayCreateCaches:1;
    unsigned int _mayCreatePartialCaches:1;
    unsigned int _isStorableValidnessLimitCalculated:1;
}
- (void)renderCacheDidChangeValidness:(id)aValidness;
- (void)discardAllRenderCachesForRenderLayer:(id)aLayer;
- (void)discardRenderCache:(id)aCache;
- (void)addRenderCache:(id)aCache;
- (id)renderCacheForRegion:(id)aRegion ofRenderLayer:(id)aLayer withRenderLayerDelegate:(id)aDelegate acceptableValidnessLimit:(CGFloat)aLimit options:(NSInteger)aOptions;
- (void)noteRenderCasheUsed:(id)aUsed;
- (id)renderCacheForRenderLayer:(id)aLayer;
- (void)setMayCreateCaches:(BOOL)aCaches;
- (BOOL)mayCreateCaches;
- (CGFloat)storableValidnessLimit;
- (void)releaseWithStorableValidnessLimit:(CGFloat)aLimit;
- (id)retainWithStorableValidnessLimit:(CGFloat)aLimit;
- (void)dereferenceObject:(id)aObject;
- (void)dealloc;
- (id)init;
- (void)HSGenericRenderCacheController_addOrderedRenderCashToList:(struct HSGenericRenderCacheController_orderedRenderCash *)aList;
- (void)HSGenericRenderCacheController_removeOrderedRenderCashFromList:(struct HSGenericRenderCacheController_orderedRenderCash *)aList;
- (void)HSGenericRenderCacheController_prepareToAddRenderCashe:(id)aCashe;
- (void)HSGenericRenderCacheController_handleValidnessMissForRenderCache:(id)aCache;
- (void)HSGenericRenderCacheController_discardRenderCache:(id)aCache;
- (void)HSGenericRenderCacheController_prepareToDiscardRenderCaches:(id)aCaches;
- (void)HSGenericRenderCacheController_prepareToDiscardRenderCache:(id)aCache withNotificationCenter:(id)aCenter;
- (void)HSGenericRenderCacheController_addRenderCache:(id)aCache forRenderLayer:(id)aLayer toSet:(id)aSet;
- (BOOL)HSGenericRenderCacheController_initializeMaps;
@end

