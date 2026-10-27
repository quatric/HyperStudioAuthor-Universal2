#import "BTCreateShapeSelectionTool.h"
#import "BTPointsContainer.h"

@implementation BTCreateShapeSelectionTool

/* Whether the centering modifiers are held for the current drag. */
static BOOL BTShapeSelectionIsCentering(BTCreateShapeSelectionTool *self)
{
    return BTModifierFlagsMatchOption(self->_effectiveModifierFlags, self->_centeringOption);
}

/* The drag start point, mirrored through itself when centering. */
static NSPoint BTShapeSelectionOrigin(BTCreateShapeSelectionTool *self)
{
    NSPoint p = self->_selectionStartPoint;
    if (BTShapeSelectionIsCentering(self)) {
        p.y += p.y - self->_selectionEndPoint.y;
        p.x += p.x - self->_selectionEndPoint.x;
    }
    return p;
}

/* Maps the prototype bounds onto the rect spanned by two points. */
static CGAffineTransform BTShapeSelectionTransform(BTCreateShapeSelectionTool *self, NSPoint aStart, NSPoint aEnd)
{
    CGRect bounds = self->_selectionShapePrototypePathBounds;
    CGAffineTransform m;
    m.a = aEnd.x - aStart.x;
    m.d = aEnd.y - aStart.y;
    m.a = bounds.size.width != 0.0 ? m.a / bounds.size.width : copysign(1.0, m.a);
    m.d = bounds.size.height != 0.0 ? m.d / bounds.size.height : copysign(1.0, m.d);
    m.b = 0.0;
    m.c = 0.0;
    m.tx = aStart.x - bounds.origin.x * m.a;
    m.ty = aStart.y - bounds.origin.y * m.d;
    return m;
}

static BOOL BTShapeSelectionIsCollecting(BTCreateShapeSelectionTool *self)
{
    return [[self->_currentSubtool currentStage] isEqualToString:@"BTCollectingPointsToolStage"];
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
    if (_view == aView)
        [[_delegate mouseTrackingDelegateForTool:self] haltWithMouseUp:aEvent inView:aView];
}

/* Redraws the selection when the centering modifiers are pressed or released. */
- (void)trackFlagsChanged:(id)aEvent inView:(id)aView
{
    if (_view != aView)
        return;
    [[_delegate mouseTrackingDelegateForTool:self] trackFlagsChanged:aEvent inView:aView];
    NSUInteger flags = [(NSEvent *)aEvent modifierFlags];
    if (!_isSelectionPathDefined
        || BTModifierFlagsMatchOption(flags, _centeringOption) == BTShapeSelectionIsCentering(self)) {
        _effectiveModifierFlags = flags;
        return;
    }
    [self BTCreateShapeSelectionTool_setNeedsDisplaySelectionPathIfNeeded];
    [_delegate tool:self willUpdateOutputForKey:@"selectionPath"];
    _effectiveModifierFlags = flags;
    [_delegate tool:self didUpdateOutputForKey:@"selectionPath"];
    [self BTCreateShapeSelectionTool_setNeedsDisplaySelectionPathIfNeeded];
}

- (void)trackMouseUp:(id)aEvent inView:(id)aView
{
    if (_view == aView)
        [[_delegate mouseTrackingDelegateForTool:self] trackMouseUp:aEvent inView:aView];
}

- (void)trackMouseDragged:(id)aEvent inView:(id)aView
{
    if (_view == aView)
        [[_delegate mouseTrackingDelegateForTool:self] trackMouseDragged:aEvent inView:aView];
}

- (void)trackMouseDown:(id)aEvent inView:(id)aView
{
    if (_view != aView)
        return;
    [[_delegate mouseTrackingDelegateForTool:self] trackMouseDown:aEvent inView:aView];
    _effectiveModifierFlags = [(NSEvent *)aEvent modifierFlags];
}

- (id)layoutGuidingContextForTool:(id)aTool
{
    return _currentSubtool == aTool ? [_delegate layoutGuidingContextForTool:self] : nil;
}

- (id)mouseTrackingDelegateForTool:(id)aTool
{
    return _currentSubtool == aTool ? self : nil;
}

