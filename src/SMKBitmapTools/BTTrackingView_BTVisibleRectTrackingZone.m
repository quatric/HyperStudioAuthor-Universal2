#import "BTTrackingView_BTVisibleRectTrackingZone.h"
#import "NSWindow+BTEvents.h"

// Tracking rects that follow their view: a view's zones are reset when it
// moves to a window and when it or a superview changes frame or bounds, and
// a zone the mouse crossed while it was being moved gets a synthesized
// entered/exited event.

@implementation BTTrackingZone

- (id)view
{
    return nil;
}

- (id)owner
{
    return nil;
}

- (BOOL)isActive
{
    return NO;
}

- (NSRect)windowTrackingRect
{
    return NSZeroRect;
}

- (NSInteger)trackingRectTag
{
    return 0;
}

- (void)discard
{
}

@end

@implementation BTTrackingView_BTTrackingZone

- (id)init
{
    return [self initWithView:nil owner:nil];
}

// Neither is retained.
- (id)initWithView:(id)aView owner:(id)aOwner
{
    self = [super init];
    if (!self)
        return nil;
    _view = aView;
    _owner = aOwner;
    return self;
}

- (id)view
{
    return _view;
}

- (id)owner
{
    return _owner;
}

- (BOOL)isActive
{
    return !NSEqualRects(_windowTrackingRect, NSZeroRect);
}

- (NSRect)windowTrackingRect
{
    return _windowTrackingRect;
}

- (NSInteger)trackingRectTag
{
    return _trackingRectTag;
}

// In view coordinates.
- (NSRect)calculateTrackingRect
{
    return NSZeroRect;
}

- (void)postMouseEnteredExited
{
    if (!_eventTypeToPost)
        return;
    NSWindow *window = [_view window];
    NSEvent *current = [window currentEvent];
    NSTimeInterval timestamp = current ? [current timestamp] : 0;
    NSEvent *event = [NSEvent enterExitEventWithType:_eventTypeToPost
                                            location:[window BT_effectiveMouseLocation]
                                       modifierFlags:[window BT_effectiveModifierFlags]
                                           timestamp:timestamp
                                        windowNumber:[window windowNumber]
                                             context:nil
                                         eventNumber:0
                                      trackingNumber:_trackingRectTag
                                            userData:NULL];
    if (event)
        [NSApp postEvent:event atStart:YES];
}

// Posted on the next run loop pass; a later request replaces the type.
- (void)postMouseEnteredExited:(NSUInteger)aExited
{
    if (!_eventTypeToPost) {
        _eventTypeToPost = aExited;
        [self performSelector:@selector(postMouseEnteredExited) withObject:nil afterDelay:0];
    } else if (_eventTypeToPost != aExited)
        _eventTypeToPost = aExited;
}

- (void)activateAssumeInside:(BOOL)aInside postInitialMouseEntered:(BOOL)aEntered
{
    NSRect rect = [self calculateTrackingRect];
    _isInside = aInside && !aEntered;
    _trackingRectTag = [_view addTrackingRect:rect owner:self userData:NULL assumeInside:_isInside];
    _windowTrackingRect = [_view convertRect:rect toView:nil];
    if (aInside && aEntered)
        [self postMouseEnteredExited:NSEventTypeMouseEntered];
}

- (void)reactivateIfNeeded
{
    NSRect rect = [self calculateTrackingRect];
    NSRect windowRect = [_view convertRect:rect toView:nil];
    if ([self isActive]) {
        if (NSEqualRects(windowRect, _windowTrackingRect))
            return;
        [_view removeTrackingRect:_trackingRectTag];
    }
    NSPoint mouse = [_view convertPoint:[[_view window] mouseLocationOutsideOfEventStream] fromView:nil];
    BOOL inside = [_view mouse:mouse inRect:rect];
    _trackingRectTag = [_view addTrackingRect:rect owner:self userData:NULL assumeInside:_isInside];
    _windowTrackingRect = windowRect;
    if (_isInside != inside)
        [self postMouseEnteredExited:inside ? NSEventTypeMouseEntered : NSEventTypeMouseExited];
}

- (void)deactivate
{
    if ([self isActive]) {
        [_view removeTrackingRect:_trackingRectTag];
        _isInside = NO;
        _windowTrackingRect = NSZeroRect;
    }
}

- (void)mouseEntered:(id)aEntered
{
    _isInside = YES;
    _eventTypeToPost = 0;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(postMouseEnteredExited) object:nil];
    [_owner mouseEntered:aEntered];
}

