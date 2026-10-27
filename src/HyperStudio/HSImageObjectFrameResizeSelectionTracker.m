#import "HSImageObjectFrameResizeSelectionTracker.h"

@implementation HSImageObjectFrameResizeSelectionTracker

- (id)mutableClipPathsAttributes
{
    return [[self trackingObject] queryHyperInterface:@protocol(HSMutableClipPathsAttributes)];
}

- (id)mutableImageRectAttributes
{
    return [[self trackingObject] queryHyperInterface:@protocol(HSMutableImageRectAttributes)];
}

- (void)updateStartClipPathsBounds
{
    CGRect bounds = NSRectToCGRect([[self mutableImageRectAttributes] relativeImageRect]);
    NSArray *clipPaths = [[self mutableClipPathsAttributes] clipPaths];
    if ([clipPaths count] != 0) {
        NSEnumerator *enumerator = [clipPaths objectEnumerator];
        id clipPath;
        while ((clipPath = [enumerator nextObject]) != nil)
            bounds = CGRectIntersection(bounds, CGEPathGetPathBoundingBox((CGPathRef)clipPath));
    }
    _startClipPathsBounds = CGRectApplyAffineTransform(bounds, [[self mutableClipPathsAttributes] relativeToObjectAffineTransform]);
}

- (BOOL)adjustSize:(NSSize *)aSize
{
    BOOL adjusted = [super adjustSize:aSize];
    if (![self isCrop])
        return adjusted;
    id geometry = [self mutableGeometryAttributes];
    NSInteger edges = [self modifyingEdges];
    if (edges & 5) {
        BOOL flipped = [geometry isFlippedHorizontally];
        float limit;
        if (((edges & 4) == 0 || flipped) && ((edges & 1) == 0 || !flipped))
            limit = [self startSize].width - CGRectGetMinX(_startClipPathsBounds);
        else
            limit = CGRectGetMaxX(_startClipPathsBounds);
        float scale = [geometry widthScale];
        if (limit * scale < aSize->width) {
            aSize->width = limit * scale;
            adjusted = YES;
        }
    }
    if (edges & 10) {
        BOOL flipped = [geometry isFlippedVertically];
        float limit;
        if (((edges & 8) == 0 || flipped) && ((edges & 2) == 0 || !flipped))
            limit = [self startSize].height - CGRectGetMinY(_startClipPathsBounds);
        else
            limit = CGRectGetMaxY(_startClipPathsBounds);
        float scale = [geometry heightScale];
        if (limit * scale < aSize->height) {
            aSize->height = limit * scale;
            adjusted = YES;
        }
    }
    return adjusted;
}

- (void)didResizeCardObject
{
    if (![self isCrop])
        return;
    id geometry = [self mutableGeometryAttributes];
    NSSize size = [(id<HSGeometryAttributes>)geometry size];
    NSInteger edges = [self modifyingEdges];
    NSRect imageRect = _imageRectBeforeResize;
    if ([self isResizesAboutCenter]) {
        imageRect.origin.x = (size.width - _sizeBeforeResize.width) * 0.5 + imageRect.origin.x;
        imageRect.origin.y = (size.height - _sizeBeforeResize.height) * 0.5 + imageRect.origin.y;
    } else {
        if (edges & ([geometry isFlippedHorizontally] ? 4 : 1))
            imageRect.origin.x = (size.width - _sizeBeforeResize.width) + imageRect.origin.x;
        if (edges & ([geometry isFlippedVertically] ? 8 : 2))
            imageRect.origin.y = (size.height - _sizeBeforeResize.height) + imageRect.origin.y;
    }
    [[self mutableImageRectAttributes] setImageRect:imageRect];
}

- (void)willResizeCardObject
{
    _imageRectBeforeResize = [[self mutableImageRectAttributes] imageRect];
    _sizeBeforeResize = [(id<HSGeometryAttributes>)[self mutableGeometryAttributes] size];
}

- (void)flagsChanged:(id)aChanged inView:(id)aView
{
    [super flagsChanged:aChanged inView:aView];
    BOOL isCrop = [self isCropForEvent:aChanged];
    id cacheAttributes = [[self trackingObject] queryHyperInterface:@protocol(HSImageCacheAttributes)];
    [cacheAttributes setEnabledCacheImage:!isCrop];
    if (isCrop && [cacheAttributes needDisableBorderForCropping]) {
        id outline = [[self trackingObject] queryHyperInterface:@protocol(HSMutableOutlineAttributes)];
        if ([outline isHyperOutlineEnabled]) {
            [outline setHyperOutlineEnabled:NO];
            _needEnableOutline = YES;
        }
    }
    [self updateStartClipPathsBounds];
}

- (void)processMouseDown:(id)aDown inView:(id)aView
{
    [super processMouseDown:aDown inView:aView];
    [self updateStartClipPathsBounds];
}

- (void)mouseUp:(id)aUp inView:(id)aView
{
    NSRect relativeImageRect = [[self mutableImageRectAttributes] relativeImageRect];
    [[self mutableImageRectAttributes] setRelativeImageRect:_startRelativeImageRect];
    [super mouseUp:aUp inView:aView];
    [[self mutableImageRectAttributes] setRelativeImageRect:relativeImageRect];
    if (_needEnableOutline)
        [[[self trackingObject] queryHyperInterface:@protocol(HSMutableOutlineAttributes)] setHyperOutlineEnabled:YES];
    id cacheAttributes = [[self trackingObject] queryHyperInterface:@protocol(HSImageCacheAttributes)];
    BOOL wasDisabled = ![cacheAttributes isEnabledCacheImage];
    if (wasDisabled)
        [cacheAttributes setEnabledCacheImage:YES];
    [cacheAttributes forceRecacheIfNeededForGroupObjectsOnly:wasDisabled];
}

- (void)preprocessMouseDown:(id)aDown inView:(id)aView
{
    [super preprocessMouseDown:aDown inView:aView];
    BOOL isCrop = [self isCropForEvent:aDown];
    id cacheAttributes = [[self trackingObject] queryHyperInterface:@protocol(HSImageCacheAttributes)];
    [cacheAttributes setEnabledCacheImage:!isCrop];
    if (isCrop && [cacheAttributes needDisableBorderForCropping]) {
        id outline = [[self trackingObject] queryHyperInterface:@protocol(HSMutableOutlineAttributes)];
        if ([outline isHyperOutlineEnabled]) {
            [outline setHyperOutlineEnabled:NO];
            _needEnableOutline = YES;
        }
    }
    _startRelativeImageRect = [[self mutableImageRectAttributes] relativeImageRect];
}

@end
