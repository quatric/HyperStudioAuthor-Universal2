#import "NSTextTable+EXTextTable.h"
@implementation NSTextTable (EXTextTable)
- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    return [NSArray arrayWithObjects:@"numberOfColumns", @"layoutAlgorithm", @"collapsesBorders", @"hidesEmptyCells", nil];
}
@end
