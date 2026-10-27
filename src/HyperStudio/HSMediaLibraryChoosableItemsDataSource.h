#import "HyperStudioPrefix.h"


@interface HSMediaLibraryChoosableItemsDataSource : NSObject <HSChooserDataSource>
{
    NSMutableArray *_mediaURLs;
    NSMutableDictionary *_medias;
    NSString *_mediaType;
    NSString *_mediaFolderPath;
    id<HSLibraryMediaDataFolder> _mediaDataFolder;
}
+ (id)defaultPathToMediaFolder;
+ (id)defaultMediaType;
- (void)updateChoosableItemsIfNeeded;
- (id)URLForChoosableItemAtIndex:(NSUInteger)aIndex;
- (id)mediaForChoosableItemAtIndex:(NSUInteger)aIndex;
- (id)labelForChoosableItemAtIndex:(NSUInteger)aIndex;
- (NSUInteger)countOfChoosableItems;
- (id)mediaURLs;
- (void)addItemsFromMediaDataFolder:(id)aFolder;
- (id)mediaData;
- (id)mediaDataProvider;
- (id)mediaDataFolder;
- (void)setPathToMediaFolder:(id)aFolder;
- (id)pathToMediaFolder;
- (id)mediaType;
- (void)setMediaType:(id)aType;
- (id)mediaDataFolderAtPath:(id)aPath;
- (void)dealloc;
@end

