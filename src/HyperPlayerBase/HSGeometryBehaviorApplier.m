#import "HSGeometryBehaviorApplier.h"
#import "HSUndoManager.h"

static NSString *HSApplierUndoName(NSString *aKey)
{
    return [[NSBundle mainBundle] localizedStringForKey:aKey value:@"" table:@"UndoManager"];
}

@implementation HSGeometryBehaviorApplier

- (void)resizeFrameProportionallyBy:(CGFloat)aBy aboutRelativePoint:(NSPoint)aPoint followResizingScalingPreference:(BOOL)aPreference withLayoutGuidingContext:(id)aContext
{
    [[self HSGeometryBehaviorApplier_undoManager] setActionName:HSApplierUndoName(@"Resize")];
    NSSize size = NSZeroSize;
    CGAffineTransform transform = CGAffineTransformIdentity;
    BOOL flipped = NO;
    [_geometryBehaviorAdaptor adaptResizingFrameProportionallyBy:aBy aboutRelativePoint:aPoint followResizingScalingPreference:aPreference withLayoutGuidingContext:aContext adaptedSize:&size affineTransform:&transform flippedHorizontally:&flipped];
    [_mutableGeometryAttributes setSize:size affineTransform:transform flippedHorizontally:flipped];
}

- (void)resizeFrameProportionallyBy:(CGFloat)aBy aboutRelativePoint:(NSPoint)aPoint withLayoutGuidingContext:(id)aContext
{
    [self resizeFrameProportionallyBy:aBy aboutRelativePoint:aPoint followResizingScalingPreference:YES withLayoutGuidingContext:aContext];
}

- (void)resizeFrameBy:(NSSize)aBy aboutRelativePoint:(NSPoint)aPoint followResizingScalingPreference:(BOOL)aPreference maintainAspectRatio:(NSInteger)aRatio byAspectRatioMaintainingRule:(NSInteger)aRule withLayoutGuidingContext:(id)aContext
{
    [[self HSGeometryBehaviorApplier_undoManager] setActionName:HSApplierUndoName(@"Resize")];
    NSSize size = NSZeroSize;
    CGAffineTransform transform = CGAffineTransformIdentity;
    BOOL flipped = NO;
    [_geometryBehaviorAdaptor adaptResizingFrameBy:aBy aboutRelativePoint:aPoint followResizingScalingPreference:aPreference maintainAspectRatio:aRatio byAspectRatioMaintainingRule:aRule withLayoutGuidingContext:aContext adaptedSize:&size affineTransform:&transform flippedHorizontally:&flipped];
    [_mutableGeometryAttributes setSize:size affineTransform:transform flippedHorizontally:flipped];
}

- (void)resizeFrameBy:(NSSize)aBy aboutRelativePoint:(NSPoint)aPoint withLayoutGuidingContext:(id)aContext
{
    [self resizeFrameBy:aBy aboutRelativePoint:aPoint followResizingScalingPreference:YES maintainAspectRatio:0 byAspectRatioMaintainingRule:0 withLayoutGuidingContext:aContext];
}

- (void)resizeFrameTo:(NSSize)aTo aboutRelativePoint:(NSPoint)aPoint followResizingScalingPreference:(BOOL)aPreference maintainAspectRatio:(NSInteger)aRatio byAspectRatioMaintainingRule:(NSInteger)aRule withLayoutGuidingContext:(id)aContext
{
    [self resizeFrameTo:aTo aboutRelativePoint:aPoint followResizingScalingPreference:aPreference maintainAspectRatio:aRatio byAspectRatioMaintainingRule:aRule withLayoutGuidingContext:aContext force:NO];
}

