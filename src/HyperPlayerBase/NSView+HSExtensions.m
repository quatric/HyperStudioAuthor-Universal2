#import "NSView+HSExtensions.h"
// View helpers: enabling a view tree, invalidation by region, and drawing
// a view (a system object's Cocoa control) scaled into another context.
// A view is rendered either directly into a bitmap or, when windows can
// be created, by placing it in an offscreen cache window and drawing that
// window's backing store.

@implementation NSView (HSExtensions)

// The last subview at each level.
- (id)hyperDeepestSubview
{
    NSArray *subviews = [self subviews];
    if (!subviews)
        return self;
    return [[subviews lastObject] hyperDeepestSubview];
}

- (void)hyperRemoveAllSubviews
{
    NSArray *subviews = [[self subviews] copy];
    [subviews makeObjectsPerformSelector:@selector(removeFromSuperviewWithoutNeedingDisplay)];
    [subviews release];
}

- (void)setNeedsHyperDisplayInRegion:(id)aRegion
{
    NSData *rects = [aRegion rectApproximation];
    const NSRect *rect = [rects bytes];
    const NSRect *end = (const NSRect *)((const char *)rect + [rects length]);
    for (; rect < end; rect++)
        [self setNeedsDisplayInRect:*rect];
}

- (void)setHyperEnabled:(BOOL)aEnabled
{
    [self setHyperEnabled:aEnabled includeSelf:YES];
}

// Labels (text fields without a background) are dimmed through their text
// color; controls are enabled; other views pass it on to their subviews.
- (void)setHyperEnabled:(BOOL)aEnabled includeSelf:(BOOL)aSelf
{
    NSArray *views = [self subviews];
    if (aSelf)
        views = [views arrayByAddingObject:self];
    NSUInteger index = [views count];
    while (index > 0) {
        index--;
        id view = [views objectAtIndex:index];
        if ([view isKindOfClass:[NSTextField class]] && ![view drawsBackground])
            [view setTextColor:aEnabled ? [NSColor controlTextColor] : [NSColor disabledControlTextColor]];
        else if ([view respondsToSelector:@selector(setEnabled:)])
            [view setEnabled:aEnabled];
        else if (view != self)
            [view setHyperEnabled:aEnabled];
    }
}

- (void)hyperCacheInSize:(NSSize)aSize fromRect:(NSRect)aRect flipped:(BOOL)aFlipped withIntegralScaling:(BOOL)aScaling resultCacheImageRep:(id *)aRep resultCacheTransform:(id *)aTransform
{
    if ([self shouldUseOffscreenWindow])
        [self NSView_HSExtensions_drawInSize:aSize toWindow:nil fromRect:aRect flipped:aFlipped withIntegralScaling:aScaling resultCacheImageRep:aRep resultCacheTransform:aTransform];
    else
        *aRep = [self NSView_HSExtensions_bitmapImageRepInSize:aSize fromRect:aRect flipped:aFlipped withIntegralScaling:aScaling resultCacheTransform:aTransform];
}

// Draws aRect2 of the view (in its superview's coordinates) into aRect.
- (void)hyperDrawInRect:(NSRect)aRect fromRect:(NSRect)aRect2 flipped:(BOOL)aFlipped withIntegralScaling:(BOOL)aScaling
{
    if ([self shouldUseOffscreenWindow]) {
        id rep = nil;
        id transform = nil;
        // (id)-1: the locked shared cache window.
        [self NSView_HSExtensions_drawInSize:aRect.size toWindow:(id)-1 fromRect:aRect2 flipped:aFlipped withIntegralScaling:aScaling resultCacheImageRep:&rep resultCacheTransform:&transform];
        [NSGraphicsContext saveGraphicsState];
        NSRectClip(aRect);
        [[transform hyperPosttranslateBy:NSMakeSize(aRect.origin.x, aRect.origin.y)] concat];
        [(NSImageRep *)rep drawAtPoint:NSZeroPoint];
        [NSGraphicsContext restoreGraphicsState];
        [NSWindow hyperUnlockSharedCacheWindow:[(NSCachedImageRep *)rep window]];
    } else {
        NSImage *image = [self hyperImage];
        // (The original leaves the flip in the current context.)
        if (aFlipped) {
            NSAffineTransform *flip = [NSAffineTransform transform];
            [flip hyperPreflipYInRect:aRect];
            [flip concat];
        }
        NSRect frame = [self frame];
        aRect2.origin.x -= frame.origin.x;
        aRect2.origin.y -= frame.origin.y;
        [image drawInRect:aRect fromRect:aRect2 operation:NSCompositingOperationSourceOver fraction:1];
    }
}

