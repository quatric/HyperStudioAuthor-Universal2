#import "HyperStudioPrefix.h"


@interface HSFolderImagesDataSource : NSObject <HSChooserDataSource>
{
    NSMutableArray *_medias;
    NSString *_path;
}
+ (id)defaultPath;
- (void)updateChoosableItemsIfNeeded;
- (id)URLForChoosableItemAtIndex:(NSUInteger)aIndex;
- (id)labelForChoosableItemAtIndex:(NSUInteger)aIndex;
- (id)mediaForChoosableItemAtIndex:(NSUInteger)aIndex;
- (NSUInteger)countOfChoosableItems;
- (void)setPath:(id)aPath;
- (id)path;
- (void)mediaUIDsWillRemoveFromMediaAccessor:(id)aAccessor;
- (void)updateMedias;
- (id)medias;
- (void)dealloc;
@end

