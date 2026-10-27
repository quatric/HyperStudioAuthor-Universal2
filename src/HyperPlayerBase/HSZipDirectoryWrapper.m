#import "HSZipDirectoryWrapper.h"
@implementation HSZipDirectoryWrapper
- (BOOL)writeToFile:(id)aFile atomically:(BOOL)aAtomically updateFilenames:(BOOL)aFilenames
{
    if ([self isDirectory]) {
        if (![[NSFileManager defaultManager] createDirectoryAtPath:aFile withIntermediateDirectories:NO
                                                        attributes:[self fileAttributes] error:NULL])
            return NO;
        NSDictionary *wrappers = [self fileWrappers];
        NSEnumerator *enumerator = [[self fileWrappers] keyEnumerator];
        NSString *name;
        BOOL written = YES;
        while ((name = [enumerator nextObject]) != nil) {
            written = [[wrappers objectForKey:name] writeToFile:[aFile stringByAppendingPathComponent:name]
                                                     atomically:aAtomically updateFilenames:aFilenames];
            if (!written)
                return NO;
        }
        return written;
    }
    if ([self isRegularFile])
        return [super writeToFile:aFile atomically:aAtomically updateFilenames:aFilenames];
    return NO;
}
@end
