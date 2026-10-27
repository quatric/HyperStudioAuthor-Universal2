#import "HyperStudioPrefix.h"


@interface HSFileChoosableItemDataSource : NSObject <HSChooserDataSource>
{
    NSString *_path;
    HSNewMedia *_media;
    BOOL _isPathChanged;
}
- (void)updateChoosableItemsIfNeeded;
- (id)URLForChoosableItemAtIndex:(NSUInteger)aIndex;
- (id)labelForChoosableItemAtIndex:(NSUInteger)aIndex;
- (id)mediaForChoosableItemAtIndex:(NSUInteger)aIndex;
- (NSUInteger)countOfChoosableItems;
- (id)media;
- (id)path;
- (void)setPath:(id)aPath;
- (void)dealloc;
- (id)initWithPath:(id)aPath;
@end

