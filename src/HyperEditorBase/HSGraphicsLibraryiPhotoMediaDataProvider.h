#import "HyperEditorBasePrefix.h"


@interface HSGraphicsLibraryiPhotoMediaDataProvider : NSObject <HSLibraryMediaDataProvider, NSObject, HSLibraryMediaItem, HSLibraryMediaFiltering, HSLibraryMediaUserInterface, HSLibraryMediaData, HSLibraryMediaDataFolder, HSLibraryMediaDataItem>
{
    NSMutableDictionary *_photos;
    NSMutableArray *_albums;
    NSMutableDictionary *_modificationTimes;
}
+ (NSInteger)defaultSortOrder;
+ (void)setDefaultSortOrder:(NSInteger)aOrder;
- (id)modificationTimes;
- (void)initializeWithLibraries:(id)aLibraries;
- (void)initializeWithLibraryFiles:(id)aFiles;
- (id)updateLibrary:(id)aLibrary withMajorVersion:(NSInteger)aVersion;
- (id)displayStringForCategory:(id)aCategory;
- (id)searchCategories;
- (id)rootDataFolder;
- (id)dataFolderAtIndex:(NSUInteger)aIndex;
- (NSUInteger)numberOfDataFolders;
- (id)dataItemAtIndex:(NSUInteger)aIndex;
- (NSUInteger)numberOfDataItems;
- (id)dataDisplayName;
- (id)dataURL;
- (id)mediaDisplayName;
- (id)mediaIcon;
- (id)rootItem;
- (id)subitemAtIndex:(NSUInteger)aIndex;
- (NSUInteger)numberOfSubitems;
- (id)actionTarget;
- (SEL)actionSelector;
- (id)actionImage;
- (id)displayName;
- (id)icon;
- (id)queryInterface:(id)aInterface;
- (BOOL)isPlayable;
- (BOOL)supportedData:(id)aData error:(id *)aError;
- (BOOL)supportedData:(id)aData;
- (id)providerType;
- (id)mediaType;
- (BOOL)sourceApplicationPresents;
- (void)dealloc;
@end