- (void)resizeFrameTo:(NSSize)aTo aboutRelativePoint:(NSPoint)aPoint followResizingScalingPreference:(BOOL)aPreference maintainAspectRatio:(NSInteger)aRatio byAspectRatioMaintainingRule:(NSInteger)aRule withLayoutGuidingContext:(id)aContext force:(BOOL)aForce
{
    [[self HSGeometryBehaviorApplier_undoManager] setActionName:HSApplierUndoName(@"Resize")];
    NSSize size = NSZeroSize;
    CGAffineTransform transform = CGAffineTransformIdentity;
    [_geometryBehaviorAdaptor adaptResizingFrameTo:aTo aboutRelativePoint:aPoint followResizingScalingPreference:aPreference maintainAspectRatio:aRatio byAspectRatioMaintainingRule:aRule withLayoutGuidingContext:aContext force:aForce adaptedSize:&size affineTransform:&transform];
    [_mutableGeometryAttributes setSize:size affineTransform:transform];
}

- (void)resizeFrameTo:(NSSize)aTo aboutRelativePoint:(NSPoint)aPoint withLayoutGuidingContext:(id)aContext
{
    [self resizeFrameTo:aTo aboutRelativePoint:aPoint withLayoutGuidingContext:aContext force:NO];
}

- (void)resizeFrameTo:(NSSize)aTo aboutRelativePoint:(NSPoint)aPoint withLayoutGuidingContext:(id)aContext force:(BOOL)aForce
{
    [self resizeFrameTo:aTo aboutRelativePoint:aPoint followResizingScalingPreference:YES maintainAspectRatio:0 byAspectRatioMaintainingRule:0 withLayoutGuidingContext:aContext force:aForce];
}

- (void)resizeFrameToHeight:(CGFloat)aHeight aboutRelativePoint:(NSPoint)aPoint followResizingScalingPreference:(BOOL)aPreference maintainAspectRatio:(NSInteger)aRatio withLayoutGuidingContext:(id)aContext
{
    [[self HSGeometryBehaviorApplier_undoManager] setActionName:HSApplierUndoName(@"Resize")];
    NSSize size = NSZeroSize;
    CGAffineTransform transform = CGAffineTransformIdentity;
    [_geometryBehaviorAdaptor adaptResizingFrameToHeight:aHeight aboutRelativePoint:aPoint followResizingScalingPreference:aPreference maintainAspectRatio:aRatio withLayoutGuidingContext:aContext adaptedSize:&size affineTransform:&transform];
    [_mutableGeometryAttributes setSize:size affineTransform:transform];
}

- (void)resizeFrameToHeight:(CGFloat)aHeight aboutRelativePoint:(NSPoint)aPoint withLayoutGuidingContext:(id)aContext
{
    [self resizeFrameToHeight:aHeight aboutRelativePoint:aPoint followResizingScalingPreference:YES maintainAspectRatio:0 withLayoutGuidingContext:aContext];
}

- (void)resizeFrameToWidth:(CGFloat)aWidth aboutRelativePoint:(NSPoint)aPoint followResizingScalingPreference:(BOOL)aPreference maintainAspectRatio:(NSInteger)aRatio withLayoutGuidingContext:(id)aContext
{
    [[self HSGeometryBehaviorApplier_undoManager] setActionName:HSApplierUndoName(@"Resize")];
    NSSize size = NSZeroSize;
    CGAffineTransform transform = CGAffineTransformIdentity;
    [_geometryBehaviorAdaptor adaptResizingFrameToWidth:aWidth aboutRelativePoint:aPoint followResizingScalingPreference:aPreference maintainAspectRatio:aRatio withLayoutGuidingContext:aContext adaptedSize:&size affineTransform:&transform];
    [_mutableGeometryAttributes setSize:size affineTransform:transform];
}

- (void)resizeFrameToWidth:(CGFloat)aWidth aboutRelativePoint:(NSPoint)aPoint withLayoutGuidingContext:(id)aContext
{
    [self resizeFrameToWidth:aWidth aboutRelativePoint:aPoint followResizingScalingPreference:YES maintainAspectRatio:0 withLayoutGuidingContext:aContext];
}

- (void)rotateBy:(CGFloat)aBy aboutRelativePoint:(NSPoint)aPoint withLayoutGuidingContext:(id)aContext
{
    [[self HSGeometryBehaviorApplier_undoManager] setActionName:HSApplierUndoName(@"Rotation")];
    [_mutableGeometryAttributes setAffineTransform:[_geometryBehaviorAdaptor adaptRotationBy:aBy aboutRelativePoint:aPoint withLayoutGuidingContext:aContext]];
}

