#import "HyperPlayerBasePrefix.h"
#import "HSWeaklyReferencedObject.h"


@interface HSGenericGeometryBehaviorAdaptor : HSWeaklyReferencedObject <HSWeakReferencer, HSNodeUnitBasedHyperImplementationCreating, HSGeometryBehaviorAdapting, HyperInterface, NSObject>
{
    id _hyperObject;
    id<HSGeometryAttributes> _geometryAttributes;
    id<HSGeometryBehaviorAttributes> _geometryBehaviorAttributes;
    HSGeometryBehaviorApplier *_geometryBehaviorApplier;
}
+ (id)hyperImplementationWithNode:(id)aNode unit:(id)aUnit;
+ (NSSize)adaptResizingUnproportionallyFromSize:(NSSize)aSize toSize:(NSSize)aSize2 canResizeHorizontally:(BOOL)aHorizontally canResizeVertically:(BOOL)aVertically withMinSize:(NSSize)aSize3 maxSize:(NSSize)aSize4 layoutGuidingContext:(id)aContext;
+ (NSSize)adaptResizingProportionallyFromSize:(NSSize)aSize toSize:(NSSize)aSize2 withMinSize:(NSSize)aSize3 maxSize:(NSSize)aSize4 layoutGuidingContext:(id)aContext;
- (void)adaptResizingFrameProportionallyBy:(CGFloat)aBy aboutRelativePoint:(NSPoint)aPoint followResizingScalingPreference:(BOOL)aPreference withLayoutGuidingContext:(id)aContext adaptedSize:(NSSize *)aSize affineTransform:(CGAffineTransform *)aTransform flippedHorizontally:(BOOL *)aHorizontally;
- (void)adaptResizingFrameBy:(NSSize)aBy aboutRelativePoint:(NSPoint)aPoint followResizingScalingPreference:(BOOL)aPreference maintainAspectRatio:(NSInteger)aRatio byAspectRatioMaintainingRule:(NSInteger)aRule withLayoutGuidingContext:(id)aContext adaptedSize:(NSSize *)aSize affineTransform:(CGAffineTransform *)aTransform flippedHorizontally:(BOOL *)aHorizontally;
- (void)adaptResizingFrameTo:(NSSize)aTo aboutRelativePoint:(NSPoint)aPoint followResizingScalingPreference:(BOOL)aPreference maintainAspectRatio:(NSInteger)aRatio byAspectRatioMaintainingRule:(NSInteger)aRule withLayoutGuidingContext:(id)aContext adaptedSize:(NSSize *)aSize affineTransform:(CGAffineTransform *)aTransform;
- (void)adaptResizingFrameTo:(NSSize)aTo aboutRelativePoint:(NSPoint)aPoint followResizingScalingPreference:(BOOL)aPreference maintainAspectRatio:(NSInteger)aRatio byAspectRatioMaintainingRule:(NSInteger)aRule withLayoutGuidingContext:(id)aContext force:(BOOL)aForce adaptedSize:(NSSize *)aSize affineTransform:(CGAffineTransform *)aTransform;
- (void)adaptResizingFrameToHeight:(CGFloat)aHeight aboutRelativePoint:(NSPoint)aPoint followResizingScalingPreference:(BOOL)aPreference maintainAspectRatio:(NSInteger)aRatio withLayoutGuidingContext:(id)aContext adaptedSize:(NSSize *)aSize affineTransform:(CGAffineTransform *)aTransform;
- (void)adaptResizingFrameToWidth:(CGFloat)aWidth aboutRelativePoint:(NSPoint)aPoint followResizingScalingPreference:(BOOL)aPreference maintainAspectRatio:(NSInteger)aRatio withLayoutGuidingContext:(id)aContext adaptedSize:(NSSize *)aSize affineTransform:(CGAffineTransform *)aTransform;
- (CGAffineTransform)adaptRotationBy:(CGFloat)aBy aboutRelativePoint:(NSPoint)aPoint withLayoutGuidingContext:(id)aContext;
- (CGAffineTransform)adaptRotationTo:(CGFloat)aTo aboutRelativePoint:(NSPoint)aPoint withLayoutGuidingContext:(id)aContext;
- (CGAffineTransform)adaptSkewingBy:(CGFloat)aBy withLayoutGuidingContext:(id)aContext;
- (CGAffineTransform)adaptSkewingTo:(CGFloat)aTo withLayoutGuidingContext:(id)aContext;
- (CGAffineTransform)adaptFlippingVerticallyWithLayoutGuidingContext:(id)aContext;
- (void)adaptFlippingHorizontallyWithLayoutGuidingContext:(id)aContext adaptedAffineTransform:(CGAffineTransform *)aTransform flippedHorizontally:(BOOL *)aHorizontally;
- (CGAffineTransform)adaptSizeScalingTo:(NSSize)aTo aboutRelativePoint:(NSPoint)aPoint maintainAspectRatio:(NSInteger)aRatio byAspectRatioMaintainingRule:(NSInteger)aRule withLayoutGuidingContext:(id)aContext;
- (void)adaptSizeScalingProportionallyBy:(CGFloat)aBy aboutRelativePoint:(NSPoint)aPoint withLayoutGuidingContext:(id)aContext adaptedAffineTransform:(CGAffineTransform *)aTransform flippedHorizontally:(BOOL *)aHorizontally;
- (void)adaptSizeScalingBy:(NSSize)aBy aboutRelativePoint:(NSPoint)aPoint maintainAspectRatio:(NSInteger)aRatio byAspectRatioMaintainingRule:(NSInteger)aRule withLayoutGuidingContext:(id)aContext adaptedAffineTransform:(CGAffineTransform *)aTransform flippedHorizontally:(BOOL *)aHorizontally;
- (CGAffineTransform)adaptMovingBy:(NSSize)aBy withLayoutGuidingContext:(id)aContext;
- (CGAffineTransform)adaptMovingVerticallyBy:(CGFloat)aBy withLayoutGuidingContext:(id)aContext;
- (CGAffineTransform)adaptMovingHorizontallyBy:(CGFloat)aBy withLayoutGuidingContext:(id)aContext;
- (void)adaptResizingProportionallyBy:(CGFloat)aBy aboutRelativePoint:(NSPoint)aPoint withLayoutGuidingContext:(id)aContext adaptedSize:(NSSize *)aSize affineTransform:(CGAffineTransform *)aTransform flippedHorizontally:(BOOL *)aHorizontally;
- (void)adaptResizingBy:(NSSize)aBy aboutRelativePoint:(NSPoint)aPoint maintainAspectRatio:(NSInteger)aRatio byAspectRatioMaintainingRule:(NSInteger)aRule withLayoutGuidingContext:(id)aContext adaptedSize:(NSSize *)aSize affineTransform:(CGAffineTransform *)aTransform flippedHorizontally:(BOOL *)aHorizontally;
- (void)adaptResizingTo:(NSSize)aTo aboutRelativePoint:(NSPoint)aPoint maintainAspectRatio:(NSInteger)aRatio byAspectRatioMaintainingRule:(NSInteger)aRule withLayoutGuidingContext:(id)aContext adaptedSize:(NSSize *)aSize affineTransform:(CGAffineTransform *)aTransform;
- (void)adaptSize:(NSSize *)aSize affineTransform:(CGAffineTransform *)aTransform flippedHorizontally:(BOOL *)aHorizontally withLayoutGuidingContext:(id)aContext;
- (void)adaptAffineTransform:(CGAffineTransform *)aTransform flippedHorizontally:(BOOL *)aHorizontally withLayoutGuidingContext:(id)aContext;
- (CGAffineTransform)adaptRotationBy:(CGFloat)aBy aboutRelativePoint:(NSPoint)aPoint canRotate:(BOOL)aRotate withLayoutGuidingContext:(id)aContext;
- (CGAffineTransform)adaptMovingBy:(NSSize)aBy canMoveHorizontally:(BOOL)aHorizontally canMoveVertically:(BOOL)aVertically withLayoutGuidingContext:(id)aContext;
- (CGAffineTransform)adaptSizeScalingTo:(NSSize)aTo aboutRelativePoint:(NSPoint)aPoint maintainAspectRatio:(NSInteger)aRatio byAspectRatioMaintainingRule:(NSInteger)aRule canScaleHorizontally:(BOOL)aHorizontally canScaleVertically:(BOOL)aVertically withLayoutGuidingContext:(id)aContext;
- (void)adaptSizeScalingProportionallyBy:(CGFloat)aBy aboutRelativePoint:(NSPoint)aPoint canScaleHorizontally:(BOOL)aHorizontally canScaleVertically:(BOOL)aVertically withLayoutGuidingContext:(id)aContext adaptedAffineTransform:(CGAffineTransform *)aTransform flippedHorizontally:(BOOL *)aHorizontally2;
- (void)adaptSizeScalingBy:(NSSize)aBy aboutRelativePoint:(NSPoint)aPoint maintainAspectRatio:(NSInteger)aRatio byAspectRatioMaintainingRule:(NSInteger)aRule canScaleHorizontally:(BOOL)aHorizontally canScaleVertically:(BOOL)aVertically withLayoutGuidingContext:(id)aContext adaptedAffineTransform:(CGAffineTransform *)aTransform flippedHorizontally:(BOOL *)aHorizontally2;
- (void)adaptResizingProportionallyBy:(CGFloat)aBy aboutRelativePoint:(NSPoint)aPoint canResizeHorizontally:(BOOL)aHorizontally canResizeVertically:(BOOL)aVertically withLayoutGuidingContext:(id)aContext adaptedSize:(NSSize *)aSize affineTransform:(CGAffineTransform *)aTransform flippedHorizontally:(BOOL *)aHorizontally2;
- (void)adaptResizingBy:(NSSize)aBy aboutRelativePoint:(NSPoint)aPoint maintainAspectRatio:(NSInteger)aRatio byAspectRatioMaintainingRule:(NSInteger)aRule canResizeHorizontally:(BOOL)aHorizontally canResizeVertically:(BOOL)aVertically withLayoutGuidingContext:(id)aContext adaptedSize:(NSSize *)aSize affineTransform:(CGAffineTransform *)aTransform flippedHorizontally:(BOOL *)aHorizontally2;
- (void)adaptAffineTransformForResizingByFactorToSize:(NSSize)aSize aboutRelativePoint:(NSPoint)aPoint flipHorizontally:(BOOL)aHorizontally flipVertically:(BOOL)aVertically withLayoutGuidingContext:(id)aContext adaptedAffineTransform:(CGAffineTransform *)aTransform flippedHorizontally:(BOOL *)aHorizontally2;
- (void)adaptResizingTo:(NSSize)aTo aboutRelativePoint:(NSPoint)aPoint maintainAspectRatio:(NSInteger)aRatio byAspectRatioMaintainingRule:(NSInteger)aRule canResizeHorizontally:(BOOL)aHorizontally canResizeVertically:(BOOL)aVertically withLayoutGuidingContext:(id)aContext adaptedSize:(NSSize *)aSize affineTransform:(CGAffineTransform *)aTransform;
- (NSSize)adaptResizingProportionallyBy:(CGFloat)aBy withLayoutGuidingContext:(id)aContext;
- (NSSize)adaptResizingTo:(NSSize)aTo maintainAspectRatio:(NSInteger)aRatio byAspectRatioMaintainingRule:(NSInteger)aRule withLayoutGuidingContext:(id)aContext;
- (NSSize)adaptSize:(NSSize)aSize withLayoutGuidingContext:(id)aContext;
- (NSSize)adaptSizeScale:(NSSize)aScale maintainAspectRatio:(NSInteger)aRatio byAspectRatioMaintainingRule:(NSInteger)aRule canScaleHorizontally:(BOOL)aHorizontally canScaleVertically:(BOOL)aVertically withLayoutGuidingContext:(id)aContext;
- (NSSize)adaptResizingTo:(NSSize)aTo maintainAspectRatio:(NSInteger)aRatio byAspectRatioMaintainingRule:(NSInteger)aRule canResizeHorizontally:(BOOL)aHorizontally canResizeVertically:(BOOL)aVertically withLayoutGuidingContext:(id)aContext;
- (NSSize)adaptScalingUnproportionallyTo:(NSSize)aTo canScaleHorizontally:(BOOL)aHorizontally canScaleVertically:(BOOL)aVertically withLayoutGuidingContext:(id)aContext;
- (NSSize)adaptScalingProportionallyTo:(NSSize)aTo withLayoutGuidingContext:(id)aContext;
- (NSSize)adaptResizingUnproportionallyTo:(NSSize)aTo canResizeHorizontally:(BOOL)aHorizontally canResizeVertically:(BOOL)aVertically withLayoutGuidingContext:(id)aContext;
- (NSSize)adaptResizingProportionallyTo:(NSSize)aTo withLayoutGuidingContext:(id)aContext;
- (NSSize)maxSize;
- (NSSize)minSize;
- (BOOL)maintainsSizeScaleAspectRatioWithRequest:(NSInteger)aRequest;
- (BOOL)maintainsSizeAspectRatioWithRequest:(NSInteger)aRequest;
- (id)queryGeometryBehaviorApplier;
- (id)hyperObject;
- (void)dereferenceObject:(id)aObject;
- (void)dealloc;
- (id)initWithHyperObject:(id)aObject;
- (id)init;
@end

