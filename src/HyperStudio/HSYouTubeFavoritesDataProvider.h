#import "HyperStudioPrefix.h"


@interface HSYouTubeFavoritesDataProvider : NSObject <HSYouTubeDataProviderInterface, NSObject>
{
    NSMutableArray *_dataItems;
    NSMutableArray *_findedItems;
}
+ (id)allocWithZone:(NSZone *)aZone;
+ (id)sharedYouTubeFavoritesDataProvider;
- (id)autorelease;
- (void)release;
- (NSUInteger)retainCount;
- (id)retain;
- (id)copyWithZone:(NSZone *)aZone;
- (id)init;
- (void)dealloc;
- (void)synchronize;
- (void)provideDataItemsForSearchString:(id)aString;
- (void)removeItemAtIndex:(NSUInteger)aIndex;
- (void)addItem:(id)aItem;
- (id)dataValueForIndex:(NSUInteger)aIndex valueCondition:(id)aCondition;
- (NSUInteger)numberOfDataItems;
- (id)visibleDataItems;
@end