- (void)rotateTo:(CGFloat)aTo aboutRelativePoint:(NSPoint)aPoint withLayoutGuidingContext:(id)aContext
{
    [[self HSGeometryBehaviorApplier_undoManager] setActionName:HSApplierUndoName(@"Rotation")];
    [_mutableGeometryAttributes setAffineTransform:[_geometryBehaviorAdaptor adaptRotationTo:aTo aboutRelativePoint:aPoint withLayoutGuidingContext:aContext]];
}

- (void)skewBy:(CGFloat)aBy withLayoutGuidingContext:(id)aContext
{
    [[self HSGeometryBehaviorApplier_undoManager] setActionName:HSApplierUndoName(@"Skew")];
    [_mutableGeometryAttributes setAffineTransform:[_geometryBehaviorAdaptor adaptSkewingBy:aBy withLayoutGuidingContext:aContext]];
}

- (void)skewTo:(CGFloat)aTo withLayoutGuidingContext:(id)aContext
{
    [[self HSGeometryBehaviorApplier_undoManager] setActionName:HSApplierUndoName(@"Skew")];
    [_mutableGeometryAttributes setAffineTransform:[_geometryBehaviorAdaptor adaptSkewingTo:aTo withLayoutGuidingContext:aContext]];
}

- (void)setFlippedVertically:(BOOL)aVertically withLayoutGuidingContext:(id)aContext
{
    if ((aVertically != NO) != ([_mutableGeometryAttributes isFlippedVertically] != NO))
        [self flipVerticallyWithLayoutGuidingContext:aContext];
}

- (void)flipVerticallyWithLayoutGuidingContext:(id)aContext
{
    [[self HSGeometryBehaviorApplier_undoManager] setActionName:HSApplierUndoName(@"Vertical Flip")];
    [_mutableGeometryAttributes setAffineTransform:[_geometryBehaviorAdaptor adaptFlippingVerticallyWithLayoutGuidingContext:aContext]];
}

- (void)setFlippedHorizontally:(BOOL)aHorizontally withLayoutGuidingContext:(id)aContext
{
    if ((aHorizontally != NO) != ([_mutableGeometryAttributes isFlippedHorizontally] != NO))
        [self flipHorizontallyWithLayoutGuidingContext:aContext];
}

- (void)flipHorizontallyWithLayoutGuidingContext:(id)aContext
{
    [[self HSGeometryBehaviorApplier_undoManager] setActionName:HSApplierUndoName(@"Horizontal Flip")];
    CGAffineTransform transform = CGAffineTransformIdentity;
    BOOL flipped = NO;
    [_geometryBehaviorAdaptor adaptFlippingHorizontallyWithLayoutGuidingContext:aContext adaptedAffineTransform:&transform flippedHorizontally:&flipped];
    [_mutableGeometryAttributes setAffineTransform:transform flippedHorizontally:flipped];
}

- (void)sizeScaleTo:(NSSize)aTo aboutRelativePoint:(NSPoint)aPoint maintainAspectRatio:(NSInteger)aRatio byAspectRatioMaintainingRule:(NSInteger)aRule withLayoutGuidingContext:(id)aContext
{
    [[self HSGeometryBehaviorApplier_undoManager] setActionName:HSApplierUndoName(@"Scale")];
    [_mutableGeometryAttributes setAffineTransform:[_geometryBehaviorAdaptor adaptSizeScalingTo:aTo aboutRelativePoint:aPoint maintainAspectRatio:aRatio byAspectRatioMaintainingRule:aRule withLayoutGuidingContext:aContext]];
}

- (void)sizeScaleTo:(NSSize)aTo aboutRelativePoint:(NSPoint)aPoint withLayoutGuidingContext:(id)aContext
{
    [self sizeScaleTo:aTo aboutRelativePoint:aPoint maintainAspectRatio:0 byAspectRatioMaintainingRule:0 withLayoutGuidingContext:aContext];
}

