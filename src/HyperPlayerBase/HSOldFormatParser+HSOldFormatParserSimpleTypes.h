#import "HyperPlayerBasePrefix.h"
#import "HSOldFormatParser.h"


@interface HSOldFormatParser (HSOldFormatParserSimpleTypes)
- (id)parseType_RGBColor:(id)aColor atDefinedTree:(id)aTree parent:(id)aParent atOffset:(NSInteger)aOffset;
- (id)parseType_extended80:(id)aExtended80 atDefinedTree:(id)aTree parent:(id)aParent atOffset:(NSInteger)aOffset;
- (id)parseType_none:(id)aNone atDefinedTree:(id)aTree parent:(id)aParent atOffset:(NSInteger)aOffset;
- (id)parseType_Rect:(id)aRect atDefinedTree:(id)aTree parent:(id)aParent atOffset:(NSInteger)aOffset;
- (id)parseType_FourCharCode:(id)aCode atDefinedTree:(id)aTree parent:(id)aParent atOffset:(NSInteger)aOffset;
- (id)parseType_chars:(id)aChars atDefinedTree:(id)aTree parent:(id)aParent atOffset:(NSInteger)aOffset;
- (id)parseType_data:(id)aData atDefinedTree:(id)aTree parent:(id)aParent atOffset:(NSInteger)aOffset;
- (id)parseType_ConstStr255Param:(id)aParam atDefinedTree:(id)aTree parent:(id)aParent atOffset:(NSInteger)aOffset;
- (id)parseType_UnsignedFixed:(id)aFixed atDefinedTree:(id)aTree parent:(id)aParent atOffset:(NSInteger)aOffset;
- (id)parseType_Ptr:(id)aPtr atDefinedTree:(id)aTree parent:(id)aParent atOffset:(NSInteger)aOffset;
- (id)parseType_unsigned_long:(id)aLong atDefinedTree:(id)aTree parent:(id)aParent atOffset:(NSInteger)aOffset;
- (id)parseType_Fixed:(id)aFixed atDefinedTree:(id)aTree parent:(id)aParent atOffset:(NSInteger)aOffset;
- (id)parseType_long:(id)aLong atDefinedTree:(id)aTree parent:(id)aParent atOffset:(NSInteger)aOffset;
- (id)parseType_unsigned_short:(id)aShort atDefinedTree:(id)aTree parent:(id)aParent atOffset:(NSInteger)aOffset;
- (id)parseType_short:(id)aShort atDefinedTree:(id)aTree parent:(id)aParent atOffset:(NSInteger)aOffset;
- (id)parseType_UInt8:(id)aInt8 atDefinedTree:(id)aTree parent:(id)aParent atOffset:(NSInteger)aOffset;
- (id)parseType_unsigned_char:(id)aChar atDefinedTree:(id)aTree parent:(id)aParent atOffset:(NSInteger)aOffset;
- (id)parseType_char:(id)aChar atDefinedTree:(id)aTree parent:(id)aParent atOffset:(NSInteger)aOffset;
@end