- (id)imageViewTransformerForTool:(id)aTool
{
    return _currentSubtool == aTool ? [_delegate imageViewTransformerForTool:self] : nil;
}

- (id)tool:(id)aTool willSetUndoActionName:(id)aName
{
    return nil;
}

- (void)tool:(id)aTool willRegisterUndoInManager:(id)aManager category:(id)aCategory
{
}

- (id)undoManagerForTool:(id)aTool category:(id)aCategory
{
    return nil;
}

- (void)tool:(id)aTool didFinalizeOutputForKey:(id)aKey
{
    if (_currentSubtool != aTool || ![aKey isEqualToString:@"pointsArray"])
        return;
    if (_isSelectionPathBeingCreated) {
        _isSelectionPathBeingCreated = 0;
        [_delegate tool:self didFinalizeOutputForKey:@"selectionPath"];
        [self endUndoActionWithName:@"Create Shape Selection"];
    } else {
        [_delegate tool:self didFinalizeOutputForKey:@"selectionPath"];
    }
}

/* The two collected points span the selection; each is pushed half a window
   pixel outward so the shape covers the pixels under both ends. */
- (void)tool:(id)aTool didUpdateOutputForKey:(id)aKey
{
    if (_currentSubtool != aTool || ![aKey isEqualToString:@"pointsArray"])
        return;
    id points = [_pointsCreationTool pointsArray];
    NSUInteger count = [points count];
    if (count == 2) {
        [_delegate tool:self willUpdateOutputForKey:@"selectionPath"];
        [_delegate tool:self willUpdateOutputForKey:@"selectionStartPoint"];
        if (!_isSelectionPathBeingCreated) {
            [self beginUndoAction];
            _isSelectionPathBeingCreated = 1;
        }
        BOOL collecting = BTShapeSelectionIsCollecting(self);
        if (_isSelectionPathDefined && collecting)
            [self BTCreateShapeSelectionTool_setNeedsDisplaySelectionPathIfNeeded];

        NSPoint first = *(NSPoint *)[points bytesOfItemAtIndex:0];
        _initialSelectionPoint = first;
        _selectionStartPoint = [_view convertPoint:[self convertImagePointToViewPoint:first] toView:nil];
        NSPoint second = *(NSPoint *)[points bytesOfItemAtIndex:1];
        _selectionEndPoint = [_view convertPoint:[self convertImagePointToViewPoint:second] toView:nil];
        CGFloat dx = _selectionEndPoint.x < _selectionStartPoint.x ? -0.5 : 0.5;
        _selectionStartPoint.x -= dx;
        _selectionEndPoint.x += dx;
        CGFloat dy = _selectionEndPoint.y < _selectionStartPoint.y ? -0.5 : 0.5;
        _selectionStartPoint.y -= dy;
        _selectionEndPoint.y += dy;
        _selectionStartPoint = [self convertViewPointToImagePoint:[_view convertPoint:_selectionStartPoint fromView:nil]];
        _selectionEndPoint = [self convertViewPointToImagePoint:[_view convertPoint:_selectionEndPoint fromView:nil]];
        _isSelectionPathDefined = 1;
        if (collecting)
            [self BTCreateShapeSelectionTool_setNeedsDisplaySelectionPathIfNeeded];
        [_delegate tool:self didUpdateOutputForKey:@"selectionStartPoint"];
        [_delegate tool:self didUpdateOutputForKey:@"selectionPath"];
        [_delegate tool:self didFinalizeOutputForKey:@"selectionStartPoint"];
    } else if (count < 2 && !_isSelectionPathBeingCreated && _isSelectionPathDefined) {
        [_delegate tool:self willUpdateOutputForKey:@"selectionPath"];
        [self beginUndoAction];
        _isSelectionPathDefined = 0;
        [_delegate tool:self didUpdateOutputForKey:@"selectionPath"];
        _isSelectionPathBeingCreated = 1;
    }
}

- (void)tool:(id)aTool willUpdateOutputForKey:(id)aKey
{
}

- (void)tool:(id)aTool didReplaceImageWithEffectiveChangeInRect:(NSRect)aRect
{
}

- (void)tool:(id)aTool willReplaceImageWithEffectiveChangeInRect:(NSRect)aRect
{
}

