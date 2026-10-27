#import "BTPointsContainer.h"

NSString * const BTCollectingDragPointsMode = @"BTDragToolTrackingMode";
NSString * const BTCollectingPickPointsMode = @"BTMoveToolTrackingMode";

// An immutable view of the first count items of a data array (the creation
// tool's points as they are tracked).
@implementation BTPointsContainer

+ (id)containerWithDataArray:(id)aArray count:(NSUInteger)aCount
{
    return [[[self alloc] initWithDataArray:aArray count:aCount] autorelease];
}

- (id)initWithDataArray:(id)aArray count:(NSUInteger)aCount
{
    self = [super init];
    if (!self)
        return nil;
    _pointsContainer = [aArray retain];
    _count = aCount;
    return self;
}

- (void)dealloc
{
    [_pointsContainer release];
    [super dealloc];
}

- (NSUInteger)count
{
    return _count;
}

- (NSUInteger)itemSize
{
    return [_pointsContainer itemSize];
}

- (void *)bytesOfItemAtIndex:(NSUInteger)aIndex
{
    return [_pointsContainer bytesOfItemAtIndex:aIndex];
}

- (id)copyWithZone:(NSZone *)aZone
{
    return [[[self class] allocWithZone:aZone] initWithDataArray:_pointsContainer count:_count];
}

- (id)mutableCopyWithZone:(NSZone *)aZone
{
    return nil;
}

@end

@implementation BTPointsCreationTool

/* Replaces the collected points with the two corners of the image, as if dragged across it. */
- (void)selectAllArea:(id)aSender
{
    if (_isPointCollectingStarted)
        return;
    id image = [self workImage];
    if (image == nil)
        return;
    CGSize size = [image imageSize];
    [_delegate tool:self willUpdateOutputForKey:@"pointsArray"];
    [_pointsDataContainer release];
    _pointsDataContainer = [[BTMutableDataArray alloc] initWithCount:2 itemSize:sizeof(NSPoint)];
    NSPoint *first = [_pointsDataContainer mutableBytesOfItemAtIndex:0];
    if (first != NULL)
        *first = NSMakePoint(0.5, size.height - 0.5);
    NSPoint *second = [_pointsDataContainer mutableBytesOfItemAtIndex:1];
    if (second != NULL)
        *second = NSMakePoint(size.width - 0.5, 0.5);
    [_delegate tool:self didUpdateOutputForKey:@"pointsArray"];
    [_delegate tool:self didFinalizeOutputForKey:@"pointsArray"];
    [_delegate tool:self didFinalizeStage:@"BTWaitingToolStage" withEvent:nil nextStage:nil];
    _isPointCollectingStarted = 0;
}

- (BOOL)validateAction_selectAllArea
{
    if (_isPointCollectingStarted)
        return NO;
    return [self workImage] != nil;
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

    if (_isStopCreationOnDoubleClick && [aEvent clickCount] == 2) {
        [self BTPointsCreationTool_didFinalizeWithEvent:aEvent];
        return;
    }

    if (!_isWaitingForClick) {
        NSUInteger count = [_pointsDataContainer count];
        if (!_isLastPointDynamic && count == _maxPointsCount - 1)
            [self BTPointsCreationTool_addTrackPointWithEvent:aEvent];
        if (_maxPointsCount == 0)
            return;
        if (count != 0 && count != _maxPointsCount)
            return;
        [self BTPointsCreationTool_didFinalizeWithEvent:aEvent];
        return;
    }

    if (_isLastPointDynamic && [_pointsDataContainer count] != 0)
        [self BTPointsCreationTool_trackMouse:aEvent];
    else
        [self BTPointsCreationTool_addTrackPointWithEvent:aEvent];
    if (_maxPointsCount != 0 && [_pointsDataContainer count] == _maxPointsCount) {
        [self BTPointsCreationTool_didFinalizeWithEvent:aEvent];
        return;
    }
    [_delegate tool:self didUpdateCursorWithEvent:aEvent];
    if (_isLastPointDynamic)
        [self BTPointsCreationTool_addTrackPointWithEvent:aEvent];
}

- (BOOL)scrollWheel:(id)aEvent
{
    return [self mouseMoved:aEvent];
}

