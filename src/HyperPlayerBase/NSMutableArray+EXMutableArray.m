#import "NSMutableArray+EXMutableArray.h"
// Range-safe array helpers and plist conversion of arrays of extra-coded
// objects.
@implementation NSMutableArray (EXMutableArray)
- (void)extraRemoveObjectAtIndex:(NSUInteger)aIndex
{
    if (aIndex < [self count])
        [self removeObjectAtIndex:aIndex];
}
- (void)extraInsertObjectsFromArray:(id)aArray atIndex:(NSInteger)aIndex
{
    for (id object in aArray)
        [self insertObject:object atIndex:aIndex++];
}
@end

// Sorts by the objects' indexes in a reference array when it has them (the
// ones it has first), else by their indexes in the array being sorted.
typedef struct {
    NSArray *array;
    NSArray *reference;
} EXReorderContext;

static NSInteger EXCompareByReferenceOrder(id aObject, id aObject2, void *aContext)
{
    EXReorderContext *context = [(NSMutableData *)aContext mutableBytes];
    if (context->reference != nil) {
        NSUInteger index = [context->reference indexOfObject:aObject];
        NSUInteger index2 = [context->reference indexOfObject:aObject2];
        if (index != NSNotFound) {
            if (index2 == NSNotFound)
                return NSOrderedAscending;
            return index2 <= index ? NSOrderedDescending : NSOrderedAscending;
        }
        if (index2 != NSNotFound)
            return NSOrderedDescending;
    }
    NSUInteger index = [context->array indexOfObject:aObject];
    NSUInteger index2 = [context->array indexOfObject:aObject2];
    return index < index2 ? NSOrderedAscending : NSOrderedDescending;
}

@implementation NSArray (EXArray)
// The extra dictionaries of the objects that have one.
- (id)extraPlistRepresentation
{
    NSMutableArray *plist = [NSMutableArray arrayWithCapacity:[self count]];
    for (id object in self) {
        if ([object conformsToProtocol:@protocol(EXKeyValueCoding)]) {
            id dictionary = [object extraDictionaryRepresentation];
            if (dictionary != nil)
                [plist addObject:dictionary];
        }
    }
    return plist;
}
- (id)extraArrayFromPlistRepresentation
{
    NSMutableArray *objects = [NSMutableArray arrayWithCapacity:[self count]];
    for (id dictionary in self)
        [objects addObject:[NSObject objectWithExtraDictionary:dictionary]];
    return objects;
}
- (BOOL)isExtraIdenticalToArray:(id)aArray
{
    if ([self count] != [aArray count])
        return NO;
    NSUInteger count = [aArray count];
    for (NSUInteger i = 0; i < count; i++) {
        if ([self objectAtIndex:i] != [aArray objectAtIndex:i])
            return NO;
    }
    return YES;
}
// In the other array's order, for the objects it has.
- (id)extraReorderedArrayAgainstArray:(id)aArray
{
    if (self == aArray || [aArray count] == 0)
        return self;
    EXReorderContext context = {self, aArray};
    NSMutableData *data = [NSMutableData dataWithBytes:&context length:sizeof(context)];
    return [self sortedArrayUsingFunction:EXCompareByReferenceOrder context:data];
}
// The same objects, maybe in another order.
- (BOOL)isExtraReorderedArray:(id)aArray
{
    if ([self count] != [aArray count])
        return NO;
    NSUInteger count = [aArray count];
    for (NSUInteger i = 0; i < count; i++) {
        if (![self extraContainsObjectIdenticalTo:[aArray objectAtIndex:i]])
            return NO;
    }
    return YES;
}
- (id)extraSortedArray
{
    return [self sortedArrayUsingSelector:@selector(compare:)];
}
- (id)extraObjectAtIndex:(NSUInteger)aIndex
{
    return aIndex < [self count] ? [self objectAtIndex:aIndex] : nil;
}
- (id)extraFirstObject
{
    return [self extraObjectAtIndex:0];
}
- (BOOL)extraContainsObjectIdenticalTo:(id)aTo
{
    return [self indexOfObjectIdenticalTo:aTo] != NSNotFound;
}
@end
