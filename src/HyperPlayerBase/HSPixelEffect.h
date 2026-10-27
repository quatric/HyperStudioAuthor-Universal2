#import "HyperPlayerBasePrefix.h"
#import "HSEffect.h"


@interface HSPixelEffect : HSEffect
{
    NSImage *_inputImage;
    NSImage *_outputImage;
    NSMutableDictionary *_effectAttributes;
    NSImage *_previewImage;
}
+ (id)effectDescriptionPlistName;
+ (id)effectsDescription;
- (void)updateInputImageRelatedInfo;
- (void)copyCocoaImage:(id)aImage toCGBitmapContext:(struct CGContext *)aContext;
- (id)loadImageWithName:(id)aName extension:(id)aExtension;
- (void)setAttribute:(id)aAttribute forKey:(id)aKey;
- (id)effectAttributes;
- (id)valueForKey:(id)aKey;
- (void)setValue:(id)aValue forKey:(id)aKey;
- (id)outputKeys;
- (id)inputKeys;
- (void)setInputImage:(id)aImage;
- (void)setDefaults;
- (id)displayName;
- (id)name;
- (struct CGImage *)outputCGImage;
- (void)dealloc;
@end

