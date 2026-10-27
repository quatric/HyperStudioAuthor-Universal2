#import "NSIndexSet+HSExtensions.h"
@implementation NSIndexSet (HSExtensions)
+ (id)indexSetWithHyperArray:(id)aArray
{
    return [[[[self class] alloc] initWithHyperArray:aArray] autorelease];
}
- (id)initWithHyperArray:(id)aArray
{
    NSMutableIndexSet *indexes = [NSMutableIndexSet new];
    NSEnumerator *enumerator = [aArray objectEnumerator];
    NSNumber *number;
    while ((number = [enumerator nextObject]) != nil)
        [indexes addIndex:[number unsignedIntValue]];
    self = [self initWithIndexSet:indexes];
    [indexes release];
    return self;
}
@end
