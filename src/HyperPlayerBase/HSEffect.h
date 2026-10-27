#import "HyperPlayerBasePrefix.h"
#import "HSObjectRegistry.h"


@interface HSEffect : HSObjectRegistry
{
}
+ (id)localizedNameForCategory:(id)aCategory;
+ (id)localizedNameForEffectName:(id)aName;
+ (void)registerEffectName:(id)aName constructor:(id)aConstructor classAttributes:(id)aAttributes;
+ (id)effectNamesInCategories:(id)aCategories;
+ (id)effectNamesInCategory:(id)aCategory;
+ (id)effectNames;
+ (id)effectWithName:(id)aName;
+ (id)sharedRegistrars;
+ (id)sharedRegistryMap;
+ (id)convertAttribute:(id)aAttribute forKey:(id)aKey;
- (id)displayName;
- (void)setAttributes:(id)aAttributes;
- (id)category;
- (id)outputImage;
- (void)setInputImage:(id)aImage;
- (id)name;
- (id)attributes;
- (void)setDefaults;
- (id)outputKeys;
- (id)inputKeys;
@end

