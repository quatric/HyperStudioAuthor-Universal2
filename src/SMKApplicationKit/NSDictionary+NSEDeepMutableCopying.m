#import "NSDictionary+NSEDeepMutableCopying.h"

// What the copying methods pass to their CFDictionaryApplyFunction callbacks:
// the dictionary being filled (nil once an element couldn't be copied), the
// depth for the elements and the zone.
typedef struct {
    NSMutableDictionary *copy;
    NSUInteger depth;
    NSZone *zone;
} NSEDictionaryCopyContext;

static void _NSEAddMutableCopy(const void *key, const void *value, void *info)
{
    NSEDictionaryCopyContext *context = info;
    if (!context->copy)
        return;
    id object = (id)value, element;
    if ([object conformsToProtocol:@protocol(NSEDeepMutableCopying)])
        element = [object NSE_mutableCopyToDepth:context->depth zone:context->zone];
    else if ([object conformsToProtocol:@protocol(NSEDeepCopying)]) {
        element = [object NSE_copyToDepth:context->depth zone:context->zone];
        if ([element conformsToProtocol:@protocol(NSMutableCopying)]) {
            id deep = element;
            element = [deep mutableCopyWithZone:context->zone];
            [deep release];
        }
    }
    else if ([object conformsToProtocol:@protocol(NSMutableCopying)])
        element = [object mutableCopyWithZone:context->zone];
    else
        element = [object copyWithZone:context->zone];
    if (!element) {
        [context->copy release];
        context->copy = nil;
        return;
    }
    [context->copy setObject:element forKey:(id)key];
    [element release];
}

static void _NSEAddCopy(const void *key, const void *value, void *info)
{
    NSEDictionaryCopyContext *context = info;
    if (!context->copy)
        return;
    id object = (id)value;
    id element = [object conformsToProtocol:@protocol(NSEDeepCopying)]
        ? [object NSE_copyToDepth:context->depth zone:context->zone] : [object copyWithZone:context->zone];
    if (!element) {
        [context->copy release];
        context->copy = nil;
        return;
    }
    [context->copy setObject:element forKey:(id)key];
    [element release];
}

@implementation NSDictionary (NSEDeepMutableCopying)

// A mutable dictionary of copies of the values down to aDepth (see
// -[NSArray NSE_mutableCopyToDepth:zone:]); nil if a value can't be copied.
// (The original returned the released dictionary then.)
- (id)NSE_mutableCopyToDepth:(NSUInteger)aDepth zone:(NSZone *)aZone
{
    NSUInteger count = [self count];
    if (aDepth == 0 || count == 0)
        return [self mutableCopyWithZone:aZone];
    NSEDictionaryCopyContext context = {[[NSMutableDictionary allocWithZone:aZone] initWithCapacity:count],
        aDepth - 1, aZone};
    if (context.copy)
        CFDictionaryApplyFunction((CFDictionaryRef)self, _NSEAddMutableCopy, &context);
    return context.copy;
}

- (id)NSE_deepMutableCopy
{
    return [self NSE_mutableCopyToDepth:NSUIntegerMax zone:NULL];
}

// A dictionary of copies of the values down to aDepth (the mutable
// dictionary it filled); nil if a value can't be copied.
- (id)NSE_copyToDepth:(NSUInteger)aDepth zone:(NSZone *)aZone
{
    NSUInteger count = [self count];
    if (aDepth == 0 || count == 0)
        return [self copyWithZone:aZone];
    NSEDictionaryCopyContext context = {[[NSMutableDictionary allocWithZone:aZone] initWithCapacity:count],
        aDepth - 1, aZone};
    if (context.copy)
        CFDictionaryApplyFunction((CFDictionaryRef)self, _NSEAddCopy, &context);
    return context.copy;
}

- (id)NSE_deepCopy
{
    return [self NSE_copyToDepth:NSUIntegerMax zone:NULL];
}

@end

@implementation NSDictionary (NSEDictionaryLoading)

// Before Leopard (Foundation < 677) this added fast enumeration.
+ (void)load
{
}

@end