- (void)trackFlagsChanged:(id)aEvent inView:(id)aView
{
    if (_view != aView)
        return;
    [[_delegate mouseTrackingDelegateForTool:self] trackFlagsChanged:aEvent inView:aView];
    unsigned char mode = [self BTPointsCreationTool_isInCorrectionModeForModifierFlags:[aEvent modifierFlags]];
    if (mode == _isInCorrectionMode)
        return;
    _isInCorrectionMode = mode;

    /* Re-place the last point from where the mouse really is, under the new correction. */
    NSPoint *last = [_pointsDataContainer bytesOfLastItem];
    if (last == NULL)
        return;
    [_delegate tool:self willUpdateOutputForKey:@"pointsArray"];
    *last = _lastUncorrectedPoint;
    NSUInteger count;
    if (_isInCorrectionMode == 0 || (count = [_pointsDataContainer count]) < 2) {
        [self snapPoint:last asDevicePixelCenter:YES withinBoundsWithMinX:-INFINITY maxX:INFINITY minY:-INFINITY maxY:INFINITY alongTrajectoryLine:CGELineUndefined withEvent:aEvent options:nil];
    } else {
        NSPoint *previous = [_pointsDataContainer bytesOfItemAtIndex:count - 2];
        *last = [self BTPointsCreationTool_guidePoint:*last withEvent:aEvent previousPoint:[self convertImagePointToViewPoint:*previous]];
    }
    *last = [self convertViewPointToImagePoint:*last];
    [_delegate tool:self didUpdateOutputForKey:@"pointsArray"];
}

- (void)trackMouseUp:(id)aEvent inView:(id)aView
{
    if (_view != aView)
        return;
    [[_delegate mouseTrackingDelegateForTool:self] trackMouseUp:aEvent inView:aView];
    [self BTPointsCreationTool_trackMouse:aEvent];
    _isTracking = 0;
    if (_maxPointsCount != 0 && [_pointsDataContainer count] == _maxPointsCount) {
        [self BTPointsCreationTool_didFinalizeWithEvent:aEvent];
        return;
    }
    if (_isLastPointDynamic) {
        _isInCorrectionMode = 0;
        [self BTPointsCreationTool_addTrackPointWithEvent:aEvent];
    }
    [_delegate tool:self didUpdateCursorWithEvent:aEvent];
}

- (void)trackMouseDragged:(id)aEvent inView:(id)aView
{
    if (_view != aView)
        return;
    [[_delegate mouseTrackingDelegateForTool:self] trackMouseDragged:aEvent inView:aView];
    [self BTPointsCreationTool_trackMouse:aEvent];
}

- (void)trackMouseDown:(id)aEvent inView:(id)aView
{
    if (_view != aView)
        return;
    [[_delegate mouseTrackingDelegateForTool:self] trackMouseDown:aEvent inView:aView];
    if (_isWaitingForClick)
        return;
    [(NSCursor *)[self doDragPointCursor] set];
    _isTracking = 1;
    _isInCorrectionMode = [self BTPointsCreationTool_isInCorrectionModeForModifierFlags:[aEvent modifierFlags]];
    if (_isLastPointDynamic && [_pointsDataContainer count] != 0)
        [self BTPointsCreationTool_trackMouse:aEvent];
    else
        [self BTPointsCreationTool_addTrackPointWithEvent:aEvent];
    if (_maxPointsCount == 0 || [_pointsDataContainer count] != _maxPointsCount)
        [self BTPointsCreationTool_addTrackPointWithEvent:aEvent];
}

/* 0: free placement, 1: corrected, 2: corrected with the alternate tangent (Command). */
- (unsigned char)BTPointsCreationTool_isInCorrectionModeForModifierFlags:(NSUInteger)aFlags
{
    if (aFlags & NSEventModifierFlagCommand)
        return 2;
    unsigned char mode = _isCorrectionModePrimary;
    if (aFlags & NSEventModifierFlagShift)
        mode ^= 1;
    return mode;
}

- (void)drawRect:(NSRect)aRect ofActiveFeedbackLayersExcludingLayers:(id)aLayers
{
}

- (void)drawRect:(NSRect)aRect ofActiveFeedbackLayersExcludingLayer:(id)aLayer
{
}

- (void)drawRect:(NSRect)aRect ofActiveFeedbackLayers:(id)aLayers
{
}

- (void)drawRect:(NSRect)aRect ofActiveFeedbackLayer:(id)aLayer
{
}

- (id)activeFeedbackLayersForDrawing
{
    return [NSArray array];
}

- (BOOL)isFeedbackLayerActive:(id)aLayer
{
    return NO;
}

- (id)activeFeedbackLayers
{
    return [NSSet set];
}

- (void)drawRect:(NSRect)aRect
{
}

