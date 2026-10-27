#import "HSAttributeDictionaryReplacements.h"
#import "HSGradientColor.h"
#import "HSColor.h"
#import "NSColor+HSGradientColorSupport.h"
#import "NSShadow+HSExtensions.h"
#import "NSTextContainer+HSExtensions.h"
#import <objc/message.h>

// Within 0.0005 of the larger magnitude (a zero magnitude counting as 1),
// compared as floats.
static BOOL HSAttributeDictionaryReplacementsFloatsEqual(float aValue, float aValue2)
{
    float magnitude = aValue != 0.0f ? fabsf(aValue) : 1.0f;
    float magnitude2 = aValue2 != 0.0f ? fabsf(aValue2) : 1.0f;
    if (magnitude2 <= magnitude)
        magnitude2 = magnitude;
    return fabsf(aValue - aValue2) <= magnitude2 * 0.0005f;
}

// Attribute name -> replacement value; a removal is registered as the null
// value.
@implementation HSAttributeDictionaryReplacements

+ (id)nullValue
{
    static id nullValue = nil;
    if (nullValue == nil)
        nullValue = [[NSNull null] retain];
    return nullValue;
}

- (id)applyToDictionary:(id)aDictionary
{
    NSMutableDictionary *result = nil;
    NSEnumerator *names = [aDictionary keyEnumerator];
    id name;
    while ((name = [names nextObject]) != nil) {
        if (![self containsValueForAttributeName:name])
            continue;
        if (result == nil)
            result = [NSMutableDictionary dictionaryWithDictionary:aDictionary];
        id value = [self replacementValueForAttributeName:name];
        if (value != nil)
            [result setObject:value forKey:name];
        else
            [result removeObjectForKey:name];
    }
    return result != nil ? result : aDictionary;
}

- (void)addAttributeReplacements:(id)aReplacements
{
    if ([aReplacements isEmpty])
        return;
    NSEnumerator *names = [aReplacements attributeNamesEnumerator];
    id name;
    while ((name = [names nextObject]) != nil)
        [self registerValue:[aReplacements replacementValueForAttributeName:name] forAttributeName:name];
}

- (id)attributeNamesEnumerator
{
    return [_dictionary keyEnumerator];
}

- (id)replacementValueForAttributeName:(id)aName
{
    id value = [_dictionary objectForKey:aName];
    return value != [HSAttributeDictionaryReplacements nullValue] ? value : nil;
}

- (BOOL)containsValueForAttributeName:(id)aName
{
    return [_dictionary objectForKey:aName] != nil;
}

- (BOOL)isEmpty
{
    return [_dictionary count] == 0;
}

- (void)registerValue:(id)aValue forAttributeName:(id)aName
{
    if (aValue == nil)
        aValue = [HSAttributeDictionaryReplacements nullValue];
    [[self replacementsDictionary] setObject:aValue forKey:aName];
}

- (id)replacementsDictionary
{
    if (_dictionary == nil)
        _dictionary = [NSMutableDictionary new];
    return _dictionary;
}

- (void)dealloc
{
    [_dictionary release];
    [super dealloc];
}

- (id)initWithCapacity:(NSUInteger)aCapacity
{
    self = [self init];
    if (self != nil)
        _dictionary = [[NSMutableDictionary alloc] initWithCapacity:aCapacity];
    return self;
}

@end

// Replacements per attribute run of a range of an attributed string.
@implementation HSAttributedStringReplacements

+ (id)dataWithAttributeRangesInAttributedString:(id)aString limitedToRange:(NSRange)aRange ranges:(NSRange **)aRanges numberOfRanges:(unsigned int *)aRanges2 actualAttributeDictionaries:(id *)aDictionaries
{
    NSMutableData *data = [NSMutableData dataWithLength:16 * sizeof(NSRange)];
    NSMutableArray *dictionaries = [NSMutableArray new];
    NSRange *ranges = [data mutableBytes];
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    unsigned int count = 0;
    if (aRange.length != 0) {
        NSUInteger capacity = 16;
        NSUInteger index = aRange.location;
        do {
            if (count == capacity) {
                capacity *= 2;
                [data setLength:capacity * sizeof(NSRange)];
                ranges = [data mutableBytes];
            }
            NSRange effectiveRange = NSMakeRange(0, 0);
            id attributes = [aString attributesAtIndex:index effectiveRange:&effectiveRange];
            if (aDictionaries != NULL && attributes != nil)
                attributes = [NSDictionary dictionaryWithDictionary:attributes];
            effectiveRange = NSIntersectionRange(effectiveRange, aRange);
            ranges[count++] = effectiveRange;
            [dictionaries addObject:attributes];
            index = NSMaxRange(effectiveRange);
        } while (index - aRange.location < aRange.length);
    }
    if (count != 0) {
        [data setLength:count * sizeof(NSRange)];
        ranges = [data mutableBytes];
    } else {
        data = nil;
        ranges = NULL;
    }
    [pool release];
    if (aRanges != NULL)
        *aRanges = ranges;
    if (aRanges2 != NULL)
        *aRanges2 = count;
    if (aDictionaries != NULL)
        *aDictionaries = count == 0 ? nil : [NSArray arrayWithArray:dictionaries];
    [dictionaries release];
    return data;
}

- (void)cleanupAuxiliaryData
{
    [_actualAttributeDictionaries release];
    _actualAttributeDictionaries = nil;
}

- (id)allIncludedAttributes
{
    return [NSSet setWithObject:NSForegroundColorAttributeName];
}

- (void)addAttributeReplacements:(id)aReplacements atReplacementIndex:(NSUInteger)aIndex
{
    [[self replacementsAtReplacementIndex:aIndex] addAttributeReplacements:aReplacements];
}

- (BOOL)containsValueForAttributeName:(id)aName atReplacementIndex:(NSUInteger)aIndex
{
    return [[self replacementsAtReplacementIndex:aIndex] containsValueForAttributeName:aName];
}

- (void)registerValue:(id)aValue forAttributeName:(id)aName atReplacementIndex:(NSUInteger)aIndex
{
    [[self replacementsAtReplacementIndex:aIndex] registerValue:aValue forAttributeName:aName];
}

- (id)actualAttributesAtReplacementIndex:(NSUInteger)aIndex
{
    return [_actualAttributeDictionaries objectAtIndex:aIndex];
}

- (id)replacementValueForAttributeName:(id)aName atReplacementIndex:(NSUInteger)aIndex
{
    return [[self replacementsAtReplacementIndex:aIndex] replacementValueForAttributeName:aName];
}

- (id)attributeNamesEnumeratorAtReplacementIndex:(NSUInteger)aIndex
{
    return [[self replacementsAtReplacementIndex:aIndex] attributeNamesEnumerator];
}

- (BOOL)isEmpty
{
    NSUInteger count = [_replacementObjects count];
    for (NSUInteger index = 0; index < count; index++) {
        if (![[_replacementObjects objectAtIndex:index] isEmpty])
            return NO;
    }
    return YES;
}

// Created up to the index on first use.
- (id)replacementsAtReplacementIndex:(NSUInteger)aIndex
{
    if (aIndex >= [_replacementObjects count]) {
        if (_replacementObjects == nil)
            _replacementObjects = [[NSMutableArray alloc] initWithCapacity:_numberOfRanges];
        while (aIndex >= [_replacementObjects count]) {
            HSAttributeDictionaryReplacements *replacements = [HSAttributeDictionaryReplacements new];
            [_replacementObjects addObject:replacements];
            [replacements release];
        }
    }
    return [_replacementObjects objectAtIndex:aIndex];
}

