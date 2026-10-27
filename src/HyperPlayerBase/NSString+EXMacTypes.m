#import "NSString+EXMacTypes.h"

@implementation NSString (EXMacTypes)

+ (id)extraStringWithPascalString:(char *)aString
{
    return [[[NSString alloc] extraInitWithPascalString:aString] autorelease];
}

+ (id)extraStringWithFourCharCode:(NSUInteger)aCode
{
    uint32_t code = (uint32_t)aCode;
    char buffer[8] = { 0 };
    buffer[0] = (char)(code >> 24);
    buffer[1] = (char)(code >> 16);
    buffer[2] = (char)(code >> 8);
    buffer[3] = (char)code;
    return [NSString stringWithCString:buffer encoding:NSASCIIStringEncoding];
}

// Accepts "TYPE" or "'TYPE'".
- (NSUInteger)extraFourCharCode
{
    const char *bytes;
    if ([self length] == 6)
        bytes = [self UTF8String] + 1;
    else if ([self length] == 4)
        bytes = [self UTF8String];
    else
        return 0;
    return ((uint32_t)(uint8_t)bytes[0] << 24) | ((uint32_t)(uint8_t)bytes[1] << 16)
         | ((uint32_t)(uint8_t)bytes[2] << 8) | (uint32_t)(uint8_t)bytes[3];
}

// The copy starts at the length byte and the string keeps the terminating
// NUL, so the result is the length byte plus all but the last character
// (original behaviour). Both branches use initWithBytesNoCopy:; only the
// encoding differs.
- (id)extraInitWithPascalString:(char *)aString
{
    if (aString == NULL)
        return [self init];
    NSUInteger length = (uint8_t)aString[0];
    char *buffer = malloc(length + 1);
    buffer[length] = 0;
    memcpy(buffer, aString, length);
    if ([self respondsToSelector:@selector(initWithBytesNoCopy:length:encoding:freeWhenDone:)])
        return [self initWithBytesNoCopy:buffer length:length + 1 encoding:NSMacOSRomanStringEncoding freeWhenDone:YES];
    return [self initWithBytesNoCopy:buffer length:length + 1 encoding:NSASCIIStringEncoding freeWhenDone:YES];
}

@end

@implementation NSMutableString (EXReplacement)

- (BOOL)extraReplaceString:(id)aString withString:(id)aString2 searchOptions:(NSUInteger)aOptions replaceOptions:(NSInteger)aOptions2
{
    return [self extraReplaceString:aString withString:aString2 searchOptions:aOptions replaceOptions:aOptions2 range:NSMakeRange(0, [self length])];
}

- (BOOL)extraReplaceString:(id)aString withString:(id)aString2 replaceOptions:(NSInteger)aOptions
{
    return [self extraReplaceString:aString withString:aString2 searchOptions:0 replaceOptions:aOptions];
}

- (BOOL)extraReplaceString:(id)aString withString:(id)aString2 searchOptions:(NSUInteger)aOptions
{
    return [self extraReplaceString:aString withString:aString2 searchOptions:aOptions replaceOptions:0];
}

- (BOOL)extraReplaceString:(id)aString withString:(id)aString2
{
    return [self extraReplaceString:aString withString:aString2 searchOptions:0];
}

- (BOOL)extraReplaceString:(id)aString withString:(id)aString2 searchOptions:(NSUInteger)aOptions replaceOptions:(NSInteger)aOptions2 range:(NSRange)aRange
{
    return [self extraReplaceString:aString withString:aString2 searchOptions:aOptions replaceOptions:aOptions2 range:aRange delimiterCharacters:nil wordCharacters:nil];
}

