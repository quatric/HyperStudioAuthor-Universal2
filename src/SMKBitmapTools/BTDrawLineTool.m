#import "BTDrawLineTool.h"
#import "BTPointsContainer.h"
#import "BTPointer.h"
#import "NSWindow+BTEvents.h"

/* The line tool collects two points with a points creation tool. While the
   positioning option is held (by default it always is) the line is shown in a
   feedback layer and drawn into the image when collecting ends; otherwise it
   is drawn into the image continuously as the points move. The centering
   option makes the first point the line's center. */
@implementation BTDrawLineTool

static BOOL BTDrawLineToolIsCollecting(BTDrawLineTool *self)
{
    return [[self->_currentSubtool currentStage] isEqualToString:@"BTCollectingPointsToolStage"];
}

static BOOL BTDrawLineToolIsPositioning(BTDrawLineTool *self)
{
    return BTModifierFlagsMatchOption(self->_effectiveModifierFlags, self->_positioningOption);
}

static void BTDrawLineToolInvalidateFeedback(BTDrawLineTool *self)
{
    if (!NSIsEmptyRect(self->_feedbackInvalidationRect))
        [self->_view setNeedsDisplayInRect:self->_feedbackInvalidationRect];
}

/* After a change that leaves the line's extent alone: redraw the image, or
   the feedback while positioning. */
static void BTDrawLineToolRedisplay(BTDrawLineTool *self)
{
    if (!BTDrawLineToolIsPositioning(self))
        [self BTDrawLineTool_drawLineIntoImage];
    else if ([self isViewInvalidationEnabled])
        BTDrawLineToolInvalidateFeedback(self);
}

