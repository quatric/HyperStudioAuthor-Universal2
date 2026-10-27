#import "BTDraw3DShapeTool.h"
#import "BTPointsContainer.h"
#import "BTPointer.h"
#import "NSWindow+BTEvents.h"

/* The 3D shape tool collects three points with a points creation tool: a drag
   sets the front face (the prototype path fitted to the dragged rect) and a
   third click places the back face's center. The faces are joined by an edge
   from every path point, and the result is stroked into the image. */
@implementation BTDraw3DShapeTool

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

/* The drag cursor of the points tool follows the color in use. */
static void BTDraw3DShapeToolSyncDragCursor(BTDraw3DShapeTool *self)
{
    id cursor = (self->_isUsingAlternateStrokeColor && self->_alternateStrokeColor != NULL) ? [self doAlternateDrawCursor] : [self doDrawCursor];
    [self->_pointsCreationTool setDoDragPointCursor:cursor];
}

- (void)trackFlagsChanged:(id)aEvent inView:(id)aView
{
    if (_view != aView)
        return;
    [[_delegate mouseTrackingDelegateForTool:self] trackFlagsChanged:aEvent inView:aView];
    BOOL alternate = BTModifierFlagsMatchOption([(NSEvent *)aEvent modifierFlags], _alternateStrokeColorOption);
    if (alternate != (BOOL)_isUsingAlternateStrokeColor) {
        _isUsingAlternateStrokeColor = alternate;
        BTDraw3DShapeToolSyncDragCursor(self);
    }
    if (_alternateStrokeColor != NULL)
        [self BTDraw3DShapeTool_setNeedsDisplay3DShapePath];
}

- (void)trackMouseUp:(id)aEvent inView:(id)aView
{
    if (_view != aView)
        return;
    [[_delegate mouseTrackingDelegateForTool:self] trackMouseUp:aEvent inView:aView];
    NSUInteger flags = [(NSEvent *)aEvent modifierFlags];
    _isUsingAlternateStrokeColor = BTModifierFlagsMatchOption(flags, _alternateStrokeColorOption);
    _isColorPicking = BTModifierFlagsMatchOption(flags, _colorPickingOption);
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
    _isUsingAlternateStrokeColor = BTModifierFlagsMatchOption([(NSEvent *)aEvent modifierFlags], _alternateStrokeColorOption);
    BTDraw3DShapeToolSyncDragCursor(self);
}

- (BOOL)flagsChanged:(id)aEvent
{
    NSUInteger flags = [(NSEvent *)aEvent modifierFlags];
    BOOL alternate = BTModifierFlagsMatchOption(flags, _alternateStrokeColorOption);
    BOOL picking = BTModifierFlagsMatchOption(flags, _colorPickingOption);
    if (alternate == (BOOL)_isUsingAlternateStrokeColor && picking == (BOOL)_isColorPicking)
        return NO;
    _isUsingAlternateStrokeColor = alternate;
    _isColorPicking = picking;
    [_delegate tool:self didUpdateCursorWithEvent:aEvent];
    if (_alternateStrokeColor != NULL && [_pointsCreationTool pointsArray] != nil)
        [self BTDraw3DShapeTool_setNeedsDisplay3DShapePath];
    return YES;
}

/* With the color picking option the click picks the (alternate) stroke color
   first; the points tool then handles it as usual. */
- (BOOL)mouseDown:(id)aEvent
{
    NSUInteger flags = [(NSEvent *)aEvent modifierFlags];
    _isUsingAlternateStrokeColor = BTModifierFlagsMatchOption(flags, _alternateStrokeColorOption);
    if (BTModifierFlagsMatchOption(flags, _colorPickingOption)) {
        id image = [self workImage];
        id color;
        if (image != nil && (color = (id)[image colorAtPoint:[self eventLocationInImage:aEvent]]) != nil) {
            NSString *key = _isUsingAlternateStrokeColor ? @"alternateStrokeColor" : @"strokeColor";
            [_delegate tool:self willUpdateOutputForKey:key];
            if (_isUsingAlternateStrokeColor)
                [self setAlternateStrokeColor:color];
            else
                [self setStrokeColor:color];
            [_delegate tool:self didUpdateOutputForKey:key];
        }
    }
    return [super mouseDown:aEvent];
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
}

