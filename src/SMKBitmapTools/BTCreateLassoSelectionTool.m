#import "BTCreateLassoSelectionTool.h"
#import "BTCreateFreeHandSelectionTool.h"
#import "BTCreateMagicWandSelectionTool.h"
#import "NSWindow+BTEvents.h"

/* The lasso tool drives two subtools: free hand selection, whose path can be
   refined into a magic lasso by tracing the image pixels inside it, and the
   magic wand. Modifier options switch between free hand and magic lasso, and
   between the lasso and the magic wand. */
@implementation BTCreateLassoSelectionTool

- (id)layoutGuidingContextForTool:(id)aTool
{
    if (_createFreeHandSelectionTool == aTool || _createMagicWandSelectionTool == aTool)
        return [_delegate layoutGuidingContextForTool:self];
    return nil;
}

- (id)mouseTrackingDelegateForTool:(id)aTool
{
    return _currentSubtool == aTool ? [_delegate mouseTrackingDelegateForTool:self] : nil;
}

- (id)imageViewTransformerForTool:(id)aTool
{
    if (_createFreeHandSelectionTool == aTool || _createMagicWandSelectionTool == aTool)
        return [_delegate imageViewTransformerForTool:self];
    return nil;
}

/* Free hand undo names are renamed while in magic lasso mode. */
- (id)tool:(id)aTool willSetUndoActionName:(id)aName
{
    if (_currentSubtool != aTool)
        return nil;
    if (_currentSubtool == _createFreeHandSelectionTool && ![self BTCreateLassoSelectionTool_isInFreeHandMode]) {
        if ([aName isEqualToString:@"Create Free Hand Selection"])
            aName = @"Create Magic Lasso Selection";
        else if ([aName isEqualToString:@"Create All Area Free Hand Selection"])
            aName = @"Create All Area Magic Lasso Selection";
    }
    [self setUndoActionName:aName];
    return nil;
}

- (void)tool:(id)aTool willRegisterUndoInManager:(id)aManager category:(id)aCategory
{
}

- (id)undoManagerForTool:(id)aTool category:(id)aCategory
{
    return nil;
}

/* A finished free hand path becomes the initial path; in magic lasso mode the
   selection is traced from the image inside it. */
- (void)tool:(id)aTool didFinalizeOutputForKey:(id)aKey
{
    if (_currentSubtool != aTool)
        return;
    if ([aKey isEqualToString:@"selectionPath"]) {
        if (_selectionPath == NULL) {
            CGPathRef path;
            if (_currentSubtool == _createFreeHandSelectionTool) {
                id freeHandPath = [_createFreeHandSelectionTool selectionPath];
                if (freeHandPath == nil)
                    goto finalize;
                [_delegate tool:self willUpdateOutputForKey:@"initialSelectionPath"];
                CGPathRelease(_initialSelectionPath);
                _initialSelectionPath = CGPathCreateCopy((CGPathRef)freeHandPath);
                [_delegate tool:self didUpdateOutputForKey:@"initialSelectionPath"];
                [_delegate tool:self didFinalizeOutputForKey:@"initialSelectionPath"];
                if (![self BTCreateLassoSelectionTool_isInFreeHandMode]) {
                    id start = [_createFreeHandSelectionTool selectionStartPoint];
                    if (start == nil)
                        goto finalize;
                    path = [self BTCreateLassoSelectionTool_createLassoPathWithInitialPath:(CGPathRef)freeHandPath startPoint:[start pointValue] tolerance:_tolerance shouldSmooth:_shouldSmoothSelectionPath];
                } else {
                    path = CGPathRetain(_initialSelectionPath);
                }
            } else {
                path = CGPathCreateCopy((CGPathRef)[_createMagicWandSelectionTool selectionPath]);
            }
            if (path != NULL) {
                [_delegate tool:self willUpdateOutputForKey:@"selectionPath"];
                _selectionPath = path;
                [_delegate tool:self didUpdateOutputForKey:@"selectionPath"];
            }
        }
    } else if ([aKey isEqualToString:@"selectionStartPoint"]) {
        [_delegate tool:self willUpdateOutputForKey:@"selectionStartPoint"];
        [_selectionStartPointValue release];
        _selectionStartPointValue = [[(id)_currentSubtool selectionStartPoint] copy];
        [_delegate tool:self didUpdateOutputForKey:@"selectionStartPoint"];
    } else {
        return;
    }
finalize:
    [_delegate tool:self didFinalizeOutputForKey:aKey];
}

