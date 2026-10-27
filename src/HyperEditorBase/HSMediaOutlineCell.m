#import "HSMediaOutlineCell.h"

// A media library outline cell: an icon, the text and an action button at
// the right edge (a strip of square frames: normal, rolled over, pressed,
// then the same highlighted), all from a dictionary object value.

enum {
    HSActionStateNormal = 1,
    HSActionStatePressed = 2,
    HSActionStateRolledOver = 3
};

static NSRect HSActionRect(NSRect aRect)
{
    return NSMakeRect(aRect.origin.x + aRect.size.width - 2.0 - aRect.size.height, aRect.origin.y, aRect.size.height, aRect.size.height);
}

// compositeToPoint: in the original.
static void HSMediaOutlineCellComposite(NSImage *aImage, NSPoint aPoint, NSRect aFromRect, BOOL aFlipped)
{
    NSSize size = NSEqualRects(aFromRect, NSZeroRect) ? [aImage size] : aFromRect.size;
    NSRect rect = NSMakeRect(aPoint.x, aFlipped ? aPoint.y - size.height : aPoint.y, size.width, size.height);
    [aImage drawInRect:rect fromRect:aFromRect operation:NSCompositingOperationSourceOver fraction:1.0 respectFlipped:YES hints:nil];
}

@implementation HSMediaOutlineCell

// Rolled over until the mouse leaves the button or clicks.
- (BOOL)trackActionMoveMouse:(id)aMouse inRect:(NSRect)aRect ofView:(id)aView
{
    NSView *view = aView;
    NSRect actionRect = HSActionRect(aRect);
    _actionState = HSActionStateRolledOver;
    _lastMousePoint = [view convertPoint:[(NSEvent *)aMouse locationInWindow] fromView:[[view window] contentView]];
    [view displayRect:aRect];
    NSEvent *event;
    // Fix: the original waited for a mask of 1 (no event type).
    while ((event = [[view window] nextEventMatchingMask:NSEventMaskMouseMoved | NSEventMaskLeftMouseDown])) {
        NSPoint point = [view convertPoint:[event locationInWindow] fromView:[[view window] contentView]];
        BOOL wasInside = NSMouseInRect(_lastMousePoint, actionRect, [view isFlipped]);
        if (NSMouseInRect(point, actionRect, [view isFlipped]) != wasInside)
            break;
        if ([event type] == NSEventTypeLeftMouseDown)
            break;
        _lastMousePoint = point;
    }
    _actionState = HSActionStateNormal;
    [view displayRect:aRect];
    return YES;
}

// Pressed while the mouse is in the button; sends the action when it's
// released there.
- (BOOL)trackActionMouse:(id)aMouse inRect:(NSRect)aRect ofView:(id)aView
{
    NSView *view = aView;
    NSRect actionRect = HSActionRect(aRect);
    _actionState = HSActionStatePressed;
    _lastMousePoint = [view convertPoint:[(NSEvent *)aMouse locationInWindow] fromView:[[view window] contentView]];
    [view displayRect:aRect];
    BOOL released = NO;
    NSEvent *event;
    do {
        event = [[view window] nextEventMatchingMask:NSEventMaskLeftMouseUp | NSEventMaskLeftMouseDragged];
        if (event == nil)
            break;
        NSPoint point = [view convertPoint:[event locationInWindow] fromView:[[view window] contentView]];
        BOOL wasInside = NSMouseInRect(_lastMousePoint, actionRect, [view isFlipped]);
        BOOL isInside = NSMouseInRect(point, actionRect, [view isFlipped]);
        if ([event type] == NSEventTypeLeftMouseUp) {
            _actionState = HSActionStateNormal;
            [view displayRect:aRect];
            if (isInside) {
                NSDictionary *object = [self hyperRepresentedObject];
                id target = [object objectForKey:actionTargetKey];
                SEL selector = [[object objectForKey:actionSelectorKey] pointerValue];
                if (target != nil && selector != NULL)
                    [target performSelector:selector withObject:self];
            }
            released = YES;
        } else if ([event type] == NSEventTypeLeftMouseDragged) {
            if (wasInside != isInside) {
                _actionState = isInside ? HSActionStatePressed : HSActionStateNormal;
                [view displayRect:aRect];
            }
            _lastMousePoint = point;
        }
    } while (_actionState != HSActionStateNormal);
    [view displayRect:aRect];
    return released;
}