- (NSRange)affectedRangeAtReplacementIndex:(NSUInteger)aIndex
{
    return _ranges[aIndex];
}

- (NSUInteger)numberOfReplacements
{
    return _numberOfRanges;
}

- (void)dealloc
{
    [_rangesData release];
    [_actualAttributeDictionaries release];
    [_replacementObjects release];
    [super dealloc];
}

- (id)initWithRange:(NSRange)aRange inAttributedString:(id)aString
{
    self = [super init];
    if (self != nil) {
        _wholeRange = aRange;
        _rangesData = [[[self class] dataWithAttributeRangesInAttributedString:aString limitedToRange:aRange ranges:&_ranges numberOfRanges:&_numberOfRanges actualAttributeDictionaries:&_actualAttributeDictionaries] retain];
        [_actualAttributeDictionaries retain];
    }
    return self;
}

@end

@implementation NSAttributedString (NSAttributedStringFittingExtension)

// Laid out in a container of the size; when the text doesn't fit, it's cut
// at the end of the last visible line and an ellipsis appended.
+ (id)textStorageFromAttributedString:(id)aString fittedToContainerSize:(NSSize)aSize
{
    NSTextStorage *storage = [[NSTextStorage alloc] init];
    NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
    NSTextContainer *container = [[NSTextContainer alloc] init];
    [layoutManager addTextContainer:container];
    [container release];
    [storage addLayoutManager:layoutManager];
    [layoutManager release];
    [container setContainerSize:aSize];
    [storage setAttributedString:aString];
    NSRange glyphRange = [layoutManager glyphRangeForTextContainer:container];
    // The original ran past an empty string's (nonexistent) last glyph.
    if (glyphRange.length == 0)
        return [storage autorelease];
    NSUInteger lastGlyph = NSMaxRange(glyphRange) - 1;
    NSRect lastLine = [layoutManager lineFragmentRectForGlyphAtIndex:lastGlyph effectiveRange:NULL];
    NSRange visibleGlyphs = [layoutManager glyphRangeForBoundingRect:lastLine inTextContainer:container];
    NSRange visibleCharacters = [layoutManager characterRangeForGlyphRange:visibleGlyphs actualGlyphRange:NULL];
    NSUInteger end = NSMaxRange(visibleCharacters);
    if (end != [aString length]) {
        NSMutableAttributedString *ellipsis = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%C", (unichar)0x2026]];
        NSDictionary *attributes = [aString attributesAtIndex:end - 1 effectiveRange:NULL];
        [ellipsis addAttributes:attributes range:NSMakeRange(0, [ellipsis length])];
        float ellipsisWidth = [ellipsis size].width;
        NSRect usedLine = [layoutManager lineFragmentUsedRectForGlyphAtIndex:lastGlyph effectiveRange:NULL];
        NSMutableAttributedString *truncated = [[aString attributedSubstringFromRange:NSMakeRange(0, end)] mutableCopy];
        float usedWidth = usedLine.size.width;
        if (ellipsisWidth > (float)lastLine.size.width - usedWidth) {
            // Backs up a glyph at a time until the ellipsis fits; one more
            // character than measured is removed, as in the original.
            NSInteger offset = -1;
            do {
                NSUInteger glyph = [layoutManager glyphRangeForCharacterRange:NSMakeRange(end + offset, 1) actualCharacterRange:NULL].location;
                usedWidth = [layoutManager locationForGlyphAtIndex:glyph].x;
                offset--;
            } while (ellipsisWidth > (float)lastLine.size.width - usedWidth);
            [truncated deleteCharactersInRange:NSMakeRange(end + offset, -offset)];
        }
        [truncated appendAttributedString:ellipsis];
        [storage setAttributedString:truncated];
        [truncated release];
        // The original leaked the ellipsis.
        [ellipsis release];
    }
    return [storage autorelease];
}

@end

@implementation NSMutableAttributedString (HSExtensions)

+ (id)hyperConvertAlignmentInParagraphStyle:(id)aStyle toAlignment:(NSUInteger)aAlignment
{
    if ([aStyle alignment] != (NSTextAlignment)aAlignment) {
        aStyle = [[aStyle mutableCopy] autorelease];
        [aStyle setAlignment:(NSTextAlignment)aAlignment];
    }
    return aStyle;
}

+ (id)hyperConvertLineSpacingInParagraphStyle:(id)aStyle toLineSpacing:(CGFloat)aSpacing
{
    if (!HSAttributeDictionaryReplacementsFloatsEqual([aStyle lineSpacing], aSpacing)) {
        aStyle = [[aStyle mutableCopy] autorelease];
        [aStyle setLineSpacing:aSpacing];
    }
    return aStyle;
}

// Line and paragraph spacing both set to the spacing.
+ (id)hyperConvertCombinedLineSpacingInParagraphStyle:(id)aStyle toLineSpacing:(CGFloat)aSpacing
{
    if (HSAttributeDictionaryReplacementsFloatsEqual([aStyle lineSpacing], aSpacing)
        && HSAttributeDictionaryReplacementsFloatsEqual([aStyle paragraphSpacing], aSpacing))
        return aStyle;
    NSMutableParagraphStyle *style = [[aStyle mutableCopy] autorelease];
    [style setLineSpacing:aSpacing];
    [style setParagraphSpacing:aSpacing];
    return style;
}

+ (id)hyperConvertFont:(id)aFont toSize:(CGFloat)aSize
{
    if (!HSAttributeDictionaryReplacementsFloatsEqual([aFont pointSize], aSize))
        aFont = [[NSFontManager sharedFontManager] convertFont:aFont toSize:aSize];
    return aFont;
}

+ (id)hyperConvertAlignmentInParagraphStyle:(id)aStyle toValue:(id)aValue
{
    return [self hyperConvertAlignmentInParagraphStyle:aStyle toAlignment:[aValue intValue]];
}

+ (id)hyperConvertLineSpacingInParagraphStyle:(id)aStyle toValue:(id)aValue
{
    return [self hyperConvertLineSpacingInParagraphStyle:aStyle toLineSpacing:[aValue floatValue]];
}

+ (id)hyperConvertCombinedLineSpacingInParagraphStyle:(id)aStyle toValue:(id)aValue
{
    return [self hyperConvertCombinedLineSpacingInParagraphStyle:aStyle toLineSpacing:[aValue floatValue]];
}

+ (id)hyperConvertShadow:(id)aShadow toHaveDistanceValue:(id)aValue
{
    return [self hyperConvertShadow:aShadow toHaveDistance:[aValue floatValue]];
}

+ (id)hyperConvertShadow:(id)aShadow toHaveAngleValue:(id)aValue
{
    return [self hyperConvertShadow:aShadow toHaveAngle:[aValue floatValue]];
}

+ (id)hyperConvertShadow:(id)aShadow toHaveBlurRadiusValue:(id)aValue
{
    return [self hyperConvertShadow:aShadow toHaveBlurRadius:[aValue floatValue]];
}

+ (id)hyperConvertShadow:(id)aShadow toHaveOffsetValue:(id)aValue
{
    return [self hyperConvertShadow:aShadow toHaveOffset:[aValue sizeValue]];
}

+ (id)hyperConvertShadow:(id)aShadow toHaveDistance:(CGFloat)aDistance
{
    if (aShadow == nil)
        return nil;
    return [self hyperConvertShadow:aShadow toHaveOffset:[aShadow hyperShadowOffsetForDistance:aDistance]];
}

