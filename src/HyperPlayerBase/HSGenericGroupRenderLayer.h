#import "HyperPlayerBasePrefix.h"
#import "HSGenericRenderLayer.h"


@interface HSGenericGroupRenderLayer : HSGenericRenderLayer <HSExpandableRenderLayer, HSRenderLayer, NSObject, HSWeakReferencing, HSRenderLayerObserver>
{
    struct __CFArray *_originalRenderSublayerRecords;
    struct __CFArray *_renderSublayerRecords;
    unsigned int _renderSublayerCapacity;
    HSMultipleObjectsAttributeSet *_renderSublayersVisualizationAttributes;
    HSMutableMultipleObjectsAttributeSet *_visualizationAttributesExpectedToChangeContinuously;
    unsigned int _renderSublayersOperationGroupCounter;
    HSMultipleObjectsAttributeSet *_savedVisualizationAttributes;
    HSMultipleObjectsAttributeSet *_savedVisualizationMaskAttributes;
    unsigned int _sublayersDrawingCounter;
    id<HSMultipleObjectsAttributeSetObservingSession> _observingSessionForContinuousChangesOfRenderSublayersAutogroupingAttributes;
    unsigned int _areRenderSublayersRecordsValid:1;
    unsigned int _autogroupsRenderSublayersForEfficientCaching:1;
    unsigned int _areRenderSublayersAutogroupedForEfficientCaching:1;
}
+ (void)HSGenericGroupRenderLayer_addSharedPrivateGroupRenderSublayerRecordsWithRenderLayer:(id)aLayer toCountedSet:(struct __CFDictionary **)aSet;
+ (void)HSGenericGroupRenderLayer_sharePrivateGroupRenderSublayerRecord:(struct HyperPlayerBase_anon11 *)aRecord;
- (void)renderLayerWantsToReexpand:(id)aReexpand;
- (void)renderLayerDidChangeBoundingRegion:(id)aRegion;
- (void)renderLayerDidChangeVisualizationMaskAttributesSet:(id)aSet;
- (void)renderLayerDidChangeVisualizationAttributesSet:(id)aSet;
- (void)getRenderCacheValidness:(float *)aValidness validnessEvaluator:(id *)aEvaluator includeScaling:(BOOL *)aScaling includeSkewing:(BOOL *)aSkewing includeRotation:(BOOL *)aRotation includeDevicePointAligning:(BOOL *)aAligning forRegion:(id)aRegion affineTransform:(CGAffineTransform)aTransform transformationIntent:(struct HyperPlayerBase_anon12 *)aIntent;
- (BOOL)willCacheRenderingInRegion:(id)aRegion withTransformationIntent:(struct HyperPlayerBase_anon12 *)aIntent countOnRenderSublayersInfluence:(NSInteger)aInfluence force:(BOOL)aForce;
- (void)drawRegion:(id)aRegion ofRenderSublayerAtIndex:(NSUInteger)aIndex withDelegate:(id)aDelegate;
- (void)drawRenderSublayersInRegion:(id)aRegion withDelegate:(id)aDelegate;
- (BOOL)unionBoundingRegionOfSublayersVisualAttributeSet:(id)aSet ofHyperObject:(id)aObject withInfo:(id)aInfo withRegion:(id *)aRegion;
- (BOOL)unionBoundingRegionOfLocalVisualAttributeSet:(id)aSet ofHyperObject:(id)aObject withInfo:(id)aInfo withRegion:(id *)aRegion;
- (BOOL)HSGenericGroupRenderLayer_unionBoundingRegionOfConcreteAttributeSet:(id)aSet ofHyperObject:(id)aObject withInfo:(id)aInfo inSublayerAtIndex:(NSUInteger)aIndex withRegion:(id *)aRegion;
- (id)calculateBoundingRegion;
- (BOOL)HSGenericGroupRenderLayer_unionBoundingRegionOfSublayerAtIndex:(NSUInteger)aIndex withRegion:(id)aRegion;
- (void)fillBoundingRegionAttributesSet:(id)aSet;
- (BOOL)requiresTransparencyLayer;
- (BOOL)isEmpty;
- (void)endRenderSublayersOperationGroup;
- (void)beginRenderSublayersOperationGroup;
- (void)visualizationMaskAttributesSetDidChange:(id)aChange;
- (void)fillVisualizationMaskAttributesSet:(id)aSet;
- (void)visualizationAttributesSetDidChange:(id)aChange;
- (void)renderSublayersVisualizationAttributesSetDidChange;
- (void)HSGenericGroupRenderLayer_invalidateRenderSublayersVisualizationAttributesSet;
- (void)fillVisualizationAttributesSet:(id)aSet;
- (id)renderSublayersVisualizationAttributes;
- (void)fillRenderSublayersVisualizationAttributesSet:(id)aSet;
- (void)disperseRenderSublayers;
- (void)removeAllRenderSublayers;
- (void)removeRenderSublayersInRange:(NSRange)aRange;
- (void)removeRenderSublayerAtIndex:(NSUInteger)aIndex;
- (void)addRenderSublayersFromRenderLayer:(id)aLayer range:(NSRange)aRange;
- (void)addRenderSublayersFromRenderLayer:(id)aLayer;
- (void)replaceRenderSublayerAtIndex:(NSUInteger)aIndex withRenderSublayer:(id)aSublayer role:(id)aRole rootFlag:(BOOL)aFlag transparencyLayerRequirementAdditionFlag:(BOOL)aFlag2;
- (void)insertRenderSublayer:(id)aSublayer atIndex:(NSUInteger)aIndex forRole:(id)aRole asRoot:(BOOL)aRoot addingTransparencyLayerRequirement:(BOOL)aRequirement;
- (void)addRenderSublayer:(id)aSublayer forRole:(id)aRole asRoot:(BOOL)aRoot addingTransparencyLayerRequirement:(BOOL)aRequirement;
- (BOOL)transparencyLayerRequirementAdditionFlagOfRenderSublayerAtIndex:(NSUInteger)aIndex;
- (BOOL)rootFlagOfRenderSublayerAtIndex:(NSUInteger)aIndex;
- (id)roleOfRenderSublayerAtIndex:(NSUInteger)aIndex;
- (id)renderSublayerAtIndex:(NSUInteger)aIndex;
- (NSUInteger)renderSublayerCount;
- (id)renderSublayers;
- (BOOL)HSGenericGroupRenderLayer_checkSublayerIncrement;
- (NSUInteger)renderSublayerCapacity;
- (void)disableAutogroupingOfRenderSublayersForEfficientCaching;
- (void)enableAutogroupingOfRenderSublayersForEfficientCaching;
- (void)setAutogroupsRenderSublayersForEfficientCaching:(BOOL)aCaching;
- (BOOL)autogroupsRenderSublayersForEfficientCaching;
- (void)HSGenericGroupRenderLayer_renderSublayersAutogroupingAttributesDidChangeContinuously:(id)aContinuously;
- (void)HSGenericGroupRenderLayer_renderSublayersAutogroupingAttributesWillBeginDidEndChangeContinuously:(id)aContinuously;
- (void)HSGenericGroupRenderLayer_rootGeometryAttributeDidChange:(id)aChange;
- (void)HSGenericGroupRenderLayer_ungroupRenderSublayersFromEfficientCaching;
- (void)HSGenericGroupRenderLayer_groupRenderSublayersForEfficientCaching;
- (BOOL)HSGenericGroupRenderLayer_areSharedGroupRenderSublayerSubrecords:(struct __CFArray *)aSubrecords subgroupOfRenderSublayerRecords:(struct __CFArray *)aRecords withRenderSublayerBypassablenesses:(struct __CFSet *)aBypassablenesses firstIndex:(unsigned int *)aIndex lastIndex:(unsigned int *)aIndex2;
- (id)HSGenericGroupRenderLayer_descriptionForRenderSublayerRecords:(void *)aRecords;
- (id)HSGenericGroupRenderLayer_descriptionForRenderSublayerGroupRecord:(struct HyperPlayerBase_anon14 *)aRecord;
- (id)HSGenericGroupRenderLayer_descriptionForRenderSublayerRecord:(struct HyperPlayerBase_anon11 *)aRecord;
- (BOOL)HSGenericGroupRenderLayer_shouldExcludeRenderSublayerRecordFromAutogrouping:(struct HyperPlayerBase_anon11 *)aAutogrouping mayBeBypassed:(BOOL *)aBypassed;
- (void)HSGenericGroupRenderLayer_preRemoveRenderSublayerRecord:(struct HyperPlayerBase_anon11 *)aRecord asOriginal:(BOOL)aOriginal;
- (void)HSGenericGroupRenderLayer_postAddRenderSublayerRecord:(struct HyperPlayerBase_anon11 *)aRecord asOriginal:(BOOL)aOriginal;
- (struct __CFArray *)HSGenericGroupRenderLayer_renderSublayerRecords;
- (id)copyRemovingRenderSublayers;
- (void)dealloc;
- (id)initWithHyperObject:(id)aObject renderSublayerCapacity:(NSUInteger)aCapacity cachingPolicy:(NSInteger)aPolicy;
- (id)initWithHyperObject:(id)aObject cachingPolicy:(NSInteger)aPolicy;
@end

@interface HSGenericGroupRenderLayer_HSPrivateGroupRenderLayerRegistry : NSObject <HSWeakReferencer>
{
    struct __CFDictionary *_renderLayerToPrivateGroupRenderSublayerRecordsMap;
}
- (void)addSharedPrivateGroupRenderSublayerRecordsWithRenderLayer:(id)aLayer toCountedSet:(struct __CFDictionary **)aSet;
- (void)sharePrivateGroupRenderSublayerRecord:(struct HyperPlayerBase_anon11 *)aRecord;
- (void)dereferenceObject:(id)aObject;
- (void)dealloc;
@end

