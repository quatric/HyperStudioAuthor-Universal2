// CGEText: glyphs drawn from the context's attachments (fill, invisible,
// clip, centered / outside / inside strokes, CGEColor arrays), added as a
// path, and glyph bounding boxes.
#import "CGEText.h"
#import <CoreText/CoreText.h>

static int failures;
#define CHECK(...) do { if (!(__VA_ARGS__)) { printf("FAIL %s:%d %s\n", __FILE__, __LINE__, #__VA_ARGS__); failures++; } } while (0)

enum { W = 120, H = 50 };
static uint8_t pixels[H][W][4]; // RGBA premultiplied
static CGGlyph glyphs[3];
static CGSize advances[3];

static CGContextRef NewContext(void)
{
    memset(pixels, 0, sizeof pixels);
    CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pixels, W, H, 8, W * 4, rgb, kCGImageAlphaPremultipliedLast);
    CGColorSpaceRelease(rgb);
    CTFontRef font = CTFontCreateWithName(CFSTR("Helvetica-Bold"), 20, NULL);
    CGEContextSetAttachmentForKey(context, (CFStringRef)kCGEContextFontAttachmentKey, font);
    CFRelease(font);
    CGContextSetTextMatrix(context, CGAffineTransformMake(36, 0, 0, 36, 4, 10));
    return context;
}

static void SetNumber(CGContextRef context, NSString *key, CFNumberType type, const void *value)
{
    CFNumberRef number = CFNumberCreate(NULL, type, value);
    CGEContextSetAttachmentForKey(context, (CFStringRef)key, number);
    CFRelease(number);
}

static void SetMode(CGContextRef context, uint8_t mode)
{
    SetNumber(context, kCGEContextTextDrawingModeAttachmentKey, kCFNumberCharType, &mode);
}

// In the context's own (device RGB) space, so no color matching.
static CGColorRef CreateColor(CGFloat r, CGFloat g, CGFloat b)
{
    CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
    CGColorRef color = CGColorCreate(rgb, (CGFloat[]){r, g, b, 1});
    CGColorSpaceRelease(rgb);
    return color;
}

static void SetColor(CGContextRef context, NSString *key, CGFloat r, CGFloat g, CGFloat b)
{
    CGColorRef color = CreateColor(r, g, b);
    CGEContextSetAttachmentForKey(context, (CFStringRef)key, color);
    CGColorRelease(color);
}

typedef struct {
    int red, green, blue, any;
} Counts;

// Pixels that are (nearly) pure red, green or blue, and any non-clear.
static Counts Count(void)
{
    Counts counts = {0};
    for (int y = 0; y < H; y++)
        for (int x = 0; x < W; x++) {
            uint8_t *p = pixels[y][x];
            if (p[3])
                counts.any++;
            if (p[3] > 250) {
                if (p[0] > 250 && p[1] < 5 && p[2] < 5)
                    counts.red++;
                if (p[1] > 250 && p[0] < 5 && p[2] < 5)
                    counts.green++;
                if (p[2] > 250 && p[0] < 5 && p[1] < 5)
                    counts.blue++;
            }
        }
    return counts;
}

static CGPoint PositionAfterGlyphs(void)
{
    return CGPointMake(4 + advances[0].width + advances[1].width + advances[2].width,
                       10 + advances[0].height + advances[1].height + advances[2].height);
}

static bool Near(CGPoint a, CGPoint b)
{
    return fabs(a.x - b.x) < 1e-6 && fabs(a.y - b.y) < 1e-6;
}

