// Paths (SMKApplicationKit's CGEPath functions): bounding boxes, glyph
// outlines, pixel-snapped lines and outlines traced from bitmaps.
#import <ApplicationServices/ApplicationServices.h>

// The bounds of path's control points once transformed by m (none: as is).
CGRect CGEPathGetBoundingBox(CGPathRef path, const CGAffineTransform *m);
CGRect CGEPathGetPathBoundingBox(CGPathRef path);
// The bounds of path stroked with the given line attributes in a space
// transformed by ctm; path itself is first transformed by m.
CGRect CGEPathGetStrokedPathBoundingBox(CGPathRef path, const CGAffineTransform *m, CGFloat lineWidth,
                                        CGLineCap cap, CGLineJoin join, CGFloat miterLimit, CGFloat phase,
                                        const CGFloat *lengths, size_t count, const CGAffineTransform *ctm);
CGRect CGEPathGetStrokeBoundingBox(CGPathRef path, const CGAffineTransform *m, CGFloat lineWidth,
                                   CGLineCap cap, CGLineJoin join, CGFloat miterLimit, CGFloat phase,
                                   const CGFloat *lengths, size_t count, const CGAffineTransform *ctm);
bool CGEPathContainsPoint(CGPathRef path, const CGAffineTransform *m, CGPoint point, bool eoFill);

// Debugging: a PDF of path (stroked, filled, even-odd filled) in the
// temporary folder, opened.
void CGEPathShow(CGPathRef path, const CGAffineTransform *m);

// Glyph outlines from a CGFont or CTFont, one unit to the em. Each glyph is
// placed by the text matrix, moved on by its advance, then by m.
CGPathRef CGEPathCreateWithGlyph(const CGAffineTransform *m, CFTypeRef font, CGGlyph glyph);
void CGEPathAddGlyphs(CGMutablePathRef path, const CGAffineTransform *m, const CGAffineTransform *textMatrix,
                      CFTypeRef font, const CGGlyph *glyphs, const CGSize *advances, size_t count);

// Where a line's end goes on the pixel grid.
enum {
    kCGEPixelizationPositionNearest = 0,
    kCGEPixelizationPositionInside = 1,  // rounded towards the other end
    kCGEPixelizationPositionOutside = 2, // rounded away from the other end
    kCGEPixelizationPositionExact = 3,   // the start: the given point; the end: as is
};
typedef int CGEPixelizationPosition;

enum {
    kCGEPolylinePointStart = 0,
    kCGEPolylinePointStep = 1,
    kCGEPolylinePointEnd = 2,
};
typedef int CGEPolylinePointType;
typedef void (*CGEPolylineApplierFunction)(void *info, CGEPolylinePointType type, CGPoint point);

// A line from start to end as a staircase of pixelSize steps, given point by
// point to function.
void CGEPolylinePixelizeLine(CGPoint start, CGPoint end, CGSize pixelSize, CGEPixelizationPosition startPosition,
                             CGPoint exactStart, CGEPixelizationPosition endPosition, void *info,
                             CGEPolylineApplierFunction function);
// The same added to path; an exact start starts at the path's current point.
void CGEPathAddPixelizedLine(CGMutablePathRef path, const CGAffineTransform *m, CGPoint start, CGPoint end,
                             CGSize pixelSize, CGEPixelizationPosition startPosition,
                             CGEPixelizationPosition endPosition);

// Outlines of pixels traced from a bitmap whose first row is its top, as
// closed staircase subpaths on pixel corners, y up from the bottom row; outer
// outlines run counterclockwise, holes clockwise. "Colored" traces every
// pixel matching color; the others trace the pixels matching the one at
// (x, y), those connected to it unless kCGEPathBitmapAllMatching. Outlines
// nested deeper than maxDepth (0: outermost only, 1: and their holes, ...)
// are left out. Colors match within tolerance (0...1) by lightness, chroma
// and hue. bounds, when given, is extended by the points added.
enum {
    kCGEPathBitmapAllMatching = 1 << 0,
    kCGEPathBitmapTransparentMatches = 1 << 1, // transparent pixels match any color
    kCGEPathBitmapDiagonals = 1 << 2,          // pixels touching at corners are connected
    kCGEPathBitmapIgnoreAlpha = 1 << 3,
};
typedef uint32_t CGEPathBitmapOptions;

bool CGEPathAddColoredPathsFromARGB8888PremultipliedBitmap(CGMutablePathRef path, const CGAffineTransform *m,
        const void *data, size_t width, size_t height, size_t bytesPerRow, const void *color, float tolerance,
        uint32_t maxDepth, CGEPathBitmapOptions options, CGRect *bounds);
bool CGEPathAddColoredPathsFromBGRA8888PremultipliedBitmap(CGMutablePathRef path, const CGAffineTransform *m,
        const void *data, size_t width, size_t height, size_t bytesPerRow, const void *color, float tolerance,
        uint32_t maxDepth, CGEPathBitmapOptions options, CGRect *bounds);
bool CGEPathAddColoredPathsFromGrayscale1Bitmap(CGMutablePathRef path, const CGAffineTransform *m,
        const void *data, size_t width, size_t height, size_t bytesPerRow, uint8_t color, float tolerance,
        uint32_t maxDepth, CGEPathBitmapOptions options, CGRect *bounds);
bool CGEPathAddPathsFromARGB8888PremultipliedBitmap(CGMutablePathRef path, const CGAffineTransform *m,
        const void *data, size_t width, size_t height, size_t bytesPerRow, float x, float y, float tolerance,
        uint32_t maxDepth, CGEPathBitmapOptions options, CGRect *bounds);
bool CGEPathAddPathsFromBGRA8888PremultipliedBitmap(CGMutablePathRef path, const CGAffineTransform *m,
        const void *data, size_t width, size_t height, size_t bytesPerRow, float x, float y, float tolerance,
        uint32_t maxDepth, CGEPathBitmapOptions options, CGRect *bounds);
bool CGEPathAddPathsFromGrayscale1Bitmap(CGMutablePathRef path, const CGAffineTransform *m,
        const void *data, size_t width, size_t height, size_t bytesPerRow, float x, float y, float tolerance,
        uint32_t maxDepth, CGEPathBitmapOptions options, CGRect *bounds);
