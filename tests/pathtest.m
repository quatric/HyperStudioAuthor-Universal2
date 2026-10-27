// CGEPath: bitmap outlines (colors, holes, depth, seeds, tolerance,
// diagonals, 1-bit), pixelized lines, stroke bounds and glyph outlines.
#import "CGEPath.h"
#import <CoreText/CoreText.h>

static int failures;
#define CHECK(...) do { if (!(__VA_ARGS__)) { printf("FAIL %s:%d %s\n", __FILE__, __LINE__, #__VA_ARGS__); failures++; } } while (0)

enum { W = 8, H = 6 };
static uint8_t argb[H][W][4];

// y counts up from the bottom row.
static void SetPixel(int x, int y, uint8_t a, uint8_t r, uint8_t g, uint8_t b)
{
    uint8_t *p = argb[H - 1 - y][x];
    p[0] = a, p[1] = r, p[2] = g, p[3] = b;
}

typedef struct {
    int subpaths, points;
    bool axisAligned;
    CGPoint last;
} Stats;

static void StatsApplier(void *info, const CGPathElement *element)
{
    Stats *stats = info;
    switch (element->type) {
    case kCGPathElementMoveToPoint:
        stats->subpaths++;
        stats->points++;
        stats->last = element->points[0];
        break;
    case kCGPathElementAddLineToPoint: {
        CGPoint p = element->points[0];
        if (p.x != stats->last.x && p.y != stats->last.y)
            stats->axisAligned = false;
        stats->points++;
        stats->last = p;
        break;
    }
    default:
        break;
    }
}

static Stats PathStats(CGPathRef path)
{
    Stats stats = {0, 0, true, CGPointZero};
    CGPathApply(path, &stats, StatsApplier);
    return stats;
}

static bool Contains(CGPathRef path, CGFloat x, CGFloat y)
{
    return CGEPathContainsPoint(path, NULL, CGPointMake(x, y), false);
}

typedef struct {
    int count;
    CGPoint points[64];
    int types[64];
} Polyline;

static void PolylineApplier(void *info, CGEPolylinePointType type, CGPoint point)
{
    Polyline *line = info;
    if (line->count < 64) {
        line->types[line->count] = type;
        line->points[line->count++] = point;
    }
}

static bool IsStaircase(const Polyline *line)
{
    for (int i = 1; i < line->count; i++)
        if (line->points[i].x != line->points[i - 1].x && line->points[i].y != line->points[i - 1].y)
            return false;
    return true;
}

