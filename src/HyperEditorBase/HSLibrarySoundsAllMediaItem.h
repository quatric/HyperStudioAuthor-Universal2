#import "HyperEditorBasePrefix.h"


@interface HSLibrarySoundsAllMediaItem : NSObject <HSLibraryMediaItem, NSObject, HSLibraryMediaDataFolder, HSLibraryMediaDataItem>
{
    NSMutableArray *_children;
    NSMutableArray *_subItems;
    NSArray *_paths;
    NSImage *_iconImage;
}
- (id)subItems;
- (id)childrenItems;
- (id)filterSounds:(id)aSounds byCategory:(id)aCategory;
- (id)soundAtIndex:(NSUInteger)aIndex;
- (NSInteger)numberOfSounds;
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
- (id)initWithPaths:(id)aPaths;
@end

