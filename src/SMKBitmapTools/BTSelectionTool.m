#import "BTSelectionTool.h"
#import "BTCreateSelectionTool.h"
#import "BTModifySelectionTool.h"

/* The selection tool: a create selection tool makes a selection, then a
   modify selection tool moves, scales, rotates and flips it. A click outside
   a selection being modified removes it (one undo action) and goes back to
   creating, unless selection creation is disabled (no initial create
   selection mode); then the selection can only be set from outside. The
   start point, mode and initial path of a magic selection are kept so that a
   tolerance change can recreate it. */
@implementation BTSelectionTool

/* The create tool counts as a subtool while creation is enabled, even when
   the modify tool is the current one. */
static BOOL BTSelectionToolIsSubtool(BTSelectionTool *self, id aTool)
{
    return self->_currentSubtool == aTool
        || (aTool == self->_createSelectionTool && self->_isSelectionCreationEnabled);
}

/* The selection outputs come from the create tool only while it is the
   current subtool and the selection isn't being set from outside. */
static BOOL BTSelectionToolIsCreating(BTSelectionTool *self)
{
    return self->_currentSubtool == (BTTool *)self->_createSelectionTool && !self->_isExternalSelectionPath;
}

/* An undo invocation that restores the modify tool's selection with the
   current create selection info. */
static void BTSelectionToolRegisterUndoOfSelection(BTSelectionTool *self, id aManager)
{
    [[self prepareUndoInManager:aManager category:@"BTSelectionUndoCategory" withInvocationTarget:self]
        BTSelectionTool_setSelectionWithPath:[self->_modifySelectionTool selectionPath]
                             affineTransform:[self->_modifySelectionTool selectionAffineTransform]
                         flippedHorizontally:[self->_modifySelectionTool isSelectionFlippedHorizontally]
                                  startPoint:self->_selectionStartPoint
                                 initialPath:(id)self->_initialSelectionPath
               finalizingCreateSelectionMode:self->_finalizingCreateSelectionMode];
}

/* Makes the modify tool the current subtool; the tool is deactivated if it
   doesn't activate. */
static BOOL BTSelectionToolActivateModifyTool(BTSelectionTool *self)
{
    self->_currentSubtool = (BTTool *)self->_modifySelectionTool;
    if ([self->_currentSubtool activateWithDelegate:self inView:self->_view])
        return YES;
    [self performDeactivate];
    return NO;
}

- (id)layoutGuidingContextForTool:(id)aTool
{
    return _currentSubtool == aTool ? [_delegate layoutGuidingContextForTool:self] : nil;
}

- (id)mouseTrackingDelegateForTool:(id)aTool
{
    return _currentSubtool == aTool ? [_delegate mouseTrackingDelegateForTool:self] : nil;
}

- (id)imageViewTransformerForTool:(id)aTool
{
    return BTSelectionToolIsSubtool(self, aTool) ? [_delegate imageViewTransformerForTool:self] : nil;
}

- (id)tool:(id)aTool willSetUndoActionName:(id)aName
{
    return _currentSubtool == aTool ? [_delegate tool:self willSetUndoActionName:aName] : nil;
}

- (void)tool:(id)aTool willRegisterUndoInManager:(id)aManager category:(id)aCategory
{
    if (_currentSubtool == aTool)
        [_delegate tool:self willRegisterUndoInManager:aManager category:aCategory];
}

/* Only the selection category, and not while this tool sets the subtool's
   selection itself. */
- (id)undoManagerForTool:(id)aTool category:(id)aCategory
{
    if (_currentSubtool != aTool || _isSubtoolUndoDisabled || _isExternalSelectionPath
        || ![aCategory isEqualToString:@"BTSelectionUndoCategory"])
        return nil;
    return [_delegate undoManagerForTool:self category:@"BTSelectionUndoCategory"];
}

- (void)tool:(id)aTool didFinalizeOutputForKey:(id)aKey
{
    if (!BTSelectionToolIsSubtool(self, aTool))
        return;
    NSString *key;
    if (aTool == _modifySelectionTool) {
        if ([aKey isEqualToString:@"selectionAffineTransform"])
            key = @"selectionAffineTransform";
        else if ([aKey isEqualToString:@"isSelectionFlippedHorizontally"])
            key = @"isSelectionFlippedHorizontally";
        else
            return;
    } else if ([aKey isEqualToString:@"currentCreateSelectionMode"])
        key = @"currentCreateSelectionMode";
    else if ([aKey isEqualToString:@"selectionPath"])
        key = @"selectionPath";
    else if ([aKey isEqualToString:@"selectionStartPoint"])
        key = @"selectionStartPoint";
    else
        return;
    [_delegate tool:self didFinalizeOutputForKey:key];
}

- (void)tool:(id)aTool didUpdateOutputForKey:(id)aKey
{
    if (!BTSelectionToolIsSubtool(self, aTool))
        return;
    if (aTool == _modifySelectionTool) {
        if ([aKey isEqualToString:@"selectionAffineTransform"])
            [_delegate tool:self didUpdateOutputForKey:@"selectionAffineTransform"];
        else if ([aKey isEqualToString:@"isSelectionFlippedHorizontally"])
            [_delegate tool:self didUpdateOutputForKey:@"isSelectionFlippedHorizontally"];
    } else if ([aKey isEqualToString:@"currentCreateSelectionMode"]) {
        if (!_ignoresCurrentCreateSelectionModeUpdate)
            [_delegate tool:self didUpdateOutputForKey:@"currentCreateSelectionMode"];
    } else if ([aKey isEqualToString:@"selectionPath"]) {
        if (_currentSubtool == (BTTool *)_createSelectionTool)
            [_delegate tool:self didUpdateOutputForKey:@"selectionPath"];
    } else if ([aKey isEqualToString:@"selectionStartPoint"]) {
        if (_currentSubtool != (BTTool *)_createSelectionTool)
            return;
        [_selectionStartPoint release];
        _selectionStartPoint = [[_createSelectionTool selectionStartPoint] retain];
        [_finalizingCreateSelectionMode release];
        _finalizingCreateSelectionMode = [[self currentCreateSelectionMode] copy];
        [_delegate tool:self didUpdateOutputForKey:@"selectionStartPoint"];
    } else if ([aKey isEqualToString:@"initialSelectionPath"]) {
        CGPathRelease(_initialSelectionPath);
        _initialSelectionPath = (struct CGPath *)CGPathRetain((CGPathRef)[_createSelectionTool initialSelectionPath]);
    }
}

