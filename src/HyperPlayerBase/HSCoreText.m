#import "HSCoreText.h"
#import "HyperPlayerBaseData.h"

static BOOL HSCoreTextFloatsAreEqual(float a, float b)
{
    float ma = a != 0.0f ? fabsf(a) : 1.0f;
    float mb = b != 0.0f ? fabsf(b) : 1.0f;
    return fabsf(a - b) <= MAX(ma, mb) * 0.0005f;
}

@implementation HSCoreText

+ (void)getAttributedString:(id *)aString dummyString:(BOOL *)aString2 fromText:(id)aText
{
    [self getAttributedString:aString dummyString:aString2 shouldCopy:YES fromText:aText];
}

+ (void)getAttributedStringNoCopy:(id *)aCopy dummyString:(BOOL *)aString fromText:(id)aText
{
    [self getAttributedString:aCopy dummyString:aString shouldCopy:NO fromText:aText];
}

// Core texts give their storage, empty texts a dummy string, attributed
// strings (or objects with a text storage) themselves.
+ (void)getAttributedString:(id *)aString dummyString:(BOOL *)aString2 shouldCopy:(BOOL)aCopy fromText:(id)aText
{
    id string = nil;
    BOOL dummy = NO;
    if ([aText isKindOfClass:[HSCoreText class]]) {
        string = aCopy ? [aText copiedRealAttributedString] : [aText textStorage];
        dummy = [aText textStorageContainsDummyString];
    } else if (aText == nil || [aText isHyperEmpty]) {
        string = [self dummyAttributedStringWithAttributes:aText];
        dummy = YES;
    } else if ([aText isKindOfClass:[NSAttributedString class]])
        string = aText;
    else if ([aText respondsToSelector:@selector(textStorage)]) {
        id textStorage = [aText performSelector:@selector(textStorage)];
        if ([textStorage isKindOfClass:[NSAttributedString class]])
            string = textStorage;
    }
    *aString = string;
    *aString2 = dummy;
}

// A space carrying the attributes, standing for empty text.
+ (id)dummyAttributedStringWithAttributes:(id)aAttributes
{
    id attributes = [aAttributes hyperTextAttributesDictionary];
    if (attributes == nil)
        attributes = [NSAttributedString hyperNullAttributes];
    return [[[NSAttributedString alloc] initWithString:@" " attributes:attributes] autorelease];
}

// Text blocks size to their height and maximum width; other texts to their
// width (fixed or not); a fixed block keeps its size.
+ (NSSize)hyperSizeForText:(id)aText withOptions:(struct HSTextObjectAutoresizingOptions)aOptions
{
    if (!aOptions.f3)
        return [self hyperSizeForText:aText withWidth:aOptions.f0 fixedWidth:aOptions.f2];
    if (!aOptions.f2)
        return [self hyperSizeForTextBlock:aText ofHeight:aOptions.f1 maxWidth:aOptions.f0];
    return NSMakeSize(aOptions.f0, aOptions.f1);
}

+ (NSSize)hyperSizeForTextBlock:(id)aBlock ofHeight:(CGFloat)aHeight maxWidth:(CGFloat)aWidth
{
    return [NSTextStorage hyperTextBlockSizeForTextStorage:[aBlock textStorage] ofHeight:aHeight maxWidth:aWidth];
}

// The shadow's vertical offset adds to the height.
+ (NSSize)hyperSizeForText:(id)aText withWidth:(CGFloat)aWidth fixedWidth:(BOOL)aWidth2
{
    NSSize size = [NSTextStorage hyperSizeForTextStorage:[aText textStorage] withWidth:aWidth fixedWidth:aWidth2];
    NSSize offset = [aText hyperShadowOffset];
    size.height = (float)size.height + ceilf(fabsf((float)offset.height));
    return size;
}

- (void)notifyDidChangeAttributes
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HSCoreTextDidChangeAttributesNotification" object:self];
    if (_coreTextFlags.parentIsNotifiedOfDidChangeAttributes)
        [_parent textDidChangeAttributes:self];
}

- (void)notifyWillChangeAttributes
{
    if (_coreTextFlags.parentIsNotifiedOfWillChangeAttributes)
        [_parent textWillChangeAttributes:self];
}

- (void)notifyDidChangeText
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HSCoreTextDidChangeTextNotification" object:self];
    if (_coreTextFlags.parentIsNotifiedOfDidChangeText)
        [_parent textDidChangeText:self];
}

- (void)notifyWillChangeText
{
    if (_coreTextFlags.parentIsNotifiedOfWillChangeText)
        [_parent textWillChangeText:self];
}

- (void)setDefaultShadowBlurRadius:(CGFloat)aRadius
{
    NSShadow *shadow = [self defaultShadow];
    float radius = [shadow shadowBlurRadius];
    if (HSCoreTextFloatsAreEqual(radius, aRadius))
        return;
    [[[self undoManager] prepareWithInvocationTarget:self] setDefaultShadowBlurRadius:radius];
    [shadow setShadowBlurRadius:aRadius];
}

- (void)setDefaultShadowOffset:(NSSize)aOffset
{
    NSShadow *shadow = [self defaultShadow];
    NSSize offset = [shadow shadowOffset];
    if (HSCoreTextFloatsAreEqual(offset.width, aOffset.width) && HSCoreTextFloatsAreEqual(offset.height, aOffset.height))
        return;
    [[[self undoManager] prepareWithInvocationTarget:self] setDefaultShadowOffset:offset];
    [shadow setShadowOffset:aOffset];
}

- (void)setDefaultShadowDistance:(CGFloat)aDistance
{
    [self setDefaultShadowOffset:[[self defaultShadow] hyperShadowOffsetForDistance:aDistance]];
}

- (void)setDefaultShadowAngle:(CGFloat)aAngle
{
    [self setDefaultShadowOffset:[[self defaultShadow] hyperShadowOffsetForAngle:aAngle]];
}

