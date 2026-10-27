#import "BTModifySelectionTool.h"
#import "BTSizeToPointSnapSource.h"
#import "NSBezierPath+BTCoreGraphicsExtensions.h"
#import "NSView+BTMouseTracking.h"

/*
 * Selection parts: 0 none, 1 inside (move), 2-9 the resize knobs counter
 * clockwise from the bottom left corner (2 BL, 3 CL, 4 TL, 5 TC, 6 TR, 7 CR,
 * 8 BR, 9 BC), 10 the rotate handle. Operations: 0 none, 1 move, 2 scale,
 * 3 rotate. Corner indices 0-3 run (minX, minY), (minX, maxY), (maxX, maxY),
 * (maxX, minY).
 */

static NSString * const BTSelectionUndoCategory = @"BTSelectionUndoCategory";

@implementation BTModifySelectionTool

static void BTModifySelectionToolCalculateBounds(BTModifySelectionTool *self)
{
    if (!self->_areSelectionPathBoundsCalculated) {
        self->_selectionPathBounds = CGEPathGetPathBoundingBox(self->_selectionPath);
        self->_areSelectionPathBoundsCalculated = 1;
    }
}

static void BTModifySelectionToolBoundsCorners(BTModifySelectionTool *self, CGPoint aCorners[4])
{
    CGRect b = self->_selectionPathBounds;
    CGFloat maxX = b.size.width + b.origin.x;
    CGFloat maxY = b.size.height + b.origin.y;
    aCorners[0] = CGPointMake(b.origin.x, b.origin.y);
    aCorners[1] = CGPointMake(b.origin.x, maxY);
    aCorners[2] = CGPointMake(maxX, maxY);
    aCorners[3] = CGPointMake(maxX, b.origin.y);
}

/* The rotation of the selection transform in [0, 2 pi). */
static CGFloat BTModifySelectionToolRotationAngle(CGAffineTransform aTransform, BOOL aFlipped)
{
    CGFloat angle;
    if (aTransform.a != 0.0 || aTransform.b != 0.0) {
        CGFloat a = aTransform.a, b = aTransform.b;
        if (aFlipped) {
            a = -a;
            b = -b;
        }
        angle = atan2(b, a);
    } else {
        CGFloat c = aTransform.c, d = aTransform.d;
        if (aFlipped) {
            c = -c;
            d = -d;
        }
        angle = atan2(d, c) + -M_PI_2;
    }
    if (angle < 0.0)
        angle += 2.0 * M_PI;
    return angle;
}

/* The line a x + b y + c = 0 through both points. */
static CGELine BTModifySelectionToolLineThrough(CGPoint aPoint, CGPoint aPoint2)
{
    CGELine line;
    line.a = aPoint.y - aPoint2.y;
    line.b = aPoint2.x - aPoint.x;
    line.c = aPoint.x * aPoint2.y - aPoint2.x * aPoint.y;
    return line;
}

/*
 * Maps a snapped position of a selection corner (view space) to where the
 * dragged knob would then be: back to selection space, through aMovement
 * (selection space), forward to view space, then offset from the knob
 * reference to the actual mouse position.
 */
static CGAffineTransform BTModifySelectionToolReflectingTransform(CGAffineTransform aToView, CGAffineTransform aFromView, CGAffineTransform aMovement, CGPoint aReflectingPoint, CGPoint aReference)
{
    CGAffineTransform t = CGAffineTransformConcat(CGAffineTransformConcat(aFromView, aMovement), aToView);
    t.tx += aReflectingPoint.x - aReference.x;
    t.ty += aReflectingPoint.y - aReference.y;
    return t;
}

/* Scaling about aCenter that takes aFrom onto aTo, axis by axis. */
static CGAffineTransform BTModifySelectionToolScaling(CGPoint aCenter, CGPoint aFrom, CGPoint aTo)
{
    CGFloat sx = (aTo.x - aCenter.x) / (aFrom.x - aCenter.x);
    CGFloat sy = (aTo.y - aCenter.y) / (aFrom.y - aCenter.y);
    return CGAffineTransformMake(sx, 0.0, 0.0, sy, (1.0 - sx) * aCenter.x, (1.0 - sy) * aCenter.y);
}

static id BTModifySelectionToolSource(CGPoint aPoint, CGELine aLine, CGAffineTransform aTransform)
{
    return [BTPointToPointSnapSource sourceWithPoint:aPoint minXBound:-INFINITY maxXBound:INFINITY minYBound:-INFINITY maxYBound:INFINITY trajectoryLine:aLine options:nil reflectingTransform:aTransform];
}

static void BTModifySelectionToolStopTracking(BTModifySelectionTool *self)
{
    self->_selectionOperation = 0;
    [self->_trackingCursorName release];
    self->_trackingCursorName = nil;
}

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
    if (_view != aView)
        return;
    [[_delegate mouseTrackingDelegateForTool:self] haltWithMouseUp:aEvent inView:aView];
    BTModifySelectionToolStopTracking(self);
}

- (void)trackFlagsChanged:(id)aEvent inView:(id)aView
{
    if (_view != aView)
        return;
    [[_delegate mouseTrackingDelegateForTool:self] trackFlagsChanged:aEvent inView:aView];
    [self BTModifySelectionTool_trackMouseAtPoint:_lastImagePoint :[self convertImagePointToViewPoint:_lastImagePoint] withEvent:aEvent];
}

/* Ends the operation as one undo action, registering the change from the base transform. */
- (void)trackMouseUp:(id)aEvent inView:(id)aView
{
    if (_view != aView)
        return;
    [[_delegate mouseTrackingDelegateForTool:self] trackMouseUp:aEvent inView:aView];
    [self BTModifySelectionTool_trackMouse:aEvent];

    NSString *name;
    id manager;
    switch (_selectionOperation) {
    case 1:
        manager = [_delegate undoManagerForTool:self category:BTSelectionUndoCategory];
        if (manager != nil && !CGAffineTransformEqualToTransform(_baseSelectionAffineTransform, _selectionAffineTransform))
            [[self prepareUndoInManager:manager category:BTSelectionUndoCategory withInvocationTarget:self]
                BTModifySelectionTool_setBaseSelectionAffineTransform:_baseSelectionAffineTransform selectionAffineTransform:_baseSelectionAffineTransform];
        name = @"Move Selection";
        break;
    case 2:
        manager = [_delegate undoManagerForTool:self category:BTSelectionUndoCategory];
        if (manager != nil && !CGAffineTransformEqualToTransform(_baseSelectionAffineTransform, _selectionAffineTransform)) {
            id target = [self prepareUndoInManager:manager category:BTSelectionUndoCategory withInvocationTarget:self];
            if (_isSelectionFlippedHorizontally != _isBaseSelectionFlippedHorizontally)
                [target BTModifySelectionTool_setBaseSelectionAffineTransform:_baseSelectionAffineTransform horizontalFlip:_isBaseSelectionFlippedHorizontally
                    selectionAffineTransform:_baseSelectionAffineTransform horizontalFlip:_isBaseSelectionFlippedHorizontally];
            else
                [target BTModifySelectionTool_setBaseSelectionAffineTransform:_baseSelectionAffineTransform selectionAffineTransform:_baseSelectionAffineTransform];
        }
        name = @"Scale Selection";
        break;
    case 3:
        manager = [_delegate undoManagerForTool:self category:BTSelectionUndoCategory];
        if (manager != nil && !CGAffineTransformEqualToTransform(_baseSelectionAffineTransform, _selectionAffineTransform))
            [[self prepareUndoInManager:manager category:BTSelectionUndoCategory withInvocationTarget:self]
                BTModifySelectionTool_setBaseSelectionAffineTransform:_baseSelectionAffineTransform selectionAffineTransform:_baseSelectionAffineTransform];
        name = @"Rotate Selection";
        break;
    default:
        NSLog(_selectionOperation == 0 ? @"Tracking without any operation." : @"Unsupported operation.");
        name = nil;
        break;
    }
    [self endUndoActionWithName:name];

    _baseSelectionAffineTransform = _selectionAffineTransform;
    _isBaseSelectionFlippedHorizontally = _isSelectionFlippedHorizontally;
    _isTracking = 0;
    [_delegate tool:self didFinalizeStage:@"BTModifyingSelectionToolStage" withEvent:aEvent nextStage:@"BTWaitingToolStage"];
    if ([self isActive]) {
        [self BTModifySelectionTool_setNeedsDisplaySelection];
        [_delegate tool:self didUpdateCursorWithEvent:aEvent];
        BTModifySelectionToolStopTracking(self);
    }
}

- (void)trackMouseDragged:(id)aEvent inView:(id)aView
{
    if (_view != aView)
        return;
    [[_delegate mouseTrackingDelegateForTool:self] trackMouseDragged:aEvent inView:aView];
    [self BTModifySelectionTool_trackMouse:aEvent];
}

- (void)BTModifySelectionTool_trackMouse:(id)aEvent
{
    NSPoint viewPoint = [self eventLocationInView:aEvent];
    [self BTModifySelectionTool_trackMouseAtPoint:[self convertViewPointToImagePoint:viewPoint] :viewPoint withEvent:aEvent];
}

/* aPoint is in image space, aViewPoint the same point in view space. */
- (void)BTModifySelectionTool_trackMouseAtPoint:(CGPoint)aPoint :(CGPoint)aViewPoint withEvent:(id)aEvent
{
    [_delegate tool:self willUpdateOutputForKey:@"selectionAffineTransform"];
    if (_selectionOperation == 2)
        [_delegate tool:self willUpdateOutputForKey:@"selectionFlippedHorizontally"];
    [self BTModifySelectionTool_setNeedsDisplaySelection];
    _lastImagePoint = [self BTModifySelectionTool_calculateSelectionAffineTransformForPoint:aPoint :aViewPoint event:aEvent];
    if ([(NSEvent *)aEvent type] != NSLeftMouseUp)
        [self BTModifySelectionTool_setNeedsDisplaySelection];
    if (_selectionOperation == 2)
        [_delegate tool:self didUpdateOutputForKey:@"selectionFlippedHorizontally"];
    [_delegate tool:self didUpdateOutputForKey:@"selectionAffineTransform"];

    // The knob under the mouse changes with rotation and flipping.
    id subname = [self BTModifySelectionTool_cursorSubnameForSelectionPart:_selectionPart];
    if (subname != nil) {
        NSString *cursorName = [NSString stringWithFormat:@"do%@SelectionCursor", subname];
        if (![_trackingCursorName isEqualToString:cursorName]) {
            [_trackingCursorName release];
            _trackingCursorName = [cursorName copy];
            [(NSCursor *)[self valueForInputKey:_trackingCursorName] set];
        }
    }
}

- (void)trackMouseDown:(id)aEvent inView:(id)aView
{
    if (_view != aView)
        return;
    [[_delegate mouseTrackingDelegateForTool:self] trackMouseDown:aEvent inView:aView];
    [_delegate tool:self didFinalizeStage:@"BTWaitingToolStage" withEvent:aEvent nextStage:@"BTModifyingSelectionToolStage"];
    if (![self isActive])
        return;
    [self beginUndoAction];
    [self BTModifySelectionTool_setNeedsDisplaySelection];
    _isTracking = 1;
    if (_selectionOperation == 1)
        _guidingMode = ([(NSEvent *)aEvent modifierFlags] & NSShiftKeyMask) ? 0xff : 0;
    _lastImagePoint = _startImagePoint;
    [self BTModifySelectionTool_setNeedsDisplaySelection];
    if (_trackingCursorName != nil)
        [(NSCursor *)[self valueForInputKey:_trackingCursorName] set];
}

/*
 * Sets the selection transform for the mouse at aPoint (image space;
 * aViewPoint in view space) and returns the point actually used after
 * guiding and snapping.
 */
