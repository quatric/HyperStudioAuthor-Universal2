#import "HSHTML5LinkedStacksContext.h"

@implementation HSHTML5LinkedStacksContext

// Names are JSON-safe stack file names, suffixed with a counter when two stacks share one.
- (void)addLinkedStackURL:(id)aURL
{
    if (aURL == nil)
        return;
    if (_linkedStacks == nil)
        _linkedStacks = [NSMutableDictionary new];
    if ([_linkedStacks objectForKey:aURL] != nil)
        return;

    NSString *path = [aURL path];
    if (path == nil)
        return;
    NSString *name = [HSHTML5ExporterHelper JSonCorrectFilenameWithString:[[path lastPathComponent] stringByDeletingPathExtension]];
    if (name == nil || [name length] == 0)
        return;
    if (_linkedStackNames == nil)
        _linkedStackNames = [NSCountedSet new];

    NSUInteger count = [_linkedStackNames countForObject:name];
    [_linkedStacks setObject:count != 0 ? [NSString stringWithFormat:@"%@_%u", name, (unsigned)count] : name forKey:aURL];
    [_linkedStackNames addObject:name];
}

- (id)nameForLinkedStackURL:(id)aURL
{
    if (aURL == nil)
        return nil;
    return [_linkedStacks objectForKey:aURL];
}

- (BOOL)isRootStackURL:(id)aURL
{
    return [[_parentDocument fileURL] isEqual:aURL];
}

- (BOOL)shouldAddLinkedStacks
{
    if (![[NSUserDefaults standardUserDefaults] boolForKey:HSHTML5ExportAreLinkedStacksInDocument])
        return NO;
    return (NSInteger)_currentLinkedStackLevel < [[NSUserDefaults standardUserDefaults] integerForKey:HSHTML5ExportLinkedStacksDepth];
}

- (void)setStackLevel:(NSUInteger)aLevel
{
    _currentLinkedStackLevel = (unsigned int)aLevel;
}

- (void)dealloc
{
    [_parentDocument release];
    [_linkedStackNames release];
    [_linkedStacks release];
    [super dealloc];
}

@end
