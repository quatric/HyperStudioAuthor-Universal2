#import "CGEColor.h"
#import "CGEContext.h"
#import <libkern/OSAtomic.h>

enum {
    kColorSolid = 0,
    kColorUserPattern = 1,
    kColorGradient = 2,
};

enum {
    kGradientAxial = 0,
    kGradientRadial = 1,
    kGradientRectangular = 2,
};

struct CGEColor {
    volatile int64_t retainCount;
    int type;
    void *object;   // CGColorRef, UserPattern * or Gradient *
};

typedef struct {
    void *info;
    CGRect bounds;
    CGFloat xStep, yStep;
    CGPatternTiling tiling;
    CGColorSpaceRef baseSpace;
    CGFloat *components;
    CGPatternDrawPatternCallback drawPattern;
    CGPatternReleaseInfoCallback releaseInfo;
    CGColorSpaceRef patternSpace;
    // The pattern color for the context's scale and rotation.
    CGColorRef color;
    CGFloat colorMatrix[4];
} UserPattern;

// Linear gradient colors (shared by the gradient and its function).
typedef struct {
    size_t retainCount;
    size_t count;
    CGFloat *locations;     // count, from 0 to 1, or NULL (evenly spaced)
    CGColorSpaceRef space;
    CGFloat *components;    // count × (components + alpha)
    CGFunctionEvaluateCallback evaluate;
} LinearColors;

typedef struct {
    CGPoint start, end;
    unsigned int extendStart : 1;
    unsigned int extendEnd : 1;
} AxialGeometry;

typedef struct {
    CGPoint startCenter;
    CGFloat startRadius;
    CGPoint endCenter;
    CGFloat endRadius;
    unsigned int extendStart : 1;
    unsigned int extendEnd : 1;
} RadialGeometry;

typedef struct {
    CGRect startRect, endRect;
    unsigned int extendStart : 1;
    unsigned int extendEnd : 1;
} RectangularGeometry;

typedef struct {
    CGAffineTransform transform;    // the unit square to the bounds' unit square
    CGShadingRef shading;           // rectangular: axial from (0, 0) to (1, 0)
    CGColorSpaceRef space;          // with callbacks only
    int kind;
    void *colors;                   // LinearColors * or CGEGradientColorsCallbacks *
    void *geometry;
} Gradient;

static void ShowInvalidType(void)
{
    CFShow(CFSTR("Invalid / unsupported color type."));
}

static void ShowInvalidGradientType(void)
{
    CFShow(CFSTR("Invalid / unsupported gradient type."));
}

#pragma mark HSV

void CGEColorConvertRGBToHSV(CGFloat r, CGFloat g, CGFloat b, CGFloat *h, CGFloat *s, CGFloat *v)
{
    CGFloat max = r, min = g;
    if (g > r) {
        max = g;
        min = r;
    }
    if (b > max)
        max = b;
    else if (b < min)
        min = b;
    CGFloat hue = 0, saturation = 0;
    if (max != 0) {
        CGFloat delta = max - min;
        saturation = delta / max;
        if (saturation != 0) {
            if (max == r)
                hue = (g - b) / delta;
            else if (max == g)
                hue = (b - r) / delta + 2;
            else if (max == b)
                hue = (r - g) / delta + 4;
            if (hue < 0)
                hue += 6;
            hue /= 6;
        }
    }
    if (h)
        *h = hue;
    if (s)
        *s = saturation;
    if (v)
        *v = max;
}

void CGEColorConvertHSVToRGB(CGFloat h, CGFloat s, CGFloat v, CGFloat *r, CGFloat *g, CGFloat *b)
{
    CGFloat red = v, green = v, blue = v;
    if (s != 0) {
        CGFloat chroma = s * v, low = v - chroma;
        h *= 6;
        if (h > 5)
            h -= 6;
        if (h < 0) {
            green = low;
            blue = low - chroma * h;
        } else if (h < 1) {
            green = chroma * h + low;
            blue = low;
        } else if (h < 2) {
            red = low - chroma * (h - 2);
            blue = low;
        } else if (h < 3) {
            red = low;
            blue = chroma * (h - 2) + low;
        } else {
            red = low;
            chroma *= h - 4;
            if (h < 4)
                green = low - chroma;
            else {
                red = chroma + low;
                green = low;
            }
        }
    }
    if (r)
        *r = red;
    if (g)
        *g = green;
    if (b)
        *b = blue;
}

#pragma mark Retain / release

static void LinearColorsRelease(LinearColors *colors)
{
    if (!colors)
        return;
    if (colors->retainCount > 1) {
        colors->retainCount--;
        return;
    }
    free(colors->locations);
    CGColorSpaceRelease(colors->space);
    free(colors->components);
    free(colors);
}

static void LinearColorsReleaseInfo(void *info)
{
    LinearColorsRelease(info);
}

CGEColorRef CGEColorRetain(CGEColorRef color)
{
    if (color)
        OSAtomicAdd64(1, &color->retainCount);
    return color;
}

void CGEColorRelease(CGEColorRef color)
{
    if (!color || OSAtomicAdd64(-1, &color->retainCount) != 0)
        return;
    OSMemoryBarrier();
    switch (color->type) {
    case kColorGradient: {
        Gradient *gradient = color->object;
        CGShadingRelease(gradient->shading);
        if (!gradient->space)
            LinearColorsRelease(gradient->colors);
        else {
            CGColorSpaceRelease(gradient->space);
            CGEGradientColorsCallbacks *callbacks = gradient->colors;
            if (callbacks) {
                if (callbacks->releaseInfo)
                    callbacks->releaseInfo(callbacks->info);
                free(callbacks);
            }
        }
        if (gradient->kind > kGradientRectangular)
            ShowInvalidGradientType();
        free(gradient->geometry);
        free(gradient);
        break;
    }
    case kColorUserPattern: {
        UserPattern *pattern = color->object;
        CGColorRelease(pattern->color);
        if (pattern->releaseInfo)
            pattern->releaseInfo(pattern->info);
        CGColorSpaceRelease(pattern->patternSpace);
        if (pattern->components) {
            CGColorSpaceRelease(pattern->baseSpace);
            free(pattern->components);
        }
        free(pattern);
        break;
    }
    case kColorSolid:
        CGColorRelease(color->object);
        break;
    default:
        ShowInvalidType();
        break;
    }
    free(color);
}

