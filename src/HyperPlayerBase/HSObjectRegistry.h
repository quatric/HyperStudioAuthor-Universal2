#import "HyperPlayerBasePrefix.h"


@interface HSObjectRegistry : NSObject
{
}
+ (void)callRegistrations;
+ (void)registerObjectName:(id)aName constructor:(id)aConstructor classAttributes:(id)aAttributes;
+ (void)registerRegistrar:(id)aRegistrar;
+ (id)objectNamesInCategories:(id)aCategories;
+ (id)objectNamesInCategory:(id)aCategory;
+ (id)objectNames;
+ (id)objectWithName:(id)aName;
+ (id)sharedRegistryMap;
+ (id)sharedRegistrars;
@end

