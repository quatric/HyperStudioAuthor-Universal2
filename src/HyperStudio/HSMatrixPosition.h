#import "HyperStudioPrefix.h"


@interface HSMatrixPosition : NSObject <NSCopying, NSCoding, EXKeyValueCoding>
{
    int _row;
    int _column;
}
+ (id)positionWithRow:(NSInteger)aRow column:(NSInteger)aColumn;
- (id)keysForExtraStoringWithCodingContext:(id)aContext;
- (id)initWithCoder:(id)aCoder;
- (void)encodeWithCoder:(id)aCoder;
- (id)copyWithZone:(NSZone *)aZone;
- (BOOL)isEqual:(id)aEqual;
- (NSUInteger)hash;
- (id)stringRepresentation;
- (void)setColumn:(NSInteger)aColumn;
- (NSInteger)column;
- (void)setRow:(NSInteger)aRow;
- (NSInteger)row;
- (id)initWithRow:(NSInteger)aRow column:(NSInteger)aColumn;
@end

