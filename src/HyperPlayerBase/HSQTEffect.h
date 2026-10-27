#import "HyperPlayerBasePrefix.h"
#import "HSEffect.h"


@interface HSQTEffect : HSEffect
{
    NSBitmapImageRep *_screenBitmap;
    char **_effectDesc;
    void *_sampleDesc;   // QuickTime image description; unused now
    NSImage *_inputImage;
    NSDictionary *_effectDescription;
    NSImage *_previewImage;
}
+ (id)effectsDescription;
- (id)selectorStringForKey:(id)aKey;
- (BOOL)getParamAtom:(id)aAtom atomID:(id)aID size:(NSInteger)aSize value:(void *)aValue;
- (BOOL)addParamAtom:(id)aAtom atomID:(id)aID size:(NSInteger)aSize value:(void *)aValue;
- (id)inputContrastWithType:(id)aType atomID:(id)aID;
- (void)setInputContrast:(id)aContrast withType:(id)aType atomID:(id)aID;
- (id)inputTintBrightnessWithType:(id)aType atomID:(id)aID;
- (void)setInputTintBrightness:(id)aBrightness withType:(id)aType atomID:(id)aID;
- (id)inputLightColorWithType:(id)aType atomID:(id)aID;
- (void)setInputLightColor:(id)aColor withType:(id)aType atomID:(id)aID;
- (id)inputDarkColorWithType:(id)aType atomID:(id)aID;
- (void)setInputDarkColor:(id)aColor withType:(id)aType atomID:(id)aID;
- (id)inputTintWithType:(id)aType atomID:(id)aID;
- (void)setInputTint:(id)aTint withType:(id)aType atomID:(id)aID;
- (id)inputPosterizeAmountWithType:(id)aType atomID:(id)aID;
- (void)setInputPosterizeAmount:(id)aAmount withType:(id)aType atomID:(id)aID;
- (id)inputSolarizePointWithType:(id)aType atomID:(id)aID;
- (void)setInputSolarizePoint:(id)aPoint withType:(id)aType atomID:(id)aID;
- (id)inputSolarizeAmountWithType:(id)aType atomID:(id)aID;
- (void)setInputSolarizeAmount:(id)aAmount withType:(id)aType atomID:(id)aID;
- (id)inputMultiplierWithType:(id)aType atomID:(id)aID;
- (void)setInputMultiplier:(id)aMultiplier withType:(id)aType atomID:(id)aID;
- (id)inputBottomAlphaPinWithType:(id)aType atomID:(id)aID;
- (void)setInputBottomAlphaPin:(id)aPin withType:(id)aType atomID:(id)aID;
- (id)inputTopAlphaPinWithType:(id)aType atomID:(id)aID;
- (void)setInputTopAlphaPin:(id)aPin withType:(id)aType atomID:(id)aID;
- (id)inputOffsetValueWithType:(id)aType atomID:(id)aID;
- (void)setInputOffsetValue:(id)aValue withType:(id)aType atomID:(id)aID;
- (id)inputGainValueWithType:(id)aType atomID:(id)aID;
- (void)setInputGainValue:(id)aValue withType:(id)aType atomID:(id)aID;
- (id)inputCellWithType:(id)aType atomID:(id)aID;
- (void)setInputCell:(id)aCell withType:(id)aType atomID:(id)aID;
- (id)inputColorizeWithType:(id)aType atomID:(id)aID;
- (void)setInputColorize:(id)aColorize withType:(id)aType atomID:(id)aID;
- (id)inputBrightnessWithType:(id)aType atomID:(id)aID;
- (void)setInputBrightness:(id)aBrightness withType:(id)aType atomID:(id)aID;
- (id)inputAmountWithType:(id)aType atomID:(id)aID;
- (void)setInputAmount:(id)aAmount withType:(id)aType atomID:(id)aID;
- (id)valueForKey:(id)aKey;
- (void)setValue:(id)aValue forKey:(id)aKey;
- (void)takeValue:(id)aValue forKey:(id)aKey;
- (id)effectImageForContextImage:(struct CGContext *)aImage;
- (id)category;
- (id)outputImage;
- (void)setInputImage:(id)aImage;
- (void)setDefaults;
- (id)attributes;
- (id)inputKeys;
- (id)name;
- (void)dealloc;
- (id)initWithName:(id)aName;
@end

