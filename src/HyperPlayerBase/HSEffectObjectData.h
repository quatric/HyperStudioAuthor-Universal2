#import "HyperPlayerBasePrefix.h"
#import "HSConcreteCardObjectData.h"


@interface HSEffectObjectData : HSConcreteCardObjectData
{
    NSString *_effectName;
    NSMutableDictionary *_attributes;
    HSEffect *_effect;
}
+ (id)nodeDataKeysToNodeKeysMap;
- (id)keysForExtraStoringWithCodingContext:(id)aContext;
- (void)setEffect:(id)aEffect;
- (id)effect;
- (void)setAttributes:(id)aAttributes;
- (id)attributes;
- (void)setEffectName:(id)aName;
- (id)effectName;
- (void)dealloc;
- (id)init;
@end

