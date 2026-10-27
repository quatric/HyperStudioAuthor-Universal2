#import "HSAttributedStringRenderer.h"

// The layout manager and text container are owned by the text storage.
static HSAttributedStringRenderer *HSAttributedStringRendererShared = nil;
static HSStringRenderer *HSStringRendererShared = nil;

@implementation HSAttributedStringRenderer
+ (id)sharedRenderer
{
    if (!HSAttributedStringRendererShared)
        HSAttributedStringRendererShared = [self new];
    return HSAttributedStringRendererShared;
}
- (id)attributedStringByFittingAttributedString:(id)aString toSize:(NSSize)aSize boundingRect:(NSRect *)aRect
{
    NSRange wholeRange = NSMakeRange(0, 0);
    [self setContainerWidth:aSize.width];
    [self _prepareLayoutManagerForAttributedString:aString outWholeGlyphRange:&wholeRange];
    NSRect limit = NSMakeRect(NSZeroPoint.x, NSZeroPoint.y, aSize.width, aSize.height);
    NSRect rect = [_layoutManager boundingRectForGlyphRange:wholeRange inTextContainer:_tc];
    if (aRect)
        *aRect = rect;
    BOOL fits = NSEqualRects(limit, NSUnionRect(rect, limit));
    if (fits && rect.size.width != 0) {
        [_attrString autorelease];
        _attrString = [aString retain];
        return aString;
    }
    unichar ellipsisCharacter = 0x2026;
    NSString *ellipsis = [NSString stringWithCharacters:&ellipsisCharacter length:1];
    NSUInteger ellipsisLength = [ellipsis length];
    NSRange visible = [_layoutManager glyphRangeForBoundingRect:limit inTextContainer:_tc];
    NSUInteger hiddenStart = NSMaxRange(visible);
    NSRange hidden = [_layoutManager characterRangeForGlyphRange:NSMakeRange(hiddenStart, wholeRange.location - hiddenStart + wholeRange.length) actualGlyphRange:NULL];
    [_textStorage replaceCharactersInRange:hidden withString:ellipsis];
    NSUInteger length = hidden.location + ellipsisLength;
    NSUInteger deleteIndex = hidden.location - 1;
    NSUInteger remaining = hidden.location + 1;
    NSUInteger i;
    NSRange glyphRange = [_layoutManager glyphRangeForCharacterRange:NSMakeRange(0, ellipsisLength) actualCharacterRange:NULL];
    for (i = 0; i != hidden.location + 1; i++) {
        glyphRange = [_layoutManager glyphRangeForCharacterRange:NSMakeRange(0, length) actualCharacterRange:NULL];
        rect = [_layoutManager boundingRectForGlyphRange:glyphRange inTextContainer:_tc];
        fits = NSEqualRects(limit, NSUnionRect(rect, limit));
        if (fits || remaining <= 1)
            break;
        [_textStorage deleteCharactersInRange:NSMakeRange(deleteIndex, 1)];
        length--;
        remaining--;
        deleteIndex--;
    }
    if (!fits) {
        NSUInteger glyphLength = glyphRange.length;
        NSUInteger j;
        for (j = 0; j != glyphRange.length; j++) {
            rect = [_layoutManager boundingRectForGlyphRange:NSMakeRange(glyphRange.location, glyphLength) inTextContainer:_tc];
            fits = NSEqualRects(limit, NSUnionRect(rect, limit));
            if (fits)
                break;
            glyphLength--;
        }
        glyphRange.length = glyphLength;
    }
    id result = nil;
    if (fits && rect.size.width != 0)
        result = [_textStorage attributedSubstringFromRange:[_layoutManager characterRangeForGlyphRange:glyphRange actualGlyphRange:NULL]];
    if (aRect)
        *aRect = rect;
    [_attrString autorelease];
    _attrString = [result retain];
    return result;
}
- (NSRect)boundingRectOfAttributedString:(id)aString
{
    NSRange range;
    [self _prepareLayoutManagerForAttributedString:aString outWholeGlyphRange:&range];
    return NSIntegralRect([_layoutManager boundingRectForGlyphRange:range inTextContainer:_tc]);
}
- (void)drawAttributedString:(id)aString atPoint:(NSPoint)aPoint
{
    NSRange range;
    [self _prepareLayoutManagerForAttributedString:aString outWholeGlyphRange:&range];
    [_layoutManager drawGlyphsForGlyphRange:range atPoint:aPoint];
}
// An empty string is laid out as a single space.
- (void)_prepareLayoutManagerForAttributedString:(id)aString outWholeGlyphRange:(NSRange *)aRange
{
    NSUInteger length = [_textStorage length];
    if (_attrString != aString) {
        [_attrString release];
        _attrString = [aString retain];
        if ([aString length])
            [_textStorage replaceCharactersInRange:NSMakeRange(0, length) withAttributedString:aString];
        else
            [_textStorage replaceCharactersInRange:NSMakeRange(0, length) withString:@" "];
    }
    *aRange = [_layoutManager glyphRangeForCharacterRange:NSMakeRange(0, [_textStorage length]) actualCharacterRange:NULL];
}
- (void)setHyphenationFactor:(CGFloat)aFactor
{
    if ([_layoutManager respondsToSelector:@selector(setHyphenationFactor:)] && (float)[_layoutManager hyphenationFactor] != (float)aFactor)
        [_layoutManager setHyphenationFactor:aFactor];
}
- (void)setContainerWidth:(CGFloat)aWidth
{
    if (_width != (float)aWidth) {
        [_tc setContainerSize:NSMakeSize(aWidth, 10000)];
        _width = (float)aWidth;
    }
}
// The original sent -dealloc to the string and leaked the text storage.
- (void)dealloc
{
    if (HSAttributedStringRendererShared == self)
        HSAttributedStringRendererShared = nil;
    [_attrString release];
    [_textStorage release];
    [super dealloc];
}
- (id)init
{
    self = [super init];
    if (self) {
        _textStorage = [[NSTextStorage alloc] initWithString:@" "];
        [_textStorage addAttribute:NSFontAttributeName value:[NSFont systemFontOfSize:[NSFont smallSystemFontSize]] range:NSMakeRange(0, 1)];
        NSTextContainer *container = [[NSTextContainer alloc] initWithContainerSize:NSMakeSize(10000, 10000)];
        _layoutManager = [NSLayoutManager new];
        _tc = container;
        [_tc setHeightTracksTextView:YES];
        [_tc setWidthTracksTextView:NO];
        [_tc setLineFragmentPadding:2.0];
        [_layoutManager addTextContainer:_tc];
        [_tc release];
        [_textStorage addLayoutManager:_layoutManager];
        [_layoutManager release];
        _attrString = nil;
        _width = 0;
    }
    return self;
}
@end

