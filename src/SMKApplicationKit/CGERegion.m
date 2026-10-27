#import "CGERegion.h"
#import "CFEURL.h"
#import <libkern/OSAtomic.h>

// A region's shape, shared between copies.
typedef struct {
    volatile int64_t retainCount;
    CGRect rect;                    // the rect, or the path's bounds if known
    CFIndex rectCount;              // rects in the path
    CGMutablePathRef path;
    CGAffineTransform transform;    // not yet applied to the path
    unsigned int isEmpty : 1;
    unsigned int isRect : 1;
    unsigned int hasTransform : 1;
    unsigned int hasBounds : 1;
} Shape;

struct CGERegion {
    volatile int64_t retainCount;
    Shape *shape;   // NULL: empty
    unsigned int isMutable : 1;
};

static Shape *ShapeCreate(void)
{
    Shape *shape = calloc(1, sizeof(Shape));
    if (shape)
        shape->retainCount = 1;
    return shape;
}

static Shape *ShapeRetain(Shape *shape)
{
    if (shape)
        OSAtomicAdd64(1, &shape->retainCount);
    return shape;
}

static void ShapeRelease(Shape *shape)
{
    if (!shape || OSAtomicAdd64(-1, &shape->retainCount) != 0)
        return;
    OSMemoryBarrier();
    if (!shape->isEmpty && !shape->isRect)
        CGPathRelease(shape->path);
    free(shape);
}

static bool ShapeIsEmpty(Shape *shape)
{
    return !shape || shape->isEmpty;
}

// Applies the pending transform to the path.
static bool ShapeApplyTransform(Shape *shape)
{
    if (!shape->hasTransform)
        return true;
    CGMutablePathRef path = CGPathCreateMutable();
    if (!path)
        return false;
    CGPathAddPath(path, &shape->transform, shape->path);
    CGPathRelease(shape->path);
    shape->path = path;
    shape->hasTransform = false;
    shape->hasBounds = false;
    return true;
}

static CGRect ShapeGetBounds(Shape *shape)
{
    if (ShapeIsEmpty(shape))
        return CGRectZero;
    if (shape->isRect || (shape->hasBounds && !shape->hasTransform))
        return shape->rect;
    ShapeApplyTransform(shape);
    shape->rect = CGPathGetBoundingBox(shape->path);
    shape->hasBounds = true;
    return shape->rect;
}

// Makes the region's shape its own before it changes.
static void RegionMakeShapeUnique(CGERegionRef region)
{
    Shape *shape = region->shape;
    if (!shape || shape->retainCount < 2)
        return;
    Shape *copy = ShapeCreate();
    if (copy) {
        copy->isEmpty = shape->isEmpty;
        if (!shape->isEmpty) {
            copy->isRect = shape->isRect;
            if (!shape->isRect) {
                copy->rectCount = shape->rectCount;
                ShapeApplyTransform(shape);
                copy->path = CGPathCreateMutableCopy(shape->path);
                if (!copy->path) {
                    free(copy);
                    copy = NULL;
                    goto done;
                }
                copy->hasBounds = shape->hasBounds;
            }
            if (shape->isRect || shape->hasBounds)
                copy->rect = shape->rect;
        }
    }
done:
    ShapeRelease(shape);
    region->shape = copy;
}

// Empties the region.
static void RegionMakeEmpty(CGERegionRef region)
{
    Shape *shape = region->shape;
    if (!shape)
        return;
    if (shape->retainCount == 1) {
        if (!shape->isEmpty) {
            if (!shape->isRect)
                CGPathRelease(shape->path);
            shape->isEmpty = true;
            shape->isRect = shape->hasTransform = shape->hasBounds = false;
        }
    } else {
        ShapeRelease(shape);
        region->shape = NULL;
    }
}

