#import "NSMutableDictionary+EXExtensions.h"
@implementation NSMutableDictionary (EXExtensions)
// A deep merge: dictionaries merge recursively, arrays concatenate, other
// values replace.
- (id)extraAppendDictionary:(id)aDictionary
{
    NSEnumerator *keys = [aDictionary keyEnumerator];
    id key;
    while ((key = [keys nextObject]) != nil) {
        id value = [aDictionary objectForKey:key];
        id existing = [self objectForKey:key];
        if ([value isKindOfClass:[NSDictionary class]]) {
            NSMutableDictionary *merged = existing != nil ? [NSMutableDictionary dictionaryWithDictionary:existing] : [NSMutableDictionary dictionary];
            value = [merged extraAppendDictionary:value];
        } else if ([value isKindOfClass:[NSArray class]]) {
            if (existing != nil && [existing isKindOfClass:[NSArray class]])
                value = [existing arrayByAddingObjectsFromArray:value];
            else
                value = [NSArray arrayWithArray:value];
        }
        [self setObject:value forKey:key];
    }
    return self;
}
@end
@implementation NSDictionary (EXDictionaryCreation)
// The named resource as given, then as a .list, .plist, .toolbar, .strings
// or extensionless file.
+ (id)extraDictionaryNamed:(id)aNamed inBundle:(id)aBundle
{
    id dictionary = nil;
    NSString *extension = [aNamed pathExtension];
    if ([extension length] != 0) {
        NSString *path = [aBundle pathForResource:[aNamed stringByDeletingPathExtension] ofType:extension];
        if (path != nil)
            dictionary = [self dictionaryWithContentsOfFile:path];
    }
    for (NSString *type in [NSArray arrayWithObjects:@"list", @"plist", @"toolbar", @"strings", nil]) {
        if (dictionary != nil)
            return dictionary;
        NSString *path = [aBundle pathForResource:aNamed ofType:type];
        if (path != nil)
            dictionary = [self dictionaryWithContentsOfFile:path];
    }
    if (dictionary == nil) {
        NSString *path = [aBundle pathForResource:aNamed ofType:nil];
        if (path != nil)
            dictionary = [self dictionaryWithContentsOfFile:path];
    }
    return dictionary;
}
+ (id)extraDictionaryNamed:(id)aNamed
{
    return [self extraDictionaryNamed:aNamed inBundle:[NSBundle mainBundle]];
}
// The values for the keys, NSNull for absent ones unless omitted.
- (id)extraObjectsForKeys:(id)aKeys omitAbsent:(BOOL)aAbsent
{
    NSMutableArray *objects = [NSMutableArray arrayWithCapacity:[aKeys count]];
    id null = nil;
    for (id key in aKeys) {
        id object = [self objectForKey:key];
        if (object == nil && !aAbsent) {
            if (null == nil)
                null = [NSNull null];
            object = null;
        }
        if (object != nil)
            [objects addObject:object];
    }
    return objects;
}
// Whether every entry of a non-empty dictionary is in the receiver.
- (BOOL)extraContainsDictionary:(id)aDictionary
{
    if ([aDictionary count] == 0)
        return NO;
    NSEnumerator *keys = [aDictionary keyEnumerator];
    id key;
    while ((key = [keys nextObject]) != nil) {
        id value = [self objectForKey:key];
        if (value == nil || ![[aDictionary objectForKey:key] isEqual:value])
            return NO;
    }
    return YES;
}
- (id)extraDictionaryByAppendingDictionary:(id)aDictionary
{
    return [NSDictionary dictionaryWithDictionary:[[NSMutableDictionary dictionaryWithDictionary:self] extraAppendDictionary:aDictionary]];
}
@end