// Replace options: 1 all occurrences, 2 word start, 4 word end, 6 inside a
// word, 8 whole delimited word, 0x10 restart from the range start after each
// replacement. Without word characters, a word character is any
// non-delimiter. The word-start test checks (character at match - 1) rather
// than the character before the match (original behaviour).
- (BOOL)extraReplaceString:(id)aString withString:(id)aString2 searchOptions:(NSUInteger)aOptions replaceOptions:(NSInteger)aOptions2 range:(NSRange)aRange delimiterCharacters:(id)aCharacters wordCharacters:(id)aCharacters2
{
    NSInteger delta = (NSInteger)[aString2 length] - (NSInteger)[aString length];
    NSCharacterSet *delimiters = aCharacters;
    NSCharacterSet *wordCharacters = aCharacters2;
    NSUInteger total = aRange.length;
    if (delimiters == nil)
        delimiters = [NSCharacterSet whitespaceCharacterSet];
    BOOL replaced = NO;
    NSRange current = aRange;
#define HS_IS_WORD_CHARACTER(c) (wordCharacters ? [wordCharacters characterIsMember:(c)] : ![delimiters characterIsMember:(c)])
    do {
        NSRange found = [self rangeOfString:aString options:aOptions range:current];
        if (found.length == 0)
            break;
        NSUInteger index = found.location;
        NSUInteger end = NSMaxRange(found);
        BOOL match;
        if (aOptions2 == 0) {
            match = YES;
        } else if (aOptions2 & 8) {
            if (end < [self length] && ![delimiters characterIsMember:[self characterAtIndex:end]])
                match = NO;
            else if (index == 0)
                match = YES;
            else
                match = [delimiters characterIsMember:[self characterAtIndex:index - 1]];
        } else if ((aOptions2 & 6) == 6) {
            if (index == 0 || !HS_IS_WORD_CHARACTER([self characterAtIndex:index - 1]))
                match = NO;
            else
                match = end < [self length] && HS_IS_WORD_CHARACTER([self characterAtIndex:end]);
        } else if (aOptions2 & 2) {
            if (index != 0 && ![delimiters characterIsMember:(unichar)([self characterAtIndex:index] - 1)])
                match = NO;
            else
                match = end < [self length] && HS_IS_WORD_CHARACTER([self characterAtIndex:end]);
        } else if (aOptions2 & 4) {
            if (index == 0 || !HS_IS_WORD_CHARACTER([self characterAtIndex:index - 1]))
                match = NO;
            else
                match = end >= [self length] || [delimiters characterIsMember:[self characterAtIndex:end]];
        } else {
            match = YES;
        }
        if (match) {
            total += delta;
            [self replaceCharactersInRange:found withString:aString2];
            replaced = YES;
            if (aOptions2 & 0x10) {
                current = NSMakeRange(aRange.location, total);
                continue;
            }
        }
        if (aOptions & NSBackwardsSearch) {
            current.length = index;
        } else {
            NSUInteger next = found.length + index + (match ? delta : 0);
            current.length = current.length + current.location - next;
            current.location = next;
        }
    } while (aOptions2 & 1);
#undef HS_IS_WORD_CHARACTER
    return replaced;
}

@end

@implementation NSString (EXSeparation)

// A separator at the very end yields a trailing empty component.
- (id)extraComponentsSeparatedByCharacterFromSet:(id)aSet options:(NSUInteger)aOptions range:(NSRange)aRange
{
    NSMutableArray *components = [[NSMutableArray alloc] init];
    BOOL backwards = (aOptions & NSBackwardsSearch) != 0;
    NSRange found;
    do {
        found = [self rangeOfCharacterFromSet:aSet options:aOptions range:aRange];
        if (found.length == 0)
            found.location = backwards ? 0 : NSMaxRange(aRange);
        NSUInteger last = aRange.location + aRange.length - 1;
        NSUInteger after = NSMaxRange(found);
        if (last <= after)
            after = last;
        NSRange piece;
        if (backwards) {
            piece = NSMakeRange(after, aRange.location + aRange.length - found.length - found.location);
            aRange.length = found.location - aRange.location;
        } else {
            piece = NSMakeRange(aRange.location, found.location - aRange.location);
            aRange.length = aRange.length - found.length - (found.location - aRange.location);
            aRange.location = after;
        }
        [components addObject:[self substringWithRange:piece]];
    } while (found.length != 0);
    NSArray *result = [NSArray arrayWithArray:components];
    [components release];
    return result;
}

// The options are not passed on (original behaviour).
- (id)extraComponentsSeparatedByCharacterFromSet:(id)aSet options:(NSUInteger)aOptions
{
    return [self extraComponentsSeparatedByCharacterFromSet:aSet options:0 range:NSMakeRange(0, [self length])];
}

- (id)extraComponentsSeparatedByCharacterFromSet:(id)aSet
{
    return [self extraComponentsSeparatedByCharacterFromSet:aSet options:0];
}

@end

@implementation NSMutableString (EXMutableStringExtensions)

- (void)extraClear
{
    [self deleteCharactersInRange:NSMakeRange(0, [self length])];
}

@end

@implementation NSString (EXUniqueFilename)