- (id)hyperImage
{
    NSRect bounds = { NSZeroPoint, [self frame].size };
    NSBitmapImageRep *rep = [self bitmapImageRepForCachingDisplayInRect:bounds];
    [self cacheDisplayInRect:bounds toBitmapImageRep:rep];
    NSImage *image = [[NSImage alloc] initWithSize:bounds.size];
    [image addRepresentation:rep];
    return [image autorelease];
}

// Whether a window can be created (it can't without a window server).
- (BOOL)shouldUseOffscreenWindow
{
    BOOL result = NO;
    @try {
        NSWindow *window = [[NSWindow alloc] initWithContentRect:NSMakeRect(0, 0, 16, 16) styleMask:NSWindowStyleMaskBorderless backing:NSBackingStoreBuffered defer:NO];
        result = window != nil;
        [window release];
    } @catch (NSException *exception) {
    }
    return result;
}

// The transform maps the cache into the requested size. (The cache is
// made of the view's bounds at its own scale.)
- (id)NSView_HSExtensions_bitmapImageRepInSize:(NSSize)aSize fromRect:(NSRect)aRect flipped:(BOOL)aFlipped withIntegralScaling:(BOOL)aScaling resultCacheTransform:(id *)aTransform
{
    NSSize cacheScale = NSMakeSize(1, 1);
    NSSize integralOffset = NSZeroSize;
    NSSize compensationScale = NSMakeSize(1, 1);
    NSSize compensationOffset = NSZeroSize;
    NSRect frame = [self frame];
    aRect.origin.x -= frame.origin.x;
    aRect.origin.y -= frame.origin.y;
    NSSize cacheSize = [self NSView_HSExtensions_cacheSizeForCachingRect:aRect inSize:aSize withIntegralScaling:aScaling cacheScale:&cacheScale integralCacheOffset:&integralOffset compensationScale:&compensationScale compensationOffset:&compensationOffset];
    NSRect cacheRect = { NSZeroPoint, cacheSize };
    NSBitmapImageRep *rep = [self bitmapImageRepForCachingDisplayInRect:cacheRect];
    [self cacheDisplayInRect:cacheRect toBitmapImageRep:rep];
    struct HyperPlayerBase_anon1 transform = { compensationScale.width, 0, 0, compensationScale.height, compensationOffset.width, compensationOffset.height };
    if (aFlipped) {
        transform.f3 = -compensationScale.height;
        transform.f5 = compensationOffset.height + cacheSize.height * compensationScale.height;
    }
    *aTransform = [NSAffineTransform transformWithHyperTransformStruct:transform];
    return rep;
}