- (void)setDefaultShadowEnabled:(BOOL)aEnabled
{
    if (_defaultShadowEnabledValue == aEnabled)
        return;
    [[[self undoManager] prepareWithInvocationTarget:self] setDefaultShadowEnabled:_defaultShadowEnabledValue];
    _defaultShadowEnabledValue = aEnabled;
}

- (id)defaultShadow
{
    if (_defaultShadow == nil)
        _defaultShadow = [[NSShadow hyperShadowWithDefaultSettingsForTextObject] retain];
    return _defaultShadow;
}

// A uniform attribute is converted once and applied; mixed values are
// converted run by run.
- (void)hyperConvertActualAttribute:(id)aAttribute toValue:(id)aValue affectingSize:(BOOL)aSize convertAttributeSelector:(SEL)aSelector undoActionName:(id)aName
{
    BOOL multiple = NO;
    id value = [[self textStorage] hyperActualAttribute:aAttribute inRange:[self wholeRange] appliedToWholeRange:&multiple comparator:nil];
    if (!multiple) {
        id converted = [[NSMutableAttributedString class] performSelector:aSelector withObject:value withObject:aValue];
        [self hyperApplyActualAttribute:aAttribute value:converted affectingSize:aSize checkForMultiple:NO undoActionName:aName];
        return;
    }
    if (aName != nil)
        [[self undoManager] setActionName:aName];
    [[[self undoManager] prepareWithInvocationTarget:self] hyperUndoableReplaceAttributes:[self copiedRealAttributedString] undoActionName:aName];
    [self notifyWillChangeAttributes];
    [[self textStorage] hyperConvertActualAttribute:aAttribute inRange:[self wholeRange] toValue:aValue convertAttributeSelector:aSelector];
    [self notifyDidChangeAttributes];
    // The original reports the font attribute whatever was converted.
    [[self parent] text:self didChangeAttribute:NSFontAttributeName affectingSize:aSize withUndoActionName:aName];
}

- (void)hyperConvertAttribute:(id)aAttribute toValue:(id)aValue affectingSize:(BOOL)aSize convertAttributeSelector:(SEL)aSelector undoActionName:(id)aName
{
    BOOL multiple = NO;
    id value = [[self textStorage] hyperAttribute:aAttribute inRange:[self wholeRange] appliedToWholeRange:&multiple comparator:nil];
    if (!multiple) {
        id converted = [[NSMutableAttributedString class] performSelector:aSelector withObject:value withObject:aValue];
        [self hyperApplyAttribute:aAttribute value:converted affectingSize:aSize checkForMultiple:NO undoActionName:aName];
        return;
    }
    if (aName != nil)
        [[self undoManager] setActionName:aName];
    [[[self undoManager] prepareWithInvocationTarget:self] hyperUndoableReplaceAttributes:[self copiedRealAttributedString] undoActionName:aName];
    [self notifyWillChangeAttributes];
    [[self textStorage] hyperConvertAttribute:aAttribute inRange:[self wholeRange] toValue:aValue convertAttributeSelector:aSelector];
    [self notifyDidChangeAttributes];
    // The original reports the font attribute whatever was converted.
    [[self parent] text:self didChangeAttribute:NSFontAttributeName affectingSize:aSize withUndoActionName:aName];
}

- (void)hyperApplyFontTraits:(NSUInteger)aTraits undoActionName:(id)aName
{
    BOOL multiple = NO;
    id font = [[self textStorage] hyperAttribute:NSFontAttributeName inRange:[self wholeRange] appliedToWholeRange:&multiple comparator:nil];
    if (aName != nil)
        [[self undoManager] setActionName:aName];
    id target = [[self undoManager] prepareWithInvocationTarget:self];
    if (!multiple)
        [target hyperUndoableApplyAttribute:NSFontAttributeName value:font undoActionName:aName];
    else
        [target hyperUndoableReplaceAttributes:[self copiedRealAttributedString] undoActionName:aName];
    [self notifyWillChangeAttributes];
    [[self textStorage] applyFontTraits:aTraits range:[self wholeRange]];
    [self notifyDidChangeAttributes];
    [[self parent] text:self didChangeAttribute:NSFontAttributeName affectingSize:YES withUndoActionName:aName];
}

// Outlines may need other attributes replaced (their colours).
- (void)hyperApplyStrokeWidth:(id)aWidth checkForMultiple:(BOOL)aMultiple undoActionName:(id)aName
{
    id replacements = [[self textStorage] hyperReplacementsForAttributesInRange:[self wholeRange] forApplyingOutlineValue:aWidth];
    if (replacements != nil && ![replacements isEmpty])
        [self hyperApplyAttributeReplacements:replacements affectingSize:NO undoActionName:aName];
    else
        [self hyperApplyAttribute:NSStrokeWidthAttributeName value:aWidth affectingSize:NO checkForMultiple:aMultiple undoActionName:aName];
}

// Gradient colours are applied as their transparent clone.
- (void)hyperApplyForegroundColor:(id)aColor checkForMultiple:(BOOL)aMultiple undoActionName:(id)aName
{
    id replacements = [[self textStorage] hyperReplacementsForForegroundColorDependentAttributesInRange:[self wholeRange] forApplyingForegroundColor:aColor];
    if (replacements != nil && ![replacements isEmpty]) {
        [self hyperApplyAttributeReplacements:replacements affectingSize:NO undoActionName:aName];
        return;
    }
    id color = aColor;
    if ([aColor hyperGradientColor] != nil)
        color = [[aColor hyperGradientColor] clonedTransparentColor];
    [self hyperApplyAttribute:NSForegroundColorAttributeName value:color affectingSize:NO checkForMultiple:aMultiple undoActionName:aName];
}