static CGEColorRef NewColor(int type, void *object)
{
    CGEColorRef color = malloc(sizeof(struct CGEColor));
    if (!color)
        return NULL;
    color->retainCount = 1;
    color->type = type;
    color->object = object;
    return color;
}

#pragma mark Solid colors

CGEColorRef CGEColorCreateSolid(CGColorSpaceRef space, const CGFloat *components)
{
    CGColorRef cgColor = CGColorCreate(space, components);
    if (!cgColor)
        return NULL;
    CGEColorRef color = NewColor(kColorSolid, cgColor);
    if (!color)
        CGColorRelease(cgColor);
    return color;
}

CGEColorRef CGEColorCreateWithCGColor(CGColorRef cgColor)
{
    if (!cgColor)
        return NULL;
    CGEColorRef color = NewColor(kColorSolid, (void *)cgColor);
    if (color)
        CGColorRetain(cgColor);
    return color;
}

#pragma mark Patterns

CGEColorRef CGEColorCreateUserPattern(void *info, CGRect bounds, CGFloat xStep, CGFloat yStep,
                                      CGPatternTiling tiling, CGColorSpaceRef baseSpace, const CGFloat *components,
                                      CGPatternDrawPatternCallback drawPattern,
                                      CGPatternReleaseInfoCallback releaseInfo)
{
    UserPattern *pattern = calloc(1, sizeof(UserPattern));
    if (!pattern)
        return NULL;
    size_t size = sizeof(CGFloat) * (CGColorSpaceGetNumberOfComponents(baseSpace) + 1);
    pattern->components = malloc(size);
    if (!pattern->components) {
        free(pattern);
        return NULL;
    }
    memcpy(pattern->components, components, size);
    pattern->patternSpace = CGColorSpaceCreatePattern(baseSpace);
    pattern->info = info;
    pattern->bounds = bounds;
    pattern->xStep = xStep;
    pattern->yStep = yStep;
    pattern->tiling = tiling;
    pattern->baseSpace = CGColorSpaceRetain(baseSpace);
    pattern->drawPattern = drawPattern;
    pattern->releaseInfo = releaseInfo;
    CGEColorRef color = NewColor(kColorUserPattern, pattern);
    if (!color) {
        CGColorSpaceRelease(pattern->patternSpace);
        CGColorSpaceRelease(pattern->baseSpace);
        free(pattern->components);
        free(pattern);
    }
    return color;
}

typedef struct {
    CGImageRef image;
    CGRect cell;
    unsigned int flipHorizontally : 1;
    unsigned int flipVertically : 1;
} ImageCell;

typedef struct {
    CGPDFDocumentRef document;
    CGPDFPageRef page;
    CGRect cell;
    unsigned int flipHorizontally : 1;
    unsigned int flipVertically : 1;
} PDFPageCell;

static CGAffineTransform CellFlip(CGRect cell, bool horizontally, bool vertically)
{
    CGAffineTransform flip = CGAffineTransformIdentity;
    if (horizontally)
        flip = CGAffineTransformMake(-1, 0, 0, 1, CGRectGetMinX(cell) + CGRectGetMaxX(cell), 0);
    if (vertically)
        flip = CGAffineTransformConcat(flip, CGAffineTransformMake(1, 0, 0, -1, 0,
                                                                   CGRectGetMinY(cell) + CGRectGetMaxY(cell)));
    return flip;
}

static void DrawImageCell(void *info, CGContextRef context)
{
    ImageCell *cell = info;
    if (cell->flipHorizontally || cell->flipVertically)
        CGContextConcatCTM(context, CellFlip(cell->cell, cell->flipHorizontally, cell->flipVertically));
    CGContextDrawImage(context, cell->cell, cell->image);
}

static void ReleaseImageCell(void *info)
{
    ImageCell *cell = info;
    CGImageRelease(cell->image);
    free(cell);
}

// The page's media box fills the cell.
static void DrawPDFPageCell(void *info, CGContextRef context)
{
    PDFPageCell *cell = info;
    CGRect box = CGPDFPageGetBoxRect(cell->page, kCGPDFMediaBox);
    if (cell->flipHorizontally || cell->flipVertically)
        CGContextConcatCTM(context, CellFlip(cell->cell, cell->flipHorizontally, cell->flipVertically));
    if (box.size.width > 0 && box.size.height > 0)
        CGContextConcatCTM(context, CGAffineTransformMake(cell->cell.size.width / box.size.width, 0, 0,
                                                          cell->cell.size.height / box.size.height,
                                                          cell->cell.origin.x - box.origin.x * cell->cell.size.width / box.size.width,
                                                          cell->cell.origin.y - box.origin.y * cell->cell.size.height / box.size.height));
    CGContextDrawPDFPage(context, cell->page);
}

static void ReleasePDFPageCell(void *info)
{
    PDFPageCell *cell = info;
    CGPDFDocumentRelease(cell->document);
    free(cell);
}