/* Two points: the front face's rect, kept in window points so that odd
   sizes can be corrected to pixel centers. A third point: the back face's
   center, corrected the same way. */
- (void)tool:(id)aTool didUpdateOutputForKey:(id)aKey
{
    if (_currentSubtool != aTool || ![aKey isEqualToString:@"pointsArray"])
        return;
    id points = [_pointsCreationTool pointsArray];
    NSUInteger count = [points count];
    if (count == 3) {
        NSPoint *p = [points bytesOfItemAtIndex:2];
        if (p == NULL)
            return;
        if (!_shouldInvalidate3DShapePath)
            _shouldInvalidate3DShapePath = 1;
        else
            [self BTDraw3DShapeTool_setNeedsDisplay3DShapePath];
        _originalFrontStartPoint = *p;
        _frontShapeStartPoint = [_view convertPoint:[self convertImagePointToViewPoint:_originalFrontStartPoint] toView:nil];
        if (!_lastPointShouldBeCorrectedVertically)
            _frontShapeStartPoint.y -= 0.5;
        if (!_lastPointShouldBeCorrectedHorizontally)
            _frontShapeStartPoint.x -= 0.5;
        _frontShapeStartPoint = [self convertViewPointToImagePoint:[_view convertPoint:_frontShapeStartPoint fromView:nil]];
    } else if (count == 2) {
        NSPoint *p0 = [points bytesOfItemAtIndex:0];
        NSPoint *p1 = [points bytesOfItemAtIndex:1];
        if (p0 == NULL || p1 == NULL)
            return;
        if (!_shouldInvalidate3DShapePath)
            _shouldInvalidate3DShapePath = 1;
        else
            [self BTDraw3DShapeTool_setNeedsDisplay3DShapePath];
        _originalStartPoint = *p0;
        _originalFrontStartPoint = _originalStartPoint;
        _startPoint = [_view convertPoint:[self convertImagePointToViewPoint:_originalStartPoint] toView:nil];
        _endPoint = [_view convertPoint:[self convertImagePointToViewPoint:*p1] toView:nil];
        _lastPointShouldBeCorrectedVertically = remainder(_endPoint.y - _startPoint.y, 2.0) == 0.0;
        _lastPointShouldBeCorrectedHorizontally = remainder(_endPoint.x - _startPoint.x, 2.0) == 0.0;
        _startPoint = [self convertViewPointToImagePoint:[_view convertPoint:_startPoint fromView:nil]];
        _endPoint = [self convertViewPointToImagePoint:[_view convertPoint:_endPoint fromView:nil]];
    } else {
        return;
    }
    [self BTDraw3DShapeTool_setNeedsUpdatePath];
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

/* Collecting points is this tool's drawing stage; when it ends for good the
   shape is stroked into the image as one undo action. */
- (BOOL)tool:(id)aTool didFinalizeStage:(id)aStage withEvent:(id)aEvent nextStage:(id)aNextStage
{
    if (_currentSubtool != aTool)
        return NO;
    if ([aNextStage isEqualToString:@"BTCollectingPointsToolStage"])
        aNextStage = @"BTDrawingToolStage";
    if ([aStage isEqualToString:@"BTCollectingPointsToolStage"]) {
        CGEColorRef color;
        CGPathRef path;
        if (aNextStage == nil && (color = [self BTDraw3DShapeTool_effectiveStrokeColor]) != NULL
            && (path = [self BTDraw3DShapeTool_shape3DPath]) != NULL) {
            CGRect bounds = [self BTDraw3DShapeTool_shapeBoundingRect];
            if (!CGRectIsEmpty(bounds)) {
                CGRect r = CGRectInset(bounds, -0.05, -0.05);
                r = CGRectIntersection(r, (CGRect){ CGPointZero, [[self workImage] imageSize] });
                id image;
                if (!CGRectIsEmpty(r) && (image = [self workImage]) != nil) {
                    [self beginUndoAction];
                    [self preEditWorkImage:image inRect:r];
                    [image beginCGEditing];
                    CGContextRef context = [image imageCGContext];
                    if (context != NULL)
                        [self BTDraw3DShapeTool_drawShape3DPath:(struct CGPath *)path withBounds:bounds strokeColor:color inContext:context];
                    [image endCGEditing];
                    [self postEditWorkImageInRect:r];
                    [self endUndoActionWithName:@"Draw 3D Shape"];
                }
            }
        }
        aStage = @"BTDrawingToolStage";
    }
    return [_delegate tool:self didFinalizeStage:aStage withEvent:aEvent nextStage:aNextStage];
}

- (void)tool:(id)aTool didUpdateCursorWithEvent:(id)aEvent
{
    if (_currentSubtool == aTool)
        [_delegate tool:self didUpdateCursorWithEvent:aEvent];
}

static BOOL BTDraw3DShapeToolIsCollecting(BTDraw3DShapeTool *self)
{
    return [[self->_currentSubtool currentStage] isEqualToString:@"BTCollectingPointsToolStage"];
}

- (BOOL)isFeedbackLayerActive:(id)aLayer
{
    return BTDraw3DShapeToolIsCollecting(self) && [aLayer isEqualToString:@"BTDrawingFeedbackLayer"];
}

- (id)activeFeedbackLayers
{
    if (BTDraw3DShapeToolIsCollecting(self))
        return [NSSet setWithObject:@"BTDrawingFeedbackLayer"];
    return [NSSet set];
}

- (id)activeFeedbackLayersForDrawing
{
    if (BTDraw3DShapeToolIsCollecting(self))
        return [NSArray arrayWithObject:@"BTDrawingFeedbackLayer"];
    return [NSArray array];
}

/* The shape being collected, drawn in the view as it will be in the image. */
- (void)draw_BTDrawingFeedbackLayer_Rect:(NSRect)aRect
{
    CGEColorRef color = [self BTDraw3DShapeTool_effectiveStrokeColor];
    if (color == NULL)
        return;
    CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];
    if (context == NULL)
        return;
    CGPathRef path = [self BTDraw3DShapeTool_shape3DPath];
    if (path == NULL)
        return;
    CGRect bounds = [self BTDraw3DShapeTool_shapeBoundingRect];
    CGContextSaveGState(context);
    CGContextConcatCTM(context, [self imageToViewTransform]);
    [self BTDraw3DShapeTool_drawShape3DPath:(struct CGPath *)path withBounds:bounds strokeColor:color inContext:context];
    CGContextRestoreGState(context);
}