// Turns the region (its own shape) into a rect.
static void RegionSetRect(CGERegionRef region, CGRect rect)
{
    RegionMakeShapeUnique(region);
    Shape *shape = region->shape;
    if (!shape)
        return;
    if (!shape->isEmpty && !shape->isRect)
        CGPathRelease(shape->path);
    shape->path = NULL;
    shape->isEmpty = shape->hasTransform = shape->hasBounds = false;
    shape->isRect = true;
    shape->rect = rect;
}

// A rect shape's rect as the first of a path's.
static bool ShapeMakePath(Shape *shape)
{
    CGMutablePathRef path = CGPathCreateMutable();
    if (!path)
        return false;
    CGPathAddRect(path, NULL, shape->rect);
    shape->isRect = shape->hasTransform = false;
    shape->hasBounds = true;
    shape->rectCount = 1;
    shape->path = path;
    return true;
}

static void ShapeAddRect(Shape *shape, CGRect rect)
{
    if (!shape)
        return;
    if (shape->isEmpty) {
        shape->isEmpty = false;
        shape->isRect = true;
        shape->rect = rect;
        return;
    }
    if (shape->isRect) {
        if (CGRectContainsRect(shape->rect, rect))
            return;
        if (CGRectContainsRect(rect, shape->rect)) {
            shape->rect = rect;
            return;
        }
        if (!ShapeMakePath(shape))
            return;
    } else if (!ShapeApplyTransform(shape))
        return;
    CGPathAddRect(shape->path, NULL, rect);
    shape->rectCount++;
    if (shape->hasBounds)
        shape->rect = CGRectUnion(shape->rect, rect);
}

static CGERegionRef RegionCreate(Shape *shape, bool isMutable)
{
    CGERegionRef region = malloc(sizeof(struct CGERegion));
    if (!region)
        return NULL;
    region->retainCount = 1;
    region->shape = shape;
    region->isMutable = isMutable;
    return region;
}

static CGERegionRef RegionCreateWithRect(CGRect rect, bool isMutable)
{
    Shape *shape = NULL;
    if (!CGRectIsEmpty(rect)) {
        shape = ShapeCreate();
        if (!shape)
            return NULL;
        shape->isRect = true;
        shape->rect = rect;
    }
    CGERegionRef region = RegionCreate(shape, isMutable);
    if (!region)
        free(shape);
    return region;
}

CGERegionRef CGERegionRetain(CGERegionRef region)
{
    if (region)
        OSAtomicAdd64(1, &region->retainCount);
    return region;
}

void CGERegionRelease(CGERegionRef region)
{
    if (!region || OSAtomicAdd64(-1, &region->retainCount) != 0)
        return;
    OSMemoryBarrier();
    ShapeRelease(region->shape);
    free(region);
}

CGERegionRef CGERegionCreateEmpty(void)
{
    static CGERegionRef empty;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        empty = RegionCreate(NULL, false);
    });
    return CGERegionRetain(empty);
}

CGERegionRef CGERegionCreateWithRect(CGRect rect)
{
    return RegionCreateWithRect(rect, false);
}

CGEMutableRegionRef CGERegionCreateMutable(void)
{
    return RegionCreate(NULL, true);
}

CGERegionRef CGERegionCreateCopy(CGERegionRef region)
{
    if (!region)
        return NULL;
    if (!region->isMutable)
        return CGERegionRetain(region);
    return RegionCreate(ShapeRetain(region->shape), false);
}

CGEMutableRegionRef CGERegionCreateMutableCopy(CGERegionRef region)
{
    if (!region)
        return NULL;
    return RegionCreate(ShapeRetain(region->shape), true);
}

static CGERegionRef RegionCreateIntersectingRect(CGERegionRef region, CGRect rect, bool isMutable)
{
    if (!region)
        return NULL;
    Shape *shape = region->shape;
    if (ShapeIsEmpty(shape))
        return isMutable ? CGERegionCreateMutable() : CGERegionCreateEmpty();
    CGRect intersection = CGRectIntersection(rect, ShapeGetBounds(shape));
    if (shape->isRect && CGRectIsEmpty(intersection))
        return isMutable ? CGERegionCreateMutable() : CGERegionCreateEmpty();
    return RegionCreateWithRect(intersection, isMutable);
}

