#import "HyperPlayerBasePrefix.h"
#import "HSUserObjectData.h"


@interface HSConcreteCardObjectData : HSUserObjectData
{
    BOOL _resizable;
    BOOL _rotatable;
    BOOL _draggable;
    BOOL _hidden;
    BOOL _isHiddenInPlayer;
    BOOL _isVisibleInEditor;
    BOOL _locked;
    BOOL _hyperIgnoredInLayoutGuiding;
    BOOL _dropOffOnly;
    BOOL _noClick;
    BOOL _groupObjectFlag;
    float _opacity;
    HSEffect *_effectPerObject;
    NSDictionary *_effectPerObjectSettings;
}
+ (id)nodeDataKeysToNodeKeysMap;
- (id)keysForExtraStoringWithCodingContext:(id)aContext;
- (void)applyEffectSettings;
- (void)setEffectSettings:(id)aSettings;
- (id)effectSettings;
- (void)setEffectName:(id)aName settings:(id)aSettings;
- (void)setEffectName:(id)aName;
- (id)effectName;
- (id)effectPerObject;
- (void)setOpacity:(CGFloat)aOpacity;
- (CGFloat)opacity;
- (void)setHidden:(BOOL)aHidden;
- (BOOL)isHidden;
- (BOOL)isVisibleInEditor;
- (void)setIsVisibleInEditor:(BOOL)aEditor;
- (BOOL)isHiddenInPlayer;
- (void)setHiddenInPlayer:(BOOL)aPlayer;
- (void)setGroupObjectFlag:(BOOL)aFlag;
- (BOOL)groupObjectFlag;
- (void)setNoClick:(BOOL)aClick;
- (BOOL)isNoClick;
- (void)setDropOffOnly:(BOOL)aOnly;
- (BOOL)isDropOffOnly;
- (void)setHyperIgnoredInLayoutGuiding:(BOOL)aGuiding;
- (BOOL)isHyperIgnoredInLayoutGuiding;
- (void)setLocked:(BOOL)aLocked;
- (BOOL)isLocked;
- (void)setDraggable:(BOOL)aDraggable;
- (BOOL)isDraggable;
- (void)setRotatableInPlayer:(BOOL)aPlayer;
- (BOOL)isRotatableInPlayer;
- (void)setResizable:(BOOL)aResizable;
- (BOOL)isResizable;
- (void)dealloc;
- (id)init;
@end