+ (id)hyperConvertShadow:(id)aShadow forEnablingShadowWithDefaultValue:(id)aValue
{
    return aShadow != nil ? aShadow : aValue;
}

+ (id)hyperConvertShadow:(id)aShadow toHaveAngle:(CGFloat)aAngle
{
    if (aShadow == nil)
        return nil;
    return [self hyperConvertShadow:aShadow toHaveOffset:[aShadow hyperShadowOffsetForAngle:aAngle]];
}

+ (id)hyperConvertShadow:(id)aShadow toHaveBlurRadius:(CGFloat)aRadius
{
    if (aShadow != nil && !HSAttributeDictionaryReplacementsFloatsEqual([aShadow shadowBlurRadius], aRadius)) {
        aShadow = [[aShadow copy] autorelease];
        [aShadow setShadowBlurRadius:aRadius];
    }
    return aShadow;
}

+ (id)hyperConvertShadow:(id)aShadow toHaveOffset:(NSSize)aOffset
{
    if (aShadow == nil)
        return nil;
    NSSize offset = [aShadow shadowOffset];
    if (HSAttributeDictionaryReplacementsFloatsEqual(offset.width, aOffset.width)
        && HSAttributeDictionaryReplacementsFloatsEqual(offset.height, aOffset.height))
        return aShadow;
    NSShadow *shadow = [[aShadow copy] autorelease];
    [shadow setShadowOffset:aOffset];
    return shadow;
}

+ (id)hyperConvertFont:(id)aFont toFamilyInFont:(id)aFont2
{
    return [self hyperConvertFont:aFont toFamily:[aFont2 familyName]];
}

+ (id)hyperConvertFont:(id)aFont toFamily:(id)aFamily
{
    if (![[aFont familyName] isEqual:aFamily])
        aFont = [[NSFontManager sharedFontManager] convertFont:aFont toFamily:aFamily];
    return aFont;
}

+ (id)hyperConvertFont:(id)aFont toSizeValue:(id)aValue
{
    return [self hyperConvertFont:aFont toSize:[aValue floatValue]];
}

// The weight is looked up in the descriptor itself, where it isn't, so it's
// 0, as in the original.
+ (id)hyperConvertFont:(id)aFont toHaveTrait:(id)aTrait
{
    NSFontManager *manager = [NSFontManager sharedFontManager];
    NSFontTraitMask traits = [manager traitsOfFont:aFont];
    NSFontTraitMask trait = [aTrait unsignedIntValue];
    NSInteger weight = [[[aFont fontDescriptor] objectForKey:NSFontWeightTrait] intValue];
    return [manager fontWithFamily:[aFont familyName] traits:trait | traits weight:weight size:[aFont pointSize]];
}

// The trait is toggled, as in the original.
+ (id)hyperConvertFont:(id)aFont toNotHaveTrait:(id)aTrait
{
    NSFontManager *manager = [NSFontManager sharedFontManager];
    NSFontTraitMask traits = [manager traitsOfFont:aFont];
    NSFontTraitMask trait = [aTrait unsignedIntValue];
    NSInteger weight = [[[aFont fontDescriptor] objectForKey:NSFontWeightTrait] intValue];
    return [manager fontWithFamily:[aFont familyName] traits:trait ^ traits weight:weight size:[aFont pointSize]];
}

// Only the alignment of paragraph styles is supported; everything else is
// reset to the default.
- (void)hyperRemoveUnsupportedFormattingWithoutCheck
{
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    NSRange effectiveRange = NSMakeRange(0, 0);
    NSUInteger length = [self length];
    while (NSMaxRange(effectiveRange) < length) {
        NSParagraphStyle *current = [self attribute:NSParagraphStyleAttributeName atIndex:NSMaxRange(effectiveRange) effectiveRange:&effectiveRange];
        [style setAlignment:[current alignment]];
        // The original added the one mutable style it kept changing.
        NSParagraphStyle *value = [style copy];
        [self addAttribute:NSParagraphStyleAttributeName value:value range:effectiveRange];
        [value release];
    }
    [style release];
}

- (void)hyperRemoveUnsupportedFormatting
{
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    NSRange effectiveRange = NSMakeRange(0, 0);
    NSUInteger length = [self length];
    while (NSMaxRange(effectiveRange) < length) {
        NSParagraphStyle *current = [self attribute:NSParagraphStyleAttributeName atIndex:NSMaxRange(effectiveRange) effectiveRange:&effectiveRange];
        [style setAlignment:[current alignment]];
        if (![current isEqual:style]) {
            // The original added the one mutable style it kept changing.
            NSParagraphStyle *value = [style copy];
            [self addAttribute:NSParagraphStyleAttributeName value:value range:effectiveRange];
            [value release];
        }
    }
    [style release];
}

- (void)hyperApplyAttributeReplacements:(id)aReplacements range:(NSRange)aRange
{
    NSUInteger count = [aReplacements numberOfReplacements];
    for (NSUInteger index = 0; index < count; index++) {
        NSEnumerator *names = [aReplacements attributeNamesEnumeratorAtReplacementIndex:index];
        NSRange affectedRange = [aReplacements affectedRangeAtReplacementIndex:index];
        id name;
        while ((name = [names nextObject]) != nil)
            [self hyperApplyAttribute:name value:[aReplacements replacementValueForAttributeName:name atReplacementIndex:index] range:affectedRange];
    }
}

// The attribute takes the other attribute's values over the range.
- (void)hyperReplaceAttributeValues:(id)aValues withAttributeValues:(id)aValues2 inRange:(NSRange)aRange
{
    [self removeAttribute:aValues range:aRange];
    NSUInteger end = NSMaxRange(aRange);
    NSRange effectiveRange = NSMakeRange(aRange.location, 0);
    while (effectiveRange.location < end) {
        id value = [self attribute:aValues2 atIndex:effectiveRange.location longestEffectiveRange:&effectiveRange inRange:aRange];
        if (value != nil)
            [self addAttribute:aValues value:value range:effectiveRange];
        // The original skipped a character between runs.
        effectiveRange = NSMakeRange(NSMaxRange(effectiveRange), 0);
    }
}

- (void)hyperApplyAttribute:(id)aAttribute value:(id)aValue range:(NSRange)aRange
{
    if (aRange.length == 0)
        return;
    if (aValue != nil)
        [self addAttribute:aAttribute value:aValue range:aRange];
    else
        [self removeAttribute:aAttribute range:aRange];
}

- (void)hyperConvertActualAttribute:(id)aAttribute inRange:(NSRange)aRange toValue:(id)aValue convertAttributeSelector:(SEL)aSelector
{
    [self hyperConvertAttribute:aAttribute inRange:aRange toValue:aValue convertAttributeSelector:aSelector substituteWithDefaultValueIfNull:NO];
}

- (void)hyperConvertAttribute:(id)aAttribute inRange:(NSRange)aRange toValue:(id)aValue convertAttributeSelector:(SEL)aSelector
{
    [self hyperConvertAttribute:aAttribute inRange:aRange toValue:aValue convertAttributeSelector:aSelector substituteWithDefaultValueIfNull:YES];
}

