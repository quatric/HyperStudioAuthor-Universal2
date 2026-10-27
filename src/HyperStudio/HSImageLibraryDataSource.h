#import "HyperStudioPrefix.h"


@interface HSImageLibraryDataSource : NSObject <HSChooserDataSource>
{
    NSMutableArray *_items;
    NSArray *_itemsNames;
}
+ (id)allocWithZone:(NSZone *)aZone;
+ (id)sharedImageLibraryDataSource;
- (void)updateChoosableItemsIfNeeded;
- (id)URLForChoosableItemAtIndex:(NSUInteger)aIndex;
- (id)labelForChoosableItemAtIndex:(NSUInteger)aIndex;
- (id)mediaForChoosableItemAtIndex:(NSUInteger)aIndex;
- (NSUInteger)countOfChoosableItems;
- (id)items;
- (id)itemsNames;
- (id)mediaForImageWithName:(id)aName;
- (id)autorelease;
- (void)release;
- (NSUInteger)retainCount;
- (id)retain;
- (id)copyWithZone:(NSZone *)aZone;
@end

