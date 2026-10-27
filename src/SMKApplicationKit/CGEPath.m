// Paths (SMKApplicationKit's CGEPath functions).
#import "CGEPath.h"
#import "CFEURL.h"
#import <CoreText/CoreText.h>
#import <pthread.h>

#pragma mark Bounds

typedef struct {
    CGAffineTransform m;
    CGRect bounds;
    bool isFirst;
} BoundsInfo;

static void BoundsAddPoint(BoundsInfo *info, CGPoint point)
{
    point = CGPointApplyAffineTransform(point, info->m);
    if (info->isFirst) {
        info->bounds = (CGRect){point, CGSizeZero};
        info->isFirst = false;
        return;
    }
    CGRect *bounds = &info->bounds;
    if (point.x < bounds->origin.x) {
        bounds->size.width += bounds->origin.x - point.x;
        bounds->origin.x = point.x;
    } else if (bounds->origin.x + bounds->size.width < point.x)
        bounds->size.width = point.x - bounds->origin.x;
    if (point.y < bounds->origin.y) {
        bounds->size.height += bounds->origin.y - point.y;
        bounds->origin.y = point.y;
    } else if (bounds->origin.y + bounds->size.height < point.y)
        bounds->size.height = point.y - bounds->origin.y;
}

static void BoundsApplier(void *info, const CGPathElement *element)
{
    switch (element->type) {
    case kCGPathElementMoveToPoint:
    case kCGPathElementAddLineToPoint:
        BoundsAddPoint(info, element->points[0]);
        break;
    case kCGPathElementAddQuadCurveToPoint:
        BoundsAddPoint(info, element->points[0]);
        BoundsAddPoint(info, element->points[1]);
        break;
    case kCGPathElementAddCurveToPoint:
        BoundsAddPoint(info, element->points[0]);
        BoundsAddPoint(info, element->points[1]);
        BoundsAddPoint(info, element->points[2]);
        break;
    case kCGPathElementCloseSubpath:
        break;
    default:
        CFShow(CFSTR("Unknown / unsupported path element type!"));
    }
}

CGRect CGEPathGetBoundingBox(CGPathRef path, const CGAffineTransform *m)
{
    if (m && !CGAffineTransformIsIdentity(*m)) {
        BoundsInfo info = {*m, CGRectNull, true};
        CGPathApply(path, &info, BoundsApplier);
        return info.bounds;
    }
    return CGPathGetBoundingBox(path);
}

CGRect CGEPathGetPathBoundingBox(CGPathRef path)
{
    return CGPathGetPathBoundingBox(path);
}

// A 1×1 mask context per thread for stroking paths.
static pthread_key_t sScratchContextKey;

static void ScratchContextRelease(void *context)
{
    CGContextRelease(context);
}

static CGContextRef ScratchContext(void)
{
    static dispatch_once_t once;
    static bool hasKey;
    static uint8_t pixel;
    dispatch_once(&once, ^{
        hasKey = pthread_key_create(&sScratchContextKey, ScratchContextRelease) == 0;
    });
    if (!hasKey)
        return NULL;
    CGContextRef context = pthread_getspecific(sScratchContextKey);
    if (!context) {
        context = CGBitmapContextCreate(&pixel, 1, 1, 8, 1, NULL, (CGBitmapInfo)kCGImageAlphaOnly);
        if (context && pthread_setspecific(sScratchContextKey, context) != 0) {
            CGContextRelease(context);
            context = NULL;
        }
    }
    return context;
}

// Leaves path stroked as the context's path, in the context's base space.
static CGContextRef ScratchContextWithStrokedPath(CGPathRef path, const CGAffineTransform *m, CGFloat lineWidth,
        CGLineCap cap, CGLineJoin join, CGFloat miterLimit, CGFloat phase, const CGFloat *lengths, size_t count,
        const CGAffineTransform *ctm)
{
    CGContextRef context = ScratchContext();
    if (!context)
        return NULL;
    CGContextSaveGState(context);
    if (ctm)
        CGContextConcatCTM(context, *ctm);
    CGContextSetLineWidth(context, lineWidth);
    CGContextSetLineCap(context, cap);
    CGContextSetLineJoin(context, join);
    CGContextSetMiterLimit(context, miterLimit);
    CGContextSetLineDash(context, phase, lengths, count);
    CGContextBeginPath(context);
    if (!m)
        CGContextAddPath(context, path);
    else {
        CGContextConcatCTM(context, *m);
        CGContextAddPath(context, path);
        CGContextConcatCTM(context, CGAffineTransformInvert(*m));
    }
    CGContextReplacePathWithStrokedPath(context);
    CGContextRestoreGState(context);
    return context;
}

