#import "HyperEditorBasePrefix.h"


@interface HSLibraryPicturesDataProvider : NSObject <HSLibraryMediaDataProvider, NSObject, HSLibraryMediaItem, HSLibraryUserMediaData, HSLibraryMediaUserInterface, HSLibraryMediaFiltering, HSLibraryMediaData, HSLibraryMediaDataItem, HSLibraryMediaDataFolder>
{
    NSMutableArray *_rootItems;
    NSImage *_iconImage;
}
+ (id)providerMediaType;
+ (NSInteger)defaultSortOrder;
+ (void)setDefaultSortOrder:(NSInteger)aOrder;
- (id)rootItems;
- (id)dataFolderAtIndex:(NSUInteger)aIndex;
- (NSUInteger)numberOfDataFolders;
- (id)dataItemAtIndex:(NSUInteger)aIndex;
- (NSUInteger)numberOfDataItems;
- (id)dataDisplayName;
- (id)dataURL;
- (id)rootDataFolder;
- (id)displayStringForCategory:(id)aCategory;
- (id)searchCategories;
- (id)mediaDisplayName;
- (id)mediaIcon;
- (id)rootItem;
- (id)dataForDescription:(id)aDescription;
- (id)dataForURL:(id)aURL;
- (id)descriptionForData:(id)aData;
- (id)fileURLForData:(id)aData;
- (id)displayNameForData:(id)aData;
- (id)identifierImage;
- (id)identifierImageForData:(id)aData;
- (id)previewImageForData:(id)aData;
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

