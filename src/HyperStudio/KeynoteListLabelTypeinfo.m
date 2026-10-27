#import "KeynoteListLabelTypeinfo.h"

@implementation KeynoteListLabelTypeinfo

+ (id)romanStringComponentsDictionary
{
    static NSDictionary *components = nil;
    if (components == nil)
        components = [[NSDictionary dictionaryWithObjectsAndKeys:
            @"m", [NSNumber numberWithInt:1000], @"cm", [NSNumber numberWithInt:900],
            @"d", [NSNumber numberWithInt:500], @"cd", [NSNumber numberWithInt:400],
            @"c", [NSNumber numberWithInt:100], @"xc", [NSNumber numberWithInt:90],
            @"l", [NSNumber numberWithInt:50], @"xl", [NSNumber numberWithInt:40],
            @"x", [NSNumber numberWithInt:10], @"ix", [NSNumber numberWithInt:9],
            @"v", [NSNumber numberWithInt:5], @"iv", [NSNumber numberWithInt:4],
            @"i", [NSNumber numberWithInt:1], nil] retain];
    return components;
}

+ (id)numberingPrefixTypes
{
    static NSArray *types = nil;
    if (types == nil)
        types = [[NSArray arrayWithObjects:@"decimal", @"upper-roman", @"lower-roman", @"upper-alpha", @"lower-alpha", nil] retain];
    return types;
}

- (id)lowerRomanStringFromInt:(NSInteger)aInt
{
    NSMutableString *string = [NSMutableString string];
    NSDictionary *components = [[self class] romanStringComponentsDictionary];
    NSArray *values = [[components allKeys] sortedArrayUsingSelector:@selector(compare:)];
    NSInteger index = (NSInteger)[values count] - 1;
    NSInteger remaining = aInt;
    while (remaining > 0) {
        NSNumber *value = [values objectAtIndex:index];
        int amount = [value intValue];
        if (remaining - amount < 0) {
            index--;
        }
        else {
            [string appendString:[components objectForKey:value]];
            remaining -= amount;
        }
    }
    return string;
}

// Original quirk kept: multiples of 26 give a backquote, as the letter is 'a' - 1 + n % 26.
- (id)lowerAlphaStringFromInt:(NSInteger)aInt
{
    int value = (int)aInt;
    int repeat = value / 26;
    NSMutableString *string = [NSMutableString string];
    NSString *letter = [NSString stringWithFormat:@"%c", value + 0x60 - repeat * 26];
    for (int i = 0; i < repeat + 1; i++)
        [string appendString:letter];
    return string;
}

- (id)stringOfType:(id)aType fromInt:(NSInteger)aInt
{
    if ([aType isEqualToString:@"decimal"])
        return [NSString stringWithFormat:@"%d", (int)aInt];
    if ([aType isEqualToString:@"upper-roman"])
        return [[self lowerRomanStringFromInt:aInt] uppercaseString];
    if ([aType isEqualToString:@"lower-roman"])
        return [self lowerRomanStringFromInt:aInt];
    if ([aType isEqualToString:@"upper-alpha"])
        return [[self lowerAlphaStringFromInt:aInt] uppercaseString];
    if ([aType isEqualToString:@"lower-alpha"])
        return [self lowerAlphaStringFromInt:aInt];
    return nil;
}