// Each run's value is converted by the class method selector (value,
// argument) and applied where it changed.
- (void)hyperConvertAttribute:(id)aAttribute inRange:(NSRange)aRange toValue:(id)aValue convertAttributeSelector:(SEL)aSelector substituteWithDefaultValueIfNull:(BOOL)aNull
{
    [self beginEditing];
    NSRange effectiveRange = NSMakeRange(aRange.location, 0);
    if (aRange.length != 0) {
        NSUInteger index = aRange.location;
        do {
            id value = [self attribute:aAttribute atIndex:index effectiveRange:&effectiveRange];
            if (value == nil && aNull)
                value = [NSAttributedString hyperNullValueForAttribute:aAttribute];
            id converted = ((id (*)(id, SEL, id, id))objc_msgSend)([NSMutableAttributedString class], aSelector, value, aValue);
            if (converted != value)
                [self hyperApplyAttribute:aAttribute value:converted range:NSIntersectionRange(effectiveRange, aRange)];
            index = NSMaxRange(effectiveRange);
        } while (index - aRange.location < aRange.length);
    }
    [self endEditing];
}

@end

@implementation NSAttributedString (HSExtensions)

+ (id)hyperActualAttribute:(id)aAttribute fromDictionary:(id)aDictionary
{
    return [self hyperAttribute:aAttribute fromDictionary:aDictionary substituteWithDefaultValueIfNull:NO];
}

+ (id)hyperAttribute:(id)aAttribute fromDictionary:(id)aDictionary
{
    return [self hyperAttribute:aAttribute fromDictionary:aDictionary substituteWithDefaultValueIfNull:YES];
}

+ (id)hyperAttribute:(id)aAttribute fromDictionary:(id)aDictionary substituteWithDefaultValueIfNull:(BOOL)aNull
{
    id value = [aDictionary objectForKey:aAttribute];
    if (value == nil && aNull)
        value = [NSAttributedString hyperNullValueForAttribute:aAttribute];
    return value;
}

+ (id)hyperNullAttributes
{
    return [NSDictionary dictionaryWithObject:[self hyperNullValueForAttribute:NSFontAttributeName] forKey:NSFontAttributeName];
}

// What an attribute that isn't set amounts to.
+ (id)hyperNullValueForAttribute:(id)aAttribute
{
    static NSDictionary *nullValues = nil;
    if (nullValues == nil) {
        nullValues = [[NSDictionary alloc] initWithObjectsAndKeys:
            [NSFont userFontOfSize:13.0], NSFontAttributeName,
            [NSParagraphStyle defaultParagraphStyle], NSParagraphStyleAttributeName,
            [NSColor blackColor], NSForegroundColorAttributeName,
            [NSNumber numberWithInt:0], NSSuperscriptAttributeName,
            [NSNumber numberWithInt:0], NSUnderlineStyleAttributeName,
            [NSNumber numberWithInt:1], NSLigatureAttributeName,
            [NSNumber numberWithFloat:0.0f], NSBaselineOffsetAttributeName,
            [NSNumber numberWithFloat:0.0f], NSKernAttributeName,
            [NSShadow hyperShadowWithDefaultSettingsForTextObject], NSShadowAttributeName,
            nil];
    }
    return [nullValues objectForKey:aAttribute];
}

+ (BOOL)isHyperAttribute:(id)aAttribute equalToAttribute:(id)aAttribute2
{
    if (aAttribute == aAttribute2 || (aAttribute != nil && [aAttribute2 isEqual:aAttribute]))
        return YES;
    if (aAttribute2 == nil)
        return NO;
    return [aAttribute isEqual:aAttribute2];
}

+ (BOOL)isHyperLineSpacingInParagraphStyle:(id)aStyle equalToParagraphStyle:(id)aStyle2
{
    return HSAttributeDictionaryReplacementsFloatsEqual([aStyle lineSpacing], [aStyle2 lineSpacing]);
}

// The first style's line spacing is also compared with the second's
// paragraph spacing, as in the original.
+ (BOOL)isHyperCombinedLineSpacingInParagraphStyle:(id)aStyle equalToParagraphStyle:(id)aStyle2
{
    float lineSpacing = [aStyle lineSpacing];
    float paragraphSpacing = [aStyle paragraphSpacing];
    float lineSpacing2 = [aStyle2 lineSpacing];
    float paragraphSpacing2 = [aStyle2 paragraphSpacing];
    return HSAttributeDictionaryReplacementsFloatsEqual(lineSpacing, lineSpacing2)
        && HSAttributeDictionaryReplacementsFloatsEqual(paragraphSpacing, paragraphSpacing2)
        && HSAttributeDictionaryReplacementsFloatsEqual(lineSpacing, paragraphSpacing2);
}

+ (BOOL)isHyperTextAlignmentInParagraphStyle:(id)aStyle equalToParagraphStyle:(id)aStyle2
{
    return [aStyle alignment] == [aStyle2 alignment];
}

+ (BOOL)isHyperExpandedInFont:(id)aFont equalToExpandedInFont:(id)aFont2
{
    NSFontManager *manager = [NSFontManager sharedFontManager];
    return (([manager traitsOfFont:aFont] ^ [manager traitsOfFont:aFont2]) & NSExpandedFontMask) == 0;
}

+ (BOOL)isHyperCondensedInFont:(id)aFont equalToCondensedInFont:(id)aFont2
{
    NSFontManager *manager = [NSFontManager sharedFontManager];
    return (([manager traitsOfFont:aFont] ^ [manager traitsOfFont:aFont2]) & NSCondensedFontMask) == 0;
}

+ (BOOL)isHyperItalicInFont:(id)aFont equalToItalicInFont:(id)aFont2
{
    NSFontManager *manager = [NSFontManager sharedFontManager];
    return (([manager traitsOfFont:aFont] ^ [manager traitsOfFont:aFont2]) & NSItalicFontMask) == 0;
}

+ (BOOL)isHyperBoldInFont:(id)aFont equalToBoldInFont:(id)aFont2
{
    NSFontManager *manager = [NSFontManager sharedFontManager];
    return (([manager traitsOfFont:aFont] ^ [manager traitsOfFont:aFont2]) & NSBoldFontMask) == 0;
}

+ (BOOL)isHyperFamilyOfFont:(id)aFont equalToFamilyOfFont:(id)aFont2
{
    return [[aFont familyName] isEqual:[aFont2 familyName]];
}

+ (BOOL)isHyperSizeOfFont:(id)aFont equalToSizeOfFont:(id)aFont2
{
    return HSAttributeDictionaryReplacementsFloatsEqual([aFont pointSize], [aFont2 pointSize]);
}

// Replacements turning the attributes into the other ones; nil when they're
// the same.
+ (id)hyperAttributeValuesForChangingAttributes:(id)aAttributes intoAttributes:(id)aAttributes2
{
    NSMutableSet *names = [NSMutableSet setWithArray:aAttributes != nil ? [aAttributes allKeys] : [NSArray array]];
    if (aAttributes2 != nil)
        [names addObjectsFromArray:[aAttributes2 allKeys]];
    HSAttributeDictionaryReplacements *replacements = nil;
    for (id name in names) {
        id value = [aAttributes objectForKey:name];
        id value2 = [aAttributes2 objectForKey:name];
        if (value != value2) {
            if (replacements == nil)
                replacements = [[[HSAttributeDictionaryReplacements alloc] initWithCapacity:[names count]] autorelease];
            [replacements registerValue:value2 forAttributeName:name];
        }
    }
    return replacements;
}

// Other attributes that change along with applying one: those following the
// text color, and the outline color and stored width with the outline.
+ (id)hyperAttributeValuesAffectedByApplyingAttribute:(id)aAttribute value:(id)aValue inDictionary:(id)aDictionary
{
    if ([aAttribute isEqualToString:NSForegroundColorAttributeName])
        return [self hyperAttributeValuesAffectedByChangingForegroundColorTo:aValue inDictionary:aDictionary];
    if ([aAttribute isEqualToString:NSStrokeWidthAttributeName])
        return [self hyperAttributeValuesAffectedByApplyingOutlineValue:aValue inDictionary:aDictionary];
    return nil;
}