- (CGPoint)BTModifySelectionTool_calculateSelectionAffineTransformForPoint:(CGPoint)aPoint :(CGPoint)aViewPoint event:(id)aEvent
{
    CGPoint p = aPoint;
    switch (_selectionOperation) {
    case 0:
        NSLog(@"Tracking without any operation.");
        break;
    case 1: {
        _selectionAffineTransform = _baseSelectionAffineTransform;
        _selectionAffineTransform.tx = (p.x - _startImagePoint.x) + _baseSelectionAffineTransform.tx;
        _selectionAffineTransform.ty = (p.y - _startImagePoint.y) + _baseSelectionAffineTransform.ty;

        CGAffineTransform toView = [self imageToViewTransform];
        CGPoint lastView = CGPointApplyAffineTransform(_lastImagePoint, toView);
        CGPoint guided;
        if ([_delegate layoutGuidingContextForTool:self] == nil) {
            guided = [self guideMovementFromPoint:lastView toPoint:aViewPoint centeringOnDevicePixel:YES inMode:(char *)&_guidingMode withEvent:aEvent];
        } else {
            // All four bounds corners guide, each reflected onto the mouse.
            CGPoint corners[4];
            CGAffineTransform reflecting[4];
            BTModifySelectionToolBoundsCorners(self, corners);
            CGAffineTransform selectionToView = CGAffineTransformConcat(_selectionAffineTransform, toView);
            for (NSUInteger i = 0; i < 4; i++) {
                corners[i] = CGPointApplyAffineTransform(corners[i], selectionToView);
                reflecting[i] = CGAffineTransformMake(1.0, 0.0, 0.0, 1.0, aViewPoint.x - corners[i].x, aViewPoint.y - corners[i].y);
            }
            guided = [self guidePoints:corners count:4 withReflectingTransforms:reflecting asDevicePixelCenters:NO forMovementFromPoint:lastView toPoint:aViewPoint centeringOnDevicePixel:YES inMode:(char *)&_guidingMode withEvent:aEvent];
        }
        p = CGPointApplyAffineTransform(guided, [self viewToImageTransform]);
        _selectionAffineTransform = _baseSelectionAffineTransform;
        _selectionAffineTransform.tx = (p.x - _startImagePoint.x) + _baseSelectionAffineTransform.tx;
        _selectionAffineTransform.ty = (p.y - _startImagePoint.y) + _baseSelectionAffineTransform.ty;
        break;
    }
    case 2: {
        BTModifySelectionToolCalculateBounds(self);
        NSUInteger flags = [(NSEvent *)aEvent modifierFlags];
        BOOL proportionally = (flags >> 17) & 1;
        NSUInteger part = _selectionPart;
        if (part <= 9) {
            if ((0x154 >> part) & 1)
                proportionally ^= _isProportionalModePrimaryForCorners;
            else if ((0x2a8 >> part) & 1)
                proportionally ^= _isProportionalModePrimaryForSides;
        }
        CGPoint center = _selectionOperationCenter;
        CGSize factor = _deltaFactor;
        BOOL aboutCenter = (flags >> 20) & 1;
        if (aboutCenter) {
            center.y = _selectionPathBounds.size.height * 0.5 + _selectionPathBounds.origin.y;
            center.x = _selectionPathBounds.size.width * 0.5 + _selectionPathBounds.origin.x;
            factor.height += factor.height;
            factor.width += factor.width;
        }
        CGAffineTransform inverse = CGAffineTransformInvert(_baseSelectionAffineTransform);
        CGFloat width = _selectionPathBounds.size.width;
        CGFloat height = _selectionPathBounds.size.height;
        // No side shrinks below one image unit.
        CGFloat minWidth = 1.0 / hypot(_baseSelectionAffineTransform.a, _baseSelectionAffineTransform.b);
        CGFloat minHeight = 1.0 / hypot(_baseSelectionAffineTransform.c, _baseSelectionAffineTransform.d);

        CGFloat scaleX = 1.0;
        for (int pass = 0; pass < 2; pass++) {
            CGFloat sx = (inverse.a * p.x + inverse.c * p.y + inverse.tx - _startSelectionPoint.x) * factor.width + width;
            CGFloat sy = (inverse.b * p.x + inverse.d * p.y + inverse.ty - _startSelectionPoint.y) * factor.height + height;
            if (minWidth > fabs(sx))
                sx = copysign(minWidth, sx);
            if (minHeight > fabs(sy))
                sy = copysign(minHeight, sy);
            sy = sy / height;
            sx = sx / width;
            if (pass == 0 && proportionally) {
                switch (_selectionAspectRatioMaintainingRule) {
                case 0:
                    if (fabs(sx) > fabs(sy))
                        sx = copysign(fabs(sy), sx);
                    else
                        sy = copysign(fabs(sx), sy);
                    break;
                case 1:
                    if (fabs(sx) > fabs(sy))
                        sy = copysign(fabs(sx), sy);
                    else
                        sx = copysign(fabs(sy), sx);
                    break;
                case 2:
                    sy = copysign(fabs(sx), sy);
                    break;
                case 3:
                    sx = copysign(fabs(sy), sx);
                    break;
                default:
                    NSLog(@"Unsupported selection aspect ratio maintaining rule.");
                    break;
                }
            }
            CGAffineTransform base = _baseSelectionAffineTransform;
            CGFloat kx = (1.0 - sx) * center.x;
            CGFloat ky = (1.0 - sy) * center.y;
            _selectionAffineTransform.a = base.a * sx;
            _selectionAffineTransform.b = base.b * sx;
            _selectionAffineTransform.c = base.c * sy;
            _selectionAffineTransform.d = base.d * sy;
            _selectionAffineTransform.tx = ky * base.c + base.a * kx + base.tx;
            _selectionAffineTransform.ty = base.b * kx + ky * base.d + base.ty;
            scaleX = sx;
            // Snapping moves p; the scale then follows it without the aspect rule.
            if (pass == 0 && ![self BTModifySelectionTool_guideResizingAboutPoint:center withPoint:&p event:aEvent proportionally:proportionally aboutCenter:aboutCenter])
                break;
        }
        _isSelectionFlippedHorizontally = _isBaseSelectionFlippedHorizontally ^ (scaleX < 0.0);
        break;
    }
    case 3: {
        NSUInteger flags = [(NSEvent *)aEvent modifierFlags];
        CGPoint center = _selectionOperationCenter;
        CGFloat delta = atan2(p.y - center.y, p.x - center.x) - atan2(_startImagePoint.y - center.y, _startImagePoint.x - center.x);
        // Shift snaps to 45 degrees, Option to 15.
        CGFloat step = (flags & NSShiftKeyMask) ? M_PI_4 : ((flags & NSAlternateKeyMask) ? M_PI / 12.0 : 0.0);
        CGFloat angle;
        if (step == 0.0) {
            angle = delta;
        } else {
            CGFloat baseAngle = BTModifySelectionToolRotationAngle(_baseSelectionAffineTransform, _isBaseSelectionFlippedHorizontally);
            angle = step * round((delta + baseAngle) / step) - baseAngle;
        }
        CGAffineTransform base = _baseSelectionAffineTransform;
        CGFloat sine = sin(angle);
        CGFloat cosine = cos(angle);
        _selectionAffineTransform.a = base.a * cosine - base.b * sine;
        _selectionAffineTransform.b = base.b * cosine + base.a * sine;
        _selectionAffineTransform.c = base.c * cosine - base.d * sine;
        _selectionAffineTransform.d = base.d * cosine + base.c * sine;
        _selectionAffineTransform.tx = (1.0 - cosine) * center.x + sine * center.y + (base.tx * cosine - base.ty * sine);
        _selectionAffineTransform.ty = (1.0 - cosine) * center.y - sine * center.x + (base.ty * cosine + base.tx * sine);
        break;
    }
    default:
        NSLog(@"Unsupported operation.");
        break;
    }
    return p;
}

/* Snaps the dragged knob; aPoint (selection space) is the fixed point of the scaling. */
- (BOOL)BTModifySelectionTool_guideResizingAboutPoint:(CGPoint)aPoint withPoint:(CGPoint *)aPoint2 event:(id)aEvent proportionally:(BOOL)aProportionally aboutCenter:(BOOL)aCenter
{
    id context = [_delegate layoutGuidingContextForTool:self];
    if (context == nil)
        return NO;
    CGPoint reflecting = CGPointApplyAffineTransform(*aPoint2, [self imageToViewTransform]);

    // Corner knob parts and the corner index they drag; side knobs drag two corners.
    static const NSInteger corners[10][2] = {
        { -1, -1 }, { -1, -1 }, { 0, -1 }, { 0, 1 }, { 1, -1 }, { 1, 2 }, { 2, -1 }, { 2, 3 }, { 3, -1 }, { 3, 0 }
    };
    NSInteger part = _selectionPart;
    id sources = nil;
    if (part >= 2 && part <= 9) {
        NSUInteger i = corners[part][0];
        NSInteger j = corners[part][1];
        if (j < 0)
            sources = aCenter
                ? [self BTModifySelectionTool_pointSnapSourcesForResizingSelectionByCornerAtIndex:i aboutPoint:aPoint proportionally:aProportionally withReflectingPoint:reflecting]
                : [self BTModifySelectionTool_pointSnapSourcesForResizingSelectionByCornerAtIndex:i proportionally:aProportionally withReflectingPoint:reflecting];
        else
            sources = aCenter
                ? [self BTModifySelectionTool_pointSnapSourcesForResizingSelectionBySideWithCornerAtIndex:i andCornerAtIndex:j aboutPoint:aPoint proportionally:aProportionally withReflectingPoint:reflecting]
                : [self BTModifySelectionTool_pointSnapSourcesForResizingSelectionBySideWithCornerAtIndex:i andCornerAtIndex:j proportionally:aProportionally withReflectingPoint:reflecting];
    }

    id rules = nil;
    if (![context snapPoints:sources sizes:nil withEvent:aEvent options:nil snappedReflectedPoint:&reflecting snapDistance:NULL appliedRules:&rules])
        return NO;
    [self BTModifySelectionTool_showAppliedRules:rules forSnappedPoint:*aPoint2 withLayoutGuidingContext:context];
    *aPoint2 = CGPointApplyAffineTransform(reflecting, [self viewToImageTransform]);
    return YES;
}

/*
 * The four snap sources (view space) are the dragged side's corners and
 * their neighbours. Each reflects onto where the side's middle knob would
 * be when that corner sits at the snapped point, scaling about aPoint.
 * Proportionally they slide along the lines from the center.
 */
- (id)BTModifySelectionTool_pointSnapSourcesForResizingSelectionBySideWithCornerAtIndex:(NSUInteger)aIndex andCornerAtIndex:(NSUInteger)aIndex2 aboutPoint:(CGPoint)aPoint proportionally:(BOOL)aProportionally withReflectingPoint:(CGPoint)aPoint2
{
    CGPoint corners[4];
    BTModifySelectionToolBoundsCorners(self, corners);
    CGAffineTransform toView = CGAffineTransformConcat(_selectionAffineTransform, [self imageToViewTransform]);
    CGAffineTransform fromView = CGAffineTransformInvert(toView);
    NSUInteger indices[4] = { (aIndex2 + 1) & 3, (aIndex + 3) & 3, aIndex2, aIndex };
    CGPoint views[4];
    for (NSUInteger k = 0; k < 4; k++)
        views[k] = CGPointApplyAffineTransform(corners[indices[k]], toView);

    CGELine lines[4];
    if (!aProportionally) {
        lines[0] = lines[2] = BTModifySelectionToolLineThrough(views[0], views[2]);
        lines[1] = lines[3] = BTModifySelectionToolLineThrough(views[1], views[3]);
    } else {
        CGPoint center = CGPointApplyAffineTransform(aPoint, toView);
        for (NSUInteger k = 0; k < 4; k++)
            lines[k] = BTModifySelectionToolLineThrough(center, views[k]);
    }

    CGPoint middle = CGPointMake((corners[aIndex].x + corners[aIndex2].x) * 0.5, (corners[aIndex].y + corners[aIndex2].y) * 0.5);
    CGPoint viewMiddle = CGPointMake((views[3].x + views[2].x) * 0.5, (views[3].y + views[2].y) * 0.5);
    id sources[4];
    for (NSUInteger k = 0; k < 4; k++)
        sources[k] = BTModifySelectionToolSource(views[k], lines[k],
            BTModifySelectionToolReflectingTransform(toView, fromView, BTModifySelectionToolScaling(aPoint, corners[indices[k]], middle), aPoint2, viewMiddle));
    return [NSArray arrayWithObjects:sources[3], sources[2], sources[1], sources[0], nil];
}

/* All four corners, each reflecting onto the dragged corner aIndex. */
- (id)BTModifySelectionTool_pointSnapSourcesForResizingSelectionByCornerAtIndex:(NSUInteger)aIndex aboutPoint:(CGPoint)aPoint proportionally:(BOOL)aProportionally withReflectingPoint:(CGPoint)aPoint2
{
    CGPoint corners[4];
    BTModifySelectionToolBoundsCorners(self, corners);
    CGAffineTransform toView = CGAffineTransformConcat(_selectionAffineTransform, [self imageToViewTransform]);
    CGAffineTransform fromView = CGAffineTransformInvert(toView);
    NSUInteger indices[4] = { (aIndex + 1) & 3, (aIndex + 3) & 3, (aIndex + 2) & 3, aIndex };
    CGPoint views[4];
    for (NSUInteger k = 0; k < 4; k++)
        views[k] = CGPointApplyAffineTransform(corners[indices[k]], toView);

    CGELine lines[4] = { CGELineUndefined, CGELineUndefined, CGELineUndefined, CGELineUndefined };
    if (aProportionally) {
        CGPoint center = CGPointApplyAffineTransform(aPoint, toView);
        for (NSUInteger k = 0; k < 4; k++)
            lines[k] = BTModifySelectionToolLineThrough(center, views[k]);
    }

    id sources[4];
    for (NSUInteger k = 0; k < 3; k++)
        sources[k] = BTModifySelectionToolSource(views[k], lines[k],
            BTModifySelectionToolReflectingTransform(toView, fromView, BTModifySelectionToolScaling(aPoint, corners[indices[k]], corners[aIndex]), aPoint2, views[3]));
    sources[3] = BTModifySelectionToolSource(views[3], lines[3],
        CGAffineTransformMake(1.0, 0.0, 0.0, 1.0, aPoint2.x - views[3].x, aPoint2.y - views[3].y));
    return [NSArray arrayWithObjects:sources[3], sources[2], sources[1], sources[0], nil];
}

/*
 * The dragged side's two corners; they move along the adjacent sides (or,
 * proportionally, along the lines from the opposite side's middle) and
 * reflect onto the side's middle knob.
 */
