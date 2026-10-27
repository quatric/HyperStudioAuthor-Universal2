#import "HSEffect.h"

@implementation HSEffect
+ (id)localizedNameForCategory:(id)aCategory
{
    return nil;
}
+ (id)localizedNameForEffectName:(id)aName
{
    id name = [[HSEffect effectWithName:aName] displayName];
    return name ? name : aName;
}
+ (void)registerEffectName:(id)aName constructor:(id)aConstructor classAttributes:(id)aAttributes
{
    [self registerObjectName:aName constructor:aConstructor classAttributes:aAttributes];
}
+ (id)effectNamesInCategories:(id)aCategories
{
    return [self objectNamesInCategories:aCategories];
}
+ (id)effectNamesInCategory:(id)aCategory
{
    return [self objectNamesInCategory:aCategory];
}
+ (id)effectNames
{
    return [self objectNames];
}
+ (id)effectWithName:(id)aName
{
    return [self objectWithName:aName];
}
// Registrars are not retained.
+ (id)sharedRegistrars
{
    static NSMutableSet *sRegistrars = nil;
    if (!sRegistrars)
        sRegistrars = (NSMutableSet *)CFSetCreateMutable(kCFAllocatorDefault, 0, &kCFEWeakObjectPointerSetCallBacks);
    return sRegistrars;
}
+ (id)sharedRegistryMap
{
    static NSMutableDictionary *sMap = nil;
    if (!sMap)
        sMap = [NSMutableDictionary new];
    return sMap;
}
+ (id)convertAttribute:(id)aAttribute forKey:(id)aKey
{
    return aAttribute;
}
- (id)displayName
{
    return [[NSBundle bundleForClass:[self class]] localizedStringForKey:[self name] value:@"" table:@"Effects"];
}
- (void)setAttributes:(id)aAttributes
{
    NSEnumerator *enumerator = [aAttributes keyEnumerator];
    id key;
    while ((key = [enumerator nextObject]))
        [self setValue:[[self class] convertAttribute:[aAttributes valueForKey:key] forKey:key] forKey:key];
}
- (id)category
{
    return nil;
}
- (id)outputImage
{
    return nil;
}
- (void)setInputImage:(id)aImage
{
}
- (id)name
{
    return nil;
}
- (id)attributes
{
    return nil;
}
- (void)setDefaults
{
}
- (id)outputKeys
{
    return nil;
}
- (id)inputKeys
{
    return nil;
}
@end
