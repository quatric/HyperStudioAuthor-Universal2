#import "NSString+NSStringLinkRecognitionHSExtensions.h"
#import "NSString+EXMacTypes.h"

@implementation NSString (NSStringLinkRecognitionHSExtensions)

- (id)hyperRecognizedLinks
{
    NSMutableArray *links = [NSMutableArray array];
    NSCharacterSet *separators = [NSMutableCharacterSet whitespaceAndNewlineCharacterSet];
    NSScanner *scanner = [[NSScanner alloc] initWithString:self];
    NSString *word = nil;
    while (![scanner isAtEnd]) {
        if ([scanner scanUpToCharactersFromSet:separators intoString:&word]) {
            NSURL *url = [NSURL URLWithString:word];
            if ([url isFileURL] || ([url scheme] != nil && [url host] != nil))
                [links addObject:url];
        }
    }
    [scanner release];
    return links;
}

- (id)hyperAttributedStringWithRecognizedLinks
{
    NSMutableAttributedString *string = [[[NSMutableAttributedString alloc] initWithString:self] autorelease];
    if ([self length]) {
        NSCharacterSet *separators = [NSMutableCharacterSet whitespaceAndNewlineCharacterSet];
        NSScanner *scanner = [[NSScanner alloc] initWithString:self];
        NSString *word = nil;
        while (![scanner isAtEnd]) {
            if ([scanner scanUpToCharactersFromSet:separators intoString:&word]) {
                NSURL *url = [NSURL URLWithString:word];
                if ([url isFileURL] || ([url scheme] != nil && [url host] != nil)) {
                    NSUInteger length = [word length];
                    [string setAttributes:[NSDictionary dictionaryWithObject:url forKey:NSLinkAttributeName]
                                    range:NSMakeRange([scanner scanLocation] - length, length)];
                }
            }
        }
        [scanner release];
    }
    return string;
}

@end

@implementation NSMutableString (HSExtensions)

- (void)hyperRemoveCharactersInSet:(id)aSet
{
    NSRange range;
    while ((range = [self rangeOfCharacterFromSet:aSet]).location != NSNotFound)
        [self deleteCharactersInRange:range];
}

@end

@implementation NSString (NSStringPathExtensionsHSExtensions)

- (id)relativePathToPath:(id)aPath
{
    NSMutableString *relativePath = [NSMutableString string];
    NSArray *components = [self pathComponents];
    NSUInteger count = [components count];
    NSArray *otherComponents = [aPath pathComponents];
    NSUInteger otherCount = [otherComponents count];
    NSUInteger commonCount = 0;
    BOOL matching = YES;
    // One "../" for every component of aPath past the common prefix.
    for (NSUInteger i = 0; i < otherCount; i++) {
        if (i < count && matching
            && [[components objectAtIndex:i] isEqualToString:[otherComponents objectAtIndex:i]]) {
            commonCount = i + 1;
        } else {
            [relativePath appendString:@"../"];
            matching = NO;
        }
    }
    [relativePath appendString:[self pathWithLastComponents:[self pathComponentsCount] - commonCount]];
    return relativePath;
}

- (id)pathWithLastComponents:(NSInteger)aComponents
{
    NSArray *components = [self pathComponents];
    NSInteger count = [components count];
    if (aComponents < 1 || count < aComponents)
        return nil;
    return [NSString pathWithComponents:[components subarrayWithRange:NSMakeRange(count - aComponents, aComponents)]];
}

- (id)pathWithFirstComponents:(NSInteger)aComponents
{
    NSArray *components = [self pathComponents];
    NSInteger count = [components count];
    if (aComponents < 1 || count < aComponents)
        return nil;
    return [NSString pathWithComponents:[components subarrayWithRange:NSMakeRange(0, aComponents)]];
}

- (NSInteger)pathComponentsCount
{
    return [[self pathComponents] count];
}

@end

@implementation NSString (HSExtensions)

+ (id)hyperUIDString
{
    CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
    NSString *string = (NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuid);
    CFRelease(uuid);
    return [string autorelease];
}

+ (id)hyperStringWithASCIIData:(id)aData
{
    return [[[NSMutableString alloc] initWithData:aData encoding:NSASCIIStringEncoding] autorelease];
}

- (id)hyperStringByReplacingUnderlineWithSlashes
{
    return [self hyperStringByReplacingString:@"_" withString:@"/"];
}

- (id)hyperStringByReplacingColonsWithSlashes
{
    return [self hyperStringByReplacingString:@":" withString:@"/"];
}

- (id)hyperStringByReplacingSlashesWithColons
{
    return [self hyperStringByReplacingString:@"/" withString:@":"];
}

- (id)hyperStringByReplacingString:(id)aString withString:(id)aString2
{
    NSMutableString *mutableString = [self mutableCopy];
    [mutableString extraReplaceString:aString withString:aString2 replaceOptions:1];
    NSString *result = [mutableString copy];
    [mutableString release];
    return [result autorelease];
}

