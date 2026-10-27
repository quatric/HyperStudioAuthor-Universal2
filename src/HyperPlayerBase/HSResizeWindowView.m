#import "HSResizeWindowView.h"
// A resize grip image in the bottom right corner (inset by the margins);
// dragging it resizes the window, keeping its top left corner in place.
@implementation HSResizeWindowView
- (void)setResizeBottomMargin:(CGFloat)aMargin
{
    _resizeBottomMargin = aMargin;
}
- (CGFloat)resizeBottomMargin
{
    return _resizeBottomMargin;
}
- (void)setResizeRightMargin:(CGFloat)aMargin
{
    _resizeRightMargin = aMargin;
}
- (CGFloat)resizeRightMargin
{
    return _resizeRightMargin;
}
- (id)image
{
    return _image;
}
- (void)setImage:(id)aImage
{
    if (_image != aImage) {
        [_image release];
        _image = [aImage retain];
    }
}
// Tracks the drag until the mouse goes up, posting begin (once) and end
// notifications with the window. The width follows the mouse's x (kept at the
// grip's offset when clamped); the height grows as the mouse goes down: as the
// window's bottom follows the mouse, the mouse's y in the window stays at the
// first event's while the mouse is still. Sizes are kept within the window's
// min and max sizes (a zero max size is no maximum). The original clamps a
// width or height under the minimum to a zero maximum when there's none;
// fixed.
- (void)resizeWindowWithEvent:(id)aEvent
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    NSWindow *window = [self window];
    NSRect frame = [window frame];
    CGFloat width = frame.size.width, height = frame.size.height;
    NSSize minSize = [window minSize], maxSize = [window maxSize];
    BOOL noMaximum = NSEqualSizes(maxSize, NSZeroSize);
    CGFloat top = frame.origin.y + frame.size.height;
    NSPoint start = [aEvent locationInWindow];
    CGFloat gripOffset = frame.size.width - start.x;
    CGFloat lastX = start.x;
    NSEventType type;
    do {
        NSEvent *event = [window nextEventMatchingMask:NSEventMaskLeftMouseUp | NSEventMaskLeftMouseDragged];
        NSPoint location = [event locationInWindow];
        type = [event type];
        if (type != NSEventTypeLeftMouseUp && type != NSEventTypeLeftMouseDragged)
            continue;
        if (NSEqualPoints(location, NSMakePoint(lastX, start.y)))
            continue;
        if (!_beginSended) {
            [center postNotificationName:@"HSResizeWindowViewBeginResizeNotification" object:window userInfo:nil];
            _beginSended = YES;
        }
        CGFloat newWidth = width + (location.x - lastX);
        CGFloat newLastX = location.x;
        if ((!noMaximum && newWidth > maxSize.width) || newWidth < minSize.width) {
            newWidth = newWidth < minSize.width ? minSize.width : maxSize.width;
            newLastX = newWidth - gripOffset;
        }
        CGFloat newHeight = height + (start.y - location.y);
        if ((!noMaximum && newHeight > maxSize.height) || newHeight < minSize.height)
            newHeight = newHeight < minSize.height ? minSize.height : maxSize.height;
        if (!NSEqualSizes(frame.size, NSMakeSize(newWidth, newHeight))) {
            frame = NSMakeRect(frame.origin.x, top - newHeight, newWidth, newHeight);
            [window setFrame:frame display:YES];
            frame = [window frame];
        }
        width = newWidth;
        height = newHeight;
        lastX = newLastX;
    } while (type != NSEventTypeLeftMouseUp);
    [center postNotificationName:@"HSResizeWindowViewEndResizeNotification" object:window userInfo:nil];
}
- (void)mouseDown:(id)aDown
{
    NSPoint point = [self convertPoint:[aDown locationInWindow] fromView:nil];
    NSRect bounds = [self bounds];
    NSSize size = [_image size];
    NSRect grip = NSMakeRect(bounds.origin.x + bounds.size.width - size.width - _resizeRightMargin, _resizeBottomMargin, size.width, size.height);
    if (NSPointInRect(point, grip))
        [self resizeWindowWithEvent:aDown];
}
- (void)drawRect:(NSRect)aRect
{
    NSRect bounds = [self bounds];
    NSSize size = [_image size];
    [_image drawAtPoint:NSMakePoint(bounds.origin.x + bounds.size.width - size.width - _resizeRightMargin, _resizeBottomMargin) fromRect:NSZeroRect operation:NSCompositingOperationSourceOver fraction:1];
}
- (BOOL)isOpaque
{
    return NO;
}
// The image is released here (leaked in the original).
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_image release];
    [super dealloc];
}
@end
