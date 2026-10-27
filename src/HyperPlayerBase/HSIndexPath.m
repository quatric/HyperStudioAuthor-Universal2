#import "HSIndexPath.h"

@implementation HSIndexPath
+ (id)indexPathWithSubpaths:(unsigned int **)aSubpaths lengths:(unsigned int *)aLengths count:(NSUInteger)aCount
{
    return [[[self alloc] initWithIndexSubpaths:aSubpaths lengths:aLengths count:aCount] autorelease];
}
+ (id)indexPathWithIndexes:(unsigned int *)aIndexes length:(NSUInteger)aLength
{
    return [[[self alloc] initWithIndexes:aIndexes length:aLength] autorelease];
}
+ (id)indexPathWithIndex:(NSUInteger)aIndex
{
    return [[[self alloc] initWithIndex:aIndex] autorelease];
}
- (id)description
{
    NSString *indexes = @"";
    if (_length) {
        indexes = [NSString stringWithFormat:@"%u", _indexes[0]];
        unsigned int i;
        for (i = 1; i < _length; i++)
            indexes = [indexes stringByAppendingFormat:@", %u", _indexes[i]];
    }
    return [NSString stringWithFormat:@"%@ (0x%x): length %u, indexes [%@]", [self class], (unsigned int)(uintptr_t)self, _length, indexes];
}
// Lexicographic, a prefix sorting first.
- (NSInteger)compare:(id)aCompare
{
    HSIndexPath *other = aCompare;
    unsigned int i;
    for (i = 0; i < _length && i < other->_length; i++) {
        if (_indexes[i] < other->_indexes[i])
            return NSOrderedAscending;
        if (_indexes[i] > other->_indexes[i])
            return NSOrderedDescending;
    }
    if (_length < other->_length)
        return NSOrderedAscending;
    return _length > other->_length ? NSOrderedDescending : NSOrderedSame;
}
- (NSUInteger)hash
{
    return _length;
}
// A subclass instance decides equality itself. The original compared only
// _length bytes of the indexes; all of them are compared here.
- (BOOL)isEqual:(id)aEqual
{
    if (aEqual == self)
        return YES;
    if (![aEqual isKindOfClass:[HSIndexPath class]])
        return NO;
    if ([aEqual isKindOfClass:[self class]] && ![aEqual isMemberOfClass:[self class]])
        return [aEqual isEqual:self];
    HSIndexPath *other = aEqual;
    if (other->_length != _length)
        return NO;
    return memcmp(other->_indexes, _indexes, _length * sizeof(unsigned int)) == 0;
}
- (void)getIndexes:(unsigned int *)aIndexes
{
    memcpy(aIndexes, _indexes, _length * sizeof(unsigned int));
}
- (NSUInteger)length
{
    return _length;
}
- (NSUInteger)indexAtPosition:(NSUInteger)aPosition
{
    return _indexes[aPosition];
}
- (id)indexPathByReplacingIndexAtPosition:(NSUInteger)aPosition withIndex:(NSUInteger)aIndex
{
    unsigned int index = (unsigned int)aIndex;
    unsigned int *subpaths[3] = {_indexes, &index, _indexes + aPosition + 1};
    unsigned int lengths[3] = {(unsigned int)aPosition, 1, _length - (unsigned int)aPosition - 1};
    return [[[[self class] allocWithZone:[self zone]] initWithIndexSubpaths:subpaths lengths:lengths count:3] autorelease];
}
- (id)indexPathByRemovingLastIndex
{
    return [[[[self class] allocWithZone:[self zone]] initWithIndexes:_indexes length:_length - 1] autorelease];
}
- (id)indexPathByAddingIndex:(NSUInteger)aIndex
{
    unsigned int index = (unsigned int)aIndex;
    unsigned int *subpaths[2] = {_indexes, &index};
    unsigned int lengths[2] = {_length, 1};
    return [[[[self class] allocWithZone:[self zone]] initWithIndexSubpaths:subpaths lengths:lengths count:2] autorelease];
}
- (id)copyWithZone:(NSZone *)aZone
{
    return [self retain];
}
- (id)initWithCoder:(id)aCoder
{
    self = [super init];
    if (self) {
        [aCoder decodeValueOfObjCType:"I" at:&_length];
        _indexes = malloc(_length * sizeof(unsigned int));
        if (!_indexes) {
            [self release];
            return nil;
        }
        unsigned int i;
        for (i = 0; i < _length; i++)
            [aCoder decodeValueOfObjCType:"I" at:&_indexes[i]];
    }
    return self;
}
- (void)encodeWithCoder:(id)aCoder
{
    [aCoder encodeValueOfObjCType:"I" at:&_length];
    unsigned int i;
    for (i = 0; i < _length; i++)
        [aCoder encodeValueOfObjCType:"I" at:&_indexes[i]];
}
- (void)dealloc
{
    if (_indexes)
        free(_indexes);
    [super dealloc];
}
// Concatenates the subpaths.
- (id)initWithIndexSubpaths:(unsigned int **)aSubpaths lengths:(unsigned int *)aLengths count:(NSUInteger)aCount
{
    self = [super init];
    if (self) {
        NSUInteger i;
        for (i = 0; i < aCount; i++)
            _length += aLengths[i];
        if (_length) {
            _indexes = malloc(_length * sizeof(unsigned int));
            if (!_indexes) {
                [self release];
                return nil;
            }
            unsigned int *destination = _indexes;
            for (i = 0; i < aCount; i++) {
                memcpy(destination, aSubpaths[i], aLengths[i] * sizeof(unsigned int));
                destination += aLengths[i];
            }
        }
    }
    return self;
}
- (id)initWithIndexes:(unsigned int *)aIndexes length:(NSUInteger)aLength
{
    unsigned int length = (unsigned int)aLength;
    return [self initWithIndexSubpaths:&aIndexes lengths:&length count:1];
}
- (id)initWithIndex:(NSUInteger)aIndex
{
    unsigned int index = (unsigned int)aIndex;
    return [self initWithIndexes:&index length:1];
}
- (id)init
{
    return [self initWithIndexes:NULL length:0];
}
@end
