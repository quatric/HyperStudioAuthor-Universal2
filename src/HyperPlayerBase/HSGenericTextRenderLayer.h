#import "HyperPlayerBasePrefix.h"
#import "HSGenericRenderLayer.h"


@interface HSGenericTextRenderLayer : HSGenericRenderLayer
{
    id<HSTextObjectAttributes> _textObjectAttributes;
    id<HSTextLayoutAttributes> _textLayoutAttributes;
    id<HSCocoaTextStorageAccessing> _cocoaTextStorageAccessing;
}
+ (void)didFinishRenderingTextStorage;
+ (void)prepareForRenderingTextStorage:(id)aStorage enclosedByRect:(NSRect)aRect layoutManager:(id *)aManager textContainer:(id *)aContainer;
+ (id)sharedRenderingLayoutManager;
+ (void)getSharedRenderingLayoutManager:(id *)aManager textContainer:(id *)aContainer;
- (void)getRenderCacheValidness:(float *)aValidness validnessEvaluator:(id *)aEvaluator includeScaling:(BOOL *)aScaling includeSkewing:(BOOL *)aSkewing includeRotation:(BOOL *)aRotation includeDevicePointAligning:(BOOL *)aAligning forRegion:(id)aRegion affineTransform:(CGAffineTransform)aTransform transformationIntent:(struct HyperPlayerBase_anon12 *)aIntent;
- (id)calculateBoundingRegion;
- (void)fillBoundingRegionAttributesSet:(id)aSet;
- (BOOL)requiresTransparencyLayer;
- (BOOL)isEmpty;
- (void)predrawRegion:(id)aRegion withDelegate:(id)aDelegate;
- (void)renderTextInRegion:(id)aRegion enclosedByRect:(NSRect)aRect;
- (void)fillVisualizationAttributesSet:(id)aSet;
- (void)calculateLayoutInfoForTextContainer:(id)aContainer enclosedByRect:(NSRect)aRect verticalAlignment:(NSInteger)aAlignment visibleTextRect:(NSRect *)aRect2 visibleGlyphRange:(NSRange *)aRange;
- (void)dealloc;
- (id)initWithHyperObject:(id)aObject cachingPolicy:(NSInteger)aPolicy;
@end

