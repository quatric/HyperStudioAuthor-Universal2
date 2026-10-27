#import "SMKBitmapToolsPrefix.h"


@interface BTCGImageSaver : NSObject <BTCGImageSaverInterface>
{
}
+ (void)connectWithPorts:(id)aPorts;
- (void)removeFileAtPath:(id)aPath;
- (void)storeImage:(NSUInteger)aImage;
@end

@interface BTCGImage : NSObject <BTCGImage, BTImage, NSObject, BTCocoaImage, BTPurgableObject>
{
    struct CGImage *_image;
    NSData *_bitmapData;
    unsigned int _width;
    unsigned int _height;
    unsigned int _bitsPerComponent;
    unsigned int _bitsPerPixel;
    unsigned int _bytesPerRow;
    CGFloat *_decode;
    int _intent;
    unsigned int _bitmapInfo;
    struct CGColorSpace *_colorSpace;
    NSString *_fileName;
    NSRecursiveLock *_imageLock;
    NSRecursiveLock *_fileNameLock;
    unsigned int _shouldInterpolate:1;
    unsigned int _isPurgePending:1;
}
+ (id)BTCGImage_uniqueFileNameInTempFolder;
- (void)BTCGImage_writeDataToFileInSeparateThread;
- (void)purge;
- (void)BTCGImage_purgeIfNeeded;
- (void)prepareToPurge;
- (void)drawInCurrentNSGraphicsContextAtPoint:(NSPoint)aPoint;
- (void)drawInCurrentNSGraphicsContextInRect:(NSRect)aRect;
- (void)drawInCGContext:(struct CGContext *)aContext atPoint:(CGPoint)aPoint;
- (void)drawInCGContext:(struct CGContext *)aContext inRect:(CGRect)aRect;
- (struct CGColor *)colorAtPoint:(CGPoint)aPoint;
- (struct CGImage *)coreGraphicsImage;
- (struct CGColorSpace *)coreGraphicsColorSpace;
- (struct CGPDFDocument *)coreGraphicsPDFDocument;
- (CGSize)imageSize;
- (struct CGImage *)image;
- (void)dealloc;
- (id)initWithBitmapData:(id)aData width:(NSUInteger)aWidth height:(NSUInteger)aHeight bitsPerComponent:(NSUInteger)aComponent bitsPerPixel:(NSUInteger)aPixel bytesPerRow:(NSUInteger)aRow colorSpace:(struct CGColorSpace *)aSpace bitmapInfo:(NSUInteger)aInfo decode:(const CGFloat *)aDecode shouldInterpolate:(BOOL)aInterpolate intent:(NSInteger)aIntent;
- (id)initWithCGImage:(struct CGImage *)aImage;
- (id)init;
@end

