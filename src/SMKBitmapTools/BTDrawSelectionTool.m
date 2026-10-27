#import "BTDrawSelectionTool.h"
#import "BTCreateSelectionTool.h"
#import "BTCGBitmapLayer.h"
#import "BTPointer.h"
#import "NSEvent+BTLocation.h"
#import "NSEvent_BTKeyBinding_BTKeyEventsInterpreter.h"
#import "NSView+BTMouseTracking.h"
#import "NSWindow+BTEvents.h"

/* The selection drawing tool lets a create selection tool make a selection
   and fills it with the fill color (or the alternate one, chosen by the
   alternate option or the pen's eraser end) as a floating "drawing path". It
   is stamped into the image when finalized, when the next click starts a new
   selection or when the tool is deactivated. Clicking with the color picking
   option picks the fill color outside the selection. */
@implementation BTDrawSelectionTool

static BOOL BTDrawSelectionToolSubtoolStageIs(BTDrawSelectionTool *self, NSString *aStage)
{
    return [[self->_currentSubtool currentStage] isEqualToString:aStage];
}

/* Whether the alternate fill color option is held right now. */
static BOOL BTDrawSelectionToolWindowWantsAlternate(BTDrawSelectionTool *self)
{
    return BTModifierFlagsMatchOption([[self->_view window] BT_effectiveModifierFlags], self->_alternateFillColorOption);
}

/* The alternate fill color option, or the pen's eraser end. */
static BOOL BTDrawSelectionToolEventWantsAlternate(BTDrawSelectionTool *self, NSEvent *aEvent)
{
    return BTModifierFlagsMatchOption([aEvent modifierFlags], self->_alternateFillColorOption)
        || [aEvent BT_pointingDeviceType] == NSPointingDeviceTypeEraser;
}

- (id)layoutGuidingContextForTool:(id)aTool
{
    return _currentSubtool == aTool ? [_delegate layoutGuidingContextForTool:self] : nil;
}

- (id)mouseTrackingDelegateForTool:(id)aTool
{
    return nil;
}

- (id)imageViewTransformerForTool:(id)aTool
{
    return _currentSubtool == aTool ? [_delegate imageViewTransformerForTool:self] : nil;
}

/* The subtool's undo names are this tool's, except its selection removal. */
- (id)tool:(id)aTool willSetUndoActionName:(id)aName
{
    if (_currentSubtool == aTool && ![aName isEqualToString:@"Remove Selection"])
        [self setUndoActionName:aName];
    return nil;
}

- (void)tool:(id)aTool willRegisterUndoInManager:(id)aManager category:(id)aCategory
{
    if (_currentSubtool == aTool)
        [_delegate tool:self willRegisterUndoInManager:aManager category:aCategory];
}

- (id)undoManagerForTool:(id)aTool category:(id)aCategory
{
    return _currentSubtool == aTool ? [_delegate undoManagerForTool:self category:aCategory] : nil;
}

/* A finished selection becomes the drawing path, filled with the color
   chosen when it was finished. While the tolerance change recreates the
   selection only the path is taken. */
- (BOOL)tool:(id)aTool didFinalizeStage:(id)aStage withEvent:(id)aEvent nextStage:(id)aNextStage
{
    if (_currentSubtool != aTool)
        return NO;
    if (_isRecreatingSelectionPath) {
        if (aNextStage == nil)
            [self BTDrawSelectionTool_setSelectionPath:[_createSelectionTool selectionPath]];
        return NO;
    }
    if ([aNextStage isEqualToString:@"BTCreatingSelectionToolStage"]) {
        if (BTModifierFlagsMatchOption([(NSEvent *)aEvent modifierFlags], _alternateFillColorOption)) {
            if (_alternateDoCreateFreeHandSelectionCursor != nil)
                [_createSelectionTool setDoCreateFreeHandSelectionCursor:_alternateDoCreateFreeHandSelectionCursor];
            if (_alternateDoCreateMagicLassoSelectionCursor != nil)
                [_createSelectionTool setDoCreateMagicLassoSelectionCursor:_alternateDoCreateMagicLassoSelectionCursor];
            if (_alternateDoCreateShapeSelectionCursor != nil)
                [_createSelectionTool setDoCreateShapeSelectionCursor:_alternateDoCreateShapeSelectionCursor];
        } else {
            [_createSelectionTool setDoCreateFreeHandSelectionCursor:[self doCreateFreeHandSelectionCursor]];
            [_createSelectionTool setDoCreateMagicLassoSelectionCursor:[self doCreateMagicLassoSelectionCursor]];
            [_createSelectionTool setDoCreateShapeSelectionCursor:[self doCreateShapeSelectionCursor]];
        }
    }
    if (([aStage isEqualToString:@"BTWaitingToolStage"] || [aStage isEqualToString:@"BTCreatingSelectionToolStage"])
        && ![aNextStage isEqualToString:@"BTWaitingToolStage"]) {
        if (_alternateFillColor != NULL && BTDrawSelectionToolEventWantsAlternate(self, aEvent))
            [self BTDrawSelectionTool_setSelectionFillColor:_alternateFillColor asAlternate:YES];
        else
            [self BTDrawSelectionTool_setSelectionFillColor:[self BTDrawSelectionTool_fillColor] asAlternate:NO];
        [self BTDrawSelectionTool_setSelectionPath:[_createSelectionTool selectionPath]];
    }
    return [_delegate tool:self didFinalizeStage:aStage withEvent:aEvent
                 nextStage:aNextStage != nil ? aNextStage : @"BTWaitingToModifySelectionToolStage"];
}

/* The subtool's selection outputs under this tool's names. */
- (void)tool:(id)aTool didFinalizeOutputForKey:(id)aKey
{
    if (_currentSubtool != aTool)
        return;
    NSString *key;
    if ([aKey isEqualToString:@"selectionPath"])
        key = @"selectionPath";
    else if ([aKey isEqualToString:@"selectionAffineTransform"])
        key = @"selectionPathTransform";
    else if ([aKey isEqualToString:@"selectionFlippedHorizontally"])
        key = @"selectionPathFlippedHorizontally";
    else if ([aKey isEqualToString:@"currentCreateSelectionMode"])
        key = @"currentCreateSelectionMode";
    else
        return;
    [_delegate tool:self didFinalizeOutputForKey:key];
}

/* The start point, mode and initial path are kept so that a tolerance
   change can recreate the selection. */
