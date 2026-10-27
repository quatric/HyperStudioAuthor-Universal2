#import "NSEView.h"
#import "NSEOpenGLContext.h"
#import "NSEOpenGLFramebufferClipper.h"
#import "NSEWindow.h"
#import "CGEContext.h"
#import "NSDictionary+NSEDeepMutableCopying.h"
#import <OpenGL/CGLMacro.h>
#import <OpenGL/glu.h>
#import <libkern/OSAtomic.h>
#import <pthread.h>

// An NSView with an OpenGL surface (its NSEOpenGLContext drawing into part of
// the view, by default all of it) that falls back to Quartz drawing when
// OpenGL can't be used and quartz backing is enabled. Quartz drawing done
// while the surface is drawn (drawOpenGLSurfaceQuartzTextureRect:) goes to a
// bitmap that's then drawn into the surface as textures.

// The bitmap Quartz drawing goes to while the surface is drawn, as GL textures.
struct __NSEViewOpenGLQuartzTextureInfo {
    NSUInteger width;                   // of the part of the surface drawn
    NSUInteger height;
    struct CGEBitmapRect *rects;        // the rects drawn, in the bitmap
    GLenum target;                      // GL_TEXTURE_2D or GL_TEXTURE_RECTANGLE_EXT
    NSUInteger maxTextureWidth;         // the size of the tiles textures are made in
    NSUInteger maxTextureHeight;
};

typedef struct __NSEViewOpenGLDrawingInfo DrawingInfo;
typedef struct __NSEViewOpenGLQuartzTextureInfo QuartzTextureInfo;

// Rects closer than this count as touching.
#define RECT_TOLERANCE 0.001953125

// Stands for the invalidation info while one thread makes it.
#define INFO_BEING_MADE ((struct __NSEViewOpenGLSurfaceInvalidationInfo *)-1)

static NSUInteger powerOfTwoAtLeast(NSUInteger n, NSUInteger least)
{
    NSUInteger p = least;
    while (p < n)
        p *= 2;
    return p;
}

static void loadAffineMatrix(CGLContextObj cgl_ctx, CGAffineTransform t)
{
    GLfloat m[16] = { t.a, t.b, 0, 0, t.c, t.d, 0, 0, 0, 0, 1, 0, t.tx, t.ty, 0, 1 };
    glLoadMatrixf(m);
}

// Clears the rects of the bitmap (rows counted from its bottom).
static void clearBitmapRects(char *data, size_t height, size_t bytesPerRow, const struct CGEBitmapRect *rects,
                             NSUInteger count)
{
    for (NSUInteger i = 0; i < count; i++) {
        const struct CGEBitmapRect *r = &rects[i];
        for (size_t row = height - r->y - r->height; row < height - r->y; row++)
            memset(data + row * bytesPerRow + r->x * 4, 0, r->width * 4);
    }
}

// Adds rect to the first *count rects of data (from index from on), splitting
// it around the ones it overlaps so the list never overlaps; the list is
// compacted from index to on. YES if any of it was added.
static BOOL addRect(NSUInteger *count, CFMutableDataRef data, NSUInteger from, NSUInteger to, NSRect rect)
{
    NSRect *rects = (NSRect *)CFDataGetMutableBytePtr(data);
    BOOL compacting = to < from;
    for (;; from++) {
        if (*count <= from) {
            if (compacting)
                rects[to] = rect;
            else {
                if ((NSUInteger)CFDataGetLength(data) / sizeof(NSRect) == *count)
                    CFDataAppendBytes(data, (const UInt8 *)&rect, sizeof(NSRect));
                else
                    rects[*count] = rect;
                to = *count;
            }
            *count = to + 1;
            return YES;
        }
        NSRect r = rects[from];
        CGFloat right = NSMaxX(rect) - RECT_TOLERANCE;
        if (right <= r.origin.x || NSMaxX(r) <= rect.origin.x + RECT_TOLERANCE ||
            NSMaxY(rect) - RECT_TOLERANCE <= r.origin.y || NSMaxY(r) <= rect.origin.y + RECT_TOLERANCE) {
            // Apart: keep it.
            if (compacting)
                rects[to] = r;
            to++;
            continue;
        }
        // The parts of rect outside r: below, above, left and right of it.
        NSRect parts[4];
        NSUInteger n = 0;
        CGFloat bottom = rect.origin.y, top = NSMaxY(rect);
        if (rect.origin.y + RECT_TOLERANCE < r.origin.y) {
            parts[n++] = NSMakeRect(rect.origin.x, rect.origin.y, rect.size.width, r.origin.y - rect.origin.y);
            bottom = r.origin.y;
        }
        if (NSMaxY(r) < top - RECT_TOLERANCE) {
            parts[n++] = NSMakeRect(rect.origin.x, NSMaxY(r), rect.size.width, top - NSMaxY(r));
            top = NSMaxY(r);
        }
        if (rect.origin.x + RECT_TOLERANCE < r.origin.x)
            parts[n++] = NSMakeRect(rect.origin.x, bottom, r.origin.x - rect.origin.x, top - bottom);
        if (NSMaxX(r) < right)
            parts[n++] = NSMakeRect(NSMaxX(r), bottom, NSMaxX(rect) - NSMaxX(r), top - bottom);
        if (n == 0)
            // Inside r.
            return NO;
        if (n == 4) {
            // r is inside rect: drop it.
            compacting = YES;
            continue;
        }
        if (compacting)
            rects[to] = r;
        NSUInteger next = to + 1;
        from++;
        BOOL added = NO;
        for (NSUInteger i = 0; i < n; i++) {
            if (addRect(count, data, from, next, parts[i])) {
                added = YES;
                compacting = NO;
                from = next;
            }
        }
        rects = (NSRect *)CFDataGetMutableBytePtr(data);
        if (!compacting)
            return added;
        // Close the gap the dropped rects left.
        NSUInteger last = *count;
        if (last - 1 < from || from <= next)
            return added;
        for (NSUInteger src = last - 1, dst = to + 2;; src--, dst++) {
            rects[dst] = rects[src];
            if (src - 1 < from || dst + 1 >= from)
                break;
        }
        return added;
    }
}

static void autodisplayObserverCallBack(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *view)
{
    [(NSEView *)view NSEView_autodisplayOpenGLSurfaceByEventLoop];
}

static CVReturn autodisplayDisplayLinkCallBack(CVDisplayLinkRef link, const CVTimeStamp *now,
                                               const CVTimeStamp *outputTime, CVOptionFlags flagsIn,
                                               CVOptionFlags *flagsOut, void *view)
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    [(NSEView *)view displayOpenGLSurfaceIfNeeded];
    [pool release];
    return kCVReturnSuccess;
}

static void releaseQuartzLayer(struct __NSEViewQuartzLayer *layer)
{
    [layer->f2 release];
    CGContextRelease(layer->f1);
    free(layer->f0);
    CFAllocatorDeallocate(kCFAllocatorDefault, layer);
}

@implementation NSEView

+ (id)createDefaultOpenGLContext
{
    // Multisampled (6 samples) if it can be, else plain.
    NSOpenGLPixelFormatAttribute attributes[] = {
        NSOpenGLPFAWindow, NSOpenGLPFAAccelerated, NSOpenGLPFASampleBuffers, 1, NSOpenGLPFASamples, 6, 0,
        NSOpenGLPFAWindow, NSOpenGLPFAAccelerated, 0, 0
    };
    return [[NSEOpenGLContext contextWithFormatAttributesSequence:(unsigned int *)attributes
                                                    shareCategory:NSEDefaultOpenGLContextShareCategory] retain];
}

- (BOOL)isOpenGLSurfaceDisplayed
{
    return _isOpenGLSurfaceDisplayed;
}

- (BOOL)needsToDrawOpenGLSurfaceRect:(NSRect)aRect
{
    if (NSIsEmptyRect(aRect))
        return NO;
    NSRect r = [self convertRect:aRect toView:nil];
    CGFloat right = NSMaxX(r) - RECT_TOLERANCE, top = NSMaxY(r) - RECT_TOLERANCE;
    DrawingInfo *info = _openGLDrawingInfo;
    if (!(info->f4.origin.x < right && r.origin.x + RECT_TOLERANCE < NSMaxX(info->f4) &&
          info->f4.origin.y < top && r.origin.y + RECT_TOLERANCE < NSMaxY(info->f4)))
        return NO;
    for (unsigned int i = 0; i < info->f5; i++) {
        CGRect d = info->f6[i];
        if (d.origin.x < right && r.origin.x + RECT_TOLERANCE < CGRectGetMaxX(d) && d.origin.y < top &&
            r.origin.y + RECT_TOLERANCE < CGRectGetMaxY(d))
            return YES;
    }
    return NO;
}

- (void)getOpenGLSurfaceRectsBeingDrawn:(NSRect **)aDrawn count:(int *)aCount
{
    DrawingInfo *info = _openGLDrawingInfo;
    if (!info->f11) {
        if (info->f5 == 1) {
            *aDrawn = &info->f10;
            *aCount = 1;
            return;
        }
        info->f11 = CFDataCreateMutable(kCFAllocatorDefault, 0);
        if (info->f11) {
            // The rects drawn are in the window: bring them to the view.
            unsigned int count = info->f5;
            CGRect *rects = info->f6;
            CGAffineTransform t = CGAffineTransformInvert(info->f0);
            if (fabs(t.a) < 0.9999999 || 1.0000001 < fabs(t.a) || fabs(t.d) < 0.9999999 || 1.0000001 < fabs(t.d) ||
                t.b < -1e-07 || 1e-07 < t.b || t.c < -1e-07 || 1e-07 < t.c) {
                // Scaled or rotated: their bounding boxes, without overlaps.
                NSUInteger added = 0;
                for (unsigned int i = 0; i < count; i++) {
                    CGRect d = rects[i];
                    CGPoint corners[4] = {
                        d.origin, { CGRectGetMaxX(d), d.origin.y }, { CGRectGetMaxX(d), CGRectGetMaxY(d) },
                        { d.origin.x, CGRectGetMaxY(d) }
                    };
                    CGFloat minX = INFINITY, minY = INFINITY, maxX = -INFINITY, maxY = -INFINITY;
                    for (int k = 0; k < 4; k++) {
                        CGPoint p = CGPointApplyAffineTransform(corners[k], t);
                        minX = MIN(minX, p.x);
                        maxX = MAX(maxX, p.x);
                        minY = MIN(minY, p.y);
                        maxY = MAX(maxY, p.y);
                    }
                    addRect(&added, info->f11, 0, 0, NSMakeRect(minX, minY, maxX - minX, maxY - minY));
                }
                CFDataSetLength(info->f11, added * sizeof(NSRect));
            }
            else {
                // Moved and maybe flipped.
                CFDataSetLength(info->f11, count * sizeof(NSRect));
                NSRect *out = (NSRect *)CFDataGetMutableBytePtr(info->f11);
                for (unsigned int i = 0; i < count; i++) {
                    CGRect d = rects[i];
                    out[i].origin.x = t.a <= 0 ? t.tx - CGRectGetMaxX(d) : d.origin.x + t.tx;
                    out[i].origin.y = t.d <= 0 ? t.ty - CGRectGetMaxY(d) : d.origin.y + t.ty;
                    out[i].size = d.size;
                }
            }
        }
    }
    if (!info->f11) {
        *aDrawn = NULL;
        *aCount = 0;
    }
    else {
        *aDrawn = (NSRect *)CFDataGetBytePtr(info->f11);
        *aCount = (int)(CFDataGetLength(info->f11) / sizeof(NSRect));
    }
}

- (void)clearQuartzSurfaceRect:(NSRect)aRect
{
    NSRectFillUsingOperation(aRect, NSCompositingOperationClear);
}

