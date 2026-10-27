#import "HyperPlayerBasePrefix.h"
#import "HSPixelEffect.h"


@interface HSReplaceColorsEffect : HSPixelEffect
{
    NSDictionary *_effectDescription;
    CGRect _imageRect;
    struct CGImage *_outputCGImage;
    void *_inputImagePixels;
    unsigned int _inputImagePixelsSize;
    NSColor *_sourceColor;
    NSColor *_targetColor;
    double _minTolerance;
    double _maxTolerance;
    unsigned int _shouldUpdateImagePixels:1;
}
+ (id)effectDescriptionPlistName;
- (id)outputImage;
- (struct CGImage *)outputCGImage;
- (id)attributes;
- (void)updateInputImageRelatedInfo;
- (void)setAttribute:(id)aAttribute forKey:(id)aKey;
- (void)setTolerance:(double)aTolerance;
- (void)setToleranceValue:(id)aValue;
- (void)setTargetColor:(id)aColor;
- (void)setSourceColor:(id)aColor;
- (void)dealloc;
- (id)initWithName:(id)aName;
@end

