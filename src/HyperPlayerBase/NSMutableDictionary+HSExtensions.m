#import "NSMutableDictionary+HSExtensions.h"
@implementation NSMutableDictionary (HSExtensions)
- (void)refreshHyperUIDsAndIgnoreUIDsFromSet:(id)aSet
{
    NSMutableDictionary *replacedUIDs = [NSMutableDictionary new];
    [self refreshHyperUIDsWithReplacedUIDs:replacedUIDs ignoreUIDs:aSet];
    [replacedUIDs release];
}
// Gives every stored HSUID (an extra dictionary of class _HSCFUUID) found in
// this dictionary tree a new UID, the same new one for every occurrence of an
// old UID (aDs maps old UID strings to the new UIDs' representations). UIDs in
// aDs2 are kept.
- (void)refreshHyperUIDsWithReplacedUIDs:(id)aDs ignoreUIDs:(id)aDs2
{
    NSEnumerator *keys = [[self allKeys] objectEnumerator];
    id key;
    while ((key = [keys nextObject]) != nil) {
        id value = [self objectForKey:key];
        if ([value isKindOfClass:[NSDictionary class]]) {
            if ([[value objectForKey:EXClassNameKey] isEqual:@"_HSCFUUID"]) {
                _HSCFUUID *uid = [HSUID objectWithExtraDictionary:value];
                if (aDs2 == nil || ![aDs2 containsObject:uid]) {
                    id replacement = [aDs objectForKey:[uid stringValue]];
                    if (replacement == nil) {
                        replacement = [[HSUID UID] extraDictionaryRepresentation];
                        [aDs setObject:replacement forKey:[uid stringValue]];
                    }
                    [self setObject:replacement forKey:key];
                }
            } else {
                NSMutableDictionary *copy = [value mutableCopy];
                [copy refreshHyperUIDsWithReplacedUIDs:aDs ignoreUIDs:aDs2];
                value = [copy copy];
                [copy release];
                [self setObject:value forKey:key];
                [value release];
            }
        } else if ([value isKindOfClass:[NSArray class]]) {
            NSMutableArray *copy = [value mutableCopy];
            [copy refreshHyperUIDsWithReplacedUIDs:aDs ignoreUIDs:aDs2];
            value = [copy copy];
            [copy release];
            [self setObject:value forKey:key];
            [value release];
        }
    }
}
@end
@implementation NSDictionary (HSExtensions)
- (id)hyperKeysOfDifferencesWithDictionary:(id)aDictionary
{
    NSMutableArray *differences = [NSMutableArray array];
    NSMutableSet *keys = [NSMutableSet setWithArray:[self allKeys]];
    [keys addObjectsFromArray:[aDictionary allKeys]];
    NSEnumerator *enumerator = [keys objectEnumerator];
    id key;
    while ((key = [enumerator nextObject]) != nil) {
        if (![[self objectForKey:key] isEqual:[aDictionary objectForKey:key]])
            [differences addObject:key];
    }
    return differences != nil ? [NSArray arrayWithArray:differences] : nil;
}
- (BOOL)isHyperIdenticalToDictionary:(id)aDictionary
{
    // Same keys holding the very same objects (pointer equality). Original
    // quirk kept: two empty dictionaries are not identical.
    if ([self count] != [aDictionary count])
        return NO;
    BOOL identical = NO;
    NSEnumerator *keys = [self keyEnumerator];
    id key;
    while ((key = [keys nextObject]) != nil) {
        if ([self objectForKey:key] != [aDictionary objectForKey:key])
            return NO;
        identical = YES;
    }
    return identical;
}
@end
