#import "NSSet+NSEDeepMutableCopying.h"

@implementation NSSet (NSEDeepMutableCopying)

// A mutable set of copies of the elements down to aDepth (see
// -[NSArray NSE_mutableCopyToDepth:zone:]); nil if one can't be copied.
// (Tiger used CFSetApplyFunction instead of fast enumeration.)
- (id)NSE_mutableCopyToDepth:(NSUInteger)aDepth zone:(NSZone *)aZone
{
    NSUInteger count = [self count];
    if (aDepth == 0 || count == 0)
        return [self mutableCopyWithZone:aZone];
    NSMutableSet *copy = [[NSMutableSet allocWithZone:aZone] initWithCapacity:count];
    if (!copy)
        return nil;
    for (id object in self) {
        id element;
        if ([object conformsToProtocol:@protocol(NSEDeepMutableCopying)])
            element = [object NSE_mutableCopyToDepth:aDepth - 1 zone:aZone];
        else if ([object conformsToProtocol:@protocol(NSEDeepCopying)]) {
            element = [object NSE_copyToDepth:aDepth - 1 zone:aZone];
            if ([element conformsToProtocol:@protocol(NSMutableCopying)]) {
                id deep = element;
                element = [deep mutableCopyWithZone:aZone];
                [deep release];
            }
        }
        else if ([object conformsToProtocol:@protocol(NSMutableCopying)])
            element = [object mutableCopyWithZone:aZone];
        else
            element = [object copyWithZone:aZone];
        if (!element) {
            [copy release];
            return nil;
        }
        [copy addObject:element];
        [element release];
    }
    return copy;
}

- (id)NSE_deepMutableCopy
{
    return [self NSE_mutableCopyToDepth:NSUIntegerMax zone:NULL];
}

// A set of copies of the elements down to aDepth (the mutable set it
// filled); nil if one can't be copied.
- (id)NSE_copyToDepth:(NSUInteger)aDepth zone:(NSZone *)aZone
{
    NSUInteger count = [self count];
    if (aDepth == 0 || count == 0)
        return [self copyWithZone:aZone];
    NSMutableSet *copy = [[NSMutableSet allocWithZone:aZone] initWithCapacity:count];
    if (!copy)
        return nil;
    for (id object in self) {
        id element = [object conformsToProtocol:@protocol(NSEDeepCopying)]
            ? [object NSE_copyToDepth:aDepth - 1 zone:aZone] : [object copyWithZone:aZone];
        if (!element) {
            [copy release];
            return nil;
        }
        [copy addObject:element];
        [element release];
    }
    return copy;
}

- (id)NSE_deepCopy
{
    return [self NSE_copyToDepth:NSUIntegerMax zone:NULL];
}

@end

@implementation NSSet (NSESetLoading)

// Before Leopard (Foundation < 677) this added fast enumeration.
+ (void)load
{
}

@end

