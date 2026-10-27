#import "HSView.h"
#import "HSCursorSynchronizer.h"
#import "NSWindow+HSExtensions.h"

// Event types that carry a mouse location: the mouse buttons, moves, drags,
// enter/exit, tablet, other-mouse and gesture events.
static BOOL HSViewIsMouseEventType(NSEventType aType)
{
    return aType <= 29 && ((0x2f8003feU >> aType) & 1) != 0;
}

// The base view: cursor visibility states (0 shown, 1 hidden, 2 hidden until
// the mouse moves), superview bounds change notifications, content change
// accumulation, acceptable drawing quality loss (the smallest one accepted),
// and the user space to view space transform.
@implementation HSView

- (void)interactiveSubviewDidUpdate
{
}

- (BOOL)isRenderInteractiveSubview
{
    return NO;
}

- (void)stopRenderInteractiveSubview
{
}

- (void)beginRenderInteractiveSubview
{
}

// The requests are counted by loss (in 1/10000).
- (void)declineDrawingQualityLoss:(CGFloat)aLoss
{
    if (_drawingQualityLossAcceptanceRequests == nil)
        return;
    NSInteger key = lroundf(aLoss * 10000.0);
    NSInteger count = (NSInteger)NSMapGet(_drawingQualityLossAcceptanceRequests, (void *)key);
    if (count == 0)
        return;
    if (count == 1) {
        NSMapRemove(_drawingQualityLossAcceptanceRequests, (void *)key);
        _isAcceptableDrawingQualityLossCalculated = 0;
    } else {
        NSMapInsert(_drawingQualityLossAcceptanceRequests, (void *)key, (void *)(count - 1));
    }
}

- (void)acceptDrawingQualityLoss:(CGFloat)aLoss
{
    NSInteger key = lroundf(aLoss * 10000.0);
    NSInteger count;
    if (_drawingQualityLossAcceptanceRequests == nil) {
        _drawingQualityLossAcceptanceRequests = NSCreateMapTable(NSIntegerMapKeyCallBacks, NSIntegerMapValueCallBacks, 0);
        if (_drawingQualityLossAcceptanceRequests == nil)
            return;
        count = 1;
    } else {
        count = (NSInteger)NSMapGet(_drawingQualityLossAcceptanceRequests, (void *)key) + 1;
    }
    NSMapInsert(_drawingQualityLossAcceptanceRequests, (void *)key, (void *)count);
    if (_isAcceptableDrawingQualityLossCalculated) {
        float loss = (float)(key * 0.0001);
        if (_acceptableDrawingQualityLoss <= loss && NSCountMapTable(_drawingQualityLossAcceptanceRequests) != 1)
            return;
        _acceptableDrawingQualityLoss = loss;
    }
}

- (CGFloat)acceptableDrawingQualityLoss
{
    if (_isAcceptableDrawingQualityLossCalculated)
        return _acceptableDrawingQualityLoss;
    if (_drawingQualityLossAcceptanceRequests == nil) {
        _acceptableDrawingQualityLoss = 0;
    } else {
        NSMapEnumerator enumerator = NSEnumerateMapTable(_drawingQualityLossAcceptanceRequests);
        NSInteger minimum = 0;
        if (NSNextMapEnumeratorPair(&enumerator, (void **)&minimum, NULL)) {
            NSInteger key = 0;
            while (NSNextMapEnumeratorPair(&enumerator, (void **)&key, NULL)) {
                if (key < minimum)
                    minimum = key;
            }
        }
        NSEndMapTableEnumeration(&enumerator);
        _acceptableDrawingQualityLoss = (float)(minimum * 0.0001);
    }
    _isAcceptableDrawingQualityLossCalculated = 1;
    return _acceptableDrawingQualityLoss;
}

- (void)viewDidMoveToSuperview
{
    if (_observesAndNotifiesOfSuperviewBoundsChanges) {
        if ([self superview] != nil)
            [self noteDidSetSuperview];
        else
            [self noteDidResetSuperview];
    }
    [super viewDidMoveToSuperview];
}

