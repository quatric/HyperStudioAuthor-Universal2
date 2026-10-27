#import "HSTextUnderlineRenderingInfo.h"
#import "HSColor.h"
#import "HSGradientColor.h"
#import "NSColor+HSGradientColorSupport.h"

// Relative float comparison (tolerance 0.0005 of the larger magnitude, with
// zero treated as 1).
static BOOL HSFloatsNearlyEqual(float a, float b)
{
    float ma = (a != 0.0f) ? fabsf(a) : 1.0f;
    float mb = (b != 0.0f) ? fabsf(b) : 1.0f;
    float m = mb <= ma ? ma : mb;
    return fabsf(a - b) <= m * 0.0005f;
}

@implementation HSTextUnderlineRenderingInfo

- (BOOL)joinInfo:(id)aInfo
{
    if ([self isAdjacent:aInfo] && [self isEqual:aInfo]) {
        [self setCharacterRange:NSUnionRange([self characterRange], [(HSTextUnderlineRenderingInfo *)aInfo characterRange])];
        return YES;
    }
    return NO;
}

- (BOOL)isAdjacent:(id)aAdjacent
{
    NSRange mine = [self characterRange];
    NSRange other = [(HSTextUnderlineRenderingInfo *)aAdjacent characterRange];
    return NSMaxRange(other) == mine.location || NSMaxRange(mine) == other.location;
}

- (BOOL)isEqual:(id)aEqual
{
    HSTextUnderlineRenderingInfo *other = aEqual;
    if ([self shouldUseSystemImplementationForRendering] && [other shouldUseSystemImplementationForRendering])
        return YES;
    if ([self shouldUseSystemImplementationForRendering] || [other shouldUseSystemImplementationForRendering])
        return NO;
    if ([self shouldDrawUnderline] != [other shouldDrawUnderline])
        return NO;
    if ([self shouldDrawUnderline] && [self underlineColor] != [other underlineColor]
        && ![[self underlineColor] isEqual:[other underlineColor]])
        return NO;
    if ([self shouldDrawOutline] != [other shouldDrawOutline])
        return NO;
    if ([self shouldDrawOutline]) {
        if (!HSFloatsNearlyEqual([self outlineWidth], [other outlineWidth]))
            return NO;
        if ([self outlineColor] != [other outlineColor] && ![[self outlineColor] isEqual:[other outlineColor]])
            return NO;
    }
    return HSFloatsNearlyEqual([self fontPointSize], [other fontPointSize]);
}

- (BOOL)outlineColorSameAsForegroundColor
{
    return _outlineColorSameAsForegroundColor;
}

- (BOOL)shouldDrawUnderline
{
    return _shouldDrawUnderline;
}

- (BOOL)shouldDrawOutline
{
    return _shouldDrawOutline;
}

- (CGFloat)fontPointSize
{
    return _fontPointSize;
}

- (CGFloat)outlineWidth
{
    return _outlineWidth;
}

- (id)underlineColor
{
    return _underlineColor;
}

- (id)outlineColor
{
    return _outlineColor;
}

- (void)setCharacterRange:(NSRange)aRange
{
    _characterRange = aRange;
}

- (NSRange)characterRange
{
    return _characterRange;
}

- (BOOL)shouldUseSystemImplementationForRendering
{
    if ([_underlineColor hyperGradientColor] == nil) {
        if (!_shouldDrawOutline)
            return YES;
        if (_shouldDrawUnderline)
            return _outlineColorSameAsForegroundColor;
    }
    return NO;
}

// The colors are retained by init but never released (original behaviour).
- (void)dealloc
{
    [super dealloc];
}

