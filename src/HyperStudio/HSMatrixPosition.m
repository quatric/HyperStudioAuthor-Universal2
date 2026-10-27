#import "HSMatrixPosition.h"

@implementation HSMatrixPosition

+ (id)positionWithRow:(NSInteger)aRow column:(NSInteger)aColumn
{
    return [[[HSMatrixPosition alloc] initWithRow:aRow column:aColumn] autorelease];
}

- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    return [NSArray arrayWithObjects:@"row", @"column", nil];
}

- (id)initWithCoder:(id)aCoder
{
    return [self initWithRow:[aCoder decodeIntForKey:@"row"] column:[aCoder decodeIntForKey:@"column"]];
}

- (void)encodeWithCoder:(id)aCoder
{
    [aCoder encodeInt:(int)[self row] forKey:@"row"];
    [aCoder encodeInt:(int)[self column] forKey:@"column"];
}

- (id)copyWithZone:(NSZone *)aZone
{
    HSMatrixPosition *copy = [[[self class] allocWithZone:aZone] init];
    [copy setRow:[self row]];
    [copy setColumn:[self column]];
    return copy;
}

- (BOOL)isEqual:(id)aEqual
{
    if (![aEqual isMemberOfClass:[self class]])
        return NO;
    return [(HSMatrixPosition *)aEqual row] == [self row] && [(HSMatrixPosition *)aEqual column] == [self column];
}

- (NSUInteger)hash
{
    return (NSUInteger)(_row << 16 | _column);
}

- (id)stringRepresentation
{
    return [NSString stringWithFormat:@"%d:%d", _row, _column];
}

- (void)setColumn:(NSInteger)aColumn
{
    if (_column != aColumn)
        _column = (int)aColumn;
}

- (NSInteger)column
{
    return _column;
}

- (void)setRow:(NSInteger)aRow
{
    if (_row != aRow)
        _row = (int)aRow;
}

- (NSInteger)row
{
    return _row;
}

- (id)initWithRow:(NSInteger)aRow column:(NSInteger)aColumn
{
    self = [super init];
    if (self != nil) {
        _row = (int)aRow;
        _column = (int)aColumn;
    }
    return self;
}

@end