@implementation HSStringRenderer
+ (id)sharedRenderer
{
    if (!HSStringRendererShared)
        HSStringRendererShared = [self new];
    return HSStringRendererShared;
}
- (id)stringByFittingString:(id)aString toSize:(NSSize)aSize boundingRect:(NSRect *)aRect
{
    NSRange wholeRange = NSMakeRange(0, 0);
    [self setContainerWidth:aSize.width];
    [self _prepareLayoutManagerForString:aString outWholeGlyphRange:&wholeRange];
    NSRect limit = NSMakeRect(NSZeroPoint.x, NSZeroPoint.y, aSize.width, aSize.height);
    NSRect rect = [_layoutManager boundingRectForGlyphRange:wholeRange inTextContainer:_tc];
    if (aRect)
        *aRect = rect;
    BOOL fits = NSEqualRects(limit, NSUnionRect(rect, limit));
    if (fits && rect.size.width != 0) {
        [_string release];
        _string = [aString retain];
        return aString;
    }
    unichar ellipsisCharacter = 0x2026;
    NSString *ellipsis = [NSString stringWithCharacters:&ellipsisCharacter length:1];
    NSUInteger ellipsisLength = [ellipsis length];
    NSRange visible = [_layoutManager glyphRangeForBoundingRect:limit inTextContainer:_tc];
    NSUInteger hiddenStart = NSMaxRange(visible);
    NSRange hidden = [_layoutManager characterRangeForGlyphRange:NSMakeRange(hiddenStart, wholeRange.location - hiddenStart + wholeRange.length) actualGlyphRange:NULL];
    [_textStorage replaceCharactersInRange:hidden withString:ellipsis];
    NSUInteger length = hidden.location + ellipsisLength;
    NSUInteger deleteIndex = hidden.location - 1;
    NSUInteger remaining = hidden.location + 1;
    NSUInteger i;
    NSRange glyphRange = [_layoutManager glyphRangeForCharacterRange:NSMakeRange(0, ellipsisLength) actualCharacterRange:NULL];
    for (i = 0; i != hidden.location + 1; i++) {
        glyphRange = [_layoutManager glyphRangeForCharacterRange:NSMakeRange(0, length) actualCharacterRange:NULL];
        rect = [_layoutManager boundingRectForGlyphRange:glyphRange inTextContainer:_tc];
        fits = NSEqualRects(limit, NSUnionRect(rect, limit));
        if (fits || remaining <= 1)
            break;
        [_textStorage deleteCharactersInRange:NSMakeRange(deleteIndex, 1)];
        length--;
        remaining--;
        deleteIndex--;
    }
    if (!fits) {
        NSUInteger glyphLength = glyphRange.length;
        NSUInteger j;
        for (j = 0; j != glyphRange.length; j++) {
            rect = [_layoutManager boundingRectForGlyphRange:NSMakeRange(glyphRange.location, glyphLength) inTextContainer:_tc];
            fits = NSEqualRects(limit, NSUnionRect(rect, limit));
            if (fits)
                break;
            glyphLength--;
        }
        glyphRange.length = glyphLength;
    }
    id result = nil;
    if (fits && rect.size.width != 0)
        result = [[[NSString alloc] initWithString:[[_textStorage attributedSubstringFromRange:[_layoutManager characterRangeForGlyphRange:glyphRange actualGlyphRange:NULL]] string]] autorelease];
    if (aRect)
        *aRect = rect;
    [_string release];
    _string = [result retain];
    return result;
}
- (NSRect)boundingRectOfString:(id)aString
{
    NSRange range;
    [self _prepareLayoutManagerForString:(aString ? aString : @"") outWholeGlyphRange:&range];
    return NSIntegralRect([_layoutManager boundingRectForGlyphRange:range inTextContainer:_tc]);
}
- (void)drawString:(id)aString atPoint:(NSPoint)aPoint withColor:(id)aColor
{
    NSRange range;
    [self _prepareLayoutManagerForString:(aString ? aString : @"") outWholeGlyphRange:&range];
    NSUInteger length = [_textStorage length];
    if (_color != aColor) {
        if (aColor)
            [_textStorage addAttribute:NSForegroundColorAttributeName value:aColor range:NSMakeRange(0, length)];
        else
            [_textStorage removeAttribute:NSForegroundColorAttributeName range:NSMakeRange(0, length)];
        [_color release];
        _color = [aColor retain];
    }
    [_layoutManager drawGlyphsForGlyphRange:range atPoint:aPoint];
}
- (void)_prepareLayoutManagerForString:(id)aString outWholeGlyphRange:(NSRange *)aRange
{
    NSUInteger length = [_textStorage length];
    if (_string != aString) {
        [_string release];
        _string = [aString retain];
        [_textStorage replaceCharactersInRange:NSMakeRange(0, length) withString:([aString length] ? aString : @" ")];
        [_textStorage addAttribute:NSFontAttributeName value:_font range:NSMakeRange(0, [_textStorage length])];
    }
    *aRange = [_layoutManager glyphRangeForCharacterRange:NSMakeRange(0, [_textStorage length]) actualCharacterRange:NULL];
}
- (void)setHyphenationFactor:(CGFloat)aFactor
{
    if ([_layoutManager respondsToSelector:@selector(setHyphenationFactor:)] && (float)[_layoutManager hyphenationFactor] != (float)aFactor)
        [_layoutManager setHyphenationFactor:aFactor];
}
- (void)setFont:(id)aFont
{
    if (_font != aFont) {
        NSUInteger length = [_textStorage length];
        if (aFont)
            [_textStorage addAttribute:NSFontAttributeName value:aFont range:NSMakeRange(0, length)];
        else
            [_textStorage removeAttribute:NSFontAttributeName range:NSMakeRange(0, length)];
        [_font release];
        _font = [aFont retain];
    }
}
- (void)setContainerWidth:(CGFloat)aWidth
{
    if (_width != (float)aWidth) {
        [_tc setContainerSize:NSMakeSize(aWidth, 10000)];
        _width = (float)aWidth;
    }
}
- (void)setAlignment:(NSUInteger)aAlignment
{
    if (_alignment != aAlignment) {
        [_textStorage setAlignment:aAlignment range:NSMakeRange(0, [_textStorage length])];
        _alignment = (unsigned int)aAlignment;
    }
}
- (void)dealloc
{
    if (HSStringRendererShared == self)
        HSStringRendererShared = nil;
    [_string release];
    [_font release];
    [_color release];
    [_textStorage release];
    [super dealloc];
}
- (id)init
{
    self = [super init];
    if (self) {
        _textStorage = [[NSTextStorage alloc] initWithString:@" "];
        [_textStorage addAttribute:NSFontAttributeName value:[NSFont systemFontOfSize:[NSFont systemFontSize]] range:NSMakeRange(0, 1)];
        [_textStorage setAlignment:NSTextAlignmentLeft range:NSMakeRange(0, 1)];
        NSTextContainer *container = [[NSTextContainer alloc] initWithContainerSize:NSMakeSize(10000, 10000)];
        _layoutManager = [NSLayoutManager new];
        _tc = container;
        [_tc setHeightTracksTextView:YES];
        [_tc setWidthTracksTextView:NO];
        [_tc setLineFragmentPadding:2.0];
        [_layoutManager addTextContainer:_tc];
        [_tc release];
        [_textStorage addLayoutManager:_layoutManager];
        [_layoutManager release];
        _string = nil;
        _font = nil;
        _color = nil;
        _alignment = 0;
        _width = 0;
    }
    return self;
}
@end