CGRect CGEPathGetStrokedPathBoundingBox(CGPathRef path, const CGAffineTransform *m, CGFloat lineWidth,
                                        CGLineCap cap, CGLineJoin join, CGFloat miterLimit, CGFloat phase,
                                        const CGFloat *lengths, size_t count, const CGAffineTransform *ctm)
{
    CGRect bounds = CGRectNull;
    CGContextRef context = ScratchContextWithStrokedPath(path, m, lineWidth, cap, join, miterLimit, phase,
                                                         lengths, count, ctm);
    if (context) {
        CGPathRef stroked = CGContextCopyPath(context);
        CGContextBeginPath(context);
        if (stroked) {
            bounds = CGEPathGetPathBoundingBox(stroked);
            CGPathRelease(stroked);
        }
    }
    return bounds;
}

CGRect CGEPathGetStrokeBoundingBox(CGPathRef path, const CGAffineTransform *m, CGFloat lineWidth,
                                   CGLineCap cap, CGLineJoin join, CGFloat miterLimit, CGFloat phase,
                                   const CGFloat *lengths, size_t count, const CGAffineTransform *ctm)
{
    CGRect bounds = CGRectNull;
    CGContextRef context = ScratchContextWithStrokedPath(path, m, lineWidth, cap, join, miterLimit, phase,
                                                         lengths, count, ctm);
    if (context) {
        bounds = CGContextGetPathBoundingBox(context);
        CGContextBeginPath(context);
    }
    return bounds;
}

bool CGEPathContainsPoint(CGPathRef path, const CGAffineTransform *m, CGPoint point, bool eoFill)
{
    return CGPathContainsPoint(path, m, point, eoFill);
}

void CGEPathShow(CGPathRef path, const CGAffineTransform *m)
{
    if (!path)
        return;
    CFURLRef url = CFEURLCreateTemporaryFileURLForObject(kUTTypePDF, CFSTR("CGPathRef"), path);
    if (!url)
        return;
    CGPathRef shown = path;
    if (m) {
        CGMutablePathRef copy = CGPathCreateMutable();
        if (!copy) {
            CFRelease(url);
            return;
        }
        CGPathAddPath(copy, m, path);
        shown = copy;
    }
    CGRect box = CGRectInset(CGPathGetBoundingBox(shown), -10, -10);
    CGContextRef context = CGPDFContextCreateWithURL(url, &box, NULL);
    if (context) {
        CGContextBeginPage(context, &box);
        CGContextSetRGBStrokeColor(context, 0, 0.5, 0, 1);
        CGContextBeginPath(context);
        CGContextAddPath(context, shown);
        CGContextStrokePath(context);
        CGContextEndPage(context);
        CGContextBeginPage(context, &box);
        CGContextSetRGBFillColor(context, 0, 0.5, 0, 1);
        CGContextBeginPath(context);
        CGContextAddPath(context, shown);
        CGContextFillPath(context);
        CGContextEndPage(context);
        CGContextBeginPage(context, &box);
        CGContextSetRGBFillColor(context, 0, 0.5, 0, 1);
        CGContextBeginPath(context);
        CGContextAddPath(context, shown);
        CGContextEOFillPath(context);
        CGContextEndPage(context);
        CGContextRelease(context);
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        LSOpenCFURLRef(url, NULL);
#pragma clang diagnostic pop
    }
    if (shown != path)
        CGPathRelease(shown);
    CFRelease(url);
}

#pragma mark Glyphs

// The CTFont to outline font's glyphs with and the matrix taking them to one
// unit to the em.
static CTFontRef GlyphFontCreate(CFTypeRef font, CGAffineTransform *unitMatrix)
{
    if (CFGetTypeID(font) == CGFontGetTypeID()) {
        CTFontRef ctFont = CTFontCreateWithGraphicsFont((CGFontRef)font, 12, NULL, NULL);
        if (ctFont)
            *unitMatrix = CGAffineTransformMakeScale(1.0 / 12, 1.0 / 12);
        return ctFont;
    }
    CTFontRef ctFont = CFRetain(font);
    CGFloat scale = 1 / CTFontGetSize(ctFont);
    CGAffineTransform inverse = CGAffineTransformInvert(CTFontGetMatrix(ctFont));
    *unitMatrix = (CGAffineTransform){inverse.a * scale, inverse.b * scale, inverse.c * scale,
                                      inverse.d * scale, inverse.tx * scale, inverse.ty * scale};
    return ctFont;
}

// An empty path for glyphs with no outline.
static CGPathRef GlyphPathCreate(CTFontRef font, const CGAffineTransform *unitMatrix, CGGlyph glyph)
{
    CGPathRef path = CTFontCreatePathForGlyph(font, glyph, unitMatrix);
    return path ? path : CGPathCreateMutable();
}

