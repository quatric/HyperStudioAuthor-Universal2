// Extended colors (SMKApplicationKit's CGEColor functions): a solid CGColor,
// a user pattern, or a gradient (axial, radial or rectangular) filling a
// path's bounds; drawn with the CGEContext…WithColor functions.
#import <ApplicationServices/ApplicationServices.h>

typedef struct CGEColor *CGEColorRef;

// Colors of a gradient given by the caller instead of linear stops: version 0;
// createFunction makes the function of a copy with other components, and may
// change the callbacks the copy gets.
typedef struct CGEGradientColorsCallbacks {
    unsigned int version;
    void *info;
    void (*releaseInfo)(void *info);
    size_t (*getNumberOfColors)(void *info);
    const CGFloat *(*getColorsComponents)(void *info);
    CGFunctionRef (*createFunction)(void *info, const CGFloat *components,
                                    struct CGEGradientColorsCallbacks **callbacks);
} CGEGradientColorsCallbacks;

void CGEColorConvertRGBToHSV(CGFloat r, CGFloat g, CGFloat b, CGFloat *h, CGFloat *s, CGFloat *v);
void CGEColorConvertHSVToRGB(CGFloat h, CGFloat s, CGFloat v, CGFloat *r, CGFloat *g, CGFloat *b);

CGEColorRef CGEColorRetain(CGEColorRef color);
void CGEColorRelease(CGEColorRef color);

CGEColorRef CGEColorCreateSolid(CGColorSpaceRef space, const CGFloat *components);
CGEColorRef CGEColorCreateWithCGColor(CGColorRef color);
// The same kind of color with other components for its base colors (as
// CGEColorGetBaseColorsComponents gives them).
CGEColorRef CGEColorCreateCopyWithBaseColorsComponents(CGEColorRef color, const CGFloat *components);

// Patterns: drawn in the base space of the context (scaled and rotated like
// its user space) and phased to the bounds drawn in. A base space makes the
// pattern uncolored, components then holding its color (with alpha);
// without, components holds the alpha.
CGEColorRef CGEColorCreateUserPattern(void *info, CGRect bounds, CGFloat xStep, CGFloat yStep,
                                      CGPatternTiling tiling, CGColorSpaceRef baseSpace, const CGFloat *components,
                                      CGPatternDrawPatternCallback drawPattern,
                                      CGPatternReleaseInfoCallback releaseInfo);
// Patterns of an image or a PDF page drawn in a cell (also their bounds).
CGEColorRef CGEColorCreateUserPatternWithImageCell(CGImageRef image, CGRect cell, bool flipHorizontally,
                                                   bool flipVertically, CGFloat xStep, CGFloat yStep,
                                                   CGPatternTiling tiling, CGColorSpaceRef baseSpace,
                                                   const CGFloat *components);
CGEColorRef CGEColorCreateUserPatternWithImage(CGImageRef image, bool flipHorizontally, bool flipVertically,
                                               CGPatternTiling tiling, CGColorSpaceRef baseSpace,
                                               const CGFloat *components);
CGEColorRef CGEColorCreateUserPatternWithPDFPageCell(CGPDFDocumentRef document, size_t pageNumber, CGRect cell,
                                                     bool flipHorizontally, bool flipVertically, CGFloat xStep,
                                                     CGFloat yStep, CGPatternTiling tiling, CGColorSpaceRef baseSpace,
                                                     const CGFloat *components);

// Gradients in a unit square mapped (by transform) onto the bounds drawn in.
// Linear ones go through count + 2 colors (components: each color's
// components and alpha), at locations 0, the count given (or evenly spaced
// without), and 1. Rectangular ones go from the edges of startRect to the
// edges of endRect.
CGEColorRef CGEColorCreateLinearAxialGradient(CGColorSpaceRef space, CGPoint start, CGPoint end, size_t count,
                                              const CGFloat *locations, const CGFloat *components, bool extendStart,
                                              bool extendEnd);
CGEColorRef CGEColorCreateLinearRadialGradient(CGColorSpaceRef space, CGPoint startCenter, CGFloat startRadius,
                                               CGPoint endCenter, CGFloat endRadius, CGAffineTransform transform,
                                               size_t count, const CGFloat *locations, const CGFloat *components,
                                               bool extendStart, bool extendEnd);
CGEColorRef CGEColorCreateLinearRectangularGradient(CGColorSpaceRef space, CGRect startRect, CGRect endRect,
                                                    CGAffineTransform transform, size_t count,
                                                    const CGFloat *locations, const CGFloat *components,
                                                    bool extendStart, bool extendEnd);
CGEColorRef CGEColorCreateAxialGradient(CGColorSpaceRef space, CGPoint start, CGPoint end, CGFunctionRef function,
                                        const CGEGradientColorsCallbacks *callbacks, bool extendStart,
                                        bool extendEnd);
CGEColorRef CGEColorCreateRadialGradient(CGColorSpaceRef space, CGPoint startCenter, CGFloat startRadius,
                                         CGPoint endCenter, CGFloat endRadius, CGAffineTransform transform,
                                         CGFunctionRef function, const CGEGradientColorsCallbacks *callbacks,
                                         bool extendStart, bool extendEnd);
CGEColorRef CGEColorCreateRectangularGradient(CGColorSpaceRef space, CGRect startRect, CGRect endRect,
                                              CGAffineTransform transform, CGFunctionRef function,
                                              const CGEGradientColorsCallbacks *callbacks, bool extendStart,
                                              bool extendEnd);

bool CGEColorIsSolid(CGEColorRef color);
bool CGEColorIsPattern(CGEColorRef color);
bool CGEColorIsUserPattern(CGEColorRef color);
bool CGEColorIsGradient(CGEColorRef color);
// A solid color's CGColor.
CGColorRef CGEColorGetCGColor(CGEColorRef color);
CGFloat CGEColorGetAlpha(CGEColorRef color);
size_t CGEColorGetNumberOfBaseColors(CGEColorRef color);
const CGFloat *CGEColorGetBaseColorsComponents(CGEColorRef color);
CGColorSpaceRef CGEColorGetBaseColorSpace(CGEColorRef color);
bool CGEColorEqualToColor(CGEColorRef color1, CGEColorRef color2);

// Drawing in bounds (in user space, after transform if there is one). A
// gradient fill leaves the context clipped to the path, with the gradient's
// transform concatenated (save the graphics state around it). Setting a
// gradient as the fill or stroke color fails.
bool CGEContextSetFillColorWithColor(CGContextRef context, const CGAffineTransform *transform, CGRect bounds,
                                     CGEColorRef color);
bool CGEContextSetStrokeColorWithColor(CGContextRef context, const CGAffineTransform *transform, CGRect bounds,
                                       CGEColorRef color);
void CGEContextFillPathWithColor(CGContextRef context, const CGAffineTransform *transform, CGRect bounds,
                                 CGEColorRef color);
void CGEContextEOFillPathWithColor(CGContextRef context, const CGAffineTransform *transform, CGRect bounds,
                                   CGEColorRef color);
void CGEContextStrokePathWithColor(CGContextRef context, const CGAffineTransform *transform, CGRect bounds,
                                   CGEColorRef color);
// Sets a context attachment to a one-color array (which keeps the color);
// the array is returned (+1) if asked for.
void CGEContextSetColorAttachmentForKey(CGContextRef context, CFStringRef key, CGEColorRef color,
                                        CFArrayRef *array);

CGColorSpaceRef CGEColorSpaceCreateWithName(CFStringRef name);
// A ColorSync profile by name (kColorSync…Profile names or their values).
ColorSyncProfileRef CSEProfileCreateWithName(CFStringRef name);
