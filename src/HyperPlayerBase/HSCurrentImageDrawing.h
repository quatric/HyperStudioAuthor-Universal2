#import "HyperPlayerBasePrefix.h"


@interface HSCurrentImageDrawing : NSObject
{
    id<HSImageObjectAttributes> _imageObjectAttributes;
    id<HSRenderer> _renderer;
    id _delegate;
}
+ (id)pngRepresentationOfImage:(struct CGImage *)aImage;
+ (id)drawingForImageObject:(id)aObject;
- (id)optimizedCurrentImagePNGRepresentationOfSize:(NSSize *)aSize;
- (id)currentImagePNGRepresentationOfSize:(NSSize *)aSize;
- (id)currentImagePNGRepresentationWithPixelSize:(NSSize)aSize;
- (struct CGImage *)currentCGImageOfSize:(NSSize *)aSize isFlippedHorizontally:(BOOL)aHorizontally isFlippedVertically:(BOOL)aVertically;
- (struct CGImage *)currentCGImageOfSize:(NSSize *)aSize;
- (struct CGImage *)currentCGImageWithPixelSize:(NSSize)aSize;
- (struct __CVBuffer *)currentCVPixelBufferOfSize:(NSSize *)aSize isFlippedHorizontally:(BOOL)aHorizontally isFlippedVertically:(BOOL)aVertically;
- (struct __CVBuffer *)currentCVPixelBufferOfSize:(NSSize *)aSize;
- (struct __CVBuffer *)currentCVPixelBufferWithPixelSize:(NSSize)aSize isFlippedHorizontally:(BOOL)aHorizontally isFlippedVertically:(BOOL)aVertically;
- (struct __CVBuffer *)currentCVPixelBufferWithPixelSize:(NSSize)aSize;
- (NSSize)requiredSizeForNotOptimizedImage;
- (NSSize)requiredSizeForOptimizedImage;
- (NSSize)requiredSizeForNotOptimizedNotVectorImage;
- (NSSize)currentEffectRelativeExtent;
- (NSRect)currentImageAndObjectBoundsUnionRect;
- (NSRect)objectBoundingRect;
- (NSRect)imageBoundingRect;
- (id)renderer;
- (void)setDelegate:(id)aDelegate;
- (id)delegate;
- (void)setImageObjectAtributes:(id)aAtributes;
- (id)imageObjectAttributes;
- (void)dealloc;
- (id)initWithImageObject:(id)aObject;
@end

