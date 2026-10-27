#import "SMKBitmapToolsPrefix.h"


@interface BTDataArray : NSObject <NSCopying, NSMutableCopying>
{
}
- (id)mutableCopyWithZone:(NSZone *)aZone;
- (id)copyWithZone:(NSZone *)aZone;
- (void *)bytesOfItemAtIndex:(NSUInteger)aIndex;
- (NSUInteger)itemSize;
- (NSUInteger)count;
@end

@interface BTMutableDataArray : BTDataArray
{
}
- (void *)mutableBytesOfItemAtIndex:(NSUInteger)aIndex;
- (void)setCount:(NSUInteger)aCount;
@end

@interface BTAbstractClustersDataArray : BTMutableDataArray
{
    NSUInteger _itemSize;
    NSUInteger _count;
    NSUInteger _firstClusterSize;
    NSUInteger _generalClusterSize;
}
+ (NSUInteger)calculateOptimalClasterSizeForItemSize:(NSUInteger)aSize;
- (NSUInteger)clustersCountToStoreItemsCount:(NSUInteger)aCount;
- (BOOL)getClusterIndex:(NSUInteger *)aIndex bytesOffset:(NSUInteger *)aOffset forItemIndex:(NSUInteger)aIndex2;
- (NSUInteger)itemSize;
- (NSUInteger)count;
- (id)initWithFirstClusterSize:(NSUInteger)aSize generalClusterSize:(NSUInteger)aSize2 itemSize:(NSUInteger)aSize3 count:(NSUInteger)aCount;
- (id)init;
@end

@interface BTClustersMutableDataArray : BTAbstractClustersDataArray <BTClustersDataArrayInitializerProtocol, BTMutableClustersDataArrayProtocol>
{
    NSMutableArray *_clustersArray;
}
- (id)mutableCopyWithZone:(NSZone *)aZone;
- (id)copyWithZone:(NSZone *)aZone;
- (void *)mutableBytesOfItemAtIndex:(NSUInteger)aIndex;
- (void *)bytesOfItemAtIndex:(NSUInteger)aIndex;
- (void)setCount:(NSUInteger)aCount;
- (id)initWithClusters:(id)aClusters firstClusterSize:(NSUInteger)aSize generalClusterSize:(NSUInteger)aSize2 itemSize:(NSUInteger)aSize3 count:(NSUInteger)aCount;
- (id)initWithData:(id)aData itemSize:(NSUInteger)aSize count:(NSUInteger)aCount;
- (void)dealloc;
@end

@interface BTClustersDataArray : BTAbstractClustersDataArray <BTClustersDataArrayInitializerProtocol>
{
    NSArray *_clustersArray;
}
- (id)mutableCopyWithZone:(NSZone *)aZone;
- (id)copyWithZone:(NSZone *)aZone;
- (void *)bytesOfItemAtIndex:(NSUInteger)aIndex;
- (id)initWithClusters:(id)aClusters firstClusterSize:(NSUInteger)aSize generalClusterSize:(NSUInteger)aSize2 itemSize:(NSUInteger)aSize3 count:(NSUInteger)aCount;
- (id)initWithData:(id)aData itemSize:(NSUInteger)aSize count:(NSUInteger)aCount;
- (void)dealloc;
@end

@interface BTMutableDataArray (BTMutableDataArrayCreationPrivate)
- (id)BTMutableDataArray_init;
@end

@interface BTMutableDataArray (BTMutableDataArrayCreation)
+ (id)arrayWithCount:(NSUInteger)aCount itemSize:(NSUInteger)aSize;
- (id)initWithCount:(NSUInteger)aCount itemSize:(NSUInteger)aSize;
- (id)init;
@end

@interface BTMutableDataArray (BTMutableDataEditing)
- (void)addItemBytes:(void *)aBytes;
@end

@interface BTDataArray (BTDataArrayCreation)
+ (id)arrayWithData:(id)aData itemSize:(NSUInteger)aSize count:(NSUInteger)aCount;
- (id)initWithData:(id)aData itemSize:(NSUInteger)aSize count:(NSUInteger)aCount;
@end

@interface BTDataArray (BTExtendedDataArray)
- (void *)bytesOfLastItem;
- (id)itemsDataInRange:(NSRange)aRange;
- (id)allItemsData;
@end

