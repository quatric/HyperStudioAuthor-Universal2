#import "HSSoundsLibraryiTunesMediaDataProvider.h"

// The iTunes libraries (iTunes Music Library.xml): their tracks and
// playlists, the master playlist first.

static NSInteger HSSoundsLibraryiTunesMediaDataProviderDefaultSortOrder = 1;

@implementation HSSoundsLibraryiTunesMediaDataProvider

+ (NSInteger)defaultSortOrder
{
    return HSSoundsLibraryiTunesMediaDataProviderDefaultSortOrder;
}

+ (void)setDefaultSortOrder:(NSInteger)aOrder
{
    HSSoundsLibraryiTunesMediaDataProviderDefaultSortOrder = aOrder;
}

// Original quirk kept: a library without a music folder location gives
// no tracks nor playlists.
- (void)initializeWithLibraries:(id)aLibraries
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    [_tracks release];
    _tracks = nil;
    [_playlists release];
    _playlists = nil;
    for (NSDictionary *entry in aLibraries) {
        @try {
            NSDictionary *library = nil;
            if ([entry objectForKey:itMusicFolderLocationKey] != nil)
                library = [self updateLibrary:entry];
            NSDictionary *tracks = [library objectForKey:itTracksKey];
            for (id key in [tracks allKeys]) {
                @try {
                    NSDictionary *info = [tracks objectForKey:key];
                    HSSoundsLibraryiTunesSong *song = [[[HSSoundsLibraryiTunesSong allocWithZone:[self zone]] initWithDictionaryRepresentation:info] autorelease];
                    if (_tracks == nil)
                        _tracks = [[NSMutableDictionary allocWithZone:[self zone]] initWithCapacity:0];
                    [_tracks setObject:song forKey:[info objectForKey:itTrackIDKey]];
                } @catch (NSException *exception) {
                }
            }
            for (id info in [library objectForKey:itPlaylistsKey]) {
                @try {
                    HSSoundsLibraryiTunesPlaylist *playlist = [[[HSSoundsLibraryiTunesPlaylist allocWithZone:[self zone]] initWithDictionaryRepresentation:info tracks:_tracks] autorelease];
                    if (_playlists == nil)
                        _playlists = [[NSMutableArray allocWithZone:[self zone]] initWithCapacity:0];
                    if ([playlist isMaster] && [_playlists count] != 0)
                        [_playlists insertObject:playlist atIndex:0];
                    else
                        [_playlists addObject:playlist];
                } @catch (NSException *exception) {
                }
            }
            NSInteger order = [[self class] defaultSortOrder];
            if (order == 1)
                [_playlists sortUsingSelector:@selector(compareIncrease:)];
            else if (order == 2)
                [_playlists sortUsingSelector:@selector(compareDecrease:)];
        } @catch (NSException *exception) {
        }
    }
    [pool release];
}

// Reads the library files changed since the last time (or all, when
// the libraries appeared or went away).
- (void)initializeWithLibraryFiles:(id)aFiles
{
    @try {
        NSMutableArray *libraries = [NSMutableArray arrayWithCapacity:[aFiles count]];
        BOOL changed = NO;
        for (NSURL *url in aFiles) {
            if (![url isFileURL])
                continue;
            NSString *path = [url path];
            NSString *name = [path lastPathComponent];
            NSDate *date = [[[NSFileManager defaultManager] attributesOfItemAtPath:[path stringByResolvingSymlinksInPath] error:NULL] objectForKey:NSFileModificationDate];
            if (![[NSFileManager defaultManager] isReadableFileAtPath:path])
                date = nil;
            if (![[[self modificationTimes] objectForKey:name] isEqualToDate:date]) {
                [[self modificationTimes] removeObjectForKey:name];
                if (date != nil)
                    [[self modificationTimes] setObject:date forKey:name];
                changed = YES;
            }
            NSDictionary *library = [NSDictionary dictionaryWithContentsOfFile:[url path]];
            if (library != nil)
                [libraries addObject:library];
        }
        if (changed || ([libraries count] == 0) != ([_tracks count] == 0))
            [self initializeWithLibraries:libraries];
    } @catch (NSException *exception) {
    }
}