- (void)heightScaleTo:(CGFloat)aTo aboutRelativePoint:(NSPoint)aPoint maintainAspectRatio:(NSInteger)aRatio withLayoutGuidingContext:(id)aContext
{
    [[self HSGeometryBehaviorApplier_undoManager] setActionName:HSApplierUndoName(@"Scale")];
    NSSize scale = NSMakeSize([_mutableGeometryAttributes widthScale], aTo);
    [_mutableGeometryAttributes setAffineTransform:[_geometryBehaviorAdaptor adaptSizeScalingTo:scale aboutRelativePoint:aPoint maintainAspectRatio:aRatio byAspectRatioMaintainingRule:3 withLayoutGuidingContext:aContext]];
}

- (void)heightScaleTo:(CGFloat)aTo aboutRelativePoint:(NSPoint)aPoint withLayoutGuidingContext:(id)aContext
{
    [self heightScaleTo:aTo aboutRelativePoint:aPoint maintainAspectRatio:0 withLayoutGuidingContext:aContext];
}

- (void)widthScaleTo:(CGFloat)aTo aboutRelativePoint:(NSPoint)aPoint maintainAspectRatio:(NSInteger)aRatio withLayoutGuidingContext:(id)aContext
{
    [[self HSGeometryBehaviorApplier_undoManager] setActionName:HSApplierUndoName(@"Scale")];
    NSSize scale = NSMakeSize(aTo, [_mutableGeometryAttributes heightScale]);
    [_mutableGeometryAttributes setAffineTransform:[_geometryBehaviorAdaptor adaptSizeScalingTo:scale aboutRelativePoint:aPoint maintainAspectRatio:aRatio byAspectRatioMaintainingRule:2 withLayoutGuidingContext:aContext]];
}

- (void)widthScaleTo:(CGFloat)aTo aboutRelativePoint:(NSPoint)aPoint withLayoutGuidingContext:(id)aContext
{
    [self widthScaleTo:aTo aboutRelativePoint:aPoint maintainAspectRatio:0 withLayoutGuidingContext:aContext];
}

- (void)sizeScaleProportionallyBy:(CGFloat)aBy aboutRelativePoint:(NSPoint)aPoint withLayoutGuidingContext:(id)aContext
{
    [[self HSGeometryBehaviorApplier_undoManager] setActionName:HSApplierUndoName(@"Scale")];
    CGAffineTransform transform = CGAffineTransformIdentity;
    BOOL flipped = NO;
    [_geometryBehaviorAdaptor adaptSizeScalingProportionallyBy:aBy aboutRelativePoint:aPoint withLayoutGuidingContext:aContext adaptedAffineTransform:&transform flippedHorizontally:&flipped];
    [_mutableGeometryAttributes setAffineTransform:transform flippedHorizontally:flipped];
}

- (void)sizeScaleBy:(NSSize)aBy aboutRelativePoint:(NSPoint)aPoint maintainAspectRatio:(NSInteger)aRatio byAspectRatioMaintainingRule:(NSInteger)aRule withLayoutGuidingContext:(id)aContext
{
    [[self HSGeometryBehaviorApplier_undoManager] setActionName:HSApplierUndoName(@"Scale")];
    CGAffineTransform transform = CGAffineTransformIdentity;
    BOOL flipped = NO;
    [_geometryBehaviorAdaptor adaptSizeScalingBy:aBy aboutRelativePoint:aPoint maintainAspectRatio:aRatio byAspectRatioMaintainingRule:aRule withLayoutGuidingContext:aContext adaptedAffineTransform:&transform flippedHorizontally:&flipped];
    [_mutableGeometryAttributes setAffineTransform:transform flippedHorizontally:flipped];
}

- (void)sizeScaleBy:(NSSize)aBy aboutRelativePoint:(NSPoint)aPoint withLayoutGuidingContext:(id)aContext
{
    [self sizeScaleBy:aBy aboutRelativePoint:aPoint maintainAspectRatio:0 byAspectRatioMaintainingRule:0 withLayoutGuidingContext:aContext];
}

