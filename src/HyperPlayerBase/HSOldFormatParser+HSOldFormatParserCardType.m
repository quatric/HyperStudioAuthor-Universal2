#import "HSOldFormatParser+HSOldFormatParserCardType.h"
@implementation HSOldFormatParser (HSOldFormatParserCardType)
// a card body is what follows the card header: its size is the card's length
// less the header's
- (id)HSOldFormatParserCardType_bodySize
{
    return [NSNumber numberWithLong:[self intEvaluate:@"cardHeader.type.length"] - [self intEvaluate:@"CardHeader.size"]];
}
- (id)parseType_vCardBodyNew:(id)aNew atDefinedTree:(id)aTree parent:(id)aParent atOffset:(NSInteger)aOffset
{
    id name = [aTree objectForKey:@"name"];
    id size = [self HSOldFormatParserCardType_bodySize];
    id value = [self valueForType:@"_ItemsNew" atDefinedTree:aTree parent:aParent atOffset:aOffset];
    return [self parametersDictionaryWithValue:value name:name type:aNew size:size];
}
- (id)parseType_vCardBody:(id)aBody atDefinedTree:(id)aTree parent:(id)aParent atOffset:(NSInteger)aOffset
{
    id name = [aTree objectForKey:@"name"];
    id size = [self HSOldFormatParserCardType_bodySize];
    id value = [self valueForType:@"_ItemsIterate" atDefinedTree:aTree parent:aParent atOffset:aOffset];
    return [self parametersDictionaryWithValue:value name:name type:aBody size:size];
}
- (id)parseType_vCardBodyForward:(id)aForward atDefinedTree:(id)aTree parent:(id)aParent atOffset:(NSInteger)aOffset
{
    id name = [aTree objectForKey:@"name"];
    return [self parametersDictionaryWithValue:@"" name:name type:aForward size:[self HSOldFormatParserCardType_bodySize]];
}
@end