CGEColorRef CGEColorCreateUserPatternWithImageCell(CGImageRef image, CGRect cell, bool flipHorizontally,
                                                   bool flipVertically, CGFloat xStep, CGFloat yStep,
                                                   CGPatternTiling tiling, CGColorSpaceRef baseSpace,
                                                   const CGFloat *components)
{
    ImageCell *info = calloc(1, sizeof(ImageCell));
    if (!info)
        return NULL;
    info->image = image;
    info->cell = cell;
    info->flipHorizontally = flipHorizontally;
    info->flipVertically = flipVertically;
    CGEColorRef color = CGEColorCreateUserPattern(info, cell, xStep, yStep, tiling, baseSpace, components,
                                                  DrawImageCell, ReleaseImageCell);
    if (!color) {
        free(info);
        return NULL;
    }
    CGImageRetain(image);
    return color;
}

CGEColorRef CGEColorCreateUserPatternWithImage(CGImageRef image, bool flipHorizontally, bool flipVertically,
                                               CGPatternTiling tiling, CGColorSpaceRef baseSpace,
                                               const CGFloat *components)
{
    CGFloat width = CGImageGetWidth(image), height = CGImageGetHeight(image);
    return CGEColorCreateUserPatternWithImageCell(image, CGRectMake(0, 0, width, height), flipHorizontally,
                                                  flipVertically, width, height, tiling, baseSpace, components);
}

CGEColorRef CGEColorCreateUserPatternWithPDFPageCell(CGPDFDocumentRef document, size_t pageNumber, CGRect cell,
                                                     bool flipHorizontally, bool flipVertically, CGFloat xStep,
                                                     CGFloat yStep, CGPatternTiling tiling, CGColorSpaceRef baseSpace,
                                                     const CGFloat *components)
{
    PDFPageCell *info = calloc(1, sizeof(PDFPageCell));
    if (!info)
        return NULL;
    info->page = CGPDFDocumentGetPage(document, pageNumber);
    if (info->page) {
        info->document = document;
        info->cell = cell;
        info->flipHorizontally = flipHorizontally;
        info->flipVertically = flipVertically;
        CGEColorRef color = CGEColorCreateUserPattern(info, cell, xStep, yStep, tiling, baseSpace, components,
                                                      DrawPDFPageCell, ReleasePDFPageCell);
        if (color) {
            CGPDFDocumentRetain(document);
            return color;
        }
    }
    free(info);
    return NULL;
}

// The pattern color for the context's user space (after transform): made
// again when its scale or rotation changes; the phase follows the bounds'
// origin.
static CGColorRef PatternColor(CGContextRef context, const CGAffineTransform *transform, UserPattern *pattern,
                               CGPoint origin)
{
    CGAffineTransform ctm = CGContextGetCTM(context);
    if (transform)
        ctm = CGAffineTransformConcat(*transform, ctm);
    if (pattern->color) {
        CGFloat matrix[4] = { ctm.a, ctm.b, ctm.c, ctm.d };
        for (int i = 0; i < 4; i++) {
            CGFloat tolerance = fabs(pattern->colorMatrix[i]) * 1e-07;
            if (pattern->colorMatrix[i] < matrix[i] - tolerance || matrix[i] + tolerance < pattern->colorMatrix[i]) {
                CGColorRelease(pattern->color);
                pattern->color = NULL;
                break;
            }
        }
    }
    if (!pattern->color) {
        CGPatternCallbacks callbacks = { 0, pattern->drawPattern, NULL };
        CGPatternRef cgPattern = CGPatternCreate(pattern->info, pattern->bounds,
                                                 CGAffineTransformMake(ctm.a, ctm.b, ctm.c, ctm.d, 0, 0),
                                                 pattern->xStep, pattern->yStep, pattern->tiling,
                                                 pattern->baseSpace == NULL, &callbacks);
        if (!cgPattern)
            return NULL;
        pattern->color = CGColorCreateWithPattern(pattern->patternSpace, cgPattern, pattern->components);
        CGPatternRelease(cgPattern);
        if (!pattern->color)
            return NULL;
        pattern->colorMatrix[0] = ctm.a;
        pattern->colorMatrix[1] = ctm.b;
        pattern->colorMatrix[2] = ctm.c;
        pattern->colorMatrix[3] = ctm.d;
    }
    CGContextSetPatternPhase(context, CGSizeMake(ctm.a * origin.x + ctm.tx + ctm.c * origin.y,
                                                 origin.x * ctm.b + ctm.ty + origin.y * ctm.d));
    return pattern->color;
}

#pragma mark Gradients

// The color at a location: interpolated between the stops around it.
static void EvaluateLinearColors(void *info, const CGFloat *in, CGFloat *out)
{
    LinearColors *colors = info;
    size_t components = CGColorSpaceGetNumberOfComponents(colors->space) + 1;
    size_t last = colors->count - 1;
    CGFloat x = in[0];
    size_t index;
    if (!colors->locations)
        index = lround(ceil(last * x));
    else if (x == colors->locations[0])
        index = 0;
    else
        for (index = 1; index < last && colors->locations[index] < x; index++)
            ;
    if (index == 0) {
        memcpy(out, colors->components, sizeof(CGFloat) * components);
        return;
    }
    CGFloat t;
    if (!colors->locations)
        t = x * last - (index - 1);
    else {
        CGFloat span = colors->locations[index] - colors->locations[index - 1];
        t = span != 0 ? (x - colors->locations[index - 1]) / span : 1;
    }
    const CGFloat *from = colors->components + (index - 1) * components, *to = from + components;
    for (size_t i = 0; i < components; i++)
        out[i] = from[i] * (1 - t) + to[i] * t;
}