- (void)drawRect:(NSRect)aRect
{
    GLint order = 1;
    _isOpenGLSurfaceDisplayed = 0;
    if (_isOpenGLSurfaceEnabled) {
        NSRect viewport = CGRectNull;
        NSInteger validness = [self NSEView_openGLSurfaceValidnessWithViewportRect:&viewport];
        if (validness != 0) {
            [[self window] disableScreenUpdatesUntilFlush];
            if (NSIsEmptyRect(viewport))
                goto quartz;
            NSInteger displayed = validness == 1 ? [self NSEView_displayOpenGLSurfaceAsNeeded]
                                                 : [self NSEView_displayOpenGLSurface];
            if (displayed != 1) {
                if (displayed == 0 && _isQuartzBackingEnabled) {
                    // Draw it with Quartz now if this drawing covers the
                    // surface, else soon.
                    NSRect bounds = [self openGLSurfaceBounds];
                    CGAffineTransform t = CGAffineTransformInvert([self NSE_affineTransformToView:nil]);
                    CGFloat tolerance = fmin(hypot(t.a, t.b), hypot(t.c, t.d)) * 0.5 * 0.00390625;
                    if (aRect.origin.x <= bounds.origin.x + tolerance && aRect.origin.y <= bounds.origin.y + tolerance &&
                        NSMaxX(bounds) - tolerance <= NSMaxX(aRect) && NSMaxY(bounds) - tolerance <= NSMaxY(aRect))
                        [self disableOpenGLSurfaceDetachingImmediately:NO];
                    else
                        [self NSEView_scheduleFallBackToQuartz];
                }
                goto quartz;
            }
        }
        if (_isOpenGLContextAssociated) {
            [_openGLContext getValues:&order forParameter:NSOpenGLContextParameterSurfaceOrder];
            if (order == -1)
                // The surface is below the window: let it show through.
                [self clearQuartzSurfaceRect:NSIntersectionRect([self openGLSurfaceBounds], aRect)];
            _isOpenGLSurfaceDisplayed = 1;
        }
    }
quartz:
    if (!_isOpenGLSurfaceEnabled && _isOpenGLContextAssociated) {
        [_openGLLock lock];
        if (_isOpenGLContextAssociated) {
            [[self window] disableScreenUpdatesUntilFlush];
            [self disassociateOpenGLContext];
        }
        [_openGLLock unlock];
    }
    if (NSIsEmptyRect(aRect))
        return;
    if (_isOpenGLSurfaceDisplayed && order != -1 && [self isOpenGLSurfaceOpaque])
        return;
    if (!_isObservingWindowDidChangeScreenProfileNotification) {
        if (![self NSEView_proxy])
            return;
        [[NSNotificationCenter defaultCenter] addObserver:_viewProxy
                                                 selector:@selector(NSEView_windowDidChangeScreenProfile:)
                                                     name:NSWindowDidChangeScreenProfileNotification
                                                   object:[self window]];
        _isObservingWindowDidChangeScreenProfileNotification = 1;
    }
    if (![self colorSyncProfile] || ![self colorSpace])
        return;
    CGContextRef port = [[NSGraphicsContext currentContext] CGContext];
    CFTypeRef profile = CGEContextGetAttachmentForKey(port, (CFStringRef)kCGEContextColorSyncProfileAttachmentKey);
    if (profile)
        CFRetain(profile);
    CGEContextSetAttachmentForKey(port, (CFStringRef)kCGEContextColorSyncProfileAttachmentKey, _colorSyncProfile);
    CFTypeRef space = CGEContextGetAttachmentForKey(port, (CFStringRef)kCGEContextColorSpaceAttachmentKey);
    if (space)
        CFRetain(space);
    CGEContextSetAttachmentForKey(port, (CFStringRef)kCGEContextColorSpaceAttachmentKey, _colorSpace);
    [self drawQuartzSurfaceRect:aRect];
    CGEContextSetAttachmentForKey(port, (CFStringRef)kCGEContextColorSpaceAttachmentKey, space);
    if (space)
        CFRelease(space);
    CGEContextSetAttachmentForKey(port, (CFStringRef)kCGEContextColorSyncProfileAttachmentKey, profile);
    if (profile)
        CFRelease(profile);
}

- (void)drawQuartzSurfaceRect:(NSRect)aRect
{
}

// NSEOpenGLCGContextDestination: GL drawing in the middle of Quartz drawing
// to the surface. What was drawn with Quartz so far goes to the surface first.
- (id)flushCGContext
{
    DrawingInfo *info = _openGLDrawingInfo;
    [self NSEView_flushQuartzTexture];
    CGAffineTransform ctm = CGContextGetCTM(_quartzLayer->f1);
    ctm.ty += info->f4.origin.y;
    ctm.tx += info->f4.origin.x;
    CGLContextObj cgl_ctx = _coreGLContext;
    glMatrixMode(GL_MODELVIEW);
    loadAffineMatrix(cgl_ctx, ctm);
    if (info->f14) {
        glDeleteTextures(1, &info->f14);
        info->f14 = 0;
    }
    else if (info->f15) {
        glDeleteTextures(info->f16, info->f15);
        memset(info->f15, 0, info->f16 * sizeof(GLuint));
    }
    clearBitmapRects(_quartzLayer->f0, CGBitmapContextGetHeight(_quartzLayer->f1),
                     CGBitmapContextGetBytesPerRow(_quartzLayer->f1), info->f13->rects, info->f5);
    [info->f12 makeCurrentContext];
    return info->f12;
}

- (id)destinationOpenGLContext
{
    return _openGLDrawingInfo->f12;
}

- (BOOL)drawOpenGLSurfaceQuartzTextureRect:(NSRect)aRect
{
    return YES;
}

// Draws the surface: Quartz drawing (drawOpenGLSurfaceQuartzTextureRect:) to
// a bitmap, then into the surface as textures.
- (BOOL)drawOpenGLSurfaceRect:(NSRect)aRect
{
    DrawingInfo *info = _openGLDrawingInfo;
    QuartzTextureInfo texture = { 0 };
    struct CGEBitmapRect rects[4];
    BOOL drawn = NO;
    CGLContextObj cgl_ctx = _coreGLContext;

    if (!_isTextureRectangleExtensionPresenceChecked) {
        const GLubyte *extensions = glGetString(GL_EXTENSIONS);
        if (!extensions)
            return NO;
        _isTextureRectangleExtensionPresent = gluCheckExtension((const GLubyte *)"GL_EXT_texture_rectangle", extensions) & 1;
        _isTextureRectangleExtensionPresenceChecked = 1;
    }
    texture.target = _isTextureRectangleExtensionPresent ? GL_TEXTURE_RECTANGLE_EXT : GL_TEXTURE_2D;
    GLint maxSize = 0;
    glGetIntegerv(_isTextureRectangleExtensionPresent ? GL_MAX_RECTANGLE_TEXTURE_SIZE_EXT : GL_MAX_TEXTURE_SIZE, &maxSize);
    CGColorSpaceRef colorSpace;
    if (maxSize == 0 || !(colorSpace = [_openGLContext CGColorSpace]))
        return NO;
    texture.width = lround(info->f4.size.width);
    texture.height = lround(info->f4.size.height);

    // The bitmap: big enough, in the context's color space.
    if (_quartzLayer && (CGBitmapContextGetWidth(_quartzLayer->f1) < texture.width ||
                         CGBitmapContextGetHeight(_quartzLayer->f1) < texture.height)) {
        releaseQuartzLayer(_quartzLayer);
        _quartzLayer = NULL;
    }
    if (!_quartzLayer) {
        struct __NSEViewQuartzLayer *layer = CFAllocatorAllocate(kCFAllocatorDefault, sizeof(*layer), 0);
        if (layer) {
            NSUInteger width, height;
            if (texture.target == GL_TEXTURE_2D && texture.width < (NSUInteger)maxSize)
                width = powerOfTwoAtLeast(texture.width, 8);
            else
                width = texture.width == (NSUInteger)maxSize ? texture.width : (texture.width + 7) & ~(NSUInteger)7;
            if (texture.target == GL_TEXTURE_2D && texture.height < (NSUInteger)maxSize)
                height = powerOfTwoAtLeast(texture.height, 1);
            else
                height = texture.height;
            layer->f0 = valloc(height * width * 4);
            if (layer->f0) {
                layer->f1 = CGBitmapContextCreate(layer->f0, width, height, 8, width * 4, colorSpace,
                                                  kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Little);
                if (layer->f1)
                    layer->f2 = nil;
                else {
                    free(layer->f0);
                    CFAllocatorDeallocate(kCFAllocatorDefault, layer);
                    layer = NULL;
                }
            }
            else {
                CFAllocatorDeallocate(kCFAllocatorDefault, layer);
                layer = NULL;
            }
        }
        _quartzLayer = layer;
        if (!_quartzLayer)
            return NO;
    }
    else if (!CFEqual(colorSpace, CGBitmapContextGetColorSpace(_quartzLayer->f1))) {
        struct __NSEViewQuartzLayer *layer = _quartzLayer;
        CGContextRef context = CGBitmapContextCreate(layer->f0, CGBitmapContextGetWidth(layer->f1),
                                                     CGBitmapContextGetHeight(layer->f1), 8,
                                                     CGBitmapContextGetBytesPerRow(layer->f1), colorSpace,
                                                     kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Little);
        if (!context)
            return NO;
        [layer->f2 release];
        layer->f2 = nil;
        CGContextRelease(layer->f1);
        layer->f1 = context;
    }

    // The textures are made in tiles up to the maximum size (powers of two
    // that fit the bitmap for GL_TEXTURE_2D).
    size_t bitmapHeight = CGBitmapContextGetHeight(_quartzLayer->f1);
    texture.maxTextureWidth = maxSize;
    texture.maxTextureHeight = maxSize;
    if (texture.target == GL_TEXTURE_2D) {
        size_t bitmapWidth = CGBitmapContextGetWidth(_quartzLayer->f1);
        while (bitmapWidth < texture.maxTextureWidth)
            texture.maxTextureWidth >>= 1;
        while (bitmapHeight < texture.maxTextureHeight)
            texture.maxTextureHeight >>= 1;
    }
    info->f16 = (int)(((texture.width - 1 + texture.maxTextureWidth) / texture.maxTextureWidth) *
                      ((texture.height - 1 + texture.maxTextureHeight) / texture.maxTextureHeight));
    if (info->f16 > 1 && !info->f15) {
        info->f15 = CFAllocatorAllocate(kCFAllocatorDefault, info->f16 * sizeof(GLuint), 0);
        if (!info->f15)
            return NO;
    }
    texture.rects = info->f5 < 5 ? rects : CFAllocatorAllocate(kCFAllocatorDefault, info->f5 * sizeof(*rects), 0);
    if (!texture.rects)
        return NO;
    size_t bytesPerRow = CGBitmapContextGetBytesPerRow(_quartzLayer->f1);
    for (unsigned int i = 0; i < info->f5; i++) {
        CGRect d = info->f6[i];
        texture.rects[i].x = (int)lround(d.origin.x - info->f4.origin.x);
        texture.rects[i].y = (int)lround(d.origin.y - info->f4.origin.y);
        texture.rects[i].width = (unsigned int)lround(d.size.width);
        texture.rects[i].height = (unsigned int)lround(d.size.height);
    }
    if (![self isInitialQuartzTextureOpaque])
        clearBitmapRects(_quartzLayer->f0, bitmapHeight, bytesPerRow, texture.rects, info->f5);

    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    if (pool) {
        info->f13 = &texture;
        CGContextRef context = _quartzLayer->f1;
        BOOL flipped = [self isFlipped];
        struct __NSEViewQuartzLayer *layer = _quartzLayer;
        if (layer->f2 && [layer->f2 isFlipped] != flipped) {
            [layer->f2 release];
            layer->f2 = nil;
        }
        if (!layer->f2)
            layer->f2 = [[NSGraphicsContext graphicsContextWithCGContext:context flipped:flipped] retain];
        NSGraphicsContext *graphicsContext = layer->f2;
        if (graphicsContext) {
            NSGraphicsContext *previous = [[NSGraphicsContext currentContext] retain];
            [NSGraphicsContext setCurrentContext:graphicsContext];
            [graphicsContext saveGraphicsState];
            CFStringRef profileKey = (CFStringRef)kCGEContextColorSyncProfileAttachmentKey;
            CFStringRef spaceKey = (CFStringRef)kCGEContextColorSpaceAttachmentKey;
            CFTypeRef profile = CGEContextGetAttachmentForKey(context, profileKey);
            if (profile)
                CFRetain(profile);
            CGEContextSetAttachmentForKey(context, profileKey, [_openGLContext colorSyncProfile]);
            CFTypeRef space = CGEContextGetAttachmentForKey(context, spaceKey);
            if (space)
                CFRetain(space);
            CGEContextSetAttachmentForKey(context, spaceKey, colorSpace);
            CGEContextSetDestination(context, (CFStringRef)NSEOpenGLCGContextDestination, self);
            CGAffineTransform t = info->f0;
            if ([self wantsDefaultClipping]) {
                CGContextTranslateCTM(context, -info->f4.origin.x, -info->f4.origin.y);
                CGContextClipToRects(context, info->f6, info->f5);
            }
            else {
                t.tx -= info->f4.origin.x;
                t.ty -= info->f4.origin.y;
            }
            CGContextConcatCTM(context, t);
            drawn = [self drawOpenGLSurfaceQuartzTextureRect:aRect];
            CGEContextSetDestination(context, (CFStringRef)NSEOpenGLCGContextDestination, NULL);
            CGEContextSetAttachmentForKey(context, spaceKey, space);
            if (space)
                CFRelease(space);
            CGEContextSetAttachmentForKey(context, profileKey, profile);
            if (profile)
                CFRelease(profile);
            [graphicsContext restoreGraphicsState];
            [NSGraphicsContext setCurrentContext:previous];
            [previous release];
        }
        [self NSEView_flushQuartzTexture];
        info->f13 = NULL;
        [pool release];
        cgl_ctx = _coreGLContext;
        glMatrixMode(GL_MODELVIEW);
        loadAffineMatrix(cgl_ctx, info->f0);
    }
    if (texture.rects != rects)
        CFAllocatorDeallocate(kCFAllocatorDefault, texture.rects);
    return drawn;
}

