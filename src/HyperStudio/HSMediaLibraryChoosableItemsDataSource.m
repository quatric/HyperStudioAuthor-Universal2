#import "HSMediaLibraryChoosableItemsDataSource.h"

@implementation HSMediaLibraryChoosableItemsDataSource

+ (id)defaultPathToMediaFolder
{
    return @"";
}

+ (id)defaultMediaType
{
    return @"picture";
}

- (void)updateChoosableItemsIfNeeded
{
}

- (id)URLForChoosableItemAtIndex:(NSUInteger)aIndex
{
    return [[self mediaURLs] objectAtIndex:aIndex];
}

- (id)mediaForChoosableItemAtIndex:(NSUInteger)aIndex
{
    if (!_medias)
        _medias = [NSMutableDictionary new];
    id url = [[self mediaURLs] objectAtIndex:aIndex];
    id media = [_medias objectForKey:url];
    if (!media) {
        media = [HSNewMedia mediaWithPath:[url path]];
        [_medias setObject:media forKey:url];
    }
    return media;
}

- (id)labelForChoosableItemAtIndex:(NSUInteger)aIndex
{
    return [[self mediaForChoosableItemAtIndex:aIndex] mediaName];
}

- (NSUInteger)countOfChoosableItems
{
    return [[self mediaURLs] count];
}

- (id)mediaURLs
{
    if (!_mediaURLs) {
        _mediaURLs = [NSMutableArray new];
        [self addItemsFromMediaDataFolder:[self mediaDataFolder]];
    }
    return _mediaURLs;
}

// Adds the folder's items, then descends into its first subfolder only.
- (void)addItemsFromMediaDataFolder:(id)aFolder
{
    NSInteger count = [aFolder numberOfDataItems];
    for (NSInteger i = 0; i < count; i++)
        [_mediaURLs addObject:[[aFolder dataItemAtIndex:i] dataURL]];
    if ([aFolder numberOfDataFolders])
        [self addItemsFromMediaDataFolder:[aFolder dataFolderAtIndex:0]];
}

- (id)mediaData
{
    return [[self mediaDataProvider] queryInterface:@protocol(HSLibraryMediaData)];
}

- (id)mediaDataProvider
{
    return [[HSLibraryManager sharedLibraryManager] providerForMediaType:[self mediaType]];
}

- (id)mediaDataFolder
{
    if (!_mediaDataFolder)
        _mediaDataFolder = [self mediaDataFolderAtPath:[self pathToMediaFolder]];
    return _mediaDataFolder;
}

- (void)setPathToMediaFolder:(id)aFolder
{
    if (![_mediaFolderPath isEqualToString:aFolder]) {
        [_mediaFolderPath release];
        _mediaFolderPath = [aFolder retain];
        _mediaDataFolder = [self mediaDataFolderAtPath:aFolder];
    }
}

// (As in the original the default is only applied when a path is already set.)
- (id)pathToMediaFolder
{
    id path = nil;
    if (_mediaFolderPath) {
        [self setPathToMediaFolder:[[self class] defaultPathToMediaFolder]];
        path = _mediaFolderPath;
    }
    return path;
}

- (id)mediaType
{
    if (!_mediaType) {
        [self setMediaType:[[self class] defaultMediaType]];
    }
    return _mediaType;
}

- (void)setMediaType:(id)aType
{
    if (![aType isEqualToString:_mediaType]) {
        [_mediaType release];
        _mediaType = [aType retain];
    }
}

// Walks the data folders along the path components, starting at the root
// (a component equal to the current folder's name stays in place).
- (id)mediaDataFolderAtPath:(id)aPath
{
    id folder = [[self mediaData] rootDataFolder];
    NSEnumerator *enumerator = [[aPath pathComponents] objectEnumerator];
    id component;
    while ((component = [enumerator nextObject])) {
        if ([[folder dataDisplayName] isEqualToString:component])
            continue;
        NSInteger count = [folder numberOfDataFolders];
        id next = nil;
        for (NSInteger i = 0; i < count; i++) {
            id child = [folder dataFolderAtIndex:i];
            if ([[child dataDisplayName] isEqualToString:component]) {
                next = child;
                break;
            }
        }
        if (!next)
            return nil;
        folder = next;
    }
    return folder;
}

- (void)dealloc
{
    [_medias release];
    [_mediaURLs release];
    [_mediaFolderPath release];
    [_mediaType release];
    [super dealloc];
}

@end