// count stops between 0 and 1 (the locations' stops are 0, those and 1).
static LinearColors *LinearColorsCreate(size_t count, const CGFloat *locations, CGColorSpaceRef space,
                                        const CGFloat *components, CGFunctionEvaluateCallback evaluate)
{
    LinearColors *colors = calloc(1, sizeof(LinearColors));
    if (!colors)
        return NULL;
    size_t perColor = CGColorSpaceGetNumberOfComponents(space) + 1;
    colors->count = count + 2;
    if (locations) {
        colors->locations = malloc(sizeof(CGFloat) * colors->count);
        if (!colors->locations) {
            free(colors);
            return NULL;
        }
        colors->locations[0] = 0;
        memcpy(colors->locations + 1, locations, sizeof(CGFloat) * count);
        colors->locations[count + 1] = 1;
    }
    size_t size = sizeof(CGFloat) * perColor * colors->count;
    colors->components = malloc(size);
    if (!colors->components) {
        free(colors->locations);
        free(colors);
        return NULL;
    }
    memcpy(colors->components, components, size);
    colors->space = CGColorSpaceRetain(space);
    colors->evaluate = evaluate;
    colors->retainCount = 1;
    return colors;
}

static CGFunctionRef LinearColorsCreateFunction(LinearColors *colors)
{
    size_t outputs = CGColorSpaceGetNumberOfComponents(colors->space) + 1;
    CGFloat *range = malloc(sizeof(CGFloat) * 2 * outputs);
    if (!range)
        return NULL;
    for (size_t i = 0; i < outputs; i++) {
        range[2 * i] = 0;
        range[2 * i + 1] = 1;
    }
    static const CGFloat domain[2] = { 0, 1 };
    CGFunctionCallbacks callbacks = { 0, colors->evaluate, LinearColorsReleaseInfo };
    CGFunctionRef function = CGFunctionCreate(colors, 1, domain, outputs, range, &callbacks);
    free(range);
    if (function)
        colors->retainCount++;
    return function;
}

// The gradient keeps the colors (linear colors' first reference, or a copy of
// the callbacks); fails with callbacks of another version.
static bool SetGradientColors(Gradient *gradient, CGColorSpaceRef space, LinearColors *colors,
                              const CGEGradientColorsCallbacks *callbacks)
{
    gradient->space = NULL;
    gradient->colors = NULL;
    if (colors) {
        gradient->colors = colors;
        return true;
    }
    if (!callbacks)
        return true;
    if (callbacks->version != 0)
        return false;
    CGEGradientColorsCallbacks *copy = malloc(sizeof(CGEGradientColorsCallbacks));
    if (!copy)
        return false;
    *copy = *callbacks;
    gradient->colors = copy;
    gradient->space = CGColorSpaceRetain(space);
    return true;
}

static CGEColorRef NewGradient(Gradient *gradient)
{
    CGEColorRef color = NewColor(kColorGradient, gradient);
    if (!color) {
        // The colors stay the caller's.
        CGShadingRelease(gradient->shading);
        if (gradient->space) {
            CGColorSpaceRelease(gradient->space);
            free(gradient->colors);
        }
        free(gradient->geometry);
        free(gradient);
    }
    return color;
}

static CGEColorRef CreateAxialGradient(CGPoint start, CGPoint end, CGColorSpaceRef space, CGFunctionRef function,
                                       LinearColors *colors, const CGEGradientColorsCallbacks *callbacks,
                                       bool extendStart, bool extendEnd)
{
    Gradient *gradient = calloc(1, sizeof(Gradient));
    if (!gradient)
        return NULL;
    gradient->shading = CGShadingCreateAxial(space, start, end, function, extendStart, extendEnd);
    AxialGeometry *geometry = calloc(1, sizeof(AxialGeometry));
    if (!gradient->shading || !geometry || !SetGradientColors(gradient, space, colors, callbacks)) {
        CGShadingRelease(gradient->shading);
        free(geometry);
        free(gradient);
        return NULL;
    }
    geometry->start = start;
    geometry->end = end;
    geometry->extendStart = extendStart;
    geometry->extendEnd = extendEnd;
    gradient->geometry = geometry;
    gradient->transform = CGAffineTransformIdentity;
    gradient->kind = kGradientAxial;
    return NewGradient(gradient);
}

static CGEColorRef CreateRadialGradient(CGPoint startCenter, CGFloat startRadius, CGPoint endCenter,
                                        CGFloat endRadius, CGColorSpaceRef space, CGFunctionRef function,
                                        LinearColors *colors, const CGEGradientColorsCallbacks *callbacks,
                                        bool extendStart, bool extendEnd, CGAffineTransform transform)
{
    Gradient *gradient = calloc(1, sizeof(Gradient));
    if (!gradient)
        return NULL;
    gradient->shading = CGShadingCreateRadial(space, startCenter, startRadius, endCenter, endRadius, function,
                                              extendStart, extendEnd);
    RadialGeometry *geometry = calloc(1, sizeof(RadialGeometry));
    if (!gradient->shading || !geometry || !SetGradientColors(gradient, space, colors, callbacks)) {
        CGShadingRelease(gradient->shading);
        free(geometry);
        free(gradient);
        return NULL;
    }
    geometry->startCenter = startCenter;
    geometry->startRadius = startRadius;
    geometry->endCenter = endCenter;
    geometry->endRadius = endRadius;
    geometry->extendStart = extendStart;
    geometry->extendEnd = extendEnd;
    gradient->geometry = geometry;
    gradient->transform = transform;
    gradient->kind = kGradientRadial;
    return NewGradient(gradient);
}

