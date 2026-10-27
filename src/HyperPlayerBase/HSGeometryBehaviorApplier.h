#import "HyperPlayerBasePrefix.h"
#import "HSWeaklyReferencedObject.h"


@interface HSGeometryBehaviorApplier : HSWeaklyReferencedObject
{
    id<HSGeometryBehaviorAdapting> _geometryBehaviorAdaptor;
    id<HSMutableGeometryAttributes> _mutableGeometryAttributes;
}
- (void)resizeFrameProportionallyBy:(CGFloat)aBy aboutRelativePoint:(NSPoint)aPoint followResizingScalingPreference:(BOOL)aPreference withLayoutGuidingContext:(id)aContext;
- (void)resizeFrameProportionallyBy:(CGFloat)aBy aboutRelativePoint:(NSPoint)aPoint withLayoutGuidingContext:(id)aContext;
- (void)resizeFrameBy:(NSSize)aBy aboutRelativePoint:(NSPoint)aPoint followResizingScalingPreference:(BOOL)aPreference maintainAspectRatio:(NSInteger)aRatio byAspectRatioMaintainingRule:(NSInteger)aRule withLayoutGuidingContext:(id)aContext;
- (void)resizeFrameBy:(NSSize)aBy aboutRelativePoint:(NSPoint)aPoint withLayoutGuidingContext:(id)aContext;
- (void)resizeFrameTo:(NSSize)aTo aboutRelativePoint:(NSPoint)aPoint followResizingScalingPreference:(BOOL)aPreference maintainAspectRatio:(NSInteger)aRatio byAspectRatioMaintainingRule:(NSInteger)aRule withLayoutGuidingContext:(id)aContext;
- (void)resizeFrameTo:(NSSize)aTo aboutRelativePoint:(NSPoint)aPoint followResizingScalingPreference:(BOOL)aPreference maintainAspectRatio:(NSInteger)aRatio byAspectRatioMaintainingRule:(NSInteger)aRule withLayoutGuidingContext:(id)aContext force:(BOOL)aForce;
- (void)resizeFrameTo:(NSSize)aTo aboutRelativePoint:(NSPoint)aPoint withLayoutGuidingContext:(id)aContext;
- (void)resizeFrameTo:(NSSize)aTo aboutRelativePoint:(NSPoint)aPoint withLayoutGuidingContext:(id)aContext force:(BOOL)aForce;
- (void)resizeFrameToHeight:(CGFloat)aHeight aboutRelativePoint:(NSPoint)aPoint followResizingScalingPreference:(BOOL)aPreference maintainAspectRatio:(NSInteger)aRatio withLayoutGuidingContext:(id)aContext;
- (void)resizeFrameToHeight:(CGFloat)aHeight aboutRelativePoint:(NSPoint)aPoint withLayoutGuidingContext:(id)aContext;
- (void)resizeFrameToWidth:(CGFloat)aWidth aboutRelativePoint:(NSPoint)aPoint followResizingScalingPreference:(BOOL)aPreference maintainAspectRatio:(NSInteger)aRatio withLayoutGuidingContext:(id)aContext;
- (void)resizeFrameToWidth:(CGFloat)aWidth aboutRelativePoint:(NSPoint)aPoint withLayoutGuidingContext:(id)aContext;
- (void)rotateBy:(CGFloat)aBy aboutRelativePoint:(NSPoint)aPoint withLayoutGuidingContext:(id)aContext;
- (void)rotateTo:(CGFloat)aTo aboutRelativePoint:(NSPoint)aPoint withLayoutGuidingContext:(id)aContext;
- (void)skewBy:(CGFloat)aBy withLayoutGuidingContext:(id)aContext;
- (void)skewTo:(CGFloat)aTo withLayoutGuidingContext:(id)aContext;
- (void)setFlippedVertically:(BOOL)aVertically withLayoutGuidingContext:(id)aContext;
- (void)flipVerticallyWithLayoutGuidingContext:(id)aContext;
- (void)setFlippedHorizontally:(BOOL)aHorizontally withLayoutGuidingContext:(id)aContext;
- (void)flipHorizontallyWithLayoutGuidingContext:(id)aContext;
- (void)sizeScaleTo:(NSSize)aTo aboutRelativePoint:(NSPoint)aPoint maintainAspectRatio:(NSInteger)aRatio byAspectRatioMaintainingRule:(NSInteger)aRule withLayoutGuidingContext:(id)aContext;
- (void)sizeScaleTo:(NSSize)aTo aboutRelativePoint:(NSPoint)aPoint withLayoutGuidingContext:(id)aContext;
- (void)heightScaleTo:(CGFloat)aTo aboutRelativePoint:(NSPoint)aPoint maintainAspectRatio:(NSInteger)aRatio withLayoutGuidingContext:(id)aContext;
- (void)heightScaleTo:(CGFloat)aTo aboutRelativePoint:(NSPoint)aPoint withLayoutGuidingContext:(id)aContext;
- (void)widthScaleTo:(CGFloat)aTo aboutRelativePoint:(NSPoint)aPoint maintainAspectRatio:(NSInteger)aRatio withLayoutGuidingContext:(id)aContext;
- (void)widthScaleTo:(CGFloat)aTo aboutRelativePoint:(NSPoint)aPoint withLayoutGuidingContext:(id)aContext;
- (void)sizeScaleProportionallyBy:(CGFloat)aBy aboutRelativePoint:(NSPoint)aPoint withLayoutGuidingContext:(id)aContext;
- (void)sizeScaleBy:(NSSize)aBy aboutRelativePoint:(NSPoint)aPoint maintainAspectRatio:(NSInteger)aRatio byAspectRatioMaintainingRule:(NSInteger)aRule withLayoutGuidingContext:(id)aContext;
- (void)sizeScaleBy:(NSSize)aBy aboutRelativePoint:(NSPoint)aPoint withLayoutGuidingContext:(id)aContext;
- (void)moveCenterTo:(NSPoint)aTo withLayoutGuidingContext:(id)aContext;
- (void)moveVerticalCenterTo:(CGFloat)aTo withLayoutGuidingContext:(id)aContext;
- (void)moveHorizontalCenterTo:(CGFloat)aTo withLayoutGuidingContext:(id)aContext;
- (void)moveMaxVerticalFrameBoundTo:(CGFloat)aTo withLayoutGuidingContext:(id)aContext;
- (void)moveMinVerticalFrameBoundTo:(CGFloat)aTo withLayoutGuidingContext:(id)aContext;
- (void)moveMaxHorizontalFrameBoundTo:(CGFloat)aTo withLayoutGuidingContext:(id)aContext;
- (void)moveMinHorizontalFrameBoundTo:(CGFloat)aTo withLayoutGuidingContext:(id)aContext;
- (void)moveFrameBoundingRectOriginTo:(NSPoint)aTo withLayoutGuidingContext:(id)aContext;
- (void)moveBy:(NSSize)aBy withLayoutGuidingContext:(id)aContext;
- (void)moveVerticallyBy:(CGFloat)aBy withLayoutGuidingContext:(id)aContext;
- (void)moveHorizontallyBy:(CGFloat)aBy withLayoutGuidingContext:(id)aContext;
- (void)resizeProportionallyBy:(CGFloat)aBy aboutRelativePoint:(NSPoint)aPoint withLayoutGuidingContext:(id)aContext;
- (void)resizeBy:(NSSize)aBy aboutRelativePoint:(NSPoint)aPoint maintainAspectRatio:(NSInteger)aRatio byAspectRatioMaintainingRule:(NSInteger)aRule withLayoutGuidingContext:(id)aContext;
- (void)resizeBy:(NSSize)aBy aboutRelativePoint:(NSPoint)aPoint withLayoutGuidingContext:(id)aContext;
- (void)resizeTo:(NSSize)aTo aboutRelativePoint:(NSPoint)aPoint maintainAspectRatio:(NSInteger)aRatio byAspectRatioMaintainingRule:(NSInteger)aRule withLayoutGuidingContext:(id)aContext;
- (void)resizeTo:(NSSize)aTo aboutRelativePoint:(NSPoint)aPoint withLayoutGuidingContext:(id)aContext;
- (void)resizeToHeight:(CGFloat)aHeight aboutRelativePoint:(NSPoint)aPoint maintainAspectRatio:(NSInteger)aRatio withLayoutGuidingContext:(id)aContext;
- (void)resizeToHeight:(CGFloat)aHeight aboutRelativePoint:(NSPoint)aPoint withLayoutGuidingContext:(id)aContext;
- (void)resizeToWidth:(CGFloat)aWidth aboutRelativePoint:(NSPoint)aPoint maintainAspectRatio:(NSInteger)aRatio withLayoutGuidingContext:(id)aContext;
- (void)resizeToWidth:(CGFloat)aWidth aboutRelativePoint:(NSPoint)aPoint withLayoutGuidingContext:(id)aContext;
- (void)setSize:(NSSize)aSize affineTransform:(CGAffineTransform)aTransform flippedHorizontally:(BOOL)aHorizontally withLayoutGuidingContext:(id)aContext;
- (void)setAffineTransform:(CGAffineTransform)aTransform flippedHorizontally:(BOOL)aHorizontally withLayoutGuidingContext:(id)aContext;
- (void)setAffineTransform:(CGAffineTransform)aTransform withLayoutGuidingContext:(id)aContext;
- (void)resizeProportionallyBy:(CGFloat)aBy withLayoutGuidingContext:(id)aContext;
- (void)resizeBy:(NSSize)aBy maintainAspectRatio:(NSInteger)aRatio byAspectRatioMaintainingRule:(NSInteger)aRule withLayoutGuidingContext:(id)aContext;
- (void)resizeBy:(NSSize)aBy withLayoutGuidingContext:(id)aContext;
- (void)resizeTo:(NSSize)aTo maintainAspectRatio:(NSInteger)aRatio byAspectRatioMaintainingRule:(NSInteger)aRule withLayoutGuidingContext:(id)aContext;
- (void)resizeTo:(NSSize)aTo withLayoutGuidingContext:(id)aContext;
- (void)resizeToHeight:(CGFloat)aHeight maintainAspectRatio:(NSInteger)aRatio withLayoutGuidingContext:(id)aContext;
- (void)resizeToHeight:(CGFloat)aHeight withLayoutGuidingContext:(id)aContext;
- (void)resizeToWidth:(CGFloat)aWidth maintainAspectRatio:(NSInteger)aRatio withLayoutGuidingContext:(id)aContext;
- (void)resizeToWidth:(CGFloat)aWidth withLayoutGuidingContext:(id)aContext;
- (void)setSize:(NSSize)aSize withLayoutGuidingContext:(id)aContext;
- (id)HSGeometryBehaviorApplier_undoManager;
- (id)mutableGeometryAttributes;
- (id)geometryBehaviorAdaptor;
- (void)dealloc;
- (id)initWithGeometryBehaviorAdaptor:(id)aAdaptor;
@end

