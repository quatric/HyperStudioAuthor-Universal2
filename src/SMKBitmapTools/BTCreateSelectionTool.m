#import "BTCreateSelectionTool.h"
#import "BTCreateShapeSelectionTool.h"
#import "BTCreateLassoSelectionTool.h"

/* The create selection tool switches between the shape tool and the lasso
   tool (free hand, magic lasso, magic wand) by initialCreateSelectionMode,
   forwards their outputs as its own and hands its inputs to the subtool that
   owns them. */
@implementation BTCreateSelectionTool

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
    return _currentSubtool == aTool ? [_delegate imageViewTransformerForTool:self] : nil;
}

- (id)tool:(id)aTool willSetUndoActionName:(id)aName
{
    return _currentSubtool == aTool ? [_delegate tool:self willSetUndoActionName:aName] : nil;
}

- (void)tool:(id)aTool willRegisterUndoInManager:(id)aManager category:(id)aCategory
{
}

- (id)undoManagerForTool:(id)aTool category:(id)aCategory
{
    return nil;
}

/* The shape tool's selection path is also the initial selection path. */
- (void)tool:(id)aTool didFinalizeOutputForKey:(id)aKey
{
    if (_currentSubtool != aTool)
        return;
    if ([aKey isEqualToString:@"selectionPath"]) {
        [_delegate tool:self didFinalizeOutputForKey:@"selectionPath"];
        if (_currentSubtool == (BTTool *)_createShapeSelectionTool)
            [_delegate tool:self didFinalizeOutputForKey:@"initialSelectionPath"];
    } else if ([aKey isEqualToString:@"currentCreateSelectionMode"]
            || [aKey isEqualToString:@"selectionStartPoint"]
            || [aKey isEqualToString:@"initialSelectionPath"]) {
        [_delegate tool:self didFinalizeOutputForKey:aKey];
    }
}

/* Mode changes made by setInitialCreateSelectionMode: are announced once by
   it, not again by the subtool switch it causes. */
- (void)tool:(id)aTool didUpdateOutputForKey:(id)aKey
{
    if (_currentSubtool != aTool)
        return;
    if ([aKey isEqualToString:@"selectionPath"]) {
        [_delegate tool:self didUpdateOutputForKey:@"selectionPath"];
        if (_currentSubtool == (BTTool *)_createShapeSelectionTool)
            [_delegate tool:self didUpdateOutputForKey:@"initialSelectionPath"];
    } else if ([aKey isEqualToString:@"currentCreateSelectionMode"]) {
        if (!_ignoresCurrentCreateSelectionModeChange)
            [_delegate tool:self didUpdateOutputForKey:aKey];
    } else if ([aKey isEqualToString:@"selectionStartPoint"] || [aKey isEqualToString:@"initialSelectionPath"]) {
        [_delegate tool:self didUpdateOutputForKey:aKey];
    }
}

