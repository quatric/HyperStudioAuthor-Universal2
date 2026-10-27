#import "BTCGLayer.h"
#import "BTMutableCGImageUndoer.h"

@implementation BTCGLayer

+ (id)layerWithCGLayer:(struct CGLayer *)aLayer
{
    return [[[self alloc] initWithCGLayer:aLayer] autorelease];
}

- (id)init
{
    [self release];
    return nil;
}

- (id)initWithCGLayer:(struct CGLayer *)aLayer
{
    self = [super init];
    if (!self)
        return nil;
    _layer = CGLayerRetain(aLayer);
    return self;
}

- (void)dealloc
{
    [_layerGraphicsContext release];
    CGLayerRelease(_layer);
    [super dealloc];
}

- (struct CGLayer *)CGLayer
{
    return _layer;
}

- (CGSize)imageSize
{
    return CGLayerGetSize(_layer);
}

- (struct CGPDFDocument *)coreGraphicsPDFDocument
{
    return NULL;
}

- (struct CGColorSpace *)coreGraphicsColorSpace
{
    return NULL;
}

- (struct CGImage *)coreGraphicsImage
{
    return NULL;
}

- (struct CGColor *)colorAtPoint:(CGPoint)aPoint
{
    if (!BTIsImagePoint(self, aPoint))
        return NULL;
    return (CGColorRef)CFAutorelease(BTCopyColorFromCGImage(self, aPoint));
}

- (void)drawInCGContext:(struct CGContext *)aContext inRect:(CGRect)aRect
{
    CGContextDrawLayerInRect(aContext, aRect, _layer);
}

- (void)drawInCGContext:(struct CGContext *)aContext atPoint:(CGPoint)aPoint
{
    CGContextDrawLayerAtPoint(aContext, aPoint, _layer);
}

- (void)drawInCurrentNSGraphicsContextInRect:(NSRect)aRect
{
    [self drawInCGContext:[[NSGraphicsContext currentContext] CGContext] inRect:NSRectToCGRect(aRect)];
}

- (void)drawInCurrentNSGraphicsContextAtPoint:(NSPoint)aPoint
{
    [self drawInCGContext:[[NSGraphicsContext currentContext] CGContext] atPoint:NSPointToCGPoint(aPoint)];
}

- (id)createImageUndoerWithDelegate:(id)aDelegate
{
    return [[BTMutableCGImageUndoer allocWithZone:[self zone]] initWithImage:self delegate:aDelegate];
}

- (void)prepareCGEditing
{
}

- (void)beginCGEditing
{
    [self prepareCGEditing];
    CGContextSaveGState(CGLayerGetContext(_layer));
}

- (struct CGContext *)imageCGContext
{
    return CGLayerGetContext(_layer);
}

- (void)endCGEditing
{
    CGContextRestoreGState(CGLayerGetContext(_layer));
    [self finalizeCGEditing];
}

- (void)finalizeCGEditing
{
}

- (void)prepareCocoaEditing
{
    [self prepareCGEditing];
    _layerGraphicsContext = [[NSGraphicsContext graphicsContextWithCGContext:[self imageCGContext] flipped:NO] retain];
    [NSGraphicsContext saveGraphicsState];
    [NSGraphicsContext setCurrentContext:_layerGraphicsContext];
}

- (void)beginCocoaEditing
{
    [self prepareCocoaEditing];
    [_layerGraphicsContext saveGraphicsState];
}

- (void)endCocoaEditing
{
    [_layerGraphicsContext restoreGraphicsState];
    [self finalizeCocoaEditing];
}

- (void)finalizeCocoaEditing
{
    [NSGraphicsContext restoreGraphicsState];
    [_layerGraphicsContext release];
    _layerGraphicsContext = nil;
    [self finalizeCGEditing];
}

@end