- (id)BTModifySelectionTool_pointSnapSourcesForResizingSelectionBySideWithCornerAtIndex:(NSUInteger)aIndex andCornerAtIndex:(NSUInteger)aIndex2 proportionally:(BOOL)aProportionally withReflectingPoint:(CGPoint)aPoint
{
    CGPoint corners[4];
    BTModifySelectionToolBoundsCorners(self, corners);
    CGAffineTransform toView = CGAffineTransformConcat(_selectionAffineTransform, [self imageToViewTransform]);
    CGAffineTransform fromView = CGAffineTransformInvert(toView);
    CGPoint corner2 = CGPointApplyAffineTransform(corners[aIndex2], toView);
    CGPoint corner = CGPointApplyAffineTransform(corners[aIndex], toView);
    CGPoint next2 = CGPointApplyAffineTransform(corners[(aIndex2 + 1) & 3], toView);
    CGPoint previous = CGPointApplyAffineTransform(corners[(aIndex + 3) & 3], toView);
    if (aProportionally) {
        next2 = CGPointMake((previous.x + next2.x) * 0.5, (previous.y + next2.y) * 0.5);
        previous = next2;
    }

    CGPoint middle = CGPointMake((corners[aIndex].x + corners[aIndex2].x) * 0.5, (corners[aIndex].y + corners[aIndex2].y) * 0.5);
    CGPoint viewMiddle = CGPointMake((corner.x + corner2.x) * 0.5, (corner.y + corner2.y) * 0.5);
    id source2 = BTModifySelectionToolSource(corner2, BTModifySelectionToolLineThrough(next2, corner2),
        BTModifySelectionToolReflectingTransform(toView, fromView, CGAffineTransformMakeTranslation(middle.x - corners[aIndex2].x, middle.y - corners[aIndex2].y), aPoint, viewMiddle));
    id source = BTModifySelectionToolSource(corner, BTModifySelectionToolLineThrough(previous, corner),
        BTModifySelectionToolReflectingTransform(toView, fromView, CGAffineTransformMakeTranslation(middle.x - corners[aIndex].x, middle.y - corners[aIndex].y), aPoint, viewMiddle));
    return [NSArray arrayWithObjects:source, source2, nil];
}

/*
 * The dragged corner, along the diagonal when proportional. The original
 * also builds sources for the two adjacent corners but lists them after a
 * nil, so only the corner's own source is returned.
 */
- (id)BTModifySelectionTool_pointSnapSourcesForResizingSelectionByCornerAtIndex:(NSUInteger)aIndex proportionally:(BOOL)aProportionally withReflectingPoint:(CGPoint)aPoint
{
    CGPoint corners[4];
    BTModifySelectionToolBoundsCorners(self, corners);
    CGAffineTransform toView = CGAffineTransformConcat(_selectionAffineTransform, [self imageToViewTransform]);
    CGPoint corner = CGPointApplyAffineTransform(corners[aIndex], toView);
    CGPoint opposite = CGPointApplyAffineTransform(corners[(aIndex + 2) & 3], toView);
    CGELine line = aProportionally ? BTModifySelectionToolLineThrough(opposite, corner) : CGELineUndefined;
    id source = BTModifySelectionToolSource(corner, line, CGAffineTransformMake(1.0, 0.0, 0.0, 1.0, aPoint.x - corner.x, aPoint.y - corner.y));
    return [NSArray arrayWithObjects:source, nil];
}

- (void)BTModifySelectionTool_showAppliedRules:(id)aRules forSnappedPoint:(CGPoint)aPoint withLayoutGuidingContext:(id)aContext
{
    SEL showSel = @selector(SMKBitmapTools_showAppliedRules:forSnappedPoint:);
    if ([aContext respondsToSelector:showSel]) {
        NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[aContext methodSignatureForSelector:showSel]];
        [inv setTarget:aContext];
        [inv setSelector:showSel];
        [inv setArgument:&aRules atIndex:2];
        [inv setArgument:&aPoint atIndex:3];
        [inv invoke];
    } else {
        [aContext showAppliedRules:aRules];
    }
}

- (BOOL)isFeedbackLayerActive:(id)aLayer
{
    return [aLayer isEqualToString:@"BTSelectionFeedbackLayer"];
}

- (id)activeFeedbackLayers
{
    return [NSSet setWithObject:@"BTSelectionFeedbackLayer"];
}

- (id)activeFeedbackLayersForDrawing
{
    return [NSArray arrayWithObject:@"BTSelectionFeedbackLayer"];
}

/*
 * Marching ants (white and red dashes) just inside the transformed bounds,
 * the eight resize knobs and the rotate handle with its line to the
 * center, all aligned to device pixels.
 */
- (void)draw_BTSelectionFeedbackLayer_Rect:(NSRect)aRect
{
    if (_selectionPath == NULL)
        return;
    CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];
    if (context == NULL)
        return;
    CGMutablePathRef path = (CGMutablePathRef)CFAutorelease(CGPathCreateMutable());
    if (path == NULL)
        return;

    BTModifySelectionToolCalculateBounds(self);
    CGAffineTransform toView = [self imageToViewTransform];
    CGAffineTransform selectionToView = CGAffineTransformConcat(_selectionAffineTransform, toView);
    CGRect bounds = _selectionPathBounds;
    CGFloat sx = hypot(selectionToView.a, selectionToView.b);
    CGFloat sy = hypot(selectionToView.c, selectionToView.d);
    CGFloat iy = sy != 0.0 ? 0.5 / sy : 0.0;
    CGFloat ix = sx != 0.0 ? 0.5 / sx : 0.0;
    CGRect inner = CGRectMake(bounds.origin.x + ix, bounds.origin.y + iy, bounds.size.width + ix * -2.0, bounds.size.height + iy * -2.0);
    if (!CGRectIsEmpty(inner)) {
        CGFloat fx = bounds.size.width != 0.0 ? inner.size.width / bounds.size.width : 1.0;
        CGFloat fy = bounds.size.height != 0.0 ? inner.size.height / bounds.size.height : 1.0;
        CGAffineTransform shrink = CGAffineTransformMake(fx, 0.0, 0.0, fy, inner.origin.x - bounds.origin.x * fx, inner.origin.y - bounds.origin.y * fy);
        CGAffineTransform m = CGAffineTransformConcat(shrink, selectionToView);
        CGPathAddPath(path, &m, _selectionPath);
        CGContextSetLineWidth(context, 1.0);
        CGFloat dash[2] = { 3.0, 5.0 };
        CGContextSetLineDash(context, _selectionFeedbackLineDashPhase, dash, 2);
        CGContextSetRGBStrokeColor(context, 1.0, 1.0, 1.0, 1.0);
        CGContextBeginPath(context);
        CGContextAddPath(context, path);
        CGContextStrokePath(context);
        dash[0] = 5.0;
        dash[1] = 3.0;
        CGContextSetLineDash(context, _selectionFeedbackLineDashPhase + 5.0, dash, 2);
        CGContextSetRGBStrokeColor(context, 1.0, 0.0, 0.0, 1.0);
        CGContextBeginPath(context);
        CGContextAddPath(context, path);
        CGContextStrokePath(context);
    }
    CGContextSetLineDash(context, 0.0, NULL, 0);

    CGAffineTransform ctm = CGContextGetCTM(context);
    CGAffineTransform toDevice = CGAffineTransformConcat(selectionToView, ctm);
    CGAffineTransform fromDevice = CGAffineTransformInvert(ctm);
    CGFloat deviceX = hypot(ctm.a, ctm.b);
    CGFloat deviceY = hypot(ctm.c, ctm.d);
    // Offsets that center odd-sized knobs on device pixels.
    CGFloat knobX = fmod(round(deviceX * 7.0) * 0.5, 1.0);
    CGFloat knobY = fmod(round(deviceY * 7.0) * 0.5, 1.0);

    CGFloat x = bounds.origin.x, y = bounds.origin.y;
    CGFloat midX = bounds.size.width * 0.5 + x;
    CGFloat midY = bounds.size.height * 0.5 + y;
    CGFloat maxY = bounds.size.height + y;
    CGFloat maxX = bounds.size.width + x;
    CGPoint lineStart = CGPointMake(midX, midY);
    CGPoint centerDot = CGPointMake(midX, midY);
    CGPoint lineEnd, handle;
    if (_isTracking && _selectionOperation == 3) {
        handle = lineEnd = CGPointApplyAffineTransform(_lastImagePoint, toView);
    } else {
        CGFloat unit = hypot(selectionToView.a, selectionToView.b);
        unit = unit != 0.0 ? 1.0 / unit : 1.0;
        CGFloat handleX = _isSelectionFlippedHorizontally ? unit * -27.5 + x : unit * 27.5 + maxX;
        CGFloat dx = toDevice.c * midY + toDevice.a * handleX + toDevice.tx + 0.0001;
        CGFloat dy = toDevice.b * handleX + toDevice.d * midY + toDevice.ty + 0.0001;
        lineEnd = CGPointApplyAffineTransform(CGPointMake(round(dx + 0.5) + -0.5, round(dy + 0.5) + -0.5), fromDevice);
        handle = CGPointApplyAffineTransform(CGPointMake(round(dx + knobX) - knobX, round(dy + knobY) - knobY), fromDevice);
    }

    CGFloat dotX = fmod(round(deviceX * 3.0) * 0.5, 1.0);
    CGFloat dotY = fmod(round(deviceY * 3.0) * 0.5, 1.0);
    CGPoint *centers[2] = { &lineStart, &centerDot };
    CGFloat offsets[2][2] = { { 0.5, 0.5 }, { dotX, dotY } };
    for (int k = 0; k < 2; k++) {
        CGPoint *c = centers[k];
        CGFloat dx = toDevice.c * c->y + toDevice.a * c->x + toDevice.tx + 0.0001;
        CGFloat dy = toDevice.b * c->x + toDevice.d * c->y + toDevice.ty + 0.0001;
        *c = CGPointApplyAffineTransform(CGPointMake(round(dx + offsets[k][0]) - offsets[k][0], round(dy + offsets[k][1]) - offsets[k][1]), fromDevice);
    }

    CGContextSetLineWidth(context, 1.0);
    CGContextSetRGBStrokeColor(context, 1.0, 0.0, 0.0, 0.7);
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, lineStart.x, lineStart.y);
    CGContextAddLineToPoint(context, lineEnd.x, lineEnd.y);
    CGContextStrokePath(context);
    CGContextSetRGBFillColor(context, 1.0, 0.0, 0.0, 0.7);
    CGContextBeginPath(context);
    CGContextAddRect(context, CGRectMake(centerDot.x + -1.5, centerDot.y + -1.5, 3.0, 3.0));
    CGContextFillPath(context);

    CGPoint knobs[8] = {
        { x, y }, { x, midY }, { x, maxY }, { midX, maxY }, { maxX, maxY }, { maxX, midY }, { maxX, y }, { midX, y }
    };
    CGContextSetLineWidth(context, 2.0);
    CGContextSetRGBStrokeColor(context, 1.0, 0.0, 0.0, 1.0);
    CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 1.0);
    for (int k = 0; k < 8; k++) {
        CGFloat dx = toDevice.c * knobs[k].y + toDevice.a * knobs[k].x + toDevice.tx + 0.0001;
        CGFloat dy = toDevice.b * knobs[k].x + toDevice.d * knobs[k].y + toDevice.ty + 0.0001;
        knobs[k] = CGPointApplyAffineTransform(CGPointMake(round(dx + knobX) - knobX, round(dy + knobY) - knobY), fromDevice);
        [self BTModifySelectionTool_drawKnobInContext:context atPoint:knobs[k]];
    }
    [self BTModifySelectionTool_drawKnobInContext:context atPoint:handle];
}

- (void)BTModifySelectionTool_drawKnobInContext:(struct CGContext *)aContext atPoint:(CGPoint)aPoint
{
    CGContextBeginPath(aContext);
    CGContextAddRect(aContext, CGRectMake(aPoint.x + -1.5, aPoint.y + -1.5, 3.0, 3.0));
    CGContextFillPath(aContext);
    CGContextBeginPath(aContext);
    CGContextAddRect(aContext, CGRectMake(aPoint.x + -2.5, aPoint.y + -2.5, 5.0, 5.0));
    CGContextStrokePath(aContext);
}

- (void)finalize:(id)aSender
{
    if (_selectionOperation == 0)
        [_delegate tool:self didFinalizeStage:@"BTWaitingToolStage" withEvent:nil nextStage:nil];
}

- (void)reset:(id)aSender
{
    if (_selectionPath == NULL)
        return;
    [self beginUndoAction];
    [self setSelectionAffineTransform:CGAffineTransformIdentity flippingHorizontally:_isSelectionFlippedHorizontally];
    [self endUndoActionWithName:@"Reset Selection"];
}

- (void)unrotate:(id)aSender
{
    if (_selectionPath == NULL)
        return;
    [self beginUndoAction];
    [self rotateSelectionAboutCenterBy:-BTModifySelectionToolRotationAngle(_selectionAffineTransform, _isSelectionFlippedHorizontally)];
    [self endUndoActionWithName:@"Unrotate Selection"];
}

- (void)unscale:(id)aSender
{
    if (_selectionPath == NULL)
        return;
    CGFloat sx = hypot(_selectionAffineTransform.a, _selectionAffineTransform.b);
    sx = sx != 0.0 ? 1.0 / sx : 1.0;
    CGFloat sy = hypot(_selectionAffineTransform.c, _selectionAffineTransform.d);
    sy = sy != 0.0 ? 1.0 / sy : 1.0;
    [self beginUndoAction];
    [self scaleSelectionAboutCenterBy:CGSizeMake(sx, sy)];
    [self endUndoActionWithName:@"Unscale Selection"];
}

/*
 * Replaces the whole transform with the mirror that undoes the flip
 * (horizontal for a flipped selection, plus vertical when the transform's
 * orientation disagrees with the flag), as the original does.
 */
