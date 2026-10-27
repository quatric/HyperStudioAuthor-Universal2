#import "HSJavaScriptCodeUtils.h"
@implementation HSJavaScriptCodeUtils
// Strips U+FFFC (object replacement characters, the attachments' place holders).
+ (id)removeInvalidCharacters:(id)aCharacters
{
    NSMutableString *string = [[aCharacters mutableCopy] autorelease];
    unichar replacement = 0xfffc;
    [string replaceOccurrencesOfString:[NSString stringWithCharacters:&replacement length:1] withString:@""
                               options:0 range:NSMakeRange(0, [string length])];
    return string;
}
// A JavaScript string literal.
+ (id)quoteString:(id)aString withQuoteChar:(unsigned short)aChar
{
    NSMutableString *literal = [NSMutableString string];
    NSString *quote = [NSString stringWithCharacters:&aChar length:1];
    [literal appendString:quote];
    NSUInteger length = [aString length];
    for (NSUInteger i = 0; i < length; i++)
        [literal appendString:[self escapedStringWithCharacter:[aString characterAtIndex:i] forSingleQuote:aChar != '"']];
    [literal appendString:quote];
    return literal;
}
+ (id)escapedStringWithCharacter:(unsigned short)aCharacter forSingleQuote:(BOOL)aQuote
{
    unichar escape;
    switch (aCharacter) {
    case '\b': escape = 'b'; break;
    case '\t': escape = 't'; break;
    case '\n': escape = 'n'; break;
    case '\v': escape = 'v'; break;
    case '\f': escape = 'f'; break;
    case '\r': escape = 'r'; break;
    case '\\': escape = '\\'; break;
    case '"':
        if (aQuote)
            goto plain;
        escape = '"';
        break;
    case '\'':
        if (!aQuote)
            goto plain;
        escape = '\'';
        break;
    default:
        goto plain;
    }
    {
        unichar characters[2] = { '\\', escape };
        return [NSString stringWithCharacters:characters length:2];
    }
plain:
    // Original quirk kept: an invisible character goes through "%C", which
    // yields the same character.
    if ([self isCharacterVisible:aCharacter])
        return [NSString stringWithCharacters:&aCharacter length:1];
    return [NSString stringWithFormat:@"%C", aCharacter];
}
// Printable Latin-1 characters (the C library's rune table).
+ (BOOL)isCharacterVisible:(unsigned short)aVisible
{
    return aVisible < 0x100 && isprint(aVisible);
}
+ (id)quoteString:(id)aString
{
    return [self quoteString:aString withQuoteChar:'\''];
}
@end
