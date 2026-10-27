#import "HyperPlayerBasePrefix.h"
#import "SMKSpeechTextParser.h"


@interface SMKSpeechSimpleParser : SMKSpeechTextParser
{
    NSDictionary *_replacementWords;
    NSCharacterSet *_stopCharacterSet;
    NSCharacterSet *_replacementSubset;
    NSCharacterSet *_scannerStopCharacters;
}
- (id)parseParagraphAsString:(id)aString;
- (id)processToken:(id)aToken range:(NSRange)aRange parentString:(id)aString;
- (void)setReplacementWords:(id)aWords;
- (id)replacementWords;
- (id)_scannerStopCharacters;
- (void)setReplacementSubset:(id)aSubset;
- (id)_replacementSubset;
- (id)replacementSubset;
- (void)setStopCharacterSet:(id)aSet;
- (id)_stopCharacterSet;
- (id)stopCharacterSet;
@end