- (BOOL)mouseMoved:(id)aMoved inRect:(NSRect)aRect ofView:(id)aView
{
    NSView *view = aView;
    id target = [[self hyperRepresentedObject] objectForKey:actionTargetKey];
    NSPoint point = [view convertPoint:[(NSEvent *)aMoved locationInWindow] fromView:[[view window] contentView]];
    if (target != nil && NSMouseInRect(point, HSActionRect(aRect), [view isFlipped]))
        return [self trackActionMoveMouse:aMoved inRect:aRect ofView:aView];
    return NO;
}

- (BOOL)mouseDown:(id)aDown inRect:(NSRect)aRect ofView:(id)aView
{
    NSView *view = aView;
    id target = [[self hyperRepresentedObject] objectForKey:actionTargetKey];
    NSPoint point = [view convertPoint:[(NSEvent *)aDown locationInWindow] fromView:[[view window] contentView]];
    if (target != nil && NSMouseInRect(point, HSActionRect(aRect), [view isFlipped]))
        return [self trackActionMouse:aDown inRect:aRect ofView:aView];
    return NO;
}

- (void)drawInteriorWithFrame:(NSRect)aFrame inView:(id)aView
{
    NSDictionary *object = [self hyperRepresentedObject];
    BOOL flipped = [(NSView *)aView isFlipped];
    NSImage *image = [object objectForKey:imageKey];
    if (image != nil) {
        HSMediaOutlineCellComposite(image, NSMakePoint(aFrame.origin.x + 2.0, aFrame.origin.y + aFrame.size.height), NSZeroRect, flipped);
        aFrame.origin.x += 2.0 + 2.0 + aFrame.size.height;
        aFrame.size.width = aFrame.size.width - aFrame.size.height - 2.0 - 2.0;
    }
    NSImage *actionImage = [object objectForKey:actionImageKey];
    if (actionImage != nil) {
        NSSize size = [actionImage size];
        CGFloat right = aFrame.origin.x + aFrame.size.width;
        aFrame.size.width = aFrame.size.width - aFrame.size.height - 2.0 - 2.0;
        CGFloat frameX;
        if (_actionState == HSActionStateRolledOver)
            frameX = size.height;
        else if (_actionState == HSActionStatePressed)
            frameX = size.height + size.height;
        else
            frameX = 0;
        if ([self isHighlighted] && size.height * 3.0 <= size.width)
            frameX += size.width * 0.5;
        NSPoint point = NSMakePoint(right - 2.0 - size.height, size.height * 0.5 + aFrame.size.height * 0.5 + aFrame.origin.y);
        HSMediaOutlineCellComposite(actionImage, point, NSMakeRect(frameX, 0, size.height, size.height), flipped);
    }
    [super drawInteriorWithFrame:aFrame inView:aView];
}

- (void)selectWithFrame:(NSRect)aFrame inView:(id)aView editor:(id)aEditor delegate:(id)aDelegate start:(NSInteger)aStart length:(NSInteger)aLength
{
    NSDictionary *object = [self hyperRepresentedObject];
    if ([object objectForKey:imageKey] != nil) {
        aFrame.origin.x += aFrame.size.height + 4.0;
        aFrame.size.width -= aFrame.size.height + 4.0;
    }
    if ([object objectForKey:actionImageKey] != nil)
        aFrame.size.width -= aFrame.size.height + 4.0;
    [super selectWithFrame:aFrame inView:aView editor:aEditor delegate:aDelegate start:aStart length:aLength];
}

// A dictionary with a text is kept, showing the text.
- (void)setObjectValue:(id)aValue
{
    if ([aValue isKindOfClass:[NSDictionary class]]) {
        id text = [aValue objectForKey:textKey];
        if (text != nil) {
            [self setHyperRepresentedObject:aValue];
            [super setObjectValue:text];
            return;
        }
    }
    [super setObjectValue:aValue];
}

- (id)copyWithZone:(NSZone *)aZone
{
    id object = [[self hyperRepresentedObject] retain];
    HSMediaOutlineCell *copy = [super copyWithZone:aZone];
    copy->_hyperRepresentedObject = [object copyWithZone:aZone];
    [object release];
    return copy;
}

- (void)setHyperRepresentedObject:(id)aObject
{
    if (_hyperRepresentedObject != aObject) {
        [_hyperRepresentedObject release];
        _hyperRepresentedObject = [aObject retain];
    }
}

- (id)hyperRepresentedObject
{
    return _hyperRepresentedObject;
}

- (void)dealloc
{
    [_hyperRepresentedObject release];
    [super dealloc];
}

- (id)init
{
    if ((self = [super init])) {
        [self setControlSize:NSControlSizeSmall];
        [self setFont:[NSFont systemFontOfSize:[NSFont smallSystemFontSize]]];
        [self setLineBreakMode:NSLineBreakByTruncatingTail];
    }
    return self;
}

@end