- (BOOL)mouseMoved:(id)aEvent
{
    if (_isLastPointDynamic && _isPointCollectingStarted && [_pointsDataContainer count] != 0) {
        [self BTPointsCreationTool_trackMouse:aEvent];
        return YES;
    }
    return NO;
}

- (BOOL)mouseDown:(id)aEvent
{
    if (!_isPointCollectingStarted) {
        BOOL result = [_delegate tool:self didFinalizeStage:@"BTWaitingToolStage" withEvent:aEvent nextStage:@"BTCollectingPointsToolStage"];
        if (![self isActive])
            return result;
        _isPointCollectingStarted = 1;
        [_delegate tool:self willUpdateOutputForKey:@"pointsArray"];
        [_pointsDataContainer release];
        _pointsDataContainer = [[BTMutableDataArray alloc] initWithCount:0 itemSize:sizeof(NSPoint)];
        [_delegate tool:self didUpdateOutputForKey:@"pointsArray"];
    }
    [_view BT_trackMouseWithEvent:aEvent tracker:self];
    return YES;
}

- (id)cursorForPoint:(NSPoint)aPoint modifierFlags:(NSUInteger)aFlags
{
    return _isPointCollectingStarted ? [self doPickPointCursor] : [self willStartPointsCollectingCursor];
}

- (BOOL)isTracking
{
    return _isTracking;
}

- (id)currentStage
{
    return _isPointCollectingStarted ? @"BTCollectingPointsToolStage" : @"BTWaitingToolStage";
}

- (void)performDeactivate
{
    if (_isTracking) {
        [_view BT_abortMouseTracking];
        _isTracking = 0;
    }
    _isPointCollectingStarted = 0;
    [super performDeactivate];
}

- (BOOL)activateWithDelegate:(id)aDelegate inView:(id)aView
{
    if (![super activateWithDelegate:aDelegate inView:aView])
        return NO;
    if ([_pointsDataContainer count] != 0) {
        [_pointsDataContainer release];
        _pointsDataContainer = [[BTMutableDataArray alloc] initWithCount:0 itemSize:sizeof(NSPoint)];
    }
    return YES;
}

- (id)outputKeys
{
    return [NSArray arrayWithObjects:@"pointsArray", nil];
}

- (id)inputKeys
{
    return [NSArray arrayWithObjects:@"generalKeyBindings", @"willStartPointsCollectingCursor", @"doPickPointCursor",
            @"doDragPointCursor", @"isLastPointDynamic", @"collectingMode", @"maxPointsCount",
            @"isCorrectionModePrimary", @"correctionMode", @"correctionDiagonalTangent",
            @"alternateCorrectionDiagonalTangent", nil];
}

- (id)pointsArray
{
    return [BTPointsContainer containerWithDataArray:_pointsDataContainer count:[_pointsDataContainer count]];
}

- (void)setAlternateCorrectionDiagonalTangent:(CGFloat)aTangent
{
    _alternateCorrectionDiagonalTangent = aTangent;
}

- (CGFloat)alternateCorrectionDiagonalTangent
{
    return _alternateCorrectionDiagonalTangent;
}

- (CGFloat)defaultAlternateCorrectionDiagonalTangent
{
    return 1.0;
}

- (void)setCorrectionDiagonalTangent:(CGFloat)aTangent
{
    _correctionDiagonalTangent = aTangent;
}

- (CGFloat)correctionDiagonalTangent
{
    return _correctionDiagonalTangent;
}

- (CGFloat)defaultCorrectionDiagonalTangent
{
    return 1.0;
}

- (void)setCorrectionMode:(id)aMode
{
    [_correctionMode release];
    _correctionMode = [aMode copy];
}

- (id)correctionMode
{
    return _correctionMode;
}

- (id)defaultCorrectionMode
{
    return nil;
}

- (void)setIsCorrectionModePrimary:(BOOL)aPrimary
{
    _isCorrectionModePrimary = aPrimary ? 1 : 0;
}

- (BOOL)isCorrectionModePrimary
{
    return _isCorrectionModePrimary;
}

- (BOOL)defaultIsCorrectionModePrimary
{
    return NO;
}

/* With no limit, a double click ends the creation. */
- (void)setMaxPointsCount:(NSUInteger)aCount
{
    _maxPointsCount = aCount;
    _isStopCreationOnDoubleClick = aCount == 0;
}

- (NSUInteger)maxPointsCount
{
    return _maxPointsCount;
}