static CGERegionRef RegionCreateIntersection(CGERegionRef region1, CGERegionRef region2, bool isMutable)
{
    if (!region1 || !region2)
        return NULL;
    if (ShapeIsEmpty(region1->shape) || ShapeIsEmpty(region2->shape))
        return isMutable ? CGERegionCreateMutable() : CGERegionCreateEmpty();
    if (region1->shape->isRect)
        return RegionCreateIntersectingRect(region2, region1->shape->rect, isMutable);
    if (region2->shape->isRect)
        return RegionCreateIntersectingRect(region1, region2->shape->rect, isMutable);
    return RegionCreateWithRect(CGRectIntersection(ShapeGetBounds(region2->shape), ShapeGetBounds(region1->shape)),
                                isMutable);
}

CGERegionRef CGERegionCreateCopyIntersectingRect(CGERegionRef region, CGRect rect)
{
    return RegionCreateIntersectingRect(region, rect, false);
}

CGEMutableRegionRef CGERegionCreateMutableCopyIntersectingRect(CGERegionRef region, CGRect rect)
{
    return RegionCreateIntersectingRect(region, rect, true);
}

CGERegionRef CGERegionCreateIntersection(CGERegionRef region1, CGERegionRef region2)
{
    return RegionCreateIntersection(region1, region2, false);
}

CGEMutableRegionRef CGERegionCreateMutableIntersection(CGERegionRef region1, CGERegionRef region2)
{
    return RegionCreateIntersection(region1, region2, true);
}

bool CGERegionIsEmpty(CGERegionRef region)
{
    return !region || ShapeIsEmpty(region->shape);
}

CGRect CGERegionGetBoundingRect(CGERegionRef region)
{
    return region ? ShapeGetBounds(region->shape) : CGRectZero;
}

bool CGERegionIntersectsRect(CGERegionRef region, CGRect rect)
{
    if (!region || ShapeIsEmpty(region->shape))
        return false;
    return CGRectIntersectsRect(ShapeGetBounds(region->shape), rect);
}

bool CGERegionIntersectsRegion(CGERegionRef region1, CGERegionRef region2)
{
    if (!region1 || !region2 || ShapeIsEmpty(region1->shape) || ShapeIsEmpty(region2->shape))
        return false;
    return CGRectIntersectsRect(ShapeGetBounds(region1->shape), ShapeGetBounds(region2->shape));
}

bool CGERegionEqualToRegion(CGERegionRef region1, CGERegionRef region2)
{
    if (region1 == region2)
        return true;
    Shape *shape1 = region1 ? region1->shape : NULL, *shape2 = region2 ? region2->shape : NULL;
    if (region1 && region2 && shape1 == shape2)
        return true;
    bool empty1 = ShapeIsEmpty(shape1), empty2 = ShapeIsEmpty(shape2);
    if (empty1 || empty2)
        return empty1 && empty2;
    if (shape1->isRect || shape2->isRect) {
        // A rect equals a path of only that rect.
        CGRect rect1 = shape1->rect, rect2 = shape2->rect;
        if (!shape1->isRect) {
            ShapeApplyTransform(shape1);
            if (!CGPathIsRect(shape1->path, &rect1))
                return false;
        } else if (!shape2->isRect) {
            ShapeApplyTransform(shape2);
            if (!CGPathIsRect(shape2->path, &rect2))
                return false;
        }
        return CGRectEqualToRect(rect1, rect2);
    }
    if (!ShapeApplyTransform(shape1) || !ShapeApplyTransform(shape2))
        return false;
    return CGPathEqualToPath(shape1->path, shape2->path);
}

