#import "HyperPlayerBasePrefix.h"


@interface HSJavaScriptCodeUtils : NSObject
{
}
+ (id)removeInvalidCharacters:(id)aCharacters;
+ (id)quoteString:(id)aString withQuoteChar:(unsigned short)aChar;
+ (id)escapedStringWithCharacter:(unsigned short)aCharacter forSingleQuote:(BOOL)aQuote;
+ (BOOL)isCharacterVisible:(unsigned short)aVisible;
+ (id)quoteString:(id)aString;
@end