// "name" -> "name 1" -> "name 2" ... until no file exists at the path.
+ (id)extraCreateUniqueFilename:(id)aFilename extension:(id)aExtension
{
    NSString *path = aFilename;
    if ([aExtension length] != 0)
        path = [aFilename stringByAppendingPathExtension:aExtension];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path])
        return path;
    NSString *name = [aFilename lastPathComponent];
    NSArray *parts = [name componentsSeparatedByString:@" "];
    NSString *lastPart = [parts lastObject];
    int number = 0;
    if ([parts count] > 1) {
        number = [lastPart intValue];
        if (number != 0)
            name = [name substringToIndex:[name length] - 1 - [lastPart length]];
    }
    NSString *newName = [name stringByAppendingFormat:@" %i", number + 1];
    return [self extraCreateUniqueFilename:[[aFilename stringByDeletingLastPathComponent] stringByAppendingPathComponent:newName] extension:aExtension];
}

@end

@implementation NSString (EXSearching)

// Each "%XX" escape becomes "_".
- (id)extraStringByReplacingURLEscapedSymbolsWithUnderscores
{
    NSString *result = [NSString stringWithString:self];
    for (;;) {
        NSRange found = [result rangeOfString:@"%"];
        if (found.length == 0)
            break;
        result = [result stringByReplacingCharactersInRange:NSMakeRange(found.location, found.length + 2) withString:@"_"];
    }
    return result;
}

- (id)extraStringByTrimmingWhitespaceCharacters
{
    NSCharacterSet *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    if ([self respondsToSelector:@selector(stringByTrimmingCharactersInSet:)])
        return [self stringByTrimmingCharactersInSet:set];
    return [self _pumaStringByTrimmingCharactersInSet:set];
}

// Pre-10.2 fallback: trims one trailing character and leading ones. The
// original never re-searches inside its leading loop (it would not
// terminate); it is only reached when stringByTrimmingCharactersInSet: is
// missing, so the search is redone here.
- (id)_pumaStringByTrimmingCharactersInSet:(id)aSet
{
    NSString *result = self;
    NSRange range = [self rangeOfCharacterFromSet:aSet options:NSBackwardsSearch];
    if (range.location != NSNotFound && NSMaxRange(range) == [self length]) {
        result = [NSMutableString stringWithString:self];
        [(NSMutableString *)result deleteCharactersInRange:range];
        range = [result rangeOfCharacterFromSet:aSet];
    }
    while (range.location == 0) {
        if (result == self)
            result = [NSMutableString stringWithString:self];
        [(NSMutableString *)result deleteCharactersInRange:NSMakeRange(0, range.length)];
        range = [result rangeOfCharacterFromSet:aSet];
    }
    return result;
}

// Returns -1 for an empty string (original behaviour).
- (NSUInteger)extraCountOfCharacterFromSet:(id)aSet options:(NSUInteger)aOptions
{
    NSUInteger length = [self length];
    NSUInteger count = (NSUInteger)-1;
    if (length == 0)
        return count;
    NSUInteger position = 0;
    NSUInteger remaining = length;
    do {
        NSRange found = [self rangeOfCharacterFromSet:aSet options:aOptions range:NSMakeRange(position, remaining)];
        position = NSMaxRange(found);
        remaining = length - position;
        count++;
    } while (position < length);
    return count;
}

- (NSUInteger)extraCountOfCharacterFromSet:(id)aSet
{
    return [self extraCountOfCharacterFromSet:aSet options:0];
}

- (NSUInteger)extraCountOfString:(id)aString options:(NSUInteger)aOptions
{
    NSUInteger length = [self length];
    NSUInteger count = (NSUInteger)-1;
    if (length == 0)
        return count;
    NSUInteger position = 0;
    NSUInteger remaining = length;
    do {
        NSRange found = [self rangeOfString:aString options:aOptions range:NSMakeRange(position, remaining)];
        position = NSMaxRange(found);
        remaining = length - position;
        count++;
    } while (position < length);
    return count;
}

- (NSUInteger)extraCountOfString:(id)aString
{
    return [self extraCountOfString:aString options:0];
}

- (NSUInteger)extraLocationOfString:(id)aString options:(NSUInteger)aOptions
{
    return [self rangeOfString:aString options:aOptions].location;
}

- (NSUInteger)extraLocationOfString:(id)aString
{
    return [self rangeOfString:aString].location;
}

- (NSUInteger)extraIndexOfCharacter:(unsigned short)aCharacter
{
    unichar character = aCharacter;
    return [self extraLocationOfString:[NSString stringWithCharacters:&character length:1]];
}

- (BOOL)extraContainsString:(id)aString
{
    return [self rangeOfString:aString].location != NSNotFound;
}

@end

@implementation NSString (EXValueSupport)

+ (id)extraStringWithInt:(NSInteger)aInt
{
    return [self stringWithFormat:@"%d", (int)aInt];
}

@end

@implementation NSString (EXCharacters)

+ (id)extraNewlineString
{
    static const unichar newline = '\n';
    return [self stringWithCharacters:&newline length:1];
}

@end