// The center is the transformed midpoint of the untransformed size.
- (void)moveCenterTo:(NSPoint)aTo withLayoutGuidingContext:(id)aContext
{
    NSSize size = [_mutableGeometryAttributes size];
    CGAffineTransform t = [_mutableGeometryAttributes affineTransform];
    CGFloat x = t.a * size.width * 0.5 + t.c * size.height * 0.5 + t.tx;
    CGFloat y = t.b * size.width * 0.5 + t.d * size.height * 0.5 + t.ty;
    [self moveBy:NSMakeSize(aTo.x - x, aTo.y - y) withLayoutGuidingContext:aContext];
}

- (void)moveVerticalCenterTo:(CGFloat)aTo withLayoutGuidingContext:(id)aContext
{
    NSSize size = [_mutableGeometryAttributes size];
    CGAffineTransform t = [_mutableGeometryAttributes affineTransform];
    [self moveVerticallyBy:aTo - (size.width * 0.5 * t.b + size.height * 0.5 * t.d + t.ty) withLayoutGuidingContext:aContext];
}

- (void)moveHorizontalCenterTo:(CGFloat)aTo withLayoutGuidingContext:(id)aContext
{
    NSSize size = [_mutableGeometryAttributes size];
    CGAffineTransform t = [_mutableGeometryAttributes affineTransform];
    [self moveHorizontallyBy:aTo - (size.width * 0.5 * t.a + size.height * 0.5 * t.c + t.tx) withLayoutGuidingContext:aContext];
}

- (void)moveMaxVerticalFrameBoundTo:(CGFloat)aTo withLayoutGuidingContext:(id)aContext
{
    NSRect frame = [_mutableGeometryAttributes frameBoundingRect];
    [self moveVerticallyBy:aTo - (frame.origin.y + frame.size.height) withLayoutGuidingContext:aContext];
}

- (void)moveMinVerticalFrameBoundTo:(CGFloat)aTo withLayoutGuidingContext:(id)aContext
{
    NSRect frame = [_mutableGeometryAttributes frameBoundingRect];
    [self moveVerticallyBy:aTo - frame.origin.y withLayoutGuidingContext:aContext];
}

- (void)moveMaxHorizontalFrameBoundTo:(CGFloat)aTo withLayoutGuidingContext:(id)aContext
{
    NSRect frame = [_mutableGeometryAttributes frameBoundingRect];
    [self moveHorizontallyBy:aTo - (frame.origin.x + frame.size.width) withLayoutGuidingContext:aContext];
}

- (void)moveMinHorizontalFrameBoundTo:(CGFloat)aTo withLayoutGuidingContext:(id)aContext
{
    NSRect frame = [_mutableGeometryAttributes frameBoundingRect];
    [self moveHorizontallyBy:aTo - frame.origin.x withLayoutGuidingContext:aContext];
}

- (void)moveFrameBoundingRectOriginTo:(NSPoint)aTo withLayoutGuidingContext:(id)aContext
{
    NSRect frame = [_mutableGeometryAttributes frameBoundingRect];
    [self moveBy:NSMakeSize(aTo.x - frame.origin.x, aTo.y - frame.origin.y) withLayoutGuidingContext:aContext];
}

// Names the multiple-actions group rather than the single action (original).
- (void)moveBy:(NSSize)aBy withLayoutGuidingContext:(id)aContext
{
    [(HSUndoManager *)[self HSGeometryBehaviorApplier_undoManager] setMultipleActionsName:HSApplierUndoName(@"Move")];
    [_mutableGeometryAttributes setAffineTransform:[_geometryBehaviorAdaptor adaptMovingBy:aBy withLayoutGuidingContext:aContext]];
}

- (void)moveVerticallyBy:(CGFloat)aBy withLayoutGuidingContext:(id)aContext
{
    [[self HSGeometryBehaviorApplier_undoManager] setActionName:HSApplierUndoName(@"Move")];
    [_mutableGeometryAttributes setAffineTransform:[_geometryBehaviorAdaptor adaptMovingVerticallyBy:aBy withLayoutGuidingContext:aContext]];
}

