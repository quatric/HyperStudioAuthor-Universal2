#import "HyperEditorBasePrefix.h"


@interface HSSoundsLibraryiTunesMediaDataProvider : NSObject <HSLibraryMediaDataProvider, NSObject, HSLibraryMediaItem, HSLibraryMediaFiltering, HSLibraryMediaUserInterface, HSLibraryMediaData, HSLibraryMediaDataFolder, HSLibraryMediaDataItem>
{
    NSMutableDictionary *_tracks;
    NSMutableArray *_playlists;
    NSMutableDictionary *_modificationTimes;
}
+ (NSInteger)defaultSortOrder;
+ (void)setDefaultSortOrder:(NSInteger)aOrder;
- (id)modificationTimes;
- (void)initializeWithLibraries:(id)aLibraries;
- (void)initializeWithLibraryFiles:(id)aFiles;
- (id)updateLibrary:(id)aLibrary;
- (id)dataFolderAtIndex:(NSUInteger)aIndex;
- (NSUInteger)numberOfDataFolders;
- (id)dataItemAtIndex:(NSUInteger)aIndex;
- (NSUInteger)numberOfDataItems;
- (id)dataDisplayName;
- (id)dataURL;
- (id)rootDataFolder;
- (id)mediaDisplayName;
- (id)mediaIcon;
- (id)rootItem;
- (id)displayStringForCategory:(id)aCategory;
- (id)searchCategories;
- (id)subitemAtIndex:(NSUInteger)aIndex;
- (NSUInteger)numberOfSubitems;
- (id)actionTarget;
- (SEL)actionSelector;
- (id)actionImage;
- (id)displayName;
- (id)icon;
- (id)queryInterface:(id)aInterface;
- (BOOL)isPlayable;
- (BOOL)supportedData:(id)aData;
- (BOOL)supportedData:(id)aData error:(id *)aError;
- (id)providerType;
- (id)mediaType;
- (BOOL)sourceApplicationPresents;
- (void)dealloc;
@end