- (void)hyperApplyAttributeReplacements:(id)aReplacements affectingSize:(BOOL)aSize undoActionName:(id)aName
{
    if (aName != nil)
        [[self undoManager] setActionName:aName];
    [[[self undoManager] prepareWithInvocationTarget:self] hyperUndoableReplaceAttributes:[self copiedRealAttributedString] undoActionName:aName];
    [self notifyWillChangeAttributes];
    [[self textStorage] hyperApplyAttributeReplacements:aReplacements range:[self wholeRange]];
    [self notifyDidChangeAttributes];
    NSEnumerator *enumerator = [[aReplacements allIncludedAttributes] objectEnumerator];
    id attribute;
    while ((attribute = [enumerator nextObject]) != nil)
        [[self parent] text:self didChangeAttribute:attribute affectingSize:aSize withUndoActionName:aName];
}

- (void)hyperApplyActualAttribute:(id)aAttribute value:(id)aValue affectingSize:(BOOL)aSize checkForMultiple:(BOOL)aMultiple undoActionName:(id)aName
{
    [self hyperApplyAttribute:aAttribute value:aValue affectingSize:aSize checkForMultiple:aMultiple checkForActualAttribute:YES undoActionName:aName];
}

- (void)hyperApplyAttribute:(id)aAttribute value:(id)aValue affectingSize:(BOOL)aSize checkForMultiple:(BOOL)aMultiple undoActionName:(id)aName
{
    [self hyperApplyAttribute:aAttribute value:aValue affectingSize:aSize checkForMultiple:aMultiple checkForActualAttribute:NO undoActionName:aName];
}

// Mixed values are undone by restoring the whole text's attributes, a
// uniform one by applying it back.
- (void)hyperApplyAttribute:(id)aAttribute value:(id)aValue affectingSize:(BOOL)aSize checkForMultiple:(BOOL)aMultiple checkForActualAttribute:(BOOL)aAttribute2 undoActionName:(id)aName
{
    BOOL multiple = NO;
    if (aMultiple) {
        if (aAttribute2)
            [[self textStorage] hyperActualAttribute:aAttribute inRange:[self wholeRange] appliedToWholeRange:&multiple comparator:nil];
        else
            [[self textStorage] hyperAttribute:aAttribute inRange:[self wholeRange] appliedToWholeRange:&multiple comparator:nil];
    }
    if (multiple) {
        if (aName != nil)
            [[self undoManager] setActionName:aName];
        [[[self undoManager] prepareWithInvocationTarget:self] hyperUndoableReplaceAttributes:[self copiedRealAttributedString] undoActionName:aName];
        [self notifyWillChangeAttributes];
        [[self textStorage] hyperApplyAttribute:aAttribute value:aValue range:[self wholeRange]];
        [self notifyDidChangeAttributes];
    } else if (aAttribute2)
        [self hyperUndoableApplyActualAttribute:aAttribute value:aValue undoActionName:aName];
    else
        [self hyperUndoableApplyAttribute:aAttribute value:aValue undoActionName:aName];
    [[self parent] text:self didChangeAttribute:aAttribute affectingSize:aSize withUndoActionName:aName];
}

- (void)hyperReplaceTextWithString:(id)aString inRange:(NSRange)aRange toSetDummyString:(BOOL)aString2 undoActionName:(id)aName
{
    if (aName != nil)
        [[self undoManager] setActionName:aName];
    id target = [[self undoManager] prepareWithInvocationTarget:self];
    BOOL dummy = _textStorageContainsDummyString;
    [target hyperUndoableReplaceTextInRange:NSMakeRange(aRange.location, [aString length]) withString:[self copiedRealAttributedStringFromRange:aRange] toSetDummyString:dummy undoActionName:aName];
    [self notifyWillChangeText];
    [[self textStorage] replaceCharactersInRange:aRange withString:aString];
    _textStorageContainsDummyString = aString2;
    [self notifyDidChangeText];
    [[self parent] text:self didChangeTextWithUndoActionName:aName];
}

- (void)hyperReplaceTextWithString:(id)aString toSetDummyString:(BOOL)aString2 undoActionName:(id)aName
{
    [self hyperReplaceTextWithString:aString inRange:[self wholeRange] toSetDummyString:aString2 undoActionName:aName];
}

- (void)hyperReplaceText:(id)aText toSetDummyString:(BOOL)aString undoActionName:(id)aName
{
    [self hyperUndoableReplaceText:aText toSetDummyString:aString undoActionName:aName];
    [[self parent] text:self didChangeTextWithUndoActionName:aName];
}

- (void)hyperReplaceAttributes:(id)aAttributes affectingSize:(BOOL)aSize undoActionName:(id)aName
{
    [self hyperUndoableReplaceAttributes:aAttributes undoActionName:aName];
    [[self parent] text:self didChangeAttribute:nil affectingSize:aSize withUndoActionName:aName];
}

- (void)hyperUndoableApplyActualAttribute:(id)aAttribute value:(id)aValue undoActionName:(id)aName
{
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    id value = [[self textStorage] hyperActualAttribute:aAttribute inRange:[self wholeRange] appliedToWholeRange:NULL comparator:nil];
    if (aName != nil)
        [[self undoManager] setActionName:aName];
    [[[self undoManager] prepareWithInvocationTarget:self] hyperUndoableApplyActualAttribute:aAttribute value:value undoActionName:aName];
    [self notifyWillChangeAttributes];
    [[self textStorage] hyperApplyAttribute:aAttribute value:aValue range:[self wholeRange]];
    [self notifyDidChangeAttributes];
    [pool release];
}

- (void)hyperUndoableApplyAttribute:(id)aAttribute value:(id)aValue undoActionName:(id)aName
{
    id value = [[self textStorage] hyperAttribute:aAttribute inRange:[self wholeRange] appliedToWholeRange:NULL comparator:nil];
    if (aName != nil)
        [[self undoManager] setActionName:aName];
    [[[self undoManager] prepareWithInvocationTarget:self] hyperUndoableApplyAttribute:aAttribute value:value undoActionName:aName];
    [self notifyWillChangeAttributes];
    [[self textStorage] hyperApplyAttribute:aAttribute value:aValue range:[self wholeRange]];
    [self notifyDidChangeAttributes];
}