- (void)moveHorizontallyBy:(CGFloat)aBy withLayoutGuidingContext:(id)aContext
{
    [[self HSGeometryBehaviorApplier_undoManager] setActionName:HSApplierUndoName(@"Move")];
    [_mutableGeometryAttributes setAffineTransform:[_geometryBehaviorAdaptor adaptMovingHorizontallyBy:aBy withLayoutGuidingContext:aContext]];
}

- (void)resizeProportionallyBy:(CGFloat)aBy aboutRelativePoint:(NSPoint)aPoint withLayoutGuidingContext:(id)aContext
{
    [[self HSGeometryBehaviorApplier_undoManager] setActionName:HSApplierUndoName(@"Resize")];
    NSSize size = NSZeroSize;
    CGAffineTransform transform = CGAffineTransformIdentity;
    BOOL flipped = NO;
    [_geometryBehaviorAdaptor adaptResizingProportionallyBy:aBy aboutRelativePoint:aPoint withLayoutGuidingContext:aContext adaptedSize:&size affineTransform:&transform flippedHorizontally:&flipped];
    [_mutableGeometryAttributes setSize:size affineTransform:transform flippedHorizontally:flipped];
}

- (void)resizeBy:(NSSize)aBy aboutRelativePoint:(NSPoint)aPoint maintainAspectRatio:(NSInteger)aRatio byAspectRatioMaintainingRule:(NSInteger)aRule withLayoutGuidingContext:(id)aContext
{
    [[self HSGeometryBehaviorApplier_undoManager] setActionName:HSApplierUndoName(@"Resize")];
    NSSize size = NSZeroSize;
    CGAffineTransform transform = CGAffineTransformIdentity;
    BOOL flipped = NO;
    [_geometryBehaviorAdaptor adaptResizingBy:aBy aboutRelativePoint:aPoint maintainAspectRatio:aRatio byAspectRatioMaintainingRule:aRule withLayoutGuidingContext:aContext adaptedSize:&size affineTransform:&transform flippedHorizontally:&flipped];
    [_mutableGeometryAttributes setSize:size affineTransform:transform flippedHorizontally:flipped];
}

- (void)resizeBy:(NSSize)aBy aboutRelativePoint:(NSPoint)aPoint withLayoutGuidingContext:(id)aContext
{
    [self resizeBy:aBy aboutRelativePoint:aPoint maintainAspectRatio:0 byAspectRatioMaintainingRule:0 withLayoutGuidingContext:aContext];
}

- (void)resizeTo:(NSSize)aTo aboutRelativePoint:(NSPoint)aPoint maintainAspectRatio:(NSInteger)aRatio byAspectRatioMaintainingRule:(NSInteger)aRule withLayoutGuidingContext:(id)aContext
{
    [[self HSGeometryBehaviorApplier_undoManager] setActionName:HSApplierUndoName(@"Resize")];
    NSSize size = NSZeroSize;
    CGAffineTransform transform = CGAffineTransformIdentity;
    [_geometryBehaviorAdaptor adaptResizingTo:aTo aboutRelativePoint:aPoint maintainAspectRatio:aRatio byAspectRatioMaintainingRule:aRule withLayoutGuidingContext:aContext adaptedSize:&size affineTransform:&transform];
    [_mutableGeometryAttributes setSize:size affineTransform:transform];
}

- (void)resizeTo:(NSSize)aTo aboutRelativePoint:(NSPoint)aPoint withLayoutGuidingContext:(id)aContext
{
    [self resizeTo:aTo aboutRelativePoint:aPoint maintainAspectRatio:0 byAspectRatioMaintainingRule:0 withLayoutGuidingContext:aContext];
}