// Renders the view in a cache window at the cache scale. aWindow nil makes
// a new window, (id)-1 locks the shared one. The view is moved into the
// window's content view just for the display.
- (void)NSView_HSExtensions_drawInSize:(NSSize)aSize toWindow:(id)aWindow fromRect:(NSRect)aRect flipped:(BOOL)aFlipped withIntegralScaling:(BOOL)aScaling resultCacheImageRep:(id *)aRep resultCacheTransform:(id *)aTransform
{
    NSSize cacheScale = NSMakeSize(1, 1);
    NSSize integralOffset = NSZeroSize;
    NSSize compensationScale = NSMakeSize(1, 1);
    NSSize compensationOffset = NSZeroSize;
    NSSize cacheSize = [self NSView_HSExtensions_cacheSizeForCachingRect:aRect inSize:aSize withIntegralScaling:aScaling cacheScale:&cacheScale integralCacheOffset:&integralOffset compensationScale:&compensationScale compensationOffset:&compensationOffset];
    NSWindow *window = aWindow;
    if (window == (id)-1)
        window = [NSWindow hyperLockedSharedChacheWindowWithContentSize:cacheSize];
    else if (!window) {
        id contentView = [[[HSVisualizationAuxiliaryView alloc] init] autorelease];
        window = [NSWindow hyperCacheWindowWithContentRect:NSMakeRect(NSZeroPoint.x, NSZeroPoint.y, cacheSize.width, cacheSize.height)];
        [window setContentView:contentView];
    }
    id contentView = [window contentView];
    NSRect contentFrame = [contentView frame];
    [contentView setHyperFlipped:aFlipped];
    [contentView setBounds:NSMakeRect(integralOffset.width / cacheScale.width, integralOffset.height / cacheScale.height,
                                      contentFrame.size.width / cacheScale.width, contentFrame.size.height / cacheScale.height)];
    NSRect frame = [self frame];
    [self setFrameOrigin:NSZeroPoint];
    [contentView addSubview:self];
    [window setViewsNeedDisplay:NO];
    [contentView hyperSetNeedsDisplayInRect:NSMakeRect(NSZeroPoint.x, NSZeroPoint.y, cacheSize.width, cacheSize.height)];
    // Displaying needs the window to be key for a moment.
    NSWindow *keyWindow = [NSApp keyWindow];
    [window becomeKeyWindow];
    [window displayIfNeeded];
    [keyWindow makeKeyWindow];
    [self removeFromSuperviewWithoutNeedingDisplay];
    [self setFrameOrigin:frame.origin];
    NSRect cacheRect = NSMakeRect(contentFrame.origin.x, contentFrame.origin.y, cacheSize.width, cacheSize.height);
    if (aFlipped)
        cacheRect.origin.y += contentFrame.size.height - cacheSize.height;
    struct HyperPlayerBase_anon1 transform = { compensationScale.width, 0, 0, compensationScale.height, compensationOffset.width, compensationOffset.height };
    if (aFlipped) {
        transform.f3 = -compensationScale.height;
        transform.f5 = compensationOffset.height + cacheSize.height * compensationScale.height;
    }
    *aRep = [[[NSCachedImageRep alloc] initWithWindow:window rect:cacheRect] autorelease];
    *aTransform = [NSAffineTransform transformWithHyperTransformStruct:transform];
}

// The cache size for aRect (in the view's frame coordinates) drawn at
// aSize, at whole scale factors if asked. The cache starts at a whole
// pixel; the compensation maps it back onto the exact rect.
- (NSSize)NSView_HSExtensions_cacheSizeForCachingRect:(NSRect)aRect inSize:(NSSize)aSize withIntegralScaling:(BOOL)aScaling cacheScale:(NSSize *)aScale integralCacheOffset:(NSSize *)aOffset compensationScale:(NSSize *)aScale2 compensationOffset:(NSSize *)aOffset2
{
    NSSize scale = NSMakeSize(aSize.width / aRect.size.width, aSize.height / aRect.size.height);
    NSSize cacheScale = scale;
    if (aScaling)
        cacheScale = [self hyperIntegralScaleFactorForScaleFactor:scale];
    NSRect frame = [self frame];
    float offsetX = (aRect.origin.x - frame.origin.x) * cacheScale.width;
    float offsetY = (aRect.origin.y - frame.origin.y) * cacheScale.height;
    float integralX = floorf(offsetX);
    float integralY = floorf(offsetY);
    if (aScale)
        *aScale = cacheScale;
    if (aOffset)
        *aOffset = NSMakeSize(integralX, integralY);
    offsetX -= integralX;
    offsetY -= integralY;
    if (aScale2)
        *aScale2 = NSMakeSize(scale.width / cacheScale.width, scale.height / cacheScale.height);
    if (aOffset2)
        *aOffset2 = NSMakeSize(scale.width / cacheScale.width * -offsetX, scale.height / cacheScale.height * -offsetY);
    return NSMakeSize(ceilf(aRect.size.width * cacheScale.width + offsetX), ceilf(aRect.size.height * cacheScale.height + offsetY));
}

// Invalidates aRect here and in every subview it touches.
- (void)hyperSetNeedsDisplayInRect:(NSRect)aRect
{
    [self setNeedsDisplayInRect:aRect];
    NSEnumerator *enumerator = [[self subviews] objectEnumerator];
    NSView *subview;
    while ((subview = [enumerator nextObject])) {
        NSRect frame = [subview frame];
        NSRect rect = NSIntersectionRect(aRect, frame);
        if (!NSEqualRects(rect, NSZeroRect)) {
            rect.origin.x -= frame.origin.x;
            rect.origin.y -= frame.origin.y;
            [subview hyperSetNeedsDisplayInRect:rect];
        }
    }
}

// Rounds up from 0.25 past a whole factor, and never below 1.
- (NSSize)hyperIntegralScaleFactorForScaleFactor:(NSSize)aFactor
{
    return NSMakeSize(fmaxf(1, roundf(aFactor.width + 0.25f)), fmaxf(1, roundf(aFactor.height + 0.25f)));
}

@end
