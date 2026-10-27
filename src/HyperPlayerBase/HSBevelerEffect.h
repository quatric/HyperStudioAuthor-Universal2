#import "HyperPlayerBasePrefix.h"
#import "HSPixelEffect.h"


@interface HSBevelerEffect : HSPixelEffect
{
    NSDictionary *_effectDescription;
    CGRect _imageRect;
    CGRect _internalRect;
    float _maxBorderWidth;
    float _minBorderWidth;
    CGPoint _leftClipPath[5];
    CGPoint _rightClipPath[5];
    CGPoint _topClipPath[5];
    CGPoint _bottomClipPath[5];
    void *_workDataStorage;
    unsigned int _workDataStorageSize;
    void *_maskDataStorage;
    unsigned int _maskDataStorageSize;
    struct CGImage *_outputCGImage;
    signed char _intensityTable[256];   // BOOL on i386; signed offsets, bool on arm64 would break them
    float _polyLight[5];
    unsigned int _intensityTableInitialized:1;
    unsigned int _polyLightTableInitialized:1;
    unsigned int _clipPointsInitialized:1;
    unsigned int _shouldUpdateIntensityTable:1;
    unsigned int _shouldUpdatePolyLightTable:1;
    unsigned int _shouldUpdateImagePixels:1;
    unsigned int _shouldUpdateMaskPixels:1;
}
+ (id)effectDescriptionPlistName;
- (void)setType:(id)aType;
- (void)setInvert:(id)aInvert;
- (void)setWidth:(id)aWidth;
- (void)setAttribute:(id)aAttribute forKey:(id)aKey;
- (CGFloat)HSBevelerEffect_adjustMaxBevelSizeWithImageSize:(CGSize)aSize;
- (CGFloat)HSBevelerEffect_adjustBevelWidth:(CGFloat)aWidth;
- (void)HSBevelerEffect_drawCurvedBevelInContext:(struct CGContext *)aContext;
- (void)HSBevelerEffect_drawFlatBevelInContext:(struct CGContext *)aContext;
- (void)HSBevelerEffect_preparePolyLightTableUsingLight:(CGFloat)aLight;
- (void)HSBevelerEffect_prepareIntensityTableForCurve:(CGFloat)aCurve;
- (void)HSBevelerEffect_calculateInternalRectangleAndPathsForWidth:(CGFloat)aWidth;
- (id)outputImage;
- (struct CGImage *)outputCGImage;
- (id)attributes;
- (void)updateInputImageRelatedInfo;
- (id)maxWidth;
- (void)dealloc;
- (id)initWithName:(id)aName;
@end

