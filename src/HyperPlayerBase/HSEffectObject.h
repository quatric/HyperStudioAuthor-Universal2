#import "HyperPlayerBasePrefix.h"
#import "HSConcreteCardObject.h"


@interface HSEffectObject : HSConcreteCardObject <HSEffectMutableAttributes, HSEffectAttributes, HSAttributes, HyperInterface, NSObject, HSEffectNameAttribute, HSEffectAttribute, HSAttribute, HSEffectSourceAreaAttribute, HSEffectVisualAttribute, HSVisualAttribute, HSUndoableAttribute, HSCoreImageEffectAccessing, HSQuickTimeEffectAccessing, HSGeometryBehaviorSubattributes>
{
    HSEffect *_effect;
}
+ (Class)nodeDataClass;
+ (id)defaultUnitClassNames;
- (id)queryEffectObjectHitTester;
- (void)adjustEffectCenters:(BOOL)aCenters;
- (void)setEffectName:(id)aName;
- (id)effectName;
- (void)createEffect;
- (void)HSEffectObject_sizeDidChange:(id)aChange;
- (id)queryNewHyperInterface:(id)aInterface;
- (id)quickTimeEffectAdjustedToSize:(NSSize)aSize;
- (id)coreImageEffectAdjustedToSize:(NSSize)aSize;
- (id)effectPerObjectAdjustedToSize:(NSSize)aSize;
- (id)quickTimeEffect;
- (id)coreImageEffect;
- (struct CGPath *)effectSourceAreaBoundingPath;
- (NSRect)HSEffectObject_boundingRect;
- (void)setHyperEffectName:(id)aName settings:(id)aSettings;
- (id)effectSettings;
- (void)setHyperValue:(id)aValue forKey:(id)aKey;
- (id)hyperValueForKey:(id)aKey;
- (id)hyperAttributes;
- (id)hyperInputKeys;
- (void)setHyperEffectName:(id)aName;
- (id)nameBaseTemplates;
- (id)hyperEffectName;
- (BOOL)canMoveVertically;
- (BOOL)canMoveHorizontally;
- (BOOL)canRotate;
- (BOOL)canSkew;
- (BOOL)canFlipVertically;
- (BOOL)canFlipHorizontally;
- (BOOL)canScaleVertically;
- (BOOL)canScaleHorizontally;
- (BOOL)canBreakSizeScaleAspectRatio;
- (BOOL)prefersResizingToScaling;
- (BOOL)canBeDraggable;
- (BOOL)canBeResizable;
- (BOOL)canBeRotatable;
- (id)effectForRender;
- (id)queryInteractivePlayerItem;
- (BOOL)canSendActionsOnDrop;
- (BOOL)canBeGrouped;
- (void)setAttributes:(id)aAttributes;
- (id)attributes;
- (id)keysForExtraLoadingWithCodingContext:(id)aContext;
- (void)loadExtraDictionaryRepresentation:(id)aRepresentation withCodingContext:(id)aContext;
- (void)dealloc;
- (id)init;
@end