// A positive stroke width outlines only; a negative one fills (underlines)
// and outlines.
- (id)initWithAttributes:(id)aAttributes characterRange:(NSRange)aRange
{
    self = [super init];
    if (self == nil)
        return nil;
    _characterRange = aRange;
    NSColor *foreground = [aAttributes objectForKey:NSForegroundColorAttributeName];
    if (foreground == nil)
        foreground = [NSColor blackColor];
    NSColor *stroke = [aAttributes objectForKey:NSStrokeColorAttributeName];
    if (stroke == nil) {
        stroke = foreground;
        if ([foreground hyperGradientColor] != nil)
            stroke = [(HSColor *)[[foreground hyperGradientColor] hyperHSColor] hyperStartColor];
    }
    _outlineColor = [stroke retain];
    NSColor *underline = [aAttributes objectForKey:NSUnderlineColorAttributeName];
    if (underline != nil)
        foreground = underline;
    _underlineColor = [foreground retain];
    _shouldDrawOutline = NO;
    _shouldDrawUnderline = YES;
    _outlineColorSameAsForegroundColor = NO;
    NSNumber *strokeWidth = [aAttributes objectForKey:NSStrokeWidthAttributeName];
    if (strokeWidth == nil) {
        _outlineWidth = 0.0f;
    } else {
        float width = [strokeWidth floatValue];
        float magnitude = fabsf(width);
        _outlineWidth = magnitude;
        float m = (width != 0.0f) ? magnitude : 1.0f;
        float tolerance = (1.0f <= m) ? m * 0.0005f : 0.0005f;
        if (tolerance < magnitude) {
            _shouldDrawOutline = YES;
            _shouldDrawUnderline = width <= tolerance + 0.0f;
            _outlineColorSameAsForegroundColor = (foreground == stroke || [foreground isEqual:stroke]);
        }
    }
    _fontPointSize = [[aAttributes objectForKey:NSFontAttributeName] pointSize];
    return self;
}

@end

@implementation HSLayoutManager

// Runs of the underline are grouped by rendering info; plain ones go to
// NSLayoutManager, the rest are drawn by hyperDrawUnderline...
- (void)drawUnderlineForGlyphRange:(NSRange)aRange underlineType:(NSInteger)aType baselineOffset:(CGFloat)aOffset lineFragmentRect:(NSRect)aRect lineFragmentGlyphRange:(NSRange)aRange2 containerOrigin:(NSPoint)aOrigin
{
    NSTextContainer *container = [self textContainerForGlyphAtIndex:aRange.location effectiveRange:NULL];
    if ([self textStorage] == nil || container == nil)
        return;
    NSRange characterRange = [self characterRangeForGlyphRange:aRange actualGlyphRange:NULL];
    NSMutableArray *infos = nil;
    NSUInteger index = characterRange.location;
    while (index < NSMaxRange(characterRange)) {
        NSRange effective = NSMakeRange(0, 0);
        NSDictionary *attributes = [[self textStorage] attributesAtIndex:index effectiveRange:&effective];
        NSRange infoRange = NSIntersectionRange(effective, characterRange);
        HSTextUnderlineRenderingInfo *info = [[[HSTextUnderlineRenderingInfo alloc] initWithAttributes:attributes characterRange:infoRange] autorelease];
        index = NSMaxRange(effective);
        if (infos == nil) {
            infos = [NSMutableArray arrayWithObject:info];
        } else {
            BOOL joined = NO;
            NSUInteger i, count = [infos count];
            for (i = 0; i < count && !joined; i++)
                joined = [[infos objectAtIndex:i] joinInfo:info];
            if (!joined)
                [infos addObject:info];
        }
    }
    if (infos == nil || ([infos count] == 1 && [[infos lastObject] shouldUseSystemImplementationForRendering])) {
        [super drawUnderlineForGlyphRange:aRange underlineType:aType baselineOffset:aOffset lineFragmentRect:aRect lineFragmentGlyphRange:aRange2 containerOrigin:aOrigin];
        return;
    }
    if ([infos count] == 1) {
        [self hyperDrawUnderlineForGlyphRange:aRange underlineType:aType baselineOffset:aOffset lineFragmentRect:aRect lineFragmentGlyphRange:aRange2 containerOrigin:aOrigin info:[infos lastObject]];
        return;
    }
    NSUInteger i, count = [infos count];
    for (i = 0; i < count; i++) {
        HSTextUnderlineRenderingInfo *info = [infos objectAtIndex:i];
        NSRange glyphRange = [self glyphRangeForCharacterRange:[info characterRange] actualCharacterRange:NULL];
        if (![info shouldUseSystemImplementationForRendering])
            [self hyperDrawUnderlineForGlyphRange:glyphRange underlineType:aType baselineOffset:aOffset lineFragmentRect:aRect lineFragmentGlyphRange:aRange2 containerOrigin:aOrigin info:info];
        else
            [super drawUnderlineForGlyphRange:glyphRange underlineType:aType baselineOffset:aOffset lineFragmentRect:aRect lineFragmentGlyphRange:aRange2 containerOrigin:aOrigin];
    }
}

