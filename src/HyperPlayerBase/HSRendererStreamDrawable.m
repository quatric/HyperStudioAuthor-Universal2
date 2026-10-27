#import "HSRendererStreamDrawable.h"
#import "HSGenericRenderCacheController.h"
#import "HSGenericRenderDelegate.h"
#import "HSMutableRegion.h"

// A stream drawable showing one renderer through a transform. With auto
// invalidation on, it watches the renderer's object and invalidates what a
// visual change touches.
@implementation HSRendererStreamDrawable

- (void)drawRect:(NSRect)aRect
{
    CGContextConcatCTM([[NSGraphicsContext currentContext] CGContext], _rendererTransform);
    HSMutableRegion *region = [HSMutableRegion region];
    NSRect *rects = NULL;
    unsigned int count = 0;
    [self getRectsBeingDrawn:&rects count:&count];
    for (unsigned int i = 0; i < count; i++)
        [region addRect:rects[i]];
    [region applyAffineTransform:[self HSRendererStreamDrawable_inverseRendererTransform]];
    [_renderer drawRegion:region withDelegate:[self HSRendererStreamDrawable_renderDelegateCreatingRenderCacheControllerIfNeeded:YES]];
}

- (void)HSRendererStreamDrawable_hyperObjectWillDidChangeVisualAttribute:(id)aAttribute
{
    HSMutableRegion *region = [HSMutableRegion region];
    [_renderer unionBoundingRegionOfAttributeSet:[aAttribute attributeProtocolSet] ofHyperObject:[aAttribute object] withInfo:[aAttribute userInfo] withRegion:region];
    [region applyAffineTransform:[self rendererTransform]];
    if ([region isEmpty])
        return;
    NSRect rect = NSIntegralRect(NSInsetRect([region boundingRect], -1.05, -1.05));
    [self invalidateInRect:rect];
    [_autoInvalidationDelegate rendererStreamDrawable:self didAutoInvalidateInRects:&rect count:1];
}

- (void)setAutoInvalidationDelegate:(id)aDelegate
{
    _autoInvalidationDelegate = aDelegate;
}

- (id)autoInvalidationDelegate
{
    return _autoInvalidationDelegate;
}

- (void)setAutoInvalidates:(BOOL)aInvalidates
{
    if (_autoInvalidates == aInvalidates)
        return;
    if (_renderer != nil) {
        if (aInvalidates)
            [self HSRendererStreamDrawable_startAutoInvalidation];
        else
            [self HSRendererStreamDrawable_stopAutoInvalidation];
    }
    _autoInvalidates = aInvalidates;
}

- (BOOL)autoInvalidates
{
    return _autoInvalidates;
}

- (void)setRenderDelegate:(id)aDelegate
{
    [_renderDelegate release];
    _renderDelegate = [aDelegate retain];
}

- (id)renderDelegate
{
    return [self HSRendererStreamDrawable_renderDelegateCreatingRenderCacheControllerIfNeeded:YES];
}

- (id)HSRendererStreamDrawable_renderDelegateCreatingRenderCacheControllerIfNeeded:(BOOL)aNeeded
{
    if (_renderDelegate == nil) {
        _renderDelegate = [[HSGenericRenderDelegate alloc] initWithDrawable:nil];
        if (_renderDelegate != nil && aNeeded) {
            HSGenericRenderCacheController *controller = [[HSGenericRenderCacheController alloc] init];
            if (controller != nil) {
                [_renderDelegate setRenderCacheController:controller];
                [controller release];
            }
        }
    }
    return _renderDelegate;
}

- (CGAffineTransform)HSRendererStreamDrawable_inverseRendererTransform
{
    if (!_isInverseRendererTransformValid) {
        _inverseRendererTransform = CGAffineTransformInvert(_rendererTransform);
        _isInverseRendererTransformValid = YES;
    }
    return _inverseRendererTransform;
}

- (void)setRendererTransform:(CGAffineTransform)aTransform
{
    if (CGAffineTransformEqualToTransform(aTransform, _rendererTransform))
        return;
    _rendererTransform = aTransform;
    _isInverseRendererTransformValid = NO;
    [self invalidate];
}

- (CGAffineTransform)rendererTransform
{
    return _rendererTransform;
}

// Auto invalidation moves to the new renderer only when it shows another
// object.
- (void)setRenderer:(id)aRenderer invalidate:(BOOL)aInvalidate
{
    if (_renderer == aRenderer)
        return;
    BOOL restartAutoInvalidation = NO;
    if (_autoInvalidates && [[[aRenderer visualization] hyperObject] hyperIdentifier] != [[[_renderer visualization] hyperObject] hyperIdentifier]) {
        if (_renderer != nil)
            [self HSRendererStreamDrawable_stopAutoInvalidation];
        restartAutoInvalidation = YES;
    }
    [aRenderer retain];
    [_renderer release];
    _renderer = aRenderer;
    if (aInvalidate)
        [self invalidate];
    if (_renderer != nil && restartAutoInvalidation)
        [self HSRendererStreamDrawable_startAutoInvalidation];
}

- (void)setRenderer:(id)aRenderer
{
    [self setRenderer:aRenderer invalidate:YES];
}

- (id)renderer
{
    return _renderer;
}

- (void)dealloc
{
    [_renderDelegate release];
    if (_renderer != nil) {
        if (_autoInvalidates)
            [self HSRendererStreamDrawable_stopAutoInvalidation];
        [_renderer release];
    }
    [super dealloc];
}

- (id)initWithPixelBufferPoolAttributes:(id)aAttributes pixelBufferAttributes:(id)aAttributes2
{
    self = [super initWithPixelBufferPoolAttributes:aAttributes pixelBufferAttributes:aAttributes2];
    if (self != nil)
        _rendererTransform = CGAffineTransformIdentity;
    return self;
}

- (void)HSRendererStreamDrawable_stopAutoInvalidation
{
    [[[[_renderer visualization] queryHyperInterface:@protocol(HSAttributes)] attributeObservingController] removeObserver:self selector:@selector(HSRendererStreamDrawable_hyperObjectWillDidChangeVisualAttribute:) ofChanges:HSActualAttributeChanges ofAttribute:@protocol(HSVisualAttribute)];
}

- (void)HSRendererStreamDrawable_startAutoInvalidation
{
    [[[[_renderer visualization] queryHyperInterface:@protocol(HSAttributes)] attributeObservingController] addObserver:self selector:@selector(HSRendererStreamDrawable_hyperObjectWillDidChangeVisualAttribute:) ofChanges:HSActualAttributeChanges ofAttribute:@protocol(HSVisualAttribute) withPriority:-0.75];
}

@end

@implementation NSObject (HSRendererStreamDrawableAutoInvalidationDelegate)

- (void)rendererStreamDrawable:(id)aDrawable didAutoInvalidateInRects:(NSRect *)aRects count:(NSUInteger)aCount
{
}

@end