- (NSRange)hyperRangeOfCharacterFromSet:(id)aSet options:(NSUInteger)aOptions range:(NSRange)aRange
{
    // The run of consecutive characters from aSet starting at the first match.
    // Backwards searches stop after one character, as in the original.
    NSUInteger end = NSMaxRange(aRange);
    NSRange found = [self rangeOfCharacterFromSet:aSet options:aOptions range:aRange];
    NSUInteger location = found.location;
    NSUInteger length = 0;
    NSUInteger step = 0;
    NSUInteger foundLocation = found.location;
    for (;;) {
        for (;;) {
            if (foundLocation != length + location || length + location >= end)
                return NSMakeRange(location, length);
            if (aOptions & NSBackwardsSearch)
                break;
            length += step;
            found = [self rangeOfCharacterFromSet:aSet options:aOptions range:NSMakeRange(length + location, end - location - length)];
            foundLocation = found.location;
            step = found.length;
        }
        location = foundLocation;
        if (foundLocation == 0)
            break;
        length++;
        found = [self rangeOfCharacterFromSet:aSet options:aOptions range:NSMakeRange(foundLocation - 1, 1)];
        foundLocation = found.location;
        step = found.length;
    }
    return NSMakeRange(location, length);
}

- (NSRange)hyperRangeOfCharacterFromSet:(id)aSet options:(NSUInteger)aOptions
{
    return [self hyperRangeOfCharacterFromSet:aSet options:aOptions range:NSMakeRange(0, [self length])];
}

- (NSRange)hyperRangeOfCharacterFromSet:(id)aSet
{
    return [self hyperRangeOfCharacterFromSet:aSet options:0];
}

- (id)hyperStringByAddingEllipsis
{
    return [self stringByAppendingString:[NSString stringWithUTF8String:"\xE2\x80\xA6"]];
}

- (NSUInteger)hasHyperPrefixCaseInsensitive:(id)aInsensitive
{
    return [self rangeOfString:aInsensitive options:NSCaseInsensitiveSearch | NSAnchoredSearch].location == 0;
}

- (NSUInteger)hasHyperSubstringCaseInsensitive:(id)aInsensitive
{
    return [self rangeOfString:aInsensitive options:NSCaseInsensitiveSearch].location != NSNotFound;
}

- (NSUInteger)hasHyperSubstring:(id)aSubstring
{
    return [self rangeOfString:aSubstring options:0].location != NSNotFound;
}

- (NSInteger)hyperCaseInsensitiveNumericCompare:(id)aCompare
{
    return [self compare:aCompare options:NSCaseInsensitiveSearch | NSNumericSearch];
}

- (id)hyperStringByRemovingCharactersInSet:(id)aSet
{
    NSMutableString *mutableString = [self mutableCopy];
    [mutableString hyperRemoveCharactersInSet:aSet];
    NSString *result = [NSString stringWithString:mutableString];
    [mutableString release];
    return result;
}

- (NSRect)hyperRectValue
{
    float x = 0, y = 0, width = 0, height = 0;
    sscanf([self cStringUsingEncoding:NSASCIIStringEncoding], "%f %f %f %f", &x, &y, &width, &height);
    return NSMakeRect(x, y, width, height);
}

- (NSSize)hyperSizeValue
{
    float width = 0, height = 0;
    sscanf([self cStringUsingEncoding:NSASCIIStringEncoding], "%f %f", &width, &height);
    return NSMakeSize(width, height);
}

- (NSPoint)hyperPointValue
{
    float x = 0, y = 0;
    sscanf([self cStringUsingEncoding:NSASCIIStringEncoding], "%f %f", &x, &y);
    return NSMakePoint(x, y);
}

- (BOOL)hyperBoolValue
{
    if (NSFoundationVersionNumber >= 949.0)
        return [self boolValue];
    // Pre-10.6 fallback: 't', 'y' or '1'-'9' is true; leading ' ', '+', '-' or '0' is skipped.
    if (![self length])
        return NO;
    unichar c = [[self lowercaseString] characterAtIndex:0];
    if (c == 't' || c == 'y' || (unichar)(c - '1') < 9)
        return YES;
    if ([self length] >= 2 && (unichar)(c - ' ') < 0x11 && ((0x12801U >> (c - ' ')) & 1))
        return [[self substringFromIndex:1] hyperBoolValue];
    return NO;
}

- (BOOL)hyperBooleanValue
{
    return [self isEqual:@"true"];
}

- (NSUInteger)hyperUnsignedValue
{
    unsigned int value = 0;
    sscanf([self cStringUsingEncoding:NSASCIIStringEncoding], "%u", &value);
    return value;
}

- (unsigned short)hyperUnicharValue
{
    unsigned int value = 0;
    sscanf([self cStringUsingEncoding:NSASCIIStringEncoding], "%x", &value);
    return (unsigned short)value;
}

@end
