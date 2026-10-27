#import "SMKSpeechSimpleParser.h"
// Prepares text for speech by replacing words (tokens between stop
// characters: by default whitespace and punctuation) from a dictionary. A
// token that isn't replaced is tried again without its trailing "replacement
// subset" characters (by default ".", so "etc." finds "etc." and then "etc").
@implementation SMKSpeechSimpleParser
static NSCharacterSet *SMKSpeechSimpleParserDefaultStopCharacters(void)
{
    static NSCharacterSet *sSet;
    if (sSet == nil) {
        NSMutableCharacterSet *set = [[NSCharacterSet whitespaceAndNewlineCharacterSet] mutableCopy];
        [set formUnionWithCharacterSet:[NSCharacterSet punctuationCharacterSet]];
        sSet = [set copy];
        [set release];
    }
    return sSet;
}
static NSCharacterSet *SMKSpeechSimpleParserDefaultReplacementSubset(void)
{
    static NSCharacterSet *sSet;
    if (sSet == nil)
        sSet = [[NSCharacterSet characterSetWithRange:NSMakeRange('.', 1)] retain];
    return sSet;
}
// The text with its replaced words; the text itself when nothing was
// replaced. Text between replacements is copied as it is.
- (id)parseParagraphAsString:(id)aString
{
    NSScanner *scanner = [[NSScanner alloc] initWithString:aString];
    NSCharacterSet *stop = [self _scannerStopCharacters];
    NSCharacterSet *subset = [self _replacementSubset];
    NSMutableString *result = nil;
    NSUInteger pendingStart = 0, pendingLength = 0;
    while (![scanner isAtEnd]) {
        NSString *token = nil;
        NSUInteger start = [scanner scanLocation];
        [scanner scanUpToCharactersFromSet:stop intoString:&token];
        NSUInteger end = [scanner scanLocation];
        NSUInteger length = end - start;
        if (![scanner isAtEnd]) {
            for (; end < [aString length]; end++) {
                if (![stop characterIsMember:[aString characterAtIndex:end]])
                    break;
            }
            [scanner setScanLocation:end];
        }
        NSString *replacement = [self processToken:token range:NSMakeRange(start, length) parentString:aString];
        NSInteger last = start + length - 1;
        while (replacement == token && length != 0 && [subset characterIsMember:[aString characterAtIndex:last--]]) {
            length--;
            token = [aString substringWithRange:NSMakeRange(start, length)];
            replacement = [self processToken:token range:NSMakeRange(start, length) parentString:aString];
        }
        if (replacement == token) {
            pendingLength = end - pendingStart;
            continue;
        }
        if (result == nil)
            result = [[NSMutableString new] autorelease];
        if (pendingLength != 0)
            [result appendString:[aString substringWithRange:NSMakeRange(pendingStart, pendingLength)]];
        [result appendString:replacement];
        pendingStart = start + length;
        pendingLength = end - pendingStart;
    }
    if (result != nil && pendingLength != 0)
        [result appendString:[aString substringWithRange:NSMakeRange(pendingStart, pendingLength)]];
    [scanner release];
    return result != nil ? result : aString;
}
// The token's replacement, or the token itself.
- (id)processToken:(id)aToken range:(NSRange)aRange parentString:(id)aString
{
    id replacement = [_replacementWords objectForKey:aToken];
    return replacement != nil ? replacement : aToken;
}
- (void)setReplacementWords:(id)aWords
{
    [aWords retain];
    [_replacementWords release];
    _replacementWords = aWords;
}
- (id)replacementWords
{
    return _replacementWords;
}
// The stop characters without the replacement subset (which the scanner must
// keep in tokens); the defaults' is shared.
- (id)_scannerStopCharacters
{
    if (_scannerStopCharacters == nil) {
        if (_stopCharacterSet == nil && _replacementSubset == nil) {
            static NSCharacterSet *sDefault;
            if (sDefault == nil) {
                NSMutableCharacterSet *set = [SMKSpeechSimpleParserDefaultStopCharacters() mutableCopy];
                [set formIntersectionWithCharacterSet:[SMKSpeechSimpleParserDefaultReplacementSubset() invertedSet]];
                sDefault = [set copy];
                [set release];
            }
            _scannerStopCharacters = [sDefault retain];
        } else {
            NSMutableCharacterSet *set = [[self _stopCharacterSet] mutableCopy];
            [set formIntersectionWithCharacterSet:[[self _replacementSubset] invertedSet]];
            _scannerStopCharacters = [set copy];
            [set release];
        }
    }
    return _scannerStopCharacters;
}
// The original only resets the derived stop characters (and releases the
// old subset) when there was a subset before; done always here.
- (void)setReplacementSubset:(id)aSubset
{
    [aSubset retain];
    [_scannerStopCharacters release];
    _scannerStopCharacters = nil;
    [_replacementSubset release];
    _replacementSubset = aSubset;
}
- (id)_replacementSubset
{
    return _replacementSubset != nil ? _replacementSubset : SMKSpeechSimpleParserDefaultReplacementSubset();
}
- (id)replacementSubset
{
    return _replacementSubset;
}
// The original stores the set as the replacement subset (a copy-and-paste
// slip); fixed.
- (void)setStopCharacterSet:(id)aSet
{
    [aSet retain];
    [_scannerStopCharacters release];
    _scannerStopCharacters = nil;
    [_stopCharacterSet release];
    _stopCharacterSet = aSet;
}
- (id)_stopCharacterSet
{
    return _stopCharacterSet != nil ? _stopCharacterSet : SMKSpeechSimpleParserDefaultStopCharacters();
}
- (id)stopCharacterSet
{
    return _stopCharacterSet;
}
// Not in the original (the sets and words leaked).
- (void)dealloc
{
    [_replacementWords release];
    [_stopCharacterSet release];
    [_replacementSubset release];
    [_scannerStopCharacters release];
    [super dealloc];
}
@end
