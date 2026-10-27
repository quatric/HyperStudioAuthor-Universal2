#import "HyperPlayerBasePrefix.h"
#import "HSWeaklyReferencedObject.h"


@interface HSGenericRenderLayer : HSWeaklyReferencedObject <HSWeakReferencer, HSRenderLayer, NSObject, HSWeakReferencing>
{
    id _hyperObject;
    int _cachingPolicy;
    struct __CFSet *_observers;
    struct __CFDictionary *_renderCaches;
    HSRegion *_boundingRegion;
    HSMutableMultipleObjectsAttributeSet *_boundingRegionAttributes;
    HSMultipleObjectsAttributeSet *_visualizationAttributes;
    HSMultipleObjectsAttributeSet *_visualizationMaskAttributes;
}
+ (CGFloat)maxBitmapCacheArea;
- (BOOL)cacheRenderingInRegion:(id)aRegion forAffineTransform:(CGAffineTransform)aTransform withTransformationIntent:(struct HyperPlayerBase_anon12 *)aIntent acceptableValidnessLimit:(CGFloat)aLimit delegate:(id)aDelegate force:(BOOL)aForce share:(BOOL)aShare resultCache:(id *)aCache;
- (BOOL)cacheRenderingInRegion:(id)aRegion withAffineTransform:(CGAffineTransform)aTransform validness:(CGFloat)aValidness validnessEvaluator:(id)aEvaluator delegate:(id)aDelegate force:(BOOL)aForce share:(BOOL)aShare resultCache:(id *)aCache;
- (id)createBitmapRenderCacheWithAffineTransform:(CGAffineTransform)aTransform cacheRect:(NSRect)aRect temporaryValidness:(CGFloat)aValidness persistentValidness:(CGFloat)aValidness2 validnessEvaluator:(id)aEvaluator delegate:(id)aDelegate share:(BOOL)aShare;
- (id)validationAttributesForBitmapRenderCache;
- (id)continuousChangeSensitiveVisualizationAttributes;
- (void)getRenderCacheValidness:(float *)aValidness validnessEvaluator:(id *)aEvaluator cachingTransform:(CGAffineTransform *)aTransform forRegion:(id)aRegion affineTransform:(CGAffineTransform)aTransform2 transformationIntent:(struct HyperPlayerBase_anon12 *)aIntent;
- (void)getRenderCacheValidness:(float *)aValidness validnessEvaluator:(id *)aEvaluator includeScaling:(BOOL *)aScaling includeSkewing:(BOOL *)aSkewing includeRotation:(BOOL *)aRotation includeDevicePointAligning:(BOOL *)aAligning forRegion:(id)aRegion affineTransform:(CGAffineTransform)aTransform transformationIntent:(struct HyperPlayerBase_anon12 *)aIntent;
- (BOOL)willCacheRenderingInRegion:(id)aRegion withTransformationIntent:(struct HyperPlayerBase_anon12 *)aIntent countOnRenderSublayersInfluence:(NSInteger)aInfluence force:(BOOL)aForce;
- (BOOL)willCacheRenderingInRegion:(id)aRegion force:(BOOL)aForce;
- (CGFloat)persistentValidnessForTemporaryValidness:(CGFloat)aValidness region:(id)aRegion;
- (void)invalidateRenderCache:(id)aCache withAttributeChangeNotification:(id)aNotification;
- (BOOL)containsTemporaryChangedAttributes;
- (void)shareRenderCache:(id)aCache withValidationAttributes:(id)aAttributes;
- (id)sharedRenderCaches;
- (void)postDrawRegion:(id)aRegion withDelegate:(id)aDelegate;
- (void)drawRenderSublayersInRegion:(id)aRegion withDelegate:(id)aDelegate;
- (void)predrawRegion:(id)aRegion withDelegate:(id)aDelegate;
- (void)drawRegion:(id)aRegion withDelegate:(id)aDelegate;
- (BOOL)unionBoundingRegionOfSublayersVisualAttributeSet:(id)aSet ofHyperObject:(id)aObject withInfo:(id)aInfo withRegion:(id *)aRegion;
- (BOOL)unionBoundingRegionOfLocalVisualAttributeSet:(id)aSet ofHyperObject:(id)aObject withInfo:(id)aInfo withRegion:(id *)aRegion;
- (BOOL)unionBoundingRegionOfConcreteAttributeSet:(id)aSet ofHyperObject:(id)aObject withInfo:(id)aInfo withRegion:(id *)aRegion;
- (BOOL)unionBoundingRegionOfAttribute:(id)aAttribute ofHyperObject:(id)aObject withInfo:(id)aInfo withRegion:(id)aRegion;
- (id)boundingRegionOfAttribute:(id)aAttribute ofHyperObject:(id)aObject withInfo:(id)aInfo;
- (BOOL)unionBoundingRegionOfAttributeSet:(id)aSet ofHyperObject:(id)aObject withInfo:(id)aInfo withRegion:(id)aRegion;
- (id)boundingRegionOfAttributeSet:(id)aSet ofHyperObject:(id)aObject withInfo:(id)aInfo;
- (BOOL)unionBoundingRegionWithRegion:(id)aRegion;
- (id)boundingRegion;
- (id)calculateBoundingRegion;
- (void)boundingRegionDidChange;
- (void)HSGenericRenderLayer_boundingRegionDidChange:(id)aChange;
- (void)unlinkBoundingRegionFromAttribute:(id)aAttribute ofHyperObject:(id)aObject withAttributeObservingController:(id)aController;
- (void)linkBoundingRegionToAttribute:(id)aAttribute ofHyperObject:(id)aObject withAttributeObservingController:(id)aController;
- (void)fillBoundingRegionAttributesSet:(id)aSet;
- (BOOL)requiresTransparencyLayer;
- (BOOL)isOpaqueInRect:(NSRect)aRect;
- (BOOL)isEmpty;
- (void)notifyObserversWithSelector:(SEL)aSelector;
- (void)removeObserver:(void *)aObserver;
- (void)addObserver:(id)aObserver;
- (void)visualizationMaskAttributesSetDidChange:(id)aChange;
- (void)addVisualizationMaskAttributesToSet:(id)aSet;
- (id)visualizationMaskAttributes;
- (void)fillVisualizationMaskAttributesSet:(id)aSet;
- (void)visualizationAttributesSetDidChange:(id)aChange;
- (void)addVisualizationAttributesToSet:(id)aSet;
- (id)visualizationAttributes;
- (void)fillVisualizationAttributesSet:(id)aSet;
- (id)description;
- (id)HSGenericRenderLayer_renderSublayersDescription;
- (id)HSGenericRenderLayer_cachingPolicyString;
- (id)renderLayerAtPosition:(NSUInteger)aPosition inIndexPath:(id)aPath role:(id *)aRole;
- (id)renderLayerAtIndexPath:(id)aPath role:(id *)aRole;
- (id)renderLayerPathForIndexPath:(id)aPath;
- (BOOL)transparencyLayerRequirementAdditionFlagOfRenderSublayerAtIndex:(NSUInteger)aIndex;
- (BOOL)rootFlagOfRenderSublayerAtIndex:(NSUInteger)aIndex;
- (id)roleOfRenderSublayerAtIndex:(NSUInteger)aIndex;
- (id)renderSublayerAtIndex:(NSUInteger)aIndex;
- (NSUInteger)renderSublayerCount;
- (id)renderSublayers;
- (NSInteger)cachingPolicy;
- (id)hyperObject;
- (id)copyRemovingRenderSublayers;
- (void)dereferenceObject:(id)aObject;
- (void)dealloc;
- (id)init;
- (id)initWithHyperObject:(id)aObject cachingPolicy:(NSInteger)aPolicy;
- (id)initWithHyperObject:(id)aObject;
@end

@interface HSGenericRenderLayer_HSRenderCacheValidator : NSObject
{
    HSGenericRenderLayer *_renderLayer;
    id<HSRenderCache, HSWeakReferencing> _renderCache;
    id<HSMultipleObjectsAttributeSetObservingSession> _validationObservingSession;
}
- (void)validationAttibutesDidChange:(id)aChange;
- (void)dealloc;
- (id)initWithRenderLayer:(id)aLayer renderCache:(id)aCache validationAttributes:(id)aAttributes;
- (id)init;
@end

