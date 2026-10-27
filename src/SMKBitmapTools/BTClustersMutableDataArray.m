#import "BTClustersMutableDataArray.h"

// Arrays of fixed-size items kept in NSData clusters, so a growing array
// never moves its items: a first cluster (of _firstClusterSize bytes, the
// initial data) and then clusters of _generalClusterSize items each.
//
// The original measured general clusters in bytes when allocating them but
// in items when locating an item in one (its offset was itemSize times the
// byte remainder), and its cluster count left out the first cluster, so an
// array grown past its first cluster indexed past the clusters. The layout
// is private (copies go through the initializers here), so it is made
// consistent: general clusters hold _generalClusterSize items.

@implementation BTDataArray

- (NSUInteger)count
{
    return 0;
}

- (NSUInteger)itemSize
{
    return 0;
}

- (void *)bytesOfItemAtIndex:(NSUInteger)aIndex
{
    return NULL;
}

- (id)copyWithZone:(NSZone *)aZone
{
    return [[[self class] allocWithZone:aZone] init];
}

- (id)mutableCopyWithZone:(NSZone *)aZone
{
    return [[BTMutableDataArray allocWithZone:aZone] init];
}

@end

@implementation BTMutableDataArray

- (void)setCount:(NSUInteger)aCount
{
}

- (void *)mutableBytesOfItemAtIndex:(NSUInteger)aIndex
{
    return NULL;
}

@end

@implementation BTAbstractClustersDataArray

// Items per general cluster: a 4 KB page's worth, at least 5.
+ (NSUInteger)calculateOptimalClasterSizeForItemSize:(NSUInteger)aSize
{
    if (!aSize)
        return 0;
    NSUInteger size = 0x1000 / aSize;
    return size < 5 ? 5 : size;
}

- (id)init
{
    return [self initWithFirstClusterSize:0
                       generalClusterSize:[[self class] calculateOptimalClasterSizeForItemSize:0]
                                 itemSize:0
                                    count:0];
}

// A zero first cluster size makes the first cluster a general one.
- (id)initWithFirstClusterSize:(NSUInteger)aSize generalClusterSize:(NSUInteger)aSize2 itemSize:(NSUInteger)aSize3 count:(NSUInteger)aCount
{
    self = [super BTMutableDataArray_init];
    if (!self)
        return nil;
    _itemSize = aSize3;
    _count = aCount;
    _firstClusterSize = aSize ? aSize : aSize2 * aSize3;
    _generalClusterSize = aSize2;
    return self;
}

- (NSUInteger)count
{
    return _count;
}

- (NSUInteger)itemSize
{
    return _itemSize;
}

- (NSUInteger)BTAbstractClustersDataArray_itemsInFirstCluster
{
    return _itemSize ? _firstClusterSize / _itemSize : 0;
}

// Including the first cluster.
- (NSUInteger)clustersCountToStoreItemsCount:(NSUInteger)aCount
{
    NSUInteger first = [self BTAbstractClustersDataArray_itemsInFirstCluster];
    if (aCount <= first || !_generalClusterSize)
        return 1;
    return 1 + (aCount - first + _generalClusterSize - 1) / _generalClusterSize;
}

- (BOOL)getClusterIndex:(NSUInteger *)aIndex bytesOffset:(NSUInteger *)aOffset forItemIndex:(NSUInteger)aIndex2
{
    if (aIndex2 >= _count)
        @throw [NSException exceptionWithName:NSRangeException reason:@"Index is out of range" userInfo:nil];
    NSUInteger first = [self BTAbstractClustersDataArray_itemsInFirstCluster];
    NSUInteger cluster, offset;
    if (aIndex2 < first) {
        cluster = 0;
        offset = aIndex2 * _itemSize;
    } else {
        if (!_generalClusterSize)
            return NO;
        NSUInteger index = aIndex2 - first;
        cluster = index / _generalClusterSize + 1;
        offset = (index % _generalClusterSize) * _itemSize;
    }
    if (aIndex)
        *aIndex = cluster;
    if (aOffset)
        *aOffset = offset;
    return YES;
}

@end

@implementation BTClustersMutableDataArray