- (void)tool:(id)aTool didUpdateOutputForKey:(id)aKey
{
    if (_currentSubtool != aTool)
        return;
    if ([aKey isEqualToString:@"selectionPath"]) {
        [_delegate tool:self didUpdateOutputForKey:@"selectionPath"];
        [_delegate tool:self didUpdateOutputForKey:@"drawingPath"];
    } else if ([aKey isEqualToString:@"currentCreateSelectionMode"]) {
        [_delegate tool:self didUpdateOutputForKey:@"currentCreateSelectionMode"];
    } else if ([aKey isEqualToString:@"selectionStartPoint"]) {
        if (_currentSubtool != (BTTool *)_createSelectionTool)
            return;
        [_selectionStartPoint release];
        _selectionStartPoint = [[_createSelectionTool selectionStartPoint] retain];
        [_finalizingCreateSelectionMode release];
        _finalizingCreateSelectionMode = [[self currentCreateSelectionMode] copy];
    } else if ([aKey isEqualToString:@"initialSelectionPath"]) {
        CGPathRelease(_initialSelectionPath);
        _initialSelectionPath = (struct CGPath *)CGPathRetain((CGPathRef)[_createSelectionTool initialSelectionPath]);
    }
}

- (void)tool:(id)aTool willUpdateOutputForKey:(id)aKey
{
    if (_currentSubtool != aTool)
        return;
    if ([aKey isEqualToString:@"selectionPath"]) {
        [_delegate tool:self willUpdateOutputForKey:@"selectionPath"];
        [_delegate tool:self willUpdateOutputForKey:@"drawingPath"];
    } else if ([aKey isEqualToString:@"currentCreateSelectionMode"]) {
        [_delegate tool:self willUpdateOutputForKey:@"currentCreateSelectionMode"];
    }
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

- (void)tool:(id)aTool didUpdateCursorWithEvent:(id)aEvent
{
    if (_currentSubtool == aTool)
        [_delegate tool:self didUpdateCursorWithEvent:aEvent];
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

- (void)trackFlagsChanged:(id)aEvent inView:(id)aView
{
    if (_view == aView)
        [[_delegate mouseTrackingDelegateForTool:self] trackFlagsChanged:aEvent inView:aView];
}

/* Color picking (tracked by this tool itself) ends. */
- (void)trackMouseUp:(id)aEvent inView:(id)aView
{
    if (_view != aView)
        return;
    [[_delegate mouseTrackingDelegateForTool:self] trackMouseUp:aEvent inView:aView];
    [self BTDrawSelectionTool_pickColorWithEvent:aEvent];
    _isPickingFillColor = 0;
    [_delegate tool:self didFinalizeStage:@"BTPickingColorToolStage" withEvent:aEvent nextStage:[_createSelectionTool currentStage]];
    if ([self isActive])
        [_delegate tool:self didUpdateCursorWithEvent:aEvent];
}

- (void)trackMouseDragged:(id)aEvent inView:(id)aView
{
    if (_view != aView)
        return;
    [[_delegate mouseTrackingDelegateForTool:self] trackMouseDragged:aEvent inView:aView];
    [self BTDrawSelectionTool_pickColorWithEvent:aEvent];
}

/* Color picking starts. */
- (void)trackMouseDown:(id)aEvent inView:(id)aView
{
    if (_view != aView)
        return;
    [[_delegate mouseTrackingDelegateForTool:self] trackMouseDown:aEvent inView:aView];
    [_delegate tool:self didFinalizeStage:[_createSelectionTool currentStage] withEvent:aEvent nextStage:@"BTPickingColorToolStage"];
    if (_currentSubtool == nil)
        return;
    _isPickingFillColor = 1;
    _isUsingAlternateFillColor = BTDrawSelectionToolEventWantsAlternate(self, aEvent);
    [self BTDrawSelectionTool_pickColorWithEvent:aEvent];
    [(NSCursor *)[self pickColorCursor] set];
}

- (BOOL)isFeedbackLayerActive:(id)aLayer
{
    if (_currentSubtool == nil)
        return NO;
    if ([_currentSubtool isFeedbackLayerActive:aLayer])
        return YES;
    return _drawingPath != NULL && [aLayer isEqualToString:@"BTDrawingFeedbackLayer"];
}

- (id)activeFeedbackLayers
{
    if (_currentSubtool == nil)
        return [NSSet set];
    id layers = [_currentSubtool activeFeedbackLayers];
    if (_drawingPath == NULL)
        return layers;
    NSMutableSet *set = [NSMutableSet setWithSet:layers];
    [set addObject:@"BTDrawingFeedbackLayer"];
    return [[set copy] autorelease];
}

/* The drawing path goes under the subtool's layers. */
- (id)activeFeedbackLayersForDrawing
{
    if (_currentSubtool == nil)
        return [NSArray array];
    id layers = [_currentSubtool activeFeedbackLayersForDrawing];
    if (_drawingPath == NULL)
        return layers;
    return [[NSArray arrayWithObject:@"BTDrawingFeedbackLayer"] arrayByAddingObjectsFromArray:layers];
}

- (void)draw_BTDrawingFeedbackLayer_Rect:(NSRect)aRect
{
    CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];
    if (context == NULL || _drawingPath == NULL)
        return;
    CGContextSaveGState(context);
    CGContextConcatCTM(context, [self imageToViewTransform]);
    [self BTDrawSelectionTool_drawPath:_drawingPath inContext:context];
    CGContextRestoreGState(context);
}

/* Stamps the drawing path (one undo action) and ends the drawing stage. */
static void BTDrawSelectionToolStamp(BTDrawSelectionTool *self)
{
    [self->_delegate tool:self didFinalizeOutputForKey:@"drawingPath"];
    [self beginUndoAction];
    [self BTDrawSelectionTool_stampSelection];
    [self BTDrawSelectionTool_resetSelection];
    [self endUndoActionWithName:@"Draw Selection"];
}

- (void)finalize:(id)aSender
{
    if (_drawingPath == NULL)
        return;
    BTDrawSelectionToolStamp(self);
    [_delegate tool:self didFinalizeStage:[self currentStage] withEvent:nil nextStage:nil];
}

- (BOOL)validateAction_finalize
{
    return _drawingPath != NULL;
}

- (void)delete:(id)aSender
{
    if (_drawingPath == NULL)
        return;
    [self beginUndoAction];
    [self BTDrawSelectionTool_resetSelection];
    [self endUndoActionWithName:@"Delete Selection"];
    [_delegate tool:self didUpdateCursorWithEvent:nil];
}

- (BOOL)validateAction_delete
{
    return _drawingPath != NULL;
}

- (BOOL)flagsChanged:(id)aEvent
{
    [_delegate tool:self didUpdateCursorWithEvent:aEvent];
    return [_currentSubtool flagsChanged:aEvent];
}

/* With the color picking option (and no selection being made) this tool
   tracks the mouse to pick the fill color. Otherwise a click stamps the
   drawing path first, then goes to the subtool. */
- (BOOL)mouseDown:(id)aEvent
{
    if (BTDrawSelectionToolSubtoolStageIs(self, @"BTWaitingToolStage")
        && BTModifierFlagsMatchOption([(NSEvent *)aEvent modifierFlags], _colorPickingOption)) {
        [_view BT_trackMouseWithEvent:aEvent tracker:self startDelay:0.0];
        return YES;
    }
    if (_drawingPath != NULL) {
        BTDrawSelectionToolStamp(self);
        if ([_delegate tool:self didFinalizeStage:[self currentStage] withEvent:aEvent nextStage:nil])
            return YES;
    }
    return [_currentSubtool mouseDown:aEvent];
}

/* The subtool shows the cursors of the fill color in use. */
- (id)cursorForPoint:(NSPoint)aPoint modifierFlags:(NSUInteger)aFlags
{
    if (BTDrawSelectionToolSubtoolStageIs(self, @"BTWaitingToolStage") && BTModifierFlagsMatchOption(aFlags, _colorPickingOption))
        return [self pickColorCursor];
    if (BTModifierFlagsMatchOption(aFlags, _alternateFillColorOption)) {
        if (_alternateWillCreateFreeHandSelectionCursor != nil)
            [_createSelectionTool setWillCreateFreeHandSelectionCursor:_alternateWillCreateFreeHandSelectionCursor];
        if (_alternateWillCreateMagicWandSelectionCursor != nil)
            [_createSelectionTool setWillCreateMagicWandSelectionCursor:_alternateWillCreateMagicWandSelectionCursor];
        if (_alternateWillCreateMagicLassoSelectionCursor != nil)
            [_createSelectionTool setWillCreateMagicLassoSelectionCursor:_alternateWillCreateMagicLassoSelectionCursor];
        if (_alternateWillCreateShapeSelectionCursor != nil)
            [_createSelectionTool setWillCreateShapeSelectionCursor:_alternateWillCreateShapeSelectionCursor];
    } else {
        [_createSelectionTool setWillCreateFreeHandSelectionCursor:[self willCreateFreeHandSelectionCursor]];
        [_createSelectionTool setWillCreateMagicWandSelectionCursor:[self willCreateMagicWandSelectionCursor]];
        [_createSelectionTool setWillCreateMagicLassoSelectionCursor:[self willCreateMagicLassoSelectionCursor]];
        [_createSelectionTool setWillCreateShapeSelectionCursor:[self willCreateShapeSelectionCursor]];
    }
    return [_currentSubtool cursorForPoint:aPoint modifierFlags:aFlags];
}

- (id)keyBindings
{
    id bindings = [[self currentStage] isEqualToString:@"BTWaitingToModifySelectionToolStage"]
        ? [self modifySelectionKeyBindings] : [self generalKeyBindings];
    return [NSEvent BT_mergeKeyBindingDictionary:bindings intoDictionary:[_currentSubtool keyBindings]];
}

- (void)removeAllUndoActionsFromManager:(id)aManager
{
    [_createSelectionTool removeAllUndoActionsFromManager:aManager];
    [super removeAllUndoActionsFromManager:aManager];
}

- (void)removeAllUndoActionsFromManager:(id)aManager category:(id)aCategory
{
    [_createSelectionTool removeAllUndoActionsFromManager:aManager category:aCategory];
    [super removeAllUndoActionsFromManager:aManager category:aCategory];
}

- (id)allUndoCategories
{
    return [NSSet setWithObjects:@"BTToolWorkImageUndoCategory", @"BTSelectionUndoCategory", nil];
}

- (id)currentStage
{
    if (_isPickingFillColor)
        return @"BTPickingColorToolStage";
    if (_drawingPath != NULL)
        return @"BTWaitingToModifySelectionToolStage";
    return [_currentSubtool currentStage];
}

/* A drawing path left over is stamped. */
- (void)performDeactivate
{
    if (BTDrawSelectionToolSubtoolStageIs(self, @"BTWaitingToolStage")) {
        [self beginUndoAction];
        [self BTDrawSelectionTool_stampSelection];
        [self BTDrawSelectionTool_resetSelection];
        [self endUndoActionWithName:@"Draw Selection"];
    }
    [_currentSubtool deactivate];
    _currentSubtool = nil;
    [super performDeactivate];
}

- (BOOL)activateWithDelegate:(id)aDelegate inView:(id)aView
{
    if (![super activateWithDelegate:aDelegate inView:aView])
        return NO;
    if ([self BTDrawSelectionTool_activateSubtool]) {
        [_selectionStartPoint release];
        _selectionStartPoint = nil;
        CGPathRelease(_initialSelectionPath);
        _initialSelectionPath = NULL;
        [_finalizingCreateSelectionMode release];
        _finalizingCreateSelectionMode = nil;
        return YES;
    }
    [super performDeactivate];
    return NO;
}

- (void)changeViewInvalidationEnabledTo:(BOOL)aEnabled
{
    [super changeViewInvalidationEnabledTo:aEnabled];
    [_createSelectionTool setViewInvalidationEnabled:aEnabled];
}

- (void)changeReferenceCGContextTo:(struct CGContext *)aContext
{
    [super changeReferenceCGContextTo:aContext];
    [_createSelectionTool setReferenceCGContext:aContext];
}

- (void)changeWorkPasteboardTo:(id)aPasteboard
{
    [super changeWorkPasteboardTo:aPasteboard];
    [_createSelectionTool setWorkPasteboard:aPasteboard];
}

- (void)changeWorkImageTo:(id)aImage
{
    [super changeWorkImageTo:aImage];
    [_createSelectionTool setWorkImage:aImage];
}

- (id)outputKeys
{
    return [NSArray arrayWithObjects:@"currentCreateSelectionMode", @"selectionPath", @"drawingPath", @"fillColor",
            @"alternateFillColor", @"selectionFillColor", nil];
}

/* "selectionPathFlippedHorizontallywillCreateFreeHandSelectionCursor" is one
   key in the original (a missing comma); kept as is. */
- (id)inputKeys
{
    return [NSArray arrayWithObjects:@"generalKeyBindings", @"modifySelectionKeyBindings", @"initialCreateSelectionMode",
            @"selectionShapePrototypePath", @"selectionTolerance", @"alternateProportion",
            @"proportionalModePrimaryForSides", @"proportionalModePrimaryForCorners", @"selectionPath",
            @"selectionPathTransform", @"selectionPathFlippedHorizontallywillCreateFreeHandSelectionCursor",
            @"doCreateFreeHandSelectionCursor", @"willCreateMagicWandSelectionCursor",
            @"willCreateMagicLassoSelectionCursor", @"doCreateMagicLassoSelectionCursor",
            @"willCreateShapeSelectionCursor", @"doCreateShapeSelectionCursor", @"willMoveSelectionCursor",
            @"doMoveSelectionCursor", @"willResizeBottomLeftSelectionCursor", @"doResizeBottomLeftSelectionCursor",
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

- (id *)requiredImageProtocols
{
    static id protocols[2];
    protocols[0] = @protocol(BTCGImage);
    return protocols;
}

static id BTDrawSelectionToolWrapColor(CGEColorRef aColor)
{
    if (aColor == NULL)
        return nil;
    id wrapper = [BTPointer wrapperForPointer:aColor withDisposer:CGEColorRelease];
    if (wrapper != nil)
        CGEColorRetain(aColor);
    return wrapper;
}

/* Colors come in as CGColors or as BTPointer-wrapped CGEColors. */
static void BTDrawSelectionToolReplaceColor(CGEColorRef *aSlot, id aColor)
{
    CGEColorRef old = *aSlot;
    if (aColor == nil)
        *aSlot = NULL;
    else if (CFGetTypeID((CFTypeRef)aColor) == CGColorGetTypeID())
        *aSlot = CGEColorCreateWithCGColor((CGColorRef)aColor);
    else
        *aSlot = CGEColorRetain((CGEColorRef)[aColor pointer]);
    CGEColorRelease(old);
}

- (id)selectionFillColor
{
    return BTDrawSelectionToolWrapColor(_selectionFillColor);
}

- (void)setAlternateFillColor:(id)aColor
{
    BTDrawSelectionToolReplaceColor(&_alternateFillColor, aColor);
}

- (id)alternateFillColor
{
    return BTDrawSelectionToolWrapColor(_alternateFillColor);
}

- (void)setFillColor:(id)aColor
{
    _isFillColorInitialized = 1;
    BTDrawSelectionToolReplaceColor(&_fillColor, aColor);
}

- (id)fillColor
{
    return BTDrawSelectionToolWrapColor([self BTDrawSelectionTool_fillColor]);
}

- (id)defaultFillColor
{
    CGEColorRef color = [self BTDrawSelectionTool_createDefaultFillColor];
    if (color == NULL)
        return nil;
    id wrapper = [BTPointer wrapperForPointer:color withDisposer:CGEColorRelease];
    if (wrapper == nil)
        CGEColorRelease(color);
    return wrapper;
}

- (struct CGEColor *)BTDrawSelectionTool_fillColor
{
    if (!_isFillColorInitialized) {
        _fillColor = [self BTDrawSelectionTool_createDefaultFillColor];
        _isFillColorInitialized = 1;
    }
    return _fillColor;
}

/* Opaque black. */
- (struct CGEColor *)BTDrawSelectionTool_createDefaultFillColor
{
    CGColorSpaceRef space = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
    if (space == NULL)
        return NULL;
    const CGFloat components[4] = { 0.0, 0.0, 0.0, 1.0 };
    CGEColorRef color = CGEColorCreateSolid(space, components);
    CGColorSpaceRelease(space);
    return color;
}

- (void)setAlternateColorOption:(NSUInteger)aOption
{
    _alternateFillColorOption = aOption;
}

- (NSUInteger)alternateColorOption
{
    return _alternateFillColorOption;
}

- (NSUInteger)defaultAlternateColorOption
{
    return NSEventModifierFlagOption;
}

- (id)drawingPath
{
    return (id)_drawingPath;
}

- (id)selectionPath
{
    return [_createSelectionTool selectionPath];
}

- (void)setProportionalModePrimaryForCreation:(BOOL)aPrimary
{
    [_createSelectionTool setProportionalModePrimary:aPrimary];
}

- (BOOL)isProportionalModePrimaryForCreation
{
    return [_createSelectionTool isProportionalModePrimary];
}

- (BOOL)defaultProportionalModePrimaryForCreation
{
    return [_createSelectionTool defaultProportionalModePrimary];
}

- (void)setAlternateProportion:(CGFloat)aProportion
{
    [_createSelectionTool setAlternateProportion:aProportion];
}

- (CGFloat)alternateProportion
{
    return [_createSelectionTool alternateProportion];
}

- (CGFloat)defaultAlternateProportion
{
    return [_createSelectionTool defaultAlternateProportion];
}

- (void)setLassoSwitchingOption:(NSUInteger)aOption
{
    [_createSelectionTool setLassoSwitchingOption:aOption];
}

- (NSUInteger)lassoSwitchingOption
{
    return [_createSelectionTool lassoSwitchingOption];
}

- (NSUInteger)defaultLassoSwitchingOption
{
    return [_createSelectionTool defaultLassoSwitchingOption];
}

- (void)setMagicSwitchingOption:(NSUInteger)aOption
{
    [_createSelectionTool setMagicSwitchingOption:aOption];
}

- (NSUInteger)magicSwitchingOption
{
    return [_createSelectionTool magicSwitchingOption];
}

- (NSUInteger)defaultMagicSwitchingOption
{
    return [_createSelectionTool defaultMagicSwitchingOption];
}

- (void)setSelectionShapePrototypePath:(id)aPath
{
    [_createSelectionTool setSelectionShapePrototypePath:aPath];
}

- (id)selectionShapePrototypePath
{
    return [_createSelectionTool selectionShapePrototypePath];
}

/* A real change (more than 1/512) recreates a magic selection waiting to be
   drawn from its start point, as one undo action. */
- (void)setSelectionTolerance:(CGFloat)aTolerance
{
    CGFloat tolerance = [_createSelectionTool tolerance];
    if (aTolerance >= tolerance - 0.001953125 && aTolerance <= tolerance + 0.001953125)
        return;
    [_createSelectionTool setTolerance:aTolerance];
    if (_currentSubtool == nil || _selectionStartPoint == nil
        || ![[_createSelectionTool currentStage] isEqualToString:@"BTWaitingToolStage"])
        return;
    [self beginUndoAction];
    id manager = [_delegate undoManagerForTool:self category:@"BTSelectionUndoCategory"];
    if (manager != nil)
        [[self prepareUndoInManager:manager category:@"BTSelectionUndoCategory" withInvocationTarget:self]
            BTDrawSelectionTool_setSelectionPath:(id)_drawingPath];
    [_createSelectionTool setFinalizingCreateSelectionMode:_finalizingCreateSelectionMode];
    [_createSelectionTool setSelectionStartPoint:_selectionStartPoint];
    [_createSelectionTool setInitialSelectionPath:(id)_initialSelectionPath];
    [self endUndoActionWithName:@"Set Selection Tolerance"];
    [self BTDrawSelectionTool_setNeedsDisplayDrawingPath];
    _isRecreatingSelectionPath = 1;
    [_createSelectionTool doCommandBySelector:@selector(finalizeSelectionPath:)];
    _isRecreatingSelectionPath = 0;
    [self BTDrawSelectionTool_setNeedsDisplayDrawingPath];
}

- (CGFloat)selectionTolerance
{
    return [_createSelectionTool tolerance];
}

- (id)currentCreateSelectionMode
{
    return [_createSelectionTool currentCreateSelectionMode];
}

- (void)setInitialCreateSelectionMode:(id)aMode
{
    [_createSelectionTool setInitialCreateSelectionMode:aMode];
}

- (id)initialCreateSelectionMode
{
    return [_createSelectionTool initialCreateSelectionMode];
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

/* Cursors: the subtool gets the alternate ones while the alternate option is
   held (the "do" ones only while a selection is being created). */
static BOOL BTDrawSelectionToolReplaceCursor(NSCursor **aSlot, id aCursor)
{
    if (*aSlot == aCursor)
        return NO;
    [aCursor retain];
    [*aSlot release];
    *aSlot = aCursor;
    return YES;
}

static BOOL BTDrawSelectionToolIsCreating(BTDrawSelectionTool *self)
{
    return BTDrawSelectionToolSubtoolStageIs(self, @"BTCreatingSelectionToolStage");
}

- (void)setAlternateDoCreateShapeSelectionCursor:(id)aCursor
{
    if (BTDrawSelectionToolReplaceCursor(&_alternateDoCreateShapeSelectionCursor, aCursor)
        && BTDrawSelectionToolIsCreating(self) && BTDrawSelectionToolWindowWantsAlternate(self))
        [_createSelectionTool setDoCreateShapeSelectionCursor:aCursor != nil ? aCursor : [self doCreateShapeSelectionCursor]];
}

- (id)alternateDoCreateShapeSelectionCursor
{
    return _alternateDoCreateShapeSelectionCursor;
}

- (void)setDoCreateShapeSelectionCursor:(id)aCursor
{
    _isDoCreateShapeSelectionCursorInitialized = 1;
    if (BTDrawSelectionToolReplaceCursor(&_doCreateShapeSelectionCursor, aCursor)
        && BTDrawSelectionToolIsCreating(self) && !BTDrawSelectionToolWindowWantsAlternate(self))
        [_createSelectionTool setDoCreateShapeSelectionCursor:aCursor];
}

- (id)doCreateShapeSelectionCursor
{
    if (!_isDoCreateShapeSelectionCursorInitialized) {
        _doCreateShapeSelectionCursor = [[_createSelectionTool defaultDoCreateShapeSelectionCursor] retain];
        _isDoCreateShapeSelectionCursorInitialized = 1;
    }
    return _doCreateShapeSelectionCursor;
}

- (id)defaultDoCreateShapeSelectionCursor
{
    return [_createSelectionTool defaultDoCreateShapeSelectionCursor];
}

- (void)setAlternateWillCreateShapeSelectionCursor:(id)aCursor
{
    if (BTDrawSelectionToolReplaceCursor(&_alternateWillCreateShapeSelectionCursor, aCursor)
        && _currentSubtool != nil && BTDrawSelectionToolWindowWantsAlternate(self))
        [_createSelectionTool setWillCreateShapeSelectionCursor:aCursor != nil ? aCursor : [self willCreateShapeSelectionCursor]];
}

- (id)alternateWillCreateShapeSelectionCursor
{
    return _alternateWillCreateShapeSelectionCursor;
}

- (void)setWillCreateShapeSelectionCursor:(id)aCursor
{
    _isWillCreateShapeSelectionCursorInitialized = 1;
    if (BTDrawSelectionToolReplaceCursor(&_willCreateShapeSelectionCursor, aCursor)
        && _currentSubtool != nil && !BTDrawSelectionToolWindowWantsAlternate(self))
        [_createSelectionTool setWillCreateShapeSelectionCursor:aCursor];
}

- (id)willCreateShapeSelectionCursor
{
    if (!_isWillCreateShapeSelectionCursorInitialized) {
        _willCreateShapeSelectionCursor = [[_createSelectionTool defaultWillCreateShapeSelectionCursor] retain];
        _isWillCreateShapeSelectionCursorInitialized = 1;
    }
    return _willCreateShapeSelectionCursor;
}

- (id)defaultWillCreateShapeSelectionCursor
{
    return [_createSelectionTool defaultWillCreateShapeSelectionCursor];
}

- (void)setAlternateDoCreateMagicLassoSelectionCursor:(id)aCursor
{
    if (BTDrawSelectionToolReplaceCursor(&_alternateDoCreateMagicLassoSelectionCursor, aCursor)
        && BTDrawSelectionToolIsCreating(self) && BTDrawSelectionToolWindowWantsAlternate(self))
        [_createSelectionTool setDoCreateMagicLassoSelectionCursor:aCursor];
}

- (id)alternateDoCreateMagicLassoSelectionCursor
{
    return _alternateDoCreateMagicLassoSelectionCursor;
}

- (void)setDoCreateMagicLassoSelectionCursor:(id)aCursor
{
    _isDoCreateMagicLassoSelectionCursorInitialized = 1;
    if (BTDrawSelectionToolReplaceCursor(&_doCreateMagicLassoSelectionCursor, aCursor)
        && BTDrawSelectionToolIsCreating(self) && !BTDrawSelectionToolWindowWantsAlternate(self))
        [_createSelectionTool setDoCreateMagicLassoSelectionCursor:aCursor];
}

- (id)doCreateMagicLassoSelectionCursor
{
    if (!_isDoCreateMagicLassoSelectionCursorInitialized) {
        _doCreateMagicLassoSelectionCursor = [[_createSelectionTool defaultDoCreateMagicLassoSelectionCursor] retain];
        _isDoCreateMagicLassoSelectionCursorInitialized = 1;
    }
    return _doCreateMagicLassoSelectionCursor;
}

- (id)defaultDoCreateMagicLassoSelectionCursor
{
    return [_createSelectionTool defaultDoCreateMagicLassoSelectionCursor];
}

- (void)setAlternateWillCreateMagicLassoSelectionCursor:(id)aCursor
{
    if (BTDrawSelectionToolReplaceCursor(&_alternateWillCreateMagicLassoSelectionCursor, aCursor)
        && _currentSubtool != nil && BTDrawSelectionToolWindowWantsAlternate(self))
        [_createSelectionTool setWillCreateMagicLassoSelectionCursor:aCursor != nil ? aCursor : [self willCreateMagicLassoSelectionCursor]];
}

- (id)alternateWillCreateMagicLassoSelectionCursor
{
    return _alternateWillCreateMagicLassoSelectionCursor;
}

- (void)setWillCreateMagicLassoSelectionCursor:(id)aCursor
{
    _isWillCreateMagicLassoSelectionCursorInitialized = 1;
    if (BTDrawSelectionToolReplaceCursor(&_willCreateMagicLassoSelectionCursor, aCursor)
        && _currentSubtool != nil && !BTDrawSelectionToolWindowWantsAlternate(self))
        [_createSelectionTool setWillCreateMagicLassoSelectionCursor:aCursor];
}

- (id)willCreateMagicLassoSelectionCursor
{
    if (!_isWillCreateMagicLassoSelectionCursorInitialized) {
        _willCreateMagicLassoSelectionCursor = [[_createSelectionTool defaultWillCreateMagicLassoSelectionCursor] retain];
        _isWillCreateMagicLassoSelectionCursorInitialized = 1;
    }
    return _willCreateMagicLassoSelectionCursor;
}

- (id)defaultWillCreateMagicLassoSelectionCursor
{
    return [_createSelectionTool defaultWillCreateMagicLassoSelectionCursor];
}

- (void)setAlternateWillCreateMagicWandSelectionCursor:(id)aCursor
{
    if (BTDrawSelectionToolReplaceCursor(&_alternateWillCreateMagicWandSelectionCursor, aCursor)
        && _currentSubtool != nil && BTDrawSelectionToolWindowWantsAlternate(self))
        [_createSelectionTool setWillCreateMagicWandSelectionCursor:aCursor != nil ? aCursor : [self willCreateMagicWandSelectionCursor]];
}

- (id)alternateWillCreateMagicWandSelectionCursor
{
    return _alternateWillCreateMagicWandSelectionCursor;
}

- (void)setWillCreateMagicWandSelectionCursor:(id)aCursor
{
    _isWillCreateMagicWandSelectionCursorInitialized = 1;
    if (BTDrawSelectionToolReplaceCursor(&_willCreateMagicWandSelectionCursor, aCursor)
        && _currentSubtool != nil && !BTDrawSelectionToolWindowWantsAlternate(self))
        [_createSelectionTool setWillCreateMagicWandSelectionCursor:aCursor];
}

- (id)willCreateMagicWandSelectionCursor
{
    if (!_isWillCreateMagicWandSelectionCursorInitialized) {
        _willCreateMagicWandSelectionCursor = [[_createSelectionTool defaultWillCreateMagicWandSelectionCursor] retain];
        _isWillCreateMagicWandSelectionCursorInitialized = 1;
    }
    return _willCreateMagicWandSelectionCursor;
}

- (id)defaultWillCreateMagicWandSelectionCursor
{
    return [_createSelectionTool defaultWillCreateMagicWandSelectionCursor];
}

- (void)setAlternateDoCreateFreeHandSelectionCursor:(id)aCursor
{
    if (BTDrawSelectionToolReplaceCursor(&_alternateDoCreateFreeHandSelectionCursor, aCursor)
        && BTDrawSelectionToolIsCreating(self) && BTDrawSelectionToolWindowWantsAlternate(self))
        [_createSelectionTool setDoCreateFreeHandSelectionCursor:aCursor];
}

- (id)alternateDoCreateFreeHandSelectionCursor
{
    return _alternateDoCreateFreeHandSelectionCursor;
}

- (void)setDoCreateFreeHandSelectionCursor:(id)aCursor
{
    _isDoCreateFreeHandSelectionCursorInitialized = 1;
    if (BTDrawSelectionToolReplaceCursor(&_doCreateFreeHandSelectionCursor, aCursor)
        && BTDrawSelectionToolIsCreating(self) && !BTDrawSelectionToolWindowWantsAlternate(self))
        [_createSelectionTool setDoCreateFreeHandSelectionCursor:aCursor];
}

- (id)doCreateFreeHandSelectionCursor
{
    if (!_isDoCreateFreeHandSelectionCursorInitialized) {
        _doCreateFreeHandSelectionCursor = [[_createSelectionTool defaultDoCreateFreeHandSelectionCursor] retain];
        _isDoCreateFreeHandSelectionCursorInitialized = 1;
    }
    return _doCreateFreeHandSelectionCursor;
}

- (id)defaultDoCreateFreeHandSelectionCursor
{
    return [_createSelectionTool defaultDoCreateFreeHandSelectionCursor];
}

- (void)setAlternateWillCreateFreeHandSelectionCursor:(id)aCursor
{
    if (BTDrawSelectionToolReplaceCursor(&_alternateWillCreateFreeHandSelectionCursor, aCursor)
        && _currentSubtool != nil && BTDrawSelectionToolWindowWantsAlternate(self))
        [_createSelectionTool setWillCreateFreeHandSelectionCursor:aCursor != nil ? aCursor : [self willCreateFreeHandSelectionCursor]];
}

- (id)alternateWillCreateFreeHandSelectionCursor
{
    return _alternateWillCreateFreeHandSelectionCursor;
}

- (void)setWillCreateFreeHandSelectionCursor:(id)aCursor
{
    _isWillCreateFreeHandSelectionCursorInitialized = 1;
    if (BTDrawSelectionToolReplaceCursor(&_willCreateFreeHandSelectionCursor, aCursor)
        && _currentSubtool != nil && !BTDrawSelectionToolWindowWantsAlternate(self))
        [_createSelectionTool setWillCreateFreeHandSelectionCursor:aCursor];
}

- (id)willCreateFreeHandSelectionCursor
{
    if (!_isWillCreateFreeHandSelectionCursorInitialized) {
        _willCreateFreeHandSelectionCursor = [[_createSelectionTool defaultWillCreateFreeHandSelectionCursor] retain];
        _isWillCreateFreeHandSelectionCursorInitialized = 1;
    }
    return _willCreateFreeHandSelectionCursor;
}

- (id)defaultWillCreateFreeHandSelectionCursor
{
    return [_createSelectionTool defaultWillCreateFreeHandSelectionCursor];
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

- (void)setModifySelectionKeyBindings:(id)aBindings
{
    if (_modifySelectionKeyBindings != aBindings) {
        [_modifySelectionKeyBindings autorelease];
        _modifySelectionKeyBindings = [aBindings copy];
    }
    _areModifySelectionKeyBindingsInitialized = 1;
}

- (id)modifySelectionKeyBindings
{
    if (!_areModifySelectionKeyBindingsInitialized) {
        _modifySelectionKeyBindings = [[self defaultModifySelectionKeyBindings] copy];
        _areModifySelectionKeyBindingsInitialized = 1;
    }
    return _modifySelectionKeyBindings;
}

- (id)defaultModifySelectionKeyBindings
{
    NSString *file = [[NSBundle bundleWithIdentifier:@"com.mackiev.SMKBitmapTools"]
        pathForResource:@"BTDrawSelectionTool.MS" ofType:@"dict" inDirectory:@"DefaultKeyBindings"];
    if (file == nil)
        return nil;
    return [NSDictionary dictionaryWithContentsOfFile:file];
}

- (void)BTDrawSelectionTool_resetSelection
{
    [self BTDrawSelectionTool_setStartPoint:nil initialPath:nil finalizingCreateSelectionMode:nil];
    [self BTDrawSelectionTool_setSelectionFillColor:NULL asAlternate:NO];
    [self BTDrawSelectionTool_setSelectionPath:nil];
}

- (void)BTDrawSelectionTool_setStartPoint:(id)aPoint initialPath:(id)aPath finalizingCreateSelectionMode:(id)aMode
{
    id manager = [_delegate undoManagerForTool:self category:@"BTSelectionUndoCategory"];
    if (manager != nil)
        [[self prepareUndoInManager:manager category:@"BTSelectionUndoCategory" withInvocationTarget:self]
            BTDrawSelectionTool_setStartPoint:_selectionStartPoint initialPath:(id)_initialSelectionPath
            finalizingCreateSelectionMode:_finalizingCreateSelectionMode];
    [_selectionStartPoint release];
    _selectionStartPoint = [aPoint retain];
    [_finalizingCreateSelectionMode release];
    _finalizingCreateSelectionMode = [aMode retain];
    CGPathRelease(_initialSelectionPath);
    _initialSelectionPath = (struct CGPath *)CGPathRetain((CGPathRef)aPath);
}

/* Fills the drawing path into (a bitmap copy of) the work image. */
- (void)BTDrawSelectionTool_stampSelection
{
    id image = [self BTDrawSelectionTool_bitmapWorkImage];
    if (image == nil || _drawingPath == NULL)
        return;
    CGRect r = CGRectIntersection((CGRect){ CGPointZero, [image imageSize] }, [self BTDrawSelectionTool_drawingPathInvalidationBounds]);
    if (CGRectIsEmpty(r))
        return;
    [self preEditWorkImage:image inRect:r];
    [image beginCGEditing];
    CGContextRef context = [image imageCGContext];
    if (context != NULL)
        [self BTDrawSelectionTool_drawPath:_drawingPath inContext:context];
    [image endCGEditing];
    [self postEditWorkImageInRect:r];
}

/* Even-odd fill with the selection fill color. */
- (void)BTDrawSelectionTool_drawPath:(struct CGPath *)aPath inContext:(struct CGContext *)aContext
{
    if (_selectionFillColor == NULL)
        return;
    CGRect bounds = (CGRect){ CGPointZero, [[self workImage] imageSize] };
    CGContextBeginPath(aContext);
    CGContextAddPath(aContext, aPath);
    if (CGEContextSetFillColorWithColor(aContext, NULL, bounds, _selectionFillColor))
        CGContextEOFillPath(aContext);
    else
        CGEContextEOFillPathWithColor(aContext, NULL, bounds, _selectionFillColor);
}

/* Picks the (alternate) fill color under the event, outside the drawing
   path. */
- (void)BTDrawSelectionTool_pickColorWithEvent:(id)aEvent
{
    id image = [self workImage];
    if (image == nil)
        return;
    NSPoint p = [self eventLocationInImage:aEvent];
    if (_drawingPath != NULL && CGEPathContainsPoint(_drawingPath, NULL, p, true))
        return;
    id color = (id)[image colorAtPoint:p];
    if (color == nil)
        return;
    NSString *key = _isUsingAlternateFillColor ? @"alternateFillColor" : @"fillColor";
    [_delegate tool:self willUpdateOutputForKey:key];
    if (_isUsingAlternateFillColor)
        [self setAlternateFillColor:color];
    else
        [self setFillColor:color];
    [_delegate tool:self didUpdateOutputForKey:key];
}

- (void)BTDrawSelectionTool_setSelectionFillColor:(struct CGEColor *)aColor asAlternate:(BOOL)aAlternate
{
    [self BTDrawSelectionTool_registerUndoOfSelectionFillColor:_selectionFillColor asAlternate:_isUsingAlternateFillColor];
    [_delegate tool:self willUpdateOutputForKey:@"selectionFillColor"];
    CGEColorRelease(_selectionFillColor);
    _selectionFillColor = CGEColorRetain(aColor);
    _isUsingAlternateFillColor = aAlternate;
    [self BTDrawSelectionTool_setNeedsDisplayDrawingPath];
    [_delegate tool:self didUpdateOutputForKey:@"selectionFillColor"];
}

- (void)BTDrawSelectionTool_setSelectionPath:(id)aPath
{
    id manager = [_delegate undoManagerForTool:self category:@"BTSelectionUndoCategory"];
    if (manager != nil)
        [[self prepareUndoInManager:manager category:@"BTSelectionUndoCategory" withInvocationTarget:self]
            BTDrawSelectionTool_setSelectionPath:(id)_drawingPath];
    [_delegate tool:self willUpdateOutputForKey:@"selectionPath"];
    if (_drawingPath != NULL)
        [self BTDrawSelectionTool_setNeedsDisplayDrawingPath];
    CGPathRelease(_drawingPath);
    _drawingPath = aPath != nil ? (struct CGPath *)CGPathCreateCopy((CGPathRef)aPath) : NULL;
    if (_drawingPath != NULL)
        [self BTDrawSelectionTool_setNeedsDisplayDrawingPath];
    [_delegate tool:self didUpdateOutputForKey:@"selectionPath"];
}

static const void *BTDrawSelectionToolColorRetain(CFAllocatorRef aAllocator, const void *aValue)
{
    return CGEColorRetain((CGEColorRef)aValue);
}

static void BTDrawSelectionToolColorRelease(CFAllocatorRef aAllocator, const void *aValue)
{
    CGEColorRelease((CGEColorRef)aValue);
}

static CFStringRef BTDrawSelectionToolColorCopyDescription(const void *aValue)
{
    return CFStringCreateWithFormat(kCFAllocatorDefault, NULL, CFSTR("<CGEColor 0x%lx>"), (unsigned long)aValue);
}

static Boolean BTDrawSelectionToolColorEqual(const void *aValue1, const void *aValue2)
{
    return CGEColorEqualToColor((CGEColorRef)aValue1, (CGEColorRef)aValue2);
}

/* The color goes to the undo invocation in a one-item array, which keeps
   it; no color is a nil array. The invocation doesn't retain a CF pointer
   argument, so the array is never released (as in the original). */
- (void)BTDrawSelectionTool_registerUndoOfSelectionFillColor:(struct CGEColor *)aColor asAlternate:(BOOL)aAlternate
{
    id manager = [_delegate undoManagerForTool:self category:@"BTSelectionUndoCategory"];
    if (manager == nil)
        return;
    CFArrayRef array = NULL;
    if (aColor != NULL) {
        static const CFArrayCallBacks callBacks = { 0, BTDrawSelectionToolColorRetain, BTDrawSelectionToolColorRelease,
                                                    BTDrawSelectionToolColorCopyDescription, BTDrawSelectionToolColorEqual };
        const void *value = aColor;
        array = CFArrayCreate(kCFAllocatorDefault, &value, 1, &callBacks);
        if (array == NULL)
            return;
    }
    [[self prepareUndoInManager:manager category:@"BTSelectionUndoCategory" withInvocationTarget:self]
        BTDrawSelectionTool_setSelectionFillColorAsArray:(struct __CFArray *)array asAlternate:aAlternate];
}

- (void)BTDrawSelectionTool_setSelectionFillColorAsArray:(struct __CFArray *)aArray asAlternate:(BOOL)aAlternate
{
    CGEColorRef color = aArray != NULL ? (CGEColorRef)CFArrayGetValueAtIndex(aArray, 0) : NULL;
    [self BTDrawSelectionTool_setSelectionFillColor:color asAlternate:aAlternate];
}

- (void)BTDrawSelectionTool_setNeedsDisplayDrawingPath
{
    CGRect r = [self BTDrawSelectionTool_drawingPathInvalidationBounds];
    if (!CGRectIsEmpty(r))
        [_view setNeedsDisplayInRect:[self convertImageRectToViewRect:r]];
}

- (CGRect)BTDrawSelectionTool_drawingPathInvalidationBounds
{
    if (_drawingPath == NULL)
        return CGRectNull;
    CGRect r = CGEPathGetPathBoundingBox(_drawingPath);
    return CGRectIntegral(CGRectMake(r.origin.x - 0.05, r.origin.y - 0.05, r.size.width + 0.1, r.size.height + 0.1));
}

/* The work image when it is a plain mutable raw image, else a bitmap layer
   copy of it. */
- (id)BTDrawSelectionTool_bitmapWorkImage
{
    id image = [self workImage];
    if (image == nil)
        return nil;
    if ([image conformsToProtocol:@protocol(BTRawImage)] && [image conformsToProtocol:@protocol(BTCGMutableImage)]
        && [image imageFormat] == -1 && [image imageDecode] == NULL && [image imageColorProfile] == NULL)
        return image;
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
    if (space == NULL)
        return nil;
    NSSize size = [image imageSize];
    size_t width = size.width > 0.0 ? (size_t)lround(ceil(size.width)) : 0;
    size_t height = size.height > 0.0 ? (size_t)lround(ceil(size.height)) : 0;
    CGContextRef context = CGEBitmapContextCreate(NULL, width, height, 8, (width * 4 + 15) & ~(size_t)15, space,
                                                  (CGBitmapInfo)kCGImageAlphaPremultipliedFirst);
    CGColorSpaceRelease(space);
    if (context == NULL)
        return nil;
    [image drawInCGContext:context atPoint:CGPointZero];
    id layer = [BTCGBitmapLayer bitmapLayerWithCGContext:context decode:NULL format:-1 colorProfile:NULL];
    CGContextRelease(context);
    return layer;
}

- (BOOL)BTDrawSelectionTool_activateSubtool
{
    _currentSubtool = (BTTool *)_createSelectionTool;
    if ([_currentSubtool activateWithDelegate:self inView:_view])
        return YES;
    _currentSubtool = nil;
    return NO;
}

/* The original retains _selectionFillColor here (a leak); it is released. */
- (void)dealloc
{
    [_pickColorCursor release];
    [_createSelectionTool release];
    [_modifySelectionKeyBindings release];
    [_selectionStartPoint release];
    CGPathRelease(_initialSelectionPath);
    [_finalizingCreateSelectionMode release];
    CGPathRelease(_drawingPath);
    CGEColorRelease(_fillColor);
    CGEColorRelease(_alternateFillColor);
    CGEColorRelease(_selectionFillColor);
    [_willCreateFreeHandSelectionCursor release];
    [_doCreateFreeHandSelectionCursor release];
    [_willCreateMagicWandSelectionCursor release];
    [_willCreateMagicLassoSelectionCursor release];
    [_doCreateMagicLassoSelectionCursor release];
    [_willCreateShapeSelectionCursor release];
    [_doCreateShapeSelectionCursor release];
    [_alternateWillCreateFreeHandSelectionCursor release];
    [_alternateDoCreateFreeHandSelectionCursor release];
    [_alternateWillCreateMagicWandSelectionCursor release];
    [_alternateWillCreateMagicLassoSelectionCursor release];
    [_alternateDoCreateMagicLassoSelectionCursor release];
    [_alternateWillCreateShapeSelectionCursor release];
    [_alternateDoCreateShapeSelectionCursor release];
    [super dealloc];
}

/* Magic wand selections, with no switching to the lasso or magic modes. */
- (id)init
{
    self = [super init];
    if (self == nil)
        return nil;
    _createSelectionTool = [[BTCreateSelectionTool alloc] init];
    if (_createSelectionTool == nil) {
        [self release];
        return nil;
    }
    [_createSelectionTool setInitialCreateSelectionMode:@"BTMagicWandCreateSelectionMode"];
    [_createSelectionTool setMagicSwitchingOption:NSUIntegerMax];
    [_createSelectionTool setLassoSwitchingOption:NSUIntegerMax];
    _colorPickingOption = NSEventModifierFlagCommand;
    _alternateFillColorOption = NSEventModifierFlagOption;
    return self;
}

@end