- (void)resizeToHeight:(CGFloat)aHeight aboutRelativePoint:(NSPoint)aPoint maintainAspectRatio:(NSInteger)aRatio withLayoutGuidingContext:(id)aContext
{
    [[self HSGeometryBehaviorApplier_undoManager] setActionName:HSApplierUndoName(@"Resize")];
    NSSize size = NSZeroSize;
    CGAffineTransform transform = CGAffineTransformIdentity;
    NSSize target = NSMakeSize([_mutableGeometryAttributes width], aHeight);
    [_geometryBehaviorAdaptor adaptResizingTo:target aboutRelativePoint:aPoint maintainAspectRatio:aRatio byAspectRatioMaintainingRule:3 withLayoutGuidingContext:aContext adaptedSize:&size affineTransform:&transform];
    [_mutableGeometryAttributes setSize:size affineTransform:transform];
}

- (void)resizeToHeight:(CGFloat)aHeight aboutRelativePoint:(NSPoint)aPoint withLayoutGuidingContext:(id)aContext
{
    [self resizeToHeight:aHeight aboutRelativePoint:aPoint maintainAspectRatio:0 withLayoutGuidingContext:aContext];
}

- (void)resizeToWidth:(CGFloat)aWidth aboutRelativePoint:(NSPoint)aPoint maintainAspectRatio:(NSInteger)aRatio withLayoutGuidingContext:(id)aContext
{
    [[self HSGeometryBehaviorApplier_undoManager] setActionName:HSApplierUndoName(@"Resize")];
    NSSize size = NSZeroSize;
    CGAffineTransform transform = CGAffineTransformIdentity;
    NSSize target = NSMakeSize(aWidth, [_mutableGeometryAttributes height]);
    [_geometryBehaviorAdaptor adaptResizingTo:target aboutRelativePoint:aPoint maintainAspectRatio:aRatio byAspectRatioMaintainingRule:2 withLayoutGuidingContext:aContext adaptedSize:&size affineTransform:&transform];
    [_mutableGeometryAttributes setSize:size affineTransform:transform];
}

- (void)resizeToWidth:(CGFloat)aWidth aboutRelativePoint:(NSPoint)aPoint withLayoutGuidingContext:(id)aContext
{
    [self resizeToWidth:aWidth aboutRelativePoint:aPoint maintainAspectRatio:0 withLayoutGuidingContext:aContext];
}

- (void)setSize:(NSSize)aSize affineTransform:(CGAffineTransform)aTransform flippedHorizontally:(BOOL)aHorizontally withLayoutGuidingContext:(id)aContext
{
    [[self HSGeometryBehaviorApplier_undoManager] setActionName:HSApplierUndoName(@"Change Geometry")];
    [_geometryBehaviorAdaptor adaptSize:&aSize affineTransform:&aTransform flippedHorizontally:&aHorizontally withLayoutGuidingContext:aContext];
    [_mutableGeometryAttributes setSize:aSize affineTransform:aTransform flippedHorizontally:aHorizontally];
}

// No undo action name is set for the transform-only setters (original).
- (void)setAffineTransform:(CGAffineTransform)aTransform flippedHorizontally:(BOOL)aHorizontally withLayoutGuidingContext:(id)aContext
{
    [_geometryBehaviorAdaptor adaptAffineTransform:&aTransform flippedHorizontally:&aHorizontally withLayoutGuidingContext:aContext];
    [_mutableGeometryAttributes setAffineTransform:aTransform flippedHorizontally:aHorizontally];
}

- (void)setAffineTransform:(CGAffineTransform)aTransform withLayoutGuidingContext:(id)aContext
{
    [_geometryBehaviorAdaptor adaptAffineTransform:&aTransform flippedHorizontally:NULL withLayoutGuidingContext:aContext];
    [_mutableGeometryAttributes setAffineTransform:aTransform];
}

- (void)resizeProportionallyBy:(CGFloat)aBy withLayoutGuidingContext:(id)aContext
{
    [_mutableGeometryAttributes setSize:[_geometryBehaviorAdaptor adaptResizingProportionallyBy:aBy withLayoutGuidingContext:aContext]];
}

- (void)resizeBy:(NSSize)aBy maintainAspectRatio:(NSInteger)aRatio byAspectRatioMaintainingRule:(NSInteger)aRule withLayoutGuidingContext:(id)aContext
{
    NSSize size = [_mutableGeometryAttributes size];
    [self resizeTo:NSMakeSize(size.width * aBy.width, size.height * aBy.height) maintainAspectRatio:aRatio byAspectRatioMaintainingRule:aRule withLayoutGuidingContext:aContext];
}