CGPathRef CGEPathCreateWithGlyph(const CGAffineTransform *m, CFTypeRef font, CGGlyph glyph)
{
    if (!font)
        return NULL;
    CGAffineTransform unitMatrix;
    CTFontRef ctFont = GlyphFontCreate(font, &unitMatrix);
    if (!ctFont)
        return NULL;
    CGPathRef path = GlyphPathCreate(ctFont, &unitMatrix, glyph);
    CFRelease(ctFont);
    if (!path || !m || CGPathIsEmpty(path))
        return path;
    CGMutablePathRef transformed = CGPathCreateMutable();
    CGPathAddPath(transformed, m, path);
    CGPathRelease(path);
    return transformed;
}

void CGEPathAddGlyphs(CGMutablePathRef path, const CGAffineTransform *m, const CGAffineTransform *textMatrix,
                      CFTypeRef font, const CGGlyph *glyphs, const CGSize *advances, size_t count)
{
    if (!path || !font || !glyphs)
        return;
    CGAffineTransform unitMatrix;
    CTFontRef ctFont = GlyphFontCreate(font, &unitMatrix);
    if (!ctFont)
        return;
    CGAffineTransform placement = textMatrix ? *textMatrix : CGAffineTransformIdentity;
    for (size_t i = 0; i < count; i++) {
        CGPathRef glyphPath = GlyphPathCreate(ctFont, &unitMatrix, glyphs[i]);
        if (!glyphPath)
            break;
        if (!CGPathIsEmpty(glyphPath)) {
            CGAffineTransform t = m ? CGAffineTransformConcat(placement, *m) : placement;
            CGPathAddPath(path, &t, glyphPath);
        }
        CGPathRelease(glyphPath);
        placement.tx += advances[i].width;
        placement.ty += advances[i].height;
    }
    CFRelease(ctFont);
}

#pragma mark Pixelized lines

// point on the grid of size, as position says relative to other.
static CGPoint PixelizePoint(CGPoint point, CGPoint other, CGSize size, CGEPixelizationPosition position,
                             CGPoint exact)
{
    CGPoint result;
    switch (position) {
    case kCGEPixelizationPositionNearest:
        result.x = size.width * round(point.x / size.width);
        result.y = size.height * round(point.y / size.height);
        break;
    case kCGEPixelizationPositionInside:
        if (point.x > other.x)
            result.x = floor(point.x / size.width);
        else if (point.x < other.x)
            result.x = ceil(point.x / size.width);
        else
            result.x = round(point.x / size.width);
        result.x *= size.width;
        // The original tests x here when choosing between rounding and ceil.
        if (point.y > other.y)
            result.y = floor(point.y / size.height);
        else if (other.x <= point.x)
            result.y = round(point.y / size.height);
        else
            result.y = ceil(point.y / size.height);
        result.y *= size.height;
        break;
    case kCGEPixelizationPositionOutside:
        result.x = size.width * (other.x < point.x ? ceil(point.x / size.width) : floor(point.x / size.width));
        result.y = size.height * (other.y < point.y ? ceil(point.y / size.height) : floor(point.y / size.height));
        break;
    case kCGEPixelizationPositionExact:
        result = exact;
        break;
    default:
        CFShow(CFSTR("Invalid / unsupported pixelization point position!"));
        result = point;
    }
    return result;
}

void CGEPolylinePixelizeLine(CGPoint start, CGPoint end, CGSize pixelSize, CGEPixelizationPosition startPosition,
                             CGPoint exactStart, CGEPixelizationPosition endPosition, void *info,
                             CGEPolylineApplierFunction function)
{
    CGFloat w = pixelSize.width, h = pixelSize.height;
    CGPoint s = PixelizePoint(start, end, pixelSize, startPosition, exactStart);
    CGPoint e = PixelizePoint(end, start, pixelSize, endPosition, end);
    function(info, kCGEPolylinePointStart, s);
    CGFloat fx = w * 0.01, fy = h * 0.01;
    if ((e.x < s.x - fx || s.x + fx < e.x) && (e.y < s.y - fy || s.y + fy < e.y)) {
        // A diagonal: steps along the line, sideways where the line is
        // nearer the next column than the next row.
        CGFloat cx = e.x, lastY = s.y;
        if (start.x != end.x && start.y != end.y) {
            CGFloat slope = (end.y - start.y) / (end.x - start.x);
            CGFloat intercept = fma(-slope, end.x, end.y);
            CGFloat dx = e.x <= s.x ? -w : w;
            CGFloat dy = e.y <= s.y ? -h : h;
            CGFloat nextY = s.y + dy;
            CGFloat remainingY = fabs(e.y - s.y), remainingX = fabs(e.x - s.x);
            CGPoint current = s, last = s;
            for (;;) {
                CGFloat cy = current.y;
                cx = current.x;
                CGFloat keptX = cx;
                CGFloat lastX;
                for (;;) {
                    lastY = last.y;
                    lastX = last.x;
                    if (remainingX <= fx || remainingY <= fy)
                        goto done;
                    CGFloat here = fma(slope, cx, intercept);
                    CGFloat there = fma(slope, cx + dx, intercept);
                    if (fabs(there - lastY) <= fabs(here - nextY))
                        break;
                    if (lastX < cx - fx || cx + fx < lastX) {
                        function(info, kCGEPolylinePointStep, CGPointMake(cx, lastY));
                        lastX = cx;
                    } else
                        lastY = cy;
                    cy = lastY;
                    remainingY -= h;
                    last = CGPointMake(lastX, nextY);
                    nextY += dy;
                }
                if (cy < lastY - fy || lastY + fy < cy) {
                    function(info, kCGEPolylinePointStep, CGPointMake(cx, lastY));
                    cy = lastY;
                } else
                    keptX = lastX;
                current = CGPointMake(cx + dx, cy);
                remainingX -= w;
                last = CGPointMake(keptX, lastY);
            }
        }
    done:
        function(info, kCGEPolylinePointStep, CGPointMake(cx, lastY));
    }
    function(info, kCGEPolylinePointEnd, e);
}

