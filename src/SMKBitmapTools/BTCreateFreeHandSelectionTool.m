#import "BTCreateFreeHandSelectionTool.h"
#import "NSView+BTMouseTracking.h"

@implementation BTCreateFreeHandSelectionTool

- (void)trackingView:(id)aView didAutoscroll:(BOOL)aAutoscroll withMouseEvent:(id)aEvent
{
    if (_view == aView)
        [[_delegate mouseTrackingDelegateForTool:self] trackingView:aView didAutoscroll:aAutoscroll withMouseEvent:aEvent];
}

- (BOOL)trackingView:(id)aView shouldAutoscrollWithMouseEvent:(id)aEvent
{
    id tracker;
    if (_view == aView && (tracker = [_delegate mouseTrackingDelegateForTool:self]) != nil)
        return [tracker trackingView:aView shouldAutoscrollWithMouseEvent:aEvent];
    return YES;
}

- (void)haltWithMouseUp:(id)aEvent inView:(id)aView
{
    if (_view == aView)
        [[_delegate mouseTrackingDelegateForTool:self] haltWithMouseUp:aEvent inView:aView];
}

- (void)trackFlagsChanged:(id)aEvent inView:(id)aView
{
    if (_view == aView)
        [[_delegate mouseTrackingDelegateForTool:self] trackFlagsChanged:aEvent inView:aView];
}

/* Snapped mouse location in image coordinates. */
static NSPoint BTFreeHandLocation(BTCreateFreeHandSelectionTool *self, NSEvent *aEvent)
{
    NSPoint p = [self eventLocationInView:aEvent];
    [self snapPoint:&p asDevicePixelCenter:NO withinBoundsWithMinX:-INFINITY maxX:INFINITY minY:-INFINITY maxY:INFINITY alongTrajectoryLine:CGELineUndefined withEvent:aEvent options:nil];
    return [self convertViewPointToImagePoint:p];
}

- (void)trackMouseUp:(id)aEvent inView:(id)aView
{
    if (_view != aView)
        return;
    [[_delegate mouseTrackingDelegateForTool:self] trackMouseUp:aEvent inView:aView];
    if (_workSelectionPath != NULL) {
        [self BTCreateFreeHandSelectionTool_invalidateSelectionTrackingFeedback];
        [_delegate tool:self willUpdateOutputForKey:@"selectionPath"];
        NSPoint p = BTFreeHandLocation(self, aEvent);
        CGPathAddLineToPoint(_workSelectionPath, NULL, p.x, p.y);
        CGPathCloseSubpath(_workSelectionPath);
        _areSelectionPathBoundsCalculated = 0;
        [_delegate tool:self didUpdateOutputForKey:@"selectionPath"];
    }
    _isTracking = 0;
}

- (void)trackMouseDragged:(id)aEvent inView:(id)aView
{
    if (_view != aView)
        return;
    [[_delegate mouseTrackingDelegateForTool:self] trackMouseDragged:aEvent inView:aView];
    [_delegate tool:self willUpdateOutputForKey:@"selectionPath"];
    if (_workSelectionPath == NULL) {
        /* The first drag starts the path at the mouse-down point. */
        [_delegate tool:self willUpdateOutputForKey:@"selectionStartPoint"];
        _workSelectionPath = CGPathCreateMutable();
        if (_workSelectionPath == NULL) {
            [_delegate tool:self didUpdateOutputForKey:@"selectionStartPoint"];
            [_delegate tool:self didFinalizeOutputForKey:@"selectionStartPoint"];
            [_delegate tool:self didUpdateOutputForKey:@"selectionPath"];
            [_view BT_abortMouseTracking];
            _isTracking = 0;
            return;
        }
        CGPathMoveToPoint(_workSelectionPath, NULL, _selectionStartPoint.x, _selectionStartPoint.y);
        [_delegate tool:self didUpdateOutputForKey:@"selectionStartPoint"];
        [_delegate tool:self didFinalizeOutputForKey:@"selectionStartPoint"];
    } else {
        [self BTCreateFreeHandSelectionTool_invalidateSelectionTrackingFeedback];
    }
    NSPoint p = BTFreeHandLocation(self, aEvent);
    CGPathAddLineToPoint(_workSelectionPath, NULL, p.x, p.y);
    _areSelectionPathBoundsCalculated = 0;
    [_delegate tool:self didUpdateOutputForKey:@"selectionPath"];
    [self BTCreateFreeHandSelectionTool_invalidateSelectionTrackingFeedback];
}

