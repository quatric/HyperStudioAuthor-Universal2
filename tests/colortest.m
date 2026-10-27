// CGEColor: HSV, solid colors, linear gradients (axial, radial, rectangular),
// user patterns, copies with other components, and color attachments.
#import "CGEColor.h"
#import "CGEContext.h"

static int failures;
#define CHECK(...) do { if (!(__VA_ARGS__)) { printf("FAIL %s:%d %s\n", __FILE__, __LINE__, #__VA_ARGS__); failures++; } } while (0)

static CGColorSpaceRef rgb;

// A 100×100 RGBA context (rows top first in memory).
static CGContextRef NewContext(unsigned char **data)
{
    *data = calloc(100 * 100, 4);
    return CGBitmapContextCreate(*data, 100, 100, 8, 400, rgb, kCGImageAlphaPremultipliedLast);
}

// The pixel at x, y in context (bottom-up) coordinates.
static unsigned char *Pixel(unsigned char *data, int x, int y)
{
    return data + 4 * ((99 - y) * 100 + x);
}

static bool Near(unsigned char *p, int r, int g, int b, int a, int tolerance)
{
    return abs(p[0] - r) <= tolerance && abs(p[1] - g) <= tolerance && abs(p[2] - b) <= tolerance &&
           abs(p[3] - a) <= tolerance;
}

static void Fill(CGEColorRef color, unsigned char **data, CGRect bounds)
{
    CGContextRef c = NewContext(data);
    CGContextSaveGState(c);
    CGContextAddRect(c, bounds);
    CGEContextFillPathWithColor(c, NULL, bounds, color);
    CGContextRestoreGState(c);
    CGContextRelease(c);
}

static int patternDraws;
static void DrawChecker(void *info, CGContextRef c)
{
    patternDraws++;
    CGContextSetRGBFillColor(c, 1, 0, 0, 1);
    CGContextFillRect(c, CGRectMake(0, 0, 5, 5));
    CGContextSetRGBFillColor(c, 0, 0, 1, 1);
    CGContextFillRect(c, CGRectMake(5, 0, 5, 5));
}

static int released;
static void ReleaseInfo(void *info)
{
    released++;
}