- (struct CGEColor *)BTDraw3DShapeTool_effectiveStrokeColor
{
    if (_isUsingAlternateStrokeColor && _alternateStrokeColor != NULL)
        return _alternateStrokeColor;
    return [self BTDraw3DShapeTool_strokeColor];
}

/* The points tool shows the cursor of the color (or color picking) in use. */
- (id)cursorForPoint:(NSPoint)aPoint modifierFlags:(NSUInteger)aFlags
{
    id cursor;
    if (BTModifierFlagsMatchOption(aFlags, _colorPickingOption)
        && ![[_pointsCreationTool currentStage] isEqualToString:@"BTCollectingPointsToolStage"])
        cursor = [self pickColorCursor];
    else if (BTModifierFlagsMatchOption(aFlags, _alternateStrokeColorOption) && _alternateStrokeColor != NULL)
        cursor = [self willAlternateDrawCursor];
    else
        cursor = [self willDrawCursor];
    [_pointsCreationTool setWillStartPointsCollectingCursor:cursor];
    return [_currentSubtool cursorForPoint:aPoint modifierFlags:aFlags];
}

- (id)currentStage
{
    if ([[_pointsCreationTool currentStage] isEqualToString:@"BTCollectingPointsToolStage"])
        return @"BTDrawingToolStage";
    return @"BTWaitingToolStage";
}

- (void)performDeactivate
{
    if (BTDraw3DShapeToolIsCollecting(self))
        [self BTDraw3DShapeTool_setNeedsDisplay3DShapePath];
    [_currentSubtool deactivate];
    _currentSubtool = nil;
    [super performDeactivate];
}

- (BOOL)activateWithDelegate:(id)aDelegate inView:(id)aView
{
    if (![super activateWithDelegate:aDelegate inView:aView])
        return NO;
    _currentSubtool = (BTTool *)_pointsCreationTool;
    if ([_currentSubtool activateWithDelegate:self inView:_view]) {
        NSUInteger flags = [[_view window] BT_effectiveModifierFlags];
        _isUsingAlternateStrokeColor = BTModifierFlagsMatchOption(flags, _alternateStrokeColorOption);
        _isColorPicking = BTModifierFlagsMatchOption(flags, _colorPickingOption);
        [_currentSubtool setViewInvalidationEnabled:[self isViewInvalidationEnabled]];
        return YES;
    }
    _currentSubtool = nil;
    [super performDeactivate];
    return NO;
}