- (void)tool:(id)aTool didChangeImageInRect:(NSRect)aRect
{
}

- (void)tool:(id)aTool willChangeImageInRect:(NSRect)aRect
{
}

- (void)toolDidEndChangingImageContinuously:(id)aTool
{
}

- (void)toolWillBeginChangingImageContinuously:(id)aTool
{
}

/* The points tool's collecting stage is reported as creating the selection. */
- (BOOL)tool:(id)aTool didFinalizeStage:(id)aStage withEvent:(id)aEvent nextStage:(id)aNextStage
{
    if (_currentSubtool != aTool)
        return NO;
    if ([aStage isEqualToString:@"BTCollectingPointsToolStage"])
        aStage = @"BTCreatingSelectionToolStage";
    if ([aNextStage isEqualToString:@"BTCollectingPointsToolStage"])
        aNextStage = @"BTCreatingSelectionToolStage";
    BOOL result = [_delegate tool:self didFinalizeStage:aStage withEvent:aEvent nextStage:aNextStage];
    if (aNextStage == nil && _currentSubtool != nil)
        _isSelectionPathDefined = 0;
    return result;
}

- (void)tool:(id)aTool didUpdateCursorWithEvent:(id)aEvent
{
    if (_currentSubtool == aTool)
        [_delegate tool:self didUpdateCursorWithEvent:aEvent];
}

- (BOOL)isFeedbackLayerActive:(id)aLayer
{
    if (!BTShapeSelectionIsCollecting(self))
        return NO;
    return [aLayer isEqualToString:@"BTSelectionFeedbackLayer"];
}

- (id)activeFeedbackLayers
{
    return BTShapeSelectionIsCollecting(self) ? [NSSet setWithObject:@"BTSelectionFeedbackLayer"] : [NSSet set];
}

- (id)activeFeedbackLayersForDrawing
{
    return BTShapeSelectionIsCollecting(self) ? [NSArray arrayWithObject:@"BTSelectionFeedbackLayer"] : [NSArray array];
}

/* Marching ants: red dashes over white, drawn just inside the shape's bounds. */
- (void)draw_BTSelectionFeedbackLayer_Rect:(NSRect)aRect
{
    if (!_isSelectionPathDefined || [self selectionShapePrototypePath] == nil)
        return;
    CGMutablePathRef path = (CGMutablePathRef)CFAutorelease(CGPathCreateMutable());
    if (path == NULL)
        return;

    CGAffineTransform toView = CGAffineTransformConcat(BTShapeSelectionTransform(self, _selectionStartPoint, _selectionEndPoint), [self imageToViewTransform]);
    CGRect bounds = _selectionShapePrototypePathBounds;
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
    CGPathAddPath(path, &m, _selectionShapePrototypePath);

    CGContextRef context = [[NSGraphicsContext currentContext] CGContext];
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
    [self beginUndoAction];
    [_currentSubtool performSelector:@selector(selectAllArea:) withObject:aSender];
    [self endUndoActionWithName:@"Create All Area Shape Selection"];
}

- (id)cursorForPoint:(NSPoint)aPoint modifierFlags:(NSUInteger)aFlags
{
    return [self willCreateSelectionCursor];
}

- (id)currentStage
{
    return [[_pointsCreationTool currentStage] isEqualToString:@"BTCollectingPointsToolStage"]
        ? @"BTCreatingSelectionToolStage" : @"BTWaitingToolStage";
}

- (void)performDeactivate
{
    if (_isSelectionPathDefined && BTShapeSelectionIsCollecting(self))
        [self BTCreateShapeSelectionTool_setNeedsDisplaySelectionPathIfNeeded];
    [_currentSubtool deactivate];
    _currentSubtool = nil;
    [super performDeactivate];
}

- (BOOL)activateWithDelegate:(id)aDelegate inView:(id)aView
{
    if (![super activateWithDelegate:aDelegate inView:aView])
        return NO;
    _isSelectionPathDefined = 0;
    _currentSubtool = _pointsCreationTool;
    if (![_pointsCreationTool activateWithDelegate:self inView:aView]) {
        _currentSubtool = nil;
        [super performDeactivate];
        return NO;
    }
    return YES;
}

