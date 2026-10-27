#import "HyperPlayerBasePrefix.h"


@interface HSImageCropApplier : NSObject
{
    id<HSImageObjectAttributes> _imageObjectAttributes;
    struct CGPath *_cropPath;
    HSCurrentImageDrawing *_drawing;
}
+ (id)cropApplierForImageObject:(id)aObject;
- (NSRect)imageObjectDrawing:(id)aDrawing imageBoundsForObjectBoundingRect:(NSRect)aRect;
- (void)imageObjectDrawing:(id)aDrawing willDrawImageInContext:(struct CGContext *)aContext;
- (void)adjustObjectSizeToBorderSize;
- (void)updateCurrentBorderPath;
- (void)setCurrentBorderPath:(id)aPath transform:(CGAffineTransform *)aTransform;
- (void)setupInitialClipPathsIfNeeded;
- (id)calculateBorderPath;
- (void)updateEffectedImageObject;
- (void)updateEffectedMediaAndBorderWithAdjustingToBorderSize:(BOOL)aSize;
- (void)updateEffectedMediaWithoutAdjustingToBorderSize;
- (BOOL)canUpdateEffectedMedia;
- (void)adjustObjectToBorderSizeWithRelativeBorderPath:(id)aPath;
- (void)cropImageObjectWithPaths:(id)aPaths modifyObjectGeometry:(BOOL)aGeometry;
- (void)cropImageObjectWithPath:(struct CGPath *)aPath;
- (void)cropImageObjectAndModifyGeometryWithPath:(struct CGPath *)aPath;
- (void)cropImageObjectWithPaths:(id)aPaths;
- (void)cropImageObjectAndModifyGeometryWithCurrentCropPath;
- (BOOL)canApplyCurrentCropPathToImageObject;
- (NSRect)croppedImageFrame;
- (NSRect)croppedImageFrameForObjectBoundingRect:(NSRect)aRect;
- (id)croppedImageDrawing;
- (void)setCropPath:(struct CGPath *)aPath;
- (struct CGPath *)cropPath;
- (id)geometryBehaviorApplier;
- (id)clipPathsAttributes;
- (id)imageObjectAttributes;
- (void)dealloc;
- (id)initWithImageObject:(id)aObject;
@end

