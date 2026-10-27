#import "HyperPlayerBasePrefix.h"
#import "HSEffect.h"


@interface HSCIEffect : HSEffect
{
    CIFilter *_filter;
    CIImage *_inputImage;
    struct CGImage *_inputImageMask;
    CIFilter *_cropFilter;
    CIFilter *_affineClampFilter;
    NSImage *_previewImage;
    NSImageRep *_outputImageRep;
    unsigned int _outputRepIsNSBitmapImageRep:1;
    unsigned int _imageNormalization:1;
}
+ (id)convertAttribute:(id)aAttribute forKey:(id)aKey;
+ (id)effectsDescription;
- (id)compositeOutputCIImage:(id)aImage;
- (id)cropImage:(id)aImage toRect:(CGRect)aRect;
- (id)effectImageForContextImage:(id)aImage;
- (void)setImageNormalization:(BOOL)aNormalization;
- (BOOL)imageNormalization;
- (id)category;
- (struct CGImage *)outputCGImage;
- (id)outputImage;
- (void)setInputImage:(id)aImage;
- (id)name;
- (void)setDefaults;
- (id)valueForKey:(id)aKey;
- (void)setValue:(id)aValue forKey:(id)aKey;
- (id)attributes;
- (id)outputKeys;
- (id)inputKeys;
- (id)HSCIEffect_outputImageRep;
- (id)HSCIEffect_processImage:(id)aImage;
- (id)HSCIEffect_affineClampFilterForImage:(id)aImage;
- (id)HSCIEffect_cropFilterForImage:(id)aImage inputRect:(CGRect)aRect;
- (void)dealloc;
- (id)initWithName:(id)aName;
@end