int main(void)
{
    rgb = CGColorSpaceCreateWithName(kCGColorSpaceSRGB);
    unsigned char *data;

    CGFloat h, s, v, r, g, b;
    CGEColorConvertRGBToHSV(0.2, 0.6, 0.4, &h, &s, &v);
    CGEColorConvertHSVToRGB(h, s, v, &r, &g, &b);
    printf("hsv %.3f %.3f %.3f -> %.3f %.3f %.3f\n", h, s, v, r, g, b);
    CHECK(fabs(h - 0.41667) < 1e-4 && fabs(s - 0.6667) < 1e-4 && fabs(v - 0.6) < 1e-9);
    CHECK(fabs(r - 0.2) < 1e-9 && fabs(g - 0.6) < 1e-9 && fabs(b - 0.4) < 1e-9);
    for (int i = 0; i < 12; i++) {
        CGFloat rr = (i % 3) / 2.0, gg = ((i / 3) % 2), bb = (i * 7 % 5) / 4.0;
        CGEColorConvertRGBToHSV(rr, gg, bb, &h, &s, &v);
        CGEColorConvertHSVToRGB(h, s, v, &r, &g, &b);
        CHECK(fabs(r - rr) < 1e-9 && fabs(g - gg) < 1e-9 && fabs(b - bb) < 1e-9);
    }

    // Solid.
    CGFloat green[4] = { 0, 1, 0, 1 };
    CGEColorRef solid = CGEColorCreateSolid(rgb, green);
    CHECK(CGEColorIsSolid(solid) && !CGEColorIsPattern(solid) && CGEColorGetNumberOfBaseColors(solid) == 1);
    CHECK(CGEColorGetAlpha(solid) == 1 && CGEColorGetCGColor(solid));
    Fill(solid, &data, CGRectMake(10, 10, 20, 20));
    CHECK(Near(Pixel(data, 15, 15), 0, 255, 0, 255, 0) && Pixel(data, 50, 50)[3] == 0);
    free(data);
    CGFloat blue[4] = { 0, 0, 1, 0.5 };
    CGEColorRef solid2 = CGEColorCreateCopyWithBaseColorsComponents(solid, blue);
    CHECK(CGEColorGetAlpha(solid2) == 0.5 && !CGEColorEqualToColor(solid, solid2));
    CGEColorRef solid3 = CGEColorCreateWithCGColor(CGEColorGetCGColor(solid));
    CHECK(CGEColorEqualToColor(solid, solid3));

    // Axial: red at the left to blue at the right, a green stop at 0.25.
    CGFloat stops[12] = { 1, 0, 0, 1, 0, 1, 0, 1, 0, 0, 1, 1 };
    CGFloat at[1] = { 0.25 };
    CGEColorRef axial = CGEColorCreateLinearAxialGradient(rgb, CGPointMake(0, 0), CGPointMake(1, 0), 1, at, stops,
                                                          true, true);
    CHECK(CGEColorIsGradient(axial) && CGEColorGetNumberOfBaseColors(axial) == 3);
    CHECK(CGEColorGetBaseColorSpace(axial) == rgb && CGEColorGetBaseColorsComponents(axial)[4] == 0);
    CHECK(!CGEContextSetFillColorWithColor(NULL, NULL, CGRectZero, axial));
    Fill(axial, &data, CGRectMake(0, 0, 100, 100));
    unsigned char *left = Pixel(data, 0, 50), *quarter = Pixel(data, 25, 50), *right = Pixel(data, 99, 50);
    unsigned char *mid = Pixel(data, 62, 50);
    printf("axial %d,%d,%d %d,%d,%d %d,%d,%d %d,%d,%d\n", left[0], left[1], left[2], quarter[0], quarter[1],
           quarter[2], mid[0], mid[1], mid[2], right[0], right[1], right[2]);
    CHECK(left[0] > 240 && left[1] < 20);
    CHECK(quarter[1] > 230 && quarter[0] < 25);
    CHECK(mid[1] > 100 && mid[2] > 100 && mid[0] < 10);
    CHECK(right[2] > 240 && right[1] < 20);
    free(data);
    // A copy with other colors: same stops.
    CGFloat others[12] = { 0, 0, 0, 1, 1, 1, 1, 1, 0, 0, 0, 1 };
    CGEColorRef axial2 = CGEColorCreateCopyWithBaseColorsComponents(axial, others);
    CHECK(axial2 && CGEColorGetNumberOfBaseColors(axial2) == 3);
    Fill(axial2, &data, CGRectMake(0, 0, 100, 100));
    CHECK(Near(Pixel(data, 25, 50), 255, 255, 255, 255, 25) && Pixel(data, 0, 50)[0] < 20);
    free(data);

    // Radial: white center to black edge, in a 50×50 square.
    CGFloat whiteToBlack[8] = { 1, 1, 1, 1, 0, 0, 0, 1 };
    CGEColorRef radial = CGEColorCreateLinearRadialGradient(rgb, CGPointMake(0.5, 0.5), 0, CGPointMake(0.5, 0.5),
                                                            0.5, CGAffineTransformIdentity, 0, NULL, whiteToBlack,
                                                            true, true);
    Fill(radial, &data, CGRectMake(25, 25, 50, 50));
    unsigned char *center = Pixel(data, 50, 50), *edge = Pixel(data, 74, 50), *halfway = Pixel(data, 62, 50);
    printf("radial %d %d %d outside %d\n", center[0], halfway[0], edge[0], Pixel(data, 10, 10)[3]);
    CHECK(center[0] > 245 && edge[0] < 15 && halfway[0] > 100 && halfway[0] < 155);
    CHECK(Pixel(data, 10, 10)[3] == 0);
    free(data);

    // Rectangular: white middle point to black edges (as HyperStudio makes
    // them): the same along both axes, a pyramid.
    CGEColorRef rect = CGEColorCreateLinearRectangularGradient(rgb, CGRectMake(0.5, 0.5, 0, 0), CGRectMake(0, 0, 1, 1),
                                                               CGAffineTransformIdentity, 0, NULL, whiteToBlack,
                                                               true, true);
    Fill(rect, &data, CGRectMake(0, 0, 100, 100));
    unsigned char *c = Pixel(data, 50, 50), *x75 = Pixel(data, 75, 50), *y75 = Pixel(data, 50, 75);
    unsigned char *diagonal = Pixel(data, 75, 75), *offDiagonal = Pixel(data, 75, 60), *edgeX = Pixel(data, 1, 30);
    printf("rect center %d x75 %d y75 %d diag %d off %d edge %d\n", c[0], x75[0], y75[0], diagonal[0],
           offDiagonal[0], edgeX[0]);
    CHECK(c[0] > 240);
    CHECK(abs(x75[0] - 127) < 12 && abs(y75[0] - 127) < 12 && abs(diagonal[0] - 127) < 12);
    CHECK(abs(offDiagonal[0] - x75[0]) < 6);
    CHECK(edgeX[0] < 15);
    // No seams: every pixel along the diagonals is drawn.
    int gaps = 0;
    for (int i = 0; i < 100; i++)
        gaps += Pixel(data, i, i)[3] != 255 || Pixel(data, i, 99 - i)[3] != 255;
    CHECK(gaps == 0);
    free(data);

    // A pattern: red and blue 5-point squares, phased to the bounds.
    CGFloat alpha[1] = { 1 };
    CGEColorRef pattern = CGEColorCreateUserPattern(NULL, CGRectMake(0, 0, 10, 5), 10, 5, kCGPatternTilingConstantSpacing,
                                                    NULL, alpha, DrawChecker, ReleaseInfo);
    CHECK(CGEColorIsUserPattern(pattern) && CGEColorIsPattern(pattern) && CGEColorGetNumberOfBaseColors(pattern) == 0);
    CHECK(CGEColorCreateCopyWithBaseColorsComponents(pattern, alpha) == pattern);
    CGEColorRelease(pattern);
    Fill(pattern, &data, CGRectMake(3, 3, 40, 40));
    unsigned char *p1 = Pixel(data, 5, 5), *p2 = Pixel(data, 10, 5);
    printf("pattern %d,%d,%d %d,%d,%d draws %d\n", p1[0], p1[1], p1[2], p2[0], p2[1], p2[2], patternDraws);
    CHECK(Near(p1, 255, 0, 0, 255, 0) && Near(p2, 0, 0, 255, 255, 0));
    free(data);

    // Attachments keep the color.
    CGContextRef context = NewContext(&data);
    CFArrayRef attached = NULL;
    CGEContextSetColorAttachmentForKey(context, CFSTR("color"), solid2, &attached);
    CHECK(attached && CFArrayGetValueAtIndex(attached, 0) == solid2);
    CHECK(CGEContextGetAttachmentForKey(context, CFSTR("color")) == attached);
    CFRelease(attached);
    CGContextRelease(context);
    free(data);

    ColorSyncProfileRef profile = CSEProfileCreateWithName(CFSTR("com.apple.ColorSync.sRGB"));
    CHECK(profile != NULL);
    if (profile)
        CFRelease(profile);
    CGColorSpaceRef space = CGEColorSpaceCreateWithName(kCGColorSpaceSRGB);
    CHECK(space != NULL);
    CGColorSpaceRelease(space);

    CGEColorRelease(solid);
    CGEColorRelease(solid2);
    CGEColorRelease(solid3);
    CGEColorRelease(axial);
    CGEColorRelease(axial2);
    CGEColorRelease(radial);
    CGEColorRelease(rect);
    CGEColorRelease(pattern);
    CHECK(released == 1);
    printf(failures ? "%d FAILED\n" : "all passed\n", failures);
    return failures != 0;
}