- (void)hyperDrawUnderlineForGlyphRange:(NSRange)aRange underlineType:(NSInteger)aType baselineOffset:(CGFloat)aOffset lineFragmentRect:(NSRect)aRect lineFragmentGlyphRange:(NSRange)aRange2 containerOrigin:(NSPoint)aOrigin info:(id)aInfo
{
    HSTextUnderlineRenderingInfo *info = aInfo;
    if (aRange.length == 0)
        return;
    if (![info shouldDrawUnderline] && ![info shouldDrawOutline])
        return;
    NSTextContainer *container = [self textContainerForGlyphAtIndex:aRange.location effectiveRange:NULL];
    NSBezierPath *path = [self underlineBezierPathForGlyphRange:aRange underlineType:aType baselineOffset:aOffset lineFragmentRect:aRect lineFragmentGlyphRange:aRange2 containerOrigin:aOrigin textContainer:container info:info];
    if ([info shouldDrawUnderline]) {
        NSColor *color = [info underlineColor];
        [[NSGraphicsContext currentContext] saveGraphicsState];
        [path addClip];
        if ([color hyperGradientColor] == nil) {
            [color set];
            [path fill];
        } else {
            // The gradient spans the container width down to the used text.
            NSSize size = [container containerSize];
            NSRect used = [self usedRectForTextContainer:container];
            NSRect bounds = NSMakeRect(aOrigin.x, aOrigin.y, size.width, NSMaxY(used));
            [(HSColor *)[[color hyperGradientColor] hyperHSColor] hyperDrawInRect:bounds ofBounds:bounds];
        }
        [[NSGraphicsContext currentContext] restoreGraphicsState];
    }
    if ([info shouldDrawOutline]) {
        [path setLineWidth:(CGFloat)(float)([info fontPointSize] * 0.01 * [info outlineWidth])];
        [(NSColor *)[info outlineColor] set];
        [path stroke];
    }
}

// A band 6% of the point size tall just below the glyph locations.
- (id)underlineBezierPathForGlyphRange:(NSRange)aRange underlineType:(NSInteger)aType baselineOffset:(CGFloat)aOffset lineFragmentRect:(NSRect)aRect lineFragmentGlyphRange:(NSRange)aRange2 containerOrigin:(NSPoint)aOrigin textContainer:(id)aContainer info:(id)aInfo
{
    double pointSize = [(HSTextUnderlineRenderingInfo *)aInfo fontPointSize];
    NSPoint location = [self locationForGlyphAtIndex:aRange.location];
    NSRect last = [self boundingRectForGlyphRange:NSMakeRange(NSMaxRange(aRange) - 1, 1) inTextContainer:aContainer];
    NSRect fragment = [self lineFragmentRectForGlyphAtIndex:aRange.location effectiveRange:NULL];
    float height = (float)(pointSize * 0.06);
    NSRect rect;
    rect.origin.x = fragment.origin.x + aOrigin.x + location.x;
    rect.origin.y = fragment.origin.y + location.y + aOrigin.y + height;
    rect.size.width = (last.origin.x + last.size.width) - location.x;
    rect.size.height = height;
    return [NSBezierPath bezierPathWithRect:rect];
}

