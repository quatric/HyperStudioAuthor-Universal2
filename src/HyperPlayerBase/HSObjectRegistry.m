#import "HSObjectRegistry.h"
// Objects made by name (registered by registrars, with category
// attributes). Subclasses provide the shared map and registrars.
@implementation HSObjectRegistry
+ (void)callRegistrations
{
    for (id registrar in [self sharedRegistrars])
        [registrar registerObjects];
}
+ (void)registerObjectName:(id)aName constructor:(id)aConstructor classAttributes:(id)aAttributes
{
    [[self sharedRegistryMap] setObject:[HSObjectRegistryItem itemWithConstructor:aConstructor attributes:aAttributes] forKey:aName];
}
+ (void)registerRegistrar:(id)aRegistrar
{
    [[self sharedRegistrars] addObject:aRegistrar];
}
// All names for nil.
+ (id)objectNamesInCategories:(id)aCategories
{
    [self callRegistrations];
    NSDictionary *map = [self sharedRegistryMap];
    if (aCategories == nil)
        return [map allKeys];
    NSMutableArray *names = [NSMutableArray array];
    for (id name in map)
        if ([[map objectForKey:name] bellowsOneOfCategories:aCategories])
            [names addObject:name];
    return names;
}
+ (id)objectNamesInCategory:(id)aCategory
{
    return [self objectNamesInCategories:aCategory != nil ? [NSArray arrayWithObject:aCategory] : nil];
}
+ (id)objectNames
{
    return [self objectNamesInCategory:nil];
}
+ (id)objectWithName:(id)aName
{
    [self callRegistrations];
    return [[[[self sharedRegistryMap] objectForKey:aName] constructor] objectWithName:aName];
}
+ (id)sharedRegistryMap
{
    return nil;
}
+ (id)sharedRegistrars
{
    return nil;
}
@end