// Each subpath's bounds.
static void CollectRects(void *info, const CGPathElement *element)
{
    CGRect **next = info;
    switch (element->type) {
    case kCGPathElementMoveToPoint:
        (*next)->origin = element->points[0];
        (*next)->size = CGSizeZero;
        break;
    case kCGPathElementAddLineToPoint: {
        CGRect *rect = *next;
        CGPoint p = element->points[0];
        if (p.x < rect->origin.x) {
            rect->size.width += rect->origin.x - p.x;
            rect->origin.x = p.x;
        } else if (rect->origin.x + rect->size.width < p.x)
            rect->size.width = p.x - rect->origin.x;
        if (p.y < rect->origin.y) {
            rect->size.height += rect->origin.y - p.y;
            rect->origin.y = p.y;
        } else if (rect->origin.y + rect->size.height < p.y)
            rect->size.height = p.y - rect->origin.y;
        break;
    }
    case kCGPathElementCloseSubpath:
        (*next)++;
        break;
    default:
        CFShow(CFSTR("Internal inconsistency."));
        break;
    }
}

CFDataRef CGERegionCopyRectApproximation(CGERegionRef region)
{
    if (!region)
        return NULL;
    Shape *shape = region->shape;
    if (ShapeIsEmpty(shape))
        return CFDataCreate(kCFAllocatorDefault, NULL, 0);
    if (shape->isRect)
        return CFDataCreate(kCFAllocatorDefault, (const UInt8 *)&shape->rect, sizeof(CGRect));
    if (!ShapeApplyTransform(shape))
        return NULL;
    CFIndex length = sizeof(CGRect) * shape->rectCount;
    CGRect *rects = calloc(shape->rectCount ? shape->rectCount : 1, sizeof(CGRect));
    if (!rects)
        return NULL;
    CGRect *next = rects;
    CGPathApply(shape->path, &next, CollectRects);
    CFDataRef data = CFDataCreateWithBytesNoCopy(kCFAllocatorDefault, (const UInt8 *)rects, length,
                                                 kCFAllocatorMalloc);
    if (!data)
        free(rects);
    return data;
}

void CGERegionAddRect(CGEMutableRegionRef region, CGRect rect)
{
    if (!region || CGRectIsEmpty(rect))
        return;
    if (!region->shape) {
        region->shape = ShapeCreate();
        if (region->shape)
            region->shape->isEmpty = true;
    } else
        RegionMakeShapeUnique(region);
    ShapeAddRect(region->shape, rect);
}

void CGERegionAddRegion(CGEMutableRegionRef region, CGERegionRef other)
{
    if (!region || !other || ShapeIsEmpty(other->shape))
        return;
    if (ShapeIsEmpty(region->shape)) {
        ShapeRelease(region->shape);
        region->shape = ShapeRetain(other->shape);
        return;
    }
    RegionMakeShapeUnique(region);
    Shape *shape = region->shape, *added = other->shape;
    if (added->isRect) {
        ShapeAddRect(shape, added->rect);
        return;
    }
    if (!shape)
        return;
    ShapeApplyTransform(added);
    if (shape->isRect) {
        if (!ShapeMakePath(shape))
            return;
    } else if (!ShapeApplyTransform(shape))
        return;
    CGPathAddPath(shape->path, NULL, added->path);
    shape->rectCount += added->rectCount;
    if (added->hasBounds) {
        if (shape->hasBounds)
            shape->rect = CGRectUnion(shape->rect, added->rect);
    } else
        shape->hasBounds = false;
}

void CGERegionIntersectRect(CGEMutableRegionRef region, CGRect rect)
{
    if (!region || ShapeIsEmpty(region->shape))
        return;
    if (CGRectIsEmpty(rect)) {
        RegionMakeEmpty(region);
        return;
    }
    Shape *shape = region->shape;
    if (!shape->isRect) {
        CGRect bounds = ShapeGetBounds(shape);
        if (CGRectContainsRect(rect, bounds))
            return;
        rect = CGRectIntersection(rect, bounds);
    } else
        rect = CGRectIntersection(rect, shape->rect);
    if (CGRectIsEmpty(rect))
        RegionMakeEmpty(region);
    else
        RegionSetRect(region, rect);
}

