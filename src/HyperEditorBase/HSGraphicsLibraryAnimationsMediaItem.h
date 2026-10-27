#import "HyperEditorBasePrefix.h"


@interface HSGraphicsLibraryAnimationsMediaItem : NSObject <HSLibraryMediaItem, NSObject, HSLibraryMediaDataFolder, HSLibraryMediaDataItem, NSCopying>
{
    NSMutableArray *_children;
    NSMutableArray *_subItems;
    HSGraphicsLibraryBuiltinMoviesDataProvider *_dataProvider;
    NSString *_path;
    NSImage *_folderImage;
}
- (id)filterPictures:(id)aPictures byCategory:(id)aCategory;
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
- (id)animationAtIndex:(NSUInteger)aIndex;
- (NSInteger)numberOfAnimations;
- (id)childrenItems;
- (id)subItems;
- (id)folderImage;
- (void)dealloc;
- (id)copyWithZone:(NSZone *)aZone;
- (id)initWithProvider:(id)aProvider path:(id)aPath;
@end