- (void)hyperUndoableReplaceText:(id)aText toSetDummyString:(BOOL)aString undoActionName:(id)aName
{
    [self hyperUndoableReplaceTextInRange:[self wholeRange] withString:aText toSetDummyString:aString undoActionName:aName];
}

- (void)hyperUndoableReplaceTextInRange:(NSRange)aRange withString:(id)aString toSetDummyString:(BOOL)aString2 undoActionName:(id)aName
{
    if (aName != nil)
        [[self undoManager] setActionName:aName];
    id target = [[self undoManager] prepareWithInvocationTarget:self];
    BOOL dummy = _textStorageContainsDummyString;
    [target hyperUndoableReplaceTextInRange:NSMakeRange(aRange.location, [aString length]) withString:[self copiedRealAttributedStringFromRange:aRange] toSetDummyString:dummy undoActionName:aName];
    [self notifyWillChangeText];
    [[self textStorage] replaceCharactersInRange:aRange withAttributedString:aString];
    _textStorageContainsDummyString = aString2;
    [self notifyDidChangeText];
}

- (void)hyperUndoableReplaceAttributes:(id)aAttributes undoActionName:(id)aName
{
    if (aName != nil)
        [[self undoManager] setActionName:aName];
    [[[self undoManager] prepareWithInvocationTarget:self] hyperUndoableReplaceAttributes:[self copiedRealAttributedString] undoActionName:aName];
    [self notifyWillChangeAttributes];
    [[self textStorage] replaceCharactersInRange:[self wholeRange] withAttributedString:aAttributes];
    [self notifyDidChangeAttributes];
}

- (BOOL)textStorageContainsDummyString
{
    return _textStorageContainsDummyString;
}

- (id)copiedRealAttributedStringFromRange:(NSRange)aRange
{
    return [[[NSAttributedString alloc] initWithAttributedString:[[self textStorage] attributedSubstringFromRange:aRange]] autorelease];
}

- (id)copiedRealAttributedString
{
    return [[[NSAttributedString alloc] initWithAttributedString:[self textStorage]] autorelease];
}

- (NSRange)wholeRange
{
    return NSMakeRange(0, [[self textStorage] length]);
}

- (id)textStorage
{
    return _textStorage;
}

- (NSSize)hyperRequiredSizeForTextBlockOfHeight:(CGFloat)aHeight maximumWidth:(CGFloat)aWidth
{
    return [NSTextStorage hyperTextBlockSizeForTextStorage:[self textStorage] ofHeight:aHeight maxWidth:aWidth];
}

- (NSSize)hyperRequiredSizeToFitWidth:(CGFloat)aWidth fixedWidth:(BOOL)aWidth2
{
    return [NSTextStorage hyperSizeForTextStorage:[self textStorage] withWidth:aWidth fixedWidth:aWidth2];
}

- (BOOL)isHyperEmpty
{
    return _textStorageContainsDummyString;
}

- (id)hyperText
{
    if (_textStorageContainsDummyString)
        return [[[NSAttributedString alloc] init] autorelease];
    return [self textStorage];
}

- (id)hyperString
{
    if (_textStorageContainsDummyString)
        return [NSString string];
    return [[self textStorage] string];
}

- (void)setHyperCursorPositionAccordingToCurrentEvent
{
}

- (void)applyCharacterAttributesWithAttributesConverter:(id)aConverter undoActionName:(id)aName
{
    id replacements = [[self textStorage] hyperReplacementsForAttributesInRange:[self wholeRange] forAttributesWithAttributesConverter:aConverter];
    if (replacements != nil && ![replacements isEmpty])
        [self hyperApplyAttributeReplacements:replacements affectingSize:NO undoActionName:aName];
}

- (void)applyFontWithFontConverter:(id)aConverter undoActionName:(id)aName
{
    id replacements = [[self textStorage] hyperReplacementsForAttributesInRange:[self wholeRange] forFontWithFontConverter:aConverter];
    if (replacements != nil && ![replacements isEmpty])
        [self hyperApplyAttributeReplacements:replacements affectingSize:YES undoActionName:aName];
}

// The whole text takes the attributes.
- (void)applyHyperTextAttributes:(id)aAttributes undoActionName:(id)aName
{
    id attributes = [aAttributes hyperTextAttributesDictionary];
    if (attributes == nil)
        attributes = [NSAttributedString hyperNullAttributes];
    NSAttributedString *string = [[[NSAttributedString alloc] initWithString:[_textStorage string] attributes:attributes] autorelease];
    [self hyperReplaceAttributes:string affectingSize:YES undoActionName:aName];
}

- (void)hyperReplaceTextWithString:(id)aString attributes:(id)aAttributes undoActionName:(id)aName
{
    id text;
    BOOL dummy;
    if ([aString length] == 0) {
        text = [HSCoreText dummyAttributedStringWithAttributes:aAttributes];
        dummy = YES;
    } else {
        id attributes = [aAttributes hyperTextAttributesDictionary];
        if (attributes == nil)
            attributes = [NSAttributedString hyperNullAttributes];
        text = [[[NSAttributedString alloc] initWithString:aString attributes:attributes] autorelease];
        dummy = NO;
    }
    [self hyperReplaceText:text toSetDummyString:dummy undoActionName:aName];
}

- (void)hyperReplaceTextWithString:(id)aString inRange:(NSRange)aRange undoActionName:(id)aName
{
    [self hyperReplaceTextWithString:[aString length] != 0 ? aString : @" " inRange:aRange toSetDummyString:NO undoActionName:aName];
}

- (void)hyperReplaceTextWithString:(id)aString undoActionName:(id)aName
{
    NSUInteger length = [aString length];
    [self hyperReplaceTextWithString:length != 0 ? aString : @" " toSetDummyString:length == 0 undoActionName:aName];
}

- (void)hyperReplaceText:(id)aText undoActionName:(id)aName
{
    if ([aText isHyperEmpty]) {
        [self hyperReplaceTextWithString:[aText hyperString] attributes:aText undoActionName:aName];
        return;
    }
    id string = nil;
    BOOL dummy = NO;
    [HSCoreText getAttributedStringNoCopy:&string dummyString:&dummy fromText:aText];
    [self hyperReplaceText:string toSetDummyString:dummy undoActionName:aName];
}