// Glyphs are drawn through the CGE text renderer so outlined and gradient
// text can use the context attachments; Apple Color Emoji stays with
// NSLayoutManager.
- (void)showPackedGlyphs:(char *)aGlyphs length:(NSUInteger)aLength glyphRange:(NSRange)aRange atPoint:(NSPoint)aPoint font:(id)aFont color:(id)aColor printingAdjustment:(NSSize)aAdjustment
{
    NSString *fontName = [aFont fontName];
    if ([fontName isEqualToString:@"AppleColorEmoji"]) {
        [super showPackedGlyphs:aGlyphs length:aLength glyphRange:aRange atPoint:aPoint font:aFont color:aColor printingAdjustment:aAdjustment];
        return;
    }
    CGContextRef context = (CGContextRef)[[NSGraphicsContext currentContext] graphicsPort];
    if (context == NULL)
        return;
    NSSize single = NSZeroSize;
    NSUInteger count = aLength >> 1;
    NSSize *advances;
    if (count == 1) {
        advances = &single;
    } else {
        advances = [[NSMutableData dataWithLength:count * sizeof(NSSize)] mutableBytes];
        if (advances == NULL)
            return;
    }
    [aFont getAdvancements:advances forPackedGlyphs:aGlyphs length:aLength];
    if (!NSEqualSizes(aAdjustment, NSZeroSize) && count != 0) {
        NSUInteger i;
        for (i = 0; i < count; i++) {
            advances[i].width += aAdjustment.width;
            advances[i].height += aAdjustment.height;
        }
    }
    NSRange characterRange = [self characterRangeForGlyphRange:aRange actualGlyphRange:NULL];
    NSTextStorage *storage = [self textStorage];
    id strokeWidthValue = [storage attribute:NSStrokeWidthAttributeName atIndex:characterRange.location effectiveRange:NULL];
    float strokeWidth = strokeWidthValue ? [strokeWidthValue floatValue] : 0.0f;
    NSInteger drawingMode;
    if (strokeWidth < -0.001f)
        drawingMode = kCGTextFillStroke;
    else if (strokeWidth > 0.001f)
        drawingMode = kCGTextStroke;
    else
        drawingMode = kCGTextFill;
    if (strokeWidth > 0.001f)
        aColor = nil;
    id strokeColor = nil;
    if (strokeWidth < -0.001f || strokeWidth > 0.001f)
        strokeColor = [storage attribute:NSStrokeColorAttributeName atIndex:characterRange.location effectiveRange:NULL];
    HSLayoutManager_HSGlyphDrawingInfo *info = [HSLayoutManager_HSGlyphDrawingInfo glyphDrawingInfoForContext:context];
    [info attachFont:aFont toContext:context];
    [info attachTextDrawingMode:drawingMode toContext:context];
    [info attachFillColor:aColor strokeColor:strokeColor colorBoundsForTextContainerForGlyphAtIndex:aRange.location atLayoutManager:self toContext:context];
    if (strokeColor != nil) {
        [info attachTextStrokingMode:2 toContext:context];
        [info attachLineWidth:fabsf(strokeWidth) * (float)[aFont pointSize] * 0.01 toContext:context];
    }
    CGContextSetTextPosition(context, aPoint.x, aPoint.y);
    if ([fontName isEqualToString:@"GB18030Bitmap"])
        CGContextShowGlyphsWithAdvances(context, (const CGGlyph *)aGlyphs, (const CGSize *)advances, count);
    else
        CGEContextShowGlyphsWithAdvances(context, (const CGGlyph *)aGlyphs, (const CGSize *)advances, count);
}

- (void)drawGlyphsForGlyphRange:(NSRange)aRange atPoint:(NSPoint)aPoint
{
    CGContextRef context = (CGContextRef)[[NSGraphicsContext currentContext] graphicsPort];
    CGEContextSaveAttachments(context);
    [super drawGlyphsForGlyphRange:aRange atPoint:aPoint];
    CGEContextRestoreAttachments(context);
}

@end

@implementation HSLayoutManager_HSGlyphDrawingInfo

+ (id)glyphDrawingInfoForContext:(struct CGContext *)aContext
{
    id info = (id)CGEContextGetAttachmentForKey(aContext, CFSTR("HSLayoutManager_HSGlyphDrawingInfo"));
    if (info == nil) {
        info = [[[HSLayoutManager_HSGlyphDrawingInfo alloc] init] autorelease];
        if (info != nil)
            CGEContextSetAttachmentForKey(aContext, CFSTR("HSLayoutManager_HSGlyphDrawingInfo"), info);
    }
    return info;
}

