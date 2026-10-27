#import "CGEText.h"
#import "CGEContext.h"
#import "CGEColor.h"
#import "CGEPath.h"
#import "SMKApplicationKitData.h"

// The original drew text at a scale under 512 through a cache of glyph masks
// (subpixel-positioned 8-bit bitmaps composited into pooled 2048 x 2047 mask
// layers) and larger text as paths, compositing the stroke-outside mode with
// mask layers as well. Quartz caches glyph rendering itself now, so every size
// goes through paths; the compositing is done with a transparency layer.

enum {
    kStrokeCentered = 0,
    kStrokeInside = 1,
    kStrokeOutside = 2,
};

typedef struct {
    CGFloat width;
    CGLineCap cap;
    CGLineJoin join;
    CGFloat miterLimit;
    CGFloat phase;
    CFDataRef lengths; // CGFloats, retained
} LineStyle;

static bool GetCharAttachment(CGContextRef context, CFStringRef key, uint8_t *value)
{
    CFNumberRef number = CGEContextGetAttachmentForKey(context, key);
    return number && CFNumberGetValue(number, kCFNumberCharType, value);
}

static void GetFloatAttachment(CGContextRef context, CFStringRef key, CGFloat *value)
{
    CFNumberRef number = CGEContextGetAttachmentForKey(context, key);
    if (number)
        CFNumberGetValue(number, kCFNumberCGFloatType, value);
}

// +1, from a CGColor or a one-color array.
static CGEColorRef CopyColorAttachment(CGContextRef context, CFStringRef key, CFStringRef boundsKey, CGRect *bounds)
{
    *bounds = CGRectNull;
    CFTypeRef value = CGEContextGetAttachmentForKey(context, key);
    if (!value)
        return NULL;
    CGEColorRef color = CFGetTypeID(value) == CGColorGetTypeID()
                            ? CGEColorCreateWithCGColor((CGColorRef)value)
                            : CGEColorRetain((CGEColorRef)CFArrayGetValueAtIndex(value, 0));
    if (color) {
        CFDataRef data = CGEContextGetAttachmentForKey(context, boundsKey);
        if (data)
            *bounds = *(const CGRect *)CFDataGetBytePtr(data);
    }
    return color;
}

static void GetLineStyle(CGContextRef context, LineStyle *style)
{
    style->width = 1;
    GetFloatAttachment(context, (CFStringRef)kCGEContextLineWidthAttachmentKey, &style->width);
    if (style->width <= 0)
        return;
    uint8_t value = 0;
    style->cap = GetCharAttachment(context, (CFStringRef)kCGEContextLineCapAttachmentKey, &value) ? value : 0;
    value = 0;
    style->join = GetCharAttachment(context, (CFStringRef)kCGEContextLineJoinAttachmentKey, &value) ? value : 0;
    if (style->join == kCGLineJoinMiter)
        GetFloatAttachment(context, (CFStringRef)kCGEContextMiterLimitAttachmentKey, &style->miterLimit);
    CFDataRef lengths = CGEContextGetAttachmentForKey(context, (CFStringRef)kCGEContextLineDashLengthsAttachmentKey);
    if (lengths && CFGetTypeID(lengths) != CFNullGetTypeID() && CFDataGetLength(lengths)) {
        style->lengths = CFRetain(lengths);
        GetFloatAttachment(context, (CFStringRef)kCGEContextLineDashPhaseAttachmentKey, &style->phase);
    }
}

static void ApplyLineStyle(CGContextRef context, const LineStyle *style)
{
    CGContextSetLineWidth(context, style->width);
    CGContextSetLineCap(context, style->cap);
    CGContextSetLineJoin(context, style->join);
    CGContextSetMiterLimit(context, style->miterLimit);
    if (style->lengths)
        CGContextSetLineDash(context, style->phase, (const CGFloat *)CFDataGetBytePtr(style->lengths),
                             CFDataGetLength(style->lengths) / sizeof(CGFloat));
    else
        CGContextSetLineDash(context, 0, NULL, 0);
}

static void FillPath(CGContextRef context, CGPathRef path, CGEColorRef color, CGRect bounds)
{
    CGContextSaveGState(context);
    CGContextBeginPath(context);
    CGContextAddPath(context, path);
    CGEContextFillPathWithColor(context, NULL, bounds, color);
    CGContextRestoreGState(context);
}

static void StrokePath(CGContextRef context, CGPathRef path, CGEColorRef color, CGRect bounds)
{
    CGContextSaveGState(context);
    CGContextBeginPath(context);
    CGContextAddPath(context, path);
    CGEContextStrokePathWithColor(context, NULL, bounds, color);
    CGContextRestoreGState(context);
}

static void DrawGlyphPath(CGContextRef context, CGPathRef path, CGEColorRef fill, CGRect fillBounds,
                          CGEColorRef stroke, CGRect strokeBounds, int strokingMode)
{
    if (stroke && strokingMode == kStrokeOutside) {
        // The stroke only where the glyphs don't cover: under the fill, or
        // cut out by the glyphs' coverage.
        CGContextBeginTransparencyLayer(context, NULL);
        if (fill) {
            FillPath(context, path, fill, fillBounds);
            CGContextSetBlendMode(context, kCGBlendModeDestinationOver);
            StrokePath(context, path, stroke, strokeBounds);
        } else {
            StrokePath(context, path, stroke, strokeBounds);
            CGContextSetBlendMode(context, kCGBlendModeDestinationOut);
            CGContextSetGrayFillColor(context, 0, 1);
            CGContextBeginPath(context);
            CGContextAddPath(context, path);
            CGContextFillPath(context);
        }
        CGContextEndTransparencyLayer(context);
        return;
    }
    if (stroke && strokingMode == kStrokeInside) {
        CGContextBeginPath(context);
        CGContextAddPath(context, path);
        CGContextClip(context);
    }
    if (fill)
        FillPath(context, path, fill, fillBounds);
    if (stroke)
        StrokePath(context, path, stroke, strokeBounds);
}

