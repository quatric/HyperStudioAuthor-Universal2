#import "HyperPlayerBasePrefix.h"


@interface HSObjectRegistryItem : NSObject
{
    id _constructor;
    NSDictionary *_attributes;
}
+ (id)itemWithConstructor:(id)aConstructor attributes:(id)aAttributes;
- (BOOL)bellowsOneOfCategories:(id)aCategories;
- (void)setAttributes:(id)aAttributes;
- (id)attributes;
- (void)setConstructor:(id)aConstructor;
- (id)constructor;
- (void)dealloc;
@end