- (void)changeViewInvalidationEnabledTo:(BOOL)aEnabled
{
    [super changeViewInvalidationEnabledTo:aEnabled];
    [_pointsCreationTool setViewInvalidationEnabled:aEnabled];
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

- (id)outputKeys
{
    return [NSArray arrayWithObjects:@"strokeColor", @"alternateStrokeColor", nil];
}

- (id)inputKeys
{
    return [NSArray arrayWithObjects:@"generalKeyBindings", @"pointsArray", @"willDrawCursor", @"doDrawCursor",
            @"shapePrototypePath", @"lineWidth", @"strokeColor", @"alternateStrokeColor", @"lineDashPhase", @"lineDash",
            @"alternateStrokeColorOption", @"colorPickingOption", nil];
}

- (id *)requiredImageProtocols
{
    static id protocols[2];
    protocols[0] = @protocol(BTCGMutableImage);
    return protocols;
}

/* The front face's rect, plus the back face's when it has been placed. */
- (CGRect)BTDraw3DShapeTool_shapeBoundingRect
{
    NSPoint start = _startPoint, end = _endPoint;
    [self BTDraw3DShapeTool_roundStartPoint:&start endPoint:&end];
    CGRect r = CGRectIntegral(CGRectMake(MIN(start.x, end.x), MIN(start.y, end.y), fabs(end.x - start.x), fabs(end.y - start.y)));
    if (!NSEqualPoints(_originalStartPoint, _originalFrontStartPoint)) {
        NSRect back = NSOffsetRect(r, _frontShapeStartPoint.x - r.origin.x - r.size.width * 0.5,
                                   _frontShapeStartPoint.y - r.origin.y - r.size.height * 0.5);
        r = NSUnionRect(r, back);
    }
    return r;
}

typedef struct {
    CGMutablePathRef path;
    CGFloat dx, dy;
} BTDraw3DShapeEdgesContext;

/* An edge from every point of the front face to the back face. */
static void BTDraw3DShapeAddEdge(void *aInfo, const CGPathElement *aElement)
{
    BTDraw3DShapeEdgesContext *c = aInfo;
    const CGPoint *p;
    switch (aElement->type) {
    case kCGPathElementMoveToPoint:
    case kCGPathElementAddLineToPoint:
        p = &aElement->points[0];
        break;
    case kCGPathElementAddQuadCurveToPoint:
        p = &aElement->points[1];
        break;
    case kCGPathElementAddCurveToPoint:
        p = &aElement->points[2];
        break;
    case kCGPathElementCloseSubpath:
        CGPathCloseSubpath(c->path);
        return;
    default:
        NSLog(@"Unknown CG path element type.");
        return;
    }
    CGPathMoveToPoint(c->path, NULL, p->x, p->y);
    CGPathAddLineToPoint(c->path, NULL, p->x + c->dx, p->y + c->dy);
}

/* The prototype fitted inside the front rect (inset by half the line width;
   the width shrinks when the lines wouldn't fit), then the edges and the back
   face, the same shape moved to the third point. */
- (struct CGPath *)BTDraw3DShapeTool_shape3DPath
{
    id prototype;
    if (_shape3DPath != NULL || (prototype = [self shapePrototypePath]) == nil)
        return (struct CGPath *)_shape3DPath;
    _shape3DPath = CGPathCreateMutable();
    if (_shape3DPath == NULL)
        return NULL;
    NSPoint start = _startPoint, end = _endPoint;
    [self BTDraw3DShapeTool_roundStartPoint:&start endPoint:&end];
    _drawingLineWidth = _lineWidth;
    if (_shapeLineCount != 0) {
        CGRect r = CGRectMake(MIN(start.x, end.x), MIN(start.y, end.y), fabs(end.x - start.x), fabs(end.y - start.y));
        if (!CGRectIsEmpty(r)) {
            CGFloat inset = _lineWidth * 0.5 * (CGFloat)_shapeLineCount;
            if (CGRectIsEmpty(CGRectInset(r, inset, inset)))
                _drawingLineWidth = fmin(r.size.width, r.size.height) / (CGFloat)_shapeLineCount - 0.0001;
        }
    }
    CGFloat half = _drawingLineWidth * 0.5;
    if (end.x <= start.x) {
        end.x += half;
        start.x -= half;
    } else {
        end.x -= half;
        start.x += half;
    }
    if (end.y <= start.y) {
        end.y += half;
        start.y -= half;
    } else {
        end.y -= half;
        start.y += half;
    }
    CGRect pb = _shape3DPrototypePathBounds;
    CGAffineTransform m;
    m.a = pb.size.width != 0.0 ? (end.x - start.x) / pb.size.width : copysign(1.0, end.x - start.x);
    m.d = pb.size.height != 0.0 ? (end.y - start.y) / pb.size.height : copysign(1.0, end.y - start.y);
    m.b = 0.0;
    m.c = 0.0;
    m.tx = start.x - pb.origin.x * m.a;
    m.ty = start.y - pb.origin.y * m.d;
    CGPathAddPath(_shape3DPath, &m, (CGPathRef)prototype);

    CGMutablePathRef back;
    if (!NSEqualPoints(_originalStartPoint, _originalFrontStartPoint) && (back = CGPathCreateMutable()) != NULL) {
        CGFloat minX = MIN(_startPoint.x, _endPoint.x), maxX = MAX(_startPoint.x, _endPoint.x);
        CGFloat minY = MIN(_startPoint.y, _endPoint.y), maxY = MAX(_startPoint.y, _endPoint.y);
        BTDraw3DShapeEdgesContext c = { back, (_frontShapeStartPoint.x - minX) + (maxX - minX) * -0.5,
                                        (_frontShapeStartPoint.y - minY) + (maxY - minY) * -0.5 };
        CGPathApply(_shape3DPath, &c, BTDraw3DShapeAddEdge);
        if (!CGPathIsEmpty(back)) {
            CGAffineTransform t = CGAffineTransformConcat(m, CGAffineTransformMakeTranslation(c.dx, c.dy));
            CGPathAddPath(back, &t, (CGPathRef)prototype);
            CGPathAddPath(_shape3DPath, NULL, back);
        }
        CGPathRelease(back);
    }
    return (struct CGPath *)_shape3DPath;
}

- (void)setLineDash:(id)aDash
{
    if (aDash == nil) {
        if (_lineDash == nil)
            return;
        [_lineDash release];
        _lineDash = nil;
    } else {
        if (_lineDash == nil)
            _lineDash = [[NSMutableData alloc] initWithLength:[aDash count] * sizeof(CGFloat)];
        else
            [_lineDash setLength:[aDash count] * sizeof(CGFloat)];
        CGFloat *lengths = [_lineDash mutableBytes];
        for (id length in aDash)
            *lengths++ = [length doubleValue];
    }
    [self BTDraw3DShapeTool_setNeedsDisplay3DShapePath];
}

- (id)lineDash
{
    if (_lineDash == nil)
        return nil;
    const CGFloat *lengths = [_lineDash bytes];
    NSUInteger count = [_lineDash length] / sizeof(CGFloat);
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:count];
    for (NSUInteger i = 0; i < count; i++)
        [array addObject:[NSNumber numberWithDouble:lengths[i]]];
    return [[array copy] autorelease];
}

