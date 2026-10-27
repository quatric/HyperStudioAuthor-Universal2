#import "HyperStudioPrefix.h"
#import "HSEffectController.h"


@interface HSGradientEffectController : HSEffectController
{
    HSImagePreviewView *_preview;
    NSMatrix *_styleMatrix;
    HSGradientColorWell *_topColorWell;
    HSGradientColorWell *_bottomColorWell;
    HSCrayonsView *_topCrayonsView;
    HSCrayonsView *_bottomCrayonsView;
    NSTextField *_leftTextField;
    NSTextField *_rightTextField;
    HSColor *_color;
    NSImage *_originalImage;
}
+ (id)defaultEndColor;
+ (id)defaultStartColor;
+ (id)createEffect;
- (void)bottomColorDidChange:(id)aChange;
- (void)topColorDidChange:(id)aChange;
- (void)styleDidChange:(id)aChange;
- (void)setGradientKindFromInterface:(id)aInterface;
- (void)applyEffectForHSEditableImageAttributes:(id)aAttributes userInfo:(void *)aInfo;
- (void)applyEffectForHSButtonObjectAttributes:(id)aAttributes userInfo:(void *)aInfo;
- (void)applyEffectForHSImageMutableAttributes:(id)aAttributes userInfo:(void *)aInfo;
- (void)applyEffectForHSImageObjectAttributes:(id)aAttributes userInfo:(void *)aInfo;
- (void)applyEffectForGraphicSelectionToolObject:(id)aObject userInfo:(void *)aInfo;
- (void)applyChanges;
- (void)update;
- (void)didMount;
- (void)didUnmount;
- (void)didLoadNib;
- (void)revertSettingsToDefault;
- (id)undoActionName;
- (id)nibName;
- (id)effect;
- (void)dealloc;
@end

