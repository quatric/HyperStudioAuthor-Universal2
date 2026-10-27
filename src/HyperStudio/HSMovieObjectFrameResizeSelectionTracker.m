#import "HSMovieObjectFrameResizeSelectionTracker.h"

// Moves the relative source rect origin by the size change on the dragged edges.
static void HSMoveCropOrigin(id aGeometry, NSInteger aEdges, BOOL aAboutCenter, float *aX, float *aY, float aDeltaWidth, float aDeltaHeight)
{
    if (!aAboutCenter) {
        if (aEdges & ([aGeometry isFlippedHorizontally] ? 4 : 1))
            *aX -= aDeltaWidth;
        if (aEdges & ([aGeometry isFlippedVertically] ? 2 : 8))
            *aY -= aDeltaHeight;
    }
    else {
        if (aEdges & 5)
            *aX += aDeltaWidth * -0.5f;
        if (aEdges & 10)
            *aY += aDeltaHeight * -0.5f;
    }
}

// Keeps a relative origin/length pair inside 0...1; about the center both sides shrink.
static void HSClampCropAxis(float *aOrigin, float *aLength, BOOL aAboutCenter)
{
    if (*aOrigin < 0.0f) {
        *aLength = (float)(*aLength + *aOrigin * (aAboutCenter ? 2.0 : 1.0));
        *aOrigin = 0.0f;
    }
    if (*aOrigin + *aLength > 1.0f) {
        if (aAboutCenter)
            *aOrigin = (float)((double)(*aOrigin + *aLength) - 1.0 + *aOrigin);
        *aLength = 1.0f - *aOrigin;
    }
}

@implementation HSMovieObjectFrameResizeSelectionTracker

- (void)mouseUp:(id)aUp inView:(id)aView
{
    id attributes;
    NSRect rect;
    NSUndoManager *undoManager;

    [[[self mutableMovieAttributes] attributeObservingController] endContinuousChangeOfAttribute:@protocol(HSRelativeMovieSourceRectAttribute)];
    [super mouseUp:aUp inView:aView];
    attributes = [self mutableMovieAttributes];
    rect = [attributes relativeMovieSourceRect];
    // Registers one undo step from the rectangle at mouse down.
    undoManager = [[[self trackingObject] hyperObject] undoManager];
    [undoManager disableUndoRegistration];
    [attributes setRelativeMovieSourceRect:_startRelativeMovieSourceRect];
    [undoManager enableUndoRegistration];
    [attributes setRelativeMovieSourceRect:rect];
}

- (BOOL)adjustSize:(NSSize *)aSize
{
    BOOL changed = [super adjustSize:aSize];
    id movieAttributes = [[self trackingObject] queryHyperInterface:@protocol(HSMovieObjectQTVRMovieAttributes)];
    id geometry;
    NSRect rect;
    float x, y, width, height;
    NSInteger edges;
    BOOL aboutCenter;

    if (![self isCrop] || [movieAttributes isHyperQTVR] || [movieAttributes isHyperPanoramaObject])
        return changed;
    rect = [[self mutableMovieAttributes] relativeMovieSourceRect];
    geometry = [self geometryAttributes];
    x = rect.origin.x;
    y = rect.origin.y;
    height = aSize->height / _uncroppedFrameSize.height;
    width = aSize->width / _uncroppedFrameSize.width;
    edges = [self modifyingEdges];
    aboutCenter = [self isResizesAboutCenter];
    HSMoveCropOrigin(geometry, edges, aboutCenter, &x, &y, width - rect.size.width, height - rect.size.height);
    if (edges & 5) {
        HSClampCropAxis(&x, &width, aboutCenter);
        width *= _uncroppedFrameSize.width;
        if (aSize->width < width - 1.0f / 510.0f || width + 1.0f / 510.0f < aSize->width) {
            aSize->width = width;
            changed = YES;
        }
    }
    if (edges & 10) {
        HSClampCropAxis(&y, &height, aboutCenter);
        height *= _uncroppedFrameSize.height;
        if (aSize->height < height - 1.0f / 510.0f || height + 1.0f / 510.0f < aSize->height) {
            aSize->height = height;
            changed = YES;
        }
    }
    return changed;
}

- (void)didResizeCardObject
{
    id movieAttributes = [[self trackingObject] queryHyperInterface:@protocol(HSMovieObjectQTVRMovieAttributes)];
    id geometry;
    NSRect rect;
    NSSize frameSize;
    float x, y, width, height;
    BOOL aboutCenter;

    if (![self isCrop] || [movieAttributes isHyperQTVR] || [movieAttributes isHyperPanoramaObject])
        return;
    rect = [[self mutableMovieAttributes] relativeMovieSourceRect];
    geometry = [self geometryAttributes];
    frameSize = [geometry affineFrameSize];
    x = rect.origin.x;
    y = rect.origin.y;
    height = frameSize.height / _uncroppedFrameSize.height;
    width = frameSize.width / _uncroppedFrameSize.width;
    aboutCenter = [self isResizesAboutCenter];
    HSMoveCropOrigin(geometry, [self modifyingEdges], aboutCenter, &x, &y, width - rect.size.width, height - rect.size.height);
    HSClampCropAxis(&x, &width, aboutCenter);
    HSClampCropAxis(&y, &height, aboutCenter);
    [[self mutableMovieAttributes] setRelativeMovieSourceRect:NSMakeRect(x, y, width, height)];
}

- (void)processMouseDown:(id)aDown inView:(id)aView
{
    id attributes;
    NSSize frameSize;

    [super processMouseDown:aDown inView:aView];
    attributes = [self mutableMovieAttributes];
    _startRelativeMovieSourceRect = [attributes relativeMovieSourceRect];
    frameSize = [[self geometryAttributes] affineFrameSize];
    _uncroppedFrameSize.width = frameSize.width / _startRelativeMovieSourceRect.size.width;
    _uncroppedFrameSize.height = frameSize.height / _startRelativeMovieSourceRect.size.height;
    [[attributes attributeObservingController] beginContinuousChangeOfAttribute:@protocol(HSRelativeMovieSourceRectAttribute)];
}

- (id)mutableMovieAttributes
{
    return [[self trackingObject] queryHyperInterface:@protocol(HSMovieAttributes)];
}

@end