// Colors without a plain CGColor (gradients) need the container bounds.
- (void)attachFillColor:(id)aColor strokeColor:(id)aColor2 colorBoundsForTextContainerForGlyphAtIndex:(NSUInteger)aIndex atLayoutManager:(id)aManager toContext:(struct CGContext *)aContext
{
    BOOL needsBounds = NO;
    if (_fillColor != aColor) {
        [aColor retain];
        [_fillColor release];
        _fillColor = aColor;
        CGEColorRef color = [aColor BT_coreGraphicsExtendedColor];
        if (color != NULL) {
            CGEContextSetColorAttachmentForKey(aContext, (CFStringRef)kCGEContextFillColorAttachmentKey, color, NULL);
            needsBounds = CGEColorGetCGColor(color) == NULL;
        }
    }
    if (_strokeColor != aColor2) {
        [aColor2 retain];
        [_strokeColor release];
        _strokeColor = aColor2;
        CGEColorRef color = [aColor2 BT_coreGraphicsExtendedColor];
        if (color != NULL) {
            CGEContextSetColorAttachmentForKey(aContext, (CFStringRef)kCGEContextStrokeColorAttachmentKey, color, NULL);
            if (!needsBounds)
                needsBounds = CGEColorGetCGColor(color) == NULL;
        }
    }
    if (!needsBounds)
        return;
    NSTextContainer *container = [aManager textContainerForGlyphAtIndex:aIndex effectiveRange:NULL];
    if (container == _textContainer)
        return;
    [container retain];
    [_textContainer release];
    _textContainer = container;
    NSRect used = [aManager usedRectForTextContainer:container];
    NSSize size = [_textContainer containerSize];
    CGRect bounds = CGRectMake(used.origin.x, used.origin.y, size.width, used.size.height);
    CFDataRef data = CFDataCreate(kCFAllocatorDefault, (const UInt8 *)&bounds, sizeof(bounds));
    if (data != NULL) {
        CGEContextSetAttachmentForKey(aContext, (CFStringRef)kCGEContextFillColorBoundsAttachmentKey, data);
        CGEContextSetAttachmentForKey(aContext, (CFStringRef)kCGEContextStrokeColorBoundsAttachmentKey, data);
        CFRelease(data);
    }
}

- (void)attachLineWidth:(CGFloat)aWidth toContext:(struct CGContext *)aContext
{
    float width = (float)aWidth;
    if (_lineWidth == width)
        return;
    _lineWidth = width;
    CFNumberRef number = CFNumberCreate(kCFAllocatorDefault, kCFNumberFloatType, &width);
    if (number != NULL) {
        CGEContextSetAttachmentForKey(aContext, (CFStringRef)kCGEContextLineWidthAttachmentKey, number);
        CFRelease(number);
    }
}

- (void)attachTextStrokingMode:(NSInteger)aMode toContext:(struct CGContext *)aContext
{
    if (_textStrokingMode == aMode)
        return;
    _textStrokingMode = (int)aMode;
    char value = (char)aMode;
    CFNumberRef number = CFNumberCreate(kCFAllocatorDefault, kCFNumberCharType, &value);
    if (number != NULL) {
        CGEContextSetAttachmentForKey(aContext, (CFStringRef)kCGEContextTextStrokingModeAttachmentKey, number);
        CFRelease(number);
    }
}

- (void)attachTextDrawingMode:(NSInteger)aMode toContext:(struct CGContext *)aContext
{
    if (_textDrawingMode == aMode)
        return;
    _textDrawingMode = (int)aMode;
    char value = (char)aMode;
    CFNumberRef number = CFNumberCreate(kCFAllocatorDefault, kCFNumberCharType, &value);
    if (number != NULL) {
        CGEContextSetAttachmentForKey(aContext, (CFStringRef)kCGEContextTextDrawingModeAttachmentKey, number);
        CFRelease(number);
    }
}

- (void)attachFont:(id)aFont toContext:(struct CGContext *)aContext
{
    if (_font == aFont)
        return;
    [aFont retain];
    [_font release];
    _font = aFont;
    CGEContextSetAttachmentForKey(aContext, (CFStringRef)kCGEContextFontAttachmentKey, aFont);
}

- (void)dealloc
{
    [_font release];
    [_fillColor release];
    [_strokeColor release];
    [_textContainer release];
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self != nil) {
        _textDrawingMode = -1;
        _textStrokingMode = 0;
    }
    return self;
}

@end