- (void)changeReferenceCGContextTo:(struct CGContext *)aContext
{
    [super changeReferenceCGContextTo:aContext];
    [_pointsCreationTool setReferenceCGContext:aContext];
}

- (void)changeWorkPasteboardTo:(id)aPasteboard
{
    [super changeWorkPasteboardTo:aPasteboard];
    [_pointsCreationTool setWorkPasteboard:aPasteboard];
}

- (void)changeWorkImageTo:(id)aImage
{
    [super changeWorkImageTo:aImage];
    [_pointsCreationTool setWorkImage:aImage];
}

- (id)outputKeys
{
    return [NSArray arrayWithObjects:@"selectionStartPoint", @"selectionPath", nil];
}

- (id)inputKeys
{
    return [NSArray arrayWithObjects:@"generalKeyBindings", @"willCreateSelectionCursor", @"doCreateSelectionCursor", @"selectionShapePrototypePath", @"centeringOption", @"alternateProportion", @"proportionalModePrimary", nil];
}

/* The prototype fitted to the dragged rect, unless the delegate supplies the shape. */
- (id)selectionPath
{
    if (!_isSelectionPathDefined || [self selectionShapePrototypePath] == nil)
        return nil;
    NSPoint start = BTShapeSelectionOrigin(self);
    CGMutablePathRef path = CGPathCreateMutable();
    if (path == NULL)
        return nil;
    CGAffineTransform m = BTShapeSelectionTransform(self, start, _selectionEndPoint);
    if ([_delegate respondsToSelector:@selector(canProvideSelectedShape)]
        && [_delegate respondsToSelector:@selector(provideSelectionPath:withOrientedRectTransform:)]
        && [(id)_delegate canProvideSelectedShape])
        [(id)_delegate provideSelectionPath:path withOrientedRectTransform:m];
    else
        CGPathAddPath(path, &m, _selectionShapePrototypePath);
    id result = [(id)CGPathCreateCopy(path) autorelease];
    CGPathRelease(path);
    return result;
}

- (id)selectionStartPoint
{
    if (!_isSelectionPathDefined)
        return nil;
    return [NSValue valueWithPoint:_initialSelectionPoint];
}

- (void)setProportionalModePrimary:(BOOL)aPrimary
{
    [_pointsCreationTool setIsCorrectionModePrimary:aPrimary];
}

- (BOOL)isProportionalModePrimary
{
    return [_pointsCreationTool isCorrectionModePrimary];
}

- (BOOL)defaultProportionalModePrimary
{
    return NO;
}

- (void)setAlternateProportion:(CGFloat)aProportion
{
    [_pointsCreationTool setAlternateCorrectionDiagonalTangent:aProportion];
}

- (CGFloat)alternateProportion
{
    return [_pointsCreationTool alternateCorrectionDiagonalTangent];
}

- (CGFloat)defaultAlternateProportion
{
    return [_pointsCreationTool defaultAlternateCorrectionDiagonalTangent];
}

- (void)setCenteringOption:(NSUInteger)aOption
{
    if (_centeringOption == aOption)
        return;
    if (_isSelectionPathDefined && [self isViewInvalidationEnabled] && BTShapeSelectionIsCollecting(self)
        && BTModifierFlagsMatchOption(_effectiveModifierFlags, aOption) != BTShapeSelectionIsCentering(self)) {
        [self BTCreateShapeSelectionTool_setNeedsDisplaySelectionPath];
        _centeringOption = aOption;
        [self BTCreateShapeSelectionTool_setNeedsDisplaySelectionPath];
    }
    _centeringOption = aOption;
}

- (NSUInteger)centeringOption
{
    return _centeringOption;
}

- (NSUInteger)defaultCenteringOption
{
    return (NSUInteger)-1;
}

/* An empty prototype leaves the tool without a shape; a usable one also sets
   the points tool's proportional tangent to its aspect ratio. */
