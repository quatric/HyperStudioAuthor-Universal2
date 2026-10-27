// CGERegion: rects, unions as paths, bounds-based intersections, copies
// sharing storage, transforms, and rect approximations.
#import "CGERegion.h"

static int failures;
#define CHECK(...) do { if (!(__VA_ARGS__)) { printf("FAIL %s:%d %s\n", __FILE__, __LINE__, #__VA_ARGS__); failures++; } } while (0)

int main(void)
{
    CGERegionRef empty = CGERegionCreateEmpty(), empty2 = CGERegionCreateEmpty();
    CHECK(empty == empty2 && CGERegionIsEmpty(empty));
    CHECK(CGRectEqualToRect(CGERegionGetBoundingRect(empty), CGRectZero));

    CGEMutableRegionRef region = CGERegionCreateMutable();
    CHECK(CGERegionIsEmpty(region) && CGERegionEqualToRegion(region, empty));
    CGERegionAddRect(region, CGRectMake(0, 0, 10, 10));
    CHECK(!CGERegionIsEmpty(region));
    CGERegionAddRect(region, CGRectMake(2, 2, 3, 3));   // inside: still one rect
    CFDataRef rects = CGERegionCopyRectApproximation(region);
    CHECK(CFDataGetLength(rects) == sizeof(CGRect));
    CFRelease(rects);
    CGERegionRef rect = CGERegionCreateWithRect(CGRectMake(0, 0, 10, 10));
    CHECK(CGERegionEqualToRegion(region, rect));

    // A copy shares; changing the mutable one doesn't change the copy.
    CGERegionRef copy = CGERegionCreateCopy(region);
    CGERegionAddRect(region, CGRectMake(20, 0, 10, 10));
    CHECK(CGRectEqualToRect(CGERegionGetBoundingRect(region), CGRectMake(0, 0, 30, 10)));
    CHECK(CGRectEqualToRect(CGERegionGetBoundingRect(copy), CGRectMake(0, 0, 10, 10)));
    CHECK(!CGERegionEqualToRegion(region, copy));
    rects = CGERegionCopyRectApproximation(region);
    CHECK(CFDataGetLength(rects) == 2 * sizeof(CGRect));
    const CGRect *r = (const CGRect *)CFDataGetBytePtr(rects);
    CHECK(CGRectEqualToRect(r[0], CGRectMake(0, 0, 10, 10)) && CGRectEqualToRect(r[1], CGRectMake(20, 0, 10, 10)));
    CFRelease(rects);
    CHECK(CGERegionIntersectsRect(region, CGRectMake(12, 2, 2, 2)));   // in the bounds (not exact)
    CHECK(!CGERegionIntersectsRect(region, CGRectMake(40, 0, 2, 2)));

    // Adding a region of paths, then transforming (lazily).
    CGEMutableRegionRef other = CGERegionCreateMutable();
    CGERegionAddRect(other, CGRectMake(0, 20, 5, 5));
    CGERegionAddRect(other, CGRectMake(10, 20, 5, 5));
    CGERegionAddRegion(region, other);
    CHECK(CGRectEqualToRect(CGERegionGetBoundingRect(region), CGRectMake(0, 0, 30, 25)));
    CGERegionApplyAffineTransform(region, CGAffineTransformMakeScale(2, 2));
    CGERegionApplyAffineTransform(region, CGAffineTransformMakeTranslation(1, 1));
    CHECK(CGRectEqualToRect(CGERegionGetBoundingRect(region), CGRectMake(1, 1, 60, 50)));
    rects = CGERegionCopyRectApproximation(region);
    CHECK(CFDataGetLength(rects) == 4 * sizeof(CGRect));
    r = (const CGRect *)CFDataGetBytePtr(rects);
    CHECK(CGRectEqualToRect(r[3], CGRectMake(21, 41, 10, 10)));
    CFRelease(rects);

    // A rect turned by a right angle stays a rect; by 45 degrees it becomes a path.
    CGEMutableRegionRef turned = CGERegionCreateMutableCopy(rect);
    CGERegionApplyAffineTransform(turned, CGAffineTransformMakeRotation(M_PI_2));
    CGRect bounds = CGERegionGetBoundingRect(turned);
    CHECK(fabs(bounds.origin.x + 10) < 1e-9 && fabs(bounds.size.width - 10) < 1e-9);
    rects = CGERegionCopyRectApproximation(turned);
    CHECK(CFDataGetLength(rects) == sizeof(CGRect));
    CFRelease(rects);
    CGERegionApplyAffineTransform(turned, CGAffineTransformMakeRotation(M_PI_4));
    bounds = CGERegionGetBoundingRect(turned);
    CHECK(fabs(bounds.size.width - 10 * sqrt(2)) < 1e-6);

    // Intersections.
    CGEMutableRegionRef clipped = CGERegionCreateMutableCopy(rect);
    CGERegionIntersectRect(clipped, CGRectMake(5, 5, 20, 20));
    CHECK(CGRectEqualToRect(CGERegionGetBoundingRect(clipped), CGRectMake(5, 5, 5, 5)));
    CGERegionIntersectRect(clipped, CGRectMake(50, 50, 1, 1));
    CHECK(CGERegionIsEmpty(clipped));
    CHECK(CGERegionIsEmpty(rect) == false);
    CGERegionRef inter = CGERegionCreateIntersection(rect, other);
    CHECK(CGERegionIsEmpty(inter));
    CGERegionRef inter2 = CGERegionCreateIntersection(region, CGERegionCreateWithRect(CGRectMake(0, 0, 25, 25)));
    CHECK(CGRectEqualToRect(CGERegionGetBoundingRect(inter2), CGRectMake(1, 1, 24, 24)));
    CGEMutableRegionRef big = (CGEMutableRegionRef)CGERegionCreateMutableCopy(CGERegionCreateWithRect(CGRectMake(-100, -100, 300, 300)));
    CGERegionIntersectRegion(big, other);   // the rect contains it: the other region as it is
    CHECK(CGERegionEqualToRegion(big, other));
    CHECK(CGERegionIntersectsRegion(big, other) && !CGERegionIntersectsRegion(rect, other));
    CGERegionRef cut = CGERegionCreateCopyIntersectingRect(other, CGRectMake(0, 0, 100, 22));
    CHECK(CGRectEqualToRect(CGERegionGetBoundingRect(cut), CGRectMake(0, 20, 15, 2)));

    CGERegionRelease(empty);
    CGERegionRelease(empty2);
    CGERegionRelease(region);
    CGERegionRelease(rect);
    CGERegionRelease(copy);
    CGERegionRelease(other);
    CGERegionRelease(turned);
    CGERegionRelease(clipped);
    CGERegionRelease(inter);
    CGERegionRelease(inter2);
    CGERegionRelease(big);
    CGERegionRelease(cut);
    printf(failures ? "%d FAILED\n" : "all passed\n", failures);
    return failures != 0;
}