- (id)defaultLineDash
{
    return nil;
}

- (void)setLineDashPhase:(CGFloat)aPhase
{
    if (_lineDashPhase == aPhase)
        return;
    _lineDashPhase = aPhase;
    [self BTDraw3DShapeTool_setNeedsDisplay3DShapePath];
}

- (CGFloat)lineDashPhase
{
    return _lineDashPhase;
}

- (CGFloat)defaultLineDashPhase
{
    return 0.0;
}

/* Colors come in as CGColors or as BTPointer-wrapped CGEColors. Returns NO
   when aColor equals aCurrent. */
static BOOL BTDraw3DShapeToolReplaceColor(CGEColorRef *aSlot, id aColor)
{
    CGEColorRef old = *aSlot;
    if (aColor == nil) {
        if (old == NULL)
            return NO;
        *aSlot = NULL;
    } else if (CFGetTypeID((CFTypeRef)aColor) == CGColorGetTypeID()) {
        if (CGColorEqualToColor((CGColorRef)aColor, CGEColorGetCGColor(old)))
            return NO;
        *aSlot = CGEColorCreateWithCGColor((CGColorRef)aColor);
    } else {
        CGEColorRef color = (CGEColorRef)[aColor pointer];
        if (CGEColorEqualToColor(color, old))
            return NO;
        *aSlot = CGEColorRetain(color);
    }
    CGEColorRelease(old);
    return YES;
}

