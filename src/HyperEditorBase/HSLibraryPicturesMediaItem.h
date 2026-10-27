#import "HyperEditorBasePrefix.h"


@interface HSLibraryPicturesMediaItem : NSObject <NSCopying, HSLibraryMediaItem, NSObject, HSLibraryMediaDataFolder, HSLibraryMediaDataItem>
{
    NSMutableArray *_children;
    NSMutableArray *_subItems;
    HSLibraryPicturesDataProvider *_dataProvider;
    NSString *_path;
    NSImage *_folderImage;
}
- (id)copyWithZone:(NSZone *)aZone;
- (id)folderImage;
- (id)subItems;
- (id)childrenItems;
- (id)filterPictures:(id)aPictures byCategory:(id)aCategory;
- (id)pictureAtIndex:(NSUInteger)aIndex;
- (NSInteger)numberOfPictures;
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
- (id)initWithProvider:(id)aProvider path:(id)aPath;
@end

