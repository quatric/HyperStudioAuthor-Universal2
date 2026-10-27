#import "HSTrackingLoop.h"

// Optional autoscrolling-client callbacks (undeclared in the original headers).
@interface NSObject (HSTrackingLoopAutoscrollingClient)
- (BOOL)trackingLoop:(id)aLoop shouldAutoscrollWithMouseEvent:(id)aEvent;
- (void)trackingLoop:(id)aLoop didAutoscrollWithMouseEvent:(id)aEvent;
@end

// Modal mouse-tracking loop started from a mouse-down: forwards drag, up, key
// and modifier events to the client, coalesces queued drags, and autoscrolls
// the view's scroll view with periodic events while dragging outside it.
@implementation HSTrackingLoop
+ (id)autoscrollingTrackingLoopWithView:(id)aView client:(id)aClient
{
    return [[[self alloc] initWithView:aView client:aClient autoscrolling:YES] autorelease];
}
+ (id)nonAutoscrollingTrackingLoopWithView:(id)aView client:(id)aClient
{
    return [[[self alloc] initWithView:aView client:aClient autoscrolling:NO] autorelease];
}
+ (id)trackingLoopWithView:(id)aView client:(id)aClient
{
    BOOL autoscrolling = [aClient conformsToProtocol:@protocol(HSAutoscrollingTrackingLoopClient)];
    return [[[self alloc] initWithView:aView client:aClient autoscrolling:autoscrolling] autorelease];
}
- (NSPoint)lastMouseLocation
{
    return _lastMouseLocation;
}
- (BOOL)wasTracked
{
    return _wasTracked;
}
- (BOOL)isTracking
{
    return _isTracking;
}
- (BOOL)isRunning
{
    return _isRunning;
}
- (void)pause
{
    _isRunning = NO;
}
- (void)resume
{
    _isRunning = YES;
}
- (void)abort
{
    _isAborted = YES;
}
- (void)runWithMouseDownEvent:(id)aEvent
{
    NSWindow *window = [_view window];
    id autoscrollingClient = [self autoscrollingClient];
    _isRunning = YES;
    [_client handleMouseDown:aEvent inTrackingLoop:self];
    [self updateCursorWithMouseEvent:aEvent handledByView:NULL];
    _lastMouseLocation = [_view convertPoint:[(NSEvent *)aEvent locationInWindow] fromView:nil];
    BOOL handlesKeyDown = [_client respondsToSelector:@selector(handleKeyDown:inTrackingLoop:)];
    BOOL handlesKeyUp = [_client respondsToSelector:@selector(handleKeyUp:inTrackingLoop:)];
    NSEvent *autoscrollEvent = nil;
    NSAutoreleasePool *pool = nil;

    while (!_isAborted) {
        [pool release];
        pool = [NSAutoreleasePool new];
        NSEvent *event = [window nextEventMatchingMask:NSUIntegerMax];
        NSEventType type = [event type];
        if (type == NSEventTypeLeftMouseDragged) {
            // Coalesce queued drags up to the next event that needs handling.
            NSEvent *next;
            while ((next = [window nextEventMatchingMask:NSUIntegerMax untilDate:nil inMode:@"HSEventQueueParsingRunLoopMode" dequeue:NO]) != nil) {
                NSEventType nextType = [next type];
                if (nextType == NSEventTypeLeftMouseUp || nextType == NSEventTypeFlagsChanged
                    || (nextType == NSEventTypePeriodic && autoscrollingClient)
                    || (nextType == NSEventTypeKeyDown && handlesKeyDown)
                    || (nextType == NSEventTypeKeyUp && handlesKeyUp))
                    break;
                if (nextType == NSEventTypeLeftMouseDragged)
                    event = next;
                [window nextEventMatchingMask:NSUIntegerMax untilDate:nil inMode:@"HSEventQueueParsingRunLoopMode" dequeue:YES];
            }
        }

        switch (type) {
        case NSEventTypeLeftMouseUp:
            [_client handleMouseUp:event inTrackingLoop:self];
            _isTracking = NO;
            _isRunning = NO;
            break;
        case NSEventTypeLeftMouseDragged:
            _isTracking = YES;
            _wasTracked = YES;
            if (autoscrollingClient && autoscrollEvent) {
                [autoscrollEvent release];
                [NSEvent stopPeriodicEvents];
                autoscrollEvent = nil;
            }
            if (autoscrollingClient && [self mouseEventShouldCauseAutoscrolling:event withClient:autoscrollingClient]) {
                if (!_isRunning)
                    break;
                NSRect visibleRect = [_view convertRect:[_view visibleRect] toView:nil];
                NSRect insetRect = NSInsetRect(visibleRect, -5.0, -5.0);
                NSPoint location = [event locationInWindow];
                NSEvent *scrollEvent = event;
                if (!NSPointInRect(location, insetRect)) {
                    // Pull the point back to just outside the visible area so
                    // scrolling advances at a steady pace.
                    NSPoint point = location;
                    if (location.x < insetRect.origin.x)
                        point.x = [event deltaX] > 0.0 ? visibleRect.origin.x : insetRect.origin.x;
                    else if (location.x > NSMaxX(insetRect))
                        point.x = [event deltaX] < 0.0 ? NSMaxX(visibleRect) : NSMaxX(insetRect);
                    if (location.y < insetRect.origin.y)
                        point.y = [event deltaY] >= 0.0 ? insetRect.origin.y : visibleRect.origin.y;
                    else if (location.y > NSMaxY(insetRect))
                        point.y = [event deltaY] > 0.0 ? NSMaxY(visibleRect) : NSMaxY(insetRect);
                    if (!NSEqualPoints(point, location)) {
                        scrollEvent = [NSEvent mouseEventWithType:[event type] location:point
                                                    modifierFlags:[event modifierFlags] timestamp:[event timestamp]
                                                     windowNumber:[event windowNumber] context:nil
                                                      eventNumber:[event eventNumber] + 1 clickCount:[event clickCount]
                                                         pressure:[event pressure]];
                        // The original also passes [event context] (removed in 10.12; always nil).
                    }
                }
                autoscrollEvent = [scrollEvent retain];
                [NSEvent startPeriodicEventsAfterDelay:0.15 withPeriod:0.15];
                [self autoscrollWithMouseDraggedEvent:autoscrollEvent withClient:autoscrollingClient];
            } else if (_isRunning) {
                [_client handleMouseDragged:event inTrackingLoop:self];
            }
            break;
        case NSEventTypeKeyDown:
            if (handlesKeyDown)
                [_client handleKeyDown:event inTrackingLoop:self];
            break;
        case NSEventTypeKeyUp:
            if (handlesKeyUp)
                [_client handleKeyUp:event inTrackingLoop:self];
            break;
        case NSEventTypeFlagsChanged:
            [_client handleFlagsChanged:event inTrackingLoop:self];
            continue; // No cursor update for modifier changes.
        case NSEventTypePeriodic:
            if (autoscrollingClient && autoscrollEvent)
                [self autoscrollWithMouseDraggedEvent:autoscrollEvent withClient:autoscrollingClient];
            break;
        default:
            break;
        }

        BOOL handledByView = NO;
        [self updateCursorWithMouseEvent:event handledByView:&handledByView];
        if (!_isRunning) {
            if (!handledByView)
                [(HSView *)_view updateCursorWithMouseEvent:event];
            break;
        }
        if (type == NSEventTypeLeftMouseDragged)
            _lastMouseLocation = [_view convertPoint:[event locationInWindow] fromView:nil];
    }
    [pool release];
    if (autoscrollEvent) {
        [autoscrollEvent release];
        [NSEvent stopPeriodicEvents];
    }
}
- (void)updateCursorWithMouseEvent:(id)aEvent handledByView:(BOOL *)aView
{
    id cursor = nil;
    if (_clientImplementsCursorOverriding)
        cursor = [_client cursorWithMouseEvent:aEvent inTrackingLoop:self];
    if (cursor == nil)
        cursor = [self cursor];
    if (cursor == nil)
        [(HSView *)_view updateCursorWithMouseEvent:aEvent];
    else
        [(NSCursor *)cursor set];
    if (aView)
        *aView = (cursor == nil);
}
- (void)autoscrollWithMouseDraggedEvent:(id)aEvent withClient:(id)aClient
{
    [_client handleMouseDragged:aEvent inTrackingLoop:self];
    if ([aClient respondsToSelector:@selector(trackingLoop:didAutoscrollWithMouseEvent:)])
        [aClient trackingLoop:self didAutoscrollWithMouseEvent:aEvent];
    [_view autoscroll:aEvent];
}
static BOOL HSTrackingLoop_approximatelyEqual(CGFloat aValue1, CGFloat aSize1, CGFloat aValue2, CGFloat aSize2, CGFloat aScale)
{
    return fabs(aValue1 - aValue2) <= aScale * 0.0005 && fabs(aSize1 - aSize2) <= aScale * 0.0005;
}
static CGFloat HSTrackingLoop_scale(CGFloat aOrigin1, CGFloat aSize1, CGFloat aOrigin2, CGFloat aSize2)
{
    CGFloat scale1 = fabs(aOrigin1) + aSize1;
    CGFloat scale2 = fabs(aOrigin2) + aSize2;
    scale1 = scale1 != 0.0 ? fabs(scale1) : 1.0;
    scale2 = scale2 != 0.0 ? fabs(scale2) : 1.0;
    return MAX(scale1, scale2);
}
- (BOOL)mouseEventShouldCauseAutoscrolling:(id)aAutoscrolling withClient:(id)aClient
{
    NSClipView *clipView = [[_view enclosingScrollView] contentView];
    NSPoint location = [(NSEvent *)aAutoscrolling locationInWindow];
    if (clipView == nil)
        return NO;
    NSRect bounds = [_view bounds];
    NSRect visible = NSIntersectionRect([clipView documentVisibleRect], [_view bounds]);
    CGFloat xScale = HSTrackingLoop_scale(bounds.origin.x, bounds.size.width, visible.origin.x, visible.size.width);
    CGFloat yScale = HSTrackingLoop_scale(bounds.origin.y, bounds.size.height, visible.origin.y, visible.size.height);
    BOOL isFullyVisible = HSTrackingLoop_approximatelyEqual(visible.origin.x, visible.size.width, bounds.origin.x, bounds.size.width, xScale)
        && HSTrackingLoop_approximatelyEqual(visible.origin.y, visible.size.height, bounds.origin.y, bounds.size.height, yScale);
    BOOL isInside = NSPointInRect([clipView convertPoint:location fromView:nil], [clipView bounds]);
    if (isFullyVisible || isInside)
        return NO;
    if (![aClient respondsToSelector:@selector(trackingLoop:shouldAutoscrollWithMouseEvent:)])
        return YES;
    return [aClient trackingLoop:self shouldAutoscrollWithMouseEvent:aAutoscrolling];
}
- (void)setCursor:(id)aCursor
{
    if (_cursor != aCursor) {
        [_cursor autorelease];
        _cursor = [aCursor retain];
    }
}
- (id)cursor
{
    return _cursor;
}
- (id)autoscrollingClient
{
    return _isAutoscrollingEnabled ? _client : nil;
}
- (id)client
{
    return _client;
}
- (BOOL)supportsAutoscrolling
{
    return _isAutoscrollingEnabled;
}
- (id)view
{
    return _view;
}
- (void)dealloc
{
    [_view release];
    [_cursor release];
    [super dealloc];
}
- (id)initWithView:(id)aView client:(id)aClient autoscrolling:(BOOL)aAutoscrolling
{
    self = [super init];
    if (self) {
        _view = [aView retain];
        _client = aClient;
        _isAutoscrollingEnabled = aAutoscrolling;
        _clientImplementsCursorOverriding = [aClient respondsToSelector:@selector(cursorWithMouseEvent:inTrackingLoop:)];
    }
    return self;
}
@end