- (void)resizeBy:(NSSize)aBy withLayoutGuidingContext:(id)aContext
{
    [self resizeBy:aBy maintainAspectRatio:0 byAspectRatioMaintainingRule:0 withLayoutGuidingContext:aContext];
}

- (void)resizeTo:(NSSize)aTo maintainAspectRatio:(NSInteger)aRatio byAspectRatioMaintainingRule:(NSInteger)aRule withLayoutGuidingContext:(id)aContext
{
    [_mutableGeometryAttributes setSize:[_geometryBehaviorAdaptor adaptResizingTo:aTo maintainAspectRatio:aRatio byAspectRatioMaintainingRule:aRule withLayoutGuidingContext:aContext]];
}

- (void)resizeTo:(NSSize)aTo withLayoutGuidingContext:(id)aContext
{
    [self resizeTo:aTo maintainAspectRatio:0 byAspectRatioMaintainingRule:0 withLayoutGuidingContext:aContext];
}

// Quirk kept: both axis variants without a reference point pass rule 2, where
// the about-point variants pass 3 for height and 2 for width.
- (void)resizeToHeight:(CGFloat)aHeight maintainAspectRatio:(NSInteger)aRatio withLayoutGuidingContext:(id)aContext
{
    NSSize target = NSMakeSize([_mutableGeometryAttributes width], aHeight);
    [_mutableGeometryAttributes setSize:[_geometryBehaviorAdaptor adaptResizingTo:target maintainAspectRatio:aRatio byAspectRatioMaintainingRule:2 withLayoutGuidingContext:aContext]];
}

- (void)resizeToHeight:(CGFloat)aHeight withLayoutGuidingContext:(id)aContext
{
    [self resizeToHeight:aHeight maintainAspectRatio:0 withLayoutGuidingContext:aContext];
}

- (void)resizeToWidth:(CGFloat)aWidth maintainAspectRatio:(NSInteger)aRatio withLayoutGuidingContext:(id)aContext
{
    NSSize target = NSMakeSize(aWidth, [_mutableGeometryAttributes height]);
    [_mutableGeometryAttributes setSize:[_geometryBehaviorAdaptor adaptResizingTo:target maintainAspectRatio:aRatio byAspectRatioMaintainingRule:2 withLayoutGuidingContext:aContext]];
}

- (void)resizeToWidth:(CGFloat)aWidth withLayoutGuidingContext:(id)aContext
{
    [self resizeToWidth:aWidth maintainAspectRatio:0 withLayoutGuidingContext:aContext];
}

- (void)setSize:(NSSize)aSize withLayoutGuidingContext:(id)aContext
{
    [_mutableGeometryAttributes setSize:[_geometryBehaviorAdaptor adaptSize:aSize withLayoutGuidingContext:aContext]];
}

- (id)HSGeometryBehaviorApplier_undoManager
{
    id object = [_mutableGeometryAttributes hyperObject];
    if (![object conformsToProtocol:@protocol(HSNodeSupport)])
        return nil;
    return [object undoManager];
}

- (id)mutableGeometryAttributes
{
    return _mutableGeometryAttributes;
}

- (id)geometryBehaviorAdaptor
{
    return _geometryBehaviorAdaptor;
}

- (void)dealloc
{
    [_mutableGeometryAttributes release];
    [_geometryBehaviorAdaptor release];
    [super dealloc];
}

- (id)initWithGeometryBehaviorAdaptor:(id)aAdaptor
{
    self = [super init];
    if (self == nil)
        return nil;
    _mutableGeometryAttributes = [[aAdaptor queryHyperInterface:@protocol(HSMutableGeometryAttributes)] retain];
    if (_mutableGeometryAttributes == nil) {
        [self release];
        return nil;
    }
    _geometryBehaviorAdaptor = [aAdaptor retain];
    return self;
}

@end