// The tracks' locations moved to where the iTunes music folder is now,
// when it was moved since.
- (id)updateLibrary:(id)aLibrary
{
    NSMutableDictionary *library = [NSMutableDictionary dictionaryWithDictionary:aLibrary];
    NSString *oldLocation = [aLibrary objectForKey:itMusicFolderLocationKey];
    if ([[NSFileManager defaultManager] isReadableFileAtPath:[[NSURL URLWithString:oldLocation] path]])
        return library;
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *folderName = [bundle localizedStringForKey:@"iTunesMusicFolderName" value:@"" table:@"LibrarySoundsiTunes"];
    NSString *folder = [[[bundle localizedStringForKey:iTunesRecentDatabasesKey value:@"" table:@"LibrarySoundsiTunes"] stringByExpandingTildeInPath] stringByDeletingLastPathComponent];
    NSString *location = [[NSURL fileURLWithPath:[folder stringByAppendingString:folderName]] absoluteString];
    if (location == nil)
        return library;
    NSURL *url = [NSURL URLWithString:location];
    NSURL *resolved = [HSSoundsLibraryiTunesHelper resolveAliasesInURL:url];
    if (resolved == nil)
        resolved = url;
    NSString *newLocation = [[resolved absoluteString] stringByAppendingString:@"/"];
    if ([newLocation isEqual:oldLocation] || ![[NSFileManager defaultManager] isReadableFileAtPath:[[NSURL URLWithString:newLocation] path]])
        return library;
    [library setObject:newLocation forKey:itMusicFolderLocationKey];
    // Fix: the tracks of the plist are immutable; setting them in place
    // threw and left every location as it was.
    NSMutableDictionary *tracks = [NSMutableDictionary dictionaryWithDictionary:[library objectForKey:itTracksKey]];
    for (id key in [tracks allKeys]) {
        @try {
            NSMutableDictionary *track = [NSMutableDictionary dictionaryWithDictionary:[tracks objectForKey:key]];
            NSMutableString *trackLocation = [NSMutableString stringWithString:[track objectForKey:itLocationKey]];
            if ([trackLocation replaceOccurrencesOfString:oldLocation withString:newLocation options:NSLiteralSearch range:NSMakeRange(0, [trackLocation length])] != 0)
                [track setObject:trackLocation forKey:itLocationKey];
            [tracks setObject:track forKey:key];
        } @catch (NSException *exception) {
        }
    }
    [library setObject:tracks forKey:itTracksKey];
    return library;
}

- (id)displayStringForCategory:(id)aCategory
{
    return [[NSBundle bundleForClass:[self class]] localizedStringForKey:aCategory value:@"" table:@"Sounds"];
}

- (id)searchCategories
{
    return [HSSoundsLibraryiTunesPlaylist searchCategories];
}

- (id)modificationTimes
{
    if (_modificationTimes == nil)
        _modificationTimes = [[NSMutableDictionary allocWithZone:[self zone]] initWithCapacity:0];
    return _modificationTimes;
}

- (id)dataFolderAtIndex:(NSUInteger)aIndex
{
    if (aIndex < [_playlists count])
        return [_playlists objectAtIndex:aIndex];
    return nil;
}

- (NSUInteger)numberOfDataFolders
{
    return [_playlists count];
}

- (id)dataItemAtIndex:(NSUInteger)aIndex
{
    return nil;
}

- (NSUInteger)numberOfDataItems
{
    return 0;
}

- (id)dataDisplayName
{
    return [self mediaDisplayName];
}

- (id)dataURL
{
    return nil;
}

- (id)rootDataFolder
{
    if (_playlists == nil)
        [self initializeWithLibraryFiles:[HSSoundsLibraryiTunesHelper iTunesRecentDatabases]];
    return self;
}

- (id)mediaDisplayName
{
    return [[NSBundle bundleForClass:[self class]] localizedStringForKey:@"iTunesDisplayName" value:@"" table:@"LibrarySoundsiTunes"];
}

- (id)mediaIcon
{
    return nil;
}

- (id)rootItem
{
    [self initializeWithLibraryFiles:[HSSoundsLibraryiTunesHelper iTunesRecentDatabases]];
    return self;
}

- (id)subitemAtIndex:(NSUInteger)aIndex
{
    if (aIndex < [_playlists count])
        return [_playlists objectAtIndex:aIndex];
    return nil;
}

- (NSUInteger)numberOfSubitems
{
    return [_playlists count];
}

- (id)actionTarget
{
    return nil;
}

- (SEL)actionSelector
{
    return NULL;
}

- (id)actionImage
{
    return nil;
}

- (id)displayName
{
    return [self mediaDisplayName];
}

- (id)icon
{
    return [self mediaIcon];
}

- (id)queryInterface:(id)aInterface
{
    return [self conformsToProtocol:aInterface] ? self : nil;
}

- (BOOL)isPlayable
{
    return YES;
}

- (BOOL)supportedData:(id)aData error:(id *)aError
{
    return NO;
}

- (BOOL)supportedData:(id)aData
{
    return [self supportedData:aData error:NULL];
}

- (id)providerType
{
    return @"iTunes";
}

- (id)mediaType
{
    return @"iTunesSound";
}

- (BOOL)sourceApplicationPresents
{
    return [HSSoundsLibraryiTunesHelper iTunesApplicationVersionSupported];
}

- (void)dealloc
{
    [_tracks release];
    [_playlists release];
    [_modificationTimes release];
    [super dealloc];
}

@end
