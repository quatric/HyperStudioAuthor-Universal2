#import "HSMovableImageView.h"

// Magnitude used for relative comparisons, zero counting as 1.
static float HSMovableMagnitude(float aValue)
{
    return aValue != 0.0f ? fabsf(aValue) : 1.0f;
}

static BOOL HSMovableIsZero(float aValue)
{
    float magnitude = HSMovableMagnitude(aValue);
    float tolerance = magnitude > 1.0f ? magnitude * 0.0005f : 0.0005f;
    return fabsf(0.0f - aValue) <= tolerance;
}

@implementation HSMovableImageView

- (NSSize)imageViewSize
{
    return _viewRectSize;
}

- (void)dealloc
{
    [_previewImage release];
    [super dealloc];
}

- (id)image
{
    return _previewImage;
}

- (void)setImage:(id)aImage resetPosition:(BOOL)aPosition viewRectSize:(NSSize)aSize imageScaling:(NSUInteger)aScaling
{
    if (_previewImage == aImage) {
        [super setNeedsDisplay:YES];
        return;
    }
    [_previewImage release];
    _previewImage = [aImage retain];
    if (_previewImage != nil) {
        NSSize viewSize = aSize;
        NSSize oldImageSize = _imageSize;
        NSPoint oldDrawPoint = _currentDrawPoint;
        _currentDrawPoint = NSZeroPoint;
        _maxDragSize = NSZeroSize;
        _viewRectSize = NSZeroSize;
        _horizontalScale = 1.0f;
        _verticalScale = 1.0f;
        _imageSize = [_previewImage size];
        if (HSMovableIsZero(_imageSize.width) || HSMovableIsZero(_imageSize.height))
            goto done;
        if (NSEqualSizes(NSZeroSize, aSize)) {
            viewSize = _imageSize;
        } else {
            if (HSMovableIsZero(viewSize.width))
                viewSize.width = 1.5f;
            else if (HSMovableIsZero(viewSize.height))
                viewSize.height = 1.5f;
            if (aScaling == 0) {
                float imageWidth = _imageSize.width, imageHeight = _imageSize.height;
                if (imageWidth - MAX(HSMovableMagnitude(viewSize.width), HSMovableMagnitude(imageWidth)) * 0.0005f <= viewSize.width
                    && imageHeight - MAX(HSMovableMagnitude(viewSize.height), HSMovableMagnitude(imageHeight)) * 0.0005f <= viewSize.height) {
                    viewSize = _imageSize;
                } else {
                    double widthRatio = MAX(0.0, (double)(viewSize.width / imageWidth));
                    double heightRatio = MAX(0.0, (double)(viewSize.height / imageHeight));
                    float aspect = imageWidth / imageHeight;
                    if (widthRatio < heightRatio)
                        viewSize.height = viewSize.width / aspect;
                    else
                        viewSize.width = aspect * viewSize.height;
                }
            }
        }
        _viewRectSize = viewSize;
        NSRect bounds = [self bounds];
        float overflowWidth = _viewRectSize.width - bounds.size.width;
        float overflowHeight = _viewRectSize.height - bounds.size.height;
        _maxDragSize.width = fmaxf(overflowWidth, 0.0f);
        _maxDragSize.height = fmaxf(overflowHeight, 0.0f);
        BOOL zeroWidth = HSMovableIsZero(_maxDragSize.width);
        BOOL zeroHeight = HSMovableIsZero(_maxDragSize.height);
        if (zeroWidth || zeroHeight) {
            if (!aPosition && _movableImageViewFlags.isZeroHorizontalDragSize == zeroWidth && _movableImageViewFlags.isZeroVerticalDragSize == zeroHeight) {
                _currentDrawPoint = oldDrawPoint;
            } else {
                _movableImageViewFlags.isZeroHorizontalDragSize = zeroWidth;
                _movableImageViewFlags.isZeroVerticalDragSize = zeroHeight;
                _currentDrawPoint.x = zeroWidth ? overflowWidth * 0.5f : _maxDragSize.width;
                _currentDrawPoint.y = zeroHeight ? overflowHeight * 0.5f : _maxDragSize.height;
            }
        } else if (!aPosition && NSEqualSizes(oldImageSize, _imageSize)) {
            _currentDrawPoint = oldDrawPoint;
        }
        _movableImageViewFlags.isVerticalMoveReversed = [aImage isFlipped] != [self isFlipped];
        _horizontalScale = _imageSize.width / _viewRectSize.width;
        _verticalScale = _imageSize.height / _viewRectSize.height;
    }
done:
    [self resetCursorRects];
    [super setNeedsDisplay:YES];
}