// The initial data (copied) is the first cluster, or a general cluster when
// there is none.
- (id)initWithData:(id)aData itemSize:(NSUInteger)aSize count:(NSUInteger)aCount
{
    NSUInteger length = aCount * aSize;
    if (aData && (!length || [aData length] < length)) {
        [self release];
        return nil;
    }
    NSUInteger general = [BTAbstractClustersDataArray calculateOptimalClasterSizeForItemSize:aSize];
    NSMutableArray *clusters;
    NSUInteger first;
    if (aData) {
        clusters = [NSMutableArray arrayWithObject:aData];
        first = length;
    } else {
        first = general * aSize;
        clusters = [NSMutableArray arrayWithObject:[NSMutableData dataWithLength:first]];
    }
    return [self initWithClusters:clusters firstClusterSize:first generalClusterSize:general itemSize:aSize count:aCount];
}

- (id)initWithClusters:(id)aClusters firstClusterSize:(NSUInteger)aSize generalClusterSize:(NSUInteger)aSize2 itemSize:(NSUInteger)aSize3 count:(NSUInteger)aCount
{
    self = [super initWithFirstClusterSize:aSize generalClusterSize:aSize2 itemSize:aSize3 count:aCount];
    if (!self)
        return nil;
    _clustersArray = [[NSMutableArray alloc] initWithCapacity:[aClusters count]];
    for (NSData *cluster in aClusters)
        [_clustersArray addObject:[NSMutableData dataWithData:cluster]];
    // Enough clusters for the count.
    [self setCount:aCount];
    return self;
}

- (void)dealloc
{
    [_clustersArray release];
    [super dealloc];
}

- (void)setCount:(NSUInteger)aCount
{
    if (!aCount) {
        [_clustersArray removeAllObjects];
        _firstClusterSize = _generalClusterSize * _itemSize;
    } else {
        NSUInteger needed = [self clustersCountToStoreItemsCount:aCount];
        NSUInteger have = [_clustersArray count];
        if (needed < have)
            [_clustersArray removeObjectsInRange:NSMakeRange(needed, have - needed)];
        else
            for (; have < needed; have++)
                [_clustersArray addObject:[NSMutableData dataWithLength:have ? _generalClusterSize * _itemSize
                                                                             : _firstClusterSize]];
    }
    _count = aCount;
}

- (void *)bytesOfItemAtIndex:(NSUInteger)aIndex
{
    NSUInteger cluster = 0, offset = 0;
    if (![super getClusterIndex:&cluster bytesOffset:&offset forItemIndex:aIndex])
        return NULL;
    return (char *)[[_clustersArray objectAtIndex:cluster] bytes] + offset;
}

- (void *)mutableBytesOfItemAtIndex:(NSUInteger)aIndex
{
    NSUInteger cluster = 0, offset = 0;
    if (![super getClusterIndex:&cluster bytesOffset:&offset forItemIndex:aIndex])
        return NULL;
    return (char *)[[_clustersArray objectAtIndex:cluster] mutableBytes] + offset;
}

- (id)copyWithZone:(NSZone *)aZone
{
    NSMutableArray *clusters = [NSMutableArray arrayWithCapacity:[_clustersArray count]];
    for (NSData *cluster in _clustersArray)
        [clusters addObject:[NSData dataWithData:cluster]];
    return [[BTClustersDataArray allocWithZone:aZone] initWithClusters:clusters
                                                      firstClusterSize:_firstClusterSize
                                                    generalClusterSize:_generalClusterSize
                                                              itemSize:_itemSize
                                                                 count:_count];
}

- (id)mutableCopyWithZone:(NSZone *)aZone
{
    return [[[self class] allocWithZone:aZone] initWithClusters:_clustersArray
                                               firstClusterSize:_firstClusterSize
                                             generalClusterSize:_generalClusterSize
                                                       itemSize:_itemSize
                                                          count:_count];
}

@end

@implementation BTClustersDataArray

- (id)initWithData:(id)aData itemSize:(NSUInteger)aSize count:(NSUInteger)aCount
{
    NSUInteger length = aCount * aSize;
    if (!aData || !length || [aData length] < length) {
        [self release];
        return nil;
    }
    return [self initWithClusters:[NSArray arrayWithObject:aData]
                 firstClusterSize:length
               generalClusterSize:[BTAbstractClustersDataArray calculateOptimalClasterSizeForItemSize:aSize]
                         itemSize:aSize
                            count:aCount];
}

