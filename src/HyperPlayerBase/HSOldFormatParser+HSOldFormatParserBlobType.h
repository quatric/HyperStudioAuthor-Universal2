#import "HyperPlayerBasePrefix.h"
#import "HSOldFormatParser.h"


@interface HSOldFormatParser (HSOldFormatParserBlobType)
- (id)parseType_vLinkActionBody:(id)aBody atDefinedTree:(id)aTree parent:(id)aParent atOffset:(NSInteger)aOffset;
- (id)parseType_vLinkTextBody:(id)aBody atDefinedTree:(id)aTree parent:(id)aParent atOffset:(NSInteger)aOffset;
- (id)parseType_vIconBody:(id)aBody atDefinedTree:(id)aTree parent:(id)aParent atOffset:(NSInteger)aOffset;
- (id)parseType_vMidiBody:(id)aBody atDefinedTree:(id)aTree parent:(id)aParent atOffset:(NSInteger)aOffset;
- (id)parseType_vFontListCount:(id)aCount atDefinedTree:(id)aTree parent:(id)aParent atOffset:(NSInteger)aOffset;
- (id)parseType_vBlobBody:(id)aBody atDefinedTree:(id)aTree parent:(id)aParent atOffset:(NSInteger)aOffset;
@end

