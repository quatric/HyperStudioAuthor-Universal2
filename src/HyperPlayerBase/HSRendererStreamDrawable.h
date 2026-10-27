#import "HyperPlayerBasePrefix.h"
#import "HSStreamDrawable.h"


@interface HSRendererStreamDrawable : HSStreamDrawable
{
    id<HSRenderer> _renderer;
    CGAffineTransform _rendererTransform;
    CGAffineTransform _inverseRendererTransform;
    HSGenericRenderDelegate *_renderDelegate;
    id _autoInvalidationDelegate;
    unsigned int _autoInvalidates:1;
    unsigned int _isInverseRendererTransformValid:1;
}
- (void)drawRect:(NSRect)aRect;
- (void)HSRendererStreamDrawable_hyperObjectWillDidChangeVisualAttribute:(id)aAttribute;
- (void)setAutoInvalidationDelegate:(id)aDelegate;
- (id)autoInvalidationDelegate;
- (void)setAutoInvalidates:(BOOL)aInvalidates;
- (BOOL)autoInvalidates;
- (void)setRenderDelegate:(id)aDelegate;
- (id)renderDelegate;
- (id)HSRendererStreamDrawable_renderDelegateCreatingRenderCacheControllerIfNeeded:(BOOL)aNeeded;
- (CGAffineTransform)HSRendererStreamDrawable_inverseRendererTransform;
- (void)setRendererTransform:(CGAffineTransform)aTransform;
- (CGAffineTransform)rendererTransform;
- (void)setRenderer:(id)aRenderer invalidate:(BOOL)aInvalidate;
- (void)setRenderer:(id)aRenderer;
- (id)renderer;
- (void)dealloc;
- (id)initWithPixelBufferPoolAttributes:(id)aAttributes pixelBufferAttributes:(id)aAttributes2;
- (void)HSRendererStreamDrawable_stopAutoInvalidation;
- (void)HSRendererStreamDrawable_startAutoInvalidation;
@end

@interface NSObject (HSRendererStreamDrawableAutoInvalidationDelegate)
- (void)rendererStreamDrawable:(id)aDrawable didAutoInvalidateInRects:(NSRect *)aRects count:(NSUInteger)aCount;
@end