- (void)unflip:(id)aSender
{
    if (_selectionPath == NULL)
        return;
    BOOL mirrored = _selectionAffineTransform.a * _selectionAffineTransform.d < _selectionAffineTransform.b * _selectionAffineTransform.c;
    BOOL flipped = _isSelectionFlippedHorizontally;
    if (!flipped && !mirrored)
        return;
    BTModifySelectionToolCalculateBounds(self);
    CGRect b = _selectionPathBounds;
    CGAffineTransform t;
    if (flipped) {
        t = CGAffineTransformMake(-1.0, 0.0, 0.0, 1.0, b.origin.x + b.origin.x + b.size.width, 0.0);
        if (flipped != mirrored)
            t = CGAffineTransformMake(-1.0, -0.0, 0.0, -1.0, t.tx, b.origin.y + b.origin.y + b.size.height);
    } else {
        t = CGAffineTransformMake(1.0, 0.0, 0.0, -1.0, 0.0, b.origin.y + b.origin.y + b.size.height);
    }
    [self beginUndoAction];
    [self setSelectionAffineTransform:t flippingHorizontally:_isSelectionFlippedHorizontally];
    [self endUndoActionWithName:@"Unflip Selection"];
}

- (void)rotateBy90DegreesCounterClockwise:(id)aSender
{
    [self rotateSelectionAboutCenterBy:M_PI_2];
}

- (void)rotateBy90DegreesClockwise:(id)aSender
{
    [self rotateSelectionAboutCenterBy:-M_PI_2];
}

- (void)flipVertically:(id)aSender
{
    [self flipSelectionVertically];
}

- (void)flipHorizontally:(id)aSender
{
    [self flipSelectionHorizontally];
}

- (void)nudgeDown:(id)aSender
{
    [self moveSelectionBy:CGSizeMake(0.0, -10.0)];
}

- (void)nudgeUp:(id)aSender
{
    [self moveSelectionBy:CGSizeMake(0.0, 10.0)];
}

- (void)nudgeLeft:(id)aSender
{
    [self moveSelectionBy:CGSizeMake(-10.0, 0.0)];
}

- (void)nudgeRight:(id)aSender
{
    [self moveSelectionBy:CGSizeMake(10.0, 0.0)];
}

- (void)moveDown:(id)aSender
{
    [self moveSelectionBy:CGSizeMake(0.0, -1.0)];
}

- (void)moveUp:(id)aSender
{
    [self moveSelectionBy:CGSizeMake(0.0, 1.0)];
}

- (void)moveLeft:(id)aSender
{
    [self moveSelectionBy:CGSizeMake(-1.0, 0.0)];
}

- (void)moveRight:(id)aSender
{
    [self moveSelectionBy:CGSizeMake(1.0, 0.0)];
}

- (BOOL)validateAction_finalize
{
    return _selectionOperation == 0;
}

- (BOOL)validateAction_reset
{
    return _selectionPath != NULL;
}

- (BOOL)validateAction_unrotate
{
    return _selectionPath != NULL;
}

- (BOOL)validateAction_unscale
{
    return _selectionPath != NULL;
}

- (BOOL)validateAction_unflip
{
    return _selectionPath != NULL;
}

- (BOOL)validateAction_rotateBy90DegreesCounterClockwise
{
    return _selectionPath != NULL;
}

- (BOOL)validateAction_rotateBy90DegreesClockwise
{
    return _selectionPath != NULL;
}

- (BOOL)validateAction_flipVertically
{
    return _selectionPath != NULL;
}

- (BOOL)validateAction_flipHorizontally
{
    return _selectionPath != NULL;
}

- (BOOL)validateAction_nudgeDown
{
    return _selectionPath != NULL;
}

- (BOOL)validateAction_nudgeUp
{
    return _selectionPath != NULL;
}

- (BOOL)validateAction_nudgeLeft
{
    return _selectionPath != NULL;
}

- (BOOL)validateAction_nudgeRight
{
    return _selectionPath != NULL;
}

- (BOOL)validateAction_moveDown
{
    return _selectionPath != NULL;
}

- (BOOL)validateAction_moveUp
{
    return _selectionPath != NULL;
}

- (BOOL)validateAction_moveLeft
{
    return _selectionPath != NULL;
}

- (BOOL)validateAction_moveRight
{
    return _selectionPath != NULL;
}

- (void)moveSelectionBy:(CGSize)aBy
{
    if (_selectionPath == NULL)
        return;
    [self beginUndoAction];
    CGAffineTransform t = _selectionAffineTransform;
    t.tx = aBy.width + _selectionAffineTransform.tx;
    t.ty = aBy.height + _selectionAffineTransform.ty;
    [self setSelectionAffineTransform:t flippingHorizontally:NO];
    [self endUndoActionWithName:@"Move Selection"];
}

- (void)rotateSelectionAboutCenterBy:(CGFloat)aBy
{
    if (_selectionPath == NULL)
        return;
    BTModifySelectionToolCalculateBounds(self);
    CGRect b = _selectionPathBounds;
    CGFloat sine = sin(aBy);
    CGFloat cosine = cos(aBy);
    [self beginUndoAction];
    CGAffineTransform s = _selectionAffineTransform;
    // The bounds center in image space stays put.
    CGFloat cy = b.origin.y + b.size.height * 0.5;
    CGFloat cx = b.origin.x + b.size.width * 0.5;
    CGFloat px = s.a * cx + s.c * cy + s.tx;
    CGFloat py = s.b * cx + s.d * cy + s.ty;
    CGAffineTransform t;
    t.a = s.a * cosine - s.b * sine;
    t.b = s.a * sine + s.b * cosine;
    t.c = s.c * cosine - s.d * sine;
    t.d = s.c * sine + s.d * cosine;
    t.tx = (s.tx * cosine - s.ty * sine) + sine * py + (1.0 - cosine) * px;
    t.ty = s.ty * cosine + s.tx * sine + ((1.0 - cosine) * py - sine * px);
    [self setSelectionAffineTransform:t flippingHorizontally:NO];
    [self endUndoActionWithName:@"Rotate Selection"];
}

- (void)scaleSelectionAboutCenterBy:(CGSize)aBy
{
    if (_selectionPath == NULL)
        return;
    BTModifySelectionToolCalculateBounds(self);
    CGRect b = _selectionPathBounds;
    [self beginUndoAction];
    CGAffineTransform s = _selectionAffineTransform;
    CGFloat kx = (b.origin.x + b.size.width * 0.5) * (1.0 - aBy.width);
    CGFloat ky = (b.origin.y + b.size.height * 0.5) * (1.0 - aBy.height);
    CGAffineTransform t;
    t.a = s.a * aBy.width;
    t.b = s.b * aBy.width;
    t.c = s.c * aBy.height;
    t.d = s.d * aBy.height;
    t.tx = ky * s.c + s.a * kx + s.tx;
    t.ty = kx * s.b + ky * s.d + s.ty;
    [self setSelectionAffineTransform:t flippingHorizontally:aBy.width < 0.0];
    [self endUndoActionWithName:@"Scale Selection"];
}

- (void)flipSelectionVertically
{
    if (_selectionPath == NULL)
        return;
    BTModifySelectionToolCalculateBounds(self);
    [self beginUndoAction];
    CGAffineTransform s = _selectionAffineTransform;
    CGFloat axis = _selectionPathBounds.origin.y + _selectionPathBounds.origin.y + _selectionPathBounds.size.height;
    CGAffineTransform t = CGAffineTransformMake(s.a, s.b, -s.c, -s.d, s.c * axis + s.tx, s.d * axis + s.ty);
    [self setSelectionAffineTransform:t flippingHorizontally:NO];
    [self endUndoActionWithName:@"Flip Vertically Selection"];
}

- (void)flipSelectionHorizontally
{
    if (_selectionPath == NULL)
        return;
    BTModifySelectionToolCalculateBounds(self);
    [self beginUndoAction];
    CGAffineTransform s = _selectionAffineTransform;
    CGFloat axis = _selectionPathBounds.origin.x + _selectionPathBounds.origin.x + _selectionPathBounds.size.width;
    CGAffineTransform t = CGAffineTransformMake(-s.a, -s.b, s.c, s.d, s.a * axis + s.tx, s.b * axis + s.ty);
    [self setSelectionAffineTransform:t flippingHorizontally:YES];
    [self endUndoActionWithName:@"Flip Horizontally Selection"];
}

- (void)posttransformSelectionUsingAffineTransform:(CGAffineTransform)aTransform flippingHorizontally:(BOOL)aHorizontally
{
    if (_selectionPath != NULL)
        [self setSelectionAffineTransform:CGAffineTransformConcat(_selectionAffineTransform, aTransform) flippingHorizontally:aHorizontally];
}

- (void)pretransformSelectionUsingAffineTransform:(CGAffineTransform)aTransform flippingHorizontally:(BOOL)aHorizontally
{
    if (_selectionPath != NULL)
        [self setSelectionAffineTransform:CGAffineTransformConcat(aTransform, _selectionAffineTransform) flippingHorizontally:aHorizontally];
}

/* aHorizontally toggles the flip flag. */
- (void)setSelectionAffineTransform:(CGAffineTransform)aTransform flippingHorizontally:(BOOL)aHorizontally
{
    if (_selectionPath != NULL)
        [self setSelectionAffineTransform:aTransform flippedHorizontally:aHorizontally ? !_isSelectionFlippedHorizontally : (BOOL)_isSelectionFlippedHorizontally];
}

- (void)setSelectionAffineTransform:(CGAffineTransform)aTransform flippedHorizontally:(BOOL)aHorizontally
{
    if (_selectionPath == NULL)
        return;
    [self beginUndoAction];
    BOOL flipChanges = (BOOL)_isSelectionFlippedHorizontally != (aHorizontally != NO);
    if (CGAffineTransformEqualToTransform(aTransform, _selectionAffineTransform)) {
        if (flipChanges)
            [self BTModifySelectionTool_setBaseSelectionFlippedHorizontally:aHorizontally selectionFlippedHorizontally:aHorizontally];
    } else if (flipChanges) {
        [self BTModifySelectionTool_setBaseSelectionAffineTransform:aTransform horizontalFlip:aHorizontally selectionAffineTransform:aTransform horizontalFlip:aHorizontally];
    } else {
        [self BTModifySelectionTool_setBaseSelectionAffineTransform:aTransform selectionAffineTransform:aTransform];
    }
    [self endUndoActionWithName:@"Transform Selection"];
}

/* Picks the operation from the part under the mouse and starts tracking. */
- (BOOL)mouseDown:(id)aEvent
{
    if (_selectionPath != NULL) {
        _startImagePoint = [self eventLocationInImage:aEvent];
        _startSelectionPoint = CGPointApplyAffineTransform(_startImagePoint, CGAffineTransformInvert(_selectionAffineTransform));
        _selectionPart = [self BTModifySelectionTool_selectionPartForPoint:_startSelectionPoint];
        CGRect b = _selectionPathBounds;
        CGFloat maxX = b.origin.x + b.size.width;
        CGFloat maxY = b.origin.y + b.size.height;
        CGFloat midX = b.size.width * 0.5 + b.origin.x;
        CGFloat midY = b.size.height * 0.5 + b.origin.y;
        // Scaling keeps the opposite knob fixed; side knobs keep the aspect along their axis.
        switch (_selectionPart) {
        case 1:
            _selectionOperation = 1;
            _deltaFactor = CGSizeMake(1.0, 1.0);
            break;
        case 2:
            _selectionOperation = 2;
            _selectionAspectRatioMaintainingRule = 0;
            _deltaFactor = CGSizeMake(-1.0, -1.0);
            _selectionOperationCenter = CGPointMake(maxX, maxY);
            break;
        case 3:
            _selectionOperation = 2;
            _selectionAspectRatioMaintainingRule = 2;
            _deltaFactor = CGSizeMake(-1.0, 0.0);
            _selectionOperationCenter = CGPointMake(maxX, midY);
            break;
        case 4:
            _selectionOperation = 2;
            _selectionAspectRatioMaintainingRule = 0;
            _deltaFactor = CGSizeMake(-1.0, 1.0);
            _selectionOperationCenter = CGPointMake(maxX, b.origin.y);
            break;
        case 5:
            _selectionOperation = 2;
            _selectionAspectRatioMaintainingRule = 3;
            _deltaFactor = CGSizeMake(0.0, 1.0);
            _selectionOperationCenter = CGPointMake(midX, b.origin.y);
            break;
        case 6:
            _selectionOperation = 2;
            _selectionAspectRatioMaintainingRule = 0;
            _deltaFactor = CGSizeMake(1.0, 1.0);
            _selectionOperationCenter = CGPointMake(b.origin.x, b.origin.y);
            break;
        case 7:
            _selectionOperation = 2;
            _selectionAspectRatioMaintainingRule = 2;
            _deltaFactor = CGSizeMake(1.0, 0.0);
            _selectionOperationCenter = CGPointMake(b.origin.x, midY);
            break;
        case 8:
            _selectionOperation = 2;
            _selectionAspectRatioMaintainingRule = 0;
            _deltaFactor = CGSizeMake(1.0, -1.0);
            _selectionOperationCenter = CGPointMake(b.origin.x, maxY);
            break;
        case 9:
            _selectionOperation = 2;
            _selectionAspectRatioMaintainingRule = 3;
            _deltaFactor = CGSizeMake(0.0, -1.0);
            _selectionOperationCenter = CGPointMake(midX, maxY);
            break;
        case 10:
            // Rotation turns about the bounds center in image space.
            _selectionOperation = 3;
            _selectionOperationCenter = CGPointApplyAffineTransform(CGPointMake(midX, midY), _selectionAffineTransform);
            break;
        default:
            break;
        }
    }

    if (_selectionOperation == 0) {
        [_delegate tool:self didFinalizeOutputForKey:@"selectionAffineTransform"];
        [_delegate tool:self didFinalizeOutputForKey:@"selectionFlippedHorizontally"];
        return [_delegate tool:self didFinalizeStage:@"BTWaitingToolStage" withEvent:aEvent nextStage:nil];
    }
    id subname = [self BTModifySelectionTool_cursorSubnameForSelectionPart:_selectionPart];
    if (subname != nil)
        _trackingCursorName = [[NSString alloc] initWithFormat:@"do%@SelectionCursor", subname];
    [_view BT_trackMouseWithEvent:aEvent tracker:self startDelay:0.0];
    return YES;
}