typedef struct {
    CGMutablePathRef path;
    const CGAffineTransform *m;
    bool movesToStart;
} PixelizedLineInfo;

static void PixelizedLineApplier(void *info, CGEPolylinePointType type, CGPoint point)
{
    PixelizedLineInfo *line = info;
    switch (type) {
    case kCGEPolylinePointStart:
        if (line->movesToStart) {
            CGPathMoveToPoint(line->path, line->m, point.x, point.y);
            return;
        }
        break;
    case kCGEPolylinePointStep:
    case kCGEPolylinePointEnd:
        break;
    default:
        CFShow(CFSTR("Invalid / unsupported polyline point type!"));
        return;
    }
    CGPathAddLineToPoint(line->path, line->m, point.x, point.y);
}

void CGEPathAddPixelizedLine(CGMutablePathRef path, const CGAffineTransform *m, CGPoint start, CGPoint end,
                             CGSize pixelSize, CGEPixelizationPosition startPosition,
                             CGEPixelizationPosition endPosition)
{
    CGPoint exactStart = start;
    if (startPosition == kCGEPixelizationPositionExact) {
        exactStart = CGPathGetCurrentPoint(path);
        if (m)
            exactStart = CGPointApplyAffineTransform(exactStart, CGAffineTransformInvert(*m));
    }
    PixelizedLineInfo info = {path, m, startPosition != kCGEPixelizationPositionExact};
    CGEPolylinePixelizeLine(start, end, pixelSize, startPosition, exactStart, endPosition, &info,
                            PixelizedLineApplier);
}

#pragma mark Bitmap outlines

typedef enum { FormatARGB8888, FormatBGRA8888, FormatGray1 } PixelFormat;

// How a pixel compares with the reference color: by lightness, chroma and
// hue of the unpremultiplied colors, within tolerance.
typedef struct {
    PixelFormat format;
    double tolerance;
    bool ignoresAlpha;
    bool transparentMatches;
    uint32_t ref;  // as laid out in memory
    unsigned refAlpha;
    double refHue, refChroma, refLightness;
    unsigned refBit;
} Matcher;

typedef struct {
    const uint8_t *data;
    size_t width, height, bytesPerRow;
    PixelFormat format;
} Bitmap;

// Rows count up from the bottom one.
static const uint8_t *BitmapRow(const Bitmap *bitmap, size_t y)
{
    return bitmap->data + (bitmap->height - 1 - y) * bitmap->bytesPerRow;
}

static uint32_t BitmapPixel(const Bitmap *bitmap, size_t x, size_t y)
{
    const uint8_t *row = BitmapRow(bitmap, y);
    if (bitmap->format == FormatGray1)
        return row[x >> 3] >> (7 - (x & 7)) & 1;
    uint32_t pixel;
    memcpy(&pixel, row + x * 4, 4);
    return pixel;
}

static void PixelComponents(PixelFormat format, uint32_t pixel, unsigned *a, unsigned *r, unsigned *g, unsigned *b)
{
    const uint8_t *bytes = (const uint8_t *)&pixel;
    if (format == FormatARGB8888) {
        *a = bytes[0], *r = bytes[1], *g = bytes[2], *b = bytes[3];
    } else {
        *b = bytes[0], *g = bytes[1], *r = bytes[2], *a = bytes[3];
    }
}