static CGEColorRef CreateRectangularGradient(CGColorSpaceRef space, CGFunctionRef function, LinearColors *colors,
                                             const CGEGradientColorsCallbacks *callbacks, bool extendStart,
                                             bool extendEnd, CGRect startRect, CGRect endRect,
                                             CGAffineTransform transform)
{
    Gradient *gradient = calloc(1, sizeof(Gradient));
    if (!gradient)
        return NULL;
    gradient->shading = CGShadingCreateAxial(space, CGPointZero, CGPointMake(1, 0), function, extendStart,
                                             extendEnd);
    RectangularGeometry *geometry = calloc(1, sizeof(RectangularGeometry));
    if (!gradient->shading || !geometry || !SetGradientColors(gradient, space, colors, callbacks)) {
        CGShadingRelease(gradient->shading);
        free(geometry);
        free(gradient);
        return NULL;
    }
    geometry->startRect = startRect;
    geometry->endRect = endRect;
    geometry->extendStart = extendStart;
    geometry->extendEnd = extendEnd;
    gradient->geometry = geometry;
    gradient->transform = transform;
    gradient->kind = kGradientRectangular;
    return NewGradient(gradient);
}

CGEColorRef CGEColorCreateLinearAxialGradient(CGColorSpaceRef space, CGPoint start, CGPoint end, size_t count,
                                              const CGFloat *locations, const CGFloat *components, bool extendStart,
                                              bool extendEnd)
{
    LinearColors *colors = LinearColorsCreate(count, locations, space, components, EvaluateLinearColors);
    if (!colors)
        return NULL;
    CGFunctionRef function = LinearColorsCreateFunction(colors);
    if (function) {
        CGEColorRef color = CreateAxialGradient(start, end, space, function, colors, NULL, extendStart, extendEnd);
        CGFunctionRelease(function);
        if (color)
            return color;
    }
    LinearColorsRelease(colors);
    return NULL;
}

CGEColorRef CGEColorCreateLinearRadialGradient(CGColorSpaceRef space, CGPoint startCenter, CGFloat startRadius,
                                               CGPoint endCenter, CGFloat endRadius, CGAffineTransform transform,
                                               size_t count, const CGFloat *locations, const CGFloat *components,
                                               bool extendStart, bool extendEnd)
{
    LinearColors *colors = LinearColorsCreate(count, locations, space, components, EvaluateLinearColors);
    if (!colors)
        return NULL;
    CGFunctionRef function = LinearColorsCreateFunction(colors);
    if (function) {
        CGEColorRef color = CreateRadialGradient(startCenter, startRadius, endCenter, endRadius, space, function,
                                                 colors, NULL, extendStart, extendEnd, transform);
        CGFunctionRelease(function);
        if (color)
            return color;
    }
    LinearColorsRelease(colors);
    return NULL;
}

CGEColorRef CGEColorCreateLinearRectangularGradient(CGColorSpaceRef space, CGRect startRect, CGRect endRect,
                                                    CGAffineTransform transform, size_t count,
                                                    const CGFloat *locations, const CGFloat *components,
                                                    bool extendStart, bool extendEnd)
{
    LinearColors *colors = LinearColorsCreate(count, locations, space, components, EvaluateLinearColors);
    if (!colors)
        return NULL;
    CGFunctionRef function = LinearColorsCreateFunction(colors);
    if (function) {
        CGEColorRef color = CreateRectangularGradient(space, function, colors, NULL, extendStart, extendEnd,
                                                      startRect, endRect, transform);
        CGFunctionRelease(function);
        if (color)
            return color;
    }
    LinearColorsRelease(colors);
    return NULL;
}

CGEColorRef CGEColorCreateAxialGradient(CGColorSpaceRef space, CGPoint start, CGPoint end, CGFunctionRef function,
                                        const CGEGradientColorsCallbacks *callbacks, bool extendStart,
                                        bool extendEnd)
{
    return CreateAxialGradient(start, end, space, function, NULL, callbacks, extendStart, extendEnd);
}

CGEColorRef CGEColorCreateRadialGradient(CGColorSpaceRef space, CGPoint startCenter, CGFloat startRadius,
                                         CGPoint endCenter, CGFloat endRadius, CGAffineTransform transform,
                                         CGFunctionRef function, const CGEGradientColorsCallbacks *callbacks,
                                         bool extendStart, bool extendEnd)
{
    return CreateRadialGradient(startCenter, startRadius, endCenter, endRadius, space, function, NULL, callbacks,
                                extendStart, extendEnd, transform);
}

CGEColorRef CGEColorCreateRectangularGradient(CGColorSpaceRef space, CGRect startRect, CGRect endRect,
                                              CGAffineTransform transform, CGFunctionRef function,
                                              const CGEGradientColorsCallbacks *callbacks, bool extendStart,
                                              bool extendEnd)
{
    return CreateRectangularGradient(space, function, NULL, callbacks, extendStart, extendEnd, startRect, endRect,
                                     transform);
}