// The default outline value enables the outline (restoring a stored width);
// a zero width disables it, keeping the old width in the stored attribute.
+ (id)hyperAttributeValuesAffectedByApplyingOutlineValue:(id)aValue inDictionary:(id)aDictionary
{
    id enablingValue = [self hyperDefaultOutlineValueForEnablingOutline];
    id width;
    if (enablingValue == aValue)
        width = [self hyperOutlineValueForEnablingOutlineInAttributeDictionary:aDictionary];
    else
        width = HSAttributeDictionaryReplacementsFloatsEqual([aValue floatValue], 0.0f) ? nil : aValue;
    id currentWidth = [aDictionary objectForKey:NSStrokeWidthAttributeName];
    if (HSAttributeDictionaryReplacementsFloatsEqual([currentWidth floatValue], 0.0f))
        currentWidth = nil;
    HSAttributeDictionaryReplacements *replacements;
    if (width == nil) {
        if (currentWidth == nil)
            return nil;
        replacements = [[[HSAttributeDictionaryReplacements alloc] initWithCapacity:0] autorelease];
        [replacements registerValue:currentWidth forAttributeName:HSStoredStrokeWidthAttributeName];
        [replacements registerValue:nil forAttributeName:NSStrokeWidthAttributeName];
    } else {
        id storedWidth = [aDictionary objectForKey:HSStoredStrokeWidthAttributeName];
        id strokeColor = [aDictionary objectForKey:NSStrokeColorAttributeName];
        if (enablingValue != aValue && storedWidth == nil && strokeColor != nil)
            return nil;
        replacements = [[[HSAttributeDictionaryReplacements alloc] initWithCapacity:0] autorelease];
        if (storedWidth != nil)
            [replacements registerValue:nil forAttributeName:HSStoredStrokeWidthAttributeName];
        if (strokeColor == nil)
            [replacements registerValue:[self hyperDefaultOutlineColorValue] forAttributeName:NSStrokeColorAttributeName];
    }
    if (![replacements isEmpty] || enablingValue == aValue)
        [replacements registerValue:width forAttributeName:NSStrokeWidthAttributeName];
    return replacements;
}

+ (id)hyperOutlineValueForEnablingOutlineInAttributeDictionary:(id)aDictionary
{
    id width = [aDictionary objectForKey:HSStoredStrokeWidthAttributeName];
    if (width == nil)
        width = [NSNumber numberWithFloat:-3.0f];
    return width;
}

// A unique object; applying it as the outline width enables the outline.
+ (id)hyperDefaultOutlineValueForEnablingOutline
{
    static id value = nil;
    if (value == nil)
        value = [[NSString alloc] initWithString:@"0.0"];
    return value;
}

+ (id)hyperDefaultOutlineColorValue
{
    return [NSColor colorWithCalibratedRed:0.11f green:0.15f blue:0.31f alpha:1.0f];
}

// A gradient text color is drawn by the gradient, so the text color becomes
// a transparent clone and the dependent colors (that were unset or followed
// the old gradient) take the gradient; going back to a plain color clears
// them.
+ (id)hyperAttributeValuesAffectedByChangingForegroundColorTo:(id)aTo inDictionary:(id)aDictionary
{
    id currentColor = [aDictionary objectForKey:NSForegroundColorAttributeName];
    id dependentValue = aTo;
    id foregroundValue;
    if ([aTo hyperGradientColor] != nil) {
        foregroundValue = [[aTo hyperGradientColor] clonedTransparentColor];
    } else {
        if ([currentColor hyperGradientColor] == nil)
            return nil;
        foregroundValue = aTo;
        dependentValue = nil;
    }
    NSArray *names = [NSAttributedString hyperAttributesDependentOnForegroundColor];
    NSUInteger count = [names count];
    BOOL currentIsGradient = [currentColor hyperGradientColor] != nil;
    if (count == 0)
        return nil;
    HSAttributeDictionaryReplacements *replacements = nil;
    NSUInteger remaining = count;
    for (NSUInteger index = 0; index < count; index++, remaining--) {
        id name = [names objectAtIndex:index];
        id value = [aDictionary objectForKey:name];
        if (value == nil || (currentIsGradient && [currentColor isEqual:value])) {
            if (replacements == nil)
                replacements = [[[HSAttributeDictionaryReplacements alloc] initWithCapacity:remaining] autorelease];
            [replacements registerValue:dependentValue forAttributeName:name];
        }
    }
    if (replacements != nil && ![replacements isEmpty])
        [replacements registerValue:foregroundValue forAttributeName:NSForegroundColorAttributeName];
    return replacements;
}

+ (id)hyperAttributesDependentOnForegroundColor
{
    static NSArray *names = nil;
    if (names == nil)
        names = [[NSArray alloc] initWithObjects:NSStrokeColorAttributeName, NSUnderlineColorAttributeName, NSStrikethroughColorAttributeName, nil];
    return names;
}

- (id)hyperActualAttribute:(id)aAttribute inRange:(NSRange)aRange appliedToWholeRange:(BOOL *)aRange2 comparator:(SEL)aComparator
{
    return [self hyperAttribute:aAttribute inRange:aRange appliedToWholeRange:aRange2 comparator:aComparator substituteWithDefaultValueIfNull:NO];
}

- (id)hyperAttribute:(id)aAttribute inRange:(NSRange)aRange appliedToWholeRange:(BOOL *)aRange2 comparator:(SEL)aComparator
{
    return [self hyperAttribute:aAttribute inRange:aRange appliedToWholeRange:aRange2 comparator:aComparator substituteWithDefaultValueIfNull:YES];
}

// The value at the start of the range. Despite its name, the flag is set
// when the range has differing values (compared by the class method
// comparator, or isHyperAttribute:equalToAttribute:); without a flag the
// rest of the range isn't looked at. A gradient text color counts as its
// original color.
- (id)hyperAttribute:(id)aAttribute inRange:(NSRange)aRange appliedToWholeRange:(BOOL *)aRange2 comparator:(SEL)aComparator substituteWithDefaultValueIfNull:(BOOL)aNull
{
    BOOL isTextColor = [aAttribute isEqual:NSForegroundColorAttributeName];
    if (aRange.length == 0) {
        id value = aNull ? [NSAttributedString hyperNullValueForAttribute:aAttribute] : nil;
        if (aRange2 != NULL)
            *aRange2 = NO;
        return value;
    }
    NSRange effectiveRange = NSMakeRange(aRange.location, 0);
    id firstActualValue = nil;
    id firstValue = nil;
    BOOL differs = NO;
    NSUInteger index = aRange.location;
    while (index - aRange.location < aRange.length && index < [self length]) {
        id actualValue = [self attribute:aAttribute atIndex:index effectiveRange:&effectiveRange];
        if (isTextColor && [actualValue hyperGradientColor] != nil)
            actualValue = [[actualValue hyperGradientColor] originalColor];
        if (effectiveRange.location <= aRange.location) {
            id value = actualValue;
            if (value == nil && aNull)
                value = [NSAttributedString hyperNullValueForAttribute:aAttribute];
            if (aRange2 == NULL)
                return value;
            firstActualValue = actualValue;
            firstValue = value;
        } else if (firstActualValue != actualValue) {
            id value = actualValue;
            if (value == nil && aNull)
                value = [NSAttributedString hyperNullValueForAttribute:aAttribute];
            BOOL equal;
            if (aComparator != NULL)
                equal = ((BOOL (*)(id, SEL, id, id))objc_msgSend)([NSAttributedString class], aComparator, firstValue, value);
            else
                equal = [NSAttributedString isHyperAttribute:firstValue equalToAttribute:value];
            if (!equal) {
                differs = YES;
                break;
            }
        }
        index = NSMaxRange(effectiveRange);
    }
    if (aRange2 != NULL)
        *aRange2 = differs;
    return firstValue;
}

