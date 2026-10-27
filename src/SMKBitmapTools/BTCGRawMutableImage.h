#import "SMKBitmapToolsPrefix.h"
#import "BTCGMutableImage.h"


@interface BTCGRawMutableImage : BTCGMutableImage <BTRawImage, BTImage, NSObject, BTRawMutableImage, BTMutableImage>
{
    void *_mutableImageBytes;
    int _imageFormat;
    struct OpaqueCMProfileRef *_imageColorProfile;
}
- (struct CGColor *)colorAtPoint:(CGPoint)aPoint;
- (void)endRawEditing;
- (void *)mutableImageBytes;
- (void)beginRawEditing;
- (id)createImageUndoerWithDelegate:(id)aDelegate;
- (const CGFloat *)imageDecode;
- (struct OpaqueCMProfileRef *)imageColorProfile;
- (NSInteger)imageFormat;
- (NSUInteger)imageBytesPerRow;
- (const void *)imageBytes;
- (void)dealloc;
- (id)initWithCGImage:(struct CGImage *)aImage context:(struct CGContext *)aContext mutableBytes:(void *)aBytes format:(NSInteger)aFormat colorProfile:(struct OpaqueCMProfileRef *)aProfile;
- (id)initWithCGImage:(struct CGImage *)aImage context:(struct CGContext *)aContext;
@end