- (id)cursorForPoint:(NSPoint)aPoint modifierFlags:(NSUInteger)aFlags
{
    if (_selectionPath == NULL)
        return nil;
    NSPoint imagePoint = [self convertViewPointToImagePoint:aPoint];
    CGPoint selectionPoint = CGPointApplyAffineTransform(imagePoint, CGAffineTransformInvert(_selectionAffineTransform));
    id subname = [self BTModifySelectionTool_cursorSubnameForSelectionPart:[self BTModifySelectionTool_selectionPartForPoint:selectionPoint]];
    if (subname == nil)
        return nil;
    return [self valueForInputKey:[NSString stringWithFormat:@"will%@SelectionCursor", subname]];
}

/* The cursor follows the knob's direction on screen, in eighths of a turn. */
- (id)BTModifySelectionTool_cursorSubnameForSelectionPart:(NSInteger)aPart
{
    static NSString * const rotateNames[8] = {
        @"RotateCenterRight", @"RotateTopRight", @"RotateTopCenter", @"RotateTopLeft",
        @"RotateCenterLeft", @"RotateBottomLeft", @"RotateBottomCenter", @"RotateBottomRight"
    };
    static NSString * const resizeNames[8] = {
        @"ResizeCenterRight", @"ResizeTopRight", @"ResizeTopCenter", @"ResizeTopLeft",
        @"ResizeCenterLeft", @"ResizeBottomLeft", @"ResizeBottomCenter", @"ResizeBottomRight"
    };
    BOOL flipped = _isSelectionFlippedHorizontally;
    CGAffineTransform t = _selectionAffineTransform;
    if (aPart == 10) {
        long index = lround(BTModifySelectionToolRotationAngle(t, flipped) / M_PI_4) % 8;
        return index >= 0 && index < 8 ? rotateNames[index] : nil;
    }
    if (aPart - 2 < 8 && aPart >= 2) {
        long direction = 15 - aPart;
        if (flipped)
            direction = 12 - direction;
        direction &= 7;
        BOOL mirrored = t.a * t.d < t.b * t.c;
        if (flipped != mirrored)
            direction = 8 - direction;
        long index = (direction + lround(BTModifySelectionToolRotationAngle(t, flipped) / M_PI_4)) % 8;
        return index >= 0 && index < 8 ? resizeNames[index] : nil;
    }
    if (aPart == 1)
        return @"Move";
    return nil;
}

/*
 * aPoint is in selection space. Knobs are 5 view points each way; the
 * rotate handle sits 27.5 view points beyond the middle of the right side
 * (the left one when flipped).
 */
- (NSInteger)BTModifySelectionTool_selectionPartForPoint:(NSPoint)aPoint
{
    CGAffineTransform selectionToView = CGAffineTransformConcat(_selectionAffineTransform, [self imageToViewTransform]);
    CGFloat unit = hypot(selectionToView.a, selectionToView.b);
    unit = unit != 0.0 ? 1.0 / unit : 1.0;
    CGFloat unitY = hypot(selectionToView.c, selectionToView.d);
    CGFloat ry = unitY != 0.0 ? 1.0 / unitY * 5.0 : 5.0;
    CGFloat rx = 5.0 * unit;

    NSBezierPath *bezier = nil;
    if (!_areSelectionPathBoundsCalculated) {
        bezier = [NSBezierPath BT_bezierPathWithCGPath:_selectionPath];
        _selectionPathBounds = [bezier bounds];
        _areSelectionPathBoundsCalculated = 1;
    }
    CGRect b = _selectionPathBounds;
    CGFloat x = b.origin.x, y = b.origin.y;
    if (y - ry > aPoint.y)
        return 0;
    CGFloat maxY = y + b.size.height;
    if (aPoint.y > maxY + ry)
        return 0;
    CGFloat maxX = x + b.size.width;
    CGFloat midX = b.size.width * 0.5 + x;

    BOOL bottom = NO, top = NO, middle = NO;
    if (y + ry >= aPoint.y) {
        bottom = YES;
    } else if (aPoint.y >= maxY - ry) {
        top = YES;
    } else {
        CGFloat midY = y + b.size.height * 0.5;
        middle = aPoint.y >= midY - ry && midY + ry >= aPoint.y;
    }

    if (bottom || top || middle) {
        if (x - rx > aPoint.x) {
            if (!middle || !_isSelectionFlippedHorizontally)
                return 0;
            CGFloat handle = unit * -27.5 + x;
            if (aPoint.x < handle - rx)
                return 0;
            return handle + rx < aPoint.x ? 0 : 10;
        }
        if (x + rx >= aPoint.x) {
            if (bottom)
                return 2;
            if (top)
                return 4;
            return 3;
        }
        if (midX + rx >= aPoint.x) {
            if (aPoint.x >= midX - rx) {
                if (bottom)
                    return 9;
                if (top)
                    return 5;
            }
        } else if (maxX + rx >= aPoint.x) {
            if (aPoint.x >= maxX - rx) {
                if (bottom)
                    return 8;
                if (top)
                    return 6;
                return 7;
            }
        } else {
            if (!middle || _isSelectionFlippedHorizontally)
                return 0;
            CGFloat handle = maxX + unit * 27.5;
            if (aPoint.x < handle - rx)
                return 0;
            return handle + rx < aPoint.x ? 0 : 10;
        }
    }
    if (bezier == nil)
        bezier = [NSBezierPath BT_bezierPathWithCGPath:_selectionPath];
    return [bezier containsPoint:aPoint] ? 1 : 0;
}

- (id)allUndoCategories
{
    return [NSSet setWithObject:BTSelectionUndoCategory];
}

- (BOOL)isTracking
{
    return _isTracking;
}

- (id)currentStage
{
    return _selectionOperation == 0 ? @"BTWaitingToolStage" : @"BTModifyingSelectionToolStage";
}

- (void)performDeactivate
{
    if (_selectionPath != NULL) {
        [self BTModifySelectionTool_setNeedsDisplaySelection];
        [self BTModifySelectionTool_stopSelectionFeedbackLineDashPhaseTimer];
    }
    if (_isTracking) {
        [_view BT_abortMouseTracking];
        _isTracking = 0;
    }
    BTModifySelectionToolStopTracking(self);
    [super performDeactivate];
}

- (BOOL)activateWithDelegate:(id)aDelegate inView:(id)aView
{
    if (![super activateWithDelegate:aDelegate inView:aView])
        return NO;
    _selectionFeedbackLineDashPhase = 0.0;
    if (_selectionPath != NULL) {
        [self BTModifySelectionTool_setNeedsDisplaySelection];
        [self BTModifySelectionTool_startSelectionFeedbackLineDashPhaseTimer];
    }
    return YES;
}

- (id)outputKeys
{
    return [NSArray arrayWithObjects:@"selectionAffineTransform", @"selectionFlippedHorizontally", nil];
}

- (id)inputKeys
{
    return [NSArray arrayWithObjects:@"generalKeyBindings", @"proportionalModePrimaryForCorners", @"proportionalModePrimaryForSides",
        @"selectionPath", @"selectionAffineTransform", @"selectionFlippedHorizontally",
        @"willMoveSelectionCursor", @"doMoveSelectionCursor",
        @"willResizeBottomLeftSelectionCursor", @"doResizeBottomLeftSelectionCursor",
        @"willResizeCenterLeftSelectionCursor", @"doResizeCenterLeftSelectionCursor",
        @"willResizeTopLeftSelectionCursor", @"doResizeTopLeftSelectionCursor",
        @"willResizeTopCenterSelectionCursor", @"doResizeTopCenterSelectionCursor",
        @"willResizeTopRightSelectionCursor", @"doResizeTopRightSelectionCursor",
        @"willResizeCenterRightSelectionCursor", @"doResizeCenterRightSelectionCursor",
        @"willResizeBottomRightSelectionCursor", @"doResizeBottomRightSelectionCursor",
        @"willResizeBottomCenterSelectionCursor", @"doResizeBottomCenterSelectionCursor",
        @"willRotateBottomLeftSelectionCursor", @"doRotateBottomLeftSelectionCursor",
        @"willRotateCenterLeftSelectionCursor", @"doRotateCenterLeftSelectionCursor",
        @"willRotateTopLeftSelectionCursor", @"doRotateTopLeftSelectionCursor",
        @"willRotateTopCenterSelectionCursor", @"doRotateTopCenterSelectionCursor",
        @"willRotateTopRightSelectionCursor", @"doRotateTopRightSelectionCursor",
        @"willRotateCenterRightSelectionCursor", @"doRotateCenterRightSelectionCursor",
        @"willRotateBottomRightSelectionCursor", @"doRotateBottomRightSelectionCursor",
        @"willRotateBottomCenterSelectionCursor", @"doRotateBottomCenterSelectionCursor", nil];
}

/* Sets both the base and current flag; undoable while active. */
- (void)setSelectionFlippedHorizontally:(BOOL)aHorizontally
{
    if ((BOOL)_isSelectionFlippedHorizontally == (aHorizontally != NO))
        return;
    BOOL active = [self isActive];
    if (!active) {
        _isSelectionFlippedHorizontally = aHorizontally;
        _isBaseSelectionFlippedHorizontally = aHorizontally;
        return;
    }
    id manager = [_delegate undoManagerForTool:self category:BTSelectionUndoCategory];
    if (manager != nil)
        [[self prepareUndoInManager:manager category:BTSelectionUndoCategory withInvocationTarget:self]
            BTModifySelectionTool_setBaseSelectionFlippedHorizontally:_isBaseSelectionFlippedHorizontally selectionFlippedHorizontally:_isSelectionFlippedHorizontally];
    _isSelectionFlippedHorizontally = aHorizontally;
    _isBaseSelectionFlippedHorizontally = aHorizontally;
    [_delegate tool:self didUpdateCursorWithEvent:nil];
}

- (BOOL)isSelectionFlippedHorizontally
{
    return _isSelectionFlippedHorizontally;
}

/* aTransform is an NSValue holding a CGAffineTransform. */
- (void)setSelectionAffineTransform:(id)aTransform
{
    CGAffineTransform t = CGAffineTransformIdentity;
    [aTransform getValue:&t];
    if (CGAffineTransformEqualToTransform(t, _selectionAffineTransform))
        return;
    BOOL active = [self isActive];
    if (active) {
        if (_selectionPath != NULL)
            [self BTModifySelectionTool_setNeedsDisplaySelection];
        id manager = [_delegate undoManagerForTool:self category:BTSelectionUndoCategory];
        if (manager != nil)
            [[self prepareUndoInManager:manager category:BTSelectionUndoCategory withInvocationTarget:self]
                BTModifySelectionTool_setBaseSelectionAffineTransform:_baseSelectionAffineTransform selectionAffineTransform:_selectionAffineTransform];
    }
    _selectionAffineTransform = t;
    _baseSelectionAffineTransform = t;
    if (active) {
        if (_selectionPath != NULL)
            [self BTModifySelectionTool_setNeedsDisplaySelection];
        [_delegate tool:self didUpdateCursorWithEvent:nil];
    }
}

- (id)selectionAffineTransform
{
    return [NSValue valueWithBytes:&_selectionAffineTransform objCType:@encode(CGAffineTransform)];
}

- (void)BTModifySelectionTool_setBaseSelectionAffineTransform:(CGAffineTransform)aTransform horizontalFlip:(BOOL)aFlip selectionAffineTransform:(CGAffineTransform)aTransform2 horizontalFlip:(BOOL)aFlip2
{
    [_delegate tool:self willUpdateOutputForKey:@"selectionAffineTransform"];
    [_delegate tool:self willUpdateOutputForKey:@"selectionFlippedHorizontally"];
    if (_selectionPath != NULL)
        [self BTModifySelectionTool_setNeedsDisplaySelection];
    id manager = [_delegate undoManagerForTool:self category:BTSelectionUndoCategory];
    if (manager != nil)
        [[self prepareUndoInManager:manager category:BTSelectionUndoCategory withInvocationTarget:self]
            BTModifySelectionTool_setBaseSelectionAffineTransform:_baseSelectionAffineTransform horizontalFlip:_isBaseSelectionFlippedHorizontally
            selectionAffineTransform:_selectionAffineTransform horizontalFlip:_isSelectionFlippedHorizontally];
    _baseSelectionAffineTransform = aTransform;
    _selectionAffineTransform = aTransform2;
    _isSelectionFlippedHorizontally = aFlip2;
    _isBaseSelectionFlippedHorizontally = aFlip;
    [_delegate tool:self didUpdateOutputForKey:@"selectionFlippedHorizontally"];
    [_delegate tool:self didUpdateOutputForKey:@"selectionAffineTransform"];
    if (_selectionPath != NULL)
        [self BTModifySelectionTool_setNeedsDisplaySelection];
    [_delegate tool:self didUpdateCursorWithEvent:nil];
}