- (id)hyperAttributedStringByRemovingUnsupportedFormatting
{
    if (![self hyperHasUnsupportedFormatting])
        return self;
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithAttributedString:self];
    [string hyperRemoveUnsupportedFormattingWithoutCheck];
    return [string autorelease];
}

- (BOOL)hyperHasUnsupportedFormatting
{
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    NSRange effectiveRange = NSMakeRange(0, 0);
    NSUInteger length = [self length];
    BOOL unsupported = NO;
    while (NSMaxRange(effectiveRange) < length) {
        NSParagraphStyle *current = [self attribute:NSParagraphStyleAttributeName atIndex:NSMaxRange(effectiveRange) effectiveRange:&effectiveRange];
        [style setAlignment:[current alignment]];
        if (![current isEqual:style]) {
            unsupported = YES;
            break;
        }
    }
    [style release];
    return unsupported;
}

- (id)hyperAttributedStringByConvertingGradientColorsToSolidColors
{
    NSUInteger length = [self length];
    if (length == 0)
        return self;
    NSMutableAttributedString *result = nil;
    NSUInteger index = 0;
    do {
        NSRange effectiveRange = NSMakeRange(0, 0);
        id color = [self attribute:NSForegroundColorAttributeName atIndex:index effectiveRange:&effectiveRange];
        if ([color hyperGradientColor] != nil) {
            if (result == nil)
                result = [[self mutableCopy] autorelease];
            [result addAttribute:NSForegroundColorAttributeName value:[[[color hyperGradientColor] hyperHSColor] hyperStartColor] range:effectiveRange];
        }
        index = NSMaxRange(effectiveRange);
    } while (index < length);
    return result != nil ? result : self;
}

// The color where no text color is set.
- (id)hyperAttributedStringByApplyingColor:(id)aColor
{
    NSUInteger length = [self length];
    if (aColor == nil || length == 0)
        return self;
    NSMutableAttributedString *result = nil;
    NSUInteger index = 0;
    do {
        NSRange effectiveRange = NSMakeRange(0, 0);
        id color = [self attribute:NSForegroundColorAttributeName atIndex:index effectiveRange:&effectiveRange];
        if (color == nil) {
            if (result == nil)
                result = [[self mutableCopy] autorelease];
            [result addAttribute:NSForegroundColorAttributeName value:aColor range:effectiveRange];
        }
        index = NSMaxRange(effectiveRange);
    } while (index < length);
    return result != nil ? result : self;
}

// Replacements for the attribute converter (a font panel's), with the text
// color's and outline's dependent attributes.
- (id)hyperReplacementsForAttributesInRange:(NSRange)aRange forAttributesWithAttributesConverter:(id)aConverter
{
    HSAttributedStringReplacements *replacements = [[HSAttributedStringReplacements alloc] initWithRange:aRange inAttributedString:self];
    NSUInteger count = [replacements numberOfReplacements];
    for (NSUInteger index = 0; index < count; index++) {
        NSDictionary *attributes = [replacements actualAttributesAtReplacementIndex:index];
        NSDictionary *converted = [aConverter convertAttributes:attributes];
        HSAttributeDictionaryReplacements *changes = [NSAttributedString hyperAttributeValuesForChangingAttributes:attributes intoAttributes:converted];
        if (changes == nil || [changes isEmpty] || converted == attributes)
            continue;
        BOOL changesColor = [changes containsValueForAttributeName:NSForegroundColorAttributeName];
        id color = changesColor ? [changes replacementValueForAttributeName:NSForegroundColorAttributeName] : nil;
        BOOL changesOutline = [changes containsValueForAttributeName:NSStrokeWidthAttributeName];
        id outline = changesOutline ? [changes replacementValueForAttributeName:NSStrokeWidthAttributeName] : nil;
        if (changesColor)
            [changes addAttributeReplacements:[NSAttributedString hyperAttributeValuesAffectedByChangingForegroundColorTo:color inDictionary:attributes]];
        if (changesOutline)
            [changes addAttributeReplacements:[NSAttributedString hyperAttributeValuesAffectedByApplyingOutlineValue:outline inDictionary:attributes]];
        [replacements addAttributeReplacements:changes atReplacementIndex:index];
    }
    [replacements cleanupAuxiliaryData];
    if ([replacements isEmpty]) {
        [replacements release];
        replacements = nil;
    }
    return [replacements autorelease];
}

- (id)hyperReplacementsForAttributesInRange:(NSRange)aRange forFontWithFontConverter:(id)aConverter
{
    HSAttributedStringReplacements *replacements = [[HSAttributedStringReplacements alloc] initWithRange:aRange inAttributedString:self];
    NSUInteger count = [replacements numberOfReplacements];
    for (NSUInteger index = 0; index < count; index++) {
        id font = [[replacements actualAttributesAtReplacementIndex:index] objectForKey:NSFontAttributeName];
        if (font == nil)
            continue;
        id converted = [aConverter convertFont:font];
        if (converted != font)
            [replacements registerValue:converted forAttributeName:NSFontAttributeName atReplacementIndex:index];
    }
    [replacements cleanupAuxiliaryData];
    if ([replacements isEmpty]) {
        [replacements release];
        replacements = nil;
    }
    return [replacements autorelease];
}

- (id)hyperReplacementsForAttributesInRange:(NSRange)aRange forApplyingOutlineValue:(id)aValue
{
    return [self hyperReplacementsAttributesInRange:aRange forApplyingAttribute:NSStrokeWidthAttributeName value:aValue replaceIfAny:NO withValue:nil];
}

- (id)hyperReplacementsForForegroundColorDependentAttributesInRange:(NSRange)aRange forApplyingForegroundColor:(id)aColor
{
    id transparent = [[aColor hyperGradientColor] clonedTransparentColor];
    return [self hyperReplacementsAttributesInRange:aRange forApplyingAttribute:NSForegroundColorAttributeName value:aColor replaceIfAny:YES withValue:transparent];
}

// Only once a run's dependent attributes change is the attribute applied:
// to that run and the earlier ones, and then to each later run (with the
// other value when replacing any, otherwise only where it isn't set).
- (id)hyperReplacementsAttributesInRange:(NSRange)aRange forApplyingAttribute:(id)aAttribute value:(id)aValue replaceIfAny:(BOOL)aAny withValue:(id)aValue2
{
    HSAttributedStringReplacements *replacements = [[HSAttributedStringReplacements alloc] initWithRange:aRange inAttributedString:self];
    NSUInteger count = [replacements numberOfReplacements];
    BOOL applying = NO;
    for (NSUInteger index = 0; index < count; index++) {
        NSDictionary *attributes = [replacements actualAttributesAtReplacementIndex:index];
        HSAttributeDictionaryReplacements *affected = [NSAttributedString hyperAttributeValuesAffectedByApplyingAttribute:aAttribute value:aValue inDictionary:attributes];
        if (affected != nil && ![affected isEmpty]) {
            if (!applying) {
                for (NSUInteger earlier = 0; earlier < index; earlier++) {
                    if (aAny)
                        [replacements registerValue:aValue2 forAttributeName:aAttribute atReplacementIndex:earlier];
                    else if (![replacements containsValueForAttributeName:aAttribute atReplacementIndex:earlier])
                        [replacements registerValue:aValue forAttributeName:aAttribute atReplacementIndex:earlier];
                }
                applying = YES;
            }
            [replacements addAttributeReplacements:affected atReplacementIndex:index];
        } else if (applying) {
            if (aAny)
                [replacements registerValue:aValue2 forAttributeName:aAttribute atReplacementIndex:index];
            else if (![replacements containsValueForAttributeName:aAttribute atReplacementIndex:index])
                [replacements registerValue:aValue forAttributeName:aAttribute atReplacementIndex:index];
        }
    }
    [replacements cleanupAuxiliaryData];
    if ([replacements isEmpty]) {
        [replacements release];
        replacements = nil;
    }
    return [replacements autorelease];
}