- (void)setSelectionShapePrototypePath:(id)aPath
{
    if ((CGPathRef)aPath != _selectionShapePrototypePath) {
        CGPathRelease(_selectionShapePrototypePath);
        _selectionShapePrototypePath = NULL;
        if (aPath != nil && !CGPathIsEmpty((CGPathRef)aPath)) {
            _selectionShapePrototypePathBounds = CGEPathGetPathBoundingBox((CGPathRef)aPath);
            if (!CGRectIsEmpty(_selectionShapePrototypePathBounds)) {
                _selectionShapePrototypePath = CGPathCreateCopy((CGPathRef)aPath);
                [_pointsCreationTool setCorrectionDiagonalTangent:_selectionShapePrototypePathBounds.size.height / _selectionShapePrototypePathBounds.size.width];
            }
        }
        if (_isSelectionPathDefined && BTShapeSelectionIsCollecting(self))
            [self BTCreateShapeSelectionTool_setNeedsDisplaySelectionPathIfNeeded];
    }
    _isShapePrototypePathInitialized = 1;
}

- (id)selectionShapePrototypePath
{
    if (!_isShapePrototypePathInitialized) {
        _selectionShapePrototypePath = CGPathCreateCopy((CGPathRef)[self defaultSelectionShapePrototypePath]);
        _selectionShapePrototypePathBounds = CGRectMake(0.0, 0.0, 1.0, 1.0);
        _isShapePrototypePathInitialized = 1;
    }
    return (id)_selectionShapePrototypePath;
}

- (id)defaultSelectionShapePrototypePath
{
    CGMutablePathRef path = CGPathCreateMutable();
    if (path != NULL) {
        CFAutorelease(path);
        CGPathAddRect(path, NULL, CGRectMake(0.0, 0.0, 1.0, 1.0));
    }
    return [(id)CGPathCreateCopy(path) autorelease];
}

- (void)setDoCreateSelectionCursor:(id)aCursor
{
    [_pointsCreationTool setDoDragPointCursor:aCursor];
}

- (id)doCreateSelectionCursor
{
    return [_pointsCreationTool doDragPointCursor];
}

- (id)defaultDoCreateSelectionCursor
{
    return [_pointsCreationTool defaultDoDragPointCursor];
}

- (void)setWillCreateSelectionCursor:(id)aCursor
{
    [_pointsCreationTool setWillStartPointsCollectingCursor:aCursor];
}

- (id)willCreateSelectionCursor
{
    return [_pointsCreationTool willStartPointsCollectingCursor];
}

- (id)defaultWillCreateSelectionCursor
{
    return [_pointsCreationTool defaultWillStartPointsCollectingCursor];
}

- (void)BTCreateShapeSelectionTool_setNeedsDisplaySelectionPathIfNeeded
{
    if ([self isViewInvalidationEnabled])
        [self BTCreateShapeSelectionTool_setNeedsDisplaySelectionPath];
}

- (void)BTCreateShapeSelectionTool_setNeedsDisplaySelectionPath
{
    NSPoint start = BTShapeSelectionOrigin(self);
    CGFloat minX = MIN(start.x, _selectionEndPoint.x), maxX = MAX(start.x, _selectionEndPoint.x);
    CGFloat minY = MIN(start.y, _selectionEndPoint.y), maxY = MAX(start.y, _selectionEndPoint.y);
    NSRect r = [self convertImageRectToViewRect:NSMakeRect(minX - 1.05, minY - 1.05, (maxX - minX) + 2.1, (maxY - minY) + 2.1)];
    [_view setNeedsDisplayInRect:NSRectFromCGRect(CGRectIntegral(NSRectToCGRect(r)))];
}

- (void)dealloc
{
    [_pointsCreationTool release];
    CGPathRelease(_selectionShapePrototypePath);
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self == nil)
        return nil;
    _pointsCreationTool = [[BTPointsCreationTool alloc] init];
    if (_pointsCreationTool == nil) {
        [self release];
        return nil;
    }
    [_pointsCreationTool setViewInvalidationEnabled:NO];
    [_pointsCreationTool setMaxPointsCount:2];
    [_pointsCreationTool setCollectingMode:BTCollectingDragPointsMode];
    [_pointsCreationTool setIsLastPointDynamic:NO];
    [_pointsCreationTool setCorrectionMode:@"BTCorrectionModeDiagonal"];
    _centeringOption = (NSUInteger)-1;
    return self;
}

@end