static void HueChromaLightness(unsigned a, unsigned r8, unsigned g8, unsigned b8, double *hue, double *chroma,
                               double *lightness)
{
    double r = r8 / (double)a, g = g8 / (double)a, b = b8 / (double)a;
    double max = r > g ? r : g, min = r > g ? g : r;
    if (b > max)
        max = b;
    else if (b < min)
        min = b;
    double c = max - min, h = 0;
    if (c > 0) {
        if (max == r) {
            h = (g - b) / c;
            if (h < 0)
                h += 6;
        } else if (max == g)
            h = (b - r) / c + 2;
        else if (max == b)
            h = (r - g) / c + 4;
        h /= 6;
    }
    *hue = h;
    *chroma = c;
    *lightness = (max + min) * 0.5;
}

static void MatcherInit(Matcher *matcher, PixelFormat format, uint32_t ref, double tolerance,
                        CGEPathBitmapOptions options)
{
    matcher->format = format;
    matcher->tolerance = tolerance < 0 ? 0 : tolerance > 1 ? 1 : tolerance;
    matcher->ignoresAlpha = options & kCGEPathBitmapIgnoreAlpha;
    matcher->transparentMatches = options & kCGEPathBitmapTransparentMatches;
    matcher->ref = ref;
    matcher->refBit = ref & 1;
    matcher->refHue = matcher->refChroma = matcher->refLightness = 0;
    matcher->refAlpha = 0;
    if (format == FormatGray1)
        return;
    unsigned r, g, b;
    PixelComponents(format, ref, &matcher->refAlpha, &r, &g, &b);
    if (ref != 0)
        HueChromaLightness(matcher->refAlpha, r, g, b, &matcher->refHue, &matcher->refChroma,
                           &matcher->refLightness);
}

static bool MatcherMatches(const Matcher *matcher, uint32_t pixel)
{
    if (matcher->format == FormatGray1)
        return pixel == matcher->refBit;
    const double slack = 1 / 510.0;
    double tolerance = matcher->tolerance;
    if (tolerance >= 254.5 / 255 || pixel == matcher->ref)
        return true;
    unsigned a, r, g, b;
    PixelComponents(matcher->format, pixel, &a, &r, &g, &b);
    if (a == 0) {
        if (matcher->transparentMatches)
            return true;
        if (matcher->ignoresAlpha)
            return false;
        if (matcher->refAlpha == 0)
            return true;
        return matcher->refAlpha / 255.0 <= tolerance + slack;
    }
    if (tolerance <= slack)
        return false;
    if (!matcher->ignoresAlpha) {
        if (tolerance + slack < fabs(((double)a - matcher->refAlpha) / 255))
            return false;
        if (matcher->refAlpha == 0)
            return true;
    }
    double hue, chroma, lightness;
    HueChromaLightness(a, r, g, b, &hue, &chroma, &lightness);
    double hueTerm = 0;
    if (chroma > slack && matcher->refChroma > slack) {
        double dh = fabs(hue - matcher->refHue);
        if (dh > 1 / 6.0)
            dh = dh > 5 / 6.0 ? 1 - dh : 1 / 6.0;
        hueTerm = chroma * 36 * matcher->refChroma * dh * dh;
    }
    double dl = lightness - matcher->refLightness, dc = chroma - matcher->refChroma;
    return sqrt(dl * dl + dc * dc * 0.75 + hueTerm) <= tolerance + slack;
}

// Where the traced points go: buffered, then added to the path.
typedef struct {
    CGMutablePathRef path;
    const CGAffineTransform *m;
    CGRect *bounds;
    bool hasBounds;
} Emitter;

static void EmitterAddPoint(Emitter *emitter, size_t x, size_t y, bool isFirst)
{
    CGPoint point = CGPointMake(x, y);
    if (!emitter->bounds) {
        if (isFirst)
            CGPathMoveToPoint(emitter->path, emitter->m, point.x, point.y);
        else
            CGPathAddLineToPoint(emitter->path, emitter->m, point.x, point.y);
        return;
    }
    if (emitter->m)
        point = CGPointApplyAffineTransform(point, *emitter->m);
    if (isFirst)
        CGPathMoveToPoint(emitter->path, NULL, point.x, point.y);
    else
        CGPathAddLineToPoint(emitter->path, NULL, point.x, point.y);
    if (!emitter->hasBounds) {
        *emitter->bounds = (CGRect){point, CGSizeZero};
        emitter->hasBounds = true;
        return;
    }
    BoundsInfo info = {CGAffineTransformIdentity, *emitter->bounds, false};
    BoundsAddPoint(&info, point);
    *emitter->bounds = info.bounds;
}

enum { East, North, West, South };
static const int kStepX[4] = {1, 0, -1, 0}, kStepY[4] = {0, 1, 0, -1};

