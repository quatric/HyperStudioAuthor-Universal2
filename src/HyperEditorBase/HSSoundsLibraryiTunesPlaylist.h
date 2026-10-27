#import "HyperEditorBasePrefix.h"


@interface HSSoundsLibraryiTunesPlaylist : NSObject <HSLibraryMediaItem, NSObject, HSLibraryMediaDataFolder, HSLibraryMediaDataItem>
{
    NSMutableArray *_tracks;
    NSDictionary *_info;
    NSImage *_masterPlaylistImage;
    NSImage *_userPlaylistImage;
    NSImage *_iTunesPlaylistImage;
    NSImage *_iTunesPartyShuffleImage;
    NSImage *_iTunesVideosImage;
    NSImage *_iTunesPodcastsImage;
    NSImage *_iTunesFolderImage;
}
+ (id)searchCategories;
- (BOOL)isFolder;
- (BOOL)isPodcasts;
- (BOOL)isVideos;
- (BOOL)isPartyShuffle;
- (BOOL)hasSmartInfo;
- (NSInteger)compareDecrease:(id)aDecrease;
- (NSInteger)compareIncrease:(id)aIncrease;
- (id)filterTracks:(id)aTracks byCategory:(id)aCategory;
- (BOOL)isMaster;
- (NSInteger)sortWeight;
- (id)songAtIndex:(NSUInteger)aIndex;
- (NSInteger)numberOfSongs;
- (id)dataDisplayName;
- (id)dataURL;
- (id)dataFolderAtIndex:(NSUInteger)aIndex;
- (NSUInteger)numberOfDataFolders;
- (id)dataItemAtIndex:(NSUInteger)aIndex;
- (NSUInteger)numberOfDataItems;
- (id)subitemAtIndex:(NSUInteger)aIndex;
- (NSUInteger)numberOfSubitems;
- (id)actionTarget;
- (SEL)actionSelector;
- (id)actionImage;
- (id)displayName;
- (id)icon;
- (void)dealloc;
- (id)initWithDictionaryRepresentation:(id)aRepresentation tracks:(id)aTracks;
- (id)init;
@end