// The same gradient with other colors' components.
static CGEColorRef GradientCreateCopyWithComponents(Gradient *gradient, const CGFloat *components)
{
    CGFunctionRef function;
    LinearColors *colors = NULL;
    CGEGradientColorsCallbacks callbacks, *newCallbacks = NULL;
    CGColorSpaceRef space;
    if (gradient->space) {
        CGEGradientColorsCallbacks *old = gradient->colors;
        if (!old || !old->createFunction)
            return NULL;
        callbacks = *old;
        newCallbacks = &callbacks;
        function = old->createFunction(old->info, components, &newCallbacks);
        if (!function)
            return NULL;
        space = gradient->space;
    } else {
        LinearColors *old = gradient->colors;
        if (!old)
            return NULL;
        colors = LinearColorsCreate(old->count - 2, old->locations ? old->locations + 1 : NULL, old->space,
                                    components, old->evaluate);
        if (!colors)
            return NULL;
        function = LinearColorsCreateFunction(colors);
        if (!function) {
            LinearColorsRelease(colors);
            return NULL;
        }
        space = old->space;
    }
    CGEColorRef color = NULL;
    switch (gradient->kind) {
    case kGradientRectangular: {
        RectangularGeometry *geometry = gradient->geometry;
        color = CreateRectangularGradient(space, function, colors, newCallbacks, geometry->extendStart,
                                          geometry->extendEnd, geometry->startRect, geometry->endRect,
                                          gradient->transform);
        break;
    }
    case kGradientRadial: {
        RadialGeometry *geometry = gradient->geometry;
        color = CreateRadialGradient(geometry->startCenter, geometry->startRadius, geometry->endCenter,
                                     geometry->endRadius, space, function, colors, newCallbacks,
                                     geometry->extendStart, geometry->extendEnd, gradient->transform);
        break;
    }
    case kGradientAxial: {
        AxialGeometry *geometry = gradient->geometry;
        color = CreateAxialGradient(geometry->start, geometry->end, space, function, colors, newCallbacks,
                                    geometry->extendStart, geometry->extendEnd);
        break;
    }
    default:
        ShowInvalidGradientType();
        break;
    }
    CGFunctionRelease(function);
    if (!color && colors)
        LinearColorsRelease(colors);
    return color;
}

CGEColorRef CGEColorCreateCopyWithBaseColorsComponents(CGEColorRef color, const CGFloat *components)
{
    if (!color)
        return NULL;
    switch (color->type) {
    case kColorGradient:
        return GradientCreateCopyWithComponents(color->object, components);
    case kColorUserPattern: {
        UserPattern *pattern = color->object;
        // A colored pattern has no base colors.
        if (!pattern->baseSpace)
            return CGEColorRetain(color);
        return CGEColorCreateUserPattern(pattern->info, pattern->bounds, pattern->xStep, pattern->yStep,
                                         pattern->tiling, pattern->baseSpace, components, pattern->drawPattern,
                                         pattern->releaseInfo);
    }
    case kColorSolid:
        if (CGColorGetPattern(color->object))
            return NULL;
        return CGEColorCreateSolid(CGColorGetColorSpace(color->object), components);
    default:
        ShowInvalidType();
        return NULL;
    }
}

#pragma mark Properties

bool CGEColorIsSolid(CGEColorRef color)
{
    return color && color->type == kColorSolid && !CGColorGetPattern(color->object);
}

bool CGEColorIsPattern(CGEColorRef color)
{
    if (!color || color->type == kColorGradient)
        return false;
    if (color->type == kColorUserPattern)
        return true;
    if (color->type == kColorSolid)
        return CGColorGetPattern(color->object) != NULL;
    ShowInvalidType();
    return false;
}

bool CGEColorIsUserPattern(CGEColorRef color)
{
    return color && color->type == kColorUserPattern;
}

bool CGEColorIsGradient(CGEColorRef color)
{
    return color && color->type == kColorGradient;
}

CGColorRef CGEColorGetCGColor(CGEColorRef color)
{
    return color && color->type == kColorSolid ? color->object : NULL;
}

CGFloat CGEColorGetAlpha(CGEColorRef color)
{
    if (!color)
        return 0;
    switch (color->type) {
    case kColorSolid:
        return CGColorGetAlpha(color->object);
    case kColorUserPattern: {
        UserPattern *pattern = color->object;
        return pattern->components[CGColorSpaceGetNumberOfComponents(pattern->baseSpace)];
    }
    case kColorGradient:
        return 1;
    default:
        ShowInvalidType();
        return 0;
    }
}

size_t CGEColorGetNumberOfBaseColors(CGEColorRef color)
{
    if (!color)
        return 0;
    switch (color->type) {
    case kColorGradient: {
        Gradient *gradient = color->object;
        if (!gradient->space)
            return gradient->colors ? ((LinearColors *)gradient->colors)->count : 0;
        CGEGradientColorsCallbacks *callbacks = gradient->colors;
        if (callbacks && callbacks->getNumberOfColors)
            return callbacks->getNumberOfColors(callbacks->info);
        return 0;
    }
    case kColorUserPattern:
        return ((UserPattern *)color->object)->baseSpace != NULL;
    case kColorSolid:
        return CGColorGetPattern(color->object) == NULL;
    default:
        ShowInvalidType();
        return 0;
    }
}

const CGFloat *CGEColorGetBaseColorsComponents(CGEColorRef color)
{
    if (!color)
        return NULL;
    switch (color->type) {
    case kColorGradient: {
        Gradient *gradient = color->object;
        if (!gradient->space)
            return gradient->colors ? ((LinearColors *)gradient->colors)->components : NULL;
        CGEGradientColorsCallbacks *callbacks = gradient->colors;
        if (callbacks && callbacks->getColorsComponents)
            return callbacks->getColorsComponents(callbacks->info);
        return NULL;
    }
    case kColorUserPattern:
        return ((UserPattern *)color->object)->components;
    case kColorSolid:
        if (!CGColorGetPattern(color->object))
            return CGColorGetComponents(color->object);
        return NULL;
    default:
        ShowInvalidType();
        return NULL;
    }
}

CGColorSpaceRef CGEColorGetBaseColorSpace(CGEColorRef color)
{
    if (!color)
        return NULL;
    switch (color->type) {
    case kColorGradient: {
        Gradient *gradient = color->object;
        if (gradient->space)
            return gradient->space;
        return gradient->colors ? ((LinearColors *)gradient->colors)->space : NULL;
    }
    case kColorUserPattern:
        return ((UserPattern *)color->object)->baseSpace;
    case kColorSolid:
        if (!CGColorGetPattern(color->object))
            return CGColorGetColorSpace(color->object);
        return NULL;
    default:
        ShowInvalidType();
        return NULL;
    }
}

