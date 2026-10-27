#import "HyperStudioPrefix.h"
#import "HSEffectCompositeController.h"


@interface HSTexturizerEffectController : HSEffectCompositeController
{
    NSPopUpButton *_texturePopUpButton;
    NSSlider *_reliefSlider;
    NSSlider *_scaleSlider;
    SMKAngleSlider *_lightAngleSlider;
    NSButton *_styleSwitch;
    NSPopUpButton *_lightDirectionPopUpButton;
    NSMenu *_textureNamesMenu;
    NSArray *_textureNamesMap;
}
+ (id)createEffect;
- (void)lightDirectionDidChange:(id)aChange;
- (void)styleDidChange:(id)aChange;
- (void)lightAngleDidChange:(id)aChange;
- (void)scaleDidChange:(id)aChange;
- (void)reliefDidChange:(id)aChange;
- (void)textureDidChange:(id)aChange;
- (void)didLoadNib;
- (void)revertSettingsToDefault;
- (NSUInteger)lightDirection;
- (void)setLightDirection:(NSUInteger)aDirection;
- (BOOL)isInverted;
- (void)setInverted:(BOOL)aInverted;
- (CGFloat)scale;
- (void)setScale:(CGFloat)aScale;
- (CGFloat)reliefValue;
- (void)setReliefValue:(CGFloat)aValue;
- (id)texture;
- (void)setTexture:(id)aTexture;
- (id)loadTextureAtPath:(id)aPath;
- (id)undoActionName;
- (id)nibName;
- (void)dealloc;
@end

