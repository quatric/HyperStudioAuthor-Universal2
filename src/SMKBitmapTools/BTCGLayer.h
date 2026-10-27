#import "SMKBitmapToolsPrefix.h"


@interface BTCGLayer : NSObject <BTCGImage, BTImage, NSObject, BTCocoaImage, BTCGMutableImage, BTMutableImage, BTCocoaMutableImage>
{
    struct CGLayer *_layer;
    NSGraphicsContext *_layerGraphicsContext;
}
+ (id)layerWithCGLayer:(struct CGLayer *)aLayer;
- (void)finalizeCocoaEditing;
- (void)endCocoaEditing;
- (void)beginCocoaEditing;
- (void)prepareCocoaEditing;
- (void)finalizeCGEditing;
- (void)endCGEditing;
- (struct CGContext *)imageCGContext;
- (void)beginCGEditing;
- (void)prepareCGEditing;
- (id)createImageUndoerWithDelegate:(id)aDelegate;
- (void)drawInCurrentNSGraphicsContextAtPoint:(NSPoint)aPoint;
- (void)drawInCurrentNSGraphicsContextInRect:(NSRect)aRect;
- (void)drawInCGContext:(struct CGContext *)aContext atPoint:(CGPoint)aPoint;
- (void)drawInCGContext:(struct CGContext *)aContext inRect:(CGRect)aRect;
- (struct CGColor *)colorAtPoint:(CGPoint)aPoint;
- (struct CGImage *)coreGraphicsImage;
- (struct CGColorSpace *)coreGraphicsColorSpace;
- (struct CGPDFDocument *)coreGraphicsPDFDocument;
- (CGSize)imageSize;
- (struct CGLayer *)CGLayer;
- (void)dealloc;
- (id)initWithCGLayer:(struct CGLayer *)aLayer;
- (id)init;
@end

