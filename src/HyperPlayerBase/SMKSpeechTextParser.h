#import "HyperPlayerBasePrefix.h"


@interface SMKSpeechTextParser : NSObject
{
}
- (BOOL)needsSpecialParsingForParagraphWithRange:(NSRange)aRange inAttributedString:(id)aString;
- (id)parseParagraphAsAttributedString:(id)aString;
- (id)parseParagraphAsString:(id)aString;
@end

@interface SMKSpeechTextParser (SMKSpeechTextParserPrivate)
- (id)parseParagraph:(id)aParagraph;
@end