- (void)setHasBackground:(BOOL)aBackground undoActionName:(id)aName
{
    if (_hasBackgroundColor == aBackground)
        return;
    [[[self undoManager] prepareWithInvocationTarget:self] setHasBackground:_hasBackgroundColor undoActionName:aName];
    _hasBackgroundColor = aBackground;
    [[self parent] text:self didChangeTextBlockAttribute:@"hasBackground" withUndoActionName:aName];
}

- (BOOL)hasBackground
{
    return _hasBackgroundColor;
}

- (void)setHyperTextBackgroundColor:(id)aColor undoActionName:(id)aName
{
    if (_backgroundColor == aColor)
        return;
    [[[self undoManager] prepareWithInvocationTarget:self] setHyperTextBackgroundColor:_backgroundColor undoActionName:aName];
    [self setBackgroundColor:aColor undoActionName:aName];
}

- (id)hyperTextBackgroundColor
{
    if (_hasBackgroundColor)
        return _backgroundColor;
    return nil;
}

- (void)setBackgroundColor:(id)aColor
{
    [self setBackgroundColor:aColor undoActionName:nil];
}

- (void)setBackgroundColor:(id)aColor undoActionName:(id)aName
{
    if (_backgroundColor == aColor)
        return;
    [_backgroundColor release];
    _backgroundColor = [aColor retain];
    if (_hasBackgroundColor)
        [[self parent] text:self didChangeTextBlockAttribute:@"hyperTextBackgroundColor" withUndoActionName:aName];
}

- (id)backgroundColor
{
    return _backgroundColor;
}

// A spacing of (about) zero removes the kerning.
- (void)setHyperSpaceBetweenCharacters:(CGFloat)aCharacters undoActionName:(id)aName
{
    float spacing = aCharacters;
    float magnitude = spacing != 0.0f ? fabsf(spacing) : 1.0f;
    float tolerance = magnitude >= 1.0f ? magnitude * 0.0005f : 0.0005f;
    id value = fabsf(spacing) > tolerance ? [NSNumber numberWithFloat:spacing] : nil;
    [self hyperApplyAttribute:NSKernAttributeName value:value affectingSize:YES checkForMultiple:YES undoActionName:aName];
}

- (void)setHyperSpaceBetweenLines:(CGFloat)aLines undoActionName:(id)aName
{
    [self hyperConvertAttribute:NSParagraphStyleAttributeName toValue:[NSNumber numberWithFloat:aLines] affectingSize:YES convertAttributeSelector:@selector(hyperConvertLineSpacingInParagraphStyle:toValue:) undoActionName:aName];
}

- (void)setHyperTextAlignment:(NSUInteger)aAlignment undoActionName:(id)aName
{
    [self hyperConvertAttribute:NSParagraphStyleAttributeName toValue:[NSNumber numberWithInt:(int)aAlignment] affectingSize:YES convertAttributeSelector:@selector(hyperConvertAlignmentInParagraphStyle:toValue:) undoActionName:aName];
}

- (void)setHyperTextColor:(id)aColor undoActionName:(id)aName
{
    [self hyperApplyForegroundColor:aColor checkForMultiple:YES undoActionName:aName];
}

// Shadow changes also go to the default shadow used when enabling it.
- (void)setHyperShadowDistance:(CGFloat)aDistance undoActionName:(id)aName
{
    [self hyperConvertActualAttribute:NSShadowAttributeName toValue:[NSNumber numberWithFloat:aDistance] affectingSize:NO convertAttributeSelector:@selector(hyperConvertShadow:toHaveDistanceValue:) undoActionName:aName];
    [self setDefaultShadowDistance:aDistance];
}

- (void)setHyperShadowBlurRadius:(CGFloat)aRadius undoActionName:(id)aName
{
    [self hyperConvertActualAttribute:NSShadowAttributeName toValue:[NSNumber numberWithFloat:aRadius] affectingSize:NO convertAttributeSelector:@selector(hyperConvertShadow:toHaveBlurRadiusValue:) undoActionName:aName];
    [self setDefaultShadowBlurRadius:aRadius];
}

- (void)setHyperShadowOffset:(NSSize)aOffset undoActionName:(id)aName
{
    [self hyperConvertActualAttribute:NSShadowAttributeName toValue:[NSValue valueWithSize:aOffset] affectingSize:NO convertAttributeSelector:@selector(hyperConvertShadow:toHaveOffsetValue:) undoActionName:aName];
    [self setDefaultShadowOffset:aOffset];
}

- (void)setHyperShadowAngle:(CGFloat)aAngle undoActionName:(id)aName
{
    [self hyperConvertActualAttribute:NSShadowAttributeName toValue:[NSNumber numberWithFloat:aAngle] affectingSize:NO convertAttributeSelector:@selector(hyperConvertShadow:toHaveAngleValue:) undoActionName:aName];
    [self setDefaultShadowAngle:aAngle];
}

- (void)setHyperShadowEnabled:(BOOL)aEnabled undoActionName:(id)aName
{
    if (aEnabled)
        [self hyperConvertActualAttribute:NSShadowAttributeName toValue:[self defaultShadow] affectingSize:NO convertAttributeSelector:@selector(hyperConvertShadow:forEnablingShadowWithDefaultValue:) undoActionName:aName];
    else
        [self hyperApplyActualAttribute:NSShadowAttributeName value:nil affectingSize:NO checkForMultiple:YES undoActionName:aName];
    [self setDefaultShadowEnabled:aEnabled];
}

