#import "KeynoteData.h"

@implementation KeynoteData

- (id)path
{
    NSString *path = [KeynoteTools pathWithAttributesDictionary:[self nodeAttributes]];
    if ([path hasPrefix:@"theme-files/"])
        path = [path substringFromIndex:[@"theme-files/" length]];
    return path;
}

// Bare file names come from the archive's resources; paths from disk,
// relative to the document when not readable as given.
- (id)data
{
    NSString *path = [self path];
    if ([path isEqualToString:[path lastPathComponent]])
        return [[[self content] resources] objectForKey:path];
    if (![[NSFileManager defaultManager] isReadableFileAtPath:path]) {
        path = [[[self importManager] pathToDocument] stringByAppendingPathComponent:path];
        if (![[NSFileManager defaultManager] isReadableFileAtPath:path])
            return nil;
    }
    return [NSData dataWithContentsOfFile:path];
}

- (id)image
{
    return [NSImage hyperImageWithData:[self data]];
}

- (BOOL)containsValidData
{
    NSString *path = [self path];
    if ([path isEqualToString:[path lastPathComponent]])
        return [[[self content] resources] objectForKey:path] != nil;
    if ([[NSFileManager defaultManager] isReadableFileAtPath:path])
        return YES;
    path = [[[self importManager] pathToDocument] stringByAppendingPathComponent:path];
    return [[NSFileManager defaultManager] isReadableFileAtPath:path];
}

@end