- (void)tool:(id)aTool willUpdateOutputForKey:(id)aKey
{
    if (!BTSelectionToolIsSubtool(self, aTool))
        return;
    if (aTool == _modifySelectionTool) {
        if ([aKey isEqualToString:@"selectionAffineTransform"])
            [_delegate tool:self willUpdateOutputForKey:@"selectionAffineTransform"];
        else if ([aKey isEqualToString:@"isSelectionFlippedHorizontally"])
            [_delegate tool:self willUpdateOutputForKey:@"isSelectionFlippedHorizontally"];
    } else if ([aKey isEqualToString:@"currentCreateSelectionMode"]) {
        if (!_ignoresCurrentCreateSelectionModeUpdate)
            [_delegate tool:self willUpdateOutputForKey:@"currentCreateSelectionMode"];
    } else if ([aKey isEqualToString:@"selectionPath"]) {
        if (_currentSubtool == (BTTool *)_createSelectionTool)
            [_delegate tool:self willUpdateOutputForKey:@"selectionPath"];
    } else if ([aKey isEqualToString:@"selectionStartPoint"]) {
        if (_currentSubtool == (BTTool *)_createSelectionTool)
            [_delegate tool:self willUpdateOutputForKey:@"selectionStartPoint"];
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

/* The click that ended a stage goes on to the new subtool, unless the
   delegate took it: the undo autogroup is closed first so the new subtool's
   changes are an undo action of their own. */
static BOOL BTSelectionToolResendEvent(BTSelectionTool *self, NSEvent *aEvent)
{
    NSUndoManager *manager = [self->_delegate undoManagerForTool:self category:@"BTSelectionUndoCategory"];
    if ([manager groupsByEvent] && [manager groupingLevel] == 1)
        [manager NSE_endUndoAutogroup];
    return [self sendEvent:aEvent];
}

/* A finished selection goes to the modify tool (a selection with no area is
   dropped). When the modify tool finishes, the selection is removed and the
   create tool takes over. The modify tool's waiting stage is reported as
   "waiting to modify". */
- (BOOL)tool:(id)aTool didFinalizeStage:(id)aStage withEvent:(id)aEvent nextStage:(id)aNextStage
{
    if (_currentSubtool != aTool)
        return NO;
    BOOL result;
    if (aTool == _createSelectionTool) {
        if (_isRecreatingSelectionPath) {
            if (aNextStage == nil) {
                [_modifySelectionTool setSelectionPath:[_createSelectionTool selectionPath]];
                BTSelectionToolActivateModifyTool(self);
            }
            return NO;
        }
        if (aNextStage != nil)
            return [_delegate tool:self didFinalizeStage:aStage withEvent:aEvent nextStage:aNextStage];
        id path = [_createSelectionTool selectionPath];
        if (CGPathIsEmpty((CGPathRef)path) || CGRectIsEmpty(CGEPathGetPathBoundingBox((CGPathRef)path)))
            path = nil;
        if (path == nil) {
            result = [_delegate tool:self didFinalizeStage:aStage withEvent:aEvent nextStage:nil];
            if (_currentSubtool == nil)
                return result;
            [self BTSelectionTool_resetCreateSelectionInfo];
        } else {
            result = [_delegate tool:self didFinalizeStage:aStage withEvent:aEvent
                           nextStage:@"BTWaitingToModifySelectionToolStage"];
            if (_currentSubtool == nil)
                return result;
            id manager = [_delegate undoManagerForTool:self category:@"BTSelectionUndoCategory"];
            if (manager != nil)
                [[self prepareUndoInManager:manager category:@"BTSelectionUndoCategory" withInvocationTarget:self]
                    BTSelectionTool_clearSelection];
            [_modifySelectionTool setSelectionPath:path];
            [_modifySelectionTool setSelectionAffineTransform:CGAffineTransformIdentity flippedHorizontally:NO];
            if (!BTSelectionToolActivateModifyTool(self))
                return result;
        }
        [_delegate tool:self didUpdateCursorWithEvent:aEvent];
        if (result || aEvent == nil)
            return result;
        if (path == nil && [aStage isEqualToString:@"BTWaitingToolStage"])
            return NO;
        return BTSelectionToolResendEvent(self, aEvent);
    }

    NSString *stage = [aStage isEqualToString:@"BTWaitingToolStage"] ? @"BTWaitingToModifySelectionToolStage" : aStage;
    if (aNextStage != nil) {
        NSString *next = [aNextStage isEqualToString:@"BTWaitingToolStage"]
            ? @"BTWaitingToModifySelectionToolStage" : aNextStage;
        return [_delegate tool:self didFinalizeStage:stage withEvent:aEvent nextStage:next];
    }
    result = [_delegate tool:self didFinalizeStage:stage withEvent:aEvent nextStage:nil];
    if (!_isSelectionCreationEnabled || _currentSubtool == nil)
        return result;
    [self beginUndoAction];
    id manager = [_delegate undoManagerForTool:self category:@"BTSelectionUndoCategory"];
    if (manager != nil)
        BTSelectionToolRegisterUndoOfSelection(self, manager);
    [_currentSubtool deactivate];
    _currentSubtool = (BTTool *)_createSelectionTool;
    [self BTSelectionTool_resetCreateSelectionInfo];
    [self endUndoActionWithName:@"Remove Selection"];
    [_delegate tool:self didUpdateCursorWithEvent:aEvent];
    if (result || aEvent == nil)
        return result;
    return BTSelectionToolResendEvent(self, aEvent);
}

/* The undo of a selection change (and of clearSelection): the selection
   goes back to the modify tool with its create selection info. Over the
   create tool the selection is set as an external one (its outputs are
   reported) and the modify tool takes over; otherwise the modify tool's
   transform is set without undo. */
- (void)BTSelectionTool_setSelectionWithPath:(id)aPath affineTransform:(id)aTransform flippedHorizontally:(BOOL)aFlipped startPoint:(id)aPoint initialPath:(id)aInitialPath finalizingCreateSelectionMode:(id)aMode
{
    BOOL creating = _currentSubtool == (BTTool *)_createSelectionTool;
    id manager = [_delegate undoManagerForTool:self category:@"BTSelectionUndoCategory"];
    if (manager != nil) {
        if (creating)
            [[self prepareUndoInManager:manager category:@"BTSelectionUndoCategory" withInvocationTarget:self]
                BTSelectionTool_clearSelection];
        else
            BTSelectionToolRegisterUndoOfSelection(self, manager);
    }
    [_delegate tool:self willUpdateOutputForKey:@"selectionStartPoint"];
    [_selectionStartPoint release];
    _selectionStartPoint = [aPoint retain];
    [_delegate tool:self didUpdateOutputForKey:@"selectionStartPoint"];
    [_finalizingCreateSelectionMode release];
    _finalizingCreateSelectionMode = [aMode retain];
    CGPathRelease(_initialSelectionPath);
    _initialSelectionPath = (struct CGPath *)CGPathRetain((CGPathRef)aInitialPath);

    creating = _currentSubtool == (BTTool *)_createSelectionTool;
    [_delegate tool:self willUpdateOutputForKey:@"selectionPath"];
    [_modifySelectionTool setSelectionPath:aPath];
    if (!creating) {
        [_delegate tool:self didUpdateOutputForKey:@"selectionPath"];
        _isSubtoolUndoDisabled = 1;
        [_modifySelectionTool setSelectionAffineTransform:aTransform];
        [_modifySelectionTool setSelectionFlippedHorizontally:aFlipped];
        _isSubtoolUndoDisabled = 0;
        return;
    }
    _isExternalSelectionPath = 1;
    [_delegate tool:self didUpdateOutputForKey:@"selectionPath"];
    [_delegate tool:self willUpdateOutputForKey:@"selectionAffineTransform"];
    [_modifySelectionTool setSelectionAffineTransform:aTransform];
    [_delegate tool:self didUpdateOutputForKey:@"selectionAffineTransform"];
    [_delegate tool:self willUpdateOutputForKey:@"isSelectionFlippedHorizontally"];
    [_modifySelectionTool setSelectionFlippedHorizontally:aFlipped];
    [_delegate tool:self didUpdateOutputForKey:@"isSelectionFlippedHorizontally"];
    [_delegate tool:self didFinalizeOutputForKey:@"selectionPath"];
    _isExternalSelectionPath = 0;
    if (BTSelectionToolActivateModifyTool(self))
        [_delegate tool:self didUpdateCursorWithEvent:nil];
}

/* The undo of setting a selection: back to creating (the create tool stays
   active under the modify tool, so it is just made current again), or with
   creation disabled an empty selection. */
- (void)BTSelectionTool_clearSelection
{
    id manager = [_delegate undoManagerForTool:self category:@"BTSelectionUndoCategory"];
    if (manager != nil)
        BTSelectionToolRegisterUndoOfSelection(self, manager);
    [self BTSelectionTool_resetCreateSelectionInfo];
    if (_isSelectionCreationEnabled) {
        [_currentSubtool deactivate];
        _currentSubtool = (BTTool *)_createSelectionTool;
        return;
    }
    [_modifySelectionTool setSelectionPath:nil];
    _isSubtoolUndoDisabled = 1;
    [_modifySelectionTool setSelectionAffineTransform:CGAffineTransformIdentity flippedHorizontally:NO];
    _isSubtoolUndoDisabled = 0;
}

- (void)tool:(id)aTool didUpdateCursorWithEvent:(id)aEvent
{
    if (BTSelectionToolIsSubtool(self, aTool))
        [_delegate tool:self didUpdateCursorWithEvent:aEvent];
}

- (void)finalize:(id)aSender
{
    if (_currentSubtool == (BTTool *)_modifySelectionTool)
        [_modifySelectionTool finalize:aSender];
}

- (BOOL)validateAction_finalize
{
    return _currentSubtool == (BTTool *)_modifySelectionTool && [_modifySelectionTool validateAction:@selector(finalize:)];
}

/* Selecting all goes through the create tool. */
- (void)selectAllArea:(id)aSender
{
    if (!_isSelectionCreationEnabled)
        return;
    if (_currentSubtool == (BTTool *)_modifySelectionTool && ![self BTSelectionTool_switchToCreateSelectionTool])
        return;
    [_currentSubtool performSelector:@selector(selectAllArea:) withObject:aSender];
}

/* Only from a waiting modify tool; the selection itself is left to the
   create tool's own select all. */
- (BOOL)BTSelectionTool_switchToCreateSelectionTool
{
    if (![[_modifySelectionTool currentStage] isEqualToString:@"BTWaitingToolStage"])
        return NO;
    [_delegate tool:self didFinalizeStage:@"BTWaitingToModifySelectionToolStage" withEvent:nil nextStage:nil];
    if (_currentSubtool == nil)
        return NO;
    [_currentSubtool deactivate];
    _currentSubtool = (BTTool *)_createSelectionTool;
    return YES;
}

- (BOOL)validateAction_selectAllArea
{
    return _isSelectionCreationEnabled && [_createSelectionTool performValidationSelector:@selector(selectAllArea:)];
}

- (void)moveSelectionBy:(CGSize)aOffset
{
    if (_currentSubtool == (BTTool *)_modifySelectionTool)
        [_modifySelectionTool moveSelectionBy:aOffset];
}

- (void)rotateSelectionAboutCenterBy:(CGFloat)aAngle
{
    if (_currentSubtool == (BTTool *)_modifySelectionTool)
        [_modifySelectionTool rotateSelectionAboutCenterBy:aAngle];
}

- (void)scaleSelectionAboutCenterBy:(CGSize)aScale
{
    if (_currentSubtool == (BTTool *)_modifySelectionTool)
        [_modifySelectionTool scaleSelectionAboutCenterBy:aScale];
}

- (void)flipSelectionVertically
{
    if (_currentSubtool == (BTTool *)_modifySelectionTool)
        [_modifySelectionTool flipSelectionVertically];
}

- (void)flipSelectionHorizontally
{
    if (_currentSubtool == (BTTool *)_modifySelectionTool)
        [_modifySelectionTool flipSelectionHorizontally];
}

- (void)posttransformSelectionUsingAffineTransform:(CGAffineTransform)aTransform flippingHorizontally:(BOOL)aFlip
{
    if (_currentSubtool == (BTTool *)_modifySelectionTool)
        [_modifySelectionTool posttransformSelectionUsingAffineTransform:aTransform flippingHorizontally:aFlip];
}

- (void)pretransformSelectionUsingAffineTransform:(CGAffineTransform)aTransform flippingHorizontally:(BOOL)aFlip
{
    if (_currentSubtool == (BTTool *)_modifySelectionTool)
        [_modifySelectionTool pretransformSelectionUsingAffineTransform:aTransform flippingHorizontally:aFlip];
}

- (void)setSelectionAffineTransform:(CGAffineTransform)aTransform flippingHorizontally:(BOOL)aFlip
{
    if (_currentSubtool == (BTTool *)_modifySelectionTool)
        [_modifySelectionTool setSelectionAffineTransform:aTransform flippingHorizontally:aFlip];
}

- (void)setSelectionAffineTransform:(CGAffineTransform)aTransform flippedHorizontally:(BOOL)aFlipped
{
    if (_currentSubtool == (BTTool *)_modifySelectionTool)
        [_modifySelectionTool setSelectionAffineTransform:aTransform flippedHorizontally:aFlipped];
}

/* While modifying, the create tool sees the flags too (for its cursors). */
- (BOOL)flagsChanged:(id)aEvent
{
    BOOL handled = NO;
    if (_currentSubtool == (BTTool *)_modifySelectionTool && _isSelectionCreationEnabled)
        handled = [_createSelectionTool flagsChanged:aEvent];
    if ([_currentSubtool flagsChanged:aEvent])
        handled = YES;
    return handled;
}

/* Outside the selection being modified the create tool's cursor shows. */
- (id)cursorForPoint:(NSPoint)aPoint modifierFlags:(NSUInteger)aFlags
{
    id cursor = [_currentSubtool cursorForPoint:aPoint modifierFlags:aFlags];
    if (cursor == nil && _currentSubtool == (BTTool *)_modifySelectionTool && _isSelectionCreationEnabled)
        cursor = [_createSelectionTool cursorForPoint:aPoint modifierFlags:aFlags];
    return cursor;
}

- (void)removeAllUndoActionsFromManager:(id)aManager
{
    [_modifySelectionTool removeAllUndoActionsFromManager:aManager];
    [super removeAllUndoActionsFromManager:aManager];
}

- (void)removeAllUndoActionsFromManager:(id)aManager category:(id)aCategory
{
    [_modifySelectionTool removeAllUndoActionsFromManager:aManager category:aCategory];
    [super removeAllUndoActionsFromManager:aManager category:aCategory];
}

- (id)allUndoCategories
{
    return [NSSet setWithObject:@"BTSelectionUndoCategory"];
}

- (id)currentStage
{
    if (_currentSubtool == nil)
        return @"BTWaitingToolStage";
    id stage = [_currentSubtool currentStage];
    if (_currentSubtool == (BTTool *)_modifySelectionTool && [stage isEqualToString:@"BTWaitingToolStage"])
        return @"BTWaitingToModifySelectionToolStage";
    return stage;
}

- (void)performDeactivate
{
    if (_currentSubtool == (BTTool *)_modifySelectionTool && _isSelectionCreationEnabled)
        [_createSelectionTool deactivate];
    [_currentSubtool deactivate];
    _currentSubtool = nil;
    _isExternalSelectionPath = 0;
    [super performDeactivate];
}

/* The create tool, or the modify tool when creation is disabled. */
- (BOOL)activateWithDelegate:(id)aDelegate inView:(id)aView
{
    if (![super activateWithDelegate:aDelegate inView:aView])
        return NO;
    _currentSubtool = _isSelectionCreationEnabled ? (BTTool *)_createSelectionTool : (BTTool *)_modifySelectionTool;
    if (![_currentSubtool activateWithDelegate:self inView:_view]) {
        _currentSubtool = nil;
        [super performDeactivate];
        return NO;
    }
    [_selectionStartPoint release];
    _selectionStartPoint = nil;
    CGPathRelease(_initialSelectionPath);
    _initialSelectionPath = NULL;
    [_finalizingCreateSelectionMode release];
    _finalizingCreateSelectionMode = nil;
    return YES;
}

- (void)changeViewInvalidationEnabledTo:(BOOL)aEnabled
{
    [super changeViewInvalidationEnabledTo:aEnabled];
    [_createSelectionTool setViewInvalidationEnabled:aEnabled];
    [_modifySelectionTool setViewInvalidationEnabled:aEnabled];
}

- (void)changeReferenceCGContextTo:(struct CGContext *)aContext
{
    [super changeReferenceCGContextTo:aContext];
    [_createSelectionTool setReferenceCGContext:aContext];
    [_modifySelectionTool setReferenceCGContext:aContext];
}

- (void)changeWorkPasteboardTo:(id)aPasteboard
{
    [super changeWorkPasteboardTo:aPasteboard];
    [_createSelectionTool setWorkPasteboard:aPasteboard];
    [_modifySelectionTool setWorkPasteboard:aPasteboard];
}

/* The original sends the subtools changeWorkImageTo: (not setWorkImage:, as
   the other compound tools do); kept. */
- (void)changeWorkImageTo:(id)aImage
{
    [super changeWorkImageTo:aImage];
    [_createSelectionTool changeWorkImageTo:aImage];
    [_modifySelectionTool changeWorkImageTo:aImage];
}

- (id)outputKeys
{
    return [NSArray arrayWithObjects:@"currentCreateSelectionMode", @"selectionStartPoint", @"selectionPath",
            @"selectionAffineTransform", @"selectionFlippedHorizontally", nil];
}

- (id)inputKeys
{
    return [NSArray arrayWithObjects:@"generalKeyBindings", @"initialCreateSelectionMode",
            @"selectionShapePrototypePath", @"alternateProportion", @"proportionalModePrimaryForCreation",
            @"proportionalModePrimaryForCorners", @"proportionalModePrimaryForSides", @"tolerance", @"selectionPath",
            @"selectionAffineTransform", @"selectionFlippedHorizontally", @"willCreateFreeHandSelectionCursor",
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

- (void)setSelectionFlippedHorizontally:(BOOL)aFlipped
{
    [_modifySelectionTool setSelectionFlippedHorizontally:aFlipped];
}

- (BOOL)isSelectionFlippedHorizontally
{
    return BTSelectionToolIsCreating(self) ? NO : [_modifySelectionTool isSelectionFlippedHorizontally];
}

- (void)setSelectionAffineTransform:(id)aTransform
{
    [_modifySelectionTool setSelectionAffineTransform:aTransform];
}

- (id)selectionAffineTransform
{
    return BTSelectionToolIsCreating(self) ? nil : [_modifySelectionTool selectionAffineTransform];
}

/* Setting a selection (one undo action) hands it to the modify tool; no
   selection removes it and goes back to creating. */
- (void)setSelectionPath:(id)aPath
{
    if (_currentSubtool == nil) {
        [_modifySelectionTool setSelectionPath:aPath];
        return;
    }
    if (_currentSubtool == (BTTool *)_createSelectionTool) {
        if (aPath == nil)
            return;
        [self beginUndoAction];
        id manager = [_delegate undoManagerForTool:self category:@"BTSelectionUndoCategory"];
        if (manager != nil)
            [[self prepareUndoInManager:manager category:@"BTSelectionUndoCategory" withInvocationTarget:self]
                BTSelectionTool_clearSelection];
        [_modifySelectionTool setSelectionPath:aPath];
        [self endUndoActionWithName:@"Set Selection"];
        if ([_modifySelectionTool activateWithDelegate:self inView:_view]) {
            _currentSubtool = (BTTool *)_modifySelectionTool;
            [_delegate tool:self didUpdateCursorWithEvent:nil];
        }
        return;
    }
    [self beginUndoAction];
    id manager = [_delegate undoManagerForTool:self category:@"BTSelectionUndoCategory"];
    if (manager != nil)
        BTSelectionToolRegisterUndoOfSelection(self, manager);
    [_modifySelectionTool setSelectionPath:aPath];
    [self BTSelectionTool_resetCreateSelectionInfo];
    [self endUndoActionWithName:aPath != nil ? @"Set Selection" : @"Remove Selection"];
    if (aPath == nil && _isSelectionCreationEnabled) {
        [_currentSubtool deactivate];
        _currentSubtool = (BTTool *)_createSelectionTool;
    }
}

- (id)selectionPath
{
    return BTSelectionToolIsCreating(self) ? [_createSelectionTool selectionPath] : [_modifySelectionTool selectionPath];
}

- (id)selectionStartPoint
{
    return _selectionStartPoint;
}

- (void)setProportionalModePrimaryForSides:(BOOL)aPrimary
{
    [_modifySelectionTool setProportionalModePrimaryForSides:aPrimary];
}

- (BOOL)isProportionalModePrimaryForSides
{
    return [_modifySelectionTool isProportionalModePrimaryForSides];
}

- (BOOL)defaultProportionalModePrimaryForSides
{
    return [_modifySelectionTool defaultProportionalModePrimaryForSides];
}

- (void)setProportionalModePrimaryForCorners:(BOOL)aPrimary
{
    [_modifySelectionTool setProportionalModePrimaryForCorners:aPrimary];
}

- (BOOL)isProportionalModePrimaryForCorners
{
    return [_modifySelectionTool isProportionalModePrimaryForCorners];
}

- (BOOL)defaultProportionalModePrimaryForCorners
{
    return [_modifySelectionTool defaultProportionalModePrimaryForCorners];
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

/* A real change (more than 1/512) recreates an untransformed magic
   selection waiting to be modified from its start point: the create tool
   finalizes it again and didFinalizeStage hands it back to the modify tool. */
- (void)setTolerance:(CGFloat)aTolerance
{
    CGFloat tolerance = [_createSelectionTool tolerance];
    if (aTolerance >= tolerance - 0.001953125 && aTolerance <= tolerance + 0.001953125)
        return;
    [_createSelectionTool setTolerance:aTolerance];
    if (_currentSubtool != (BTTool *)_modifySelectionTool || _selectionStartPoint == nil || !_isSelectionCreationEnabled)
        return;
    CGAffineTransform transform = CGAffineTransformIdentity;
    [[_modifySelectionTool selectionAffineTransform] getValue:&transform];
    if (!CGAffineTransformEqualToTransform(transform, CGAffineTransformIdentity)
        || ![[_modifySelectionTool currentStage] isEqualToString:@"BTWaitingToolStage"])
        return;
    id manager = [_delegate undoManagerForTool:self category:@"BTSelectionUndoCategory"];
    if (manager != nil)
        [[self prepareUndoInManager:manager category:@"BTSelectionUndoCategory" withInvocationTarget:self]
            BTSelectionTool_setSelectionPath:[_modifySelectionTool selectionPath]];
    [_currentSubtool deactivate];
    _currentSubtool = (BTTool *)_createSelectionTool;
    [_createSelectionTool setFinalizingCreateSelectionMode:_finalizingCreateSelectionMode];
    [_createSelectionTool setSelectionStartPoint:_selectionStartPoint];
    [_createSelectionTool setInitialSelectionPath:(id)_initialSelectionPath];
    _isRecreatingSelectionPath = 1;
    [_createSelectionTool doCommandBySelector:@selector(finalizeSelectionPath:)];
    _isRecreatingSelectionPath = 0;
}

- (void)BTSelectionTool_setSelectionPath:(id)aPath
{
    id manager = [_delegate undoManagerForTool:self category:@"BTSelectionUndoCategory"];
    if (manager != nil)
        [[self prepareUndoInManager:manager category:@"BTSelectionUndoCategory" withInvocationTarget:self]
            BTSelectionTool_setSelectionPath:[_modifySelectionTool selectionPath]];
    [_delegate tool:self willUpdateOutputForKey:@"selectionPath"];
    [_modifySelectionTool setSelectionPath:aPath];
    [_delegate tool:self didUpdateOutputForKey:@"selectionPath"];
}

- (CGFloat)tolerance
{
    return [_createSelectionTool tolerance];
}

- (id)currentCreateSelectionMode
{
    return _isSelectionCreationEnabled ? [_createSelectionTool currentCreateSelectionMode] : nil;
}

/* A mode enables selection creation (activating the create tool under a
   modify tool); nil disables it, finishing a selection being created. As in
   the original, the whole tool is deactivated when the create tool isn't
   active after a mode is set, even if this tool wasn't active. */
- (void)setInitialCreateSelectionMode:(id)aMode
{
    if (aMode != nil) {
        _ignoresCurrentCreateSelectionModeUpdate = 1;
        [_delegate tool:self willUpdateOutputForKey:@"currentCreateSelectionMode"];
        [_createSelectionTool setInitialCreateSelectionMode:aMode];
        if (!_isSelectionCreationEnabled) {
            _isSelectionCreationEnabled = 1;
            if (_currentSubtool == (BTTool *)_modifySelectionTool)
                [_createSelectionTool activateWithDelegate:self inView:_view];
        }
        [_delegate tool:self didUpdateOutputForKey:@"currentCreateSelectionMode"];
        _ignoresCurrentCreateSelectionModeUpdate = 0;
        if (![_createSelectionTool isActive])
            [self performDeactivate];
        return;
    }
    if (!_isSelectionCreationEnabled)
        return;
    [_delegate tool:self willUpdateOutputForKey:@"currentCreateSelectionMode"];
    _isSelectionCreationEnabled = 0;
    [_delegate tool:self didUpdateOutputForKey:@"currentCreateSelectionMode"];
    if (_currentSubtool != (BTTool *)_createSelectionTool)
        return;
    [_delegate tool:self didFinalizeStage:[_currentSubtool currentStage] withEvent:nil nextStage:nil];
    if (_currentSubtool == nil)
        return;
    [_currentSubtool deactivate];
    if (BTSelectionToolActivateModifyTool(self))
        [_delegate tool:self didUpdateCursorWithEvent:nil];
}

- (id)initialCreateSelectionMode
{
    return _isSelectionCreationEnabled ? [_createSelectionTool initialCreateSelectionMode] : nil;
}

/* Cursors belong to the subtools: rotate, resize and move to the modify
   tool, create to the create tool. */
- (void)setDoRotateBottomCenterSelectionCursor:(id)aCursor
{
    [_modifySelectionTool setDoRotateBottomCenterSelectionCursor:aCursor];
}

- (id)doRotateBottomCenterSelectionCursor
{
    return [_modifySelectionTool doRotateBottomCenterSelectionCursor];
}

- (id)defaultDoRotateBottomCenterSelectionCursor
{
    return [_modifySelectionTool defaultDoRotateBottomCenterSelectionCursor];
}

- (void)setWillRotateBottomCenterSelectionCursor:(id)aCursor
{
    [_modifySelectionTool setWillRotateBottomCenterSelectionCursor:aCursor];
}

- (id)willRotateBottomCenterSelectionCursor
{
    return [_modifySelectionTool willRotateBottomCenterSelectionCursor];
}

- (id)defaultWillRotateBottomCenterSelectionCursor
{
    return [_modifySelectionTool defaultWillRotateBottomCenterSelectionCursor];
}

- (void)setDoRotateBottomRightSelectionCursor:(id)aCursor
{
    [_modifySelectionTool setDoRotateBottomRightSelectionCursor:aCursor];
}

- (id)doRotateBottomRightSelectionCursor
{
    return [_modifySelectionTool doRotateBottomRightSelectionCursor];
}

- (id)defaultDoRotateBottomRightSelectionCursor
{
    return [_modifySelectionTool defaultDoRotateBottomRightSelectionCursor];
}

- (void)setWillRotateBottomRightSelectionCursor:(id)aCursor
{
    [_modifySelectionTool setWillRotateBottomRightSelectionCursor:aCursor];
}

- (id)willRotateBottomRightSelectionCursor
{
    return [_modifySelectionTool willRotateBottomRightSelectionCursor];
}

- (id)defaultWillRotateBottomRightSelectionCursor
{
    return [_modifySelectionTool defaultWillRotateBottomRightSelectionCursor];
}

- (void)setDoRotateCenterRightSelectionCursor:(id)aCursor
{
    [_modifySelectionTool setDoRotateCenterRightSelectionCursor:aCursor];
}

- (id)doRotateCenterRightSelectionCursor
{
    return [_modifySelectionTool doRotateCenterRightSelectionCursor];
}

- (id)defaultDoRotateCenterRightSelectionCursor
{
    return [_modifySelectionTool defaultDoRotateCenterRightSelectionCursor];
}

- (void)setWillRotateCenterRightSelectionCursor:(id)aCursor
{
    [_modifySelectionTool setWillRotateCenterRightSelectionCursor:aCursor];
}

- (id)willRotateCenterRightSelectionCursor
{
    return [_modifySelectionTool willRotateCenterRightSelectionCursor];
}

- (id)defaultWillRotateCenterRightSelectionCursor
{
    return [_modifySelectionTool defaultWillRotateCenterRightSelectionCursor];
}

- (void)setDoRotateTopRightSelectionCursor:(id)aCursor
{
    [_modifySelectionTool setDoRotateTopRightSelectionCursor:aCursor];
}

- (id)doRotateTopRightSelectionCursor
{
    return [_modifySelectionTool doRotateTopRightSelectionCursor];
}

- (id)defaultDoRotateTopRightSelectionCursor
{
    return [_modifySelectionTool defaultDoRotateTopRightSelectionCursor];
}

- (void)setWillRotateTopRightSelectionCursor:(id)aCursor
{
    [_modifySelectionTool setWillRotateTopRightSelectionCursor:aCursor];
}

- (id)willRotateTopRightSelectionCursor
{
    return [_modifySelectionTool willRotateTopRightSelectionCursor];
}

- (id)defaultWillRotateTopRightSelectionCursor
{
    return [_modifySelectionTool defaultWillRotateTopRightSelectionCursor];
}

- (void)setDoRotateTopCenterSelectionCursor:(id)aCursor
{
    [_modifySelectionTool setDoRotateTopCenterSelectionCursor:aCursor];
}

- (id)doRotateTopCenterSelectionCursor
{
    return [_modifySelectionTool doRotateTopCenterSelectionCursor];
}

- (id)defaultDoRotateTopCenterSelectionCursor
{
    return [_modifySelectionTool defaultDoRotateTopCenterSelectionCursor];
}

- (void)setWillRotateTopCenterSelectionCursor:(id)aCursor
{
    [_modifySelectionTool setWillRotateTopCenterSelectionCursor:aCursor];
}

- (id)willRotateTopCenterSelectionCursor
{
    return [_modifySelectionTool willRotateTopCenterSelectionCursor];
}

- (id)defaultWillRotateTopCenterSelectionCursor
{
    return [_modifySelectionTool defaultWillRotateTopCenterSelectionCursor];
}

- (void)setDoRotateTopLeftSelectionCursor:(id)aCursor
{
    [_modifySelectionTool setDoRotateTopLeftSelectionCursor:aCursor];
}

- (id)doRotateTopLeftSelectionCursor
{
    return [_modifySelectionTool doRotateTopLeftSelectionCursor];
}

- (id)defaultDoRotateTopLeftSelectionCursor
{
    return [_modifySelectionTool defaultDoRotateTopLeftSelectionCursor];
}

- (void)setWillRotateTopLeftSelectionCursor:(id)aCursor
{
    [_modifySelectionTool setWillRotateTopLeftSelectionCursor:aCursor];
}

- (id)willRotateTopLeftSelectionCursor
{
    return [_modifySelectionTool willRotateTopLeftSelectionCursor];
}

- (id)defaultWillRotateTopLeftSelectionCursor
{
    return [_modifySelectionTool defaultWillRotateTopLeftSelectionCursor];
}

- (void)setDoRotateCenterLeftSelectionCursor:(id)aCursor
{
    [_modifySelectionTool setDoRotateCenterLeftSelectionCursor:aCursor];
}

- (id)doRotateCenterLeftSelectionCursor
{
    return [_modifySelectionTool doRotateCenterLeftSelectionCursor];
}

- (id)defaultDoRotateCenterLeftSelectionCursor
{
    return [_modifySelectionTool defaultDoRotateCenterLeftSelectionCursor];
}

- (void)setWillRotateCenterLeftSelectionCursor:(id)aCursor
{
    [_modifySelectionTool setWillRotateCenterLeftSelectionCursor:aCursor];
}

- (id)willRotateCenterLeftSelectionCursor
{
    return [_modifySelectionTool willRotateCenterLeftSelectionCursor];
}

- (id)defaultWillRotateCenterLeftSelectionCursor
{
    return [_modifySelectionTool defaultWillRotateCenterLeftSelectionCursor];
}

- (void)setDoRotateBottomLeftSelectionCursor:(id)aCursor
{
    [_modifySelectionTool setDoRotateBottomLeftSelectionCursor:aCursor];
}

- (id)doRotateBottomLeftSelectionCursor
{
    return [_modifySelectionTool doRotateBottomLeftSelectionCursor];
}

- (id)defaultDoRotateBottomLeftSelectionCursor
{
    return [_modifySelectionTool defaultDoRotateBottomLeftSelectionCursor];
}

- (void)setWillRotateBottomLeftSelectionCursor:(id)aCursor
{
    [_modifySelectionTool setWillRotateBottomLeftSelectionCursor:aCursor];
}

- (id)willRotateBottomLeftSelectionCursor
{
    return [_modifySelectionTool willRotateBottomLeftSelectionCursor];
}

- (id)defaultWillRotateBottomLeftSelectionCursor
{
    return [_modifySelectionTool defaultWillRotateBottomLeftSelectionCursor];
}

- (void)setDoResizeBottomCenterSelectionCursor:(id)aCursor
{
    [_modifySelectionTool setDoResizeBottomCenterSelectionCursor:aCursor];
}

- (id)doResizeBottomCenterSelectionCursor
{
    return [_modifySelectionTool doResizeBottomCenterSelectionCursor];
}

- (id)defaultDoResizeBottomCenterSelectionCursor
{
    return [_modifySelectionTool defaultDoResizeBottomCenterSelectionCursor];
}

- (void)setWillResizeBottomCenterSelectionCursor:(id)aCursor
{
    [_modifySelectionTool setWillResizeBottomCenterSelectionCursor:aCursor];
}

- (id)willResizeBottomCenterSelectionCursor
{
    return [_modifySelectionTool willResizeBottomCenterSelectionCursor];
}

- (id)defaultWillResizeBottomCenterSelectionCursor
{
    return [_modifySelectionTool defaultWillResizeBottomCenterSelectionCursor];
}

- (void)setDoResizeBottomRightSelectionCursor:(id)aCursor
{
    [_modifySelectionTool setDoResizeBottomRightSelectionCursor:aCursor];
}

- (id)doResizeBottomRightSelectionCursor
{
    return [_modifySelectionTool doResizeBottomRightSelectionCursor];
}

- (id)defaultDoResizeBottomRightSelectionCursor
{
    return [_modifySelectionTool defaultDoResizeBottomRightSelectionCursor];
}

- (void)setWillResizeBottomRightSelectionCursor:(id)aCursor
{
    [_modifySelectionTool setWillResizeBottomRightSelectionCursor:aCursor];
}

- (id)willResizeBottomRightSelectionCursor
{
    return [_modifySelectionTool willResizeBottomRightSelectionCursor];
}

- (id)defaultWillResizeBottomRightSelectionCursor
{
    return [_modifySelectionTool defaultWillResizeBottomRightSelectionCursor];
}

- (void)setDoResizeCenterRightSelectionCursor:(id)aCursor
{
    [_modifySelectionTool setDoResizeCenterRightSelectionCursor:aCursor];
}

- (id)doResizeCenterRightSelectionCursor
{
    return [_modifySelectionTool doResizeCenterRightSelectionCursor];
}

- (id)defaultDoResizeCenterRightSelectionCursor
{
    return [_modifySelectionTool defaultDoResizeCenterRightSelectionCursor];
}

- (void)setWillResizeCenterRightSelectionCursor:(id)aCursor
{
    [_modifySelectionTool setWillResizeCenterRightSelectionCursor:aCursor];
}

- (id)willResizeCenterRightSelectionCursor
{
    return [_modifySelectionTool willResizeCenterRightSelectionCursor];
}

- (id)defaultWillResizeCenterRightSelectionCursor
{
    return [_modifySelectionTool defaultWillResizeCenterRightSelectionCursor];
}

- (void)setDoResizeTopRightSelectionCursor:(id)aCursor
{
    [_modifySelectionTool setDoResizeTopRightSelectionCursor:aCursor];
}

- (id)doResizeTopRightSelectionCursor
{
    return [_modifySelectionTool doResizeTopRightSelectionCursor];
}

- (id)defaultDoResizeTopRightSelectionCursor
{
    return [_modifySelectionTool defaultDoResizeTopRightSelectionCursor];
}

- (void)setWillResizeTopRightSelectionCursor:(id)aCursor
{
    [_modifySelectionTool setWillResizeTopRightSelectionCursor:aCursor];
}

- (id)willResizeTopRightSelectionCursor
{
    return [_modifySelectionTool willResizeTopRightSelectionCursor];
}

- (id)defaultWillResizeTopRightSelectionCursor
{
    return [_modifySelectionTool defaultWillResizeTopRightSelectionCursor];
}

- (void)setDoResizeTopCenterSelectionCursor:(id)aCursor
{
    [_modifySelectionTool setDoResizeTopCenterSelectionCursor:aCursor];
}

- (id)doResizeTopCenterSelectionCursor
{
    return [_modifySelectionTool doResizeTopCenterSelectionCursor];
}

- (id)defaultDoResizeTopCenterSelectionCursor
{
    return [_modifySelectionTool defaultDoResizeTopCenterSelectionCursor];
}

- (void)setWillResizeTopCenterSelectionCursor:(id)aCursor
{
    [_modifySelectionTool setWillResizeTopCenterSelectionCursor:aCursor];
}

- (id)willResizeTopCenterSelectionCursor
{
    return [_modifySelectionTool willResizeTopCenterSelectionCursor];
}

- (id)defaultWillResizeTopCenterSelectionCursor
{
    return [_modifySelectionTool defaultWillResizeTopCenterSelectionCursor];
}

- (void)setDoResizeTopLeftSelectionCursor:(id)aCursor
{
    [_modifySelectionTool setDoResizeTopLeftSelectionCursor:aCursor];
}

- (id)doResizeTopLeftSelectionCursor
{
    return [_modifySelectionTool doResizeTopLeftSelectionCursor];
}

- (id)defaultDoResizeTopLeftSelectionCursor
{
    return [_modifySelectionTool defaultDoResizeTopLeftSelectionCursor];
}

- (void)setWillResizeTopLeftSelectionCursor:(id)aCursor
{
    [_modifySelectionTool setWillResizeTopLeftSelectionCursor:aCursor];
}

- (id)willResizeTopLeftSelectionCursor
{
    return [_modifySelectionTool willResizeTopLeftSelectionCursor];
}

- (id)defaultWillResizeTopLeftSelectionCursor
{
    return [_modifySelectionTool defaultWillResizeTopLeftSelectionCursor];
}

- (void)setDoResizeCenterLeftSelectionCursor:(id)aCursor
{
    [_modifySelectionTool setDoResizeCenterLeftSelectionCursor:aCursor];
}

- (id)doResizeCenterLeftSelectionCursor
{
    return [_modifySelectionTool doResizeCenterLeftSelectionCursor];
}

- (id)defaultDoResizeCenterLeftSelectionCursor
{
    return [_modifySelectionTool defaultDoResizeCenterLeftSelectionCursor];
}

- (void)setWillResizeCenterLeftSelectionCursor:(id)aCursor
{
    [_modifySelectionTool setWillResizeCenterLeftSelectionCursor:aCursor];
}

- (id)willResizeCenterLeftSelectionCursor
{
    return [_modifySelectionTool willResizeCenterLeftSelectionCursor];
}

- (id)defaultWillResizeCenterLeftSelectionCursor
{
    return [_modifySelectionTool defaultWillResizeCenterLeftSelectionCursor];
}

- (void)setDoResizeBottomLeftSelectionCursor:(id)aCursor
{
    [_modifySelectionTool setDoResizeBottomLeftSelectionCursor:aCursor];
}

- (id)doResizeBottomLeftSelectionCursor
{
    return [_modifySelectionTool doResizeBottomLeftSelectionCursor];
}

- (id)defaultDoResizeBottomLeftSelectionCursor
{
    return [_modifySelectionTool defaultDoResizeBottomLeftSelectionCursor];
}

- (void)setWillResizeBottomLeftSelectionCursor:(id)aCursor
{
    [_modifySelectionTool setWillResizeBottomLeftSelectionCursor:aCursor];
}

- (id)willResizeBottomLeftSelectionCursor
{
    return [_modifySelectionTool willResizeBottomLeftSelectionCursor];
}

- (id)defaultWillResizeBottomLeftSelectionCursor
{
    return [_modifySelectionTool defaultWillResizeBottomLeftSelectionCursor];
}

- (void)setDoMoveSelectionCursor:(id)aCursor
{
    [_modifySelectionTool setDoMoveSelectionCursor:aCursor];
}

- (id)doMoveSelectionCursor
{
    return [_modifySelectionTool doMoveSelectionCursor];
}

- (id)defaultDoMoveSelectionCursor
{
    return [_modifySelectionTool defaultDoMoveSelectionCursor];
}

- (void)setWillMoveSelectionCursor:(id)aCursor
{
    [_modifySelectionTool setWillMoveSelectionCursor:aCursor];
}

- (id)willMoveSelectionCursor
{
    return [_modifySelectionTool willMoveSelectionCursor];
}

- (id)defaultWillMoveSelectionCursor
{
    return [_modifySelectionTool defaultWillMoveSelectionCursor];
}

- (void)setDoCreateShapeSelectionCursor:(id)aCursor
{
    [_createSelectionTool setDoCreateShapeSelectionCursor:aCursor];
}

- (id)doCreateShapeSelectionCursor
{
    return [_createSelectionTool doCreateShapeSelectionCursor];
}

- (id)defaultDoCreateShapeSelectionCursor
{
    return [_createSelectionTool defaultDoCreateShapeSelectionCursor];
}

- (void)setWillCreateShapeSelectionCursor:(id)aCursor
{
    [_createSelectionTool setWillCreateShapeSelectionCursor:aCursor];
}

- (id)willCreateShapeSelectionCursor
{
    return [_createSelectionTool willCreateShapeSelectionCursor];
}

- (id)defaultWillCreateShapeSelectionCursor
{
    return [_createSelectionTool defaultWillCreateShapeSelectionCursor];
}

- (void)setDoCreateMagicLassoSelectionCursor:(id)aCursor
{
    [_createSelectionTool setDoCreateMagicLassoSelectionCursor:aCursor];
}

- (id)doCreateMagicLassoSelectionCursor
{
    return [_createSelectionTool doCreateMagicLassoSelectionCursor];
}

- (id)defaultDoCreateMagicLassoSelectionCursor
{
    return [_createSelectionTool defaultDoCreateMagicLassoSelectionCursor];
}

- (void)setWillCreateMagicLassoSelectionCursor:(id)aCursor
{
    [_createSelectionTool setWillCreateMagicLassoSelectionCursor:aCursor];
}

- (id)willCreateMagicLassoSelectionCursor
{
    return [_createSelectionTool willCreateMagicLassoSelectionCursor];
}

- (id)defaultWillCreateMagicLassoSelectionCursor
{
    return [_createSelectionTool defaultWillCreateMagicLassoSelectionCursor];
}

- (void)setWillCreateMagicWandSelectionCursor:(id)aCursor
{
    [_createSelectionTool setWillCreateMagicWandSelectionCursor:aCursor];
}

- (id)willCreateMagicWandSelectionCursor
{
    return [_createSelectionTool willCreateMagicWandSelectionCursor];
}

- (id)defaultWillCreateMagicWandSelectionCursor
{
    return [_createSelectionTool defaultWillCreateMagicWandSelectionCursor];
}

- (void)setDoCreateFreeHandSelectionCursor:(id)aCursor
{
    [_createSelectionTool setDoCreateFreeHandSelectionCursor:aCursor];
}

- (id)doCreateFreeHandSelectionCursor
{
    return [_createSelectionTool doCreateFreeHandSelectionCursor];
}

- (id)defaultDoCreateFreeHandSelectionCursor
{
    return [_createSelectionTool defaultDoCreateFreeHandSelectionCursor];
}

- (void)setWillCreateFreeHandSelectionCursor:(id)aCursor
{
    [_createSelectionTool setWillCreateFreeHandSelectionCursor:aCursor];
}

- (id)willCreateFreeHandSelectionCursor
{
    return [_createSelectionTool willCreateFreeHandSelectionCursor];
}

- (id)defaultWillCreateFreeHandSelectionCursor
{
    return [_createSelectionTool defaultWillCreateFreeHandSelectionCursor];
}

- (void)BTSelectionTool_resetCreateSelectionInfo
{
    if (_selectionStartPoint != nil) {
        [_delegate tool:self willUpdateOutputForKey:@"selectionStartPoint"];
        [_selectionStartPoint release];
        _selectionStartPoint = nil;
        [_delegate tool:self didUpdateOutputForKey:@"selectionStartPoint"];
    }
    CGPathRelease(_initialSelectionPath);
    _initialSelectionPath = NULL;
    [_finalizingCreateSelectionMode release];
    _finalizingCreateSelectionMode = nil;
}

- (void)dealloc
{
    [_modifySelectionTool release];
    [_createSelectionTool release];
    [_selectionStartPoint release];
    CGPathRelease(_initialSelectionPath);
    [_finalizingCreateSelectionMode release];
    [super dealloc];
}

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
    _modifySelectionTool = [[BTModifySelectionTool alloc] init];
    if (_modifySelectionTool == nil) {
        [self release];
        return nil;
    }
    _isSelectionCreationEnabled = 1;
    return self;
}

- (void)setProportionalMode:(BOOL)aMode
{
    [_modifySelectionTool setProportionalMode:aMode];
    [_createSelectionTool setProportionalMode:aMode];
}

- (BOOL)isProportionalMode
{
    return [_modifySelectionTool isProportionalMode] && [_createSelectionTool isProportionalMode];
}

- (BOOL)defaultProportionalMode
{
    return [_modifySelectionTool defaultProportionalMode] && [_createSelectionTool defaultProportionalMode];
}

- (void)setIgnoreClickOutsidePath:(BOOL)aIgnore
{
    [_modifySelectionTool setIgnoreClickOutsidePath:aIgnore];
}

- (BOOL)isIgnoreClickOutsidePath
{
    return [_modifySelectionTool isIgnoreClickOutsidePath];
}

- (BOOL)defaultIgnoreClickOutsidePath
{
    return [_modifySelectionTool defaultIgnoreClickOutsidePath];
}

@end