- (NSUInteger)defaultMaxPointsCount
{
    return 0;
}

- (void)setCollectingMode:(id)aMode
{
    _isWaitingForClick = ![aMode isEqualToString:@"BTDragToolTrackingMode"];
}

- (id)collectingMode
{
    return _isWaitingForClick ? @"BTMoveToolTrackingMode" : @"BTDragToolTrackingMode";
}

- (id)defaultCollectingMode
{
    return @"BTMoveToolTrackingMode";
}

- (void)setIsLastPointDynamic:(BOOL)aDynamic
{
    _isLastPointDynamic = aDynamic ? 1 : 0;
}

- (BOOL)isLastPointDynamic
{
    return _isLastPointDynamic;
}

- (BOOL)defaultIsLastPointDynamic
{
    return NO;
}

- (void)setDoDragPointCursor:(id)aCursor
{
    if (_doDragPointCursor != aCursor) {
        [aCursor retain];
        [_doDragPointCursor release];
        _doDragPointCursor = aCursor;
        if (_isTracking)
            [(NSCursor *)(aCursor != nil ? aCursor : [NSCursor arrowCursor]) set];
    }
    _isDoDragPointCursorInitialized = 1;
}

- (id)doDragPointCursor
{
    if (!_isDoDragPointCursorInitialized) {
        _doDragPointCursor = [[self defaultDoDragPointCursor] retain];
        _isDoDragPointCursorInitialized = 1;
    }
    return _doDragPointCursor;
}

- (id)defaultDoDragPointCursor
{
    return [NSCursor crosshairCursor];
}

- (void)setDoPickPointCursor:(id)aCursor
{
    if (_doPickPointCursor != aCursor) {
        [aCursor retain];
        [_doPickPointCursor release];
        _doPickPointCursor = aCursor;
    }
    _isDoPickPointCursorInitialized = 1;
}

- (id)doPickPointCursor
{
    if (!_isDoPickPointCursorInitialized) {
        _doPickPointCursor = [[self defaultDoPickPointCursor] retain];
        _isDoPickPointCursorInitialized = 1;
    }
    return _doPickPointCursor;
}

- (id)defaultDoPickPointCursor
{
    return [NSCursor crosshairCursor];
}

- (void)setWillStartPointsCollectingCursor:(id)aCursor
{
    if (_willStartPointsCollectingCursor != aCursor) {
        [_willStartPointsCollectingCursor release];
        _willStartPointsCollectingCursor = [aCursor retain];
    }
    _isWillStartPointsCollectingCursorInitialized = 1;
}

- (id)willStartPointsCollectingCursor
{
    if (!_isWillStartPointsCollectingCursorInitialized) {
        _willStartPointsCollectingCursor = [[self defaultWillStartPointsCollectingCursor] retain];
        _isWillStartPointsCollectingCursorInitialized = 1;
    }
    return _willStartPointsCollectingCursor;
}

- (id)defaultWillStartPointsCollectingCursor
{
    return [NSCursor crosshairCursor];
}

/* Constrains a point (view coordinates) relative to the previous one according to the
   correction mode: horizontal, vertical, diagonal at the correction tangent, or the best of
   those. Snapping onto a guide wins when the layout context offers one. */