/* The same after a change of the line's extent. */
static void BTDrawLineToolRedisplayResized(BTDrawLineTool *self)
{
    if (!BTDrawLineToolIsPositioning(self)) {
        [self BTDrawLineTool_drawLineIntoImage];
    } else if ([self isViewInvalidationEnabled]) {
        BTDrawLineToolInvalidateFeedback(self);
        [self BTDrawLineTool_calculateFeedbackInvalidationRect];
        BTDrawLineToolInvalidateFeedback(self);
    }
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

/* Pressing or releasing the centering, alternate color or positioning option
   while dragging redraws the line; leaving positioning draws it into the
   image (as a continuous change), entering it shows it as feedback. */
- (void)trackFlagsChanged:(id)aEvent inView:(id)aView
{
    if (_view != aView)
        return;
    [[_delegate mouseTrackingDelegateForTool:self] trackFlagsChanged:aEvent inView:aView];
    NSUInteger oldFlags = _effectiveModifierFlags;
    NSUInteger flags = [(NSEvent *)aEvent modifierFlags];
    _effectiveModifierFlags = flags;
    BOOL centeringChanged = BTModifierFlagsMatchOption(oldFlags, _centeringOption) != BTModifierFlagsMatchOption(flags, _centeringOption);
    BOOL alternate = BTModifierFlagsMatchOption(flags, _alternateStrokeColorOption);
    BOOL alternateChanged = BTModifierFlagsMatchOption(oldFlags, _alternateStrokeColorOption) != alternate;
    BOOL wasPositioning = BTModifierFlagsMatchOption(oldFlags, _positioningOption);
    BOOL positioning = BTModifierFlagsMatchOption(flags, _positioningOption);
    if (_alternateStrokeColor != NULL && alternateChanged)
        [_pointsCreationTool setDoDragPointCursor:alternate ? [self doAlternateDrawCursor] : [self doDrawCursor]];
    else if (!centeringChanged && wasPositioning == positioning)
        return;
    if (!positioning) {
        if (![self isGroupingWorkImageUndo]) {
            [_delegate toolWillBeginChangingImageContinuously:self];
            [self beginWorkImageUndoGrouping];
        }
        [self BTDrawLineTool_drawLineIntoImage];
        return;
    }
    if (![self isViewInvalidationEnabled])
        return;
    if (wasPositioning)
        BTDrawLineToolInvalidateFeedback(self);
    if (!wasPositioning || centeringChanged) {
        [self BTDrawLineTool_calculateFeedbackInvalidationRect];
        BTDrawLineToolInvalidateFeedback(self);
    }
}

- (void)trackMouseUp:(id)aEvent inView:(id)aView
{
    if (_view != aView)
        return;
    [[_delegate mouseTrackingDelegateForTool:self] trackMouseUp:aEvent inView:aView];
    NSUInteger flags = [(NSEvent *)aEvent modifierFlags];
    _isUsingAlternateColor = BTModifierFlagsMatchOption(flags, _alternateStrokeColorOption);
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
    id cursor = (_isUsingAlternateColor && _alternateStrokeColor != NULL) ? [self doAlternateDrawCursor] : [self doDrawCursor];
    [_pointsCreationTool setDoDragPointCursor:cursor];
    _effectiveModifierFlags = [(NSEvent *)aEvent modifierFlags];
}

- (BOOL)flagsChanged:(id)aEvent
{
    NSUInteger flags = [(NSEvent *)aEvent modifierFlags];
    BOOL alternate = BTModifierFlagsMatchOption(flags, _alternateStrokeColorOption);
    BOOL picking = BTModifierFlagsMatchOption(flags, _colorPickingOption);
    if (alternate == (BOOL)_isUsingAlternateColor && picking == (BOOL)_isColorPicking)
        return NO;
    _isUsingAlternateColor = alternate;
    _isColorPicking = picking;
    [_delegate tool:self didUpdateCursorWithEvent:aEvent];
    return YES;
}

/* With the color picking option the click picks the (alternate) stroke color
   first; the points tool then handles it as usual. */
- (BOOL)mouseDown:(id)aEvent
{
    NSUInteger flags = [(NSEvent *)aEvent modifierFlags];
    _isUsingAlternateColor = BTModifierFlagsMatchOption(flags, _alternateStrokeColorOption);
    if (BTModifierFlagsMatchOption(flags, _colorPickingOption)) {
        id image = [self workImage];
        id color;
        if (image != nil && (color = (id)[image colorAtPoint:[self eventLocationInImage:aEvent]]) != nil) {
            NSString *key = _isUsingAlternateColor ? @"alternateStrokeColor" : @"strokeColor";
            [_delegate tool:self willUpdateOutputForKey:key];
            if (_isUsingAlternateColor)
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

- (void)tool:(id)aTool didUpdateOutputForKey:(id)aKey
{
    if (_currentSubtool != aTool || ![aKey isEqualToString:@"pointsArray"])
        return;
    id points = [_pointsCreationTool pointsArray];
    if ([points count] != 2)
        return;
    _startPoint = *(NSPoint *)[points bytesOfItemAtIndex:0];
    _endPoint = *(NSPoint *)[points bytesOfItemAtIndex:1];
    if (!BTDrawLineToolIsPositioning(self)) {
        [self BTDrawLineTool_drawLineIntoImage];
    } else if ([self isViewInvalidationEnabled]) {
        BTDrawLineToolInvalidateFeedback(self);
        [self BTDrawLineTool_calculateFeedbackInvalidationRect];
        BTDrawLineToolInvalidateFeedback(self);
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

/* Collecting points is this tool's drawing stage and one undo action; unless
   positioning, the line is drawn continuously in a work image undo group. */
- (BOOL)tool:(id)aTool didFinalizeStage:(id)aStage withEvent:(id)aEvent nextStage:(id)aNextStage
{
    if (_currentSubtool != aTool)
        return NO;
    if ([aNextStage isEqualToString:@"BTCollectingPointsToolStage"]) {
        [self beginUndoAction];
        if (!BTDrawLineToolIsPositioning(self)) {
            [_delegate toolWillBeginChangingImageContinuously:self];
            [self beginWorkImageUndoGrouping];
        }
        aNextStage = @"BTDrawingToolStage";
    }
    if ([aStage isEqualToString:@"BTCollectingPointsToolStage"]) {
        if (aNextStage == nil) {
            if (BTDrawLineToolIsPositioning(self))
                [self BTDrawLineTool_drawLineIntoImage];
            if ([self isGroupingWorkImageUndo]) {
                [self endWorkImageUndoGrouping];
                [_delegate toolDidEndChangingImageContinuously:self];
            }
            [self endUndoActionWithName:@"Draw Line"];
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

static BOOL BTDrawLineToolShowsFeedback(BTDrawLineTool *self)
{
    return BTDrawLineToolIsCollecting(self) && BTDrawLineToolIsPositioning(self);
}

- (BOOL)isFeedbackLayerActive:(id)aLayer
{
    return BTDrawLineToolShowsFeedback(self) && [aLayer isEqualToString:@"BTDrawingFeedbackLayer"];
}

- (id)activeFeedbackLayers
{
    if (BTDrawLineToolShowsFeedback(self))
        return [NSSet setWithObject:@"BTDrawingFeedbackLayer"];
    return [NSSet set];
}

- (id)activeFeedbackLayersForDrawing
{
    if (BTDrawLineToolShowsFeedback(self))
        return [NSArray arrayWithObject:@"BTDrawingFeedbackLayer"];
    return [NSArray array];
}

/* The line being positioned, drawn in the view as it will be in the image. */
- (void)draw_BTDrawingFeedbackLayer_Rect:(NSRect)aRect
{
    CGEColorRef color = [self BTDrawLineTool_effectiveStrokeColor];
    if (color == NULL)
        return;
    CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];
    if (context == NULL)
        return;
    CGContextSaveGState(context);
    CGContextConcatCTM(context, [self imageToViewTransform]);
    [self BTDrawLineTool_drawLineWithStartPoint:_startPoint endPoint:_endPoint withStrokeColor:color inContext:context];
    CGContextRestoreGState(context);
}

- (id)cursorForPoint:(NSPoint)aPoint modifierFlags:(NSUInteger)aFlags
{
    if (![_pointsCreationTool isTracking] && BTModifierFlagsMatchOption(aFlags, _colorPickingOption))
        return [self pickColorCursor];
    if (_alternateStrokeColor != NULL && BTModifierFlagsMatchOption(aFlags, _alternateStrokeColorOption))
        return [self willAlternateDrawCursor];
    return [self willDrawCursor];
}

- (id)currentStage
{
    if (BTDrawLineToolIsCollecting(self))
        return @"BTDrawingToolStage";
    return @"BTWaitingToolStage";
}

- (void)performDeactivate
{
    [_currentSubtool deactivate];
    _currentSubtool = nil;
    [super performDeactivate];
}

- (BOOL)activateWithDelegate:(id)aDelegate inView:(id)aView
{
    if (![super activateWithDelegate:aDelegate inView:aView])
        return NO;
    _currentSubtool = (BTTool *)_pointsCreationTool;
    if ([_currentSubtool activateWithDelegate:self inView:aView]) {
        NSUInteger flags = [[_view window] BT_effectiveModifierFlags];
        _isUsingAlternateColor = BTModifierFlagsMatchOption(flags, _alternateStrokeColorOption);
        _isColorPicking = BTModifierFlagsMatchOption(flags, _colorPickingOption);
        return YES;
    }
    _currentSubtool = nil;
    [super performDeactivate];
    return NO;
}

- (void)changeViewInvalidationEnabledTo:(BOOL)aEnabled
{
    [super changeViewInvalidationEnabledTo:aEnabled];
    _feedbackInvalidationRect = NSZeroRect;
    if (aEnabled && BTDrawLineToolShowsFeedback(self))
        [self BTDrawLineTool_calculateFeedbackInvalidationRect];
}

- (void)changeReferenceCGContextTo:(struct CGContext *)aContext
{
    [super changeReferenceCGContextTo:aContext];
    [_currentSubtool setReferenceCGContext:aContext];
}

- (void)changeWorkPasteboardTo:(id)aPasteboard
{
    [super changeWorkPasteboardTo:aPasteboard];
    [_currentSubtool setWorkPasteboard:aPasteboard];
}

- (id)outputKeys
{
    return [NSArray arrayWithObjects:@"strokeColor", @"alternateStrokeColor", nil];
}

- (id)inputKeys
{
    return [NSArray arrayWithObjects:@"generalKeyBindings", @"willDrawCursor", @"doDrawCursor", @"willAlternateDrawCursor",
            @"doAlternateDrawCursor", @"pickColorCursor", @"positioningOption", @"centeringOption", @"strokeColor",
            @"alternateStrokeColorOption", @"alternateStrokeColor", @"colorPickingOption", @"lineWidth", @"lineCap",
            @"lineDash", @"lineDashPhase", nil];
}

- (id *)requiredImageProtocols
{
    static id protocols[2];
    protocols[0] = @protocol(BTCGMutableImage);
    return protocols;
}

/* The dash is kept as the NSData of CGFloat lengths it comes in. */
- (void)setLineDash:(id)aDash
{
    if (_lineDash == aDash)
        return;
    [_lineDash release];
    _lineDash = [aDash copy];
    if (BTDrawLineToolIsCollecting(self))
        BTDrawLineToolRedisplay(self);
}

- (id)lineDash
{
    return _lineDash;
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
    if (BTDrawLineToolIsCollecting(self))
        BTDrawLineToolRedisplay(self);
}

- (CGFloat)lineDashPhase
{
    return _lineDashPhase;
}

- (CGFloat)defaultLineDashPhase
{
    return 0.0;
}

/* Unknown names mean round caps. */
- (void)setLineCap:(id)aCap
{
    CGLineCap cap;
    if ([aCap isEqualToString:@"BTLineCapButt"])
        cap = kCGLineCapButt;
    else if ([aCap isEqualToString:@"BTLineCapSquare"])
        cap = kCGLineCapSquare;
    else
        cap = kCGLineCapRound;
    if (_lineCap == cap)
        return;
    _lineCap = cap;
    if (BTDrawLineToolIsCollecting(self))
        BTDrawLineToolRedisplayResized(self);
}

- (id)lineCap
{
    return [self BTDrawLineTool_nameForCGLineCap:_lineCap];
}

- (id)defaultLineCap
{
    return [self BTDrawLineTool_nameForCGLineCap:kCGLineCapRound];
}

- (id)BTDrawLineTool_nameForCGLineCap:(NSInteger)aCap
{
    if (aCap == kCGLineCapSquare)
        return @"BTLineCapSquare";
    if (aCap == kCGLineCapRound)
        return @"BTLineCapRound";
    return @"BTLineCapButt";
}

- (void)setLineWidth:(CGFloat)aWidth
{
    if (_lineWidth == aWidth)
        return;
    _lineWidth = aWidth;
    if (BTDrawLineToolIsCollecting(self))
        BTDrawLineToolRedisplayResized(self);
}

- (CGFloat)lineWidth
{
    return _lineWidth;
}

- (CGFloat)defaultLineWidth
{
    return 1.0;
}

/* Colors come in as CGColors or as BTPointer-wrapped CGEColors. Returns NO
   when aColor equals the current one. */
static BOOL BTDrawLineToolReplaceColor(CGEColorRef *aSlot, id aColor)
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

static BOOL BTDrawLineToolUsesAlternateColor(BTDrawLineTool *self)
{
    return self->_alternateStrokeColor != NULL
        && BTModifierFlagsMatchOption(self->_effectiveModifierFlags, self->_alternateStrokeColorOption);
}

- (void)setAlternateStrokeColor:(id)aColor
{
    if (!BTDrawLineToolReplaceColor(&_alternateStrokeColor, aColor))
        return;
    if (BTDrawLineToolIsCollecting(self) && BTModifierFlagsMatchOption(_effectiveModifierFlags, _alternateStrokeColorOption))
        BTDrawLineToolRedisplay(self);
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

/* A change of the option matters only when it changes which color is used. */
- (void)setAlternateStrokeColorOption:(NSUInteger)aOption
{
    NSUInteger old = _alternateStrokeColorOption;
    if (old == aOption)
        return;
    _alternateStrokeColorOption = aOption;
    if (BTDrawLineToolIsCollecting(self) && _alternateStrokeColor != NULL
        && BTModifierFlagsMatchOption(_effectiveModifierFlags, old) != BTModifierFlagsMatchOption(_effectiveModifierFlags, aOption))
        BTDrawLineToolRedisplay(self);
}

- (NSUInteger)alternateStrokeColorOption
{
    return _alternateStrokeColorOption;
}

- (NSUInteger)defaultAlternateStrokeColorOption
{
    return NSEventModifierFlagOption;
}

- (void)setStrokeColor:(id)aColor
{
    _isStrokeColorInitialized = 1;
    if (!BTDrawLineToolReplaceColor(&_strokeColor, aColor))
        return;
    if (BTDrawLineToolIsCollecting(self) && !BTDrawLineToolUsesAlternateColor(self))
        BTDrawLineToolRedisplay(self);
}

- (id)strokeColor
{
    if ([self BTDrawLineTool_strokeColor] == NULL)
        return nil;
    id wrapper = [BTPointer wrapperForPointer:_strokeColor withDisposer:CGEColorRelease];
    if (wrapper != nil)
        CGEColorRetain(_strokeColor);
    return wrapper;
}

- (id)defaultStrokeColor
{
    CGEColorRef color = [self BTDrawLineTool_createDefaultStrokeColor];
    if (color == NULL)
        return nil;
    id wrapper = [BTPointer wrapperForPointer:color withDisposer:CGEColorRelease];
    if (wrapper == nil)
        CGEColorRelease(color);
    return wrapper;
}

- (void)setCenteringOption:(NSUInteger)aOption
{
    NSUInteger old = _centeringOption;
    if (old == aOption)
        return;
    _centeringOption = aOption;
    if (BTDrawLineToolIsCollecting(self)
        && BTModifierFlagsMatchOption(_effectiveModifierFlags, old) != BTModifierFlagsMatchOption(_effectiveModifierFlags, aOption))
        BTDrawLineToolRedisplayResized(self);
}

- (NSUInteger)centeringOption
{
    return _centeringOption;
}

/* No modifier combination matches it, so lines are not centered. */
- (NSUInteger)defaultCenteringOption
{
    return NSUIntegerMax;
}

/* Leaving positioning draws the line into the image and clears the feedback;
   entering it shows the feedback. */
- (void)setPositioningOption:(NSUInteger)aOption
{
    NSUInteger old = _positioningOption;
    if (old == aOption)
        return;
    _positioningOption = aOption;
    BOOL positioning = BTModifierFlagsMatchOption(_effectiveModifierFlags, aOption);
    if (!BTDrawLineToolIsCollecting(self) || BTModifierFlagsMatchOption(_effectiveModifierFlags, old) == positioning)
        return;
    BOOL invalidate = [self isViewInvalidationEnabled];
    if (positioning) {
        if (!invalidate)
            return;
        [self BTDrawLineTool_calculateFeedbackInvalidationRect];
    } else {
        [self BTDrawLineTool_drawLineIntoImage];
        if (!invalidate)
            return;
    }
    BTDrawLineToolInvalidateFeedback(self);
}

- (NSUInteger)positioningOption
{
    return _positioningOption;
}

/* Matched by any modifier flags: lines are positioned before drawing. */
- (NSUInteger)defaultPositioningOption
{
    return 0;
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
    return [_pointsCreationTool defaultDoDragPointCursor];
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

- (void)BTDrawLineTool_drawLineIntoImage
{
    CGEColorRef color = [self BTDrawLineTool_effectiveStrokeColor];
    if (color == NULL)
        return;
    id image = [self workImage];
    if (image == nil)
        return;
    CGRect r = [self BTDrawLineTool_changedImageRectForLineWithStartPoint:_startPoint endPoint:_endPoint];
    r = CGRectIntersection(r, (CGRect){ CGPointZero, [image imageSize] });
    if (CGRectIsEmpty(r))
        return;
    [self preEditWorkImage:image inRect:r];
    [image beginCGEditing];
    CGContextRef context = [image imageCGContext];
    if (context != NULL)
        [self BTDrawLineTool_drawLineWithStartPoint:_startPoint endPoint:_endPoint withStrokeColor:color inContext:context];
    [image endCGEditing];
    [self postEditWorkImageInRect:r];
}

/* The line is stroked into a path and filled in a space rotated along it,
   where its bounds (with the caps) are a simple rect. While centering, the
   start point is the line's center. */
- (void)BTDrawLineTool_drawLineWithStartPoint:(NSPoint)aStart endPoint:(NSPoint)aEnd withStrokeColor:(struct CGEColor *)aColor inContext:(struct CGContext *)aContext
{
    if (BTModifierFlagsMatchOption(_effectiveModifierFlags, _centeringOption)) {
        aStart.x += aStart.x - aEnd.x;
        aStart.y += aStart.y - aEnd.y;
    }
    CGContextSetLineWidth(aContext, _lineWidth);
    CGContextSetLineCap(aContext, _lineCap);
    CGContextSetLineDash(aContext, _lineDashPhase, [_lineDash bytes], [_lineDash length] / sizeof(CGFloat));
    CGContextBeginPath(aContext);
    CGContextMoveToPoint(aContext, aStart.x, aStart.y);
    CGContextAddLineToPoint(aContext, aEnd.x, aEnd.y);
    CGContextReplacePathWithStrokedPath(aContext);
    CGFloat dx = aEnd.x - aStart.x, dy = aEnd.y - aStart.y;
    CGFloat angle = atan2(dy, dx);
    CGFloat c = cos(angle), s = sin(angle);
    CGContextConcatCTM(aContext, CGAffineTransformMake(c, s, -s, c, aStart.x, aStart.y));
    CGFloat length = hypot(dx, dy);
    CGRect bounds = CGRectMake(0.0, -_lineWidth * 0.5, length, _lineWidth);
    if (_lineCap == kCGLineCapRound || _lineCap == kCGLineCapSquare) {
        bounds.origin.x = -_lineWidth * 0.5;
        bounds.size.width = length + _lineWidth;
    } else if (_lineCap != kCGLineCapButt) {
        CFShow(CFSTR("Unknown line cap style."));
    }
    CGEContextFillPathWithColor(aContext, NULL, bounds, aColor);
}

- (struct CGEColor *)BTDrawLineTool_effectiveStrokeColor
{
    if (BTDrawLineToolUsesAlternateColor(self))
        return _alternateStrokeColor;
    return [self BTDrawLineTool_strokeColor];
}

- (struct CGEColor *)BTDrawLineTool_strokeColor
{
    if (!_isStrokeColorInitialized) {
        _strokeColor = [self BTDrawLineTool_createDefaultStrokeColor];
        _isStrokeColorInitialized = 1;
    }
    return _strokeColor;
}

/* Opaque black. */
- (struct CGEColor *)BTDrawLineTool_createDefaultStrokeColor
{
    CGColorSpaceRef space = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
    if (space == NULL)
        return NULL;
    const CGFloat components[4] = { 0.0, 0.0, 0.0, 1.0 };
    CGEColorRef color = CGEColorCreateSolid(space, components);
    CGColorSpaceRelease(space);
    return color;
}

- (void)BTDrawLineTool_calculateFeedbackInvalidationRect
{
    CGRect r = [self BTDrawLineTool_changedImageRectForLineWithStartPoint:_startPoint endPoint:_endPoint];
    _feedbackInvalidationRect = NSIntegralRect([self convertImageRectToViewRect:r]);
}

- (NSRect)BTDrawLineTool_changedImageRectForLineWithStartPoint:(NSPoint)aStart endPoint:(NSPoint)aEnd
{
    if (BTModifierFlagsMatchOption(_effectiveModifierFlags, _centeringOption)) {
        aStart.x += aStart.x - aEnd.x;
        aStart.y += aStart.y - aEnd.y;
    }
    CGFloat pad = _lineWidth * 0.5 + 0.05;
    CGRect r = CGRectMake(MIN(aStart.x, aEnd.x) - pad, MIN(aStart.y, aEnd.y) - pad,
                          fabs(aEnd.x - aStart.x) + 2.0 * pad, fabs(aEnd.y - aStart.y) + 2.0 * pad);
    return CGRectIntegral(r);
}

- (void)dealloc
{
    [_pointsCreationTool release];
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

/* Two points, dragged; the second is corrected to horizontal, vertical or
   diagonal lines. */
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
    [_pointsCreationTool setCorrectionMode:@"BTCorrectionModeHorizontalVerticalDiagonal"];
    _positioningOption = 0;
    _centeringOption = NSUIntegerMax;
    _alternateStrokeColorOption = NSEventModifierFlagOption;
    _colorPickingOption = NSEventModifierFlagCommand;
    _lineWidth = 1.0;
    _lineCap = kCGLineCapRound;
    return self;
}

@end
