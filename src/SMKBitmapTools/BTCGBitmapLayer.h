#import "SMKBitmapToolsPrefix.h"


@interface BTCGBitmapLayer : NSObject <BTCGImage, BTImage, NSObject, BTCocoaImage, BTCGMutableImage, BTMutableImage, BTCocoaMutableImage, BTRawImage, BTRawMutableImage>
{
    struct CGContext *_bitmapContext;
    struct CGImage *_image;
    NSData *_imageDecode;
    int _imageFormat;
    struct OpaqueCMProfileRef *_imageColorProfile;
    NSGraphicsContext *_layerGraphicsContext;
    unsigned int _isEditing:1;
}
+ (id)bitmapLayerWithCGContext:(struct CGContext *)aContext decode:(const CGFloat *)aDecode format:(NSInteger)aFormat colorProfile:(struct OpaqueCMProfileRef *)aProfile;
- (void)endRawEditing;
- (void *)mutableImageBytes;
- (void)beginRawEditing;
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
- (const CGFloat *)imageDecode;
- (struct OpaqueCMProfileRef *)imageColorProfile;
- (NSInteger)imageFormat;
- (NSUInteger)imageBytesPerRow;
- (const void *)imageBytes;
- (struct CGColor *)colorAtPoint:(CGPoint)aPoint;
- (struct CGImage *)coreGraphicsImage;
- (struct CGColorSpace *)coreGraphicsColorSpace;
- (struct CGPDFDocument *)coreGraphicsPDFDocument;
- (CGSize)imageSize;
- (struct CGContext *)CGContext;
- (void)dealloc;
- (id)initWithCGContext:(struct CGContext *)aContext decode:(const CGFloat *)aDecode format:(NSInteger)aFormat colorProfile:(struct OpaqueCMProfileRef *)aProfile;
- (id)init;
@end