// Gradients are equal only to themselves.
bool CGEColorEqualToColor(CGEColorRef color1, CGEColorRef color2)
{
    if (color1 == color2)
        return true;
    if (!color1 || !color2)
        return false;
    if (color1->type != color2->type || color1->type == kColorGradient)
        return false;
    if (color1->type == kColorSolid)
        return CGColorEqualToColor(color1->object, color2->object);
    if (color1->type != kColorUserPattern) {
        ShowInvalidType();
        return false;
    }
    UserPattern *pattern1 = color1->object, *pattern2 = color2->object;
    return pattern1->info == pattern2->info && CGRectEqualToRect(pattern1->bounds, pattern2->bounds) &&
           pattern1->xStep == pattern2->xStep && pattern1->yStep == pattern2->yStep &&
           pattern1->tiling == pattern2->tiling && pattern1->baseSpace == pattern2->baseSpace &&
           memcmp(pattern1->components, pattern2->components,
                  sizeof(CGFloat) * (CGColorSpaceGetNumberOfComponents(pattern1->baseSpace) + 1)) == 0 &&
           pattern1->drawPattern == pattern2->drawPattern && pattern1->releaseInfo == pattern2->releaseInfo;
}

#pragma mark Drawing

// A rectangular gradient: each side's region (between the diagonals through
// the start and end rects' corners) gets the axial shading across that side.
// The regions are clipped without antialiasing so they meet without seams
// (the original pixelized their diagonals in device space).
static void DrawRectangularGradient(CGContextRef context, Gradient *gradient)
{
    RectangularGeometry *geometry = gradient->geometry;
    CGRect inner = geometry->startRect, outer = geometry->endRect;
    CGFloat iMinX = CGRectGetMinX(inner), iMinY = CGRectGetMinY(inner);
    CGFloat iMaxX = CGRectGetMaxX(inner), iMaxY = CGRectGetMaxY(inner);
    CGFloat oMinX = CGRectGetMinX(outer), oMinY = CGRectGetMinY(outer);
    CGFloat oMaxX = CGRectGetMaxX(outer), oMaxY = CGRectGetMaxY(outer);
    // Corners (bottom left, bottom right, top right, top left) and points far
    // out along their diagonals.
    const CGFloat far = 1e5;
    CGPoint corners[4] = { { iMinX, iMinY }, { iMaxX, iMinY }, { iMaxX, iMaxY }, { iMinX, iMaxY } };
    CGPoint outerCorners[4] = { { oMinX, oMinY }, { oMaxX, oMinY }, { oMaxX, oMaxY }, { oMinX, oMaxY } };
    CGPoint farCorners[4];
    for (int i = 0; i < 4; i++)
        farCorners[i] = CGPointMake(corners[i].x + (outerCorners[i].x - corners[i].x) * far,
                                    corners[i].y + (outerCorners[i].y - corners[i].y) * far);
    // Left, right, bottom, top: the corners bounding the region and the
    // shading's mapping onto the side.
    struct {
        bool exists;
        int from, to;
        CGAffineTransform across;
    } sides[4] = {
        { oMinX < iMinX, 0, 3, CGAffineTransformMake(oMinX - iMinX, 0, 0, 1, iMinX, 0) },
        { iMaxX < oMaxX, 1, 2, CGAffineTransformMake(oMaxX - iMaxX, 0, 0, 1, iMaxX, 0) },
        { oMinY < iMinY, 0, 1, CGAffineTransformMake(0, oMinY - iMinY, -1, 0, 0, iMinY) },
        { iMaxY < oMaxY, 3, 2, CGAffineTransformMake(0, oMaxY - iMaxY, -1, 0, 0, iMaxY) },
    };
    bool interiorDrawn = false;
    for (int i = 0; i < 4; i++) {
        if (!sides[i].exists)
            continue;
        CGContextSaveGState(context);
        CGContextSetShouldAntialias(context, false);
        CGContextBeginPath(context);
        CGContextMoveToPoint(context, corners[sides[i].from].x, corners[sides[i].from].y);
        CGContextAddLineToPoint(context, farCorners[sides[i].from].x, farCorners[sides[i].from].y);
        CGContextAddLineToPoint(context, farCorners[sides[i].to].x, farCorners[sides[i].to].y);
        CGContextAddLineToPoint(context, corners[sides[i].to].x, corners[sides[i].to].y);
        CGContextClosePath(context);
        // The start rect's inside is the start of the first region drawn.
        if (!interiorDrawn && inner.size.width > 0 && inner.size.height > 0)
            CGContextAddRect(context, inner);
        interiorDrawn = true;
        CGContextClip(context);
        CGContextConcatCTM(context, sides[i].across);
        CGContextDrawShading(context, gradient->shading);
        CGContextRestoreGState(context);
    }
}

// Fills the path with a gradient in bounds: leaves the context clipped to the
// path and in the gradient's space.
static void FillPathWithGradient(CGContextRef context, bool evenOdd, const CGAffineTransform *transform,
                                 Gradient *gradient, CGRect bounds)
{
    if (evenOdd)
        CGContextEOClip(context);
    else
        CGContextClip(context);
    CGAffineTransform space = CGAffineTransformConcat(gradient->transform,
                                                      CGAffineTransformMake(bounds.size.width, 0, 0,
                                                                            bounds.size.height, bounds.origin.x,
                                                                            bounds.origin.y));
    if (transform)
        space = CGAffineTransformConcat(space, *transform);
    CGContextConcatCTM(context, space);
    switch (gradient->kind) {
    case kGradientAxial:
    case kGradientRadial:
        CGContextDrawShading(context, gradient->shading);
        break;
    case kGradientRectangular:
        DrawRectangularGradient(context, gradient);
        break;
    default:
        ShowInvalidGradientType();
        break;
    }
}