typedef struct {
    size_t width, height;
    uint8_t *inside;   // 1 for the pixels traced
    uint32_t *depth;   // nesting: 0 outside, 1 outermost pixels, ...
    bool diagonals;    // inside pixels touching at corners are connected
} Mask;

static bool MaskInside(const Mask *mask, long x, long y)
{
    if (x < 0 || y < 0 || (size_t)x >= mask->width || (size_t)y >= mask->height)
        return false;
    return mask->inside[(size_t)y * mask->width + x];
}

// Pixels connected to (x, y) and like it, through neighbors (and diagonals).
typedef struct {
    long *items;
    size_t count, capacity;
} Stack;

static bool StackPush(Stack *stack, long item)
{
    if (stack->count == stack->capacity) {
        size_t capacity = stack->capacity ? stack->capacity * 2 : 1024;
        long *items = realloc(stack->items, capacity * sizeof(long));
        if (!items)
            return false;
        stack->items = items;
        stack->capacity = capacity;
    }
    stack->items[stack->count++] = item;
    return true;
}

static const int kNeighborX[8] = {1, 0, -1, 0, 1, -1, -1, 1}, kNeighborY[8] = {0, 1, 0, -1, 1, 1, -1, -1};

// Nesting depths, level by level from outside the bitmap: pixels of the same
// kind connected to one another share a depth, and a neighbor of the other
// kind is one deeper. Inside pixels connect through diagonals or not as mask
// says, the others the opposite way.
static bool MaskComputeDepths(Mask *mask)
{
    size_t count = mask->width * mask->height;
    mask->depth = malloc(count * sizeof(uint32_t));
    if (!mask->depth)
        return false;
    for (size_t i = 0; i < count; i++)
        mask->depth[i] = UINT32_MAX;
    Stack level = {0}, next = {0};
    bool ok = true;
    for (size_t y = 0; ok && y < mask->height; y++)
        for (size_t x = 0; ok && x < mask->width; x++) {
            if (x != 0 && y != 0 && x != mask->width - 1 && y != mask->height - 1)
                continue;
            size_t i = y * mask->width + x;
            ok = StackPush(mask->inside[i] ? &next : &level, (long)i);
        }
    for (uint32_t depth = 0; ok && (level.count || next.count); depth++) {
        while (ok && level.count) {
            long i = level.items[--level.count];
            if (mask->depth[i] != UINT32_MAX)
                continue;
            mask->depth[i] = depth;
            long x = i % (long)mask->width, y = i / (long)mask->width;
            bool inside = mask->inside[i];
            int neighbors = inside == mask->diagonals ? 8 : 4;
            for (int n = 0; ok && n < neighbors; n++) {
                long nx = x + kNeighborX[n], ny = y + kNeighborY[n];
                if (nx < 0 || ny < 0 || nx >= (long)mask->width || ny >= (long)mask->height)
                    continue;
                long j = ny * (long)mask->width + nx;
                if (mask->depth[j] != UINT32_MAX)
                    continue;
                if (mask->inside[j] == inside)
                    ok = StackPush(&level, j);
                else if (n < 4)
                    ok = StackPush(&next, j);
            }
        }
        Stack swap = level;
        level = next;
        next = swap;
    }
    free(level.items);
    free(next.items);
    return ok;
}