int main(void)
{
    // A red ring (4×4 with a 2×2 hole) at (1, 1), and a lone red pixel.
    for (int y = 1; y < 5; y++)
        for (int x = 1; x < 5; x++)
            if (!(x >= 2 && x <= 3 && y >= 2 && y <= 3))
                SetPixel(x, y, 255, 255, 0, 0);
    SetPixel(6, 4, 255, 255, 0, 0);
    uint8_t red[4] = {255, 255, 0, 0};

    CGMutablePathRef path = CGPathCreateMutable();
    CGRect bounds = CGRectNull;
    CHECK(CGEPathAddColoredPathsFromARGB8888PremultipliedBitmap(path, NULL, argb, W, H, W * 4, red, 0, UINT32_MAX,
                                                                0, &bounds));
    Stats stats = PathStats(path);
    CHECK(stats.subpaths == 3 && stats.points == 12 && stats.axisAligned);
    CHECK(CGRectEqualToRect(bounds, CGRectMake(1, 1, 6, 4)));
    CHECK(Contains(path, 1.5, 1.5) && !Contains(path, 3, 3) && Contains(path, 6.5, 4.5) && !Contains(path, 5.5, 1.5));
    CHECK(CGRectEqualToRect(CGEPathGetPathBoundingBox(path), CGRectMake(1, 1, 6, 4)));
    CGPathRelease(path);

    // Outermost outlines only: the hole is filled.
    path = CGPathCreateMutable();
    CGEPathAddColoredPathsFromARGB8888PremultipliedBitmap(path, NULL, argb, W, H, W * 4, red, 0, 0, 0, NULL);
    CHECK(PathStats(path).subpaths == 2 && Contains(path, 3, 3));
    CGPathRelease(path);

    // From a seed: the ring alone, with its hole; or everything like it.
    path = CGPathCreateMutable();
    CHECK(CGEPathAddPathsFromARGB8888PremultipliedBitmap(path, NULL, argb, W, H, W * 4, 1.5, 4.2, 0, 1, 0, NULL));
    CHECK(PathStats(path).subpaths == 2 && !Contains(path, 3, 3) && !Contains(path, 6.5, 4.5));
    CGPathRelease(path);
    path = CGPathCreateMutable();
    CGEPathAddPathsFromARGB8888PremultipliedBitmap(path, NULL, argb, W, H, W * 4, 1.5, 4.2, 0, 1,
                                                   kCGEPathBitmapAllMatching, NULL);
    CHECK(PathStats(path).subpaths == 3 && Contains(path, 6.5, 4.5));
    CGPathRelease(path);
    // A seed outside the bitmap adds nothing but succeeds.
    path = CGPathCreateMutable();
    CHECK(CGEPathAddPathsFromARGB8888PremultipliedBitmap(path, NULL, argb, W, H, W * 4, 9, 1, 0, 1, 0, NULL));
    CHECK(CGPathIsEmpty(path));
    CGPathRelease(path);
    CHECK(!CGEPathAddColoredPathsFromARGB8888PremultipliedBitmap(NULL, NULL, argb, W, H, W * 4, red, 0, 0, 0, NULL));

    // Tolerance: a slightly darker red joins the lone pixel.
    SetPixel(6, 3, 255, 240, 0, 0);
    path = CGPathCreateMutable();
    CGEPathAddPathsFromARGB8888PremultipliedBitmap(path, NULL, argb, W, H, W * 4, 6, 4, 0, 1, 0, NULL);
    CHECK(!Contains(path, 6.5, 3.5));
    CGPathRelease(path);
    path = CGPathCreateMutable();
    CGEPathAddPathsFromARGB8888PremultipliedBitmap(path, NULL, argb, W, H, W * 4, 6, 4, 0.1, 1, 0, NULL);
    CHECK(Contains(path, 6.5, 3.5) && PathStats(path).subpaths == 1);
    CGPathRelease(path);
    // Transparent pixels: no match, or matched when asked.
    path = CGPathCreateMutable();
    CGEPathAddPathsFromARGB8888PremultipliedBitmap(path, NULL, argb, W, H, W * 4, 6, 4, 0.5, 0, 0, NULL);
    CHECK(!Contains(path, 7.5, 0.5));
    CGPathRelease(path);
    path = CGPathCreateMutable();
    CGEPathAddPathsFromARGB8888PremultipliedBitmap(path, NULL, argb, W, H, W * 4, 6, 4, 0, 0,
                                                   kCGEPathBitmapTransparentMatches, NULL);
    CHECK(Contains(path, 7.5, 0.5) && Contains(path, 1.5, 1.5));
    CGPathRelease(path);

    // Transformed points and bounds.
    path = CGPathCreateMutable();
    CGAffineTransform scale = CGAffineTransformMakeScale(2, 3);
    bounds = CGRectNull;
    CGEPathAddColoredPathsFromARGB8888PremultipliedBitmap(path, &scale, argb, W, H, W * 4, red, 0, 0, 0, &bounds);
    CHECK(CGRectEqualToRect(bounds, CGRectMake(2, 3, 12, 12)));
    CGPathRelease(path);

    // 1-bit: an L of set bits and two pixels touching at a corner.
    uint8_t bits[4] = {0x80, 0x80, 0xc0, 0x00};  // rows top down: x0; x0; x0,x1
    path = CGPathCreateMutable();
    CHECK(CGEPathAddColoredPathsFromGrayscale1Bitmap(path, NULL, bits, 2, 3, 1, 1, 0, UINT32_MAX, 0, NULL));
    stats = PathStats(path);
    CHECK(stats.subpaths == 1 && stats.points == 6 && Contains(path, 1.5, 0.5) && !Contains(path, 1.5, 1.5));
    CGPathRelease(path);
    uint8_t diagonal[2] = {0x40, 0x80};  // (1, 1) and (0, 0)
    path = CGPathCreateMutable();
    CGEPathAddColoredPathsFromGrayscale1Bitmap(path, NULL, diagonal, 2, 2, 1, 1, 0, UINT32_MAX, 0, NULL);
    CHECK(PathStats(path).subpaths == 2);
    CGPathRelease(path);
    path = CGPathCreateMutable();
    CGEPathAddColoredPathsFromGrayscale1Bitmap(path, NULL, diagonal, 2, 2, 1, 1, 0, UINT32_MAX,
                                               kCGEPathBitmapDiagonals, NULL);
    stats = PathStats(path);
    CHECK(stats.subpaths == 1 && stats.points == 8 && Contains(path, 0.5, 0.5) && Contains(path, 1.5, 1.5));
    CGPathRelease(path);
    // The cleared bits, from a seed in them.
    path = CGPathCreateMutable();
    CGEPathAddPathsFromGrayscale1Bitmap(path, NULL, bits, 2, 3, 1, 1.5, 2.5, 0, 1, 0, NULL);
    CHECK(PathStats(path).subpaths == 1 && Contains(path, 1.5, 1.5) && !Contains(path, 0.5, 0.5));
    CGPathRelease(path);

    // Pixelized lines: a staircase of whole pixels from start to end.
    Polyline line = {0};
    CGEPolylinePixelizeLine(CGPointMake(0.2, 0.1), CGPointMake(3.9, 2.2), CGSizeMake(1, 1),
                            kCGEPixelizationPositionNearest, CGPointZero, kCGEPixelizationPositionNearest, &line,
                            PolylineApplier);
    CHECK(line.count >= 3 && line.types[0] == kCGEPolylinePointStart && line.types[line.count - 1] == kCGEPolylinePointEnd);
    CHECK(CGPointEqualToPoint(line.points[0], CGPointZero) && CGPointEqualToPoint(line.points[line.count - 1], CGPointMake(4, 2)));
    CHECK(IsStaircase(&line));
    // Inside/outside round towards or away from the other end.
    line.count = 0;
    CGEPolylinePixelizeLine(CGPointMake(0.4, 1.2), CGPointMake(5.6, 1.4), CGSizeMake(1, 1),
                            kCGEPixelizationPositionOutside, CGPointZero, kCGEPixelizationPositionOutside, &line,
                            PolylineApplier);
    CHECK(line.count >= 3 && CGPointEqualToPoint(line.points[0], CGPointMake(0, 1)) &&
          CGPointEqualToPoint(line.points[line.count - 1], CGPointMake(6, 2)) && IsStaircase(&line));
    line.count = 0;
    CGEPolylinePixelizeLine(CGPointMake(0.4, 1.2), CGPointMake(5.6, 1.4), CGSizeMake(2, 2),
                            kCGEPixelizationPositionInside, CGPointZero, kCGEPixelizationPositionInside, &line,
                            PolylineApplier);
    CHECK(line.count >= 3 && CGPointEqualToPoint(line.points[0], CGPointMake(2, 2)) &&
          CGPointEqualToPoint(line.points[line.count - 1], CGPointMake(4, 0)) && IsStaircase(&line));
    // Straight lines need no steps.
    line.count = 0;
    CGEPolylinePixelizeLine(CGPointMake(0.4, 1.2), CGPointMake(5.6, 0.9), CGSizeMake(1, 1),
                            kCGEPixelizationPositionNearest, CGPointZero, kCGEPixelizationPositionNearest, &line,
                            PolylineApplier);
    CHECK(line.count == 2 && CGPointEqualToPoint(line.points[0], CGPointMake(0, 1)) &&
          CGPointEqualToPoint(line.points[1], CGPointMake(6, 1)));
    path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, 1, 1);
    CGEPathAddPixelizedLine(path, NULL, CGPointMake(7, 7), CGPointMake(4.2, 3.1), CGSizeMake(1, 1),
                            kCGEPixelizationPositionExact, kCGEPixelizationPositionNearest);
    stats = PathStats(path);
    CHECK(stats.subpaths == 1 && stats.axisAligned && CGPointEqualToPoint(stats.last, CGPointMake(4, 3)));
    CGPathRelease(path);

    // Bounds: control points transformed, stroked outlines.
    path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, 0, 0);
    CGPathAddLineToPoint(path, NULL, 10, 0);
    CGAffineTransform rotate = CGAffineTransformMakeRotation(M_PI_2);
    CGRect box = CGEPathGetBoundingBox(path, &rotate);
    CHECK(fabs(box.origin.x) < 1e-9 && fabs(box.size.width) < 1e-9 && fabs(box.size.height - 10) < 1e-9);
    CHECK(CGRectEqualToRect(CGEPathGetBoundingBox(path, NULL), CGRectMake(0, 0, 10, 0)));
    box = CGEPathGetStrokedPathBoundingBox(path, NULL, 2, kCGLineCapButt, kCGLineJoinMiter, 10, 0, NULL, 0, NULL);
    CHECK(fabs(box.origin.y + 1) < 1e-6 && fabs(box.size.height - 2) < 1e-6 && fabs(box.size.width - 10) < 1e-6);
    box = CGEPathGetStrokeBoundingBox(path, NULL, 2, kCGLineCapSquare, kCGLineJoinMiter, 10, 0, NULL, 0, &scale);
    CHECK(fabs(box.origin.x + 2) < 1e-6 && fabs(box.size.width - 24) < 1e-6 && fabs(box.size.height - 6) < 1e-6);
    CGPathRelease(path);

    // Glyphs: one unit to the em, whatever the font's size.
    CTFontRef font = CTFontCreateWithName(CFSTR("Helvetica"), 50, NULL);
    UniChar character = 'H';
    CGGlyph glyph;
    CHECK(CTFontGetGlyphsForCharacters(font, &character, &glyph, 1));
    CGPathRef glyphPath = CGEPathCreateWithGlyph(NULL, font, glyph);
    CGRect glyphBox = CGPathGetBoundingBox(glyphPath);
    CHECK(glyphBox.size.height > 0.6 && glyphBox.size.height < 0.8 && glyphBox.origin.y > -0.01);
    CGFontRef cgFont = CTFontCopyGraphicsFont(font, NULL);
    CGPathRef cgGlyphPath = CGEPathCreateWithGlyph(&scale, cgFont, glyph);
    CGRect cgBox = CGPathGetBoundingBox(cgGlyphPath);
    CHECK(fabs(cgBox.size.height - glyphBox.size.height * 3) < 1e-3 && fabs(cgBox.size.width - glyphBox.size.width * 2) < 1e-3);
    CGGlyph glyphs[2] = {glyph, glyph};
    CGSize advances[2] = {{1, 0}, {1, 0}};
    CGAffineTransform textMatrix = CGAffineTransformMakeScale(10, 10);
    path = CGPathCreateMutable();
    CGEPathAddGlyphs(path, NULL, &textMatrix, cgFont, glyphs, advances, 2);
    box = CGPathGetBoundingBox(path);
    CHECK(fabs(box.size.height - glyphBox.size.height * 10) < 1e-3 &&
          fabs(box.size.width - (glyphBox.size.width * 10 + 1)) < 1e-3);
    UniChar space = ' ';
    CTFontGetGlyphsForCharacters(font, &space, &glyph, 1);
    CGPathRef spacePath = CGEPathCreateWithGlyph(NULL, font, glyph);
    CHECK(spacePath && CGPathIsEmpty(spacePath));
    CGPathRelease(spacePath);
    CGPathRelease(path);
    CGPathRelease(glyphPath);
    CGPathRelease(cgGlyphPath);
    CGFontRelease(cgFont);
    CFRelease(font);

    printf(failures ? "%d FAILED\n" : "all passed\n", failures);
    return failures != 0;
}