int main(void)
{
    CTFontRef font = CTFontCreateWithName(CFSTR("Helvetica-Bold"), 36, NULL);
    UniChar chars[3] = {'H', 'o', 'W'};
    CHECK(CTFontGetGlyphsForCharacters(font, chars, glyphs, 3));
    CTFontGetAdvancesForGlyphs(font, kCTFontOrientationHorizontal, glyphs, advances, 3);

    // No drawing mode: nothing happens.
    CGContextRef context = NewContext();
    CGEContextShowGlyphsWithAdvances(context, glyphs, advances, 3);
    CHECK(Count().any == 0 && Near(CGContextGetTextPosition(context), CGPointMake(4, 10)));

    // Invisible: only the position moves.
    SetMode(context, kCGTextInvisible);
    SetColor(context, kCGEContextFillColorAttachmentKey, 1, 0, 0);
    CGEContextShowGlyphsWithAdvances(context, glyphs, advances, 3);
    CHECK(Count().any == 0 && Near(CGContextGetTextPosition(context), PositionAfterGlyphs()));
    CGContextRelease(context);

    // Fill.
    context = NewContext();
    SetMode(context, kCGTextFill);
    SetColor(context, kCGEContextFillColorAttachmentKey, 1, 0, 0);
    CGEContextShowGlyphsWithAdvances(context, glyphs, advances, 3);
    Counts filled = Count();
    CHECK(filled.red > 300 && Near(CGContextGetTextPosition(context), PositionAfterGlyphs()));
    // The text is where the text matrix puts it: nothing left of x = 4.
    bool leftClear = true;
    for (int y = 0; y < H; y++)
        for (int x = 0; x < 3; x++)
            if (pixels[y][x][3])
                leftClear = false;
    CHECK(leftClear);
    CGContextRelease(context);

    // Centered stroke over the fill: some fill pixels are covered.
    CGFloat width = 3;
    context = NewContext();
    SetMode(context, kCGTextFillStroke);
    SetColor(context, kCGEContextFillColorAttachmentKey, 1, 0, 0);
    SetColor(context, kCGEContextStrokeColorAttachmentKey, 0, 0, 1);
    SetNumber(context, kCGEContextLineWidthAttachmentKey, kCFNumberCGFloatType, &width);
    CGEContextShowGlyphsWithAdvances(context, glyphs, advances, 3);
    Counts centered = Count();
    CHECK(centered.blue > 100 && centered.red < filled.red - 50);
    CGContextRelease(context);

    // Outside: the fill stays whole, the stroke only around it.
    context = NewContext();
    SetMode(context, kCGTextFillStroke);
    SetColor(context, kCGEContextFillColorAttachmentKey, 1, 0, 0);
    SetColor(context, kCGEContextStrokeColorAttachmentKey, 0, 0, 1);
    SetNumber(context, kCGEContextLineWidthAttachmentKey, kCFNumberCGFloatType, &width);
    uint8_t strokingMode = 2;
    SetNumber(context, kCGEContextTextStrokingModeAttachmentKey, kCFNumberCharType, &strokingMode);
    CGEContextShowGlyphsWithAdvances(context, glyphs, advances, 3);
    Counts outside = Count();
    CHECK(abs(outside.red - filled.red) <= 5 && outside.blue > 50 && outside.any > filled.any);
    CGContextRelease(context);

    // Outside without a fill: no stroke inside the glyphs.
    context = NewContext();
    SetMode(context, kCGTextStroke);
    SetColor(context, kCGEContextStrokeColorAttachmentKey, 0, 0, 1);
    SetNumber(context, kCGEContextLineWidthAttachmentKey, kCFNumberCGFloatType, &width);
    SetNumber(context, kCGEContextTextStrokingModeAttachmentKey, kCFNumberCharType, &strokingMode);
    CGEContextShowGlyphsWithAdvances(context, glyphs, advances, 3);
    Counts strokeOnly = Count();
    CGContextRelease(context);
    context = NewContext();
    SetMode(context, kCGTextFill);
    SetColor(context, kCGEContextFillColorAttachmentKey, 1, 0, 0);
    CGEContextShowGlyphsWithAdvances(context, glyphs, advances, 3);
    uint8_t mask[H][W];
    for (int y = 0; y < H; y++)
        for (int x = 0; x < W; x++)
            mask[y][x] = pixels[y][x][3];
    CGContextRelease(context);
    context = NewContext();
    SetMode(context, kCGTextStroke);
    SetColor(context, kCGEContextStrokeColorAttachmentKey, 0, 0, 1);
    SetNumber(context, kCGEContextLineWidthAttachmentKey, kCFNumberCGFloatType, &width);
    SetNumber(context, kCGEContextTextStrokingModeAttachmentKey, kCFNumberCharType, &strokingMode);
    CGEContextShowGlyphsWithAdvances(context, glyphs, advances, 3);
    int strokeInsideGlyphs = 0;
    for (int y = 0; y < H; y++)
        for (int x = 0; x < W; x++)
            if (mask[y][x] == 255 && pixels[y][x][3] > 5)
                strokeInsideGlyphs++;
    CHECK(strokeOnly.blue > 50 && strokeInsideGlyphs == 0);
    CGContextRelease(context);

    // Inside: the stroke stays within the glyphs.
    strokingMode = 1;
    context = NewContext();
    SetMode(context, kCGTextStroke);
    SetColor(context, kCGEContextStrokeColorAttachmentKey, 0, 0, 1);
    SetNumber(context, kCGEContextLineWidthAttachmentKey, kCFNumberCGFloatType, &width);
    SetNumber(context, kCGEContextTextStrokingModeAttachmentKey, kCFNumberCharType, &strokingMode);
    CGEContextShowGlyphsWithAdvances(context, glyphs, advances, 3);
    int strokeOutsideGlyphs = 0, inside = 0;
    for (int y = 0; y < H; y++)
        for (int x = 0; x < W; x++) {
            if (!mask[y][x] && pixels[y][x][3])
                strokeOutsideGlyphs++;
            if (pixels[y][x][3])
                inside++;
        }
    CHECK(inside > 50 && strokeOutsideGlyphs == 0);
    CGContextRelease(context);

    // Clip: later drawing lands only in the glyphs.
    context = NewContext();
    SetMode(context, kCGTextClip);
    CGEContextShowGlyphsWithAdvances(context, glyphs, advances, 3);
    CHECK(Count().any == 0 && Near(CGContextGetTextPosition(context), PositionAfterGlyphs()));
    CGContextSetRGBFillColor(context, 0, 1, 0, 1);
    CGContextFillRect(context, CGRectMake(0, 0, W, H));
    Counts clipped = Count();
    CHECK(abs(clipped.green - filled.red) <= 5 && abs(clipped.any - filled.any) <= 5);
    CGContextRelease(context);

    // A one-CGEColor array as the fill color.
    context = NewContext();
    SetMode(context, kCGTextFill);
    CGColorRef green = CreateColor(0, 1, 0);
    CGEColorRef color = CGEColorCreateWithCGColor(green);
    CGColorRelease(green);
    CGEContextSetColorAttachmentForKey(context, (CFStringRef)kCGEContextFillColorAttachmentKey, color, NULL);
    CGEColorRelease(color);
    CGEContextShowGlyphsWithAdvances(context, glyphs, advances, 3);
    CHECK(abs(Count().green - filled.red) <= 5);
    CGContextRelease(context);

    // Added as the context's path; the text position stays.
    context = NewContext();
    CGContextBeginPath(context);
    CGEContextAddGlyphs(context, glyphs, advances, 3);
    CGRect box = CGContextGetPathBoundingBox(context);
    CHECK(!CGContextIsPathEmpty(context) && box.origin.x >= 4 && box.origin.y >= 9 && box.size.height > 20 &&
          CGRectGetMaxX(box) <= PositionAfterGlyphs().x + 1);
    CHECK(Near(CGContextGetTextPosition(context), CGPointMake(4, 10)));
    CGContextRelease(context);

    // Glyph boxes in glyph space units.
    CGFontRef cgFont = CTFontCopyGraphicsFont(font, NULL);
    CGRect boxes[3];
    CHECK(CGEFontGetGlyphBBoxes(cgFont, glyphs, 3, boxes) && boxes[0].size.height > 0 &&
          boxes[2].size.width > boxes[0].size.width);
    CGFontRelease(cgFont);
    CFRelease(font);

    if (failures)
        printf("%d FAILED\n", failures);
    else
        printf("all passed\n");
    return failures != 0;
}