// %P expands to the parent level's prefix, %L to this level's label; shouldModify advances the level's counter.
- (id)prefixOfType:(id)aType withFormat:(id)aFormat stringAttributes:(id)aAttributes listLevel:(NSInteger)aLevel shouldModify:(BOOL)aModify
{
    NSMutableString *prefix = [NSMutableString string];
    if (aLevel < 0)
        return prefix;
    NSNumber *level = [NSNumber numberWithInt:(int)aLevel];
    NSNumber *stored = [[[self topicsInfo] objectForKey:@"numbers"] objectForKey:level];
    int number;
    if (stored == nil) {
        id first = [aAttributes objectForKey:@"firstTopicNumber"];
        number = first ? [first intValue] : 1;
    }
    else {
        number = [stored intValue];
        if (aModify)
            number++;
    }
    NSString *label = [self stringOfType:aType fromInt:number];
    [prefix appendString:aFormat];
    if ([aFormat hasPrefix:@"%P"]) {
        NSString *parentFormat = [[[self topicsInfo] objectForKey:@"formats"] objectForKey:[NSNumber numberWithInt:(int)aLevel - 1]];
        NSString *parentPrefix = @"";
        if ([parentFormat hasPrefix:@"%"])
            parentPrefix = [self prefixOfType:aType withFormat:parentFormat stringAttributes:aAttributes listLevel:aLevel - 1 shouldModify:NO];
        [prefix replaceOccurrencesOfString:@"%P" withString:parentPrefix options:NSLiteralSearch range:NSMakeRange(0, [prefix length])];
    }
    // Fix: an unknown type leaves %L in place instead of raising on a nil label.
    if (label != nil)
        [prefix replaceOccurrencesOfString:@"%L" withString:label options:NSLiteralSearch range:NSMakeRange(0, [prefix length])];
    if (aModify) {
        [[[self topicsInfo] objectForKey:@"numbers"] setObject:[NSNumber numberWithInt:number] forKey:level];
        [[[self topicsInfo] objectForKey:@"formats"] setObject:aFormat forKey:level];
    }
    return prefix;
}

- (id)defaultPrefix
{
    return [[KeynoteTools stringWithKeynoteString:@"&#x2022;"] stringByAppendingString:@" "];
}

- (id)attributedPrefixFromPrefix:(id)aPrefix withStringAttributes:(id)aAttributes
{
    return [KeynoteTools attributedStringFromString:aPrefix withStringAttributes:aAttributes];
}

- (id)prefixWithStringAttributes:(id)aAttributes listLevel:(NSInteger)aLevel
{
    NSString *type = [[self nodeAttributes] objectForKey:@"type"];
    if ([type isEqualToString:@"none"])
        return [[[NSAttributedString alloc] initWithString:@""] autorelease];

    NSString *prefix = nil;
    if ([type isEqualToString:@"text"]) {
        NSDictionary *label = [[self keynoteObjectForXMLPath:@"./text-label"] nodeAttributes];
        if (label == nil) {
            id labelId = [[[self keynoteObjectForXMLPath:@"./text-label-ref"] nodeAttributes] objectForKey:@"IDREF"];
            label = [[[self cache] objectOfType:@"textLabel" inCacheForId:labelId] nodeAttributes];
        }
        NSString *labelType = [label objectForKey:@"type"];
        NSString *format = [label objectForKey:@"format"];
        if ([labelType isEqualToString:@"bullet"])
            prefix = [[KeynoteTools stringWithKeynoteString:format] stringByAppendingString:@" "];
        else if ([[[self class] numberingPrefixTypes] containsObject:labelType])
            prefix = [[self prefixOfType:labelType withFormat:format stringAttributes:aAttributes listLevel:aLevel shouldModify:YES] stringByAppendingString:@" "];
    }
    if (prefix == nil)
        prefix = [self defaultPrefix];
    return [self attributedPrefixFromPrefix:prefix withStringAttributes:aAttributes];
}

- (void)setTopicsInfo:(id)aInfo
{
    _topicsInfo = aInfo;
}

- (id)topicsInfo
{
    return _topicsInfo;
}

- (void)didInitFromParser
{
    [super didInitFromParser];
    [[self cache] addObject:self type:@"listLabelType" inCacheForId:[self nodeId]];
    if ([[[self nodeAttributes] objectForKey:@"type"] isEqualToString:@"text"]) {
        id label = [self keynoteObjectForXMLPath:@"./text-label"];
        if (label != nil)
            [[self cache] addObject:label type:@"textLabel" inCacheForId:[label nodeId]];
    }
}

@end