// Live outline edits keep the original stroke in temporary attributes: a
// cancel restores it, a commit records one undoable change from it.
- (void)finishOutlineMutating:(BOOL)aMutating undoActionName:(id)aName
{
    NSTextStorage *textStorage = [self textStorage];
    if (!aMutating) {
        [[self textStorage] hyperReplaceAttributeValues:NSStrokeWidthAttributeName withAttributeValues:HSTemporaryStrokeWidthAttributeName inRange:NSMakeRange(0, [[self textStorage] length])];
        [[self textStorage] hyperReplaceAttributeValues:NSStrokeColorAttributeName withAttributeValues:HSTemporaryStrokeColorAttributeName inRange:NSMakeRange(0, [[self textStorage] length])];
        [self notifyDidChangeAttributes];
        return;
    }
    NSMutableAttributedString *mutated = [[textStorage mutableCopy] autorelease];
    NSMutableAttributedString *original = [[mutated mutableCopy] autorelease];
    [original hyperReplaceAttributeValues:NSStrokeWidthAttributeName withAttributeValues:HSTemporaryStrokeWidthAttributeName inRange:NSMakeRange(0, [[self textStorage] length])];
    [original hyperReplaceAttributeValues:NSStrokeColorAttributeName withAttributeValues:HSTemporaryStrokeColorAttributeName inRange:NSMakeRange(0, [[self textStorage] length])];
    [[self undoManager] disableUndoRegistration];
    [self hyperReplaceText:original toSetDummyString:_textStorageContainsDummyString undoActionName:aName];
    [[self undoManager] enableUndoRegistration];
    [self hyperReplaceText:mutated toSetDummyString:_textStorageContainsDummyString undoActionName:aName];
}

- (void)startOutlineMutating
{
    [[self textStorage] hyperReplaceAttributeValues:HSTemporaryStrokeWidthAttributeName withAttributeValues:NSStrokeWidthAttributeName inRange:NSMakeRange(0, [[self textStorage] length])];
    [[self textStorage] hyperReplaceAttributeValues:HSTemporaryStrokeColorAttributeName withAttributeValues:NSStrokeColorAttributeName inRange:NSMakeRange(0, [[self textStorage] length])];
}

- (void)setHyperOutlineColor:(id)aColor undoActionName:(id)aName
{
    [self hyperApplyAttribute:NSStrokeColorAttributeName value:aColor affectingSize:NO checkForMultiple:YES undoActionName:aName];
}

- (void)setHyperOutlineWidth:(CGFloat)aWidth undoActionName:(id)aName
{
    [self hyperApplyStrokeWidth:[NSNumber numberWithFloat:aWidth] checkForMultiple:YES undoActionName:aName];
}

- (void)setHyperOutlineEnabled:(BOOL)aEnabled undoActionName:(id)aName
{
    id value = aEnabled ? [NSAttributedString hyperDefaultOutlineValueForEnablingOutline] : nil;
    [self hyperApplyStrokeWidth:value checkForMultiple:YES undoActionName:aName];
}

- (void)setHyperCondensed:(BOOL)aCondensed undoActionName:(id)aName
{
    SEL selector = aCondensed ? @selector(hyperConvertFont:toHaveTrait:) : @selector(hyperConvertFont:toNotHaveTrait:);
    [self hyperConvertAttribute:NSFontAttributeName toValue:[NSNumber numberWithUnsignedInt:NSCondensedFontMask] affectingSize:YES convertAttributeSelector:selector undoActionName:aName];
}

- (void)setHyperExpanded:(BOOL)aExpanded undoActionName:(id)aName
{
    SEL selector = aExpanded ? @selector(hyperConvertFont:toHaveTrait:) : @selector(hyperConvertFont:toNotHaveTrait:);
    [self hyperConvertAttribute:NSFontAttributeName toValue:[NSNumber numberWithUnsignedInt:NSExpandedFontMask] affectingSize:YES convertAttributeSelector:selector undoActionName:aName];
}

- (void)setHyperUnderlined:(BOOL)aUnderlined undoActionName:(id)aName
{
    // The original leaked an allocated number here.
    id value = aUnderlined ? [NSNumber numberWithInt:1] : nil;
    [self hyperApplyAttribute:NSUnderlineStyleAttributeName value:value affectingSize:NO checkForMultiple:YES undoActionName:aName];
}

- (void)setHyperItalic:(BOOL)aItalic undoActionName:(id)aName
{
    [self hyperApplyFontTraits:aItalic ? NSItalicFontMask : NSUnitalicFontMask undoActionName:aName];
}

- (void)setHyperBold:(BOOL)aBold undoActionName:(id)aName
{
    [self hyperApplyFontTraits:aBold ? NSBoldFontMask : NSUnboldFontMask undoActionName:aName];
}

- (void)setHyperFontSize:(CGFloat)aSize undoActionName:(id)aName
{
    [self hyperConvertAttribute:NSFontAttributeName toValue:[NSNumber numberWithFloat:aSize] affectingSize:YES convertAttributeSelector:@selector(hyperConvertFont:toSizeValue:) undoActionName:aName];
}

- (void)setHyperFontFamilyWithFont:(id)aFont undoActionName:(id)aName
{
    [self hyperConvertAttribute:NSFontAttributeName toValue:aFont affectingSize:YES convertAttributeSelector:@selector(hyperConvertFont:toFamilyInFont:) undoActionName:aName];
}

- (void)setHyperFontFamily:(id)aFamily undoActionName:(id)aName
{
    [self hyperConvertAttribute:NSFontAttributeName toValue:aFamily affectingSize:YES convertAttributeSelector:@selector(hyperConvertFont:toFamily:) undoActionName:aName];
}

- (void)setHyperFont:(id)aFont undoActionName:(id)aName
{
    [self hyperApplyAttribute:NSFontAttributeName value:aFont affectingSize:YES checkForMultiple:YES undoActionName:aName];
}

- (void)getHyperTextAttributes:(id *)aAttributes multipleValues:(BOOL *)aValues
{
    id attributes = nil;
    [[self textStorage] getHyperAttributesDictionary:&attributes inRange:[self wholeRange] multipleValues:aValues];
    *aAttributes = attributes;
}

- (void)getHyperSpaceBetweenCharacters:(float *)aCharacters multipleValues:(BOOL *)aValues
{
    [[self textStorage] getHyperSpaceBetweenCharacters:aCharacters inRange:[self wholeRange] multipleValues:aValues];
}