- (NSPoint)BTPointsCreationTool_guidePoint:(NSPoint)aPoint withEvent:(id)aEvent previousPoint:(NSPoint)aPrevious
{
    NSPoint p = aPoint;

    if (_correctionMode == nil) {
        [self snapPoint:&p asDevicePixelCenter:YES withinBoundsWithMinX:-INFINITY maxX:INFINITY minY:-INFINITY maxY:INFINITY alongTrajectoryLine:CGELineUndefined withEvent:aEvent options:nil];
        return p;
    }
    if ([_correctionMode isEqualToString:@"BTCorrectionModeHorizontal"]) {
        if (![self snapPoint:&p asDevicePixelCenter:YES withinBoundsWithMinX:-INFINITY maxX:INFINITY minY:aPrevious.y maxY:aPrevious.y alongTrajectoryLine:(CGELine){0, 1, -aPrevious.y} withEvent:aEvent options:nil])
            p.y = aPrevious.y;
        return p;
    }
    if ([_correctionMode isEqualToString:@"BTCorrectionModeVertical"]) {
        if (![self snapPoint:&p asDevicePixelCenter:YES withinBoundsWithMinX:aPrevious.x maxX:aPrevious.x minY:-INFINITY maxY:INFINITY alongTrajectoryLine:(CGELine){1, 0, -aPrevious.x} withEvent:aEvent options:nil])
            p.x = aPrevious.x;
        return p;
    }

    BOOL diagonal = [_correctionMode isEqualToString:@"BTCorrectionModeDiagonal"];
    BOOL horizontalVertical = [_correctionMode isEqualToString:@"BTCorrectionModeHorizontalVertical"];
    BOOL all = [_correctionMode isEqualToString:@"BTCorrectionModeHorizontalVerticalDiagonal"];
    CGFloat t = ([aEvent modifierFlags] & NSEventModifierFlagCommand) ? _alternateCorrectionDiagonalTangent : _correctionDiagonalTangent;

    if ([_delegate layoutGuidingContextForTool:self] != nil) {
        NSSize s = [_view convertSize:NSMakeSize(0.001, 0.001) fromView:nil];
        CGFloat tol = hypot(s.width, s.height);
        NSPoint best = NSMakePoint(NAN, NAN);
        id bestRules = nil;
        CGFloat bestDistance = INFINITY;
        CGPoint candidate = CGPointMake(NAN, NAN);
        CGFloat distance = INFINITY;
        id rules = nil;

        if (all || horizontalVertical) {
            if ([self snapPoint:p asDevicePixelCenter:YES withinBoundsWithMinX:-INFINITY maxX:INFINITY minY:aPrevious.y maxY:aPrevious.y alongTrajectoryLine:(CGELine){0, 1, -aPrevious.y} withEvent:aEvent options:nil snappedPoint:&candidate snapDistance:&distance appliedRules:&rules]
                && !(aPrevious.x - tol <= candidate.x && candidate.x <= tol + aPrevious.x)) {
                bestDistance = distance; best = candidate; bestRules = rules;
            }
            if ([self snapPoint:p asDevicePixelCenter:YES withinBoundsWithMinX:aPrevious.x maxX:aPrevious.x minY:-INFINITY maxY:INFINITY alongTrajectoryLine:(CGELine){1, 0, -aPrevious.x} withEvent:aEvent options:nil snappedPoint:&candidate snapDistance:&distance appliedRules:&rules]
                && distance + tol < bestDistance
                && (candidate.y < aPrevious.y - tol || tol + aPrevious.y < candidate.y)) {
                bestDistance = distance; best = candidate; bestRules = rules;
            }
        }
        if (all || diagonal) {
            if ([self snapPoint:p asDevicePixelCenter:YES withinBoundsWithMinX:-INFINITY maxX:INFINITY minY:-INFINITY maxY:INFINITY alongTrajectoryLine:(CGELine){t, -1, aPrevious.y - t * aPrevious.x} withEvent:aEvent options:nil snappedPoint:&candidate snapDistance:&distance appliedRules:&rules]
                && distance + tol < bestDistance
                && (candidate.x < aPrevious.x - tol || tol + aPrevious.x < candidate.x)) {
                bestDistance = distance; best = candidate; bestRules = rules;
            }
            if ([self snapPoint:p asDevicePixelCenter:YES withinBoundsWithMinX:-INFINITY maxX:INFINITY minY:-INFINITY maxY:INFINITY alongTrajectoryLine:(CGELine){-t, -1, t * aPrevious.x + aPrevious.y} withEvent:aEvent options:nil snappedPoint:&candidate snapDistance:&distance appliedRules:&rules]
                && distance + tol < bestDistance
                && (candidate.x < aPrevious.x - tol || tol + aPrevious.x < candidate.x)) {
                bestDistance = distance; best = candidate; bestRules = rules;
            }
        }

        if (!isnan(bestDistance) && fabs(bestDistance) < INFINITY) {
            id context = [_delegate layoutGuidingContextForTool:self];
            SEL showSel = @selector(SMKBitmapTools_showAppliedRules:forSnappedPoint:);
            if ([context respondsToSelector:showSel]) {
                NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[context methodSignatureForSelector:showSel]];
                [inv setTarget:context];
                [inv setSelector:showSel];
                [inv setArgument:&bestRules atIndex:2];
                [inv setArgument:&best atIndex:3];
                [inv invoke];
            } else {
                [context showAppliedRules:bestRules];
            }
            return best;
        }
    }

    /* No guide: project onto the nearest allowed direction. */
    CGFloat dy = aPoint.y - aPrevious.y;
    CGFloat dx = aPoint.x - aPrevious.x;
    CGFloat ady = fabs(dy);
    CGFloat adx = fabs(t * dx);
    if (diagonal) {
        if (ady >= adx)
            p.y -= copysign(ady - adx, dy);
        else
            p.x -= copysign(adx - ady, dx) / fabs(t);
    } else if (horizontalVertical) {
        if (ady < adx)
            p.y = aPrevious.y;
        else
            p.x = aPrevious.x;
    } else if (all) {
        if (ady >= adx) {
            if (ady - adx >= adx)
                p.x = aPrevious.x;
            else
                p.y -= copysign(ady - adx, dy);
        } else {
            if (adx - ady >= ady)
                p.y = aPrevious.y;
            else
                p.x -= copysign(adx - ady, dx) / fabs(t);
        }
    }
    return p;
}

