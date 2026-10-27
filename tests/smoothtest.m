// BTCGPath helpers: corner smoothing of pixel-edge outlines and inscribing.
#import "SMKBitmapToolsUmbrella.h"

static int failures;
#define CHECK(c, ...) do { if (!(c)) { failures++; printf("FAIL: " __VA_ARGS__); printf("\n"); } } while (0)

static void dump(void *info, const CGPathElement *e)
{
    NSMutableString *s = info;
    static const char *names[] = { "M", "L", "Q", "C", "Z" };
    [s appendFormat:@"%s", names[e->type]];
    int n = e->type == kCGPathElementAddCurveToPoint ? 3 : e->type == kCGPathElementAddQuadCurveToPoint ? 2 : e->type == kCGPathElementCloseSubpath ? 0 : 1;
    for (int i = 0; i < n; i++)
        [s appendFormat:@"%g,%g ", e->points[i].x, e->points[i].y];
}

static NSString *describe(CGPathRef p)
{
    NSMutableString *s = [NSMutableString string];
    CGPathApply(p, s, dump);
    return s;
}

int main(void)
{
    @autoreleasepool {
        // A 3x2 pixel rectangle traced along pixel edges, counter-clockwise.
        CGMutablePathRef square = CGPathCreateMutable();
        CGPathMoveToPoint(square, NULL, 0, 0);
        CGPathAddLineToPoint(square, NULL, 3, 0);
        CGPathAddLineToPoint(square, NULL, 3, 2);
        CGPathAddLineToPoint(square, NULL, 0, 2);
        CGPathCloseSubpath(square);
        CGPathRef smooth = BTCGPathCreateCopyWithSmoothedCorners(square);
        NSString *d = describe(smooth);
        printf("rect: %s\n", [d UTF8String]);
        CHECK([d isEqualToString:@"M2.5,0 L3,0.5 L3,1.5 L2.5,2 L0.5,2 L0,1.5 L0,0.5 L0.5,0 Z"], "rect corners cut");
        CGRect box = CGPathGetBoundingBox(smooth);
        CHECK(CGRectEqualToRect(box, CGRectMake(0, 0, 3, 2)), "bounds kept");
        CGPathRelease(smooth);

        // An L shape: inner corners are cut too.
        CGMutablePathRef ell = CGPathCreateMutable();
        CGPathMoveToPoint(ell, NULL, 0, 0);
        CGPathAddLineToPoint(ell, NULL, 2, 0);
        CGPathAddLineToPoint(ell, NULL, 2, 1);
        CGPathAddLineToPoint(ell, NULL, 1, 1);
        CGPathAddLineToPoint(ell, NULL, 1, 2);
        CGPathAddLineToPoint(ell, NULL, 0, 2);
        CGPathCloseSubpath(ell);
        smooth = BTCGPathCreateCopyWithSmoothedCorners(ell);
        printf("ell: %s\n", [describe(smooth) UTF8String]);
        CHECK(CGPathContainsPoint(smooth, NULL, CGPointMake(0.5, 0.5), false), "ell keeps its body");
        CHECK(!CGPathContainsPoint(smooth, NULL, CGPointMake(1.5, 1.5), false), "ell keeps its notch");
        CGPathRelease(smooth);

        // Inscribing scales the bounds onto the rect; an empty path gives the rect.
        CGMutablePathRef in = BTCGPathCreateMutableCopyInscribedInRect(square, CGRectMake(10, 20, 6, 8));
        CHECK(CGRectEqualToRect(CGPathGetBoundingBox(in), CGRectMake(10, 20, 6, 8)), "inscribed bounds");
        CGPathRelease(in);
        CGMutablePathRef empty = CGPathCreateMutable();
        in = BTCGPathCreateMutableCopyInscribedInRect(empty, CGRectMake(1, 2, 3, 4));
        CHECK(CGRectEqualToRect(CGPathGetBoundingBox(in), CGRectMake(1, 2, 3, 4)), "empty gives rect");
        CGPathRelease(in);
        CGPathRelease(empty);

        // Magic-wand style: trace a 4x4 opaque block in an 8x8 ARGB bitmap, then smooth it.
        uint32_t pixels[64] = { 0 };
        for (int y = 2; y < 6; y++)
            for (int x = 2; x < 6; x++)
                pixels[y * 8 + x] = 0xff0000ffu;
        CGMutablePathRef traced = CGPathCreateMutable();
        bool ok = CGEPathAddPathsFromARGB8888PremultipliedBitmap(traced, NULL, pixels, 8, 8, 32, 3.5, 3.5, 0, 1, 8, NULL);
        CHECK(ok, "trace");
        CGRect tb = CGPathGetBoundingBox(traced);
        printf("traced bounds %g %g %g %g\n", tb.origin.x, tb.origin.y, tb.size.width, tb.size.height);
        smooth = BTCGPathCreateCopyWithSmoothedCorners(traced);
        printf("traced smooth: %s\n", [describe(smooth) UTF8String]);
        CHECK(CGRectEqualToRect(CGPathGetBoundingBox(smooth), tb), "smoothed traced bounds");
        CGPathRelease(smooth);
        CGPathRelease(traced);
        CGPathRelease(square);
        CGPathRelease(ell);
    }
    printf(failures ? "%d FAILED\n" : "all passed\n", failures);
    return failures != 0;
}
