#import "HSImportDialogMoviesiTunesPaneViewController.h"

@implementation HSImportDialogMoviesiTunesPaneViewController

+ (void)load
{
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    [HSImportDialogController registerPaneViewController:self withIdentifier:HSImportDialogControllerTypeMovies];
    [HSImportDialogController registerPaneViewController:self withIdentifier:HSImportDialogControllerTypeAnimations];
    [pool release];
}

- (id)moviesPlaylist
{
    if (_moviesPlaylist == nil) {
        HSSoundsLibraryiTunesMediaDataProvider *provider = [[HSSoundsLibraryiTunesMediaDataProvider allocWithZone:[self zone]] init];
        id rootItem = [provider rootItem];
        if (rootItem != nil) {
            NSInteger count = [rootItem numberOfSubitems];
            for (NSInteger i = 0; i < count && _moviesPlaylist == nil; i++) {
                id item = [rootItem subitemAtIndex:i];
                if ([item isKindOfClass:[HSSoundsLibraryiTunesPlaylist class]] && [item isVideos])
                    _moviesPlaylist = [item retain];
            }
        }
        [provider release];
    }
    return _moviesPlaylist;
}

- (id)currentMediaPathsLocation
{
    return [[self moviesPlaylist] displayName];
}

- (id)createMediaPathsForKey:(id)aKey
{
    if (![aKey isEqualToString:[[self moviesPlaylist] displayName]])
        return nil;
    HSSoundsLibraryiTunesPlaylist *playlist = [self moviesPlaylist];
    if (playlist == nil)
        return nil;
    NSInteger count = [playlist numberOfSongs];
    NSMutableArray *paths = [NSMutableArray array];
    for (NSInteger i = 0; i < count; i++) {
        if ([[playlist songAtIndex:i] hasAccessibleURL]) {
            NSString *path = [[[playlist songAtIndex:i] URL] path];
            if (path != nil)
                [paths addObject:path];
        }
    }
    return paths;
}

- (id)paneTitle
{
    return [[NSBundle bundleForClass:[self class]] localizedStringForKey:@"ImportDialogSoundiTunesPaneTitle" value:@"" table:@"ImportDialogs"];
}

- (NSInteger)paneWeight
{
    return 2;
}

- (id)paneView
{
    if (_paneView == nil)
        [NSBundle loadNibNamed:[self paneViewNibName] owner:self];
    return _paneView;
}

- (id)paneIdentifier
{
    return @"HSImportDialogiTunesMovies";
}

- (id)paneViewNibName
{
    return @"IDMoviesiTunesPaneView";
}

- (void)dealloc
{
    [_moviesPlaylist release];
    [super dealloc];
}

@end