// Each boundary edge runs with the inside on its left; edges between depths
// deeper than maxDepth are dropped. Then the edges are followed round,
// turning towards a diagonal neighbor only if diagonals connect, and each
// loop's corners added as a closed subpath.
static bool MaskTrace(const Mask *mask, uint32_t maxDepth, Emitter *emitter)
{
    size_t vw = mask->width + 1, vh = mask->height + 1;
    uint8_t *edges = calloc(vw * vh, 1);
    if (!edges)
        return false;
    for (size_t y = 0; y < mask->height; y++)
        for (size_t x = 0; x < mask->width; x++) {
            size_t i = y * mask->width + x;
            if (!mask->inside[i])
                continue;
            for (int direction = 0; direction < 4; direction++) {
                // The neighbor across the edge on this pixel's side.
                static const int sideX[4] = {0, 1, 0, -1}, sideY[4] = {-1, 0, 1, 0};
                long nx = (long)x + sideX[direction], ny = (long)y + sideY[direction];
                if (MaskInside(mask, nx, ny))
                    continue;
                uint32_t outerDepth = 0;
                if (nx >= 0 && ny >= 0 && (size_t)nx < mask->width && (size_t)ny < mask->height)
                    outerDepth = mask->depth[(size_t)ny * mask->width + nx];
                uint32_t level = outerDepth < mask->depth[i] ? outerDepth : mask->depth[i];
                if (level > maxDepth)
                    continue;
                // Bottom edges run east from the lower left corner, right
                // edges north from the lower right, and so on round.
                static const int startX[4] = {0, 1, 1, 0}, startY[4] = {0, 0, 1, 1};
                static const int edgeDirection[4] = {East, North, West, South};
                size_t vx = x + startX[direction], vy = y + startY[direction];
                edges[vy * vw + vx] |= 1 << edgeDirection[direction];
            }
        }
    // Turn order: left first keeps diagonal pixels apart, right first joins
    // them.
    int turns[3];
    if (mask->diagonals)
        turns[0] = 3, turns[1] = 0, turns[2] = 1;
    else
        turns[0] = 1, turns[1] = 0, turns[2] = 3;
    size_t *loopX = NULL, *loopY = NULL;
    int *loopDirection = NULL;
    size_t loopCapacity = 0;
    bool ok = true;
    for (size_t sy = vh; ok && sy-- > 0;)
        for (size_t sx = 0; ok && sx < vw; sx++) {
            while (edges[sy * vw + sx]) {
                int direction = __builtin_ctz(edges[sy * vw + sx]);
                size_t x = sx, y = sy, length = 0;
                do {
                    if (length == loopCapacity) {
                        loopCapacity = loopCapacity ? loopCapacity * 2 : 256;
                        size_t *newX = realloc(loopX, loopCapacity * sizeof(size_t));
                        if (newX)
                            loopX = newX;
                        size_t *newY = realloc(loopY, loopCapacity * sizeof(size_t));
                        if (newY)
                            loopY = newY;
                        int *newDirection = realloc(loopDirection, loopCapacity * sizeof(int));
                        if (newDirection)
                            loopDirection = newDirection;
                        if (!newX || !newY || !newDirection) {
                            ok = false;
                            break;
                        }
                    }
                    edges[y * vw + x] &= ~(1 << direction);
                    loopX[length] = x;
                    loopY[length] = y;
                    loopDirection[length] = direction;
                    length++;
                    x += kStepX[direction];
                    y += kStepY[direction];
                    uint8_t out = edges[y * vw + x];
                    int startDirection = loopDirection[0];
                    if (x == sx && y == sy)
                        out |= 1 << startDirection;
                    if (!out)
                        break;
                    int next = -1;
                    for (int t = 0; t < 3; t++) {
                        int candidate = (direction + turns[t]) & 3;
                        if (out & 1 << candidate) {
                            next = candidate;
                            break;
                        }
                    }
                    if (next < 0 || (x == sx && y == sy && next == startDirection))
                        break;
                    direction = next;
                } while (true);
                if (!ok)
                    break;
                // The corners: where the direction changes.
                size_t first = 0;
                while (first < length && loopDirection[first] == loopDirection[(first + length - 1) % length])
                    first++;
                if (first == length)
                    continue;
                bool isFirst = true;
                for (size_t k = 0; k < length; k++) {
                    size_t j = (first + k) % length;
                    if (loopDirection[j] == loopDirection[(j + length - 1) % length])
                        continue;
                    EmitterAddPoint(emitter, loopX[j], loopY[j], isFirst);
                    isFirst = false;
                }
                CGPathCloseSubpath(emitter->path);
            }
        }
    free(loopX);
    free(loopY);
    free(loopDirection);
    free(edges);
    return ok;
}

// Traces the pixels matching color (all of them), or those like the one at
// (x, y).
static bool AddPathsFromBitmap(CGMutablePathRef path, const CGAffineTransform *m, const Bitmap *bitmap,
                               const uint32_t *color, size_t x, size_t y, double tolerance, uint32_t maxDepth,
                               CGEPathBitmapOptions options, CGRect *bounds)
{
    if (!path)
        return false;
    if (x >= bitmap->width || y >= bitmap->height)
        return true;
    Matcher matcher;
    MatcherInit(&matcher, bitmap->format, color ? *color : BitmapPixel(bitmap, x, y), tolerance, options);
    size_t count = bitmap->width * bitmap->height;
    Mask mask = {bitmap->width, bitmap->height, calloc(count, 1), NULL, false};
    if (!mask.inside)
        return true;
    if (color || (options & kCGEPathBitmapAllMatching)) {
        mask.diagonals = options & kCGEPathBitmapDiagonals;
        for (size_t py = 0; py < bitmap->height; py++)
            for (size_t px = 0; px < bitmap->width; px++)
                mask.inside[py * bitmap->width + px] = MatcherMatches(&matcher, BitmapPixel(bitmap, px, py));
    } else {
        // The region round the seed, followed along its boundary.
        mask.diagonals = true;
        uint8_t *seen = calloc(count, 1);
        Stack stack = {0};
        if (seen && StackPush(&stack, (long)(y * bitmap->width + x))) {
            seen[y * bitmap->width + x] = 1;
            while (stack.count) {
                long i = stack.items[--stack.count];
                mask.inside[i] = 1;
                long px = i % (long)bitmap->width, py = i / (long)bitmap->width;
                for (int n = 0; n < 8; n++) {
                    long nx = px + kNeighborX[n], ny = py + kNeighborY[n];
                    if (nx < 0 || ny < 0 || nx >= (long)bitmap->width || ny >= (long)bitmap->height)
                        continue;
                    long j = ny * (long)bitmap->width + nx;
                    if (seen[j])
                        continue;
                    seen[j] = 1;
                    if (MatcherMatches(&matcher, BitmapPixel(bitmap, nx, ny)) && !StackPush(&stack, j))
                        break;
                }
            }
        }
        free(stack.items);
        free(seen);
    }
    Emitter emitter = {path, m, bounds, false};
    if (MaskComputeDepths(&mask))
        MaskTrace(&mask, maxDepth, &emitter);
    free(mask.depth);
    free(mask.inside);
    return true;
}

