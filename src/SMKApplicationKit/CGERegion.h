// Regions (SMKApplicationKit's CGERegion functions): a rect, or the union of
// rects (added as a path). They are kept cheap rather than exact: the
// intersection of two non-rect regions, or of one with a rect it doesn't
// contain, is the intersection of their bounds; tests use the bounds.
// Copies share their storage until one changes.
#import <ApplicationServices/ApplicationServices.h>

typedef struct CGERegion *CGERegionRef;
typedef struct CGERegion *CGEMutableRegionRef;

CGERegionRef CGERegionRetain(CGERegionRef region);
void CGERegionRelease(CGERegionRef region);

// The shared empty region.
CGERegionRef CGERegionCreateEmpty(void);
CGERegionRef CGERegionCreateWithRect(CGRect rect);
CGERegionRef CGERegionCreateCopy(CGERegionRef region);
CGERegionRef CGERegionCreateCopyIntersectingRect(CGERegionRef region, CGRect rect);
CGERegionRef CGERegionCreateIntersection(CGERegionRef region1, CGERegionRef region2);
CGEMutableRegionRef CGERegionCreateMutable(void);
CGEMutableRegionRef CGERegionCreateMutableCopy(CGERegionRef region);
CGEMutableRegionRef CGERegionCreateMutableCopyIntersectingRect(CGERegionRef region, CGRect rect);
CGEMutableRegionRef CGERegionCreateMutableIntersection(CGERegionRef region1, CGERegionRef region2);

bool CGERegionIsEmpty(CGERegionRef region);
CGRect CGERegionGetBoundingRect(CGERegionRef region);
bool CGERegionIntersectsRect(CGERegionRef region, CGRect rect);
bool CGERegionIntersectsRegion(CGERegionRef region1, CGERegionRef region2);
bool CGERegionEqualToRegion(CGERegionRef region1, CGERegionRef region2);
// The rects added (their bounds once transformed), as CGRects.
CFDataRef CGERegionCopyRectApproximation(CGERegionRef region);

void CGERegionAddRect(CGEMutableRegionRef region, CGRect rect);
void CGERegionAddRegion(CGEMutableRegionRef region, CGERegionRef other);
void CGERegionIntersectRect(CGEMutableRegionRef region, CGRect rect);
void CGERegionIntersectRegion(CGEMutableRegionRef region, CGERegionRef other);
// A rect stays a rect if transform only scales, flips or turns it by right
// angles.
void CGERegionApplyAffineTransform(CGEMutableRegionRef region, CGAffineTransform transform);

// Debugging: a PDF of the region in the temporary folder, opened.
void CGERegionShowAs(CGERegionRef region, CFStringRef name, const void *object);
void CGERegionShow(CGERegionRef region);
