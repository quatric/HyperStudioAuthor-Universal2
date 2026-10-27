#import "HSPatternsSharedProvider.h"
// The ready made patterns: the PNG files of the patterns folder, by name.
@implementation HSPatternsSharedProvider
+ (id)sharedPatternsProvider
{
    static id provider = nil;
    if (provider == nil)
        provider = [[self class] new];
    return provider;
}
- (id)patterns
{
    if (_patterns == nil) {
        _patterns = [[NSMutableDictionary allocWithZone:[self zone]] initWithCapacity:0];
        NSString *folder = [[HSPathsProvider sharedPathsProvider] readyMadePatternsFolder];
        NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtPath:folder];
        NSString *file;
        while ((file = [enumerator nextObject]) != nil) {
            NSString *path = [folder stringByAppendingPathComponent:file];
            NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:NULL];
            if ([[attributes objectForKey:NSFileType] isEqualToString:NSFileTypeRegular]
                && [[self patternExtensions] containsObject:[file pathExtension]])
                [_patterns setObject:path forKey:[file stringByDeletingPathExtension]];
        }
    }
    return _patterns;
}
- (id)patternExtensions
{
    return [NSArray arrayWithObjects:@"png", nil];
}
- (id)hyperPatternPathForName:(id)aName
{
    if (aName == nil)
        return nil;
    return [[self patterns] objectForKey:aName];
}
- (id)hyperPatternForName:(id)aName
{
    NSString *path = [self hyperPatternPathForName:aName];
    if (path == nil)
        return nil;
    return [[[NSImage alloc] initWithContentsOfFile:path] autorelease];
}
- (id)hyperPatternNames
{
    return [[self patterns] allKeys];
}
- (void)dealloc
{
    [_patterns release];
    [super dealloc];
}
@end