- (void)BTModifySelectionTool_setBaseSelectionFlippedHorizontally:(BOOL)aHorizontally selectionFlippedHorizontally:(BOOL)aHorizontally2
{
    [_delegate tool:self willUpdateOutputForKey:@"selectionFlippedHorizontally"];
    id manager = [_delegate undoManagerForTool:self category:BTSelectionUndoCategory];
    if (manager != nil)
        [[self prepareUndoInManager:manager category:BTSelectionUndoCategory withInvocationTarget:self]
            BTModifySelectionTool_setBaseSelectionFlippedHorizontally:_isBaseSelectionFlippedHorizontally selectionFlippedHorizontally:_isSelectionFlippedHorizontally];
    _isSelectionFlippedHorizontally = aHorizontally2;
    _isBaseSelectionFlippedHorizontally = aHorizontally;
    [_delegate tool:self didUpdateOutputForKey:@"selectionFlippedHorizontally"];
    [_delegate tool:self didUpdateCursorWithEvent:nil];
}

- (void)BTModifySelectionTool_setBaseSelectionAffineTransform:(CGAffineTransform)aTransform selectionAffineTransform:(CGAffineTransform)aTransform2
{
    if (_selectionPath != NULL)
        [self BTModifySelectionTool_setNeedsDisplaySelection];
    [_delegate tool:self willUpdateOutputForKey:@"selectionAffineTransform"];
    id manager = [_delegate undoManagerForTool:self category:BTSelectionUndoCategory];
    if (manager != nil)
        [[self prepareUndoInManager:manager category:BTSelectionUndoCategory withInvocationTarget:self]
            BTModifySelectionTool_setBaseSelectionAffineTransform:_baseSelectionAffineTransform selectionAffineTransform:_selectionAffineTransform];
    _baseSelectionAffineTransform = aTransform;
    _selectionAffineTransform = aTransform2;
    [_delegate tool:self didUpdateOutputForKey:@"selectionAffineTransform"];
    if (_selectionPath != NULL)
        [self BTModifySelectionTool_setNeedsDisplaySelection];
    [_delegate tool:self didUpdateCursorWithEvent:nil];
}

/* aPath is a CGPath; an empty one clears the selection. */
- (void)setSelectionPath:(id)aPath
{
    if ((CGPathRef)aPath == _selectionPath)
        return;
    BOOL active = [self isActive];
    CGPathRef old = _selectionPath;
    if (old != NULL && active)
        [self BTModifySelectionTool_setNeedsDisplaySelection];
    CGPathRelease(_selectionPath);
    _selectionPath = NULL;
    _areSelectionPathBoundsCalculated = 0;
    if (aPath != nil && !CGPathIsEmpty((CGPathRef)aPath))
        _selectionPath = (struct CGPath *)CGPathCreateCopy((CGPathRef)aPath);
    if (!active)
        return;
    if (_selectionPath == NULL) {
        if (old != NULL)
            [self BTModifySelectionTool_stopSelectionFeedbackLineDashPhaseTimer];
        if (_isTracking) {
            [_view BT_abortMouseTracking];
            _isTracking = 0;
        }
    } else {
        [self BTModifySelectionTool_setNeedsDisplaySelection];
        if (old == NULL)
            [self BTModifySelectionTool_startSelectionFeedbackLineDashPhaseTimer];
    }
}

- (id)selectionPath
{
    return (id)_selectionPath;
}

- (void)setProportionalModePrimaryForSides:(BOOL)aSides
{
    _isProportionalModePrimaryForSides = aSides;
}

- (BOOL)isProportionalModePrimaryForSides
{
    return _isProportionalModePrimaryForSides;
}

- (BOOL)defaultProportionalModePrimaryForSides
{
    return NO;
}

- (void)setProportionalModePrimaryForCorners:(BOOL)aCorners
{
    _isProportionalModePrimaryForCorners = aCorners;
}

- (BOOL)isProportionalModePrimaryForCorners
{
    return _isProportionalModePrimaryForCorners;
}

- (BOOL)defaultProportionalModePrimaryForCorners
{
    return NO;
}

/* "do" cursors show while dragging; the one in use is set again when replaced. */
static void BTModifySelectionToolReplaceDoCursor(BTModifySelectionTool *self, NSCursor **aSlot, id aCursor, NSString *aKey)
{
    if (*aSlot == aCursor)
        return;
    [aCursor retain];
    [*aSlot release];
    *aSlot = aCursor;
    if (self->_isTracking && [self->_trackingCursorName isEqualToString:aKey])
        [(*aSlot != nil ? *aSlot : [NSCursor arrowCursor]) set];
}

static void BTModifySelectionToolReplaceWillCursor(NSCursor **aSlot, id aCursor)
{
    if (*aSlot == aCursor)
        return;
    [*aSlot release];
    *aSlot = [aCursor retain];
}

- (void)setDoRotateBottomCenterSelectionCursor:(id)aCursor
{
    BTModifySelectionToolReplaceDoCursor(self, &_doRotateBottomCenterSelectionCursor, aCursor, @"doRotateBottomCenterSelectionCursor");
    _isDoRotateBottomCenterSelectionCursorInitialized = 1;
}

- (id)doRotateBottomCenterSelectionCursor
{
    if (!_isDoRotateBottomCenterSelectionCursorInitialized) {
        _doRotateBottomCenterSelectionCursor = [[self defaultDoRotateBottomCenterSelectionCursor] retain];
        _isDoRotateBottomCenterSelectionCursorInitialized = 1;
    }
    return _doRotateBottomCenterSelectionCursor;
}

- (id)defaultDoRotateBottomCenterSelectionCursor
{
    return [NSCursor pointingHandCursor];
}

- (void)setWillRotateBottomCenterSelectionCursor:(id)aCursor
{
    BTModifySelectionToolReplaceWillCursor(&_willRotateBottomCenterSelectionCursor, aCursor);
    _isWillRotateBottomCenterSelectionCursorInitialized = 1;
}

- (id)willRotateBottomCenterSelectionCursor
{
    if (!_isWillRotateBottomCenterSelectionCursorInitialized) {
        _willRotateBottomCenterSelectionCursor = [[self defaultWillRotateBottomCenterSelectionCursor] retain];
        _isWillRotateBottomCenterSelectionCursorInitialized = 1;
    }
    return _willRotateBottomCenterSelectionCursor;
}

- (id)defaultWillRotateBottomCenterSelectionCursor
{
    return [NSCursor pointingHandCursor];
}

- (void)setDoRotateBottomRightSelectionCursor:(id)aCursor
{
    BTModifySelectionToolReplaceDoCursor(self, &_doRotateBottomRightSelectionCursor, aCursor, @"doRotateBottomRightSelectionCursor");
    _isDoRotateBottomRightSelectionCursorInitialized = 1;
}

- (id)doRotateBottomRightSelectionCursor
{
    if (!_isDoRotateBottomRightSelectionCursorInitialized) {
        _doRotateBottomRightSelectionCursor = [[self defaultDoRotateBottomRightSelectionCursor] retain];
        _isDoRotateBottomRightSelectionCursorInitialized = 1;
    }
    return _doRotateBottomRightSelectionCursor;
}

- (id)defaultDoRotateBottomRightSelectionCursor
{
    return [NSCursor pointingHandCursor];
}

- (void)setWillRotateBottomRightSelectionCursor:(id)aCursor
{
    BTModifySelectionToolReplaceWillCursor(&_willRotateBottomRightSelectionCursor, aCursor);
    _isWillRotateBottomRightSelectionCursorInitialized = 1;
}

- (id)willRotateBottomRightSelectionCursor
{
    if (!_isWillRotateBottomRightSelectionCursorInitialized) {
        _willRotateBottomRightSelectionCursor = [[self defaultWillRotateBottomRightSelectionCursor] retain];
        _isWillRotateBottomRightSelectionCursorInitialized = 1;
    }
    return _willRotateBottomRightSelectionCursor;
}

- (id)defaultWillRotateBottomRightSelectionCursor
{
    return [NSCursor pointingHandCursor];
}

- (void)setDoRotateCenterRightSelectionCursor:(id)aCursor
{
    BTModifySelectionToolReplaceDoCursor(self, &_doRotateCenterRightSelectionCursor, aCursor, @"doRotateCenterRightSelectionCursor");
    _isDoRotateCenterRightSelectionCursorInitialized = 1;
}

- (id)doRotateCenterRightSelectionCursor
{
    if (!_isDoRotateCenterRightSelectionCursorInitialized) {
        _doRotateCenterRightSelectionCursor = [[self defaultDoRotateCenterRightSelectionCursor] retain];
        _isDoRotateCenterRightSelectionCursorInitialized = 1;
    }
    return _doRotateCenterRightSelectionCursor;
}

- (id)defaultDoRotateCenterRightSelectionCursor
{
    return [NSCursor pointingHandCursor];
}

- (void)setWillRotateCenterRightSelectionCursor:(id)aCursor
{
    BTModifySelectionToolReplaceWillCursor(&_willRotateCenterRightSelectionCursor, aCursor);
    _isWillRotateCenterRightSelectionCursorInitialized = 1;
}

- (id)willRotateCenterRightSelectionCursor
{
    if (!_isWillRotateCenterRightSelectionCursorInitialized) {
        _willRotateCenterRightSelectionCursor = [[self defaultWillRotateCenterRightSelectionCursor] retain];
        _isWillRotateCenterRightSelectionCursorInitialized = 1;
    }
    return _willRotateCenterRightSelectionCursor;
}

- (id)defaultWillRotateCenterRightSelectionCursor
{
    return [NSCursor pointingHandCursor];
}

- (void)setDoRotateTopRightSelectionCursor:(id)aCursor
{
    BTModifySelectionToolReplaceDoCursor(self, &_doRotateTopRightSelectionCursor, aCursor, @"doRotateTopRightSelectionCursor");
    _isDoRotateTopRightSelectionCursorInitialized = 1;
}

- (id)doRotateTopRightSelectionCursor
{
    if (!_isDoRotateTopRightSelectionCursorInitialized) {
        _doRotateTopRightSelectionCursor = [[self defaultDoRotateTopRightSelectionCursor] retain];
        _isDoRotateTopRightSelectionCursorInitialized = 1;
    }
    return _doRotateTopRightSelectionCursor;
}

- (id)defaultDoRotateTopRightSelectionCursor
{
    return [NSCursor pointingHandCursor];
}

- (void)setWillRotateTopRightSelectionCursor:(id)aCursor
{
    BTModifySelectionToolReplaceWillCursor(&_willRotateTopRightSelectionCursor, aCursor);
    _isWillRotateTopRightSelectionCursorInitialized = 1;
}

- (id)willRotateTopRightSelectionCursor
{
    if (!_isWillRotateTopRightSelectionCursorInitialized) {
        _willRotateTopRightSelectionCursor = [[self defaultWillRotateTopRightSelectionCursor] retain];
        _isWillRotateTopRightSelectionCursorInitialized = 1;
    }
    return _willRotateTopRightSelectionCursor;
}

- (id)defaultWillRotateTopRightSelectionCursor
{
    return [NSCursor pointingHandCursor];
}

- (void)setDoRotateTopCenterSelectionCursor:(id)aCursor
{
    BTModifySelectionToolReplaceDoCursor(self, &_doRotateTopCenterSelectionCursor, aCursor, @"doRotateTopCenterSelectionCursor");
    _isDoRotateTopCenterSelectionCursorInitialized = 1;
}

- (id)doRotateTopCenterSelectionCursor
{
    if (!_isDoRotateTopCenterSelectionCursorInitialized) {
        _doRotateTopCenterSelectionCursor = [[self defaultDoRotateTopCenterSelectionCursor] retain];
        _isDoRotateTopCenterSelectionCursorInitialized = 1;
    }
    return _doRotateTopCenterSelectionCursor;
}

- (id)defaultDoRotateTopCenterSelectionCursor
{
    return [NSCursor pointingHandCursor];
}

- (void)setWillRotateTopCenterSelectionCursor:(id)aCursor
{
    BTModifySelectionToolReplaceWillCursor(&_willRotateTopCenterSelectionCursor, aCursor);
    _isWillRotateTopCenterSelectionCursorInitialized = 1;
}

- (id)willRotateTopCenterSelectionCursor
{
    if (!_isWillRotateTopCenterSelectionCursorInitialized) {
        _willRotateTopCenterSelectionCursor = [[self defaultWillRotateTopCenterSelectionCursor] retain];
        _isWillRotateTopCenterSelectionCursorInitialized = 1;
    }
    return _willRotateTopCenterSelectionCursor;
}

- (id)defaultWillRotateTopCenterSelectionCursor
{
    return [NSCursor pointingHandCursor];
}

- (void)setDoRotateTopLeftSelectionCursor:(id)aCursor
{
    BTModifySelectionToolReplaceDoCursor(self, &_doRotateTopLeftSelectionCursor, aCursor, @"doRotateTopLeftSelectionCursor");
    _isDoRotateTopLeftSelectionCursorInitialized = 1;
}

- (id)doRotateTopLeftSelectionCursor
{
    if (!_isDoRotateTopLeftSelectionCursorInitialized) {
        _doRotateTopLeftSelectionCursor = [[self defaultDoRotateTopLeftSelectionCursor] retain];
        _isDoRotateTopLeftSelectionCursorInitialized = 1;
    }
    return _doRotateTopLeftSelectionCursor;
}

- (id)defaultDoRotateTopLeftSelectionCursor
{
    return [NSCursor pointingHandCursor];
}

- (void)setWillRotateTopLeftSelectionCursor:(id)aCursor
{
    BTModifySelectionToolReplaceWillCursor(&_willRotateTopLeftSelectionCursor, aCursor);
    _isWillRotateTopLeftSelectionCursorInitialized = 1;
}

