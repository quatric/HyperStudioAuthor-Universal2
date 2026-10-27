#import "HyperPlayerBasePrefix.h"
#import "HSPixelEffect.h"


@interface HSTexturizerEffect : HSPixelEffect
{
    NSImage *_textureImage;
    NSDictionary *_effectDescription;
    void *_inputImagePixels;
    unsigned int _inputImagePixelsSize;
    void *_maskImagePixels;
    unsigned int _maskImagePixelsSize;
    CGRect _imageRect;
    unsigned int _maskPixelsWidth;
    unsigned int _maskPixelsHeight;
    unsigned int _maskPixelsBytesPerRow;
    struct CGImage *_outputCGImage;
    signed char _intensityTable[256];  // BOOL in the original (signed char on i386)
    unsigned int _intensityTableInitialized:1;
    unsigned int _shouldUpdateIntensityTable:1;
    unsigned int _shouldUpdateTexturePixels:1;
    unsigned int _shouldUpdateMaskPixels:1;
    unsigned int _shouldUpdateImagePixels:1;
}
+ (id)effectDescriptionPlistName;
- (void)HSTexturizerEffect_prepareMaskImageOffscreenData;
- (void)HSTexturizerEffect_prepareInputImagePixelsForWidth:(NSUInteger)aWidth height:(NSUInteger)aHeight bytesPerRow:(NSUInteger)aRow;
- (void)HSTexturizerEffect_prepareIntensityTable;
- (void)setInvertMask:(id)aMask;
- (void)setScale:(id)aScale;
- (void)setRelief:(id)aRelief;
- (void)setEmboss:(id)aEmboss;
- (void)setTextureImage:(id)aImage;
- (id)outputImage;
- (struct CGImage *)outputCGImage;
- (id)attributes;
- (void)updateInputImageRelatedInfo;
- (void)setAttribute:(id)aAttribute forKey:(id)aKey;
- (void)dealloc;
- (id)initWithName:(id)aName;
@end