- (void)mouseExited:(id)aExited
{
    _isInside = NO;
    _eventTypeToPost = 0;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(postMouseEnteredExited) object:nil];
    [_owner mouseExited:aExited];
}

- (void)discard
{
    [self deactivate];
    [_view BTTrackingView_removeTrackingZone:self];
    _view = nil;
    _windowTrackingRect = NSZeroRect;
}

@end

@implementation BTTrackingView_BTVisibleRectTrackingZone

- (NSRect)calculateTrackingRect
{
    return [_view visibleRect];
}

@end

@implementation BTTrackingView

- (void)BTTrackingView_addViewObserversStartingFromView:(id)aView
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    for (NSView *view = aView; view; view = [view superview]) {
        [center addObserver:_trackingViewProxy selector:@selector(BTTrackingView_viewDidChangeGeometry:)
                       name:NSViewFrameDidChangeNotification object:view];
        [center addObserver:_trackingViewProxy selector:@selector(BTTrackingView_viewDidChangeGeometry:)
                       name:NSViewBoundsDidChangeNotification object:view];
    }
}

- (void)BTTrackingView_removeViewObservers
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:_trackingViewProxy name:NSViewFrameDidChangeNotification object:nil];
    [center removeObserver:_trackingViewProxy name:NSViewBoundsDidChangeNotification object:nil];
}

- (void)dealloc
{
    if (_trackingViewProxy) {
        if (_isRegisteredForViewNotifications)
            [self BTTrackingView_removeViewObservers];
        [[self class] NSE_invalidateWeakProxy:_trackingViewProxy];
        [_trackingViewProxy release];
    }
    [_trackingZones release];
    [super dealloc];
}

- (BOOL)BTTrackingView_prepareToTrackZones
{
    if (!_trackingZones) {
        _trackingZones = [[NSMutableSet alloc] init];
        if (!_trackingZones)
            return NO;
    }
    if (!_trackingViewProxy) {
        _trackingViewProxy = [self NSE_newWeakProxy];
        if (!_trackingViewProxy)
            return NO;
    }
    if (!_isRegisteredForViewNotifications && [self window]) {
        [self BTTrackingView_addViewObserversStartingFromView:self];
        _isRegisteredForViewNotifications = YES;
    }
    return YES;
}

- (void)BTTrackingView_resetTrackingRects:(BOOL)aRects
{
    if (![self window] || !_trackingZones)
        return;
    for (BTTrackingView_BTTrackingZone *zone in [[_trackingZones copy] autorelease]) {
        if (aRects)
            [zone reactivateIfNeeded];
        else
            [zone deactivate];
    }
}

- (void)BTTrackingView_viewDidChangeGeometry:(id)aGeometry
{
    [self BTTrackingView_resetTrackingRects:YES];
}

- (void)viewWillMoveToWindow:(id)aWindow
{
    if (_isRegisteredForViewNotifications) {
        [self BTTrackingView_removeViewObservers];
        _isRegisteredForViewNotifications = NO;
    }
    [self BTTrackingView_resetTrackingRects:NO];
}

- (void)viewDidMoveToWindow
{
    if ([_trackingZones count] && [self window]) {
        [self BTTrackingView_addViewObserversStartingFromView:self];
        _isRegisteredForViewNotifications = YES;
    }
    [self BTTrackingView_resetTrackingRects:YES];
}

- (BOOL)BTTrackingView_addTrackingZone:(id)aZone assumeInside:(BOOL)aInside postInitialMouseEntered:(BOOL)aEntered
{
    if (![self BTTrackingView_prepareToTrackZones])
        return NO;
    if ([self window])
        [aZone activateAssumeInside:aInside postInitialMouseEntered:aEntered];
    [_trackingZones addObject:aZone];
    return YES;
}

- (id)addTrackingZoneForVisibleRectWithOwner:(id)aOwner assumeInside:(BOOL)aInside postInitialMouseEntered:(BOOL)aEntered
{
    BTTrackingView_BTVisibleRectTrackingZone *zone =
        [[[BTTrackingView_BTVisibleRectTrackingZone alloc] initWithView:self owner:aOwner] autorelease];
    if (!zone)
        return nil;
    return [self BTTrackingView_addTrackingZone:zone assumeInside:aInside postInitialMouseEntered:aEntered] ? zone : nil;
}

- (void)BTTrackingView_removeTrackingZone:(id)aZone
{
    [_trackingZones removeObject:aZone];
    if (_isRegisteredForViewNotifications && ![_trackingZones count]) {
        [self BTTrackingView_removeViewObservers];
        _isRegisteredForViewNotifications = NO;
    }
}

@end