- (void)viewWillMoveToSuperview:(id)aSuperview
{
    if (_observesAndNotifiesOfSuperviewBoundsChanges && aSuperview == nil)
        [self noteWillResetSuperview];
    [super viewWillMoveToSuperview:aSuperview];
}

- (void)setObservesAndNotifiesOfSuperviewBoundsChanges:(BOOL)aChanges
{
    if ((_observesAndNotifiesOfSuperviewBoundsChanges != 0) == (aChanges != NO))
        return;
    if (_observesAndNotifiesOfSuperviewBoundsChanges && [self superview] != nil) {
        [self noteWillResetSuperview];
        [self noteDidResetSuperview];
    }
    _observesAndNotifiesOfSuperviewBoundsChanges = aChanges ? 1 : 0;
    if (aChanges && [self superview] != nil)
        [self noteDidSetSuperview];
}

- (BOOL)observesAndNotifiesOfSuperviewBoundsChanges
{
    return _observesAndNotifiesOfSuperviewBoundsChanges ? YES : NO;
}

- (void)noteDidResetSuperview
{
    [self noteSuperviewBoundsDidChange];
}

- (void)noteWillResetSuperview
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSViewBoundsDidChangeNotification object:[self superview]];
    _observesSuperviewNotifications = 0;
}

- (void)noteDidSetSuperview
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hyperSuperviewBoundsDidChange:) name:NSViewBoundsDidChangeNotification object:[self superview]];
    _observesSuperviewNotifications = 1;
    [self noteSuperviewBoundsDidChange];
}

- (void)hyperSuperviewBoundsDidChange:(id)aChange
{
    [self noteSuperviewBoundsDidChange];
}

- (void)noteSuperviewBoundsDidChange
{
    [[NSNotificationCenter defaultCenter] postNotificationName:HSViewSuperviewBoundsDidChangeNotification object:self];
}

- (void)viewDidMoveToWindow
{
    [super viewDidMoveToWindow];
    if ([self window] != nil)
        [[NSNotificationCenter defaultCenter] postNotificationName:HSViewDidMountIntoWindowNotification object:self];
}

- (void)viewWillMoveToWindow:(id)aWindow
{
    if (aWindow == nil)
        [[NSNotificationCenter defaultCenter] postNotificationName:HSViewWillUnmountFromWindowNotification object:self];
    [super viewWillMoveToWindow:aWindow];
}

- (void)restorePreviosCursorVisabilityState
{
    _cursorVisibilityState = _previosCursorVisibilityState;
    [self updateCursor];
}

- (void)savePreviosCursorVisabilityState
{
    _previosCursorVisibilityState = _cursorVisibilityState;
}

- (void)obscureCursor
{
    [self savePreviosCursorVisabilityState];
    _cursorVisibilityState = 2;
    [self updateCursor];
}

- (void)hideCursor
{
    [self savePreviosCursorVisabilityState];
    _cursorVisibilityState = 1;
    [self updateCursor];
}

- (void)showCursor
{
    [self savePreviosCursorVisabilityState];
    _cursorVisibilityState = 0;
    [self updateCursor];
}

// For subclasses.
- (void)updateCursorAtPoint:(NSPoint)aPoint inside:(BOOL)aInside modifierFlags:(NSUInteger)aFlags event:(id)aEvent
{
}

// From the current event, or a mouse-moved event at the mouse location when
// the current event has no location.
- (void)updateCursor
{
    NSWindow *window = [self window];
    if (window == nil)
        return;
    NSEvent *event = [window currentEvent];
    NSUInteger modifierFlags = [event modifierFlags];
    NSPoint location;
    if (!HSViewIsMouseEventType([event type])) {
        location = [window convertPointFromScreen:[NSEvent mouseLocation]];
        event = [NSEvent mouseEventWithType:NSEventTypeMouseMoved location:location modifierFlags:modifierFlags timestamp:[event timestamp] windowNumber:[event windowNumber] context:nil eventNumber:0 clickCount:0 pressure:0];
    } else {
        location = [event locationInWindow];
    }
    [self updateCursorAtPoint:[self convertPoint:location fromView:nil] modifierFlags:modifierFlags event:event];
}

