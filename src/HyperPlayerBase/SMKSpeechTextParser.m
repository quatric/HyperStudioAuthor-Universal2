#import "SMKSpeechTextParser.h"
@implementation SMKSpeechTextParser
- (BOOL)needsSpecialParsingForParagraphWithRange:(NSRange)aRange inAttributedString:(id)aString
{
    return NO;
}
- (id)parseParagraphAsAttributedString:(id)aString
{
    return [aString string];
}
- (id)parseParagraphAsString:(id)aString
{
    return aString;
}
@end
@implementation SMKSpeechTextParser (SMKSpeechTextParserPrivate)
- (id)parseParagraph:(id)aParagraph
{
    if ([aParagraph isKindOfClass:[NSString class]])
        return [self parseParagraphAsString:aParagraph];
    if ([aParagraph isKindOfClass:[NSAttributedString class]])
        return [self parseParagraphAsAttributedString:aParagraph];
    [[NSAssertionHandler currentHandler] handleFailureInMethod:_cmd object:self file:@(__FILE__) lineNumber:__LINE__
                                                   description:@"Parameter should be either NSString or NSAttributedString"];
    return nil;
}
@end