- (void)setImage:(id)aImage resetPosition:(BOOL)aPosition viewRectSize:(NSSize)aSize
{
    [self setImage:aImage resetPosition:aPosition viewRectSize:aSize imageScaling:1];
}

- (void)drawRect:(NSRect)aRect
{
    [super drawRect:aRect];
    if (_previewImage != nil && !HSMovableIsZero(_imageSize.width) && !HSMovableIsZero(_imageSize.height)) {
        // Fix: drew through a separate window graphics context at the view's frame; layer-backed views
        // never show that, so draw into the current context at the same spot in view coordinates.
        NSRect frame = [super frame];
        NSRect destRect = NSMakeRect(0.0, 0.0, frame.size.width, frame.size.height);
        NSRect sourceRect = NSMakeRect(_currentDrawPoint.x * _horizontalScale, _currentDrawPoint.y * _verticalScale, _horizontalScale * frame.size.width, _verticalScale * frame.size.height);
        [_previewImage drawInRect:destRect fromRect:sourceRect operation:NSCompositingOperationSourceOver fraction:1.0];
    }
}

- (void)resetCursorRects
{
    [super discardCursorRects];
    if (HSMovableIsZero(_maxDragSize.width) && HSMovableIsZero(_maxDragSize.height))
        return;
    NSCursor *cursor = (_movableImageViewFlags.isTracking || _movableImageViewFlags.isMouseDownNow) ? [NSCursor closedHandCursor] : [NSCursor openHandCursor];
    [super addCursorRect:[super visibleRect] cursor:cursor];
    [cursor setOnMouseEntered:YES];
    if (_movableImageViewFlags.isForMouseEvent)
        [(NSCursor *)cursor set];
}

- (id)initWithFrame:(NSRect)aFrame
{
    self = [super initWithFrame:aFrame];
    if (self != nil) {
        _horizontalScale = 1.0f;
        _verticalScale = 1.0f;
    }
    return self;
}

@end

@implementation HSMovableImageView (MouseHandling)

- (void)handleMouseDragged:(id)aDragged
{
    if (!_movableImageViewFlags.isTracking)
        return;
    NSPoint point = [self convertPoint:[aDragged locationInWindow] fromView:nil];
    if (_maxDragSize.width != 0.0f)
        _currentDrawPoint.x = fminf(_maxDragSize.width, fmaxf(0.0f, _currentDrawPoint.x - (point.x - _dragPoint.x)));
    if (_maxDragSize.height != 0.0f) {
        float deltaY = _movableImageViewFlags.isVerticalMoveReversed ? _dragPoint.y - point.y : point.y - _dragPoint.y;
        _currentDrawPoint.y = fminf(_maxDragSize.height, fmaxf(0.0f, _currentDrawPoint.y - deltaY));
    }
    _dragPoint = point;
    [self setNeedsDisplay:YES];
}

- (void)mouseDown:(id)aDown
{
    if (HSMovableIsZero(_maxDragSize.width) && HSMovableIsZero(_maxDragSize.height)) {
        [super mouseDown:aDown];
        return;
    }
    NSWindow *window = [self window];
    _dragPoint = [aDown locationInWindow];
    _dragPoint = [self convertPoint:_dragPoint fromView:nil];
    _movableImageViewFlags.isMouseDownNow = 1;
    [self resetCursorRectsForEvent:aDown];
    BOOL done = NO;
    while (!done) {
        NSEvent *event = [window nextEventMatchingMask:NSEventMaskLeftMouseUp | NSEventMaskLeftMouseDragged];
        if (event == nil)
            break;
        NSEventType type = [event type];
        if (type == NSEventTypeLeftMouseUp) {
            _movableImageViewFlags.isMouseDownNow = 0;
            if (_movableImageViewFlags.isTracking) {
                [window discardEventsMatchingMask:NSEventMaskAny beforeEvent:event];
                _movableImageViewFlags.isTracking = 0;
            }
            [self resetCursorRectsForEvent:event];
            done = YES;
        } else if (type == NSEventTypeLeftMouseDragged) {
            _movableImageViewFlags.isTracking = 1;
            [self handleMouseDragged:event];
        }
        [self displayIfNeeded];
    }
}

- (void)resetCursorRectsForEvent:(id)aEvent
{
    _movableImageViewFlags.isForMouseEvent = 1;
    [self resetCursorRects];
    _movableImageViewFlags.isForMouseEvent = 0;
}

@end