- (void)setAlternateStrokeColor:(id)aColor
{
    if (BTDraw3DShapeToolReplaceColor(&_alternateStrokeColor, aColor) && _isUsingAlternateStrokeColor)
        [self BTDraw3DShapeTool_setNeedsDisplay3DShapePath];
}

- (id)alternateStrokeColor
{
    if (_alternateStrokeColor == NULL)
        return nil;
    id wrapper = [BTPointer wrapperForPointer:_alternateStrokeColor withDisposer:CGEColorRelease];
    if (wrapper != nil)
        CGEColorRetain(_alternateStrokeColor);
    return wrapper;
}

- (void)setStrokeColor:(id)aColor
{
    _isStrokeColorInitialized = 1;
    if (!BTDraw3DShapeToolReplaceColor(&_strokeColor, aColor))
        return;
    if (!_isUsingAlternateStrokeColor || _alternateStrokeColor == NULL)
        [self BTDraw3DShapeTool_setNeedsDisplay3DShapePath];
}

- (id)strokeColor
{
    if ([self BTDraw3DShapeTool_strokeColor] == NULL)
        return nil;
    id wrapper = [BTPointer wrapperForPointer:_strokeColor withDisposer:CGEColorRelease];
    if (wrapper != nil)
        CGEColorRetain(_strokeColor);
    return wrapper;
}

- (struct CGEColor *)BTDraw3DShapeTool_strokeColor
{
    if (!_isStrokeColorInitialized) {
        _strokeColor = [self BTDraw3DShapeTool_createDefaultStrokeColor];
        _isStrokeColorInitialized = 1;
    }
    return _strokeColor;
}

- (id)defaultStrokeColor
{
    CGEColorRef color = [self BTDraw3DShapeTool_createDefaultStrokeColor];
    if (color == NULL)
        return nil;
    id wrapper = [BTPointer wrapperForPointer:color withDisposer:CGEColorRelease];
    if (wrapper == nil)
        CGEColorRelease(color);
    return wrapper;
}

/* Opaque black. */
- (struct CGEColor *)BTDraw3DShapeTool_createDefaultStrokeColor
{
    CGColorSpaceRef space = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
    if (space == NULL)
        return NULL;
    const CGFloat components[4] = { 0.0, 0.0, 0.0, 1.0 };
    CGEColorRef color = CGEColorCreateSolid(space, components);
    CGColorSpaceRelease(space);
    return color;
}

- (void)setLineWidth:(CGFloat)aWidth
{
    if (_lineWidth == aWidth)
        return;
    _lineWidth = aWidth;
    [self BTDraw3DShapeTool_setNeedsUpdatePath];
}

- (CGFloat)lineWidth
{
    return _lineWidth;
}

- (CGFloat)defaultLineWidth
{
    return 1.0;
}

- (void)setShapeLineCount:(NSUInteger)aCount
{
    _shapeLineCount = aCount;
}

- (NSUInteger)shapeLineCount
{
    return _shapeLineCount;
}

- (NSUInteger)defaultShapeLineCount
{
    return 2;
}

/* Empty paths and paths with empty bounds are dropped. */
- (void)setShapePrototypePath:(id)aPath
{
    if ((CGPathRef)aPath != _shape3DPrototypePath) {
        CGPathRelease(_shape3DPrototypePath);
        _shape3DPrototypePath = NULL;
        if (aPath != nil && !CGPathIsEmpty((CGPathRef)aPath)) {
            _shape3DPrototypePathBounds = CGEPathGetPathBoundingBox((CGPathRef)aPath);
            if (!CGRectIsEmpty(_shape3DPrototypePathBounds))
                _shape3DPrototypePath = CGPathCreateCopy((CGPathRef)aPath);
        }
        if ([self isActive])
            [self BTDraw3DShapeTool_setNeedsDisplay3DShapePath];
    }
    _isShapePrototypePathInitialized = 1;
}