- (void)dealloc
{
    [_willStartPointsCollectingCursor release];
    [_doPickPointCursor release];
    [_doDragPointCursor release];
    [_pointsDataContainer release];
    [_correctionMode release];
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self == nil)
        return nil;
    _pointsDataContainer = [[BTMutableDataArray alloc] initWithCount:0 itemSize:sizeof(NSPoint)];
    if (_pointsDataContainer == nil) {
        [self release];
        return nil;
    }
    _correctionDiagonalTangent = 1.0;
    _alternateCorrectionDiagonalTangent = 1.0;
    _isLastPointDynamic = 0;
    _isWaitingForClick = 0;
    return self;
}

- (void)setProportionalMode:(BOOL)aMode
{
    _isProportionalMode = aMode;
}

- (BOOL)isProportionalMode
{
    return _isProportionalMode;
}

- (BOOL)defaultProportionalMode
{
    return NO;
}

@end

@implementation BTPointsCreationTool (Private)

- (void)BTPointsCreationTool_didFinalizeWithEvent:(id)aEvent
{
    [_delegate tool:self didFinalizeOutputForKey:@"pointsArray"];
    [_delegate tool:self didFinalizeStage:@"BTCollectingPointsToolStage" withEvent:aEvent nextStage:nil];
    if ([self isActive]) {
        _isPointCollectingStarted = 0;
        [_delegate tool:self didUpdateCursorWithEvent:aEvent];
    }
}

- (void)BTPointsCreationTool_addTrackPointWithEvent:(id)aEvent
{
    [_delegate tool:self willUpdateOutputForKey:@"pointsArray"];
    NSPoint point = [self eventLocationInView:aEvent];
    _lastUncorrectedPoint = point;
    NSUInteger count;
    if (_isInCorrectionMode != 0 && (count = [_pointsDataContainer count]) != 0) {
        NSPoint *previous = [_pointsDataContainer bytesOfItemAtIndex:count - 1];
        point = [self BTPointsCreationTool_guidePoint:point withEvent:aEvent previousPoint:[self convertImagePointToViewPoint:*previous]];
    } else {
        [self snapPoint:&point asDevicePixelCenter:YES withinBoundsWithMinX:-INFINITY maxX:INFINITY minY:-INFINITY maxY:INFINITY alongTrajectoryLine:CGELineUndefined withEvent:aEvent options:nil];
    }
    point = [self convertViewPointToImagePoint:point];
    [_pointsDataContainer addItemBytes:&point];
    [_delegate tool:self didUpdateOutputForKey:@"pointsArray"];
}

- (void)BTPointsCreationTool_trackMouse:(id)aEvent
{
    NSPoint *last = [_pointsDataContainer bytesOfLastItem];
    if (last == NULL)
        return;
    [_delegate tool:self willUpdateOutputForKey:@"pointsArray"];
    NSPoint point = [self eventLocationInView:aEvent];
    _lastUncorrectedPoint = point;
    *last = point;
    NSUInteger count;
    if (_isInCorrectionMode == 0 || (count = [_pointsDataContainer count]) < 2) {
        [self snapPoint:last asDevicePixelCenter:YES withinBoundsWithMinX:-INFINITY maxX:INFINITY minY:-INFINITY maxY:INFINITY alongTrajectoryLine:CGELineUndefined withEvent:aEvent options:nil];
    } else {
        NSPoint *previous = [_pointsDataContainer bytesOfItemAtIndex:count - 2];
        *last = [self BTPointsCreationTool_guidePoint:*last withEvent:aEvent previousPoint:[self convertImagePointToViewPoint:*previous]];
    }
    *last = [self convertViewPointToImagePoint:*last];
    [_delegate tool:self didUpdateOutputForKey:@"pointsArray"];
}

@end