// Inside when in the visible rect and this window is the frontmost one under
// the mouse.
- (void)updateCursorAtPoint:(NSPoint)aPoint modifierFlags:(NSUInteger)aFlags event:(id)aEvent
{
    BOOL isInside = NO;
    if ([self mouse:aPoint inRect:[self visibleRect]]) {
        NSWindow *hitWindow = nil;
        for (NSWindow *window in [NSApp orderedWindows]) {
            if ([window isHyperWindowHitByCurrentMouseLocation] != nil) {
                hitWindow = window;
                break;
            }
        }
        isInside = hitWindow == [self window];
    }
    [self updateCursorVisibilityAtPoint:aPoint inside:isInside modifierFlags:aFlags event:aEvent];
}

- (void)updateCursorWithMouseEvent:(id)aEvent
{
    [self updateCursorAtPoint:[self convertPoint:[aEvent locationInWindow] fromView:nil] modifierFlags:[aEvent modifierFlags] event:aEvent];
}

// A hidden cursor isn't updated.
- (void)updateCursorVisibilityAtPoint:(NSPoint)aPoint inside:(BOOL)aInside modifierFlags:(NSUInteger)aFlags event:(id)aEvent
{
    if (aInside && _cursorVisibilityState == 1) {
        [HSCursor hideCursorIfNeeded];
        return;
    }
    if (!aInside || _cursorVisibilityState == 0) {
        [HSCursor unhideCursorIfNeeded];
    } else if (_cursorVisibilityState == 2) {
        [NSCursor setHiddenUntilMouseMoves:YES];
        _cursorVisibilityState = 0;
    }
    [self updateCursorAtPoint:aPoint inside:aInside modifierFlags:aFlags event:aEvent];
}

- (void)handleMouseMoved:(id)aMoved
{
    [self updateCursorWithMouseEvent:aMoved];
}

- (void)processAccumulatedContentChanges
{
}

- (BOOL)areContentChangesBeingAccumulated
{
    return _contentChangesAccumulationCounter != 0;
}

- (void)endContentChangeAccumulation
{
    if (--_contentChangesAccumulationCounter == 0)
        [self processAccumulatedContentChanges];
}

- (void)beginContentChangeAccumulation
{
    _contentChangesAccumulationCounter++;
}

- (NSRect)userBoundingRectForViewRect:(NSRect)aRect
{
    return [[self viewSpaceToUserSpaceTransform] hyperTransformAndBoundRect:aRect];
}

- (NSRect)viewBoundingRectForUserRect:(NSRect)aRect
{
    return [[self userSpaceToViewSpaceTransform] hyperTransformAndBoundRect:aRect];
}

- (NSPoint)convertPointFromViewSpaceToUserSpace:(NSPoint)aSpace
{
    return [[self viewSpaceToUserSpaceTransform] transformPoint:aSpace];
}

- (NSPoint)convertPointFromUserSpaceToViewSpace:(NSPoint)aSpace
{
    return [[self userSpaceToViewSpaceTransform] transformPoint:aSpace];
}

- (CGAffineTransform)viewSpaceToUserSpaceCGAffineTransform
{
    NSAffineTransformStruct transform = [[self viewSpaceToUserSpaceTransform] transformStruct];
    return CGAffineTransformMake(transform.m11, transform.m12, transform.m21, transform.m22, transform.tX, transform.tY);
}

- (id)viewSpaceToUserSpaceTransform
{
    NSAffineTransform *transform = [self userSpaceToViewSpaceTransform];
    [transform invert];
    return transform;
}

- (CGAffineTransform)userSpaceToViewSpaceCGAffineTransform
{
    NSAffineTransformStruct transform = [[self userSpaceToViewSpaceTransform] transformStruct];
    return CGAffineTransformMake(transform.m11, transform.m12, transform.m21, transform.m22, transform.tX, transform.tY);
}

// The identity here; a new transform each time.
- (id)userSpaceToViewSpaceTransform
{
    return [NSAffineTransform transform];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _observesAndNotifiesOfSuperviewBoundsChanges = 0;
    if (_drawingQualityLossAcceptanceRequests != nil)
        NSFreeMapTable(_drawingQualityLossAcceptanceRequests);
    [super dealloc];
}

@end