// Draws what's in the Quartz bitmap into the surface: one texture, or tiles.
- (void)NSEView_flushQuartzTexture
{
    DrawingInfo *info = _openGLDrawingInfo;
    QuartzTextureInfo *texture = info->f13;
    size_t bitmapWidth = CGBitmapContextGetWidth(_quartzLayer->f1);
    size_t bitmapHeight = CGBitmapContextGetHeight(_quartzLayer->f1);
    size_t bytesPerRow = CGBitmapContextGetBytesPerRow(_quartzLayer->f1);
    char *data = _quartzLayer->f0;
    CGLContextObj cgl_ctx = _coreGLContext;

    if (!_isAGPTexturingChecked) {
        // Shared (AGP) texture storage is wrong on GeForce2 MX and GeForce4 MX.
        BOOL correct = YES;
        const char *vendor = (const char *)glGetString(GL_VENDOR);
        if (vendor && !strcmp(vendor, "NVIDIA Corporation")) {
            const char *renderer = (const char *)glGetString(GL_RENDERER);
            if (renderer && (!strcmp(renderer, "NVIDIA GeForce2 MX OpenGL Engine") ||
                             !strcmp(renderer, "NVIDIA GeForce4 MX OpenGL Engine")))
                correct = NO;
        }
        _isAGPTexturingCorrect = correct;
        _isAGPTexturingChecked = 1;
    }

    // The rects are in window coordinates (the projection's); the texture
    // matrix maps bitmap coordinates to the texture.
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    GLfloat textureMatrix[16];
    glGetFloatv(GL_TEXTURE_MATRIX, textureMatrix);
    glMatrixMode(GL_TEXTURE);

    GLint rowLength, alignment;
    GLboolean clientStorage;
    glGetIntegerv(GL_UNPACK_ROW_LENGTH, &rowLength);
    glGetIntegerv(GL_UNPACK_ALIGNMENT, &alignment);
    glGetBooleanv(GL_UNPACK_CLIENT_STORAGE_APPLE, &clientStorage);
    if ((size_t)rowLength != bitmapWidth)
        glPixelStorei(GL_UNPACK_ROW_LENGTH, (GLint)bitmapWidth);
    if (alignment != 4)
        glPixelStorei(GL_UNPACK_ALIGNMENT, 4);
    if (!clientStorage)
        glPixelStorei(GL_UNPACK_CLIENT_STORAGE_APPLE, GL_TRUE);

    // Premultiplied alpha over what's there.
    GLboolean blend = glIsEnabled(GL_BLEND);
    GLint equationRGB, equationAlpha, sourceRGB, destinationRGB, sourceAlpha, destinationAlpha;
    glGetIntegerv(GL_BLEND_EQUATION_RGB, &equationRGB);
    glGetIntegerv(GL_BLEND_EQUATION_ALPHA, &equationAlpha);
    glGetIntegerv(GL_BLEND_SRC_RGB, &sourceRGB);
    glGetIntegerv(GL_BLEND_DST_RGB, &destinationRGB);
    glGetIntegerv(GL_BLEND_SRC_ALPHA, &sourceAlpha);
    glGetIntegerv(GL_BLEND_DST_ALPHA, &destinationAlpha);
    BOOL equationSet = equationRGB != GL_FUNC_ADD || equationAlpha != GL_FUNC_ADD;
    BOOL functionSet = sourceRGB != GL_ONE || destinationRGB != GL_ONE_MINUS_SRC_ALPHA || sourceAlpha != GL_ONE ||
                       destinationAlpha != GL_ONE_MINUS_SRC_ALPHA;
    if (equationSet)
        glBlendEquationSeparateEXT(GL_FUNC_ADD, GL_FUNC_ADD);
    if (functionSet)
        glBlendFuncSeparate(GL_ONE, GL_ONE_MINUS_SRC_ALPHA, GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
    if (!blend)
        glEnable(GL_BLEND);
    GLboolean targetEnabled = glIsEnabled(texture->target);
    if (!targetEnabled)
        glEnable(texture->target);

    if (info->f16 == 1) {
        NSUInteger width = texture->width, height = texture->height;
        if (texture->target == GL_TEXTURE_2D) {
            width = powerOfTwoAtLeast(width, 1);
            height = powerOfTwoAtLeast(height, 1);
        }
        glGenTextures(1, &info->f14);
        if (info->f14) {
            glBindTexture(texture->target, info->f14);
            if (_isAGPTexturingCorrect)
                glTexParameteri(texture->target, GL_TEXTURE_STORAGE_HINT_APPLE, GL_STORAGE_SHARED_APPLE);
            glTexParameteri(texture->target, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
            glTexParameteri(texture->target, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
            glTexImage2D(texture->target, 0, GL_RGBA, (GLsizei)width, (GLsizei)height, 0, GL_BGRA,
                         GL_UNSIGNED_INT_8_8_8_8_REV, data + (bitmapHeight - height) * bytesPerRow);
            GLfloat m[16] = { 1, 0, 0, 0, 0, -1, 0, 0, 0, 0, 1, 0, 0, height, 0, 1 };
            if (texture->target == GL_TEXTURE_2D) {
                m[0] = width ? 1.0f / width : 1;
                m[5] = height ? -1.0f / height : -1;
                m[13] = 1;
            }
            glLoadMatrixf(m);
            glBegin(GL_QUADS);
            for (unsigned int i = 0; i < info->f5; i++) {
                struct CGEBitmapRect r = texture->rects[i];
                CGRect d = info->f6[i];
                glTexCoord2i(r.x, r.y);
                glVertex2d(d.origin.x, d.origin.y);
                glTexCoord2i(r.x, r.y + r.height);
                glVertex2d(d.origin.x, CGRectGetMaxY(d));
                glTexCoord2i(r.x + r.width, r.y + r.height);
                glVertex2d(CGRectGetMaxX(d), CGRectGetMaxY(d));
                glTexCoord2i(r.x + r.width, r.y);
                glVertex2d(CGRectGetMaxX(d), d.origin.y);
            }
            glEnd();
        }
    }
    else {
        // Tiles, bottom to top, left to right.
        glGenTextures(info->f16, info->f15);
        GLuint *name = info->f15;
        NSUInteger tileY = 0;
        for (NSUInteger rowsLeft = texture->height; rowsLeft; ) {
            NSUInteger tileHeight = MIN(rowsLeft, texture->maxTextureHeight);
            NSUInteger textureHeight = tileHeight, textureY = tileY;
            if (texture->target == GL_TEXTURE_2D && tileHeight != texture->maxTextureHeight) {
                textureHeight = powerOfTwoAtLeast(tileHeight, 1);
                if (bitmapHeight < textureHeight + tileY)
                    textureY = bitmapHeight - textureHeight;
            }
            NSUInteger tileX = 0;
            for (NSUInteger columnsLeft = texture->width; columnsLeft; ) {
                NSUInteger tileWidth = MIN(columnsLeft, texture->maxTextureWidth);
                NSUInteger textureWidth = tileWidth, textureX = tileX;
                if (texture->target == GL_TEXTURE_2D && tileWidth != texture->maxTextureWidth) {
                    textureWidth = powerOfTwoAtLeast(tileWidth, 1);
                    if (bitmapWidth < textureWidth + tileX)
                        textureX = bitmapWidth - textureWidth;
                }
                CGFloat left = info->f4.origin.x + tileX, bottom = info->f4.origin.y + tileY;
                CGFloat right = left + tileWidth, top = bottom + tileHeight;
                glBindTexture(texture->target, *name++);
                if (_isAGPTexturingCorrect)
                    glTexParameteri(texture->target, GL_TEXTURE_STORAGE_HINT_APPLE, GL_STORAGE_SHARED_APPLE);
                glTexParameteri(texture->target, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
                glTexParameteri(texture->target, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
                glTexImage2D(texture->target, 0, GL_RGBA, (GLsizei)textureWidth, (GLsizei)textureHeight, 0, GL_BGRA,
                             GL_UNSIGNED_INT_8_8_8_8_REV,
                             data + (bitmapHeight - textureHeight - textureY) * bytesPerRow + textureX * 4);
                GLfloat m[16] = { 1, 0, 0, 0, 0, -1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1 };
                if (texture->target == GL_TEXTURE_2D) {
                    m[0] = textureWidth ? 1.0f / textureWidth : 1;
                    m[5] = textureHeight ? -1.0f / textureHeight : -1;
                    m[12] = -(GLfloat)textureX * m[0];
                    m[13] = 1 - m[5] * textureY;
                }
                else {
                    m[12] = -(GLfloat)textureX;
                    m[13] = textureHeight + (GLfloat)textureY;
                }
                glLoadMatrixf(m);
                glBegin(GL_QUADS);
                for (unsigned int i = 0; i < info->f5; i++) {
                    // The part of the rect in this tile.
                    struct CGEBitmapRect r = texture->rects[i];
                    long x0 = r.x, y0 = r.y, x1 = r.x + (long)r.width, y1 = r.y + (long)r.height;
                    long w = 0, h = 0;
                    if ((long)tileX < x1 && x0 < (long)(tileX + tileWidth) && (long)tileY < y1 &&
                        y0 < (long)(tileY + tileHeight)) {
                        x0 = MAX(x0, (long)tileX);
                        x1 = MIN(x1, (long)(tileX + tileWidth));
                        y0 = MAX(y0, (long)tileY);
                        y1 = MIN(y1, (long)(tileY + tileHeight));
                        w = x1 - x0;
                        h = y1 - y0;
                    }
                    if (!w || !h)
                        continue;
                    CGRect d = CGRectIntersection(info->f6[i], CGRectMake(left, bottom, right - left, top - bottom));
                    glTexCoord2i((GLint)x0, (GLint)y0);
                    glVertex2d(d.origin.x, d.origin.y);
                    glTexCoord2i((GLint)x0, (GLint)(y0 + h));
                    glVertex2d(d.origin.x, CGRectGetMaxY(d));
                    glTexCoord2i((GLint)(x0 + w), (GLint)(y0 + h));
                    glVertex2d(CGRectGetMaxX(d), CGRectGetMaxY(d));
                    glTexCoord2i((GLint)(x0 + w), (GLint)y0);
                    glVertex2d(CGRectGetMaxX(d), d.origin.y);
                }
                glEnd();
                columnsLeft -= tileWidth;
                tileX += tileWidth;
            }
            rowsLeft -= tileHeight;
            tileY += tileHeight;
        }
    }

    glLoadMatrixf(textureMatrix);
    if (!targetEnabled)
        glDisable(texture->target);
    if (!blend)
        glDisable(GL_BLEND);
    if (equationSet)
        glBlendEquationSeparateEXT(equationRGB, equationAlpha);
    if (functionSet)
        glBlendFuncSeparate(sourceRGB, destinationRGB, sourceAlpha, destinationAlpha);
    if (!clientStorage)
        glPixelStorei(GL_UNPACK_CLIENT_STORAGE_APPLE, GL_FALSE);
    if ((size_t)rowLength != bitmapWidth)
        glPixelStorei(GL_UNPACK_ROW_LENGTH, rowLength);
    if (alignment != 4)
        glPixelStorei(GL_UNPACK_ALIGNMENT, alignment);
}

- (void)setCanDrawOpenGLSurfaceConcurrently:(BOOL)aConcurrently
{
    NSLog(@"-= Concurrent OpenGL surface drawing is not implemented yet. =-");
}

- (BOOL)canDrawOpenGLSurfaceConcurrently
{
    return _canDrawOpenGLSurfaceConcurrently;
}

- (BOOL)shouldDisplayOpenGLSurface
{
    return YES;
}

- (BOOL)displayOpenGLSurfaceIfNeeded
{
    if (_isOpenGLSurfaceEnabled) {
        NSRect viewport = CGRectNull;
        if ([self NSEView_isOpenGLSurfaceValidWithViewportRect:&viewport])
            return YES;
        if (NSIsEmptyRect(viewport))
            return NO;
        NSInteger displayed = [self NSEView_displayOpenGLSurfaceAsNeeded];
        if (displayed == -1)
            return NO;
        if (displayed == 1)
            return YES;
    }
    if (!_isQuartzBackingEnabled)
        return NO;
    if ([[NSThread currentThread] isMainThread])
        [self NSEView_fallBackToQuartz];
    else
        [self performSelectorOnMainThread:@selector(NSEView_delayedFallBackToQuartz) withObject:nil waitUntilDone:NO];
    return NO;
}

- (void)NSEView_autodisplayOpenGLSurfaceByEventLoop
{
    NSRect viewport = CGRectNull;
    if ([self NSEView_isOpenGLSurfaceValidWithViewportRect:&viewport] || NSIsEmptyRect(viewport))
        return;
    if (NSAppKitVersionNumber >= 949) {
        // The window will display anyway: draw with it.
        if ([self needsDisplay])
            return;
        NSWindow *window = [self window];
        if ([window viewsNeedDisplay])
            [window disableScreenUpdatesUntilFlush];
    }
    if ([self NSEView_displayOpenGLSurfaceAsNeeded] == 0 && _isQuartzBackingEnabled)
        [self NSEView_delayedFallBackToQuartz];
}

// Draws the invalid parts of the surface. 1 if drawn, 0 if not, -1 if there's
// nothing to draw.
- (NSInteger)NSEView_displayOpenGLSurfaceAsNeeded
{
    DrawingInfo info;
    memset(&info, 0, sizeof(info));
    NSInteger result = 0;
    [_openGLLock lock];
    if (!_isOpenGLSurfaceEnabled)
        goto unlock;
    info.f1 = NSIntegralRect([self convertRect:[self openGLSurfaceBounds] toView:nil]);
    info.f2 = [self NSEView_openGLSurfaceViewportBounds];
    info.f3 = NSIntersectionRect(info.f1, info.f2);
    if (NSIsEmptyRect(info.f3)) {
        result = -1;
        goto unlock;
    }
    if (!_openGLInvalidationInfo)
        _isOpenGLSurfaceValid = 1;
    else {
        struct __NSEViewOpenGLSurfaceInvalidationInfo *invalidation = _openGLInvalidationInfo;
        if (pthread_mutex_lock(&invalidation->f0) != 0)
            goto unlock;
        NSUInteger count = invalidation->f1;
        const NSRect *invalid = count ? (const NSRect *)CFDataGetBytePtr(invalidation->f2) : NULL;
        if (count == 1) {
            info.f4 = NSIntersectionRect(NSIntegralRect([self convertRect:invalid[0] toView:nil]), info.f3);
            if (NSIsEmptyRect(info.f4))
                result = -1;
            else {
                info.f5 = 1;
                info.f6 = &info.f4;
            }
        }
        else if (count > 128) {
            // Many: their bounds.
            for (NSUInteger i = 0; i < count; i++)
                info.f4 = NSUnionRect(info.f4, NSIntegralRect([self convertRect:invalid[i] toView:nil]));
            info.f4 = NSIntersectionRect(info.f4, info.f3);
            if (NSIsEmptyRect(info.f4))
                result = -1;
            else {
                info.f5 = 1;
                info.f6 = &info.f4;
            }
        }
        else if (count) {
            NSUInteger i;
            NSUInteger added = 0;
            for (i = 0; i < count; i++) {
                NSRect r = NSIntersectionRect(NSIntegralRect([self convertRect:invalid[i] toView:nil]), info.f3);
                if (NSIsEmptyRect(r))
                    continue;
                if (!info.f7 && !(info.f7 = CFDataCreateMutable(kCFAllocatorDefault, 0)))
                    break;
                addRect(&added, info.f7, 0, 0, r);
                info.f4 = NSUnionRect(info.f4, r);
            }
            if (info.f7) {
                info.f5 = (unsigned int)added;
                CFDataSetLength(info.f7, added * sizeof(NSRect));
                info.f6 = (CGRect *)CFDataGetBytePtr(info.f7);
            }
            else if (i == count)
                result = -1;
        }
        _isOpenGLSurfaceValid = 1;
        pthread_mutex_unlock(&invalidation->f0);
        if (!info.f6 && invalidation->f1)
            goto unlock;
    }
    if (info.f5 == 0) {
        // All of it.
        info.f4 = info.f3;
        info.f5 = 1;
        info.f6 = &info.f4;
    }
    info.f10 = [self convertRect:info.f4 fromView:nil];
    _openGLDrawingInfo = &info;
    result = [self NSEView_displayOpenGLSurfaceRect:info.f10];
    _openGLDrawingInfo = NULL;
unlock:
    [_openGLLock unlock];
    if (info.f7)
        CFRelease(info.f7);
    if (info.f11)
        CFRelease(info.f11);
    return result;
}

- (BOOL)displayOpenGLSurface
{
    if (_isOpenGLSurfaceEnabled) {
        NSInteger displayed = [self NSEView_displayOpenGLSurface];
        if (displayed == -1)
            return NO;
        if (displayed == 1)
            return YES;
    }
    if (_isQuartzBackingEnabled) {
        if ([[NSThread currentThread] isMainThread])
            [self NSEView_fallBackToQuartz];
        else
            [self performSelectorOnMainThread:@selector(NSEView_delayedFallBackToQuartz) withObject:nil
                                waitUntilDone:NO];
    }
    return NO;
}

// Draws all of the surface (see NSEView_displayOpenGLSurfaceAsNeeded).
- (NSInteger)NSEView_displayOpenGLSurface
{
    NSInteger result = 0;
    _isOpenGLSurfaceValid = 1;
    [_openGLLock lock];
    if (_isOpenGLSurfaceEnabled) {
        DrawingInfo info;
        memset(&info, 0, sizeof(info));
        info.f1 = NSIntegralRect([self convertRect:[self openGLSurfaceBounds] toView:nil]);
        info.f2 = [self NSEView_openGLSurfaceViewportBounds];
        info.f3 = NSIntersectionRect(info.f1, info.f2);
        if (NSIsEmptyRect(info.f3))
            result = -1;
        else {
            info.f4 = info.f3;
            info.f5 = 1;
            info.f6 = &info.f4;
            info.f10 = [self convertRect:info.f4 fromView:nil];
            _openGLDrawingInfo = &info;
            result = [self NSEView_displayOpenGLSurfaceRect:info.f10];
            _openGLDrawingInfo = NULL;
            if (info.f11)
                CFRelease(info.f11);
        }
    }
    [_openGLLock unlock];
    return result;
}

// Draws the part of the surface _openGLDrawingInfo describes (f1: the surface
// in the window, f2: the viewport bounds, f3: their intersection, f4 and the
// f5 rects f6: what to draw, f10: f4 in the view).
- (NSInteger)NSEView_displayOpenGLSurfaceRect:(NSRect)aRect
{
    DrawingInfo *info = _openGLDrawingInfo;
    struct CGEBitmapRect clipRects[4];
    NSInteger result;
    CGLContextObj cgl_ctx;

    if (![self shouldDisplayOpenGLSurface]) {
        result = -1;
        goto done;
    }
    if ((!_isOpenGLContextAssociated && ![self openGLContext]) || CGLLockContext(_coreGLContext) != kCGLNoError) {
        result = 0;
        goto done;
    }
    if (_isOpenGLContextAssociated && _isOpenGLContextUpdateQueried) {
        _isOpenGLContextUpdateQueried = 0;
        if ((_openGLRendererMinVideoMemory && [self NSEView_openGLRendererVideoMemory] < _openGLRendererMinVideoMemory) ||
            ![self NSEView_isOpenGLRendererAllowed])
            goto failed;
        [self updateOpenGLContext];
    }
    cgl_ctx = _coreGLContext;
    GLint maxDimensions[2] = { 0, 0 };
    glGetIntegerv(GL_MAX_VIEWPORT_DIMS, maxDimensions);
    GLint viewport[4] = {
        (GLint)lround(info->f3.origin.x - info->f2.origin.x), (GLint)lround(info->f3.origin.y - info->f2.origin.y),
        (GLint)lround(info->f3.size.width), (GLint)lround(info->f3.size.height)
    };
    if (maxDimensions[0] < viewport[2] || maxDimensions[1] < viewport[3] ||
        (!_isOpenGLContextAssociated && ![self associateOpenGLContext]))
        goto failed;

    if (!_isOpenGLFramebufferStabilityChecked) {
        // The framebuffer keeps its contents between frames, except on the
        // Radeon HD 2400 XT with AppKit 10.6.
        if (NSAppKitVersionNumber < 1138)
            _isOpenGLFramebufferStable = 1;
        else {
            const char *vendor = (const char *)glGetString(GL_VENDOR);
            const char *renderer;
            _isOpenGLFramebufferStable = !(vendor && !strcmp(vendor, "ATI Technologies Inc.") &&
                                           (renderer = (const char *)glGetString(GL_RENDERER)) &&
                                           !strcmp(renderer, "ATI Radeon HD 2400 XT OpenGL Engine"));
        }
        _isOpenGLFramebufferStabilityChecked = 1;
        if (_isOpenGLFramebufferStable && _openGLBufferTexture) {
            glDeleteTextures(1, &_openGLBufferTexture);
            _openGLBufferTexture = 0;
        }
    }
    GLint current[4];
    glGetIntegerv(GL_VIEWPORT, current);
    if (current[0] != viewport[0] || current[1] != viewport[1] || current[2] != viewport[2] || current[3] != viewport[3])
        [self changeOpenGLSurfaceViewportFrom:current to:viewport];
    GLint order = 1;
    [_openGLContext getValues:&order forParameter:NSOpenGLContextParameterSurfaceOrder];
    if (order == -1 && ![self isOpaque] && ![self isOpenGLSurfaceOpaque])
        NSLog(@"-= Non-opaque underlying OpenGL surface is not implemented yet. =-");

    // An unstable framebuffer gets the last frame back from a texture.
    BOOL restored = NO;
    if (_openGLBufferTexture) {
        glBindTexture(GL_TEXTURE_RECTANGLE_EXT, _openGLBufferTexture);
        GLint width = 0, height = 0;
        glGetTexLevelParameteriv(GL_TEXTURE_RECTANGLE_EXT, 0, GL_TEXTURE_WIDTH, &width);
        glGetTexLevelParameteriv(GL_TEXTURE_RECTANGLE_EXT, 0, GL_TEXTURE_HEIGHT, &height);
        if (width == viewport[2] && height == viewport[3]) {
            glMatrixMode(GL_PROJECTION);
            glLoadIdentity();
            glMatrixMode(GL_MODELVIEW);
            glLoadIdentity();
            GLboolean enabled = glIsEnabled(GL_TEXTURE_RECTANGLE_EXT);
            if (!enabled)
                glEnable(GL_TEXTURE_RECTANGLE_EXT);
            glBegin(GL_QUADS);
            glTexCoord2i(0, 0);
            glVertex2f(-1, -1);
            glTexCoord2i(0, viewport[3]);
            glVertex2f(-1, 1);
            glTexCoord2i(viewport[2], viewport[3]);
            glVertex2f(1, 1);
            glTexCoord2i(viewport[2], 0);
            glVertex2f(1, -1);
            glEnd();
            if (!enabled)
                glDisable(GL_TEXTURE_RECTANGLE_EXT);
            restored = YES;
        }
        glBindTexture(GL_TEXTURE_RECTANGLE_EXT, 0);
    }

    // Draw straight to the context when all of the viewport is drawn (or the
    // view doesn't want clipping), else through the framebuffer clipper.
    BOOL direct;
    NSOpenGLContext *previous = nil;
    CGRect *drawn = info->f6;
    if ((info->f5 == 1 && drawn->origin.x <= info->f3.origin.x + RECT_TOLERANCE &&
         drawn->origin.y <= info->f3.origin.y + RECT_TOLERANCE &&
         NSMaxX(info->f3) - RECT_TOLERANCE <= CGRectGetMaxX(*drawn) &&
         NSMaxY(info->f3) - RECT_TOLERANCE <= CGRectGetMaxY(*drawn)) ||
        ![self wantsDefaultOpenGLClipping]) {
        info->f12 = _openGLContext;
        previous = [[NSOpenGLContext currentContext] retain];
        if (previous != _openGLContext)
            [_openGLContext makeCurrentContext];
        direct = YES;
    }
    else {
        if (!_openGLFramebufferClipper &&
            !(_openGLFramebufferClipper = [[NSEOpenGLFramebufferClipper alloc] initWithOpenGLContext:_openGLContext]))
            goto failed;
        info->f9 = info->f5 < 5 ? clipRects : CFAllocatorAllocate(kCFAllocatorDefault, info->f5 * sizeof(*info->f9), 0);
        if (!info->f9)
            goto failed;
        for (unsigned int i = 0; i < info->f5; i++) {
            CGRect d = info->f6[i];
            info->f9[i].x = (int)lround(d.origin.x - info->f2.origin.x);
            info->f9[i].y = (int)lround(d.origin.y - info->f2.origin.y);
            info->f9[i].width = (unsigned int)lround(d.size.width);
            info->f9[i].height = (unsigned int)lround(d.size.height);
        }
        info->f8.x = (int)lround(info->f4.origin.x - info->f2.origin.x);
        info->f8.y = (int)lround(info->f4.origin.y - info->f2.origin.y);
        info->f8.width = (unsigned int)lround(info->f4.size.width);
        info->f8.height = (unsigned int)lround(info->f4.size.height);
        info->f12 = [_openGLFramebufferClipper lockOpenGLFocusWithClipBounds:info->f8 rects:info->f9 count:info->f5];
        if (!info->f12)
            goto failed;
        _coreGLContext = [info->f12 CGLContextObj];
        direct = NO;
    }

    // Window coordinates of the viewport map to it.
    cgl_ctx = _coreGLContext;
    GLfloat projection[16];
    [self getOpenGLSurfaceProjectionMatrix:projection forBounds:info->f1 viewportRect:info->f3];
    const GLfloat *posttransform = direct ? NULL : [_openGLFramebufferClipper projectionPosttransform];
    glMatrixMode(GL_PROJECTION);
    if (posttransform) {
        glLoadMatrixf(posttransform);
        glMultMatrixf(projection);
    }
    else
        glLoadMatrixf(projection);
    info->f0 = [self NSE_affineTransformToView:nil];
    glMatrixMode(GL_MODELVIEW);
    loadAffineMatrix(cgl_ctx, info->f0);
    BOOL didDraw = [self drawOpenGLSurfaceRect:aRect];
    result = didDraw ? 1 : 0;
    if (direct) {
        if ([NSOpenGLContext currentContext] == _openGLContext) {
            if (previous)
                [previous makeCurrentContext];
            else
                [NSOpenGLContext clearCurrentContext];
        }
        [previous release];
    }
    else {
        [_openGLFramebufferClipper unlockOpenGLFocus];
        _coreGLContext = [_openGLContext CGLContextObj];
    }
    cgl_ctx = _coreGLContext;
    if (info->f14)
        glDeleteTextures(1, &info->f14);
    else if (info->f15)
        glDeleteTextures(info->f16, info->f15);
    if (didDraw) {
        if (!_isOpenGLFramebufferStable &&
            (_openGLBufferTexture || (glGenTextures(1, &_openGLBufferTexture), _openGLBufferTexture))) {
            // Keep the frame for next time.
            glFlush();
            glBindTexture(GL_TEXTURE_RECTANGLE_EXT, _openGLBufferTexture);
            if (!restored)
                glCopyTexImage2D(GL_TEXTURE_RECTANGLE_EXT, 0, GL_RGB, viewport[0], viewport[1], viewport[2],
                                 viewport[3], 0);
            else if (direct)
                glCopyTexSubImage2D(GL_TEXTURE_RECTANGLE_EXT, 0, 0, 0, viewport[0], viewport[1], viewport[2],
                                    viewport[3]);
            else
                for (unsigned int i = 0; i < info->f5; i++) {
                    struct CGEBitmapRect r = info->f9[i];
                    glCopyTexSubImage2D(GL_TEXTURE_RECTANGLE_EXT, 0, r.x - viewport[0], r.y - viewport[1], r.x, r.y,
                                        r.width, r.height);
                }
            glBindTexture(GL_TEXTURE_RECTANGLE_EXT, 0);
        }
        [_openGLContext flush];
    }
    goto unlock;
failed:
    result = 0;
unlock:
    CGLUnlockContext(_coreGLContext);
done:
    if (_isOpenGLContextAssociated && (result == -1 || (result == 0 && !_isQuartzBackingEnabled)))
        [self disassociateOpenGLContext];
    if (info->f9 && info->f9 != clipRects)
        CFAllocatorDeallocate(kCFAllocatorDefault, info->f9);
    if (info->f15)
        CFAllocatorDeallocate(kCFAllocatorDefault, info->f15);
    return result;
}

- (BOOL)NSEView_isOpenGLSurfaceValidWithViewportRect:(NSRect *)aRect
{
    NSInteger validness = [self NSEView_openGLSurfaceValidnessWithViewportRect:aRect];
    if (validness == 0)
        return YES;
    if (validness == -1)
        [self NSEView_setNeedsDisplayOpenGLSurface];
    return NO;
}

// 0 if the surface is valid, 1 if parts need drawing, -1 if the viewport
// moved (all of it does). *aRect: the viewport.
- (NSInteger)NSEView_openGLSurfaceValidnessWithViewportRect:(NSRect *)aRect
{
    *aRect = NSIntersectionRect([self openGLSurfaceBounds], [self visibleRect]);
    OSSpinLockLock(&_openGLSurfaceViewportRectLock);
    NSRect old = _openGLSurfaceViewportRect;
    _openGLSurfaceViewportRect = *aRect;
    OSSpinLockUnlock(&_openGLSurfaceViewportRectLock);
    if (!CGRectEqualToRect(*aRect, old))
        return -1;
    return !_isOpenGLSurfaceValid;
}

- (NSRect)NSEView_openGLSurfaceViewportBounds
{
    return NSIntegralRect([self convertRect:[self visibleRect] toView:nil]);
}

- (BOOL)needsDisplayOpenGLSurface
{
    return _isOpenGLSurfaceEnabled && !_isOpenGLSurfaceValid;
}

- (void)setNeedsDisplayOpenGLSurfaceInRect:(NSRect)aRect
{
    if (!_isOpenGLSurfaceEnabled) {
        if (!_isQuartzBackingEnabled)
            return;
        if ([[NSThread currentThread] isMainThread])
            [self setNeedsDisplayInRect:aRect];
        else {
            NSValue *value = [NSValue valueWithRect:aRect];
            if (value)
                [self performSelectorOnMainThread:@selector(NSEView_setNeedsDisplayInRectFromValue:) withObject:value
                                    waitUntilDone:NO];
        }
        return;
    }
    if (!_isOpenGLSurfaceValid && !_openGLInvalidationInfo)
        // All of it is invalid already.
        return;
    if (NSIsEmptyRect(aRect))
        return;
    aRect = NSIntersectionRect(aRect, [self bounds]);
    if (NSIsEmptyRect(aRect))
        return;

    // The invalidation info is made by the first thread to get here.
    struct __NSEViewOpenGLSurfaceInvalidationInfo *volatile *slot = &_openGLInvalidationInfo;
    for (;;) {
        struct __NSEViewOpenGLSurfaceInvalidationInfo *info = *slot;
        if (info && info != INFO_BEING_MADE)
            break;
        if (!info && __sync_bool_compare_and_swap(slot, NULL, INFO_BEING_MADE)) {
            info = CFAllocatorAllocate(kCFAllocatorDefault, sizeof(*info), 0);
            if (info) {
                if (pthread_mutex_init(&info->f0, NULL) == 0) {
                    info->f1 = 0;
                    info->f2 = NULL;
                }
                else {
                    CFAllocatorDeallocate(kCFAllocatorDefault, info);
                    info = NULL;
                }
            }
            *slot = info;
            if (!info)
                return;
            break;
        }
        struct timespec wait = { 0, 1000 };
        nanosleep(&wait, NULL);
    }
    struct __NSEViewOpenGLSurfaceInvalidationInfo *info = _openGLInvalidationInfo;
    if (pthread_mutex_lock(&info->f0) != 0)
        return;
    if (_isOpenGLSurfaceValid) {
        // The first invalid rect.
        _isOpenGLSurfaceValid = 0;
        if (!info->f2 && !(info->f2 = CFDataCreateMutable(kCFAllocatorDefault, 0))) {
            pthread_mutex_unlock(&info->f0);
            return;
        }
        if (CFDataGetLength(info->f2) == 0)
            CFDataAppendBytes(info->f2, (const UInt8 *)&aRect, sizeof(NSRect));
        else
            *(NSRect *)CFDataGetMutableBytePtr(info->f2) = aRect;
        info->f1 = 1;
    }
    else if (info->f1 * sizeof(NSRect) == (size_t)getpagesize())
        // Too many: all of it (0 rects).
        info->f1 = 0;
    else if (info->f1) {
        if ((size_t)CFDataGetLength(info->f2) == info->f1 * sizeof(NSRect))
            CFDataAppendBytes(info->f2, (const UInt8 *)&aRect, sizeof(NSRect));
        else
            ((NSRect *)CFDataGetMutableBytePtr(info->f2))[info->f1] = aRect;
        info->f1++;
    }
    pthread_mutex_unlock(&info->f0);
}

- (void)setNeedsDisplayOpenGLSurface:(BOOL)aSurface
{
    if (!_isOpenGLSurfaceEnabled) {
        if (!_isQuartzBackingEnabled || !aSurface)
            return;
        if ([[NSThread currentThread] isMainThread])
            [self setNeedsDisplay:YES];
        else
            [self performSelectorOnMainThread:@selector(NSEView_setNeedsDisplay) withObject:nil waitUntilDone:NO];
    }
    else if (aSurface)
        [self NSEView_setNeedsDisplayOpenGLSurface];
    else
        _isOpenGLSurfaceValid = 1;
}

- (void)NSEView_setNeedsDisplay
{
    [self setNeedsDisplay:YES];
}

- (void)setDisablesOpenGLSurfaceInLiveResize:(BOOL)aResize
{
    if (!aResize) {
        if (_disablesOpenGLSurfaceInLiveResize) {
            _disablesOpenGLSurfaceInLiveResize = 0;
            if ([self inLiveResize])
                [self NSEView_reenableOpenGLSurfaceForLiveResizeIfNeeded];
        }
    }
    else if (!_disablesOpenGLSurfaceInLiveResize) {
        if ([self inLiveResize])
            [self NSEView_disableOpenGLSurfaceForLiveResizeIfNeeded];
        _disablesOpenGLSurfaceInLiveResize = 1;
    }
}

- (BOOL)disablesOpenGLSurfaceInLiveResize
{
    return _disablesOpenGLSurfaceInLiveResize;
}

- (void)setQuartzBackingEnabled:(BOOL)aEnabled
{
    _isQuartzBackingEnabled = aEnabled & 1;
}

- (BOOL)isQuartzBackingEnabled
{
    return _isQuartzBackingEnabled;
}

- (void)NSEView_windowDidChangeScreenProfile:(id)aProfile
{
    if (_colorSyncProfile) {
        CFRelease(_colorSyncProfile);
        _colorSyncProfile = NULL;
    }
    CGColorSpaceRelease(_colorSpace);
    _colorSpace = NULL;
    [_openGLContext invalidateColorProfile];
    [self setNeedsDisplayOpenGLSurface:YES];
}

// Maps the viewport (window coordinates) to clip space.
- (void)getOpenGLSurfaceProjectionMatrix:(float *)aMatrix forBounds:(NSRect)aBounds viewportRect:(NSRect)aRect
{
    float sx = aRect.size.width != 0 ? 2.0f / aRect.size.width : 1;
    float sy = aRect.size.height != 0 ? 2.0f / aRect.size.height : 1;
    float m[16] = { sx, 0, 0, 0, 0, sy, 0, 0, 0, 0, 1, 0, -1 - aRect.origin.x * sx, -1 - aRect.origin.y * sy, 0, 1 };
    memcpy(aMatrix, m, sizeof(m));
}

- (void)changeOpenGLSurfaceViewportFrom:(int *)aFrom to:(int *)aTo
{
    CGLContextObj cgl_ctx = _coreGLContext;
    glViewport(aTo[0], aTo[1], aTo[2], aTo[3]);
}

- (void)updateOpenGLContext
{
    _isOpenGLFramebufferStabilityChecked = 0;
    _isTextureRectangleExtensionPresenceChecked = 0;
    _isAGPTexturingChecked = 0;
    [_openGLContext update];
    [_openGLFramebufferClipper noteContextUpdated];
    if (OSAtomicCompareAndSwap32(0, 1, &_isOpenGLSurfaceDisplayLinkUpdateScheduled))
        [self performSelectorOnMainThread:@selector(NSEView_updateDisplayLinkIfNeeded) withObject:nil waitUntilDone:NO];
}

- (void)NSEView_openGLSurfaceNeedsUpdate:(id)aUpdate
{
    _isOpenGLContextUpdateQueried = 1;
    [self NSEView_setNeedsDisplayOpenGLSurface];
}

- (void)disassociateOpenGLContext
{
    [[NSNotificationCenter defaultCenter] removeObserver:_viewProxy name:NSViewGlobalFrameDidChangeNotification
                                                  object:self];
    if (_openGLBufferTexture) {
        // (CGLLockContext returns 0 on success: the original deletes the
        // texture only if the lock fails, and forgets it either way.)
        if (CGLLockContext(_coreGLContext) != kCGLNoError) {
            CGLContextObj cgl_ctx = _coreGLContext;
            glDeleteTextures(1, &_openGLBufferTexture);
            CGLUnlockContext(_coreGLContext);
        }
        _openGLBufferTexture = 0;
    }
    if ([_openGLContext view] == self)
        [_openGLContext clearDrawable];
    _isOpenGLFramebufferStabilityChecked = 0;
    _isOpenGLContextAssociated = 0;
    _isTextureRectangleExtensionPresenceChecked = 0;
    _isAGPTexturingChecked = 0;
    [self NSEView_setNeedsDisplayOpenGLSurface];
}

- (BOOL)associateOpenGLContext
{
    NSWindow *window;
    if (![self NSEView_proxy] || !(window = [self window]))
        return _isOpenGLContextAssociated;
    [_openGLContext setView:self];
    if ([_openGLContext view] != self)
        return _isOpenGLContextAssociated;
    if ((_openGLRendererMinVideoMemory && [self NSEView_openGLRendererVideoMemory] < _openGLRendererMinVideoMemory) ||
        ![self NSEView_isOpenGLRendererAllowed]) {
        [_openGLContext clearDrawable];
        return _isOpenGLContextAssociated;
    }
    if (OSAtomicCompareAndSwap32(0, 1, &_isOpenGLSurfaceDisplayLinkUpdateScheduled))
        [self performSelectorOnMainThread:@selector(NSEView_updateDisplayLinkIfNeeded) withObject:nil waitUntilDone:NO];
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    if (!_isObservingWindowDidChangeScreenProfileNotification) {
        [center addObserver:_viewProxy selector:@selector(NSEView_windowDidChangeScreenProfile:)
                       name:NSWindowDidChangeScreenProfileNotification object:window];
        _isObservingWindowDidChangeScreenProfileNotification = 1;
    }
    [center addObserver:_viewProxy selector:@selector(NSEView_openGLSurfaceNeedsUpdate:)
                   name:NSViewGlobalFrameDidChangeNotification object:self];
    _isOpenGLContextAssociated = 1;
    _isOpenGLContextUpdateQueried = 0;
    return _isOpenGLContextAssociated;
}

- (void)unlockAssociatedOpenGLContext
{
    [_openGLLock unlock];
}

- (BOOL)lockAssociatedOpenGLContext
{
    [_openGLLock lock];
    BOOL associated = _isOpenGLContextAssociated;
    if (!associated)
        [_openGLLock unlock];
    return associated;
}

- (BOOL)wantsDefaultOpenGLClipping
{
    return [self wantsDefaultClipping];
}

- (BOOL)isInitialQuartzTextureOpaque
{
    return [self isOpenGLSurfaceOpaque];
}

- (BOOL)isOpenGLSurfaceOpaque
{
    GLint order = 1;
    [_openGLContext getValues:&order forParameter:NSOpenGLContextParameterSurfaceOrder];
    if (order == -1)
        return [self isOpaque];
    GLint opaque = 1;
    [_openGLContext getValues:&opaque forParameter:NSOpenGLContextParameterSurfaceOpacity];
    return opaque == 1;
}

- (void)setOpenGLSurfaceAutodisplayMode:(NSUInteger)aMode
{
    if (_openGLSurfaceAutodisplayMode == aMode)
        return;
    if (![self window])
        _openGLSurfaceAutodisplayMode = aMode & 3;
    else {
        [self NSEView_disableOpenGLSurfaceAutodisplay];
        _openGLSurfaceAutodisplayMode = aMode & 3;
        [self NSEView_enableOpenGLSurfaceAutodisplay];
    }
}

- (NSUInteger)openGLSurfaceAutodisplayMode
{
    return _openGLSurfaceAutodisplayMode;
}

// Just before AppKit's display observer (600000), after it before 10.5.
- (NSUInteger)openGLSurfaceAutodisplayRunLoopOrdering
{
    return NSAppKitVersionNumber < 949 ? 600001 : 599999;
}

- (void)disallowOpenGLRendererWithName:(id)aName vendor:(id)aVendor
{
    [_openGLLock lock];
    NSMutableSet *allowed = [_allowedOpenGLRenderers objectForKey:aVendor];
    if ([allowed containsObject:aName]) {
        if ([allowed count] == 1)
            [_allowedOpenGLRenderers removeObjectForKey:aVendor];
        else
            [allowed removeObject:aName];
    }
    else {
        if (!_disallowedOpenGLRenderers && !(_disallowedOpenGLRenderers = [[NSMutableDictionary alloc] init])) {
            [_openGLLock unlock];
            return;
        }
        NSMutableSet *disallowed = [_disallowedOpenGLRenderers objectForKey:aVendor];
        if (!disallowed) {
            if (!(disallowed = [[[NSMutableSet alloc] init] autorelease])) {
                [_openGLLock unlock];
                return;
            }
            [_disallowedOpenGLRenderers setObject:disallowed forKey:aVendor];
        }
        [disallowed addObject:aName];
    }
    if (_isOpenGLSurfaceEnabled && _isOpenGLContextAssociated) {
        BOOL stillAllowed = [self NSEView_isOpenGLRendererAllowed];
        [_openGLLock unlock];
        if (!stillAllowed)
            [self NSEView_disableOpenGLSurface];
        return;
    }
    [_openGLLock unlock];
}

- (void)allowOpenGLRendererWithName:(id)aName vendor:(id)aVendor
{
    [_openGLLock lock];
    NSMutableSet *disallowed = [_disallowedOpenGLRenderers objectForKey:aVendor];
    if ([disallowed containsObject:aName]) {
        if ([disallowed count] == 1)
            [_disallowedOpenGLRenderers removeObjectForKey:aVendor];
        else
            [disallowed removeObject:aName];
        [_openGLLock unlock];
        return;
    }
    if (!_allowedOpenGLRenderers && !(_allowedOpenGLRenderers = [[NSMutableDictionary alloc] init])) {
        [_openGLLock unlock];
        return;
    }
    NSMutableSet *allowed = [_allowedOpenGLRenderers objectForKey:aVendor];
    if (!allowed) {
        if (!(allowed = [[[NSMutableSet alloc] init] autorelease])) {
            [_openGLLock unlock];
            return;
        }
        [_allowedOpenGLRenderers setObject:allowed forKey:aVendor];
    }
    [allowed addObject:aName];
    if (_isOpenGLSurfaceEnabled && _isOpenGLContextAssociated) {
        BOOL stillAllowed = [self NSEView_isOpenGLRendererAllowed];
        [_openGLLock unlock];
        if (!stillAllowed)
            [self NSEView_disableOpenGLSurface];
        return;
    }
    [_openGLLock unlock];
}

// With renderers allowed, only those; else all but the disallowed ones.
- (BOOL)NSEView_isOpenGLRendererAllowed
{
    NSUInteger allowedCount = [_allowedOpenGLRenderers count];
    if (!allowedCount && ![_disallowedOpenGLRenderers count])
        return YES;
    if (CGLLockContext(_coreGLContext) != kCGLNoError)
        return NO;
    CGLContextObj cgl_ctx = _coreGLContext;
    BOOL allowed = NO;
    const char *vendorName = (const char *)glGetString(GL_VENDOR);
    NSString *vendor = vendorName ? [[NSString alloc] initWithBytesNoCopy:(void *)vendorName length:strlen(vendorName)
                                                                 encoding:NSUTF8StringEncoding freeWhenDone:NO]
                                  : nil;
    if (vendor) {
        NSSet *renderers = [(allowedCount ? _allowedOpenGLRenderers : _disallowedOpenGLRenderers) objectForKey:vendor];
        [vendor release];
        if (![renderers count])
            allowed = !allowedCount;
        else {
            const char *rendererName = (const char *)glGetString(GL_RENDERER);
            NSString *renderer = rendererName ? [[NSString alloc] initWithBytesNoCopy:(void *)rendererName
                                                                                length:strlen(rendererName)
                                                                              encoding:NSUTF8StringEncoding
                                                                          freeWhenDone:NO]
                                              : nil;
            if (renderer) {
                BOOL listed = [renderers containsObject:renderer];
                allowed = allowedCount ? listed : !listed;
                [renderer release];
            }
        }
    }
    CGLUnlockContext(_coreGLContext);
    return allowed;
}

- (BOOL)allowsOpenGLRendererWithName:(id)aName vendor:(id)aVendor
{
    [_openGLLock lock];
    BOOL allows;
    if ([_allowedOpenGLRenderers count])
        allows = [[_allowedOpenGLRenderers objectForKey:aVendor] containsObject:aName];
    else
        allows = ![[_disallowedOpenGLRenderers objectForKey:aVendor] containsObject:aName];
    [_openGLLock unlock];
    return allows;
}

- (id)disallowedOpenGLRenderers
{
    [_openGLLock lock];
    id copy = _disallowedOpenGLRenderers ? [_disallowedOpenGLRenderers NSE_copyToDepth:1 zone:NULL] : nil;
    [_openGLLock unlock];
    return copy ? [copy autorelease] : [NSDictionary dictionary];
}

- (id)allowedOpenGLRenderers
{
    [_openGLLock lock];
    id copy = _allowedOpenGLRenderers ? [_allowedOpenGLRenderers NSE_copyToDepth:1 zone:NULL] : nil;
    [_openGLLock unlock];
    return copy ? [copy autorelease] : [NSDictionary dictionary];
}

- (void)setOpenGLRendererMinVideoMemory:(NSUInteger)aMemory
{
    NSUInteger old = _openGLRendererMinVideoMemory;
    if (old == aMemory)
        return;
    _openGLRendererMinVideoMemory = (unsigned int)aMemory;
    // Only a lower limit can stop the renderer in use (as the original).
    if (aMemory < old && aMemory && _isOpenGLSurfaceEnabled) {
        [_openGLLock lock];
        if (!_isOpenGLContextAssociated) {
            [_openGLLock unlock];
            return;
        }
        NSUInteger memory = [self NSEView_openGLRendererVideoMemory];
        NSUInteger minimum = _openGLRendererMinVideoMemory;
        [_openGLLock unlock];
        if (memory < minimum)
            [self NSEView_disableOpenGLSurface];
    }
}

- (NSUInteger)openGLRendererMinVideoMemory
{
    return _openGLRendererMinVideoMemory;
}

// The video memory of the renderer in use.
- (NSUInteger)NSEView_openGLRendererVideoMemory
{
    NSOpenGLPixelFormat *format = [_openGLContext format];
    GLint screen = [_openGLContext currentVirtualScreen];
    GLint rendererID = 0;
    [format getValues:&rendererID forAttribute:NSOpenGLPFARendererID forVirtualScreen:screen];
    if (!rendererID)
        return 0;
    GLint displayMask = 0;
    [format getValues:&displayMask forAttribute:NSOpenGLPFAScreenMask forVirtualScreen:screen];
    if (!displayMask)
        return 0;
    CGLRendererInfoObj renderers = NULL;
    GLint count = 0;
    CGLQueryRendererInfo(displayMask, &renderers, &count);
    if (!renderers)
        return 0;
    GLint memory = 0;
    for (GLint i = 0; i < count; i++) {
        GLint id = 0;
        CGLDescribeRenderer(renderers, i, kCGLRPRendererID, &id);
        if (id == rendererID) {
            CGLDescribeRenderer(renderers, i, kCGLRPVideoMemory, &memory);
            break;
        }
    }
    CGLDestroyRendererInfo(renderers);
    return memory;
}

- (void)setOpenGLContext:(id)aContext
{
    if (_openGLContext == aContext)
        return;
    [_openGLLock lock];
    if (_openGLContext != aContext) {
        if (_isOpenGLContextAssociated)
            [self disassociateOpenGLContext];
        [_openGLFramebufferClipper release];
        _openGLFramebufferClipper = nil;
        _isOpenGLFramebufferStabilityChecked = 0;
        _isTextureRectangleExtensionPresenceChecked = 0;
        _isAGPTexturingChecked = 0;
        [aContext retain];
        [_openGLContext release];
        _openGLContext = aContext;
        _coreGLContext = [aContext CGLContextObj];
    }
    [_openGLLock unlock];
}

- (id)openGLContext
{
    [_openGLLock lock];
    NSEOpenGLContext *context = _openGLContext;
    if (!context) {
        context = _openGLContext = [[self class] createDefaultOpenGLContext];
        _coreGLContext = [context CGLContextObj];
    }
    if (_openGLLock) {
        [context retain];
        [_openGLLock unlock];
        context = [context autorelease];
    }
    return context;
}

// The relative bounds scaled to the view's bounds.
- (NSRect)openGLSurfaceBounds
{
    OSSpinLockLock(&_openGLSurfaceBoundsLock);
    NSRect relative = _relativeOpenGLSurfaceBounds;
    OSSpinLockUnlock(&_openGLSurfaceBoundsLock);
    NSRect bounds = [self bounds];
    if (bounds.size.width > 0) {
        relative.size.width *= bounds.size.width;
        relative.origin.x *= bounds.size.width;
    }
    if (bounds.size.height > 0) {
        relative.size.height *= bounds.size.height;
        relative.origin.y *= bounds.size.height;
    }
    relative.origin.x += bounds.origin.x;
    relative.origin.y += bounds.origin.y;
    return relative;
}

- (void)setRelativeOpenGLSurfaceBounds:(NSRect)aBounds
{
    OSSpinLockLock(&_openGLSurfaceBoundsLock);
    NSRect old = _relativeOpenGLSurfaceBounds;
    _relativeOpenGLSurfaceBounds = aBounds;
    OSSpinLockUnlock(&_openGLSurfaceBoundsLock);
    if (_isOpenGLSurfaceEnabled && !CGRectEqualToRect(aBounds, old)) {
        _isOpenGLContextUpdateQueried = 1;
        [self NSEView_setNeedsDisplayOpenGLSurface];
    }
}

- (NSRect)relativeOpenGLSurfaceBounds
{
    OSSpinLockLock(&_openGLSurfaceBoundsLock);
    NSRect bounds = _relativeOpenGLSurfaceBounds;
    OSSpinLockUnlock(&_openGLSurfaceBoundsLock);
    return bounds;
}

- (void)disableOpenGLSurfaceDetachingImmediately:(BOOL)aImmediately
{
    if (!_isOpenGLSurfaceEnabled) {
        _isOpenGLSurfaceDisabledDueToLiveResize = 0;
        return;
    }
    if (![self window])
        return;
    [self NSEView_disableOpenGLSurfaceAutodisplay];
    [_openGLLock lock];
    if (_isOpenGLContextAssociated && aImmediately)
        [self disassociateOpenGLContext];
    _isOpenGLSurfaceEnabled = 0;
    [_openGLLock unlock];
}

- (void)enableOpenGLSurface
{
    if (_isOpenGLSurfaceEnabled)
        return;
    if (_disablesOpenGLSurfaceInLiveResize && [self inLiveResize]) {
        _isOpenGLSurfaceDisabledDueToLiveResize = 1;
        return;
    }
    if (!_openGLLock && !(_openGLLock = [[NSRecursiveLock alloc] init]))
        return;
    _isOpenGLSurfaceEnabled = 1;
    [self NSEView_setNeedsDisplayOpenGLSurface];
    if ([self window])
        [self NSEView_enableOpenGLSurfaceAutodisplay];
}

- (BOOL)isOpenGLSurfaceEnabled
{
    return _isOpenGLSurfaceEnabled;
}

// The renderer can't be used: draw with Quartz instead, if quartz backed.
- (void)NSEView_disableOpenGLSurface
{
    if (!_isQuartzBackingEnabled)
        [self disableOpenGLSurfaceDetachingImmediately:YES];
    else if (NSAppKitVersionNumber < 1038 && [[[NSView focusView] window] isEqual:[self window]])
        [self NSEView_scheduleFallBackToQuartz];
    else
        [self NSEView_delayedFallBackToQuartz];
}

- (void)NSEView_scheduleFallBackToQuartz
{
    NSArray *modes = [NSArray arrayWithObjects:NSDefaultRunLoopMode, NSModalPanelRunLoopMode, NSEventTrackingRunLoopMode, nil];
    if (modes)
        [[NSRunLoop currentRunLoop] performSelector:@selector(NSEView_delayedFallBackToQuartz) target:self argument:nil
                                              order:0 modes:modes];
}

- (void)NSEView_delayedFallBackToQuartz
{
    [self disableOpenGLSurfaceDetachingImmediately:NO];
    [self setNeedsDisplayInRect:[self openGLSurfaceBounds]];
}

- (void)NSEView_fallBackToQuartz
{
    [self disableOpenGLSurfaceDetachingImmediately:NO];
    [self displayRect:[self openGLSurfaceBounds]];
}

// All of the surface is invalid (no rects).
- (void)NSEView_setNeedsDisplayOpenGLSurface
{
    if (!_openGLInvalidationInfo)
        _isOpenGLSurfaceValid = 0;
    if (_openGLInvalidationInfo && pthread_mutex_lock(&_openGLInvalidationInfo->f0) == 0) {
        _isOpenGLSurfaceValid = 0;
        _openGLInvalidationInfo->f1 = 0;
        pthread_mutex_unlock(&_openGLInvalidationInfo->f0);
    }
}

- (void)NSEView_scheduleNeedsDisplayInRect:(NSRect)aRect
{
    NSValue *value = [NSValue valueWithRect:aRect];
    if (!value)
        return;
    NSArray *modes = [NSArray arrayWithObjects:NSDefaultRunLoopMode, NSModalPanelRunLoopMode, NSEventTrackingRunLoopMode, nil];
    if (modes)
        [[NSRunLoop currentRunLoop] performSelector:@selector(NSEView_setNeedsDisplayInRectFromValue:) target:self
                                           argument:value order:599999 modes:modes];
}

- (void)NSEView_setNeedsDisplayInRectFromValue:(id)aValue
{
    [self setNeedsDisplayInRect:[aValue rectValue]];
}

- (struct CGColorSpace *)colorSpace
{
    if (!_colorSpace && [self colorSyncProfile])
        _colorSpace = CGColorSpaceCreateWithPlatformColorSpace(_colorSyncProfile);
    return _colorSpace;
}

- (struct OpaqueCMProfileRef *)colorSyncProfile
{
    if (!_colorSyncProfile) {
        _colorSyncProfile = [[self window] NSE_displayColorSyncProfile];
        if (!_colorSyncProfile)
            return NULL;
        CFRetain(_colorSyncProfile);
    }
    return _colorSyncProfile;
}

- (void)viewDidEndLiveResize
{
    [super viewDidEndLiveResize];
    if (_disablesOpenGLSurfaceInLiveResize)
        [self NSEView_reenableOpenGLSurfaceForLiveResizeIfNeeded];
}

- (void)viewWillStartLiveResize
{
    if (_disablesOpenGLSurfaceInLiveResize)
        [self NSEView_disableOpenGLSurfaceForLiveResizeIfNeeded];
    [super viewWillStartLiveResize];
}

- (void)NSEView_reenableOpenGLSurfaceForLiveResizeIfNeeded
{
    if (_isOpenGLSurfaceDisabledDueToLiveResize) {
        [self enableOpenGLSurface];
        [self setNeedsDisplayInRect:[self openGLSurfaceBounds]];
    }
}

- (void)NSEView_disableOpenGLSurfaceForLiveResizeIfNeeded
{
    _isOpenGLSurfaceDisabledDueToLiveResize = _isOpenGLSurfaceEnabled;
    if (_isOpenGLSurfaceDisabledDueToLiveResize) {
        [self disableOpenGLSurfaceDetachingImmediately:NO];
        [self setNeedsDisplayInRect:[self openGLSurfaceBounds]];
    }
}

- (void)setHidden:(BOOL)aHidden
{
    [super setHidden:aHidden];
    if (!aHidden && _isOpenGLSurfaceEnabled) {
        // Attach and detach once to take the hidden state.
        [_openGLLock lock];
        if (!_isOpenGLContextAssociated && [self associateOpenGLContext])
            [self disassociateOpenGLContext];
        [_openGLLock unlock];
    }
}

- (void)viewDidMoveToWindow
{
    if (_isOpenGLSurfaceEnabled && [self window])
        [self NSEView_enableOpenGLSurfaceAutodisplay];
    [super viewDidMoveToWindow];
}

- (void)viewWillMoveToWindow:(id)aWindow
{
    NSWindow *window = [self window];
    if (window) {
        if (_isObservingWindowDidChangeScreenProfileNotification) {
            if (_colorSyncProfile) {
                CFRelease(_colorSyncProfile);
                _colorSyncProfile = NULL;
            }
            CGColorSpaceRelease(_colorSpace);
            _colorSpace = NULL;
            [[NSNotificationCenter defaultCenter] removeObserver:_viewProxy
                                                            name:NSWindowDidChangeScreenProfileNotification
                                                          object:window];
            _isObservingWindowDidChangeScreenProfileNotification = 0;
        }
        if (_isOpenGLSurfaceEnabled)
            [self NSEView_disableOpenGLSurfaceAutodisplay];
        [_openGLLock lock];
        if (_isOpenGLContextAssociated)
            [self disassociateOpenGLContext];
        [_openGLLock unlock];
    }
    [super viewWillMoveToWindow:aWindow];
}

// Mode 1: a run loop observer; mode 2: a display link.
- (void)NSEView_disableOpenGLSurfaceAutodisplay
{
    if (_openGLSurfaceAutodisplayMode == 2) {
        if (CVDisplayLinkIsRunning(_openGLSurfaceAutodisplayControl))
            CVDisplayLinkStop(_openGLSurfaceAutodisplayControl);
        _isOpenGLSurfaceDisplayLinkUpdateScheduled = 0;
    }
    else if (_openGLSurfaceAutodisplayMode == 1 && _openGLSurfaceAutodisplayControl)
        CFRunLoopRemoveObserver(CFRunLoopGetCurrent(), _openGLSurfaceAutodisplayControl, kCFRunLoopCommonModes);
}

- (void)NSEView_enableOpenGLSurfaceAutodisplay
{
    if (_openGLSurfaceAutodisplayMode == 1) {
        if (_openGLSurfaceAutodisplayControl && CFGetTypeID(_openGLSurfaceAutodisplayControl) == CVDisplayLinkGetTypeID()) {
            CVDisplayLinkSetOutputCallback(_openGLSurfaceAutodisplayControl, NULL, NULL);
            CVDisplayLinkRelease(_openGLSurfaceAutodisplayControl);
            _openGLSurfaceAutodisplayControl = NULL;
        }
        if (!_openGLSurfaceAutodisplayControl) {
            CFRunLoopObserverContext context = { 0, self, NULL, NULL, CFCopyDescription };
            _openGLSurfaceAutodisplayControl = CFRunLoopObserverCreate(
                kCFAllocatorDefault, kCFRunLoopBeforeTimers, true, [self openGLSurfaceAutodisplayRunLoopOrdering],
                autodisplayObserverCallBack, &context);
            if (!_openGLSurfaceAutodisplayControl)
                return;
        }
        CFRunLoopAddObserver(CFRunLoopGetCurrent(), _openGLSurfaceAutodisplayControl, kCFRunLoopCommonModes);
    }
    else if (_openGLSurfaceAutodisplayMode == 2) {
        if (_openGLSurfaceAutodisplayControl &&
            CFGetTypeID(_openGLSurfaceAutodisplayControl) == CFRunLoopObserverGetTypeID()) {
            CFRelease(_openGLSurfaceAutodisplayControl);
            _openGLSurfaceAutodisplayControl = NULL;
        }
        if (!_openGLSurfaceAutodisplayControl) {
            CVDisplayLinkCreateWithActiveCGDisplays((CVDisplayLinkRef *)&_openGLSurfaceAutodisplayControl);
            if (!_openGLSurfaceAutodisplayControl)
                return;
            if (CVDisplayLinkSetOutputCallback(_openGLSurfaceAutodisplayControl, autodisplayDisplayLinkCallBack,
                                               self) != kCVReturnSuccess) {
                CVDisplayLinkRelease(_openGLSurfaceAutodisplayControl);
                _openGLSurfaceAutodisplayControl = NULL;
                return;
            }
        }
        [self NSEView_updateDisplayLink];
        _isOpenGLSurfaceDisplayLinkUpdateScheduled = 0;
        CVDisplayLinkStart(_openGLSurfaceAutodisplayControl);
    }
}

- (void)NSEView_updateDisplayLinkIfNeeded
{
    if (OSAtomicCompareAndSwap32(1, 0, &_isOpenGLSurfaceDisplayLinkUpdateScheduled))
        [self NSEView_updateDisplayLink];
}

// The display link follows the display the context (or else the window) is on.
- (void)NSEView_updateDisplayLink
{
    if ([self lockAssociatedOpenGLContext]) {
        NSOpenGLContext *context = [_openGLContext retain];
        [self unlockAssociatedOpenGLContext];
        CVDisplayLinkSetCurrentCGDisplayFromOpenGLContext(_openGLSurfaceAutodisplayControl, [context CGLContextObj],
                                                          [[context pixelFormat] CGLPixelFormatObj]);
        [context release];
    }
    else {
        CGDirectDisplayID display =
            [[[[[self window] screen] deviceDescription] objectForKey:@"NSScreenNumber"] unsignedIntValue];
        if (display)
            CVDisplayLinkSetCurrentCGDisplay(_openGLSurfaceAutodisplayControl, display);
    }
}

- (id)NSEView_proxy
{
    if (!_viewProxy)
        _viewProxy = [self NSE_newWeakProxy];
    return _viewProxy;
}

- (void)dealloc
{
    if (_quartzLayer)
        releaseQuartzLayer(_quartzLayer);
    if (_openGLSurfaceAutodisplayControl) {
        if (CFGetTypeID(_openGLSurfaceAutodisplayControl) == CVDisplayLinkGetTypeID())
            CVDisplayLinkSetOutputCallback(_openGLSurfaceAutodisplayControl, NULL, NULL);
        CFRelease(_openGLSurfaceAutodisplayControl);
    }
    if (_openGLInvalidationInfo) {
        if (_openGLInvalidationInfo->f2)
            CFRelease(_openGLInvalidationInfo->f2);
        pthread_mutex_destroy(&_openGLInvalidationInfo->f0);
        CFAllocatorDeallocate(kCFAllocatorDefault, _openGLInvalidationInfo);
    }
    [_openGLFramebufferClipper release];
    [_openGLContext release];
    [_openGLLock release];
    [_allowedOpenGLRenderers release];
    [_disallowedOpenGLRenderers release];
    [[self class] NSE_invalidateWeakProxy:_viewProxy];
    [_viewProxy release];
    [super dealloc];
}

- (id)initWithFrame:(NSRect)aFrame
{
    self = [super initWithFrame:aFrame];
    if (self)
        // The surface is all of the view.
        _relativeOpenGLSurfaceBounds.size = NSMakeSize(1, 1);
    return self;
}

@end

@implementation NSView (NSEViewPartial)

// From the points (0,0), (1,1) and (2,1) converted to the view.
- (CGAffineTransform)NSE_affineTransformToView:(id)aView
{
    NSPoint origin = [self convertPoint:NSZeroPoint toView:aView];
    NSPoint p1 = [self convertPoint:NSMakePoint(1, 1) toView:aView];
    NSPoint p2 = [self convertPoint:NSMakePoint(2, 1) toView:aView];
    CGAffineTransform t;
    t.a = p2.x - p1.x;
    t.b = p2.y - p1.y;
    t.c = (p1.x - t.a) - origin.x;
    t.d = (p1.y - t.b) - origin.y;
    t.tx = origin.x;
    t.ty = origin.y;
    return t;
}

// The bounds to frame transform (rotation included).
- (CGAffineTransform)NSE_boundsAffineTransform
{
    NSView *superview = [self superview];
    BOOL superFlipped = [superview isFlipped];
    BOOL flipped = [self isFlipped];
    NSRect frame = [self frame];
    CGAffineTransform t = [self NSE_affineTransformToView:superview];
    t.tx -= frame.origin.x;
    t.ty -= frame.origin.y;
    float angle = (float)(([self frameRotation] * M_PI) / -180.0);
    float s = sinf(angle), c = cosf(angle);
    CGAffineTransform r;
    r.a = t.a * c - t.b * s;
    r.b = t.b * c + t.a * s;
    r.c = t.c * c - t.d * s;
    r.d = t.d * c + t.c * s;
    r.tx = t.tx * c - t.ty * s;
    r.ty = t.ty * c + t.tx * s;
    if (flipped != superFlipped) {
        r.b = -r.b;
        r.d = -r.d;
        r.ty = frame.size.height - r.ty;
    }
    return r;
}

- (NSRect)NSE_unrotatedBounds
{
    CGAffineTransform t = [self NSE_boundsAffineTransform];
    CGFloat sx = hypotf(t.a, t.c), sy = hypotf(t.b, t.d);
    NSRect frame = [self frame];
    return NSMakeRect(-t.tx / sx, -t.ty / sy, frame.size.width / sx, frame.size.height / sy);
}

// The screen the view is on: the one with all of it, else most of it.
- (id)NSE_screen
{
    NSWindow *window = [self window];
    NSScreen *screen = [window screen];
    if (!screen)
        return nil;
    NSRect rect = [window convertRectToScreen:[self convertRect:[self visibleRect] toView:nil]];
    if (NSContainsRect([screen frame], rect))
        return screen;
    NSScreen *best = nil;
    CGFloat bestArea = 0;
    for (NSScreen *candidate in [NSScreen screens]) {
        NSRect frame = [candidate frame];
        if (NSContainsRect(frame, rect))
            return candidate;
        NSRect common = NSIntersectionRect(rect, frame);
        CGFloat area = common.size.width * common.size.height;
        if (bestArea < area) {
            best = candidate;
            bestArea = area;
        }
    }
    return best;
}

@end

@implementation NSView (NSEViewLoading)

// Added convertPointToBacking: and the other backing conversions before
// 10.7; AppKit has them.
+ (void)load
{
}

@end