- (void)tool:(id)aTool willUpdateOutputForKey:(id)aKey
{
    if (_currentSubtool != aTool)
        return;
    if ([aKey isEqualToString:@"selectionPath"]) {
        [_delegate tool:self willUpdateOutputForKey:@"selectionPath"];
        if (_currentSubtool == (BTTool *)_createShapeSelectionTool)
            [_delegate tool:self willUpdateOutputForKey:@"initialSelectionPath"];
    } else if ([aKey isEqualToString:@"currentCreateSelectionMode"]) {
        if (!_ignoresCurrentCreateSelectionModeChange)
            [_delegate tool:self willUpdateOutputForKey:aKey];
    } else if ([aKey isEqualToString:@"selectionStartPoint"] || [aKey isEqualToString:@"initialSelectionPath"]) {
        [_delegate tool:self willUpdateOutputForKey:aKey];
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
    return [_delegate tool:self didFinalizeStage:aStage withEvent:aEvent nextStage:aNextStage];
}

- (void)tool:(id)aTool didUpdateCursorWithEvent:(id)aEvent
{
    if (_currentSubtool == aTool)
        [_delegate tool:self didUpdateCursorWithEvent:aEvent];
}

- (BOOL)isFeedbackLayerActive:(id)aLayer
{
    return [_currentSubtool isFeedbackLayerActive:aLayer];
}

- (id)activeFeedbackLayers
{
    if (_currentSubtool == nil)
        return [NSSet set];
    return [_currentSubtool activeFeedbackLayers];
}

- (id)currentStage
{
    if (_currentSubtool == nil)
        return @"BTWaitingToolStage";
    return [_currentSubtool currentStage];
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
    if ([_initialCreateSelectionMode isEqualToString:@"BTShapeCreateSelectionMode"]) {
        _currentSubtool = (BTTool *)_createShapeSelectionTool;
    } else {
        [_createLassoSelectionTool setInitialCreateSelectionMode:_initialCreateSelectionMode];
        _currentSubtool = (BTTool *)_createLassoSelectionTool;
    }
    if ([_currentSubtool activateWithDelegate:self inView:_view])
        return YES;
    _currentSubtool = nil;
    [super performDeactivate];
    return NO;
}

- (void)changeViewInvalidationEnabledTo:(BOOL)aEnabled
{
    [super changeViewInvalidationEnabledTo:aEnabled];
    [_createShapeSelectionTool setViewInvalidationEnabled:aEnabled];
    [_createLassoSelectionTool setViewInvalidationEnabled:aEnabled];
}

- (void)changeReferenceCGContextTo:(struct CGContext *)aContext
{
    [super changeReferenceCGContextTo:aContext];
    [_createShapeSelectionTool setReferenceCGContext:aContext];
    [_createLassoSelectionTool setReferenceCGContext:aContext];
}

- (void)changeWorkPasteboardTo:(id)aPasteboard
{
    [super changeWorkPasteboardTo:aPasteboard];
    [_createShapeSelectionTool setWorkPasteboard:aPasteboard];
    [_createLassoSelectionTool setWorkPasteboard:aPasteboard];
}

/* Like the original, the subtools get changeWorkImageTo: directly rather
   than setWorkImage:. */
- (void)changeWorkImageTo:(id)aImage
{
    [super changeWorkImageTo:aImage];
    [_createShapeSelectionTool changeWorkImageTo:aImage];
    [_createLassoSelectionTool changeWorkImageTo:aImage];
}

- (id)outputKeys
{
    return [NSArray arrayWithObjects:@"selectionStartPoint", @"selectionPath", @"currentCreateSelectionMode", @"initialSelectionPath", nil];
}

- (id)inputKeys
{
    return [NSArray arrayWithObjects:@"initialCreateSelectionMode", @"tolerance", @"selectionShapePrototypePath", @"alternateProportion", @"proportionalModePrimary", @"willCreateFreeHandSelectionCursor", @"doCreateFreeHandSelectionCursor", @"willCreateMagicWandSelectionCursor", @"willCreateMagicLassoSelectionCursor", @"doCreateMagicLassoSelectionCursor", @"willCreateShapeSelectionCursor", @"doCreateShapeSelectionCursor", @"finalizingCreateSelectionMode", nil];
}

- (id *)requiredImageProtocols
{
    static id protocols[2];
    protocols[0] = @protocol(BTCGImage);
    return protocols;
}

- (void)setFinalizingCreateSelectionMode:(id)aMode
{
    [_createLassoSelectionTool setFinalizingCreateSelectionMode:aMode];
}

- (id)finalizingCreateSelectionMode
{
    return [_createLassoSelectionTool finalizingCreateSelectionMode];
}

- (void)setInitialSelectionPath:(id)aPath
{
    [_createLassoSelectionTool setInitialSelectionPath:aPath];
}

/* The shape tool's initial path is its selection path. */
- (id)initialSelectionPath
{
    if (_currentSubtool == (BTTool *)_createLassoSelectionTool)
        return [_createLassoSelectionTool initialSelectionPath];
    if (_currentSubtool == (BTTool *)_createShapeSelectionTool)
        return [_createShapeSelectionTool selectionPath];
    if ([_initialCreateSelectionMode isEqualToString:@"BTShapeCreateSelectionMode"])
        return [_createShapeSelectionTool selectionPath];
    return [_createLassoSelectionTool initialSelectionPath];
}

- (id)BTCreateSelectionTool_effectiveSubtool
{
    if (_currentSubtool != nil)
        return _currentSubtool;
    if ([_initialCreateSelectionMode isEqualToString:@"BTShapeCreateSelectionMode"])
        return _createShapeSelectionTool;
    return _createLassoSelectionTool;
}

- (id)selectionPath
{
    return [[self BTCreateSelectionTool_effectiveSubtool] selectionPath];
}

- (void)setSelectionStartPoint:(id)aPoint
{
    [_createLassoSelectionTool setSelectionStartPoint:aPoint];
}

- (id)selectionStartPoint
{
    return [[self BTCreateSelectionTool_effectiveSubtool] selectionStartPoint];
}

- (void)setProportionalModePrimary:(BOOL)aPrimary
{
    [_createShapeSelectionTool setProportionalModePrimary:aPrimary];
}

- (BOOL)isProportionalModePrimary
{
    return [_createShapeSelectionTool isProportionalModePrimary];
}

- (BOOL)defaultProportionalModePrimary
{
    return [_createShapeSelectionTool defaultProportionalModePrimary];
}

- (void)setAlternateProportion:(CGFloat)aProportion
{
    [_createShapeSelectionTool setAlternateProportion:aProportion];
}

- (CGFloat)alternateProportion
{
    return [_createShapeSelectionTool alternateProportion];
}

- (CGFloat)defaultAlternateProportion
{
    return [_createShapeSelectionTool defaultAlternateProportion];
}

- (void)setLassoSwitchingOption:(NSUInteger)aOption
{
    [_createLassoSelectionTool setLassoSwitchingOption:aOption];
}

- (NSUInteger)lassoSwitchingOption
{
    return [_createLassoSelectionTool lassoSwitchingOption];
}

- (NSUInteger)defaultLassoSwitchingOption
{
    return [_createLassoSelectionTool defaultLassoSwitchingOption];
}

- (void)setMagicSwitchingOption:(NSUInteger)aOption
{
    [_createLassoSelectionTool setMagicSwitchingOption:aOption];
}

- (NSUInteger)magicSwitchingOption
{
    return [_createLassoSelectionTool magicSwitchingOption];
}

- (NSUInteger)defaultMagicSwitchingOption
{
    return [_createLassoSelectionTool defaultMagicSwitchingOption];
}

- (void)setSelectionShapePrototypePath:(id)aPath
{
    [_createShapeSelectionTool setValue:aPath forInputKey:@"selectionShapePrototypePath"];
}

- (id)selectionShapePrototypePath
{
    return [_createShapeSelectionTool valueForInputKey:@"selectionShapePrototypePath"];
}

- (void)setTolerance:(CGFloat)aTolerance
{
    [_createLassoSelectionTool setTolerance:aTolerance];
}

- (CGFloat)tolerance
{
    return [_createLassoSelectionTool tolerance];
}

- (id)currentCreateSelectionMode
{
    if (_currentSubtool == nil)
        return _initialCreateSelectionMode;
    if (_currentSubtool == (BTTool *)_createShapeSelectionTool)
        return @"BTShapeCreateSelectionMode";
    return [_createLassoSelectionTool currentCreateSelectionMode];
}

/* While active, switches to the subtool of the new mode (the lasso tool
   switches its own modes) and announces one mode change. */
- (void)setInitialCreateSelectionMode:(id)aMode
{
    if (_initialCreateSelectionMode == aMode || (aMode != nil && [_initialCreateSelectionMode isEqualToString:aMode]))
        return;
    if (_currentSubtool != nil) {
        [_delegate tool:self willUpdateOutputForKey:@"currentCreateSelectionMode"];
        _ignoresCurrentCreateSelectionModeChange = 1;
    }
    [_initialCreateSelectionMode release];
    _initialCreateSelectionMode = [aMode copy];
    if (_currentSubtool == nil)
        return;
    BTTool *subtool;
    if ([_initialCreateSelectionMode isEqualToString:@"BTShapeCreateSelectionMode"]) {
        subtool = (BTTool *)_createShapeSelectionTool;
    } else {
        [_createLassoSelectionTool setInitialCreateSelectionMode:_initialCreateSelectionMode];
        subtool = _currentSubtool == (BTTool *)_createShapeSelectionTool ? (BTTool *)_createLassoSelectionTool : nil;
    }
    if (subtool != nil) {
        [_currentSubtool deactivate];
        _currentSubtool = subtool;
        if (![_currentSubtool activateWithDelegate:self inView:_view])
            _currentSubtool = nil;
    }
    _ignoresCurrentCreateSelectionModeChange = 0;
    [_delegate tool:self didUpdateOutputForKey:@"currentCreateSelectionMode"];
    if (_currentSubtool == nil)
        [super performDeactivate];
}

- (id)initialCreateSelectionMode
{
    return _initialCreateSelectionMode;
}

- (void)setDoCreateShapeSelectionCursor:(id)aCursor
{
    [_createShapeSelectionTool setDoCreateSelectionCursor:aCursor];
}

- (id)doCreateShapeSelectionCursor
{
    return [_createShapeSelectionTool doCreateSelectionCursor];
}

- (id)defaultDoCreateShapeSelectionCursor
{
    return [_createShapeSelectionTool defaultDoCreateSelectionCursor];
}

- (void)setWillCreateShapeSelectionCursor:(id)aCursor
{
    [_createShapeSelectionTool setWillCreateSelectionCursor:aCursor];
}

- (id)willCreateShapeSelectionCursor
{
    return [_createShapeSelectionTool willCreateSelectionCursor];
}

- (id)defaultWillCreateShapeSelectionCursor
{
    return [_createShapeSelectionTool defaultWillCreateSelectionCursor];
}

- (void)setDoCreateMagicLassoSelectionCursor:(id)aCursor
{
    [_createLassoSelectionTool setDoCreateMagicLassoSelectionCursor:aCursor];
}

- (id)doCreateMagicLassoSelectionCursor
{
    return [_createLassoSelectionTool doCreateMagicLassoSelectionCursor];
}

- (id)defaultDoCreateMagicLassoSelectionCursor
{
    return [_createLassoSelectionTool defaultDoCreateMagicLassoSelectionCursor];
}

- (void)setWillCreateMagicLassoSelectionCursor:(id)aCursor
{
    [_createLassoSelectionTool setWillCreateMagicLassoSelectionCursor:aCursor];
}

- (id)willCreateMagicLassoSelectionCursor
{
    return [_createLassoSelectionTool willCreateMagicLassoSelectionCursor];
}

- (id)defaultWillCreateMagicLassoSelectionCursor
{
    return [_createLassoSelectionTool defaultWillCreateMagicLassoSelectionCursor];
}

- (void)setWillCreateMagicWandSelectionCursor:(id)aCursor
{
    [_createLassoSelectionTool setWillCreateMagicWandSelectionCursor:aCursor];
}

- (id)willCreateMagicWandSelectionCursor
{
    return [_createLassoSelectionTool willCreateMagicWandSelectionCursor];
}

- (id)defaultWillCreateMagicWandSelectionCursor
{
    return [_createLassoSelectionTool defaultWillCreateMagicWandSelectionCursor];
}

- (void)setDoCreateFreeHandSelectionCursor:(id)aCursor
{
    [_createLassoSelectionTool setDoCreateFreeHandSelectionCursor:aCursor];
}

- (id)doCreateFreeHandSelectionCursor
{
    return [_createLassoSelectionTool doCreateFreeHandSelectionCursor];
}

- (id)defaultDoCreateFreeHandSelectionCursor
{
    return [_createLassoSelectionTool defaultDoCreateFreeHandSelectionCursor];
}

- (void)setWillCreateFreeHandSelectionCursor:(id)aCursor
{
    [_createLassoSelectionTool setWillCreateFreeHandSelectionCursor:aCursor];
}

- (id)willCreateFreeHandSelectionCursor
{
    return [_createLassoSelectionTool willCreateFreeHandSelectionCursor];
}

- (id)defaultWillCreateFreeHandSelectionCursor
{
    return [_createLassoSelectionTool defaultWillCreateFreeHandSelectionCursor];
}

- (void)dealloc
{
    [_createShapeSelectionTool release];
    [_createLassoSelectionTool release];
    [_initialCreateSelectionMode release];
    [super dealloc];
}

/* The initial mode starts as the lasso tool's (magic lasso). */
- (id)init
{
    self = [super init];
    if (self == nil)
        return nil;
    _createShapeSelectionTool = [[BTCreateShapeSelectionTool alloc] init];
    if (_createShapeSelectionTool != nil)
        _createLassoSelectionTool = [[BTCreateLassoSelectionTool alloc] init];
    if (_createLassoSelectionTool != nil)
        _initialCreateSelectionMode = [[_createLassoSelectionTool initialCreateSelectionMode] copy];
    if (_initialCreateSelectionMode == nil) {
        [self release];
        return nil;
    }
    return self;
}

@end
