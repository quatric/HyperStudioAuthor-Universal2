#import "HSSoundsLibraryiTunesPlaylist.h"

// A playlist of the iTunes library, with its tracks (iTunes songs).

// Before iTunes 6 the special playlists are only known by their names.
static BOOL HSiTunesPlaylistIsNamed(HSSoundsLibraryiTunesPlaylist *aPlaylist, NSString *aName)
{
    NSString *name = [[NSBundle bundleForClass:[aPlaylist class]] localizedStringForKey:aName value:@"" table:@"LibrarySoundsiTunes"];
    return [[aPlaylist displayName] isEqualToString:name] && ![aPlaylist hasSmartInfo];
}

@implementation HSSoundsLibraryiTunesPlaylist

+ (id)searchCategories
{
    return [NSArray arrayWithObjects:itHumanReadableNameKey, itArtistKey, nil];
}

- (BOOL)isFolder
{
    return [[_info objectForKey:itFolderKey] boolValue];
}

- (BOOL)isPodcasts
{
    @try {
        if ([HSSoundsLibraryiTunesHelper iTunesApplicationVersion] < 6.0f)
            return HSiTunesPlaylistIsNamed(self, @"iTunesPodcasts");
        return [[_info objectForKey:itPodcastsKey] boolValue];
    } @catch (NSException *exception) {
    }
    return NO;
}

- (BOOL)isVideos
{
    @try {
        if ([HSSoundsLibraryiTunesHelper iTunesApplicationVersion] < 6.0f)
            return HSiTunesPlaylistIsNamed(self, @"iTunesVideos");
        return [[_info objectForKey:itVideosKey] boolValue] || [[_info objectForKey:itMoviesKey] boolValue];
    } @catch (NSException *exception) {
    }
    return NO;
}

- (BOOL)isPartyShuffle
{
    @try {
        if ([HSSoundsLibraryiTunesHelper iTunesApplicationVersion] < 6.0f)
            return HSiTunesPlaylistIsNamed(self, @"iTunesPartyShuffle");
        return [[_info objectForKey:itPartyShuffleKey] boolValue];
    } @catch (NSException *exception) {
    }
    return NO;
}

- (BOOL)hasSmartInfo
{
    return [_info objectForKey:itSmartInfoKey] != nil;
}

- (NSInteger)compareDecrease:(id)aDecrease
{
    return [aDecrease compareIncrease:self];
}

// The special playlists first (by weight), then by name.
- (NSInteger)compareIncrease:(id)aIncrease
{
    NSInteger weight = [self sortWeight];
    NSInteger otherWeight = [aIncrease sortWeight];
    if (weight == otherWeight)
        return [[self displayName] caseInsensitiveCompare:[aIncrease displayName]];
    return otherWeight < weight ? NSOrderedAscending : NSOrderedDescending;
}

// The tracks with the text in the category (any search category if none).
- (id)filterTracks:(id)aTracks byCategory:(id)aCategory
{
    if ([aTracks length] == 0)
        return _tracks;
    NSMutableArray *tracks = [NSMutableArray arrayWithCapacity:0];
    for (id track in _tracks) {
        if ([aCategory length] != 0) {
            if ([[[track info] objectForKey:aCategory] rangeOfString:aTracks options:NSCaseInsensitiveSearch].location != NSNotFound)
                [tracks addObject:track];
            continue;
        }
        for (id category in [[self class] searchCategories]) {
            NSString *value = [[track info] objectForKey:category];
            if (value != nil && [value rangeOfString:aTracks options:NSCaseInsensitiveSearch].location != NSNotFound) {
                [tracks addObject:track];
                break;
            }
        }
    }
    return tracks;
}

- (BOOL)isMaster
{
    id master = [_info objectForKey:itMasterKey];
    BOOL isMaster = master != nil;
    @try {
        isMaster = [master boolValue];
    } @catch (NSException *exception) {
    }
    return isMaster;
}

- (NSInteger)sortWeight
{
    if ([self isMaster])
        return 6;
    if ([self isPodcasts])
        return 5;
    if ([self isVideos])
        return 4;
    if ([self isPartyShuffle])
        return 3;
    if ([self isFolder])
        return 2;
    return [self hasSmartInfo] ? 1 : 0;
}

- (id)songAtIndex:(NSUInteger)aIndex
{
    if (aIndex < [_tracks count])
        return [_tracks objectAtIndex:aIndex];
    return nil;
}

- (NSInteger)numberOfSongs
{
    return [_tracks count];
}

- (id)dataDisplayName
{
    return [self displayName];
}

- (id)dataURL
{
    return nil;
}

- (id)dataFolderAtIndex:(NSUInteger)aIndex
{
    return nil;
}

- (NSUInteger)numberOfDataFolders
{
    return 0;
}

- (id)dataItemAtIndex:(NSUInteger)aIndex
{
    return [self songAtIndex:aIndex];
}

- (NSUInteger)numberOfDataItems
{
    return [self numberOfSongs];
}

- (id)subitemAtIndex:(NSUInteger)aIndex
{
    return nil;
}

- (NSUInteger)numberOfSubitems
{
    return 0;
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
    return [_info objectForKey:itHumanReadableNameKey];
}

- (NSImage *)loadImage:(NSImage **)aImage named:(NSString *)aName
{
    if (*aImage == nil) {
        NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:aName ofType:@"tiff"];
        if (path != nil)
            *aImage = [[NSImage allocWithZone:[self zone]] initWithContentsOfFile:path];
    }
    return *aImage;
}

// Original quirk kept: the special playlists share one image (each
// playlist being of one kind only).
- (id)icon
{
    if ([self isMaster])
        return [self loadImage:&_masterPlaylistImage named:@"iTunesLibraryPlaylist"];
    if ([self isPartyShuffle])
        return [self loadImage:&_iTunesPlaylistImage named:@"iTunesPartyShuffle"];
    if ([self isVideos])
        return [self loadImage:&_iTunesPlaylistImage named:@"iTunesVideos"];
    if ([self isPodcasts])
        return [self loadImage:&_iTunesPlaylistImage named:@"iTunesPodcasts"];
    if ([self isFolder])
        return [self loadImage:&_iTunesFolderImage named:@"iTunesFolder"];
    if ([self hasSmartInfo])
        return [self loadImage:&_iTunesPlaylistImage named:@"iTunesPlaylist"];
    return [self loadImage:&_userPlaylistImage named:@"iTunesUserPlaylist"];
}

- (void)dealloc
{
    [_tracks release];
    [_info release];
    [_masterPlaylistImage release];
    [_userPlaylistImage release];
    [_iTunesPlaylistImage release];
    [_iTunesPartyShuffleImage release];
    [_iTunesVideosImage release];
    [_iTunesPodcastsImage release];
    [_iTunesFolderImage release];
    [super dealloc];
}

// The playlist's items are track IDs in the tracks dictionary.
- (id)initWithDictionaryRepresentation:(id)aRepresentation tracks:(id)aTracks
{
    if ((self = [super init])) {
        _info = [aRepresentation retain];
        _tracks = [[NSMutableArray allocWithZone:[self zone]] initWithCapacity:0];
        for (id item in [aRepresentation objectForKey:itPlaylistItemsKey]) {
            @try {
                [_tracks addObject:[aTracks objectForKey:[item objectForKey:itTrackIDKey]]];
            } @catch (NSException *exception) {
            }
        }
    }
    return self;
}

- (id)init
{
    return [self initWithDictionaryRepresentation:nil tracks:nil];
}

@end
