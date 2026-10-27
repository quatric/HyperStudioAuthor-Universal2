#import "HyperPlayerBasePrefix.h"


@interface HSIndexPath : NSObject <NSCopying, NSCoding>
{
    unsigned int *_indexes;
    unsigned int _length;
}
+ (id)indexPathWithSubpaths:(unsigned int **)aSubpaths lengths:(unsigned int *)aLengths count:(NSUInteger)aCount;
+ (id)indexPathWithIndexes:(unsigned int *)aIndexes length:(NSUInteger)aLength;
+ (id)indexPathWithIndex:(NSUInteger)aIndex;
- (id)description;
- (NSInteger)compare:(id)aCompare;
- (NSUInteger)hash;
- (BOOL)isEqual:(id)aEqual;
- (void)getIndexes:(unsigned int *)aIndexes;
- (NSUInteger)length;
- (NSUInteger)indexAtPosition:(NSUInteger)aPosition;
- (id)indexPathByReplacingIndexAtPosition:(NSUInteger)aPosition withIndex:(NSUInteger)aIndex;
- (id)indexPathByRemovingLastIndex;
- (id)indexPathByAddingIndex:(NSUInteger)aIndex;
- (id)copyWithZone:(NSZone *)aZone;
- (id)initWithCoder:(id)aCoder;
- (void)encodeWithCoder:(id)aCoder;
- (void)dealloc;
- (id)initWithIndexSubpaths:(unsigned int **)aSubpaths lengths:(unsigned int *)aLengths count:(NSUInteger)aCount;
- (id)initWithIndexes:(unsigned int *)aIndexes length:(NSUInteger)aLength;
- (id)initWithIndex:(NSUInteger)aIndex;
- (id)init;
@end