// The text matrix with the position moved past the glyphs.
static CGPoint PositionAfter(CGAffineTransform textMatrix, const CGSize *advances, size_t count)
{
    CGPoint position = CGPointMake(textMatrix.tx, textMatrix.ty);
    for (size_t i = 0; i < count; i++) {
        position.x += advances[i].width;
        position.y += advances[i].height;
    }
    return position;
}

void CGEContextShowGlyphsWithAdvances(CGContextRef context, const CGGlyph *glyphs, const CGSize *advances,
                                      size_t count)
{
    if (!context || !count || CGRectIsEmpty(CGContextGetClipBoundingBox(context)))
        return;
    uint8_t mode;
    if (!GetCharAttachment(context, (CFStringRef)kCGEContextTextDrawingModeAttachmentKey, &mode))
        return;

    LineStyle style = {1, kCGLineCapButt, kCGLineJoinMiter, 10, 0, NULL};
    CGEColorRef stroke = NULL, fill = NULL;
    CGRect strokeBounds = CGRectNull, fillBounds = CGRectNull;
    uint8_t strokingMode = kStrokeCentered;
    if (mode == kCGTextStroke || mode == kCGTextFillStroke || mode == kCGTextStrokeClip ||
        mode == kCGTextFillStrokeClip) {
        GetLineStyle(context, &style);
        if (style.width > 0) {
            stroke = CopyColorAttachment(context, (CFStringRef)kCGEContextStrokeColorAttachmentKey,
                                         (CFStringRef)kCGEContextStrokeColorBoundsAttachmentKey, &strokeBounds);
            if (stroke && !GetCharAttachment(context, (CFStringRef)kCGEContextTextStrokingModeAttachmentKey,
                                             &strokingMode))
                strokingMode = kStrokeCentered;
        }
    }
    if (mode == kCGTextFill || mode == kCGTextFillStroke || mode == kCGTextFillClip || mode == kCGTextFillStrokeClip)
        fill = CopyColorAttachment(context, (CFStringRef)kCGEContextFillColorAttachmentKey,
                                   (CFStringRef)kCGEContextFillColorBoundsAttachmentKey, &fillBounds);
    bool clip = mode == kCGTextFillClip || mode == kCGTextStrokeClip || mode == kCGTextFillStrokeClip ||
                mode == kCGTextClip;

    CFTypeRef font = CGEContextGetAttachmentForKey(context, (CFStringRef)kCGEContextFontAttachmentKey);
    CGAffineTransform textMatrix = CGContextGetTextMatrix(context);
    if (!clip && !fill && !stroke) {
        // Nothing to draw: just move past the glyphs.
        CGPoint position = CGContextGetTextPosition(context);
        for (size_t i = 0; i < count; i++) {
            position.x += advances[i].width;
            position.y += advances[i].height;
        }
        CGContextSetTextPosition(context, position.x, position.y);
    } else if (font) {
        CGMutablePathRef path = CGPathCreateMutable();
        if (path) {
            CGEPathAddGlyphs(path, NULL, &textMatrix, font, glyphs, advances, count);
            if (fill || stroke) {
                CGContextSaveGState(context);
                if (stroke)
                    ApplyLineStyle(context, &style);
                if (!CGPathIsEmpty(path))
                    DrawGlyphPath(context, path, fill, fillBounds, stroke, strokeBounds, strokingMode);
                CGContextRestoreGState(context);
            }
            CGPoint position = PositionAfter(textMatrix, advances, count);
            CGContextSetTextPosition(context, position.x, position.y);
            if (clip) {
                CGContextBeginPath(context);
                if (CGPathIsEmpty(path))
                    CGContextClipToRect(context, CGRectZero);
                else {
                    CGContextAddPath(context, path);
                    CGContextClip(context);
                }
            }
            CGPathRelease(path);
        }
    }
    CGEColorRelease(fill);
    CGEColorRelease(stroke);
    if (style.lengths)
        CFRelease(style.lengths);
}

void CGEContextAddGlyphs(CGContextRef context, const CGGlyph *glyphs, const CGSize *advances, size_t count)
{
    if (!context || !count || CGRectIsEmpty(CGContextGetClipBoundingBox(context)))
        return;
    CFTypeRef font = CGEContextGetAttachmentForKey(context, (CFStringRef)kCGEContextFontAttachmentKey);
    if (!font)
        return;
    CGMutablePathRef path = CGPathCreateMutable();
    CGAffineTransform textMatrix = CGContextGetTextMatrix(context);
    CGEPathAddGlyphs(path, NULL, &textMatrix, font, glyphs, advances, count);
    if (!CGPathIsEmpty(path))
        CGContextAddPath(context, path);
    CGPathRelease(path);
}

bool CGEFontGetGlyphBBoxes(CGFontRef font, const CGGlyph *glyphs, size_t count, CGRect *bboxes)
{
    return CGFontGetGlyphBBoxes(font, glyphs, count, bboxes);
}
