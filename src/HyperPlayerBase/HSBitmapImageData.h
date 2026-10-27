#import "HyperPlayerBasePrefix.h"


@interface HSBitmapImageData : NSObject <NSCopying, NSMutableCopying>
{
    NSData *_data;
    NSMutableData *_mutableData;
    unsigned int _width;
    unsigned int _height;
    unsigned int _bitsPerSample;
    unsigned int _samplesPerPixel;
    int _bitmapFormat;
    unsigned int _bytesPerRow;
    unsigned int _bitsPerPixel;
    unsigned int _colorSpaceSignature;
    struct HyperPlayerBase_anon15 _bitmapImageDataFlags;
}
- (BOOL)isFlippedVertically;
- (BOOL)isFlippedHorizontally;
- (NSUInteger)bitsPerPixel;
- (NSUInteger)bytesPerRow;
- (NSInteger)bitmapInfo;
- (NSInteger)bitmapFormat;
- (NSUInteger)colorSpaceSignature;
- (BOOL)hasAlpha;
- (NSUInteger)samplesPerPixel;
- (NSUInteger)bitsPerSample;
- (NSUInteger)height;
- (NSUInteger)width;
- (id)mutableData;
- (id)data;
- (id)mutableCopyWithZone:(NSZone *)aZone;
- (id)copyWithZone:(NSZone *)aZone;
- (void)dealloc;
- (id)initWithMutableData:(id)aData pixelsWide:(NSUInteger)aWide pixelsHigh:(NSUInteger)aHigh bitsPerSample:(NSUInteger)aSample samplesPerPixel:(NSUInteger)aPixel hasAlpha:(BOOL)aAlpha colorSpaceSignature:(NSUInteger)aSignature bitmapFormat:(NSInteger)aFormat bytesPerRow:(NSUInteger)aRow bitsPerPixel:(NSUInteger)aPixel2 isFlippedHorizontally:(BOOL)aHorizontally isFlippedVertically:(BOOL)aVertically;
- (id)initWithData:(id)aData pixelsWide:(NSUInteger)aWide pixelsHigh:(NSUInteger)aHigh bitsPerSample:(NSUInteger)aSample samplesPerPixel:(NSUInteger)aPixel hasAlpha:(BOOL)aAlpha colorSpaceSignature:(NSUInteger)aSignature bitmapFormat:(NSInteger)aFormat bytesPerRow:(NSUInteger)aRow bitsPerPixel:(NSUInteger)aPixel2 isFlippedHorizontally:(BOOL)aHorizontally isFlippedVertically:(BOOL)aVertically;
@end