// Keeps the (immutable) clusters.
- (id)initWithClusters:(id)aClusters firstClusterSize:(NSUInteger)aSize generalClusterSize:(NSUInteger)aSize2 itemSize:(NSUInteger)aSize3 count:(NSUInteger)aCount
{
    if (!aClusters) {
        [self release];
        return nil;
    }
    self = [super initWithFirstClusterSize:aSize generalClusterSize:aSize2 itemSize:aSize3 count:aCount];
    if (!self)
        return nil;
    _clustersArray = [aClusters retain];
    return self;
}

- (void)dealloc
{
    [_clustersArray release];
    [super dealloc];
}

- (void *)bytesOfItemAtIndex:(NSUInteger)aIndex
{
    NSUInteger cluster = 0, offset = 0;
    if (![super getClusterIndex:&cluster bytesOffset:&offset forItemIndex:aIndex])
        return NULL;
    return (char *)[[_clustersArray objectAtIndex:cluster] bytes] + offset;
}

- (id)copyWithZone:(NSZone *)aZone
{
    return [[[self class] allocWithZone:aZone] initWithClusters:_clustersArray
                                               firstClusterSize:_firstClusterSize
                                             generalClusterSize:_generalClusterSize
                                                       itemSize:_itemSize
                                                          count:_count];
}

// The original allocated an abstract BTMutableDataArray here (which does not
// take these arguments).
- (id)mutableCopyWithZone:(NSZone *)aZone
{
    return [[BTClustersMutableDataArray allocWithZone:aZone] initWithClusters:_clustersArray
                                                             firstClusterSize:_firstClusterSize
                                                           generalClusterSize:_generalClusterSize
                                                                     itemSize:_itemSize
                                                                        count:_count];
}

@end

@implementation BTMutableDataArray (BTMutableDataArrayCreationPrivate)

- (id)BTMutableDataArray_init
{
    return [super init];
}

@end

@implementation BTMutableDataArray (BTMutableDataArrayCreation)

+ (id)arrayWithCount:(NSUInteger)aCount itemSize:(NSUInteger)aSize
{
    return [[[self alloc] initWithCount:aCount itemSize:aSize] autorelease];
}

- (id)initWithCount:(NSUInteger)aCount itemSize:(NSUInteger)aSize
{
    [self release];
    return [[BTClustersMutableDataArray alloc] initWithData:nil itemSize:aSize count:aCount];
}

- (id)init
{
    @throw [NSException exceptionWithName:@"BTDataArrayInvalidInitializer" reason:@"Invalid initializer" userInfo:nil];
}

@end

@implementation BTMutableDataArray (BTMutableDataEditing)

- (void)addItemBytes:(void *)aBytes
{
    NSUInteger count = [self count];
    [self setCount:count + 1];
    void *bytes = [self mutableBytesOfItemAtIndex:count];
    if (bytes)
        memcpy(bytes, aBytes, [self itemSize]);
}

@end

@implementation BTDataArray (BTDataArrayCreation)

+ (id)arrayWithData:(id)aData itemSize:(NSUInteger)aSize count:(NSUInteger)aCount
{
    return [[[self alloc] initWithData:aData itemSize:aSize count:aCount] autorelease];
}

- (id)initWithData:(id)aData itemSize:(NSUInteger)aSize count:(NSUInteger)aCount
{
    [self release];
    return [[BTClustersDataArray alloc] initWithData:aData itemSize:aSize count:aCount];
}

@end

@implementation BTDataArray (BTExtendedDataArray)

- (void *)bytesOfLastItem
{
    return [self bytesOfItemAtIndex:[self count] - 1];
}

- (id)itemsDataInRange:(NSRange)aRange
{
    NSUInteger size = [self itemSize];
    NSMutableData *data = [NSMutableData dataWithLength:size * aRange.length];
    if (data) {
        char *bytes = [data mutableBytes];
        for (NSUInteger i = aRange.location; i < NSMaxRange(aRange); i++, bytes += size)
            memcpy(bytes, [self bytesOfItemAtIndex:i], size);
    }
    return data;
}

- (id)allItemsData
{
    return [self itemsDataInRange:NSMakeRange(0, [self count])];
}

@end
