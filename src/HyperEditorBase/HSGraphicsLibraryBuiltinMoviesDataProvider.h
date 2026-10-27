#import "HyperEditorBasePrefix.h"


@interface HSGraphicsLibraryBuiltinMoviesDataProvider : NSObject <HSLibraryMediaDataProvider, NSObject, HSLibraryMediaItem, HSLibraryMediaFiltering, HSLibraryMediaUserInterface, HSLibraryMediaData, HSLibraryMediaDataFolder, HSLibraryMediaDataItem, HSLibraryUserMediaData>
{
    NSImage *_medidIcon;
    NSMutableArray *_rootItems;
}
+ (NSInteger)defaultSortOrder;
+ (void)setDefaultSortOrder:(NSInteger)aOrder;
- (id)dataForDescription:(id)aDescription;
- (id)dataForURL:(id)aURL;
- (id)descriptionForData:(id)aData;
- (id)fileURLForData:(id)aData;
- (id)displayNameForData:(id)aData;
- (id)identifierImage;
- (id)identifierImageForData:(id)aData;
- (id)previewImageForData:(id)aData;
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
- (id)rootItems;
- (id)builtinMoviesFolders;
- (void)dealloc;
@end

