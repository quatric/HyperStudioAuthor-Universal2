#import "HyperPlayerBasePrefix.h"
#import "HSOldFormatParser.h"


@interface HSOldFormatParser (HSOldFormatParserCardType)
- (id)parseType_vCardBodyNew:(id)aNew atDefinedTree:(id)aTree parent:(id)aParent atOffset:(NSInteger)aOffset;
- (id)parseType_vCardBody:(id)aBody atDefinedTree:(id)aTree parent:(id)aParent atOffset:(NSInteger)aOffset;
- (id)parseType_vCardBodyForward:(id)aForward atDefinedTree:(id)aTree parent:(id)aParent atOffset:(NSInteger)aOffset;
@end

