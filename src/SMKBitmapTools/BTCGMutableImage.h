#import "SMKBitmapToolsPrefix.h"


@interface BTCGMutableImage : NSObject <BTCGImage, BTImage, NSObject, BTCocoaImage, BTCGMutableImage, BTMutableImage, BTCocoaMutableImage>
{
    struct CGImage *_image;
    struct CGContext *_imageContext;
    NSGraphicsContext *_layerGraphicsContext;
    unsigned int _isImageValid:1;
    unsigned int _isEditing:1;
}
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
- (void)dealloc;
- (id)initWithCGImage:(struct CGImage *)aImage context:(struct CGContext *)aContext;
- (id)init;
@end