- (void)trackMouseDown:(id)aEvent inView:(id)aView
{
    if (_view != aView)
        return;
    [[_delegate mouseTrackingDelegateForTool:self] trackMouseDown:aEvent inView:aView];
    _isTracking = 1;
    [_doCreateSelectionCursor set];
}

- (BOOL)isFeedbackLayerActive:(id)aLayer
{
    if (!_isTracking)
        return NO;
    return [aLayer isEqualToString:@"BTSelectionFeedbackLayer"];
}

- (id)activeFeedbackLayers
{
    return _isTracking ? [NSSet setWithObject:@"BTSelectionFeedbackLayer"] : [NSSet set];
}

- (id)activeFeedbackLayersForDrawing
{
    return _isTracking ? [NSArray arrayWithObject:@"BTSelectionFeedbackLayer"] : [NSArray array];
}

/* Marching ants: red dashes over white, drawn just inside the path's bounds. */
- (void)draw_BTSelectionFeedbackLayer_Rect:(NSRect)aRect
{
    if (_workSelectionPath == NULL)
        return;
    CGContextRef context = [[NSGraphicsContext currentContext] CGContext];
    if (context == NULL)
        return;
    CGMutablePathRef path = (CGMutablePathRef)CFAutorelease(CGPathCreateMutable());
    if (path == NULL)
        return;

    CGAffineTransform toView = [self imageToViewTransform];
    if (!_areSelectionPathBoundsCalculated) {
        _selectionPathBounds = CGEPathGetPathBoundingBox(_workSelectionPath);
        _areSelectionPathBoundsCalculated = 1;
    }
    CGRect bounds = _selectionPathBounds;
    CGFloat sx = hypot(toView.a, toView.b);
    CGFloat sy = hypot(toView.c, toView.d);
    CGFloat ix = sx != 0.0 ? 0.475 / sx : 0.0;
    CGFloat iy = sy != 0.0 ? 0.475 / sy : 0.0;
    CGRect inner = CGRectMake(bounds.origin.x + ix, bounds.origin.y + iy, bounds.size.width - 2.0 * ix, bounds.size.height - 2.0 * iy);
    if (CGRectIsEmpty(inner))
        return;

    CGAffineTransform m;
    m.a = bounds.size.width != 0.0 ? inner.size.width / bounds.size.width : 1.0;
    m.d = bounds.size.height != 0.0 ? inner.size.height / bounds.size.height : 1.0;
    m.b = 0.0;
    m.c = 0.0;
    m.tx = inner.origin.x - bounds.origin.x * m.a;
    m.ty = inner.origin.y - bounds.origin.y * m.d;
    m = CGAffineTransformConcat(m, toView);
    CGPathAddPath(path, &m, _workSelectionPath);

    const CGFloat whiteDash[2] = { 3.0, 5.0 };
    CGContextSetLineDash(context, 0.0, whiteDash, 2);
    CGContextSetRGBStrokeColor(context, 1.0, 1.0, 1.0, 1.0);
    CGContextBeginPath(context);
    CGContextAddPath(context, path);
    CGContextStrokePath(context);
    const CGFloat redDash[2] = { 5.0, 3.0 };
    CGContextSetLineDash(context, 5.0, redDash, 2);
    CGContextSetRGBStrokeColor(context, 1.0, 0.0, 0.0, 1.0);
    CGContextBeginPath(context);
    CGContextAddPath(context, path);
    CGContextStrokePath(context);
}

