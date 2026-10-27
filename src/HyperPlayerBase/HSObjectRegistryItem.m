#import "HSObjectRegistryItem.h"
@implementation HSObjectRegistryItem
+ (id)itemWithConstructor:(id)aConstructor attributes:(id)aAttributes
{
    HSObjectRegistryItem *item = [[HSObjectRegistryItem new] autorelease];
    [item setConstructor:aConstructor];
    [item setAttributes:aAttributes];
    return item;
}
// YES when one of the item's categories is among them (NO for none).
- (BOOL)bellowsOneOfCategories:(id)aCategories
{
    if ([aCategories count] == 0)
        return NO;
    for (id category in [[self attributes] objectForKey:@"HSObjectCategoriesKey"]) {
        if ([aCategories containsObject:category])
            return YES;
    }
    return NO;
}
- (void)setAttributes:(id)aAttributes
{
    if (_attributes != aAttributes) {
        [_attributes release];
        _attributes = [aAttributes retain];
    }
}
- (id)attributes
{
    return _attributes;
}
- (void)setConstructor:(id)aConstructor
{
    if (_constructor != aConstructor) {
        [_constructor release];
        _constructor = [aConstructor retain];
    }
}
- (id)constructor
{
    return _constructor;
}
- (void)dealloc
{
    [_constructor release];
    [_attributes release];
    [super dealloc];
}
@end
