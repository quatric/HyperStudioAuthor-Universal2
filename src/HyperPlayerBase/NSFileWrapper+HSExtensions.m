#import "NSFileWrapper+HSExtensions.h"
@implementation NSFileWrapper (HSExtensions)
// The paths of all regular files inside, starting with the wrapper's name.
- (id)hyperWrapperContents
{
    return [self hyperWrapperContentsWithRootWrapperPath:[self preferredFilename]];
}
- (id)hyperWrapperContentsWithRootWrapperPath:(id)aPath
{
    NSMutableArray *contents = [NSMutableArray arrayWithCapacity:0];
    NSDictionary *wrappers = [self fileWrappers];
    for (id key in [wrappers allKeys]) {
        NSFileWrapper *wrapper = [[self fileWrappers] objectForKey:key];
        NSString *path = [aPath stringByAppendingPathComponent:[wrapper preferredFilename]];
        if ([wrapper isDirectory])
            [contents addObjectsFromArray:[wrapper hyperWrapperContentsWithRootWrapperPath:path]];
        else
            [contents addObject:path];
    }
    return contents;
}
- (id)hyperWrapperForPath:(id)aPath
{
    NSFileWrapper *wrapper = self;
    for (NSString *component in [aPath componentsSeparatedByString:@"/"])
        wrapper = [[wrapper fileWrappers] objectForKey:component];
    return wrapper;
}
// Uniqued names are "<prefix>__#$!@%!#__<name>": the part after the
// separator. Original quirk kept: with more than one separator the whole
// name comes back (the parts are joined again).
- (id)originalPreferredHyperFilename
{
    NSString *name = [self preferredFilename];
    NSArray *parts = [name componentsSeparatedByString:@"__#$!@%!#__"];
    NSUInteger count = [parts count];
    if (count < 2)
        return name;
    if (count == 2)
        return [parts lastObject];
    return [parts componentsJoinedByString:@"__#$!@%!#__"];
}
// A regular file with the dictionary as an XML property list.
- (id)initWithHyperDictionary:(id)aDictionary
{
    NSString *error = nil;
    NSData *data = aDictionary != nil
        ? [NSPropertyListSerialization dataFromPropertyList:aDictionary format:NSPropertyListXMLFormat_v1_0 errorDescription:&error]
        : [NSData data];
    self = [self initRegularFileWithContents:data];
    if (error != nil) {
        [self autorelease];
        return nil;
    }
    return self;
}
- (id)hyperDictionaryRepresentation
{
    NSData *data = [self regularFileContents];
    if ([data length] == 0)
        return nil;
    NSString *error = nil;
    id plist = [NSPropertyListSerialization propertyListFromData:data mutabilityOption:NSPropertyListImmutable format:NULL errorDescription:&error];
    if (plist != nil && ![plist isKindOfClass:[NSDictionary class]] && error == nil)
        error = @"is not a dictionary";
    return error == nil ? plist : nil;
}
@end
