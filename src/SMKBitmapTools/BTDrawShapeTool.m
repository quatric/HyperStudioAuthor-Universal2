#import "BTDrawShapeTool.h"
#import "BTCreateShapeSelectionTool.h"
#import "BTPointer.h"
#import "NSWindow+BTEvents.h"

/* The shape tool lets a shape selection tool create the shape (the prototype
   path fitted to a dragged rect) and strokes and fills it into the image.
   While the positioning option is held (by default it always is) the shape is
   shown in a feedback layer and drawn when creating ends; otherwise it is
   drawn into the image continuously. */
@implementation BTDrawShapeTool

static BOOL BTDrawShapeToolIsCreating(BTDrawShapeTool *self)
{
    return [[self->_currentSubtool currentStage] isEqualToString:@"BTCreatingSelectionToolStage"];
}

static BOOL BTDrawShapeToolIsPositioning(BTDrawShapeTool *self)
{
    return BTModifierFlagsMatchOption(self->_effectiveModifierFlags, self->_positioningOption);
}

- (BOOL)canProvideSelectedShape
{
    if ([_delegate respondsToSelector:@selector(canProvideSelectedShape)]
        && [_delegate respondsToSelector:@selector(provideSelectionPath:withOrientedRectTransform:)])
        return [_delegate canProvideSelectedShape];
    return NO;
}

