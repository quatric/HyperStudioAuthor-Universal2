#import "HyperStudioPrefix.h"


@interface HSEffectController : NSObject
{
    id _object;
    id<HSGeometryAttributes> _geometryAttributes;
    NSView *_contentView;
    HSEffect *_effect;
    HSHyperObjectEffectApplier *_effectApplier;
}
+ (id)createEffect;
- (id)objectGeometryAttributes;
- (void)applyChanges;
- (id)undoActionName;
- (void)update;
- (void)didUnmount;
- (void)willUnmount;
- (void)didMount;
- (void)willMount;
- (id)effectApplier;
- (id)effect;
- (id)object;
- (void)didLoadNib;
- (id)contentView;
- (void)revertSettingsToDefault;
- (id)nibName;
- (void)loadNibIfNeeded;
- (void)setObject:(id)aObject;
- (id)initWithObject:(id)aObject;
- (id)init;
- (void)dealloc;
@end

