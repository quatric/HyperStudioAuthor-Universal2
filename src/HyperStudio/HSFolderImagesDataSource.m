#import "HSFolderImagesDataSource.h"

@implementation HSFolderImagesDataSource

+ (id)defaultPath
{
    return [[HSPathsProvider sharedPathsProvider] userLibraryFolder];
}

- (void)updateChoosableItemsIfNeeded
{
}

// Original quirk kept: every item gets the folder's URL.
- (id)URLForChoosableItemAtIndex:(NSUInteger)aIndex
{
    return [NSURL fileURLWithPath:[self path]];
}

- (id)labelForChoosableItemAtIndex:(NSUInteger)aIndex
{
    return nil;
}

- (id)mediaForChoosableItemAtIndex:(NSUInteger)aIndex
{
    return [[self medias] objectAtIndex:aIndex];
}

- (NSUInteger)countOfChoosableItems
{
    return [[self medias] count];
}

- (void)setPath:(id)aPath
{
    if (![_path isEqualToString:aPath]) {
        [_path release];
        _path = [aPath retain];
        [self updateMedias];
    }
}

- (id)path
{
    if (_path == nil)
        _path = [[[self class] defaultPath] retain];
    return _path;
}

- (void)mediaUIDsWillRemoveFromMediaAccessor:(id)aAccessor
{
    [_medias release];
    _medias = nil;
}

// An image file is recognized by its extension, through an alias when it is one.
- (void)updateMedias
{
    [_medias release];
    _medias = nil;
    if (_path == nil)
        return;
    _medias = [NSMutableArray new];
    NSEnumerator *enumerator = [[[NSFileManager defaultManager] contentsOfDirectoryAtPath:_path error:NULL] objectEnumerator];
    NSString *name;
    while ((name = [enumerator nextObject]) != nil) {
        NSString *path = [[NSString stringWithString:_path] stringByAppendingPathComponent:name];
        NSString *resolvedPath = [[NSFileManager defaultManager] hyperResolveAliasAtPath:path];
        if (resolvedPath == nil)
            resolvedPath = path;
        if ([[NSImage imageFileTypes] containsObject:[resolvedPath pathExtension]])
            [_medias addObject:[HSNewMedia mediaWithPath:[[NSString stringWithString:_path] stringByAppendingPathComponent:name]]];
    }
}

- (id)medias
{
    if (_medias == nil)
        [self updateMedias];
    return _medias;
}

- (void)dealloc
{
    [_medias release];
    [_path release];
    [super dealloc];
}

@end