// The CGColor to draw a solid or pattern color with.
static CGColorRef DrawingColor(CGContextRef context, const CGAffineTransform *transform, CGRect bounds,
                               CGEColorRef color)
{
    if (color->type == kColorUserPattern)
        return PatternColor(context, transform, color->object, bounds.origin);
    if (color->type == kColorSolid)
        return color->object;
    ShowInvalidType();
    return NULL;
}

bool CGEContextSetFillColorWithColor(CGContextRef context, const CGAffineTransform *transform, CGRect bounds,
                                     CGEColorRef color)
{
    if (!context || !color || color->type == kColorGradient)
        return false;
    CGColorRef cgColor = DrawingColor(context, transform, bounds, color);
    if (!cgColor)
        return false;
    CGContextSetFillColorWithColor(context, cgColor);
    return true;
}

bool CGEContextSetStrokeColorWithColor(CGContextRef context, const CGAffineTransform *transform, CGRect bounds,
                                       CGEColorRef color)
{
    if (!context || !color || color->type == kColorGradient)
        return false;
    CGColorRef cgColor = DrawingColor(context, transform, bounds, color);
    if (!cgColor)
        return false;
    CGContextSetStrokeColorWithColor(context, cgColor);
    return true;
}

static void FillPathWithColor(CGContextRef context, bool evenOdd, const CGAffineTransform *transform, CGRect bounds,
                              CGEColorRef color)
{
    if (!context || !color)
        return;
    if (color->type == kColorGradient) {
        FillPathWithGradient(context, evenOdd, transform, color->object, bounds);
        return;
    }
    CGColorRef cgColor = DrawingColor(context, transform, bounds, color);
    if (!cgColor)
        return;
    CGContextSetFillColorWithColor(context, cgColor);
    if (evenOdd)
        CGContextEOFillPath(context);
    else
        CGContextFillPath(context);
}

void CGEContextFillPathWithColor(CGContextRef context, const CGAffineTransform *transform, CGRect bounds,
                                 CGEColorRef color)
{
    FillPathWithColor(context, false, transform, bounds, color);
}

void CGEContextEOFillPathWithColor(CGContextRef context, const CGAffineTransform *transform, CGRect bounds,
                                   CGEColorRef color)
{
    FillPathWithColor(context, true, transform, bounds, color);
}

void CGEContextStrokePathWithColor(CGContextRef context, const CGAffineTransform *transform, CGRect bounds,
                                   CGEColorRef color)
{
    if (!context || !color)
        return;
    if (color->type == kColorGradient) {
        CGContextReplacePathWithStrokedPath(context);
        FillPathWithGradient(context, false, transform, color->object, bounds);
        return;
    }
    CGColorRef cgColor = DrawingColor(context, transform, bounds, color);
    if (!cgColor)
        return;
    CGContextSetStrokeColorWithColor(context, cgColor);
    CGContextStrokePath(context);
}

static const void *ColorArrayRetain(CFAllocatorRef allocator, const void *value)
{
    return CGEColorRetain((CGEColorRef)value);
}

static void ColorArrayRelease(CFAllocatorRef allocator, const void *value)
{
    CGEColorRelease((CGEColorRef)value);
}

static CFStringRef ColorArrayCopyDescription(const void *value)
{
    return CFStringCreateWithFormat(kCFAllocatorDefault, NULL, CFSTR("<CGEColor %p>"), value);
}

static Boolean ColorArrayEqual(const void *value1, const void *value2)
{
    return CGEColorEqualToColor((CGEColorRef)value1, (CGEColorRef)value2);
}

void CGEContextSetColorAttachmentForKey(CGContextRef context, CFStringRef key, CGEColorRef color,
                                        CFArrayRef *array)
{
    if (!color) {
        CGEContextSetAttachmentForKey(context, key, NULL);
        if (array)
            *array = NULL;
        return;
    }
    CFArrayCallBacks callbacks = { 0, ColorArrayRetain, ColorArrayRelease, ColorArrayCopyDescription,
                                   ColorArrayEqual };
    const void *values[1] = { color };
    CFArrayRef colors = CFArrayCreate(kCFAllocatorDefault, values, 1, &callbacks);
    if (!colors)
        return;
    CGEContextSetAttachmentForKey(context, key, colors);
    if (array)
        *array = colors;
    else
        CFRelease(colors);
}

#pragma mark Color spaces and profiles

// (Before 10.5 sRGB came from its ColorSync profile.)
CGColorSpaceRef CGEColorSpaceCreateWithName(CFStringRef name)
{
    return CGColorSpaceCreateWithName(name);
}

ColorSyncProfileRef CSEProfileCreateWithName(CFStringRef name)
{
    const CFStringRef *names[] = {
        &kColorSyncGenericGrayProfile, &kColorSyncGenericGrayGamma22Profile, &kColorSyncGenericRGBProfile,
        &kColorSyncGenericCMYKProfile, &kColorSyncSRGBProfile, &kColorSyncAdobeRGB1998Profile,
        &kColorSyncGenericLabProfile, &kColorSyncGenericXYZProfile,
    };
    bool known = false;
    for (size_t i = 0; i < sizeof names / sizeof *names && !known; i++)
        known = *names[i] == name;
    for (size_t i = 0; i < sizeof names / sizeof *names && !known; i++)
        if (CFEqual(name, *names[i])) {
            name = *names[i];
            known = true;
        }
    return ColorSyncProfileCreateWithName(name);
}