// The attributes at the range's start (or insertion point), and whether they
// change within the range.
- (void)getHyperAttributesDictionary:(id *)aDictionary inRange:(NSRange)aRange multipleValues:(BOOL *)aValues
{
    NSDictionary *dictionary = nil;
    if (aRange.length == 0) {
        if (aRange.location < [self length]) {
            NSDictionary *attributes = [self attributesAtIndex:aRange.location effectiveRange:NULL];
            if (attributes != nil)
                dictionary = [[[NSDictionary alloc] initWithDictionary:attributes] autorelease];
        } else {
            dictionary = [NSAttributedString hyperNullAttributes];
        }
        if (aValues != NULL)
            *aValues = NO;
    } else {
        NSRange effectiveRange = NSMakeRange(0, 0);
        NSDictionary *attributes = [self attributesAtIndex:aRange.location effectiveRange:&effectiveRange];
        if (attributes != nil)
            dictionary = [[[NSDictionary alloc] initWithDictionary:attributes] autorelease];
        if (aValues != NULL)
            *aValues = NSMaxRange(effectiveRange) < NSMaxRange(aRange);
    }
    *aDictionary = dictionary;
}

- (void)getHyperSpaceBetweenCharacters:(float *)aCharacters inRange:(NSRange)aRange multipleValues:(BOOL *)aValues
{
    id kern = [self hyperAttribute:NSKernAttributeName inRange:aRange appliedToWholeRange:aValues comparator:NULL];
    *aCharacters = kern != nil ? [kern floatValue] : 0.0f;
}

- (void)getHyperSpaceBetweenLines:(float *)aLines inRange:(NSRange)aRange multipleValues:(BOOL *)aValues
{
    id style = [self hyperAttribute:NSParagraphStyleAttributeName inRange:aRange appliedToWholeRange:aValues comparator:@selector(isHyperLineSpacingInParagraphStyle:equalToParagraphStyle:)];
    *aLines = [style lineSpacing];
}

- (void)getHyperTextAlignment:(unsigned int *)aAlignment inRange:(NSRange)aRange multipleValues:(BOOL *)aValues
{
    id style = [self hyperAttribute:NSParagraphStyleAttributeName inRange:aRange appliedToWholeRange:aValues comparator:@selector(isHyperTextAlignmentInParagraphStyle:equalToParagraphStyle:)];
    *aAlignment = (unsigned int)[style alignment];
}

- (void)getHyperTextColor:(id *)aColor inRange:(NSRange)aRange multipleValues:(BOOL *)aValues
{
    *aColor = [self hyperAttribute:NSForegroundColorAttributeName inRange:aRange appliedToWholeRange:aValues comparator:NULL];
}

- (void)getHyperShadowDistance:(float *)aDistance inRange:(NSRange)aRange multipleValues:(BOOL *)aValues
{
    NSShadow *shadow = [self hyperAttribute:NSShadowAttributeName inRange:aRange appliedToWholeRange:aValues comparator:NULL];
    *aDistance = shadow != nil ? [NSShadow hyperShadowDistanceWithShadowOffset:[shadow shadowOffset]] : 0.0f;
}

- (void)getHyperShadowOffset:(NSSize *)aOffset inRange:(NSRange)aRange multipleValues:(BOOL *)aValues
{
    NSShadow *shadow = [self hyperAttribute:NSShadowAttributeName inRange:aRange appliedToWholeRange:aValues comparator:NULL];
    *aOffset = shadow != nil ? [shadow shadowOffset] : NSZeroSize;
}

- (void)getHyperShadowBlurRadius:(float *)aRadius inRange:(NSRange)aRange multipleValues:(BOOL *)aValues
{
    NSShadow *shadow = [self hyperAttribute:NSShadowAttributeName inRange:aRange appliedToWholeRange:aValues comparator:NULL];
    *aRadius = shadow != nil ? [shadow shadowBlurRadius] : 0.0f;
}

- (void)getHyperShadowAngle:(float *)aAngle inRange:(NSRange)aRange multipleValues:(BOOL *)aValues
{
    NSShadow *shadow = [self hyperAttribute:NSShadowAttributeName inRange:aRange appliedToWholeRange:aValues comparator:NULL];
    *aAngle = shadow != nil ? [NSShadow hyperShadowAngleWithShadowOffset:[shadow shadowOffset]] : 0.0f;
}

- (void)getHyperShadowEnabled:(BOOL *)aEnabled inRange:(NSRange)aRange multipleValues:(BOOL *)aValues
{
    *aEnabled = [self hyperActualAttribute:NSShadowAttributeName inRange:aRange appliedToWholeRange:aValues comparator:NULL] != nil;
}

- (void)getHyperShadow:(id *)aShadow inRange:(NSRange)aRange multipleValues:(BOOL *)aValues
{
    *aShadow = [self hyperAttribute:NSShadowAttributeName inRange:aRange appliedToWholeRange:aValues comparator:NULL];
}

- (void)getHyperOutlineColor:(id *)aColor inRange:(NSRange)aRange multipleValues:(BOOL *)aValues
{
    id color = [self hyperAttribute:NSStrokeColorAttributeName inRange:aRange appliedToWholeRange:aValues comparator:NULL];
    if (color == nil)
        color = [NSAttributedString hyperDefaultOutlineColorValue];
    *aColor = color;
}

- (void)getHyperOutlineWidth:(float *)aWidth inRange:(NSRange)aRange multipleValues:(BOOL *)aValues
{
    id width = [self hyperAttribute:NSStrokeWidthAttributeName inRange:aRange appliedToWholeRange:aValues comparator:NULL];
    *aWidth = width != nil ? [width floatValue] : 0.0f;
}

- (void)getHyperOutlineEnabled:(BOOL *)aEnabled inRange:(NSRange)aRange multipleValues:(BOOL *)aValues
{
    id width = [self hyperAttribute:NSStrokeWidthAttributeName inRange:aRange appliedToWholeRange:aValues comparator:NULL];
    *aEnabled = width != nil && [width intValue] != 0;
}

- (void)getHyperExpanded:(BOOL *)aExpanded inRange:(NSRange)aRange multipleValues:(BOOL *)aValues
{
    id font = [self hyperAttribute:NSFontAttributeName inRange:aRange appliedToWholeRange:aValues comparator:@selector(isHyperExpandedInFont:equalToExpandedInFont:)];
    *aExpanded = ([[NSFontManager sharedFontManager] traitsOfFont:font] & NSExpandedFontMask) != 0;
}