- (id)willRotateTopLeftSelectionCursor
{
    if (!_isWillRotateTopLeftSelectionCursorInitialized) {
        _willRotateTopLeftSelectionCursor = [[self defaultWillRotateTopLeftSelectionCursor] retain];
        _isWillRotateTopLeftSelectionCursorInitialized = 1;
    }
    return _willRotateTopLeftSelectionCursor;
}

- (id)defaultWillRotateTopLeftSelectionCursor
{
    return [NSCursor pointingHandCursor];
}

- (void)setDoRotateCenterLeftSelectionCursor:(id)aCursor
{
    BTModifySelectionToolReplaceDoCursor(self, &_doRotateCenterLeftSelectionCursor, aCursor, @"doRotateCenterLeftSelectionCursor");
    _isDoRotateCenterLeftSelectionCursorInitialized = 1;
}

- (id)doRotateCenterLeftSelectionCursor
{
    if (!_isDoRotateCenterLeftSelectionCursorInitialized) {
        _doRotateCenterLeftSelectionCursor = [[self defaultDoRotateCenterLeftSelectionCursor] retain];
        _isDoRotateCenterLeftSelectionCursorInitialized = 1;
    }
    return _doRotateCenterLeftSelectionCursor;
}

- (id)defaultDoRotateCenterLeftSelectionCursor
{
    return [NSCursor pointingHandCursor];
}

- (void)setWillRotateCenterLeftSelectionCursor:(id)aCursor
{
    BTModifySelectionToolReplaceWillCursor(&_willRotateCenterLeftSelectionCursor, aCursor);
    _isWillRotateCenterLeftSelectionCursorInitialized = 1;
}

- (id)willRotateCenterLeftSelectionCursor
{
    if (!_isWillRotateCenterLeftSelectionCursorInitialized) {
        _willRotateCenterLeftSelectionCursor = [[self defaultWillRotateCenterLeftSelectionCursor] retain];
        _isWillRotateCenterLeftSelectionCursorInitialized = 1;
    }
    return _willRotateCenterLeftSelectionCursor;
}

- (id)defaultWillRotateCenterLeftSelectionCursor
{
    return [NSCursor pointingHandCursor];
}

- (void)setDoRotateBottomLeftSelectionCursor:(id)aCursor
{
    BTModifySelectionToolReplaceDoCursor(self, &_doRotateBottomLeftSelectionCursor, aCursor, @"doRotateBottomLeftSelectionCursor");
    _isDoRotateBottomLeftSelectionCursorInitialized = 1;
}

- (id)doRotateBottomLeftSelectionCursor
{
    if (!_isDoRotateBottomLeftSelectionCursorInitialized) {
        _doRotateBottomLeftSelectionCursor = [[self defaultDoRotateBottomLeftSelectionCursor] retain];
        _isDoRotateBottomLeftSelectionCursorInitialized = 1;
    }
    return _doRotateBottomLeftSelectionCursor;
}

- (id)defaultDoRotateBottomLeftSelectionCursor
{
    return [NSCursor pointingHandCursor];
}

- (void)setWillRotateBottomLeftSelectionCursor:(id)aCursor
{
    BTModifySelectionToolReplaceWillCursor(&_willRotateBottomLeftSelectionCursor, aCursor);
    _isWillRotateBottomLeftSelectionCursorInitialized = 1;
}

- (id)willRotateBottomLeftSelectionCursor
{
    if (!_isWillRotateBottomLeftSelectionCursorInitialized) {
        _willRotateBottomLeftSelectionCursor = [[self defaultWillRotateBottomLeftSelectionCursor] retain];
        _isWillRotateBottomLeftSelectionCursorInitialized = 1;
    }
    return _willRotateBottomLeftSelectionCursor;
}

- (id)defaultWillRotateBottomLeftSelectionCursor
{
    return [NSCursor pointingHandCursor];
}

- (void)setDoResizeBottomCenterSelectionCursor:(id)aCursor
{
    BTModifySelectionToolReplaceDoCursor(self, &_doResizeBottomCenterSelectionCursor, aCursor, @"doResizeBottomCenterSelectionCursor");
    _isDoResizeBottomCenterSelectionCursorInitialized = 1;
}

- (id)doResizeBottomCenterSelectionCursor
{
    if (!_isDoResizeBottomCenterSelectionCursorInitialized) {
        _doResizeBottomCenterSelectionCursor = [[self defaultDoResizeBottomCenterSelectionCursor] retain];
        _isDoResizeBottomCenterSelectionCursorInitialized = 1;
    }
    return _doResizeBottomCenterSelectionCursor;
}

- (id)defaultDoResizeBottomCenterSelectionCursor
{
    return [NSCursor crosshairCursor];
}

- (void)setWillResizeBottomCenterSelectionCursor:(id)aCursor
{
    BTModifySelectionToolReplaceWillCursor(&_willResizeBottomCenterSelectionCursor, aCursor);
    _isWillResizeBottomCenterSelectionCursorInitialized = 1;
}

- (id)willResizeBottomCenterSelectionCursor
{
    if (!_isWillResizeBottomCenterSelectionCursorInitialized) {
        _willResizeBottomCenterSelectionCursor = [[self defaultWillResizeBottomCenterSelectionCursor] retain];
        _isWillResizeBottomCenterSelectionCursorInitialized = 1;
    }
    return _willResizeBottomCenterSelectionCursor;
}

- (id)defaultWillResizeBottomCenterSelectionCursor
{
    return [NSCursor crosshairCursor];
}

- (void)setDoResizeBottomRightSelectionCursor:(id)aCursor
{
    BTModifySelectionToolReplaceDoCursor(self, &_doResizeBottomRightSelectionCursor, aCursor, @"doResizeBottomRightSelectionCursor");
    _isDoResizeBottomRightSelectionCursorInitialized = 1;
}

- (id)doResizeBottomRightSelectionCursor
{
    if (!_isDoResizeBottomRightSelectionCursorInitialized) {
        _doResizeBottomRightSelectionCursor = [[self defaultDoResizeBottomRightSelectionCursor] retain];
        _isDoResizeBottomRightSelectionCursorInitialized = 1;
    }
    return _doResizeBottomRightSelectionCursor;
}

- (id)defaultDoResizeBottomRightSelectionCursor
{
    return [NSCursor crosshairCursor];
}

- (void)setWillResizeBottomRightSelectionCursor:(id)aCursor
{
    BTModifySelectionToolReplaceWillCursor(&_willResizeBottomRightSelectionCursor, aCursor);
    _isWillResizeBottomRightSelectionCursorInitialized = 1;
}

- (id)willResizeBottomRightSelectionCursor
{
    if (!_isWillResizeBottomRightSelectionCursorInitialized) {
        _willResizeBottomRightSelectionCursor = [[self defaultWillResizeBottomRightSelectionCursor] retain];
        _isWillResizeBottomRightSelectionCursorInitialized = 1;
    }
    return _willResizeBottomRightSelectionCursor;
}

- (id)defaultWillResizeBottomRightSelectionCursor
{
    return [NSCursor crosshairCursor];
}

- (void)setDoResizeCenterRightSelectionCursor:(id)aCursor
{
    BTModifySelectionToolReplaceDoCursor(self, &_doResizeCenterRightSelectionCursor, aCursor, @"doResizeCenterRightSelectionCursor");
    _isDoResizeCenterRightSelectionCursorInitialized = 1;
}

- (id)doResizeCenterRightSelectionCursor
{
    if (!_isDoResizeCenterRightSelectionCursorInitialized) {
        _doResizeCenterRightSelectionCursor = [[self defaultDoResizeCenterRightSelectionCursor] retain];
        _isDoResizeCenterRightSelectionCursorInitialized = 1;
    }
    return _doResizeCenterRightSelectionCursor;
}

- (id)defaultDoResizeCenterRightSelectionCursor
{
    return [NSCursor crosshairCursor];
}

- (void)setWillResizeCenterRightSelectionCursor:(id)aCursor
{
    BTModifySelectionToolReplaceWillCursor(&_willResizeCenterRightSelectionCursor, aCursor);
    _isWillResizeCenterRightSelectionCursorInitialized = 1;
}

- (id)willResizeCenterRightSelectionCursor
{
    if (!_isWillResizeCenterRightSelectionCursorInitialized) {
        _willResizeCenterRightSelectionCursor = [[self defaultWillResizeCenterRightSelectionCursor] retain];
        _isWillResizeCenterRightSelectionCursorInitialized = 1;
    }
    return _willResizeCenterRightSelectionCursor;
}

- (id)defaultWillResizeCenterRightSelectionCursor
{
    return [NSCursor crosshairCursor];
}

- (void)setDoResizeTopRightSelectionCursor:(id)aCursor
{
    BTModifySelectionToolReplaceDoCursor(self, &_doResizeTopRightSelectionCursor, aCursor, @"doResizeTopRightSelectionCursor");
    _isDoResizeTopRightSelectionCursorInitialized = 1;
}

- (id)doResizeTopRightSelectionCursor
{
    if (!_isDoResizeTopRightSelectionCursorInitialized) {
        _doResizeTopRightSelectionCursor = [[self defaultDoResizeTopRightSelectionCursor] retain];
        _isDoResizeTopRightSelectionCursorInitialized = 1;
    }
    return _doResizeTopRightSelectionCursor;
}

- (id)defaultDoResizeTopRightSelectionCursor
{
    return [NSCursor crosshairCursor];
}

- (void)setWillResizeTopRightSelectionCursor:(id)aCursor
{
    BTModifySelectionToolReplaceWillCursor(&_willResizeTopRightSelectionCursor, aCursor);
    _isWillResizeTopRightSelectionCursorInitialized = 1;
}

- (id)willResizeTopRightSelectionCursor
{
    if (!_isWillResizeTopRightSelectionCursorInitialized) {
        _willResizeTopRightSelectionCursor = [[self defaultWillResizeTopRightSelectionCursor] retain];
        _isWillResizeTopRightSelectionCursorInitialized = 1;
    }
    return _willResizeTopRightSelectionCursor;
}

- (id)defaultWillResizeTopRightSelectionCursor
{
    return [NSCursor crosshairCursor];
}

- (void)setDoResizeTopCenterSelectionCursor:(id)aCursor
{
    BTModifySelectionToolReplaceDoCursor(self, &_doResizeTopCenterSelectionCursor, aCursor, @"doResizeTopCenterSelectionCursor");
    _isDoResizeTopCenterSelectionCursorInitialized = 1;
}

- (id)doResizeTopCenterSelectionCursor
{
    if (!_isDoResizeTopCenterSelectionCursorInitialized) {
        _doResizeTopCenterSelectionCursor = [[self defaultDoResizeTopCenterSelectionCursor] retain];
        _isDoResizeTopCenterSelectionCursorInitialized = 1;
    }
    return _doResizeTopCenterSelectionCursor;
}

- (id)defaultDoResizeTopCenterSelectionCursor
{
    return [NSCursor crosshairCursor];
}

- (void)setWillResizeTopCenterSelectionCursor:(id)aCursor
{
    BTModifySelectionToolReplaceWillCursor(&_willResizeTopCenterSelectionCursor, aCursor);
    _isWillResizeTopCenterSelectionCursorInitialized = 1;
}

- (id)willResizeTopCenterSelectionCursor
{
    if (!_isWillResizeTopCenterSelectionCursorInitialized) {
        _willResizeTopCenterSelectionCursor = [[self defaultWillResizeTopCenterSelectionCursor] retain];
        _isWillResizeTopCenterSelectionCursorInitialized = 1;
    }
    return _willResizeTopCenterSelectionCursor;
}

- (id)defaultWillResizeTopCenterSelectionCursor
{
    return [NSCursor crosshairCursor];
}

- (void)setDoResizeTopLeftSelectionCursor:(id)aCursor
{
    BTModifySelectionToolReplaceDoCursor(self, &_doResizeTopLeftSelectionCursor, aCursor, @"doResizeTopLeftSelectionCursor");
    _isDoResizeTopLeftSelectionCursorInitialized = 1;
}

- (id)doResizeTopLeftSelectionCursor
{
    if (!_isDoResizeTopLeftSelectionCursorInitialized) {
        _doResizeTopLeftSelectionCursor = [[self defaultDoResizeTopLeftSelectionCursor] retain];
        _isDoResizeTopLeftSelectionCursorInitialized = 1;
    }
    return _doResizeTopLeftSelectionCursor;
}

- (id)defaultDoResizeTopLeftSelectionCursor
{
    return [NSCursor crosshairCursor];
}

- (void)setWillResizeTopLeftSelectionCursor:(id)aCursor
{
    BTModifySelectionToolReplaceWillCursor(&_willResizeTopLeftSelectionCursor, aCursor);
    _isWillResizeTopLeftSelectionCursorInitialized = 1;
}

- (id)willResizeTopLeftSelectionCursor
{
    if (!_isWillResizeTopLeftSelectionCursorInitialized) {
        _willResizeTopLeftSelectionCursor = [[self defaultWillResizeTopLeftSelectionCursor] retain];
        _isWillResizeTopLeftSelectionCursorInitialized = 1;
    }
    return _willResizeTopLeftSelectionCursor;
}

- (id)defaultWillResizeTopLeftSelectionCursor
{
    return [NSCursor crosshairCursor];
}

- (void)setDoResizeCenterLeftSelectionCursor:(id)aCursor
{
    BTModifySelectionToolReplaceDoCursor(self, &_doResizeCenterLeftSelectionCursor, aCursor, @"doResizeCenterLeftSelectionCursor");
    _isDoResizeCenterLeftSelectionCursorInitialized = 1;
}