- (void)tool:(id)aTool didUpdateOutputForKey:(id)aKey
{
}

/* A subtool changing its path invalidates the traced selection. */
- (void)tool:(id)aTool willUpdateOutputForKey:(id)aKey
{
    if (_currentSubtool == aTool && [aKey isEqualToString:@"selectionPath"] && _selectionPath != NULL) {
        [_delegate tool:self willUpdateOutputForKey:@"selectionPath"];
        CGPathRelease(_selectionPath);
        _selectionPath = NULL;
        [_delegate tool:self didUpdateOutputForKey:@"selectionPath"];
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

- (BOOL)tool:(id)aTool didFinalizeStage:(id)aStage withEvent:(id)aEvent nextStage:(id)aNextStage
{
    if (_currentSubtool != aTool)
        return NO;
    if (aNextStage == nil)
        [_delegate tool:self didFinalizeOutputForKey:@"currentCreateSelectionMode"];
    BOOL result = [_delegate tool:self didFinalizeStage:aStage withEvent:aEvent nextStage:aNextStage];
    if (_currentSubtool != nil && aNextStage == nil) {
        CGPathRelease(_selectionPath);
        _selectionPath = NULL;
        CGPathRelease(_initialSelectionPath);
        _initialSelectionPath = NULL;
        [_finalizingCreateSelectionMode release];
        _finalizingCreateSelectionMode = nil;
        if (_pendingInitialCreateSelectionMode != nil) {
            [_initialCreateSelectionMode release];
            _initialCreateSelectionMode = _pendingInitialCreateSelectionMode;
            _pendingInitialCreateSelectionMode = nil;
            [self BTCreateLassoSelectionTool_synchronizeWithFreeHandMode];
        }
        if (aEvent != nil)
            [self BTCreateLassoSelectionTool_flagsChanged:aEvent];
    }
    return result;
}

- (void)tool:(id)aTool didUpdateCursorWithEvent:(id)aEvent
{
    if (_currentSubtool == aTool)
        [_delegate tool:self didUpdateCursorWithEvent:aEvent];
}

/* Re-creates the selection from the stored initial path and start point in
   the mode named by finalizingCreateSelectionMode, with the modifier switches
   cleared for the duration. */
- (void)finalizeSelectionPath:(id)aSender
{
    BTTool *savedSubtool = _currentSubtool;
    unsigned int savedMagicSwitch = _switchesMagicLassoAndMagicWandModes;
    unsigned int savedLassoSwitch = _switchesFreeHandAndMagicLassoModes;
    _switchesMagicLassoAndMagicWandModes = 0;
    _switchesFreeHandAndMagicLassoModes = 0;
    if ([_finalizingCreateSelectionMode isEqualToString:@"BTMagicWandCreateSelectionMode"]) {
        _currentSubtool = [self BTCreateLassoSelectionTool_activeCreateMagicWandSelectionTool];
        [_createMagicWandSelectionTool finalizeSelectionPath:aSender];
    } else if ([_finalizingCreateSelectionMode isEqualToString:@"BTMagicLassoCreateSelectionMode"]) {
        [self beginUndoAction];
        _currentSubtool = [self BTCreateLassoSelectionTool_activeCreateFreeHandSelectionTool];
        CGPathRef path = [self BTCreateLassoSelectionTool_createLassoPathWithInitialPath:_initialSelectionPath startPoint:[_selectionStartPointValue pointValue] tolerance:_tolerance shouldSmooth:_shouldSmoothSelectionPath];
        [_delegate tool:self willUpdateOutputForKey:@"selectionPath"];
        CGPathRelease(_selectionPath);
        _selectionPath = path;
        [_delegate tool:self didUpdateOutputForKey:@"selectionPath"];
        [_delegate tool:self didFinalizeOutputForKey:@"selectionPath"];
        [self endUndoActionWithName:@"Change Magic Lasso Selection"];
        [_delegate tool:self didFinalizeStage:@"BTWaitingToolStage" withEvent:nil nextStage:nil];
    }
    _currentSubtool = savedSubtool;
    _switchesMagicLassoAndMagicWandModes = savedMagicSwitch;
    _switchesFreeHandAndMagicLassoModes = savedLassoSwitch;
}

- (void)selectAllArea:(id)aSender
{
    BTTool *savedSubtool = _currentSubtool;
    unsigned int savedMagicSwitch = _switchesMagicLassoAndMagicWandModes;
    unsigned int savedLassoSwitch = _switchesFreeHandAndMagicLassoModes;
    _switchesMagicLassoAndMagicWandModes = 0;
    _switchesFreeHandAndMagicLassoModes = 0;
    _shouldSmoothSelectionPath = 1;
    _currentSubtool = [self BTCreateLassoSelectionTool_activeSubtoolSwitchingMagicLassoAndMagicWandModes:NO];
    [_currentSubtool performSelector:@selector(selectAllArea:) withObject:aSender];
    _currentSubtool = savedSubtool;
    _switchesMagicLassoAndMagicWandModes = savedMagicSwitch;
    _switchesFreeHandAndMagicLassoModes = savedLassoSwitch;
}

- (BOOL)flagsChanged:(id)aEvent
{
    [self BTCreateLassoSelectionTool_flagsChanged:aEvent];
    return [_currentSubtool flagsChanged:aEvent];
}

/* Shift keeps the traced magic lasso path unsmoothed. */
- (BOOL)mouseDown:(id)aEvent
{
    [self BTCreateLassoSelectionTool_flagsChanged:aEvent];
    _shouldSmoothSelectionPath = ([(NSEvent *)aEvent modifierFlags] & NSEventModifierFlagShift) == 0;
    return [_currentSubtool mouseDown:aEvent];
}

/* Switches subtool and free hand mode to match the held modifiers. */
- (void)BTCreateLassoSelectionTool_flagsChanged:(id)aEvent
{
    NSUInteger flags = [(NSEvent *)aEvent modifierFlags];
    BOOL switchesLassoAndWand = BTModifierFlagsMatchOption(flags, _lassoSwitchingOption);
    _switchesMagicLassoAndMagicWandModes = switchesLassoAndWand;
    id subtool = [self BTCreateLassoSelectionTool_activeSubtoolSwitchingMagicLassoAndMagicWandModes:switchesLassoAndWand];
    if (subtool == nil) {
        [self performDeactivate];
        return;
    }
    BOOL changed = _currentSubtool != subtool;
    if (changed) {
        [_delegate tool:self willUpdateOutputForKey:@"currentCreateSelectionMode"];
        _currentSubtool = subtool;
    }
    BOOL switchesFreeHand = BTModifierFlagsMatchOption(flags, _magicSwitchingOption);
    if ((BOOL)_switchesFreeHandAndMagicLassoModes != switchesFreeHand) {
        if (_currentSubtool == _createFreeHandSelectionTool && !changed) {
            [_delegate tool:self willUpdateOutputForKey:@"currentCreateSelectionMode"];
            changed = YES;
        }
        _switchesFreeHandAndMagicLassoModes = switchesFreeHand;
        [self BTCreateLassoSelectionTool_synchronizeWithFreeHandMode];
    }
    if (!changed)
        return;
    [_delegate tool:self didUpdateOutputForKey:@"currentCreateSelectionMode"];
    [_delegate tool:self didUpdateCursorWithEvent:aEvent];
}

/* The cursor of the mode the modifiers would switch to, borrowing the free
   hand tool with the other mode's cursors when needed. */
- (id)cursorForPoint:(NSPoint)aPoint modifierFlags:(NSUInteger)aFlags
{
    id subtool = [self BTCreateLassoSelectionTool_activeSubtoolSwitchingMagicLassoAndMagicWandModes:BTModifierFlagsMatchOption(aFlags, _lassoSwitchingOption)];
    if (subtool == _createFreeHandSelectionTool) {
        BOOL inFreeHandMode = [self BTCreateLassoSelectionTool_isInFreeHandMode];
        BOOL switchesFreeHand = BTModifierFlagsMatchOption(aFlags, _magicSwitchingOption);
        BOOL initialFreeHand = [_initialCreateSelectionMode isEqualToString:@"BTFreeHandCreateSelectionMode"];
        BOOL willBeFreeHand = switchesFreeHand != initialFreeHand;
        id cursor;
        if (willBeFreeHand && !inFreeHandMode) {
            [_createFreeHandSelectionTool setWillCreateSelectionCursor:_willCreateFreeHandSelectionCursor];
            [_createFreeHandSelectionTool setDoCreateSelectionCursor:_doCreateFreeHandSelectionCursor];
            cursor = [_createFreeHandSelectionTool cursorForPoint:aPoint modifierFlags:aFlags];
            [_createFreeHandSelectionTool setWillCreateSelectionCursor:_willCreateMagicLassoSelectionCursor];
            [_createFreeHandSelectionTool setDoCreateSelectionCursor:_doCreateMagicLassoSelectionCursor];
            return cursor;
        }
        if (!willBeFreeHand && inFreeHandMode) {
            [_createFreeHandSelectionTool setWillCreateSelectionCursor:_willCreateMagicLassoSelectionCursor];
            [_createFreeHandSelectionTool setDoCreateSelectionCursor:_doCreateMagicLassoSelectionCursor];
            cursor = [_createFreeHandSelectionTool cursorForPoint:aPoint modifierFlags:aFlags];
            [_createFreeHandSelectionTool setWillCreateSelectionCursor:_willCreateFreeHandSelectionCursor];
            [_createFreeHandSelectionTool setDoCreateSelectionCursor:_doCreateFreeHandSelectionCursor];
            return cursor;
        }
    }
    return [subtool cursorForPoint:aPoint modifierFlags:aFlags];
}

- (id)currentStage
{
    if (_currentSubtool == nil)
        return @"BTWaitingToolStage";
    return [_currentSubtool currentStage];
}

- (void)performDeactivate
{
    if (_pendingInitialCreateSelectionMode != nil) {
        [_initialCreateSelectionMode release];
        _initialCreateSelectionMode = _pendingInitialCreateSelectionMode;
        _pendingInitialCreateSelectionMode = nil;
    }
    if (_isCreateFreeHandSelectionToolActivated) {
        [_createFreeHandSelectionTool deactivate];
        _isCreateFreeHandSelectionToolActivated = 0;
    }
    if (_isCreateMagicWandSelectionToolActivated) {
        [_createMagicWandSelectionTool deactivate];
        _isCreateMagicWandSelectionToolActivated = 0;
    }
    _currentSubtool = nil;
    [super performDeactivate];
}

- (BOOL)activateWithDelegate:(id)aDelegate inView:(id)aView
{
    if (![super activateWithDelegate:aDelegate inView:aView])
        return NO;
    NSUInteger flags = [[_view window] BT_effectiveModifierFlags];
    _switchesMagicLassoAndMagicWandModes = BTModifierFlagsMatchOption(flags, _lassoSwitchingOption);
    _switchesFreeHandAndMagicLassoModes = BTModifierFlagsMatchOption(flags, _magicSwitchingOption);
    [self BTCreateLassoSelectionTool_synchronizeWithFreeHandMode];
    _currentSubtool = [self BTCreateLassoSelectionTool_activeSubtoolSwitchingMagicLassoAndMagicWandModes:_switchesMagicLassoAndMagicWandModes];
    if (_currentSubtool != nil) {
        CGPathRelease(_selectionPath);
        _selectionPath = NULL;
        return YES;
    }
    [super performDeactivate];
    return NO;
}

- (void)changeViewInvalidationEnabledTo:(BOOL)aEnabled
{
    [super changeViewInvalidationEnabledTo:aEnabled];
    if (_currentSubtool == nil)
        return;
    if (_isCreateFreeHandSelectionToolActivated)
        [_createFreeHandSelectionTool setViewInvalidationEnabled:aEnabled];
    if (_isCreateMagicWandSelectionToolActivated)
        [_createMagicWandSelectionTool setViewInvalidationEnabled:aEnabled];
}

- (void)changeReferenceCGContextTo:(struct CGContext *)aContext
{
    [super changeReferenceCGContextTo:aContext];
    if (_currentSubtool == nil)
        return;
    if (_isCreateFreeHandSelectionToolActivated)
        [_createFreeHandSelectionTool setReferenceCGContext:aContext];
    if (_isCreateMagicWandSelectionToolActivated)
        [_createMagicWandSelectionTool setReferenceCGContext:aContext];
}

- (void)changeWorkPasteboardTo:(id)aPasteboard
{
    [super changeWorkPasteboardTo:aPasteboard];
    if (_currentSubtool == nil)
        return;
    if (_isCreateFreeHandSelectionToolActivated)
        [_createFreeHandSelectionTool setWorkPasteboard:aPasteboard];
    if (_isCreateMagicWandSelectionToolActivated)
        [_createMagicWandSelectionTool setWorkPasteboard:aPasteboard];
}

- (void)changeWorkImageTo:(id)aImage
{
    [super changeWorkImageTo:aImage];
    if (_currentSubtool == nil)
        return;
    if (_isCreateFreeHandSelectionToolActivated)
        [_createFreeHandSelectionTool setWorkImage:aImage];
    if (_isCreateMagicWandSelectionToolActivated)
        [_createMagicWandSelectionTool setWorkImage:aImage];
}

- (id)outputKeys
{
    return [NSArray arrayWithObjects:@"currentCreateSelectionMode", @"selectionStartPoint", @"selectionPath", @"initialSelectionPath", nil];
}

- (id)inputKeys
{
    return [NSArray arrayWithObjects:@"generalKeyBindings", @"willCreateFreeHandSelectionCursor", @"doCreateFreeHandSelectionCursor", @"willCreateMagicWandSelectionCursor", @"willCreateMagicLassoSelectionCursor", @"doCreateMagicLassoSelectionCursor", @"initialCreateSelectionMode", @"tolerance", @"selectionStartPoint", @"initialSelectionPath", @"finalizingCreateSelectionMode", nil];
}

- (id)selectionPath
{
    return (id)_selectionPath;
}

- (void)setFinalizingCreateSelectionMode:(id)aMode
{
    [_finalizingCreateSelectionMode release];
    _finalizingCreateSelectionMode = [aMode copy];
}

- (id)finalizingCreateSelectionMode
{
    return _finalizingCreateSelectionMode;
}

- (void)setInitialSelectionPath:(id)aPath
{
    CGPathRelease(_initialSelectionPath);
    _initialSelectionPath = CGPathRetain((CGPathRef)aPath);
}

- (id)initialSelectionPath
{
    return (id)_initialSelectionPath;
}

- (void)setSelectionStartPoint:(id)aPoint
{
    [_selectionStartPointValue release];
    _selectionStartPointValue = [aPoint retain];
    [_createMagicWandSelectionTool setSelectionStartPoint:aPoint];
}

- (id)selectionStartPoint
{
    return _selectionStartPointValue;
}

- (id)currentCreateSelectionMode
{
    if (_currentSubtool == nil)
        return _initialCreateSelectionMode;
    if (_currentSubtool == _createMagicWandSelectionTool)
        return @"BTMagicWandCreateSelectionMode";
    return [self BTCreateLassoSelectionTool_isInFreeHandMode] ? @"BTFreeHandCreateSelectionMode" : @"BTMagicLassoCreateSelectionMode";
}

/* While a subtool is tracking, the new mode waits until the stage ends. */
- (void)setInitialCreateSelectionMode:(id)aMode
{
    id *current = _pendingInitialCreateSelectionMode != nil ? &_pendingInitialCreateSelectionMode : &_initialCreateSelectionMode;
    if (*current == aMode || (aMode != nil && [*current isEqualToString:aMode]))
        return;
    if (_currentSubtool == nil) {
        [_initialCreateSelectionMode release];
        _initialCreateSelectionMode = [aMode copy];
    } else if (![_currentSubtool isTracking]) {
        [_delegate tool:self willUpdateOutputForKey:@"currentCreateSelectionMode"];
        [_initialCreateSelectionMode release];
        _initialCreateSelectionMode = [aMode copy];
        [self BTCreateLassoSelectionTool_synchronizeWithFreeHandMode];
        _currentSubtool = [self BTCreateLassoSelectionTool_activeSubtoolSwitchingMagicLassoAndMagicWandModes:_switchesMagicLassoAndMagicWandModes];
        [_delegate tool:self didUpdateOutputForKey:@"currentCreateSelectionMode"];
        if (_currentSubtool != nil)
            [_delegate tool:self didUpdateCursorWithEvent:nil];
        else
            [self performDeactivate];
    } else {
        [_pendingInitialCreateSelectionMode release];
        _pendingInitialCreateSelectionMode = [aMode copy];
    }
}

- (id)initialCreateSelectionMode
{
    return _pendingInitialCreateSelectionMode != nil ? _pendingInitialCreateSelectionMode : _initialCreateSelectionMode;
}

- (void)setLassoSwitchingOption:(NSUInteger)aOption
{
    _lassoSwitchingOption = aOption;
}

- (NSUInteger)lassoSwitchingOption
{
    return _lassoSwitchingOption;
}

- (NSUInteger)defaultLassoSwitchingOption
{
    return NSEventModifierFlagOption;
}

- (void)setMagicSwitchingOption:(NSUInteger)aOption
{
    _magicSwitchingOption = aOption;
}

- (NSUInteger)magicSwitchingOption
{
    return _magicSwitchingOption;
}

- (NSUInteger)defaultMagicSwitchingOption
{
    return NSEventModifierFlagCommand;
}

- (void)setTolerance:(CGFloat)aTolerance
{
    _tolerance = aTolerance;
    [_createMagicWandSelectionTool setTolerance:aTolerance];
}

- (CGFloat)tolerance
{
    return _tolerance;
}

/* Traces the image inside aPath into a new path of matching color regions.
   When the start point lies on the image, the region grows from that pixel,
   which is drawn even if the path leaves it out; otherwise every non-clear
   region inside the path is traced. Returns a +1 path or NULL. */
- (CGPathRef)BTCreateLassoSelectionTool_createLassoPathWithInitialPath:(CGPathRef)aPath startPoint:(NSPoint)aPoint tolerance:(CGFloat)aTolerance shouldSmooth:(BOOL)aSmooth
{
    id image = [self workImage];
    if (image == nil)
        return NULL;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    if ([(id)colorSpace autorelease] == nil)
        return NULL;

    CGRect imageRect = { CGPointZero, [image imageSize] };
    CGRect r = CGRectIntegral(CGRectIntersection(CGEPathGetPathBoundingBox(aPath), imageRect));
    BOOL seeded = CGRectContainsPoint(imageRect, NSPointToCGPoint(aPoint));
    CGRect seedRect = CGRectZero;
    CGFloat sx = 0.0, sy = 0.0;
    if (seeded) {
        sx = aPoint.x - r.origin.x;
        sy = aPoint.y - r.origin.y;
        if (r.size.width <= sx)
            r.size.width += 1.0;
        if (r.size.height <= sy)
            r.size.height += 1.0;
        seedRect = CGRectMake(floor(sx), floor(sy), 1.0, 1.0);
    }
    size_t width = lround(r.size.width);
    size_t bytesPerRow = ((width * 32 + 127) >> 3) & ~(size_t)15;
    size_t height = lround(r.size.height);
    void *bytes = [[NSMutableData dataWithLength:bytesPerRow * height] mutableBytes];
    if (bytes == NULL)
        return NULL;
    CGContextRef context = CGBitmapContextCreate(bytes, width, height, 8, bytesPerRow, colorSpace, (CGBitmapInfo)kCGImageAlphaPremultipliedFirst);
    if (context == NULL)
        return NULL;

    CGContextSaveGState(context);
    if (seeded) {
        CGContextBeginPath(context);
        CGContextAddRect(context, seedRect);
        CGContextAddRect(context, (CGRect){ CGPointZero, r.size });
        CGContextEOClip(context);
    }
    CGContextSetShouldAntialias(context, false);
    CGContextTranslateCTM(context, -r.origin.x, -r.origin.y);
    CGContextBeginPath(context);
    CGContextAddPath(context, aPath);
    CGContextClip(context);
    [image drawInCGContext:context atPoint:CGPointZero];
    CGContextRestoreGState(context);
    if (seeded) {
        CGContextClipToRect(context, seedRect);
        [image drawInCGContext:context atPoint:CGPointMake(-r.origin.x, -r.origin.y)];
    }
    CGContextRelease(context);

    CGMutablePathRef path = CGPathCreateMutable();
    if ([(id)path autorelease] == nil)
        return NULL;
    CGAffineTransform m = CGAffineTransformMake(1.0, 0.0, 0.0, 1.0, r.origin.x, r.origin.y);
    bool traced;
    if (seeded) {
        traced = CGEPathAddPathsFromARGB8888PremultipliedBitmap(path, &m, bytes, width, height, bytesPerRow, sx, sy, aTolerance, UINT32_MAX,
            kCGEPathBitmapAllMatching | kCGEPathBitmapTransparentMatches | kCGEPathBitmapDiagonals | kCGEPathBitmapIgnoreAlpha, NULL);
    } else {
        const uint8_t clear[4] = { 0, 0, 0, 0 };
        traced = CGEPathAddColoredPathsFromARGB8888PremultipliedBitmap(path, &m, bytes, width, height, bytesPerRow, clear, aTolerance, UINT32_MAX,
            kCGEPathBitmapDiagonals, NULL);
    }
    if (!traced || CGPathIsEmpty(path))
        return NULL;
    if (aSmooth)
        return (CGPathRef)BTCGPathCreateCopyWithSmoothedCorners(path);
    return CGPathCreateCopy(path);
}

- (void)setDoCreateMagicLassoSelectionCursor:(id)aCursor
{
    if (_doCreateMagicLassoSelectionCursor == aCursor)
        return;
    [aCursor retain];
    [_doCreateMagicLassoSelectionCursor release];
    _doCreateMagicLassoSelectionCursor = aCursor;
    if (_currentSubtool == _createFreeHandSelectionTool && ![self BTCreateLassoSelectionTool_isInFreeHandMode])
        [_createFreeHandSelectionTool setDoCreateSelectionCursor:_doCreateMagicLassoSelectionCursor];
}

- (id)doCreateMagicLassoSelectionCursor
{
    return _doCreateMagicLassoSelectionCursor;
}

- (id)defaultDoCreateMagicLassoSelectionCursor
{
    return nil;
}

- (void)setWillCreateMagicLassoSelectionCursor:(id)aCursor
{
    if (_willCreateMagicLassoSelectionCursor == aCursor)
        return;
    [aCursor retain];
    [_willCreateMagicLassoSelectionCursor release];
    _willCreateMagicLassoSelectionCursor = aCursor;
    if (_currentSubtool == _createFreeHandSelectionTool && ![self BTCreateLassoSelectionTool_isInFreeHandMode])
        [_createFreeHandSelectionTool setWillCreateSelectionCursor:_willCreateMagicLassoSelectionCursor];
}

- (id)willCreateMagicLassoSelectionCursor
{
    return _willCreateMagicLassoSelectionCursor;
}

- (id)defaultWillCreateMagicLassoSelectionCursor
{
    return nil;
}

- (void)setWillCreateMagicWandSelectionCursor:(id)aCursor
{
    [_createMagicWandSelectionTool setWillCreateSelectionCursor:aCursor];
}

- (id)willCreateMagicWandSelectionCursor
{
    return [_createMagicWandSelectionTool willCreateSelectionCursor];
}

- (id)defaultWillCreateMagicWandSelectionCursor
{
    return [_createMagicWandSelectionTool defaultWillCreateSelectionCursor];
}

- (void)setDoCreateFreeHandSelectionCursor:(id)aCursor
{
    if (_doCreateFreeHandSelectionCursor != aCursor) {
        [aCursor retain];
        [_doCreateFreeHandSelectionCursor release];
        _doCreateFreeHandSelectionCursor = aCursor;
        if (_currentSubtool == _createFreeHandSelectionTool && [self BTCreateLassoSelectionTool_isInFreeHandMode])
            [_createFreeHandSelectionTool setDoCreateSelectionCursor:_doCreateFreeHandSelectionCursor];
    }
    _isDoCreateFreeHandSelectionCursorInitialized = 1;
}

- (id)doCreateFreeHandSelectionCursor
{
    if (!_isDoCreateFreeHandSelectionCursorInitialized) {
        _doCreateFreeHandSelectionCursor = [[_createFreeHandSelectionTool defaultDoCreateSelectionCursor] retain];
        _isDoCreateFreeHandSelectionCursorInitialized = 1;
    }
    return _doCreateFreeHandSelectionCursor;
}

- (id)defaultDoCreateFreeHandSelectionCursor
{
    return [_createFreeHandSelectionTool defaultDoCreateSelectionCursor];
}

- (void)setWillCreateFreeHandSelectionCursor:(id)aCursor
{
    if (_willCreateFreeHandSelectionCursor != aCursor) {
        [aCursor retain];
        [_willCreateFreeHandSelectionCursor release];
        _willCreateFreeHandSelectionCursor = aCursor;
        if (_currentSubtool == _createFreeHandSelectionTool && [self BTCreateLassoSelectionTool_isInFreeHandMode])
            [_createFreeHandSelectionTool setWillCreateSelectionCursor:_willCreateFreeHandSelectionCursor];
    }
    _isWillCreateFreeHandSelectionCursorInitialized = 1;
}

- (id)willCreateFreeHandSelectionCursor
{
    if (!_isWillCreateFreeHandSelectionCursorInitialized) {
        _willCreateFreeHandSelectionCursor = [[_createFreeHandSelectionTool defaultWillCreateSelectionCursor] retain];
        _isWillCreateFreeHandSelectionCursorInitialized = 1;
    }
    return _willCreateFreeHandSelectionCursor;
}

- (id)defaultWillCreateFreeHandSelectionCursor
{
    return [_createFreeHandSelectionTool defaultWillCreateSelectionCursor];
}

/* The free hand tool shows the cursors of the mode it currently serves. */
- (void)BTCreateLassoSelectionTool_synchronizeWithFreeHandMode
{
    if ([self BTCreateLassoSelectionTool_isInFreeHandMode]) {
        [_createFreeHandSelectionTool setWillCreateSelectionCursor:_willCreateFreeHandSelectionCursor];
        [_createFreeHandSelectionTool setDoCreateSelectionCursor:_doCreateFreeHandSelectionCursor];
    } else {
        [_createFreeHandSelectionTool setWillCreateSelectionCursor:_willCreateMagicLassoSelectionCursor];
        [_createFreeHandSelectionTool setDoCreateSelectionCursor:_doCreateMagicLassoSelectionCursor];
    }
}

- (BOOL)BTCreateLassoSelectionTool_isInFreeHandMode
{
    if ([_initialCreateSelectionMode isEqualToString:@"BTFreeHandCreateSelectionMode"])
        return !_switchesFreeHandAndMagicLassoModes;
    return _switchesFreeHandAndMagicLassoModes;
}

- (id)BTCreateLassoSelectionTool_activeSubtoolSwitchingMagicLassoAndMagicWandModes:(BOOL)aSwitching
{
    id magicWandMode = aSwitching ? @"BTMagicLassoCreateSelectionMode" : @"BTMagicWandCreateSelectionMode";
    if ([_initialCreateSelectionMode isEqualToString:magicWandMode])
        return [self BTCreateLassoSelectionTool_activeCreateMagicWandSelectionTool];
    return [self BTCreateLassoSelectionTool_activeCreateFreeHandSelectionTool];
}

- (id)BTCreateLassoSelectionTool_activeCreateFreeHandSelectionTool
{
    if (!_isCreateFreeHandSelectionToolActivated) {
        if (![_createFreeHandSelectionTool activateWithDelegate:self inView:_view])
            return nil;
        [self BTCreateLassoSelectionTool_synchronizeSubtool:_createFreeHandSelectionTool];
        _isCreateFreeHandSelectionToolActivated = 1;
    }
    return _createFreeHandSelectionTool;
}

- (id)BTCreateLassoSelectionTool_activeCreateMagicWandSelectionTool
{
    if (!_isCreateMagicWandSelectionToolActivated) {
        if (![_createMagicWandSelectionTool activateWithDelegate:self inView:_view])
            return nil;
        [self BTCreateLassoSelectionTool_synchronizeSubtool:_createMagicWandSelectionTool];
        _isCreateMagicWandSelectionToolActivated = 1;
    }
    return _createMagicWandSelectionTool;
}

- (BOOL)BTCreateLassoSelectionTool_activateSubtool:(id)aSubtool
{
    _currentSubtool = aSubtool;
    if ([aSubtool activateWithDelegate:self inView:_view]) {
        [self BTCreateLassoSelectionTool_synchronizeSubtool:_currentSubtool];
        return YES;
    }
    _currentSubtool = nil;
    return NO;
}

- (void)BTCreateLassoSelectionTool_synchronizeSubtool:(id)aSubtool
{
    [aSubtool setWorkImage:[self workImage]];
    [aSubtool setWorkPasteboard:[self workPasteboard]];
    [aSubtool setReferenceCGContext:[self referenceCGContext]];
    [aSubtool setViewInvalidationEnabled:[self isViewInvalidationEnabled]];
}

- (id *)requiredImageProtocols
{
    static id protocols[2];
    protocols[0] = @protocol(BTCGImage);
    return protocols;
}

- (void)dealloc
{
    [_willCreateFreeHandSelectionCursor release];
    [_doCreateFreeHandSelectionCursor release];
    [_willCreateMagicLassoSelectionCursor release];
    [_doCreateMagicLassoSelectionCursor release];
    [_selectionStartPointValue release];
    CGPathRelease(_selectionPath);
    CGPathRelease(_initialSelectionPath);
    [_finalizingCreateSelectionMode release];
    [_createFreeHandSelectionTool release];
    [_createMagicWandSelectionTool release];
    [_pendingInitialCreateSelectionMode release];
    [_initialCreateSelectionMode release];
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self == nil)
        return nil;
    _createFreeHandSelectionTool = [[BTCreateFreeHandSelectionTool alloc] init];
    if (_createFreeHandSelectionTool != nil)
        _createMagicWandSelectionTool = [[BTCreateMagicWandSelectionTool alloc] init];
    if (_createMagicWandSelectionTool == nil) {
        [self release];
        return nil;
    }
    _initialCreateSelectionMode = [@"BTMagicLassoCreateSelectionMode" retain];
    _magicSwitchingOption = NSEventModifierFlagCommand;
    _lassoSwitchingOption = NSEventModifierFlagOption;
    return self;
}

@end