- (void)getHyperSpaceBetweenLines:(float *)aLines multipleValues:(BOOL *)aValues
{
    [[self textStorage] getHyperSpaceBetweenLines:aLines inRange:[self wholeRange] multipleValues:aValues];
}

- (void)getHyperTextAlignment:(unsigned int *)aAlignment multipleValues:(BOOL *)aValues
{
    [[self textStorage] getHyperTextAlignment:aAlignment inRange:[self wholeRange] multipleValues:aValues];
}

- (void)getHyperTextColor:(id *)aColor multipleValues:(BOOL *)aValues
{
    [[self textStorage] getHyperTextColor:aColor inRange:[self wholeRange] multipleValues:aValues];
}

- (void)getHyperShadowDistance:(float *)aDistance multipleValues:(BOOL *)aValues
{
    [[self textStorage] getHyperShadowDistance:aDistance inRange:[self wholeRange] multipleValues:aValues];
}

- (void)getHyperShadowOffset:(NSSize *)aOffset multipleValues:(BOOL *)aValues
{
    [[self textStorage] getHyperShadowOffset:aOffset inRange:[self wholeRange] multipleValues:aValues];
}

- (void)getHyperShadowBlurRadius:(float *)aRadius multipleValues:(BOOL *)aValues
{
    [[self textStorage] getHyperShadowBlurRadius:aRadius inRange:[self wholeRange] multipleValues:aValues];
}

- (void)getHyperShadowAngle:(float *)aAngle multipleValues:(BOOL *)aValues
{
    [[self textStorage] getHyperShadowAngle:aAngle inRange:[self wholeRange] multipleValues:aValues];
}

- (void)getHyperShadowEnabled:(BOOL *)aEnabled multipleValues:(BOOL *)aValues
{
    [[self textStorage] getHyperShadowEnabled:aEnabled inRange:[self wholeRange] multipleValues:aValues];
}

- (void)getHyperShadow:(id *)aShadow multipleValues:(BOOL *)aValues
{
    id shadow = [[self textStorage] hyperAttribute:NSShadowAttributeName inRange:[self wholeRange] appliedToWholeRange:aValues comparator:nil];
    if (aShadow != NULL)
        *aShadow = shadow;
}

- (void)getHyperOutlineWidth:(float *)aWidth multipleValues:(BOOL *)aValues
{
    [[self textStorage] getHyperOutlineWidth:aWidth inRange:[self wholeRange] multipleValues:aValues];
}

- (void)getHyperOutlineColor:(id *)aColor multipleValues:(BOOL *)aValues
{
    [[self textStorage] getHyperOutlineColor:aColor inRange:[self wholeRange] multipleValues:aValues];
}

- (void)getHyperOutlineEnabled:(BOOL *)aEnabled multipleValues:(BOOL *)aValues
{
    [[self textStorage] getHyperOutlineEnabled:aEnabled inRange:[self wholeRange] multipleValues:aValues];
}

- (void)getHyperExpanded:(BOOL *)aExpanded multipleValues:(BOOL *)aValues
{
    [[self textStorage] getHyperExpanded:aExpanded inRange:[self wholeRange] multipleValues:aValues];
}

- (void)getHyperCondensed:(BOOL *)aCondensed multipleValues:(BOOL *)aValues
{
    [[self textStorage] getHyperCondensed:aCondensed inRange:[self wholeRange] multipleValues:aValues];
}

- (void)getHyperUnderlined:(BOOL *)aUnderlined multipleValues:(BOOL *)aValues
{
    [[self textStorage] getHyperUnderlined:aUnderlined inRange:[self wholeRange] multipleValues:aValues];
}

- (void)getHyperItalic:(BOOL *)aItalic multipleValues:(BOOL *)aValues
{
    [[self textStorage] getHyperItalic:aItalic inRange:[self wholeRange] multipleValues:aValues];
}

- (void)getHyperBold:(BOOL *)aBold multipleValues:(BOOL *)aValues
{
    [[self textStorage] getHyperBold:aBold inRange:[self wholeRange] multipleValues:aValues];
}

- (void)getHyperFontSize:(float *)aSize multipleValues:(BOOL *)aValues
{
    [[self textStorage] getHyperFontSize:aSize inRange:[self wholeRange] multipleValues:aValues];
}

- (void)getHyperFontFamily:(id *)aFamily multipleValues:(BOOL *)aValues
{
    [[self textStorage] getHyperFontFamily:aFamily inRange:[self wholeRange] multipleValues:aValues];
}

- (void)getHyperFont:(id *)aFont multipleValues:(BOOL *)aValues
{
    [[self textStorage] getHyperFont:aFont inRange:[self wholeRange] multipleValues:aValues];
}

- (id)hyperTextAttributesDictionary
{
    id attributes = nil;
    [[self textStorage] getHyperAttributesDictionary:&attributes inRange:[self wholeRange] multipleValues:NULL];
    return attributes;
}

- (CGFloat)hyperSpaceBetweenCharacters
{
    float spacing = 0.0f;
    [self getHyperSpaceBetweenCharacters:&spacing multipleValues:NULL];
    return spacing;
}

- (CGFloat)hyperSpaceBetweenLines
{
    float spacing = 0.0f;
    [self getHyperSpaceBetweenLines:&spacing multipleValues:NULL];
    return spacing;
}

- (NSUInteger)hyperTextAlignment
{
    unsigned int alignment = 0;
    [self getHyperTextAlignment:&alignment multipleValues:NULL];
    return alignment;
}

- (id)hyperTextColor
{
    id color = nil;
    [self getHyperTextColor:&color multipleValues:NULL];
    return color;
}

- (CGFloat)hyperShadowBlurRadius
{
    float radius = 0.0f;
    [self getHyperShadowBlurRadius:&radius multipleValues:NULL];
    return radius;
}

- (NSSize)hyperShadowOffset
{
    NSSize offset = NSZeroSize;
    [self getHyperShadowOffset:&offset multipleValues:NULL];
    return offset;
}