- (id)doResizeCenterLeftSelectionCursor
{
    if (!_isDoResizeCenterLeftSelectionCursorInitialized) {
        _doResizeCenterLeftSelectionCursor = [[self defaultDoResizeCenterLeftSelectionCursor] retain];
        _isDoResizeCenterLeftSelectionCursorInitialized = 1;
    }
    return _doResizeCenterLeftSelectionCursor;
}

- (id)defaultDoResizeCenterLeftSelectionCursor
{
    return [NSCursor crosshairCursor];
}

- (void)setWillResizeCenterLeftSelectionCursor:(id)aCursor
{
    BTModifySelectionToolReplaceWillCursor(&_willResizeCenterLeftSelectionCursor, aCursor);
    _isWillResizeCenterLeftSelectionCursorInitialized = 1;
}

- (id)willResizeCenterLeftSelectionCursor
{
    if (!_isWillResizeCenterLeftSelectionCursorInitialized) {
        _willResizeCenterLeftSelectionCursor = [[self defaultWillResizeCenterLeftSelectionCursor] retain];
        _isWillResizeCenterLeftSelectionCursorInitialized = 1;
    }
    return _willResizeCenterLeftSelectionCursor;
}

- (id)defaultWillResizeCenterLeftSelectionCursor
{
    return [NSCursor crosshairCursor];
}

- (void)setDoResizeBottomLeftSelectionCursor:(id)aCursor
{
    BTModifySelectionToolReplaceDoCursor(self, &_doResizeBottomLeftSelectionCursor, aCursor, @"doResizeBottomLeftSelectionCursor");
    _isDoResizeBottomLeftSelectionCursorInitialized = 1;
}

- (id)doResizeBottomLeftSelectionCursor
{
    if (!_isDoResizeBottomLeftSelectionCursorInitialized) {
        _doResizeBottomLeftSelectionCursor = [[self defaultDoResizeBottomLeftSelectionCursor] retain];
        _isDoResizeBottomLeftSelectionCursorInitialized = 1;
    }
    return _doResizeBottomLeftSelectionCursor;
}

- (id)defaultDoResizeBottomLeftSelectionCursor
{
    return [NSCursor crosshairCursor];
}

- (void)setWillResizeBottomLeftSelectionCursor:(id)aCursor
{
    BTModifySelectionToolReplaceWillCursor(&_willResizeBottomLeftSelectionCursor, aCursor);
    _isWillResizeBottomLeftSelectionCursorInitialized = 1;
}

- (id)willResizeBottomLeftSelectionCursor
{
    if (!_isWillResizeBottomLeftSelectionCursorInitialized) {
        _willResizeBottomLeftSelectionCursor = [[self defaultWillResizeBottomLeftSelectionCursor] retain];
        _isWillResizeBottomLeftSelectionCursorInitialized = 1;
    }
    return _willResizeBottomLeftSelectionCursor;
}

- (id)defaultWillResizeBottomLeftSelectionCursor
{
    return [NSCursor crosshairCursor];
}

- (void)setDoMoveSelectionCursor:(id)aCursor
{
    BTModifySelectionToolReplaceDoCursor(self, &_doMoveSelectionCursor, aCursor, @"doMoveSelectionCursor");
    _isDoMoveSelectionCursorInitialized = 1;
}

- (id)doMoveSelectionCursor
{
    if (!_isDoMoveSelectionCursorInitialized) {
        _doMoveSelectionCursor = [[self defaultDoMoveSelectionCursor] retain];
        _isDoMoveSelectionCursorInitialized = 1;
    }
    return _doMoveSelectionCursor;
}

- (id)defaultDoMoveSelectionCursor
{
    return [NSCursor closedHandCursor];
}

- (void)setWillMoveSelectionCursor:(id)aCursor
{
    BTModifySelectionToolReplaceWillCursor(&_willMoveSelectionCursor, aCursor);
    _isWillMoveSelectionCursorInitialized = 1;
}

- (id)willMoveSelectionCursor
{
    if (!_isWillMoveSelectionCursorInitialized) {
        _willMoveSelectionCursor = [[self defaultWillMoveSelectionCursor] retain];
        _isWillMoveSelectionCursorInitialized = 1;
    }
    return _willMoveSelectionCursor;
}

- (id)defaultWillMoveSelectionCursor
{
    return [NSCursor openHandCursor];
}

- (void)dealloc
{
    [_selectionFeedbackLineDashPhaseTimer invalidate];
    [_selectionFeedbackLineDashPhaseTimer release];
    [_trackingCursorName release];
    [_willMoveSelectionCursor release];
    [_doMoveSelectionCursor release];
    [_willResizeBottomLeftSelectionCursor release];
    [_doResizeBottomLeftSelectionCursor release];
    [_willResizeCenterLeftSelectionCursor release];
    [_doResizeCenterLeftSelectionCursor release];
    [_willResizeTopLeftSelectionCursor release];
    [_doResizeTopLeftSelectionCursor release];
    [_willResizeTopCenterSelectionCursor release];
    [_doResizeTopCenterSelectionCursor release];
    [_willResizeTopRightSelectionCursor release];
    [_doResizeTopRightSelectionCursor release];
    [_willResizeCenterRightSelectionCursor release];
    [_doResizeCenterRightSelectionCursor release];
    [_willResizeBottomRightSelectionCursor release];
    [_doResizeBottomRightSelectionCursor release];
    [_willResizeBottomCenterSelectionCursor release];
    [_doResizeBottomCenterSelectionCursor release];
    [_willRotateBottomLeftSelectionCursor release];
    [_doRotateBottomLeftSelectionCursor release];
    [_willRotateCenterLeftSelectionCursor release];
    [_doRotateCenterLeftSelectionCursor release];
    [_willRotateTopLeftSelectionCursor release];
    [_doRotateTopLeftSelectionCursor release];
    [_willRotateTopCenterSelectionCursor release];
    [_doRotateTopCenterSelectionCursor release];
    [_willRotateTopRightSelectionCursor release];
    [_doRotateTopRightSelectionCursor release];
    [_willRotateCenterRightSelectionCursor release];
    [_doRotateCenterRightSelectionCursor release];
    [_willRotateBottomRightSelectionCursor release];
    [_doRotateBottomRightSelectionCursor release];
    [_willRotateBottomCenterSelectionCursor release];
    [_doRotateBottomCenterSelectionCursor release];
    CGPathRelease(_selectionPath);
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self == nil)
        return nil;
    _baseSelectionAffineTransform = CGAffineTransformIdentity;
    _selectionAffineTransform = CGAffineTransformIdentity;
    return self;
}

- (void)BTModifySelectionTool_stopSelectionFeedbackLineDashPhaseTimer
{
    [_selectionFeedbackLineDashPhaseTimer invalidate];
    [_selectionFeedbackLineDashPhaseTimer release];
    _selectionFeedbackLineDashPhaseTimer = nil;
}

/* The marching ants advance every tenth of a second, also during tracking and modal panels. */
- (void)BTModifySelectionTool_startSelectionFeedbackLineDashPhaseTimer
{
    _selectionFeedbackLineDashPhaseTimer = [[NSTimer alloc] initWithFireDate:[NSDate dateWithTimeIntervalSinceNow:0.1] interval:0.1 target:self
        selector:@selector(BTModifySelectionTool_selectionFeedbackLineDashPhaseTimerFireMethod:) userInfo:nil repeats:YES];
    if (_selectionFeedbackLineDashPhaseTimer == nil)
        return;
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    [runLoop addTimer:_selectionFeedbackLineDashPhaseTimer forMode:NSDefaultRunLoopMode];
    [runLoop addTimer:_selectionFeedbackLineDashPhaseTimer forMode:NSEventTrackingRunLoopMode];
    [runLoop addTimer:_selectionFeedbackLineDashPhaseTimer forMode:NSModalPanelRunLoopMode];
}

- (void)BTModifySelectionTool_selectionFeedbackLineDashPhaseTimerFireMethod:(id)aTimer
{
    _selectionFeedbackLineDashPhase = _selectionFeedbackLineDashPhase + 1.0;
    [self BTModifySelectionTool_setNeedsDisplaySelectionPath];
}

/* Device pixel aligned rect for a knob at aPoint (view space). */
static CGRect BTModifySelectionToolKnobRect(CGPoint aPoint)
{
    return CGRectIntegral(CGRectInset(CGRectMake(aPoint.x + -3.5, aPoint.y + -3.5, 7.0, 7.0), -0.05, -0.05));
}

/* The path, the eight knobs and the rotate handle, with knobs aligned as drawn. */
- (void)BTModifySelectionTool_setNeedsDisplaySelection
{
    if (![self isViewInvalidationEnabled])
        return;
    CGAffineTransform selectionToView = CGAffineTransformConcat(_selectionAffineTransform, [self imageToViewTransform]);
    [self BTModifySelectionTool_setNeedsDisplaySelectionPathWithSelectionToViewTransform:selectionToView];
    BTModifySelectionToolCalculateBounds(self);
    NSSize deviceScale = [_view convertSize:NSMakeSize(1.0, 1.0) fromView:nil];
    CGRect b = _selectionPathBounds;
    CGFloat knobX = fmod(round(deviceScale.width * 7.0) * 0.5, 1.0);
    CGFloat knobY = fmod(round(deviceScale.height * 7.0) * 0.5, 1.0);
    CGFloat x = b.origin.x, y = b.origin.y;
    CGFloat midY = b.size.height * 0.5 + y;
    CGFloat maxY = b.size.height + y;
    CGFloat midX = b.size.width * 0.5 + x;
    CGFloat maxX = b.size.width + x;
    CGPoint knobs[8] = {
        { x, y }, { x, midY }, { x, maxY }, { midX, maxY }, { maxX, maxY }, { maxX, midY }, { maxX, y }, { midX, y }
    };
    for (int k = 0; k < 8; k++) {
        NSPoint window = [_view convertPoint:CGPointApplyAffineTransform(knobs[k], selectionToView) toView:nil];
        NSPoint aligned = NSMakePoint(round(window.x + 0.0001 + knobX) - knobX, round(window.y + 0.0001 + knobY) - knobY);
        knobs[k] = [_view convertPoint:aligned fromView:nil];
        [_view setNeedsDisplayInRect:BTModifySelectionToolKnobRect(knobs[k])];
    }
    [self BTModifySelectionTool_setNeedsDisplayRotateSelectionHandleWithSelectionToViewTransform:selectionToView viewToDeviceScaleFactor:deviceScale knobAlignment:CGSizeMake(knobX, knobY)];
}

- (void)BTModifySelectionTool_setNeedsDisplaySelectionPath
{
    if ([self isViewInvalidationEnabled])
        [self BTModifySelectionTool_setNeedsDisplaySelectionPathWithSelectionToViewTransform:CGAffineTransformConcat(_selectionAffineTransform, [self imageToViewTransform])];
}

- (void)BTModifySelectionTool_setNeedsDisplaySelectionPathWithSelectionToViewTransform:(CGAffineTransform)aTransform
{
    CGMutablePathRef path = CGPathCreateMutable();
    if (path == NULL)
        return;
    CGPathAddPath(path, &aTransform, _selectionPath);
    [_view setNeedsDisplayInRect:CGRectIntegral(CGRectInset(CGEPathGetPathBoundingBox(path), -0.05, -0.05))];
    CGPathRelease(path);
}

/* The handle knob and the line from the bounds center to it. aFactor is unused. */
- (void)BTModifySelectionTool_setNeedsDisplayRotateSelectionHandleWithSelectionToViewTransform:(CGAffineTransform)aTransform viewToDeviceScaleFactor:(NSSize)aFactor knobAlignment:(CGSize)aAlignment
{
    BTModifySelectionToolCalculateBounds(self);
    CGRect b = _selectionPathBounds;
    CGFloat midX = b.size.width * 0.5 + b.origin.x;
    CGFloat midY = b.size.height * 0.5 + b.origin.y;
    NSPoint lineEnd, handle;
    if (_isTracking && _selectionOperation == 3) {
        handle = lineEnd = CGPointApplyAffineTransform(_lastImagePoint, [self imageToViewTransform]);
    } else {
        CGFloat unit = hypot(aTransform.a, aTransform.b);
        unit = unit != 0.0 ? 1.0 / unit : 1.0;
        CGFloat handleX = _isSelectionFlippedHorizontally ? b.origin.x + unit * -27.5 : b.origin.x + b.size.width + unit * 27.5;
        NSPoint view = CGPointApplyAffineTransform(CGPointMake(handleX, midY), aTransform);
        NSPoint window = [_view convertPoint:view toView:nil];
        lineEnd = [_view convertPoint:NSMakePoint(round(window.x + 0.5) + -0.5, round(window.y + 0.5) + -0.5) fromView:nil];
        window = [_view convertPoint:view toView:nil];
        handle = [_view convertPoint:NSMakePoint(round(window.x + aAlignment.width) - aAlignment.width, round(window.y + aAlignment.height) - aAlignment.height) fromView:nil];
    }
    NSPoint window = [_view convertPoint:CGPointApplyAffineTransform(CGPointMake(midX, midY), aTransform) toView:nil];
    NSPoint center = [_view convertPoint:NSMakePoint(round(window.x + 0.5) + -0.5, round(window.y + 0.5) + -0.5) fromView:nil];
    CGRect line = CGRectMake(MIN(center.x, lineEnd.x), MIN(center.y, lineEnd.y), MAX(center.x, lineEnd.x) - MIN(center.x, lineEnd.x), MAX(center.y, lineEnd.y) - MIN(center.y, lineEnd.y));
    [_view setNeedsDisplayInRect:CGRectIntegral(CGRectInset(line, -0.55, -0.55))];
    [_view setNeedsDisplayInRect:BTModifySelectionToolKnobRect(handle)];
}

@end