- (id)shapePrototypePath
{
    if (!_isShapePrototypePathInitialized) {
        _shape3DPrototypePath = CGPathCreateCopy((CGPathRef)[self defaultShapePrototypePath]);
        _shape3DPrototypePathBounds = CGRectMake(0.0, 0.0, 1.0, 1.0);
        _isShapePrototypePathInitialized = 1;
    }
    return (id)_shape3DPrototypePath;
}

/* The unit square. */
- (id)defaultShapePrototypePath
{
    CGMutablePathRef path = CGPathCreateMutable();
    if (path != NULL) {
        [(id)path autorelease];
        CGPathAddRect(path, NULL, CGRectMake(0.0, 0.0, 1.0, 1.0));
    }
    return [(id)CGPathCreateCopy(path) autorelease];
}

- (void)setPickColorCursor:(id)aCursor
{
    if (_pickColorCursor != aCursor) {
        [_pickColorCursor release];
        _pickColorCursor = [aCursor retain];
    }
    _isPickColorCursorInitialized = 1;
}

- (id)pickColorCursor
{
    if (!_isPickColorCursorInitialized) {
        _pickColorCursor = [[self defaultPickColorCursor] retain];
        _isPickColorCursorInitialized = 1;
    }
    return _pickColorCursor;
}

- (id)defaultPickColorCursor
{
    return [NSCursor crosshairCursor];
}

- (void)setDoAlternateDrawCursor:(id)aCursor
{
    if (_doAlternateDrawCursor != aCursor) {
        [_doAlternateDrawCursor release];
        _doAlternateDrawCursor = [aCursor retain];
    }
    _isDoAlternateDrawCursorInitialized = 1;
}

- (id)doAlternateDrawCursor
{
    if (!_isDoAlternateDrawCursorInitialized) {
        _doAlternateDrawCursor = [[self defaultDoAlternateDrawCursor] retain];
        _isDoAlternateDrawCursorInitialized = 1;
    }
    return _doAlternateDrawCursor;
}

- (id)defaultDoAlternateDrawCursor
{
    return [_pointsCreationTool defaultDoDragPointCursor];
}

- (void)setWillAlternateDrawCursor:(id)aCursor
{
    if (_willAlternateDrawCursor != aCursor) {
        [_willAlternateDrawCursor release];
        _willAlternateDrawCursor = [aCursor retain];
    }
    _isWillAlternateDrawCursorInitialized = 1;
}

- (id)willAlternateDrawCursor
{
    if (!_isWillAlternateDrawCursorInitialized) {
        _willAlternateDrawCursor = [[self defaultWillAlternateDrawCursor] retain];
        _isWillAlternateDrawCursorInitialized = 1;
    }
    return _willAlternateDrawCursor;
}

- (id)defaultWillAlternateDrawCursor
{
    return [_pointsCreationTool defaultWillStartPointsCollectingCursor];
}

- (void)setDoDrawCursor:(id)aCursor
{
    if (_doDrawCursor != aCursor) {
        [_doDrawCursor release];
        _doDrawCursor = [aCursor retain];
    }
    _isDoDrawCursorInitialized = 1;
}

- (id)doDrawCursor
{
    if (!_isDoDrawCursorInitialized) {
        _doDrawCursor = [[self defaultDoDrawCursor] retain];
        _isDoDrawCursorInitialized = 1;
    }
    return _doDrawCursor;
}

- (id)defaultDoDrawCursor
{
    return [_pointsCreationTool defaultDoPickPointCursor];
}

- (void)setWillDrawCursor:(id)aCursor
{
    if (_willDrawCursor != aCursor) {
        [_willDrawCursor release];
        _willDrawCursor = [aCursor retain];
    }
    _isWillDrawCursorInitialized = 1;
}

- (id)willDrawCursor
{
    if (!_isWillDrawCursorInitialized) {
        _willDrawCursor = [[self defaultWillDrawCursor] retain];
        _isWillDrawCursorInitialized = 1;
    }
    return _willDrawCursor;
}

- (id)defaultWillDrawCursor
{
    return [_pointsCreationTool defaultWillStartPointsCollectingCursor];
}