- (void)provideSelectionPath:(struct CGPath *)aPath withOrientedRectTransform:(CGAffineTransform)aTransform
{
    if ([_delegate respondsToSelector:@selector(provideSelectionPath:withOrientedRectTransform:)])
        [_delegate provideSelectionPath:aPath withOrientedRectTransform:aTransform];
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

/* The cursor of the color in use; the alternate one only when there is a
   stroke to draw. */
static id BTDrawShapeToolDoDrawCursor(BTDrawShapeTool *self, BOOL aAlternate)
{
    if (aAlternate && self->_lineWidth > 0.0)
        return [self doAlternateDrawCursor];
    return [self doDrawCursor];
}

/* Pressing or releasing an alternate color option (when that color is set)
   or the positioning option while dragging redraws the shape; out of
   positioning it is drawn into the image as a continuous change. */
- (void)trackFlagsChanged:(id)aEvent inView:(id)aView
{
    if (_view != aView)
        return;
    [[_delegate mouseTrackingDelegateForTool:self] trackFlagsChanged:aEvent inView:aView];
    NSUInteger oldFlags = _effectiveModifierFlags;
    NSUInteger flags = [(NSEvent *)aEvent modifierFlags];
    _effectiveModifierFlags = flags;
    BOOL alternateStroke = BTModifierFlagsMatchOption(flags, _alternateStrokeColorOption);
    BOOL alternateStrokeChanged = BTModifierFlagsMatchOption(oldFlags, _alternateStrokeColorOption) != alternateStroke;
    BOOL alternateFillChanged = BTModifierFlagsMatchOption(oldFlags, _alternateFillColorOption) != BTModifierFlagsMatchOption(flags, _alternateFillColorOption);
    BOOL positioning = BTModifierFlagsMatchOption(flags, _positioningOption);
    BOOL positioningChanged = BTModifierFlagsMatchOption(oldFlags, _positioningOption) != positioning;
    if (_alternateStrokeColor != NULL && alternateStrokeChanged)
        [_createShapeSelectionTool setDoCreateSelectionCursor:BTDrawShapeToolDoDrawCursor(self, alternateStroke)];
    else if (!(alternateFillChanged && _alternateFillColor != NULL) && !positioningChanged)
        return;
    if (positioning) {
        if ([self isViewInvalidationEnabled])
            [self BTDrawShapeTool_setNeedsDisplayShapePath];
        return;
    }
    if (![self isGroupingWorkImageUndo]) {
        [_delegate toolWillBeginChangingImageContinuously:self];
        [self beginWorkImageUndoGrouping];
    }
    [self BTDrawShapeTool_drawShapePathIntoImage];
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
    [_createShapeSelectionTool setDoCreateSelectionCursor:BTDrawShapeToolDoDrawCursor(self, _isUsingAlternateColor && _alternateStrokeColor != NULL)];
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

/* With the color picking option (and a stroke to draw) the click picks the
   (alternate) stroke color first; the selection tool then handles it. */
- (BOOL)mouseDown:(id)aEvent
{
    NSUInteger flags = [(NSEvent *)aEvent modifierFlags];
    _isUsingAlternateColor = BTModifierFlagsMatchOption(flags, _alternateStrokeColorOption);
    if (_lineWidth > 0.0 && BTModifierFlagsMatchOption(flags, _colorPickingOption)) {
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

- (id)cursorForPoint:(NSPoint)aPoint modifierFlags:(NSUInteger)aFlags
{
    if (_lineWidth <= 0.0)
        return [self willDrawCursor];
    if (![_createShapeSelectionTool isTracking] && BTModifierFlagsMatchOption(aFlags, _colorPickingOption))
        return [self pickColorCursor];
    if (_alternateStrokeColor != NULL && BTModifierFlagsMatchOption(aFlags, _alternateStrokeColorOption))
        return [self willAlternateDrawCursor];
    return [self willDrawCursor];
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
    if (_currentSubtool != aTool || ![aKey isEqualToString:@"selectionPath"])
        return;
    if (!BTDrawShapeToolIsPositioning(self))
        [self BTDrawShapeTool_drawShapePathIntoImage];
    else if ([self isViewInvalidationEnabled])
        [self BTDrawShapeTool_setNeedsDisplayShapePath];
}

/* The feedback where the shape was. */
- (void)tool:(id)aTool willUpdateOutputForKey:(id)aKey
{
    if (_currentSubtool == aTool && [aKey isEqualToString:@"selectionPath"] && BTDrawShapeToolIsPositioning(self)
        && [self isViewInvalidationEnabled])
        [self BTDrawShapeTool_setNeedsDisplayShapePath];
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

/* Creating the shape is this tool's drawing stage and one undo action;
   unless positioning, the shape is drawn continuously in a work image undo
   group. */
- (BOOL)tool:(id)aTool didFinalizeStage:(id)aStage withEvent:(id)aEvent nextStage:(id)aNextStage
{
    if (_currentSubtool != aTool)
        return NO;
    if ([aNextStage isEqualToString:@"BTCreatingSelectionToolStage"]) {
        [self beginUndoAction];
        if (!BTDrawShapeToolIsPositioning(self)) {
            [_delegate toolWillBeginChangingImageContinuously:self];
            [self beginWorkImageUndoGrouping];
        }
        aNextStage = @"BTDrawingToolStage";
    }
    if ([aStage isEqualToString:@"BTCreatingSelectionToolStage"]) {
        if (aNextStage == nil) {
            if (BTDrawShapeToolIsPositioning(self))
                [self BTDrawShapeTool_drawShapePathIntoImage];
            if ([self isGroupingWorkImageUndo]) {
                [self endWorkImageUndoGrouping];
                [_delegate toolDidEndChangingImageContinuously:self];
            }
            [self endUndoActionWithName:@"Draw Shape"];
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

static BOOL BTDrawShapeToolShowsFeedback(BTDrawShapeTool *self)
{
    return BTDrawShapeToolIsCreating(self) && BTDrawShapeToolIsPositioning(self);
}

- (BOOL)isFeedbackLayerActive:(id)aLayer
{
    return BTDrawShapeToolShowsFeedback(self) && [aLayer isEqualToString:@"BTDrawingFeedbackLayer"];
}

- (id)activeFeedbackLayers
{
    if (BTDrawShapeToolShowsFeedback(self))
        return [NSSet setWithObject:@"BTDrawingFeedbackLayer"];
    return [NSSet set];
}

- (id)activeFeedbackLayersForDrawing
{
    if (BTDrawShapeToolShowsFeedback(self))
        return [NSArray arrayWithObject:@"BTDrawingFeedbackLayer"];
    return [NSArray array];
}

/* The shape being positioned, drawn in the view as it will be in the image. */
- (void)draw_BTDrawingFeedbackLayer_Rect:(NSRect)aRect
{
    CGEColorRef stroke = [self BTDrawShapeTool_effectiveStrokeColor];
    CGEColorRef fill = [self BTDrawShapeTool_effectiveFillColor];
    if (stroke == NULL && fill == NULL)
        return;
    CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];
    if (context == NULL)
        return;
    id path = [(BTCreateShapeSelectionTool *)_currentSubtool selectionPath];
    if (path == nil)
        return;
    CGRect bounds = CGEPathGetPathBoundingBox((CGPathRef)path);
    if (CGRectIsEmpty(bounds))
        return;
    CGContextSaveGState(context);
    CGContextConcatCTM(context, [self imageToViewTransform]);
    [self BTDrawShapeTool_drawShapePath:(struct CGPath *)path withBounds:bounds strokeColor:stroke fillColor:fill inContext:context];
    CGContextRestoreGState(context);
}

- (id)currentStage
{
    if ([[_createShapeSelectionTool currentStage] isEqualToString:@"BTCreatingSelectionToolStage"])
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
    _currentSubtool = (BTTool *)_createShapeSelectionTool;
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

- (void)changeReferenceCGContextTo:(struct CGContext *)aContext
{
    [super changeReferenceCGContextTo:aContext];
    [_createShapeSelectionTool setReferenceCGContext:aContext];
}

- (void)changeWorkPasteboardTo:(id)aPasteboard
{
    [super changeWorkPasteboardTo:aPasteboard];
    [_createShapeSelectionTool setWorkPasteboard:aPasteboard];
}

- (id)outputKeys
{
    return [NSArray arrayWithObjects:@"strokeColor", @"alternateStrokeColor", nil];
}

- (id)inputKeys
{
    return [NSArray arrayWithObjects:@"generalKeyBindings", @"shapePrototypePath", @"willDrawCursor", @"doDrawCursor",
            @"willAlternateDrawCursor", @"doAlternateDrawCursor", @"pickColorCursor", @"positioningOption",
            @"centeringOption", @"strokeColor", @"alternateStrokeColorOption", @"alternateStrokeColor",
            @"colorPickingOption", @"fillColor", @"alternateFillColorOption", @"alternateFillColor", @"lineWidth",
            @"lineJoin", @"lineDash", @"lineDashPhase", nil];
}

- (id *)requiredImageProtocols
{
    static id protocols[2];
    protocols[0] = @protocol(BTCGMutableImage);
    return protocols;
}

- (void)setShapeLineCount:(NSUInteger)aCount
{
    if (_shapeLineCount == aCount)
        return;
    _shapeLineCount = aCount;
    if (BTDrawShapeToolIsCreating(self))
        [self BTDrawShapeTool_shapeDidChange];
}

- (NSUInteger)shapeLineCount
{
    return _shapeLineCount;
}

- (NSUInteger)defaultShapeLineCount
{
    return 0;
}

- (void)setShapePrototypePath:(id)aPath
{
    [_createShapeSelectionTool setSelectionShapePrototypePath:aPath];
}

- (id)shapePrototypePath
{
    return [_createShapeSelectionTool selectionShapePrototypePath];
}

- (id)defaultShapePrototypePath
{
    return [_createShapeSelectionTool defaultSelectionShapePrototypePath];
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
    if (BTDrawShapeToolIsCreating(self))
        [self BTDrawShapeTool_shapeDidChange];
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
    if (BTDrawShapeToolIsCreating(self))
        [self BTDrawShapeTool_shapeDidChange];
}

- (CGFloat)lineDashPhase
{
    return _lineDashPhase;
}

- (CGFloat)defaultLineDashPhase
{
    return 0.0;
}

/* Unknown names mean round joins. */
- (void)setLineJoin:(id)aJoin
{
    CGLineJoin join;
    if ([aJoin isEqualToString:@"BTLineJoinMiter"])
        join = kCGLineJoinMiter;
    else if ([aJoin isEqualToString:@"BTLineJoinBevel"])
        join = kCGLineJoinBevel;
    else
        join = kCGLineJoinRound;
    if (_lineJoin == join)
        return;
    _lineJoin = join;
    if (BTDrawShapeToolIsCreating(self))
        [self BTDrawShapeTool_shapeDidChange];
}

- (id)lineJoin
{
    return [self BTDrawShapeTool_nameForCGLineJoin:_lineJoin];
}

- (id)defaultLineJoin
{
    return [self BTDrawShapeTool_nameForCGLineJoin:kCGLineJoinRound];
}

- (id)BTDrawShapeTool_nameForCGLineJoin:(NSInteger)aJoin
{
    switch (aJoin) {
    case kCGLineJoinMiter:
        return @"BTLineJoinMiter";
    case kCGLineJoinRound:
        return @"BTLineJoinRound";
    case kCGLineJoinBevel:
        return @"BTLineJoinBevel";
    default:
        return nil;
    }
}

- (void)setLineWidth:(CGFloat)aWidth
{
    if (_lineWidth == aWidth)
        return;
    _lineWidth = aWidth;
    if (BTDrawShapeToolIsCreating(self))
        [self BTDrawShapeTool_shapeDidChange];
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
static BOOL BTDrawShapeToolReplaceColor(CGEColorRef *aSlot, id aColor)
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

static id BTDrawShapeToolWrapColor(CGEColorRef aColor)
{
    if (aColor == NULL)
        return nil;
    id wrapper = [BTPointer wrapperForPointer:aColor withDisposer:CGEColorRelease];
    if (wrapper != nil)
        CGEColorRetain(aColor);
    return wrapper;
}

static id BTDrawShapeToolWrapNewColor(CGEColorRef aColor)
{
    if (aColor == NULL)
        return nil;
    id wrapper = [BTPointer wrapperForPointer:aColor withDisposer:CGEColorRelease];
    if (wrapper == nil)
        CGEColorRelease(aColor);
    return wrapper;
}

/* Whether an alternate color option change switches the color in use. */
static BOOL BTDrawShapeToolOptionChangeMatters(BTDrawShapeTool *self, NSUInteger aOld, NSUInteger aNew)
{
    return BTModifierFlagsMatchOption(self->_effectiveModifierFlags, aOld) != BTModifierFlagsMatchOption(self->_effectiveModifierFlags, aNew);
}

- (void)setAlternateFillColor:(id)aColor
{
    if (BTDrawShapeToolReplaceColor(&_alternateFillColor, aColor) && BTDrawShapeToolIsCreating(self)
        && BTModifierFlagsMatchOption(_effectiveModifierFlags, _alternateFillColorOption))
        [self BTDrawShapeTool_shapeDidChange];
}

- (id)alternateFillColor
{
    return BTDrawShapeToolWrapColor(_alternateFillColor);
}

- (void)setAlternateFillColorOption:(NSUInteger)aOption
{
    NSUInteger old = _alternateFillColorOption;
    if (old == aOption)
        return;
    _alternateFillColorOption = aOption;
    if (BTDrawShapeToolIsCreating(self) && _alternateFillColor != NULL && BTDrawShapeToolOptionChangeMatters(self, old, aOption))
        [self BTDrawShapeTool_shapeDidChange];
}

- (NSUInteger)alternateFillColorOption
{
    return _alternateFillColorOption;
}

- (NSUInteger)defaultAlternateFillColorOption
{
    return NSEventModifierFlagOption;
}

- (void)setFillColor:(id)aColor
{
    _isFillColorInitialized = 1;
    if (!BTDrawShapeToolReplaceColor(&_fillColor, aColor) || !BTDrawShapeToolIsCreating(self))
        return;
    if (_alternateFillColor == NULL || !BTModifierFlagsMatchOption(_effectiveModifierFlags, _alternateFillColorOption))
        [self BTDrawShapeTool_shapeDidChange];
}

- (id)fillColor
{
    return BTDrawShapeToolWrapColor([self BTDrawShapeTool_fillColor]);
}

- (id)defaultFillColor
{
    return BTDrawShapeToolWrapNewColor([self BTDrawShapeTool_createDefaultFillColor]);
}

- (void)setAlternateStrokeColor:(id)aColor
{
    if (BTDrawShapeToolReplaceColor(&_alternateStrokeColor, aColor) && BTDrawShapeToolIsCreating(self)
        && BTModifierFlagsMatchOption(_effectiveModifierFlags, _alternateStrokeColorOption))
        [self BTDrawShapeTool_shapeDidChange];
}

- (id)alternateStrokeColor
{
    return BTDrawShapeToolWrapColor(_alternateStrokeColor);
}

- (void)setAlternateStrokeColorOption:(NSUInteger)aOption
{
    NSUInteger old = _alternateStrokeColorOption;
    if (old == aOption)
        return;
    _alternateStrokeColorOption = aOption;
    if (BTDrawShapeToolIsCreating(self) && _alternateStrokeColor != NULL && BTDrawShapeToolOptionChangeMatters(self, old, aOption))
        [self BTDrawShapeTool_shapeDidChange];
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
    if (!BTDrawShapeToolReplaceColor(&_strokeColor, aColor) || !BTDrawShapeToolIsCreating(self))
        return;
    if (_alternateStrokeColor == NULL || !BTModifierFlagsMatchOption(_effectiveModifierFlags, _alternateStrokeColorOption))
        [self BTDrawShapeTool_shapeDidChange];
}

- (id)strokeColor
{
    return BTDrawShapeToolWrapColor([self BTDrawShapeTool_strokeColor]);
}

- (id)defaultStrokeColor
{
    return BTDrawShapeToolWrapNewColor([self BTDrawShapeTool_createDefaultStrokeColor]);
}

- (void)setCenteringOption:(NSUInteger)aOption
{
    [_createShapeSelectionTool setCenteringOption:aOption];
}

- (NSUInteger)centeringOption
{
    return [_createShapeSelectionTool centeringOption];
}

- (NSUInteger)defaultCenteringOption
{
    return [_createShapeSelectionTool defaultCenteringOption];
}

/* Leaving positioning draws the shape into the image; either way the
   feedback is redisplayed. */
- (void)setPositioningOption:(NSUInteger)aOption
{
    NSUInteger old = _positioningOption;
    if (old == aOption)
        return;
    _positioningOption = aOption;
    if (!BTDrawShapeToolIsCreating(self) || !BTDrawShapeToolOptionChangeMatters(self, old, aOption))
        return;
    if (!BTModifierFlagsMatchOption(_effectiveModifierFlags, aOption))
        [self BTDrawShapeTool_drawShapePathIntoImage];
    if ([self isViewInvalidationEnabled])
        [self BTDrawShapeTool_setNeedsDisplayShapePath];
}

- (NSUInteger)positioningOption
{
    return _positioningOption;
}

/* Matched by any modifier flags: shapes are positioned before drawing. */
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
    return [_createShapeSelectionTool defaultDoCreateSelectionCursor];
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
    return [_createShapeSelectionTool defaultWillCreateSelectionCursor];
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
    return [_createShapeSelectionTool defaultDoCreateSelectionCursor];
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
    return [_createShapeSelectionTool defaultWillCreateSelectionCursor];
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
    [_createShapeSelectionTool release];
    CGEColorRelease(_strokeColor);
    CGEColorRelease(_alternateStrokeColor);
    CGEColorRelease(_fillColor);
    CGEColorRelease(_alternateFillColor);
    [_lineDash release];
    [_willDrawCursor release];
    [_doDrawCursor release];
    [_willAlternateDrawCursor release];
    [_doAlternateDrawCursor release];
    [_pickColorCursor release];
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self == nil)
        return nil;
    _createShapeSelectionTool = [BTCreateShapeSelectionTool new];
    if (_createShapeSelectionTool == nil) {
        [self release];
        return nil;
    }
    [_createShapeSelectionTool setViewInvalidationEnabled:NO];
    _positioningOption = 0;
    _alternateStrokeColorOption = NSEventModifierFlagOption;
    _alternateFillColorOption = NSEventModifierFlagOption;
    _colorPickingOption = NSEventModifierFlagCommand;
    _lineWidth = 1.0;
    _lineJoin = kCGLineJoinRound;
    _shapeLineCount = 0;
    return self;
}

/* Redraws the image, or the feedback while positioning. */
- (void)BTDrawShapeTool_shapeDidChange
{
    if (!BTDrawShapeToolIsPositioning(self))
        [self BTDrawShapeTool_drawShapePathIntoImage];
    else if ([self isViewInvalidationEnabled])
        [self BTDrawShapeTool_setNeedsDisplayShapePath];
}

- (void)BTDrawShapeTool_drawShapePathIntoImage
{
    CGEColorRef stroke = [self BTDrawShapeTool_effectiveStrokeColor];
    CGEColorRef fill = [self BTDrawShapeTool_effectiveFillColor];
    if (stroke == NULL && fill == NULL)
        return;
    id path = [(BTCreateShapeSelectionTool *)_currentSubtool selectionPath];
    if (path == nil)
        return;
    CGRect bounds = CGEPathGetPathBoundingBox((CGPathRef)path);
    if (CGRectIsEmpty(bounds))
        return;
    CGRect r = CGRectInset(bounds, -0.05, -0.05);
    r = CGRectIntersection(r, (CGRect){ CGPointZero, [[self workImage] imageSize] });
    id image;
    if (CGRectIsEmpty(r) || (image = [self workImage]) == nil)
        return;
    [self beginUndoAction];
    [self preEditWorkImage:image inRect:r];
    [image beginCGEditing];
    CGContextRef context = [image imageCGContext];
    if (context != NULL)
        [self BTDrawShapeTool_drawShapePath:(struct CGPath *)path withBounds:bounds strokeColor:stroke fillColor:fill inContext:context];
    [image endCGEditing];
    [self postEditWorkImageInRect:r];
    [self endUndoActionWithName:@"Draw Shape"];
}

/* The path is scaled into the bounds inset by half the line width (the width
   shrinks when the lines wouldn't fit), filled, then stroked. */
- (void)BTDrawShapeTool_drawShapePath:(struct CGPath *)aPath withBounds:(CGRect)aBounds strokeColor:(struct CGEColor *)aStroke fillColor:(struct CGEColor *)aFill inContext:(struct CGContext *)aContext
{
    CGMutablePathRef path = CGPathCreateMutable();
    if (path == NULL)
        return;
    CGFloat lineWidth = _lineWidth;
    if (_shapeLineCount != 0) {
        CGFloat inset = lineWidth * 0.5 * (CGFloat)_shapeLineCount;
        if (CGRectIsEmpty(CGRectInset(aBounds, inset, inset)))
            lineWidth = fmin(aBounds.size.width, aBounds.size.height) / (CGFloat)_shapeLineCount - 0.0001;
    }
    CGRect inner = CGRectInset(aBounds, lineWidth * 0.5, lineWidth * 0.5);
    CGAffineTransform m;
    m.a = aBounds.size.width != 0.0 ? inner.size.width / aBounds.size.width : 1.0;
    m.d = aBounds.size.height != 0.0 ? inner.size.height / aBounds.size.height : 1.0;
    m.b = 0.0;
    m.c = 0.0;
    m.tx = inner.origin.x - aBounds.origin.x * m.a;
    m.ty = inner.origin.y - aBounds.origin.y * m.d;
    CGPathAddPath(path, &m, aPath);
    CGContextSetLineWidth(aContext, lineWidth);
    CGContextSetLineJoin(aContext, _lineJoin);
    CGContextSetLineDash(aContext, _lineDashPhase, [_lineDash bytes], [_lineDash length] / sizeof(CGFloat));
    if (aFill != NULL) {
        CGContextBeginPath(aContext);
        CGContextAddPath(aContext, path);
        if (CGEContextSetFillColorWithColor(aContext, NULL, inner, aFill)) {
            CGContextFillPath(aContext);
        } else if (aStroke != NULL) {
            /* A gradient fill clips; keep the path for the stroke. */
            CGContextSaveGState(aContext);
            CGEContextFillPathWithColor(aContext, NULL, inner, aFill);
            CGContextRestoreGState(aContext);
        } else {
            CGEContextFillPathWithColor(aContext, NULL, inner, aFill);
        }
    }
    if (aStroke != NULL) {
        CGContextBeginPath(aContext);
        CGContextAddPath(aContext, path);
        CGEContextStrokePathWithColor(aContext, NULL, inner, aStroke);
    }
    CGPathRelease(path);
}

- (struct CGEColor *)BTDrawShapeTool_effectiveFillColor
{
    if (_alternateFillColor != NULL && BTModifierFlagsMatchOption(_effectiveModifierFlags, _alternateFillColorOption))
        return _alternateFillColor;
    return [self BTDrawShapeTool_fillColor];
}

- (struct CGEColor *)BTDrawShapeTool_fillColor
{
    if (!_isFillColorInitialized) {
        _fillColor = [self BTDrawShapeTool_createDefaultFillColor];
        _isFillColorInitialized = 1;
    }
    return _fillColor;
}

/* No fill. */
- (struct CGEColor *)BTDrawShapeTool_createDefaultFillColor
{
    return NULL;
}

- (struct CGEColor *)BTDrawShapeTool_effectiveStrokeColor
{
    if (_alternateStrokeColor != NULL && BTModifierFlagsMatchOption(_effectiveModifierFlags, _alternateStrokeColorOption))
        return _alternateStrokeColor;
    return [self BTDrawShapeTool_strokeColor];
}

- (struct CGEColor *)BTDrawShapeTool_strokeColor
{
    if (!_isStrokeColorInitialized) {
        _strokeColor = [self BTDrawShapeTool_createDefaultStrokeColor];
        _isStrokeColorInitialized = 1;
    }
    return _strokeColor;
}

/* Opaque black. */
- (struct CGEColor *)BTDrawShapeTool_createDefaultStrokeColor
{
    CGColorSpaceRef space = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
    if (space == NULL)
        return NULL;
    const CGFloat components[4] = { 0.0, 0.0, 0.0, 1.0 };
    CGEColorRef color = CGEColorCreateSolid(space, components);
    CGColorSpaceRelease(space);
    return color;
}

- (void)BTDrawShapeTool_setNeedsDisplayShapePathIfNeeded
{
    if ([self isViewInvalidationEnabled] && BTDrawShapeToolIsCreating(self))
        [self BTDrawShapeTool_setNeedsDisplayShapePath];
}

- (void)BTDrawShapeTool_setNeedsDisplayShapePath
{
    id path = [(BTCreateShapeSelectionTool *)_currentSubtool selectionPath];
    if (path == nil)
        return;
    CGRect bounds = CGEPathGetPathBoundingBox((CGPathRef)path);
    if (CGRectIsEmpty(bounds))
        return;
    NSRect r = NSInsetRect([self convertImageRectToViewRect:bounds], -0.05, -0.05);
    [_view setNeedsDisplayInRect:CGRectIntegral(r)];
}

@end
