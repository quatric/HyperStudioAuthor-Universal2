#import "SMKBitmapToolsPrefix.h"


@interface BTNSImage : NSObject <BTCocoaImage, BTImage, NSObject, BTCocoaMutableImage, BTMutableImage, BTCGImage, BTCGMutableImage>
{
    NSImage *_image;
    NSGraphicsContext *_imageContext;
}
- (void)endCGEditing;
- (struct CGContext *)imageCGContext;
- (void)beginCGEditing;
- (void)endCocoaEditing;
- (void)beginCocoaEditing;
- (id)createImageUndoerWithDelegate:(id)aDelegate;
- (struct CGColor *)colorAtPoint:(CGPoint)aPoint;
- (struct CGImage *)coreGraphicsImage;
- (struct CGColorSpace *)coreGraphicsColorSpace;
- (struct CGPDFDocument *)coreGraphicsPDFDocument;
- (void)drawInCGContext:(struct CGContext *)aContext atPoint:(CGPoint)aPoint;
- (void)drawInCGContext:(struct CGContext *)aContext inRect:(CGRect)aRect;
- (void)drawInCurrentNSGraphicsContextAtPoint:(NSPoint)aPoint;
- (void)drawInCurrentNSGraphicsContextInRect:(NSRect)aRect;
- (CGSize)imageSize;
- (void)dealloc;
- (id)initWithNSImage:(id)aImage;
- (id)init;
@end