void CGERegionIntersectRegion(CGEMutableRegionRef region, CGERegionRef other)
{
    if (!region || ShapeIsEmpty(region->shape))
        return;
    if (!other || ShapeIsEmpty(other->shape)) {
        RegionMakeEmpty(region);
        return;
    }
    Shape *shape = region->shape, *otherShape = other->shape;
    if (otherShape->isRect) {
        CGERegionIntersectRect(region, otherShape->rect);
        return;
    }
    CGRect otherBounds = ShapeGetBounds(otherShape), rect;
    if (shape->isRect) {
        // Inside the rect, the other region as it is.
        if (CGRectContainsRect(shape->rect, otherBounds)) {
            ShapeRelease(shape);
            region->shape = ShapeRetain(otherShape);
            return;
        }
        rect = CGRectIntersection(shape->rect, otherBounds);
    } else
        rect = CGRectIntersection(otherBounds, ShapeGetBounds(shape));
    if (CGRectIsEmpty(rect))
        RegionMakeEmpty(region);
    else
        RegionSetRect(region, rect);
}

void CGERegionApplyAffineTransform(CGEMutableRegionRef region, CGAffineTransform transform)
{
    if (!region)
        return;
    RegionMakeShapeUnique(region);
    Shape *shape = region->shape;
    if (ShapeIsEmpty(shape))
        return;
    if (!shape->isRect) {
        if (shape->hasTransform)
            shape->transform = CGAffineTransformConcat(shape->transform, transform);
        else {
            shape->transform = transform;
            shape->hasTransform = true;
        }
        return;
    }
    // Turned by a multiple of a right angle, without skew: still a rect.
    double angle = transform.a != 0 || transform.b != 0 ? atan2(transform.b, transform.a)
                                                        : atan2(transform.d, transform.c) - M_PI_2;
    if (angle < 0)
        angle += 2 * M_PI;
    angle = remainder(angle, M_PI_2);
    if (-6.366197723675814e-06 <= angle && angle <= 6.366197723675814e-06) {
        double skew = atan2(transform.a * transform.c + transform.b * transform.d,
                            transform.a * transform.d - transform.b * transform.c);
        if (skew < -M_PI_2)
            skew += M_PI;
        else if (skew > M_PI_2)
            skew -= M_PI;
        if (-1e-05 <= skew && skew <= 1e-05) {
            shape->rect = CGRectApplyAffineTransform(shape->rect, transform);
            return;
        }
    }
    CGMutablePathRef path = CGPathCreateMutable();
    if (!path)
        return;
    CGPathAddRect(path, &transform, shape->rect);
    shape->isRect = shape->hasTransform = shape->hasBounds = false;
    shape->rectCount = 1;
    shape->path = path;
}

void CGERegionShowAs(CGERegionRef region, CFStringRef name, const void *object)
{
    if (!region)
        return;
    Shape *shape = region->shape;
    CFURLRef url = CFEURLCreateTemporaryFileURLForObject(kUTTypePDF, name, object);
    if (!url)
        return;
    CGRect box = CGRectInset(ShapeGetBounds(shape), -10, -10);
    CGContextRef context = CGPDFContextCreateWithURL(url, &box, NULL);
    if (context) {
        CGContextBeginPage(context, &box);
        if (shape) {
            CGContextSetRGBFillColor(context, 0, 0.5, 0, 1);
            CGContextBeginPath(context);
            if (shape->isRect)
                CGContextAddRect(context, shape->rect);
            else if (!shape->isEmpty) {
                ShapeApplyTransform(shape);
                CGContextAddPath(context, shape->path);
            }
            CGContextFillPath(context);
        }
        CGContextEndPage(context);
        CGContextRelease(context);
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        LSOpenCFURLRef(url, NULL);
#pragma clang diagnostic pop
    }
    CFRelease(url);
}

void CGERegionShow(CGERegionRef region)
{
    CGERegionShowAs(region, CFSTR("CGERegionRef"), region);
}