- (void)selectAllArea:(id)aSender
{
    if (_isTracking || [self workImage] == nil)
        return;
    [self beginUndoAction];
    [_delegate tool:self willUpdateOutputForKey:@"selectionPath"];
    [_delegate tool:self willUpdateOutputForKey:@"selectionStartPoint"];
    CGSize size = [[self workImage] imageSize];
    _selectionStartPoint = NSMakePoint(0.5, size.height - 0.5);
    CGPathRelease(_selectionPath);
    _selectionPath = NULL;
    CGPathRelease(_workSelectionPath);
    _workSelectionPath = CGPathCreateMutable();
    if (_workSelectionPath != NULL) {
        _selectionPathBounds = (CGRect){ CGPointZero, size };
        CGPathAddRect(_workSelectionPath, NULL, _selectionPathBounds);
        _areSelectionPathBoundsCalculated = 1;
    }
    [_delegate tool:self didUpdateOutputForKey:@"selectionStartPoint"];
    [_delegate tool:self didFinalizeOutputForKey:@"selectionStartPoint"];
    [_delegate tool:self didUpdateOutputForKey:@"selectionPath"];
    [_delegate tool:self didFinalizeOutputForKey:@"selectionPath"];
    [self endUndoActionWithName:@"Create All Area Free Hand Selection"];
    [_delegate tool:self didFinalizeStage:@"BTWaitingToolStage" withEvent:nil nextStage:nil];
    if ([self isActive]) {
        CGPathRelease(_selectionPath);
        _selectionPath = NULL;
        CGPathRelease(_workSelectionPath);
        _workSelectionPath = NULL;
    }
}

- (BOOL)validateAction_selectAllArea
{
    if (_isTracking)
        return NO;
    return [self workImage] != nil;
}

- (BOOL)mouseDown:(id)aEvent
{
    BOOL result = [_delegate tool:self didFinalizeStage:@"BTWaitingToolStage" withEvent:aEvent nextStage:@"BTCreatingSelectionToolStage"];
    if (![self isActive])
        return result;
    [self beginUndoAction];
    _isCreatingSelectionPath = 1;
    NSPoint p = [self eventLocationInView:aEvent];
    [self snapPoint:&p asDevicePixelCenter:NO withinBoundsWithMinX:-INFINITY maxX:INFINITY minY:-INFINITY maxY:INFINITY alongTrajectoryLine:CGELineUndefined withEvent:aEvent options:nil];
    [_delegate tool:self willUpdateOutputForKey:@"selectionStartPoint"];
    [_delegate tool:self willUpdateOutputForKey:@"selectionPath"];
    _selectionStartPoint = [self convertViewPointToImagePoint:p];
    [_delegate tool:self didUpdateOutputForKey:@"selectionPath"];
    [_delegate tool:self didUpdateOutputForKey:@"selectionStartPoint"];
    id lastEvent = [_view BT_trackMouseWithEvent:aEvent tracker:self];
    [_delegate tool:self didFinalizeOutputForKey:@"selectionPath"];
    [self endUndoActionWithName:@"Create Free Hand Selection"];
    [_delegate tool:self didFinalizeStage:@"BTCreatingSelectionToolStage" withEvent:lastEvent nextStage:nil];
    if ([self isActive]) {
        CGPathRelease(_selectionPath);
        _selectionPath = NULL;
        CGPathRelease(_workSelectionPath);
        _workSelectionPath = NULL;
        _isCreatingSelectionPath = 0;
        [_delegate tool:self didUpdateCursorWithEvent:lastEvent];
    }
    return YES;
}

- (id)cursorForPoint:(NSPoint)aPoint modifierFlags:(NSUInteger)aFlags
{
    return [self willCreateSelectionCursor];
}

- (BOOL)isTracking
{
    return _isTracking;
}

- (id)currentStage
{
    return _isCreatingSelectionPath ? @"BTCreatingSelectionToolStage" : @"BTWaitingToolStage";
}

