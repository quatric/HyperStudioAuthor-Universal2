#import "NSMutableArray+HSExtensions.h"
@implementation NSMutableArray (HSExtensions)
- (void)refreshHyperUIDsAndIgnoreUIDsFromSet:(id)aSet
{
    NSMutableDictionary *replaced = [NSMutableDictionary new];
    [self refreshHyperUIDsWithReplacedUIDs:replaced ignoreUIDs:aSet];
    [replaced release];
}
- (void)refreshHyperUIDsWithReplacedUIDs:(id)aDs ignoreUIDs:(id)aDs2
{
    // every archived UID (a dictionary of class _HSCFUUID) gets a new one,
    // the same new one wherever the old one appears; nested dictionaries
    // and arrays are refreshed too
    NSInteger count = [self count];
    for (NSInteger i = 0; i < count; i++) {
        id object = [self objectAtIndex:i];
        if ([object isKindOfClass:[NSDictionary class]] &&
            [[object objectForKey:EXClassNameKey] isEqual:@"_HSCFUUID"]) {
            HSUID *uid = [HSUID objectWithExtraDictionary:object];
            if (aDs2 != nil && [aDs2 containsObject:uid])
                continue;
            NSString *key = [uid stringValue];
            id replacement = [aDs objectForKey:key];
            if (replacement == nil) {
                replacement = [[HSUID UID] extraDictionaryRepresentation];
                [aDs setObject:replacement forKey:[uid stringValue]];
            }
            [self removeObjectAtIndex:i];
            [self insertObject:replacement atIndex:i];
        } else if ([object isKindOfClass:[NSDictionary class]] || [object isKindOfClass:[NSArray class]]) {
            id mutableObject = [object mutableCopy];
            [mutableObject refreshHyperUIDsWithReplacedUIDs:aDs ignoreUIDs:aDs2];
            id refreshed = [mutableObject copy];
            [mutableObject release];
            [self removeObjectAtIndex:i];
            [self insertObject:refreshed atIndex:i];
            [refreshed release];
        }
    }
}
@end