- (void)getHyperCondensed:(BOOL *)aCondensed inRange:(NSRange)aRange multipleValues:(BOOL *)aValues
{
    id font = [self hyperAttribute:NSFontAttributeName inRange:aRange appliedToWholeRange:aValues comparator:@selector(isHyperCondensedInFont:equalToCondensedInFont:)];
    *aCondensed = ([[NSFontManager sharedFontManager] traitsOfFont:font] & NSCondensedFontMask) != 0;
}

- (void)getHyperUnderlined:(BOOL *)aUnderlined inRange:(NSRange)aRange multipleValues:(BOOL *)aValues
{
    id style = [self hyperAttribute:NSUnderlineStyleAttributeName inRange:aRange appliedToWholeRange:aValues comparator:NULL];
    *aUnderlined = style != nil && [style intValue] != 0;
}

- (void)getHyperItalic:(BOOL *)aItalic inRange:(NSRange)aRange multipleValues:(BOOL *)aValues
{
    id font = [self hyperAttribute:NSFontAttributeName inRange:aRange appliedToWholeRange:aValues comparator:@selector(isHyperItalicInFont:equalToItalicInFont:)];
    *aItalic = ([[NSFontManager sharedFontManager] traitsOfFont:font] & NSItalicFontMask) != 0;
}

- (void)getHyperBold:(BOOL *)aBold inRange:(NSRange)aRange multipleValues:(BOOL *)aValues
{
    id font = [self hyperAttribute:NSFontAttributeName inRange:aRange appliedToWholeRange:aValues comparator:@selector(isHyperBoldInFont:equalToBoldInFont:)];
    *aBold = ([[NSFontManager sharedFontManager] traitsOfFont:font] & NSBoldFontMask) != 0;
}

- (void)getHyperFontSize:(float *)aSize inRange:(NSRange)aRange multipleValues:(BOOL *)aValues
{
    id font = [self hyperAttribute:NSFontAttributeName inRange:aRange appliedToWholeRange:aValues comparator:@selector(isHyperSizeOfFont:equalToSizeOfFont:)];
    *aSize = [font pointSize];
}

- (void)getHyperFontFamily:(id *)aFamily inRange:(NSRange)aRange multipleValues:(BOOL *)aValues
{
    id font = [self hyperAttribute:NSFontAttributeName inRange:aRange appliedToWholeRange:aValues comparator:@selector(isHyperFamilyOfFont:equalToFamilyOfFont:)];
    *aFamily = [font familyName];
}

- (void)getHyperFont:(id *)aFont inRange:(NSRange)aRange multipleValues:(BOOL *)aValues
{
    *aFont = [self hyperAttribute:NSFontAttributeName inRange:aRange appliedToWholeRange:aValues comparator:NULL];
}

@end

@implementation NSTextStorage (HSExtensions)

+ (NSSize)hyperTextBlockSizeForAttributedString:(id)aString ofHeight:(CGFloat)aHeight maxWidth:(CGFloat)aWidth
{
    return NSZeroSize;
}

+ (NSSize)hyperTextBlockSizeForTextStorage:(id)aStorage ofHeight:(CGFloat)aHeight maxWidth:(CGFloat)aWidth
{
    return NSZeroSize;
}

+ (NSSize)hyperSizeForAttributedString:(id)aString withWidth:(CGFloat)aWidth fixedWidth:(BOOL)aWidth2 padding:(CGFloat)aPadding
{
    NSTextStorage *storage = [[NSTextStorage alloc] initWithAttributedString:aString];
    NSSize size = [self hyperSizeForTextStorage:storage withWidth:aWidth fixedWidth:aWidth2 padding:aPadding];
    [storage release];
    return size;
}

+ (NSSize)hyperSizeForAttributedString:(id)aString withWidth:(CGFloat)aWidth fixedWidth:(BOOL)aWidth2
{
    return [self hyperSizeForAttributedString:aString withWidth:aWidth fixedWidth:aWidth2 padding:[NSTextContainer hyperDefaultLineFragmentPadding]];
}

+ (NSSize)hyperSizeForTextStorage:(id)aStorage withWidth:(CGFloat)aWidth fixedWidth:(BOOL)aWidth2
{
    return [self hyperSizeForTextStorage:aStorage withWidth:aWidth fixedWidth:aWidth2 padding:[NSTextContainer hyperDefaultLineFragmentPadding]];
}

// Laid out at the width (unbounded when not positive); unless the width is
// fixed, the container narrows to the widest line.
+ (NSSize)hyperSizeForTextStorage:(id)aStorage withWidth:(CGFloat)aWidth fixedWidth:(BOOL)aWidth2 padding:(CGFloat)aPadding
{
    NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
    NSTextContainer *container = [[NSTextContainer alloc] initWithContainerSize:NSMakeSize(aWidth > 0.0 ? aWidth : 1e6, 1e6)];
    [container setWidthTracksTextView:YES];
    [container setHeightTracksTextView:NO];
    [container setLineFragmentPadding:aPadding];
    [layoutManager addTextContainer:container];
    [container release];
    [aStorage addLayoutManager:layoutManager];
    [layoutManager release];
    NSSize size = [self hyperSizeOfTextInTextContainer:container calculateOptimalSize:!aWidth2];
    if (aWidth2)
        size.width = aWidth;
    [aStorage removeLayoutManager:layoutManager];
    return size;
}

+ (NSSize)hyperSizeOfTextInTextContainer:(id)aContainer calculateOptimalSize:(BOOL)aSize
{
    NSTextContainer *container = aContainer;
    NSUInteger length = [[[container layoutManager] textStorage] length];
    if (length != 0) {
        NSRange glyphRange = [[container layoutManager] glyphRangeForCharacterRange:NSMakeRange(0, length) actualCharacterRange:NULL];
        if (glyphRange.length != 0) {
            NSUInteger lastGlyph = NSMaxRange(glyphRange) - 1;
            [[container layoutManager] textContainerForGlyphAtIndex:lastGlyph effectiveRange:NULL];
            if (aSize) {
                float widest = 0.0f;
                NSUInteger glyph = glyphRange.location;
                do {
                    NSRange lineRange = NSMakeRange(0, 0);
                    NSRect usedRect = [[container layoutManager] lineFragmentUsedRectForGlyphAtIndex:glyph effectiveRange:&lineRange];
                    float width = usedRect.size.width;
                    float magnitude = width != 0.0f ? fabsf(width) : 1.0f;
                    float magnitude2 = widest != 0.0f ? fabsf(widest) : 1.0f;
                    if (width > MAX(magnitude, magnitude2) * 0.0005f + widest)
                        widest = width;
                    glyph = NSMaxRange(lineRange);
                } while (glyph - glyphRange.location < glyphRange.length);
                if (!HSAttributeDictionaryReplacementsFloatsEqual(widest, 0.0f) && widest > 0.0f) {
                    float width = (float)[container lineFragmentPadding] * 2.0f + ceilf(widest);
                    NSSize containerSize = [container containerSize];
                    float magnitude = width != 0.0f ? fabsf(width) : 1.0f;
                    float magnitude2 = containerSize.width != 0.0f ? fabsf((float)containerSize.width) : 1.0f;
                    if (width < (float)containerSize.width - MAX(magnitude, magnitude2) * 0.0005f) {
                        [container setContainerSize:NSMakeSize(width, containerSize.height)];
                        [[container layoutManager] textContainerForGlyphAtIndex:lastGlyph effectiveRange:NULL];
                    }
                }
            }
        }
    }
    NSRect usedRect = [[container layoutManager] usedRectForTextContainer:container];
    return NSMakeSize(ceilf(usedRect.size.width), ceilf(usedRect.size.height));
}

@end