- (void)performDeactivate
{
    if (_isTracking) {
        [self BTCreateFreeHandSelectionTool_invalidateSelectionTrackingFeedback];
        [_view BT_abortMouseTracking];
        _isTracking = 0;
    }
    _isCreatingSelectionPath = 0;
    [super performDeactivate];
}

- (BOOL)activateWithDelegate:(id)aDelegate inView:(id)aView
{
    if (![super activateWithDelegate:aDelegate inView:aView])
        return NO;
    CGPathRelease(_selectionPath);
    _selectionPath = NULL;
    CGPathRelease(_workSelectionPath);
    _workSelectionPath = NULL;
    return YES;
}

- (void)BTCreateFreeHandSelectionTool_invalidateSelectionTrackingFeedback
{
    if (![self isViewInvalidationEnabled] || _workSelectionPath == NULL)
        return;
    if (!_areSelectionPathBoundsCalculated) {
        _selectionPathBounds = CGEPathGetPathBoundingBox(_workSelectionPath);
        _areSelectionPathBoundsCalculated = 1;
    }
    CGRect r = CGRectIntegral(CGRectInset(_selectionPathBounds, -0.05, -0.05));
    NSRect v = [self convertImageRectToViewRect:NSRectFromCGRect(r)];
    [_view setNeedsDisplayInRect:NSRectFromCGRect(CGRectIntegral(NSRectToCGRect(v)))];
}

- (id)outputKeys
{
    return [NSArray arrayWithObjects:@"selectionStartPoint", @"selectionPath", nil];
}

- (id)inputKeys
{
    return [NSArray arrayWithObjects:@"generalKeyBindings", @"willCreateSelectionCursor", @"doCreateSelectionCursor", nil];
}

/* While tracking, a closed copy of the path so far; afterwards the finished path. */
- (id)selectionPath
{
    if (_isTracking) {
        if (_workSelectionPath == NULL)
            return nil;
        CGMutablePathRef closed = CGPathCreateMutableCopy(_workSelectionPath);
        if (closed == NULL)
            return nil;
        CGPathCloseSubpath(closed);
        CGPathRef copy = CGPathCreateCopy(closed);
        CGPathRelease(closed);
        return [(id)copy autorelease];
    }
    if (_selectionPath != NULL)
        return (id)_selectionPath;
    if (_workSelectionPath != NULL) {
        _selectionPath = CGPathCreateCopy(_workSelectionPath);
        if (_selectionPath != NULL) {
            CGPathRelease(_workSelectionPath);
            _workSelectionPath = NULL;
            return (id)_selectionPath;
        }
    }
    return nil;
}

- (id)selectionStartPoint
{
    if (_workSelectionPath == NULL && _selectionPath == NULL)
        return nil;
    return [NSValue valueWithPoint:_selectionStartPoint];
}

- (void)setDoCreateSelectionCursor:(id)aCursor
{
    if (_doCreateSelectionCursor == aCursor)
        return;
    [aCursor retain];
    [_doCreateSelectionCursor release];
    _doCreateSelectionCursor = aCursor;
    if (_isTracking)
        [(NSCursor *)(aCursor != nil ? aCursor : [NSCursor arrowCursor]) set];
}

- (id)doCreateSelectionCursor
{
    return _doCreateSelectionCursor;
}

- (id)defaultDoCreateSelectionCursor
{
    return nil;
}

- (void)setWillCreateSelectionCursor:(id)aCursor
{
    if (_willCreateSelectionCursor != aCursor) {
        [_willCreateSelectionCursor release];
        _willCreateSelectionCursor = [aCursor retain];
    }
}

- (id)willCreateSelectionCursor
{
    return _willCreateSelectionCursor;
}

- (id)defaultWillCreateSelectionCursor
{
    return nil;
}

- (void)dealloc
{
    [_willCreateSelectionCursor release];
    [_doCreateSelectionCursor release];
    CGPathRelease(_workSelectionPath);
    CGPathRelease(_selectionPath);
    [super dealloc];
}

@end