- (CGFloat)hyperShadowDistance
{
    float distance = 0.0f;
    [self getHyperShadowDistance:&distance multipleValues:NULL];
    return distance;
}

- (CGFloat)hyperShadowAngle
{
    float angle = 0.0f;
    [self getHyperShadowAngle:&angle multipleValues:NULL];
    return angle;
}

- (BOOL)isHyperShadowEnabled
{
    BOOL enabled = NO;
    [self getHyperShadowEnabled:&enabled multipleValues:NULL];
    return enabled;
}

- (id)hyperOutlineColor
{
    id color = nil;
    [self getHyperOutlineColor:&color multipleValues:NULL];
    return color;
}

- (CGFloat)hyperOutlineWidth
{
    float width = 0.0f;
    [self getHyperOutlineWidth:&width multipleValues:NULL];
    return width;
}

- (BOOL)isHyperOutlineEnabled
{
    BOOL enabled = NO;
    [self getHyperOutlineEnabled:&enabled multipleValues:NULL];
    return enabled;
}

- (BOOL)isHyperExpanded
{
    BOOL expanded = NO;
    [self getHyperExpanded:&expanded multipleValues:NULL];
    return expanded;
}

- (BOOL)isHyperCondensed
{
    BOOL condensed = NO;
    [self getHyperCondensed:&condensed multipleValues:NULL];
    return condensed;
}

- (BOOL)isHyperUnderlined
{
    BOOL underlined = NO;
    [self getHyperUnderlined:&underlined multipleValues:NULL];
    return underlined;
}

- (BOOL)isHyperItalic
{
    BOOL italic = NO;
    [self getHyperItalic:&italic multipleValues:NULL];
    return italic;
}

- (BOOL)isHyperBold
{
    BOOL bold = NO;
    [self getHyperBold:&bold multipleValues:NULL];
    return bold;
}

- (CGFloat)hyperFontSize
{
    float size = 0.0f;
    [self getHyperFontSize:&size multipleValues:NULL];
    return size;
}

- (id)hyperFontFamily
{
    id family = nil;
    [self getHyperFontFamily:&family multipleValues:NULL];
    return family;
}

- (id)hyperFont
{
    id font = nil;
    [self getHyperFont:&font multipleValues:NULL];
    return font;
}

// Object styles store no text.
- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    if (![[aContext codingOperation] isEqualToString:@"HSObjectStyleCodingOperation"]) {
        id keys = [NSArray arrayWithObjects:[@"serializedText" extraKeyForMultiRepresentations], @"_textStorageContainsDummyString", [@"backgroundColor" extraKeyForMultiRepresentations], @"_hasBackgroundColor", nil];
        if (keys != nil)
            return keys;
    }
    return [NSArray array];
}

- (void)setSerializedText:(id)aText
{
    [[self textStorage] replaceCharactersInRange:[self wholeRange] withAttributedString:aText];
}

- (id)serializedText
{
    return [self copiedRealAttributedString];
}

- (id)undoManager
{
    return [[self parent] undoManager];
}

- (id)parent
{
    return _parent;
}

// The parent is told only of the changes it handles.
- (void)setParent:(id)aParent
{
    if (_parent == aParent)
        return;
    _coreTextFlags.parentIsNotifiedOfWillChangeText = 0;
    _coreTextFlags.parentIsNotifiedOfDidChangeAttributes = 0;
    _coreTextFlags.parentIsNotifiedOfWillChangeAttributes = 0;
    _coreTextFlags.parentIsNotifiedOfDidChangeText = 0;
    _parent = aParent;
    if (aParent != nil) {
        _coreTextFlags.parentIsNotifiedOfWillChangeText = [aParent respondsToSelector:@selector(textWillChangeText:)];
        _coreTextFlags.parentIsNotifiedOfDidChangeText = [_parent respondsToSelector:@selector(textDidChangeText:)];
        _coreTextFlags.parentIsNotifiedOfWillChangeAttributes = [_parent respondsToSelector:@selector(textWillChangeAttributes:)];
        _coreTextFlags.parentIsNotifiedOfDidChangeAttributes = [_parent respondsToSelector:@selector(textDidChangeAttributes:)];
    }
}

- (void)dealloc
{
    [_textStorage release];
    [_backgroundColor release];
    [_defaultShadow release];
    [super dealloc];
}

- (id)initWithAttributedString:(id)aString dummyString:(BOOL)aString2
{
    self = [super init];
    if (self != nil) {
        _textStorage = [[NSTextStorage alloc] init];
        [_textStorage replaceCharactersInRange:NSMakeRange(0, 0) withAttributedString:aString];
        _textStorageContainsDummyString = aString2;
    }
    return self;
}

- (id)initWithText:(id)aText
{
    if ([aText isHyperEmpty])
        return [self initWithAttributes:aText];
    id string = nil;
    BOOL dummy = NO;
    [HSCoreText getAttributedStringNoCopy:&string dummyString:&dummy fromText:aText];
    return [self initWithAttributedString:string dummyString:dummy];
}

- (id)initWithAttributes:(id)aAttributes
{
    return [self initWithAttributedString:[HSCoreText dummyAttributedStringWithAttributes:aAttributes] dummyString:YES];
}

- (id)initWithString:(id)aString attributes:(id)aAttributes
{
    if ([aString length] == 0)
        return [self initWithAttributes:aAttributes];
    id attributes = [aAttributes hyperTextAttributesDictionary];
    if (attributes == nil)
        attributes = [NSAttributedString hyperNullAttributes];
    return [self initWithAttributedString:[[[NSAttributedString alloc] initWithString:aString attributes:attributes] autorelease] dummyString:NO];
}

- (id)initWithAttributedString:(id)aString
{
    if ([aString length] == 0)
        return [self initWithAttributes:nil];
    return [self initWithAttributedString:aString dummyString:NO];
}

- (id)init
{
    return [self initWithAttributes:nil];
}

@end