- (void)setAlternateStrokeColorOption:(NSUInteger)aOption
{
    _alternateStrokeColorOption = aOption;
}

- (NSUInteger)alternateStrokeColorOption
{
    return _alternateStrokeColorOption;
}

- (NSUInteger)defaultAlternateStrokeColorOption
{
    return NSEventModifierFlagOption;
}

- (void)setColorPickingOption:(NSUInteger)aOption
{
    _colorPickingOption = aOption;
}

- (NSUInteger)colorPickingOption
{
    return _colorPickingOption;
}

- (NSUInteger)defaultColorPickingOption
{
    return NSEventModifierFlagCommand;
}

- (void)dealloc
{
    [_pointsCreationTool release];
    CGPathRelease(_shape3DPrototypePath);
    CGPathRelease(_shape3DPath);
    CGEColorRelease(_strokeColor);
    CGEColorRelease(_alternateStrokeColor);
    [_lineDash release];
    [_willDrawCursor release];
    [_doDrawCursor release];
    [_willAlternateDrawCursor release];
    [_doAlternateDrawCursor release];
    [_pickColorCursor release];
    [super dealloc];
}

/* Three points: a drag for the front face, then a click for the back. */
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
    [_pointsCreationTool setMaxPointsCount:3];
    [_pointsCreationTool setCollectingMode:BTCollectingDragPointsMode];
    [_pointsCreationTool setIsLastPointDynamic:YES];
    [_pointsCreationTool setDoPickPointCursor:[NSCursor closedHandCursor]];
    [_pointsCreationTool setCorrectionMode:@"BTCorrectionModeDiagonal"];
    _lineWidth = 1.0;
    _shapeLineCount = 2;
    _alternateStrokeColorOption = NSEventModifierFlagOption;
    _colorPickingOption = NSEventModifierFlagCommand;
    return self;
}

@end

@implementation BTDraw3DShapeTool (Private)

/* Widens the rect of the two points by half a window pixel on each side. */
- (void)BTDraw3DShapeTool_roundStartPoint:(NSPoint *)aStart endPoint:(NSPoint *)aEnd
{
    NSPoint s = [_view convertPoint:[self convertImagePointToViewPoint:*aStart] toView:nil];
    NSPoint e = [_view convertPoint:[self convertImagePointToViewPoint:*aEnd] toView:nil];
    if (e.x > s.x) {
        e.x += 0.5;
        s.x -= 0.5;
    } else {
        e.x -= 0.5;
        s.x += 0.5;
    }
    if (e.y > s.y) {
        e.y += 0.5;
        s.y -= 0.5;
    } else {
        e.y -= 0.5;
        s.y += 0.5;
    }
    *aStart = [self convertViewPointToImagePoint:[_view convertPoint:s fromView:nil]];
    *aEnd = [self convertViewPointToImagePoint:[_view convertPoint:e fromView:nil]];
}

- (void)BTDraw3DShapeTool_setNeedsUpdatePath
{
    [self BTDraw3DShapeTool_setNeedsDisplay3DShapePath];
    CGPathRelease(_shape3DPath);
    _shape3DPath = NULL;
}

- (void)BTDraw3DShapeTool_drawShape3DPath:(struct CGPath *)aPath withBounds:(CGRect)aBounds strokeColor:(struct CGEColor *)aColor inContext:(struct CGContext *)aContext
{
    CGContextSetLineWidth(aContext, _drawingLineWidth);
    CGContextSetLineJoin(aContext, kCGLineJoinRound);
    CGContextSetLineCap(aContext, kCGLineCapButt);
    CGContextSetLineDash(aContext, _lineDashPhase, [_lineDash bytes], [_lineDash length] / sizeof(CGFloat));
    CGContextBeginPath(aContext);
    CGContextAddPath(aContext, aPath);
    CGEContextStrokePathWithColor(aContext, NULL, aBounds, aColor);
}

- (void)BTDraw3DShapeTool_setNeedsDisplay3DShapePath
{
    if (![self isViewInvalidationEnabled])
        return;
    CGRect r = CGRectIntegral(CGRectInset([self BTDraw3DShapeTool_shapeBoundingRect], -0.05, -0.05));
    [_view setNeedsDisplayInRect:NSIntegralRect([self convertImageRectToViewRect:r])];
}

@end