static size_t PixelIndex(float coordinate)
{
    return (size_t)lroundf(floorf(coordinate));
}

bool CGEPathAddColoredPathsFromARGB8888PremultipliedBitmap(CGMutablePathRef path, const CGAffineTransform *m,
        const void *data, size_t width, size_t height, size_t bytesPerRow, const void *color, float tolerance,
        uint32_t maxDepth, CGEPathBitmapOptions options, CGRect *bounds)
{
    Bitmap bitmap = {data, width, height, bytesPerRow, FormatARGB8888};
    uint32_t ref;
    memcpy(&ref, color, 4);
    return AddPathsFromBitmap(path, m, &bitmap, &ref, 0, 0, tolerance, maxDepth, options, bounds);
}

bool CGEPathAddColoredPathsFromBGRA8888PremultipliedBitmap(CGMutablePathRef path, const CGAffineTransform *m,
        const void *data, size_t width, size_t height, size_t bytesPerRow, const void *color, float tolerance,
        uint32_t maxDepth, CGEPathBitmapOptions options, CGRect *bounds)
{
    Bitmap bitmap = {data, width, height, bytesPerRow, FormatBGRA8888};
    uint32_t ref;
    memcpy(&ref, color, 4);
    return AddPathsFromBitmap(path, m, &bitmap, &ref, 0, 0, tolerance, maxDepth, options, bounds);
}

bool CGEPathAddColoredPathsFromGrayscale1Bitmap(CGMutablePathRef path, const CGAffineTransform *m,
        const void *data, size_t width, size_t height, size_t bytesPerRow, uint8_t color, float tolerance,
        uint32_t maxDepth, CGEPathBitmapOptions options, CGRect *bounds)
{
    Bitmap bitmap = {data, width, height, bytesPerRow, FormatGray1};
    uint32_t ref = color;
    return AddPathsFromBitmap(path, m, &bitmap, &ref, 0, 0, tolerance, maxDepth, options, bounds);
}

bool CGEPathAddPathsFromARGB8888PremultipliedBitmap(CGMutablePathRef path, const CGAffineTransform *m,
        const void *data, size_t width, size_t height, size_t bytesPerRow, float x, float y, float tolerance,
        uint32_t maxDepth, CGEPathBitmapOptions options, CGRect *bounds)
{
    Bitmap bitmap = {data, width, height, bytesPerRow, FormatARGB8888};
    return AddPathsFromBitmap(path, m, &bitmap, NULL, PixelIndex(x), PixelIndex(y), tolerance, maxDepth, options,
                              bounds);
}

bool CGEPathAddPathsFromBGRA8888PremultipliedBitmap(CGMutablePathRef path, const CGAffineTransform *m,
        const void *data, size_t width, size_t height, size_t bytesPerRow, float x, float y, float tolerance,
        uint32_t maxDepth, CGEPathBitmapOptions options, CGRect *bounds)
{
    Bitmap bitmap = {data, width, height, bytesPerRow, FormatBGRA8888};
    return AddPathsFromBitmap(path, m, &bitmap, NULL, PixelIndex(x), PixelIndex(y), tolerance, maxDepth, options,
                              bounds);
}

bool CGEPathAddPathsFromGrayscale1Bitmap(CGMutablePathRef path, const CGAffineTransform *m,
        const void *data, size_t width, size_t height, size_t bytesPerRow, float x, float y, float tolerance,
        uint32_t maxDepth, CGEPathBitmapOptions options, CGRect *bounds)
{
    Bitmap bitmap = {data, width, height, bytesPerRow, FormatGray1};
    return AddPathsFromBitmap(path, m, &bitmap, NULL, PixelIndex(x), PixelIndex(y), tolerance, maxDepth, options,
                              bounds);
}
