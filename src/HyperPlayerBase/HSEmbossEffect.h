#import "HyperPlayerBasePrefix.h"
#import "HSPixelEffect.h"


@interface HSEmbossEffect : HSPixelEffect
{
    NSDictionary *_effectDescription;
    CGRect _imageRect;
    float _minReliefValue;
    float _maxReliefValue;
    struct CGImage *_outputCGImage;
    void *_inputImagePixels;
    unsigned int _inputImagePixelsSize;
    short _intensityTable[256];
    unsigned int _intensityTableInitialized:1;
    unsigned int _shouldUpdateImagePixels:1;
}
+ (id)effectDescriptionPlistName;
- (void)setRelief:(id)aRelief;
- (void)HSEmbossEffect_prepareIntensityTableForRelief:(CGFloat)aRelief;
- (id)outputImage;
- (struct CGImage *)outputCGImage;
- (id)attributes;
- (void)setAttribute:(id)aAttribute forKey:(id)aKey;
- (void)updateInputImageRelatedInfo;
- (void)dealloc;
- (id)initWithName:(id)aName;
@end

