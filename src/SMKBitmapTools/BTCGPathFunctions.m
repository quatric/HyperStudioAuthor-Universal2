#import "BTCGPathFunctions.h"

CGMutablePathRef BTCGPathCreateMutableCopyInscribedInRect(CGPathRef path, CGRect rect)
{
    CGMutablePathRef copy = CGPathCreateMutable();
    if (copy == NULL)
        return NULL;
    if (!CGPathIsEmpty(path)) {
        CGRect bounds = CGEPathGetPathBoundingBox(path);
        if (!CGRectIsEmpty(bounds)) {
            CGAffineTransform m;
            m.a = bounds.size.width != 0.0 ? rect.size.width / bounds.size.width : 1.0;
            m.d = bounds.size.height != 0.0 ? rect.size.height / bounds.size.height : 1.0;
            m.b = 0.0;
            m.c = 0.0;
            m.tx = rect.origin.x - bounds.origin.x * m.a;
            m.ty = rect.origin.y - bounds.origin.y * m.d;
            CGPathAddPath(copy, &m, path);
            return copy;
        }
    }
    CGPathAddRect(copy, NULL, rect);
    return copy;
}

typedef struct {
    CGMutablePathRef path;
    CGPoint first;      // first point emitted for the subpath
    CGPoint start;      // the subpath's move-to point
    CGPoint second;     // end of the subpath's first segment, NaN until known
    CGPoint current;
    CGSize pending;     // half-pixel offset back along the previous segment
    BOOL started;
} BTSmoothingState;

/* Moves to the point at the start of a subpath, else adds a line unless already there. */
static void BTSmoothingPut(BTSmoothingState *s, CGPoint p)
{
    if (!s->started) {
        CGPathMoveToPoint(s->path, NULL, p.x, p.y);
        s->first = p;
        s->started = YES;
        return;
    }
    CGPoint c = CGPathGetCurrentPoint(s->path);
    if (p.x < c.x - 0.01 || c.x + 0.01 < p.x || p.y < c.y - 0.01 || c.y + 0.01 < p.y)
        CGPathAddLineToPoint(s->path, NULL, p.x, p.y);
}

static void BTSmoothingLineTo(BTSmoothingState *s, CGPoint p)
{
    CGPoint c = s->current;
    CGSize next = CGSizeZero;
    if (c.x - 0.01 <= p.x && p.x <= c.x + 0.01) {
        /* Vertical step: cut the corner with a preceding horizontal one. */
        next.height = p.y > c.y ? -0.5 : (p.y < c.y ? 0.5 : 0.0);
        if (isnan(s->second.x)) {
            s->second = p;
        } else if (s->pending.width == 0.0) {
            BTSmoothingPut(s, c);
        } else {
            BTSmoothingPut(s, CGPointMake(c.x + s->pending.width, c.y + s->pending.height));
            CGPathAddLineToPoint(s->path, NULL, s->current.x, s->current.y - next.height);
        }
    } else if (c.y - 0.01 <= p.y && p.y <= c.y + 0.01) {
        /* Horizontal step: cut the corner with a preceding vertical one. */
        next.width = p.x > c.x ? -0.5 : (p.x < c.x ? 0.5 : 0.0);
        if (isnan(s->second.x)) {
            s->second = p;
        } else if (s->pending.height == 0.0) {
            BTSmoothingPut(s, c);
        } else {
            BTSmoothingPut(s, CGPointMake(c.x + s->pending.width, c.y + s->pending.height));
            CGPathAddLineToPoint(s->path, NULL, s->current.x - next.width, s->current.y);
        }
    } else {
        if (isnan(s->second.x))
            s->second = p;
        else
            BTSmoothingPut(s, c);
    }
    s->current = p;
    s->pending = next;
}

static void BTSmoothingApply(void *info, const CGPathElement *element)
{
    BTSmoothingState *s = info;
    CGPoint *pts = element->points;

    switch (element->type) {
    case kCGPathElementMoveToPoint:
        if (s->started) {
            CGPathAddLineToPoint(s->path, NULL, s->current.x, s->current.y);
            CGPathMoveToPoint(s->path, NULL, s->start.x, s->start.y);
            CGPathAddLineToPoint(s->path, NULL, s->first.x, s->first.y);
        }
        s->start = pts[0];
        s->current = pts[0];
        s->second = CGPointMake(NAN, NAN);
        s->pending = CGSizeZero;
        return;
    case kCGPathElementAddLineToPoint:
        BTSmoothingLineTo(s, pts[0]);
        return;
    case kCGPathElementAddQuadCurveToPoint:
        BTSmoothingPut(s, s->current);
        CGPathAddQuadCurveToPoint(s->path, NULL, pts[0].x, pts[0].y, pts[1].x, pts[1].y);
        s->current = pts[1];
        break;
    case kCGPathElementAddCurveToPoint:
        BTSmoothingPut(s, s->current);
        CGPathAddCurveToPoint(s->path, NULL, pts[0].x, pts[0].y, pts[1].x, pts[1].y, pts[2].x, pts[2].y);
        s->current = pts[2];
        break;
    case kCGPathElementCloseSubpath:
        if (s->current.x != s->start.x || s->current.y != s->start.y)
            BTSmoothingLineTo(s, s->start);
        BTSmoothingLineTo(s, s->second);
        CGPathCloseSubpath(s->path);
        s->current = s->start;
        s->second = CGPointMake(NAN, NAN);
        s->pending = CGSizeZero;
        s->started = NO;
        return;
    default:
        CFShow(CFSTR("Unknown CG path element type."));
        return;
    }
    s->pending = CGSizeZero;
    if (isnan(s->second.x))
        s->second = s->start;
}

CGMutablePathRef BTCGPathCreateMutableCopyWithSmoothedCorners(CGPathRef path)
{
    CGMutablePathRef copy = CGPathCreateMutable();
    if (copy == NULL)
        return NULL;
    BTSmoothingState state = { copy, CGPointZero, CGPointZero, { NAN, NAN }, CGPointZero, CGSizeZero, NO };
    CGPathApply(path, &state, BTSmoothingApply);
    return copy;
}

CGPathRef BTCGPathCreateCopyWithSmoothedCorners(CGPathRef path)
{
    CGMutablePathRef mutable = BTCGPathCreateMutableCopyWithSmoothedCorners(path);
    CGPathRef copy = CGPathCreateCopy(mutable);
    CGPathRelease(mutable);
    return copy;
}
