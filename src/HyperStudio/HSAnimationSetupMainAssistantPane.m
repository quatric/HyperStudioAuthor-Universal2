#import "HSAnimationSetupMainAssistantPane.h"

// Speed multipliers offered by the move value pop-up, indexed by item tag.
static const float HSAnimationSetupSpeedMultipliers[5] = { 0.25f, 0.5f, 1.0f, 2.0f, 3.0f };
static id sDAT_00342930;
static id sDAT_00342934;
static id sDAT_00342938;
static id sDAT_0034293c;
static id sDAT_00342940;
static id sDAT_00342944;
static id sDAT_00342948;
static id sDAT_0034294c;

static id sDAT_00342930;
static id sDAT_00342934;
static id sDAT_00342938;
static id sDAT_0034293c;
static id sDAT_00342940;
static id sDAT_00342944;
static id sDAT_00342948;
static id sDAT_0034294c;

@implementation HSAnimationSetupMainAssistantPane

/* i386 ivar offsets: _delegate=0x5c, _navigationPaneSwitcher=0x60, _isMovieAnimation=0x64, _segmentedControl=0x68, _optionsView=0x6c, _mainOptionsView=0x70, _pathOptionsView=0x74, _showFirstFrameButton=0x78, _eraseWhenDoneButton=0x7c, _matchToMovementMatrix=0x80, _allowClonesButton=0x84, _movieSpeedTextField=0x88, _movieSpeedStepper=0x8c, _playForPopUpButton=0x90, _playForValueTextField=0x94, _playForValueStepper=0x98, _horizontalFlipButton=0x9c, _verticalFlipButton=0xa0, _transparentColorPickerButton=0xa4, _transparentColorButton=0xa8, _mainPlayStopButton=0xac, _newPathButton=0xb0, _getNewSourceButton=0xb4, _beginArrowButton=0xb8, _endArrowButton=0xbc, _horizontalFlipAtStartButton=0xc0, _verticalFlipAtStartButton=0xc4, _horizontalFlipAtFinishButton=0xc8, _verticalFlipAtFinishButton=0xcc, _startFromBeginButton=0xd0, _startFromEndButton=0xd4, _goingImageView=0xd8, _returningImageView=0xdc, _floatOverGoingButton=0xe0, _floatOverReturningButton=0xe4, _dontEraseGoingButton=0xe8, _dontEraseReturningButton=0xec, _movePopUpButton=0xf0, _moveValueTextField=0xf4, _moveValueStepper=0xf8, _secondsLabel=0xfc, _moveValuePopUpButton=0x100, _layerPopUpButton=0x104, _pathPlayStopButton=0x108, _helpIsActive=0x10c, _helpDrawer=0x110, _actionHelpView=0x114, _helpTextView=0x118 */

+ (id)noFloatOverImage
{
    if (sDAT_0034294c == nil) {
        sDAT_0034294c = [NSImage imageNamed:@"PassOptions_ObjectOver"];
    }
    return sDAT_0034294c;
}

+ (id)floatOverImage
{
    if (sDAT_00342948 == nil) {
        sDAT_00342948 = [NSImage imageNamed:@"PassOptions_ObjectUnder"];
    }
    return sDAT_00342948;
}

+ (id)rightTurnImage
{
    if (sDAT_00342944 == nil) {
        sDAT_00342944 = [NSImage imageNamed:@"AnimationLeftEndButton"];
    }
    return sDAT_00342944;
}

+ (id)leftTurnImage
{
    if (sDAT_00342940 == nil) {
        sDAT_00342940 = [NSImage imageNamed:@"AnimationRightEndButton"];
    }
    return sDAT_00342940;
}

+ (id)rightEndImage
{
    if (sDAT_0034293c == nil) {
        sDAT_0034293c = [NSImage imageNamed:@"AnimationRightEndButton"];
    }
    return sDAT_0034293c;
}

+ (id)leftEndImage
{
    if (sDAT_00342938 == nil) {
        sDAT_00342938 = [NSImage imageNamed:@"AnimationLeftEndButton"];
    }
    return sDAT_00342938;
}

+ (id)rightStartImage
{
    if (sDAT_00342934 == nil) {
        sDAT_00342934 = [NSImage imageNamed:@"AnimationRightStartButton"];
    }
    return sDAT_00342934;
}

+ (id)leftStartImage
{
    if (sDAT_00342930 == nil) {
        sDAT_00342930 = [NSImage imageNamed:@"AnimationLeftStartButton"];
    }
    return sDAT_00342930;
}

+ (id)stopAnimationImage
{
    return [[HSPlaybackControlImagesProvider sharedPlaybackControlsImagesProvider] playbackImageOfType:@"Stop" state:@"N" size:@"M" tint:@"A"];
}

+ (id)playAnimationImage
{
    return [[HSPlaybackControlImagesProvider sharedPlaybackControlsImagesProvider] playbackImageOfType:@"Play" state:@"N" size:@"M" tint:@"A"];
}

- (void)setPlayTryItAnimation:(BOOL)aAnimation
{
    [self setPlayStopImage:(aAnimation ? [[self class] playAnimationImage] : [[self class] stopAnimationImage])];
    [self setOptionsEnabled:aAnimation];
}

- (void)setPlayStopImage:(id)aImage
{
    [_mainPlayStopButton setImage:aImage];
    [_pathPlayStopButton setImage:aImage];
}

- (void)setOptionsEnabled:(BOOL)aEnabled
{
    int iVar1;

    iVar1 = (int)aEnabled;
    [_segmentedControl setEnabled:iVar1];
    [_showFirstFrameButton setEnabled:iVar1];
    [_eraseWhenDoneButton setEnabled:iVar1];
    [_matchToMovementMatrix setEnabled:iVar1];
    [_allowClonesButton setEnabled:iVar1];
    [_movieSpeedTextField setEnabled:iVar1];
    [_movieSpeedStepper setEnabled:iVar1];
    [_playForPopUpButton setEnabled:iVar1];
    [_playForValueTextField setEnabled:iVar1];
    [_playForValueStepper setEnabled:iVar1];
    [_horizontalFlipButton setEnabled:iVar1];
    [_verticalFlipButton setEnabled:iVar1];
    [_transparentColorPickerButton setEnabled:iVar1];
    [_transparentColorButton setEnabled:iVar1];
    [_beginArrowButton setEnabled:iVar1];
    [_endArrowButton setEnabled:iVar1];
    [_horizontalFlipAtStartButton setEnabled:iVar1];
    [_verticalFlipAtStartButton setEnabled:iVar1];
    [_horizontalFlipAtFinishButton setEnabled:iVar1];
    [_verticalFlipAtFinishButton setEnabled:iVar1];
    [_startFromBeginButton setEnabled:iVar1];
    [_startFromEndButton setEnabled:iVar1];
    [_goingImageView setEnabled:iVar1];
    [_returningImageView setEnabled:iVar1];
    [_floatOverGoingButton setEnabled:iVar1];
    [_floatOverReturningButton setEnabled:iVar1];
    [_dontEraseGoingButton setEnabled:iVar1];
    [_dontEraseReturningButton setEnabled:iVar1];
    [_movePopUpButton setEnabled:iVar1];
    [_moveValueTextField setEnabled:iVar1];
    [_moveValueStepper setEnabled:iVar1];
    [_moveValuePopUpButton setEnabled:iVar1];
    [_layerPopUpButton setEnabled:iVar1];
    [_newPathButton setEnabled:iVar1];
    [_getNewSourceButton setEnabled:iVar1];
}

- (void)hideHelp:(id)aHelp
{
    [self hideHelpNeedsRelayout:YES];
}

- (void)showHelp:(id)aHelp
{
    [[self assistant] toggleDrawerModeWithDrawerSize:[[self actionHelpView] frame].size];
    [self setFooterView:[self actionHelpView]];
    [[_helpTextView textStorage] setAttributedString:[[HSNBAHelpProvider sharedNBAHelpProvider] localizedHelpForActionOfType:[HSPlayAnimationAction actionType]]];
    [self layoutIfNeeded];
    _helpIsActive = YES;
}

- (void)hideHelpNeedsRelayout:(BOOL)aRelayout
{
    [self setFooterView:nil];
    if (aRelayout) {
        [self layoutIfNeeded];
    }
    _helpIsActive = NO;
    [[self assistant] toggleDrawerModeWithDrawerSize:[[self actionHelpView] frame].size];
}

- (id)helpDrawer
{
    id pvVar1;
    id pvVar2;
    HSObjectAssistantDrawer *pHVar4;

    pHVar4 = _helpDrawer;
    if (pHVar4 == nil) {
        pvVar1 = [HSObjectAssistantDrawer alloc];
        pvVar2 = [self assistant];
        _helpDrawer = [pvVar1 initWithContentView:[self actionHelpView] objectAssistant:pvVar2];
        [[_helpTextView textStorage] setAttributedString:[[HSNBAHelpProvider sharedNBAHelpProvider] localizedHelpForActionOfType:[HSPlayAnimationAction actionType]]];
        pHVar4 = _helpDrawer;
    }
    return pHVar4;
}

- (id)actionHelpView
{
    return _actionHelpView;
}

- (BOOL)isHelpVisible
{
    return _helpIsActive;
}

- (void)updatePathOptionsUI
{
    [self updateBeginAndEndArrows];
    [self updateFlipsUI];
    id animation = [self animation];
    [_pathPlayStopButton setEnabled:[animation animatedObject] != nil];
    BOOL fromEnd = [animation playbackDirection] == 1;
    [_startFromBeginButton setState:!fromEnd];
    [_startFromEndButton setState:fromEnd];
    [self HSAnimationSetupMainAssistantPane_validateGoingAbsoluteLayerGUI];
    [self HSAnimationSetupMainAssistantPane_validateReturningAbsoluteLayerGUI];
    [_floatOverReturningButton setEnabled:[animation playBackAndForth]];
    [_dontEraseReturningButton setEnabled:[animation playBackAndForth]];
    [_dontEraseGoingButton setState:[animation dontEraseGoing] ? 1 : 0];
    [_dontEraseReturningButton setState:[animation dontEraseReturning] ? 1 : 0];
    [_layerPopUpButton selectItemWithTag:[(HSAnimation *)animation layer]];
    NSInteger speedMode = [animation speedMode];
    [_movePopUpButton selectItemWithTag:speedMode];
    int value;
    if (speedMode == 0) {
        [_moveValueTextField setHidden:YES];
        [_moveValueStepper setHidden:YES];
        [_moveValuePopUpButton setHidden:NO];
        [_secondsLabel setHidden:YES];
        for (NSInteger tag = 0; tag < 5; tag++) {
            if ((float)[animation speedMultiplier] == HSAnimationSetupSpeedMultipliers[tag]) {
                [_moveValuePopUpButton selectItemWithTag:tag];
                return;
            }
        }
        return;
    }
    if (speedMode == 2) {
        [_moveValueTextField setHidden:NO];
        [_moveValueStepper setHidden:NO];
        [_moveValuePopUpButton setHidden:YES];
        [_secondsLabel setHidden:YES];
        [[_moveValueTextField formatter] setMinimum:[NSNumber numberWithInt:1]];
        [[_moveValueTextField formatter] setMaximum:[NSNumber numberWithInt:99]];
        [_moveValueStepper setMaxValue:99.0];
        [_moveValueStepper setMinValue:1.0];
        value = (int)[animation timesPerSecond];
        if (value >= 100) {
            value = 99;
        }
    }
    else if (speedMode == 1) {
        [_moveValueTextField setHidden:NO];
        [_moveValueStepper setHidden:NO];
        [_moveValuePopUpButton setHidden:YES];
        [_secondsLabel setHidden:NO];
        [[_moveValueTextField formatter] setMinimum:[NSNumber numberWithInt:1]];
        [[_moveValueTextField formatter] setMaximum:[NSNumber numberWithInt:9999]];
        [_moveValueStepper setMinValue:1.0];
        [_moveValueStepper setMaxValue:9999.0];
        value = (int)[animation clampedDuration];
        if (value >= 10000) {
            value = 9999;
        }
    }
    else {
        return;
    }
    if (value < 1) {
        value = 1;
    }
    [_moveValueTextField setIntValue:value];
    [_moveValueStepper setIntValue:value];
}

- (void)updateFlipsUI
{
    id geometry = [[[self animation] animatedObject] queryHyperInterface:@protocol(HSGeometryBehaviorAttributes)];
    BOOL canFlipHorizontally = [geometry canFlipHorizontally];
    BOOL canFlipVertically = [geometry canFlipVertically];
    // Start flips apply when going back and forth from the end, finish flips from the beginning.
    BOOL atStart = [[self animation] playBackAndForth] && [[self animation] playbackDirection] == 1;
    BOOL atFinish = [[self animation] playBackAndForth] && [[self animation] playbackDirection] == 0;
    [_horizontalFlipAtStartButton setEnabled:atStart && canFlipHorizontally];
    [_verticalFlipAtStartButton setEnabled:atStart && canFlipVertically];
    [_horizontalFlipAtFinishButton setEnabled:atFinish && canFlipHorizontally];
    [_verticalFlipAtFinishButton setEnabled:atFinish && canFlipVertically];
    [_horizontalFlipAtStartButton setState:(atStart && canFlipHorizontally && [[self animation] horizontalFlipAtStart]) ? 1 : 0];
    [_verticalFlipAtStartButton setState:(atStart && canFlipVertically && [[self animation] verticalFlipAtStart]) ? 1 : 0];
    [_horizontalFlipAtFinishButton setState:(atFinish && canFlipHorizontally && [[self animation] horizontalFlipAtFinish]) ? 1 : 0];
    [_verticalFlipAtFinishButton setState:(atFinish && canFlipVertically && [[self animation] verticalFlipAtFinish]) ? 1 : 0];
}

- (void)updateBeginAndEndArrows
{
    NSString *beginToolTip = [[NSBundle mainBundle] localizedStringForKey:@"HSAnimationBeginPathToolTip" value:@"" table:@"AssistantPanes"];
    NSString *endToolTip = [[NSBundle mainBundle] localizedStringForKey:@"HSAnimationEndPathToolTip" value:@"" table:@"AssistantPanes"];
    if ([[self animation] playbackDirection] == 0) {
        [_beginArrowButton setImage:[[self class] leftStartImage]];
        [_endArrowButton setImage:([[self animation] playBackAndForth] ? [[self class] rightTurnImage] : [[self class] rightEndImage])];
        [_beginArrowButton setEnabled:NO];
        [_endArrowButton setEnabled:YES];
        [_beginArrowButton setToolTip:beginToolTip];
        [_endArrowButton setToolTip:endToolTip];
    }
    else if ([[self animation] playbackDirection] == 1) {
        [_beginArrowButton setImage:([[self animation] playBackAndForth] ? [[self class] leftTurnImage] : [[self class] leftEndImage])];
        [_endArrowButton setImage:[[self class] rightStartImage]];
        [_beginArrowButton setEnabled:YES];
        [_endArrowButton setEnabled:NO];
        // With the direction reversed the two tooltips swap buttons.
        [_beginArrowButton setToolTip:endToolTip];
        [_endArrowButton setToolTip:beginToolTip];
    }
}

- (void)setLayer:(NSInteger)aLayer
{
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change Options" value:@"" table:@"UndoManager"]];
    [(HSAnimationSetupMainAssistantPane *)[[self undoManager] prepareWithInvocationTarget:self] setLayer:[(HSAnimation *)[self animation] layer]];
    [[self undoHelper] duplicateAction];
    [(HSAnimation *)[self allAnimations] setLayer:aLayer];
    [self updatePathOptionsUI];
}

- (void)changeLayer:(id)aLayer
{
    id pvVar1_3;

    [self setLayer:[[aLayer selectedItem] tag]];
    pvVar1_3 = _layerPopUpButton;
    [pvVar1_3 setToolTip:[[pvVar1_3 selectedItem] toolTip]];
}

- (void)setSpeedMultiplier:(CGFloat)aMultiplier
{
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change Options" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setSpeedMultiplier:(float)[[self animation] speedMultiplier]];
    [[self undoHelper] duplicateAction];
    [[self allAnimations] setSpeedMultiplier:aMultiplier];
    [self updatePathOptionsUI];
}

- (void)changeMoveValueFromPopUpButton:(id)aButton
{
    [self setSpeedMultiplier:HSAnimationSetupSpeedMultipliers[[[aButton selectedItem] tag]]];
}

- (void)setClampedDuration:(NSInteger)aDuration timesPerSecond:(NSInteger)aSecond
{
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change Options" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setClampedDuration:(int)[[self animation] clampedDuration] timesPerSecond:[[self animation] timesPerSecond]];
    [[self undoHelper] duplicateAction];
    NSInteger duration = aDuration;
    if (duration >= 10000) {
        duration = 9999;
    }
    else if (duration < 1) {
        duration = 1;
    }
    [[self allAnimations] setClampedDuration:(double)duration];
    NSInteger timesPerSecond = aSecond;
    if (timesPerSecond >= 100) {
        timesPerSecond = 99;
    }
    else if (timesPerSecond < 1) {
        timesPerSecond = 1;
    }
    [[self allAnimations] setTimesPerSecond:timesPerSecond];
    [self updatePathOptionsUI];
}

- (void)changeMoveValue:(id)aValue
{
    NSInteger duration = (int)[[self animation] clampedDuration];
    NSInteger timesPerSecond = [[self animation] timesPerSecond];
    // The original fed the pop-up, not the stepper, when the value came from elsewhere.
    if (_moveValueStepper != aValue) {
        [_moveValuePopUpButton takeIntValueFrom:aValue];
    }
    if (_moveValueTextField != aValue) {
        [_moveValueTextField takeIntValueFrom:aValue];
    }
    NSInteger mode = [[_movePopUpButton selectedCell] tag];
    if (mode == 1) {
        duration = [aValue intValue];
    }
    else if (mode == 2) {
        timesPerSecond = [aValue intValue];
    }
    [self setClampedDuration:duration timesPerSecond:timesPerSecond];
}

- (void)setSpeedMode:(NSInteger)aMode
{
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change Options" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setSpeedMode:[[self animation] speedMode]];
    [[self undoHelper] duplicateAction];
    [[self allAnimations] setSpeedMode:aMode];
    [self updatePathOptionsUI];
}

- (void)setDontEraseReturning:(BOOL)aReturning
{
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change Options" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setDontEraseReturning:(unsigned int)(aReturning == 0)];
    [[self undoHelper] duplicateAction];
    [[self allAnimations] setDontEraseReturning:aReturning];
    [self updatePathOptionsUI];
}

- (void)toggleDontEraseReturning:(id)aReturning
{
    [self setDontEraseReturning:(unsigned int)(![[self animation] dontEraseReturning])];
}

- (void)setDontEraseGoing:(BOOL)aGoing
{
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change Options" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setDontEraseGoing:(unsigned int)(aGoing == 0)];
    [[self undoHelper] duplicateAction];
    [[self allAnimations] setDontEraseGoing:aGoing];
    [self updatePathOptionsUI];
}

- (void)toggleDontEraseGoing:(id)aGoing
{
    [self setDontEraseGoing:(unsigned int)(![[self animation] dontEraseGoing])];
}

- (void)changeReturningAbsoluteLayer:(id)aLayer
{
    [self HSAnimationSetupMainAssistantPane_setReturningAbsoluteLayer:[[aLayer selectedItem] tag]];
}

- (void)HSAnimationSetupMainAssistantPane_setReturningAbsoluteLayer:(NSInteger)aLayer
{
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change Options" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] HSAnimationSetupMainAssistantPane_setReturningAbsoluteLayer:[[self animation] returningAbsoluteLayer]];
    [[self undoHelper] duplicateAction];
    [[self allAnimations] setReturningAbsoluteLayer:aLayer];
    [self HSAnimationSetupMainAssistantPane_validateReturningAbsoluteLayerGUI];
}

- (void)HSAnimationSetupMainAssistantPane_validateReturningAbsoluteLayerGUI
{
    NSInteger layer = [[self animation] returningAbsoluteLayer];
    [_returningImageView setImage:(layer != 0 ? [[self class] floatOverImage] : [[self class] noFloatOverImage])];
    [_floatOverReturningButton selectItemWithTag:layer];
    [_floatOverReturningButton setToolTip:[[_floatOverReturningButton selectedItem] toolTip]];
}

- (void)changeGoingAbsoluteLayer:(id)aLayer
{
    [self HSAnimationSetupMainAssistantPane_setGoingAbsoluteLayer:[[aLayer selectedItem] tag]];
}

- (void)HSAnimationSetupMainAssistantPane_setGoingAbsoluteLayer:(NSInteger)aLayer
{
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change Options" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] HSAnimationSetupMainAssistantPane_setGoingAbsoluteLayer:[[self animation] goingAbsoluteLayer]];
    [[self undoHelper] duplicateAction];
    [[self allAnimations] setGoingAbsoluteLayer:aLayer];
    [self HSAnimationSetupMainAssistantPane_validateGoingAbsoluteLayerGUI];
}

- (void)HSAnimationSetupMainAssistantPane_validateGoingAbsoluteLayerGUI
{
    NSInteger layer = [[self animation] goingAbsoluteLayer];
    [_goingImageView setImage:(layer != 0 ? [[self class] floatOverImage] : [[self class] noFloatOverImage])];
    [_floatOverGoingButton selectItemWithTag:layer];
    [_floatOverGoingButton setToolTip:[[_floatOverGoingButton selectedItem] toolTip]];
}

- (void)framesPerSecondChanged:(id)aChanged
{
    [self changeMovieSpeeed:aChanged];
}

- (void)setPlaybackDirection:(NSInteger)aDirection
{
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change Options" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setPlaybackDirection:[[self animation] playbackDirection]];
    [[self undoHelper] duplicateAction];
    [[self allAnimations] setPlaybackDirection:aDirection];
    [self updatePathOptionsUI];
    [self updatePathInEditPathTool];
}

- (void)toggleStartHere:(id)aHere
{
    [self setPlaybackDirection:(unsigned int)(_startFromEndButton == aHere)]
    ;
}

- (void)setVerticalFlipAtFinish:(BOOL)aFinish
{
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change Options" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setVerticalFlipAtFinish:(unsigned int)(aFinish == 0)];
    [[self undoHelper] duplicateAction];
    [[self allAnimations] setVerticalFlipAtFinish:aFinish];
    [self updatePathOptionsUI];
}

- (void)toggleVerticalFlipAtFinish:(id)aFinish
{
    [self setVerticalFlipAtFinish:(unsigned int)(![[self animation] verticalFlipAtFinish])];
}

- (void)setHorizontalFlipAtFinish:(BOOL)aFinish
{
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change Options" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setHorizontalFlipAtFinish:(unsigned int)(aFinish == 0)];
    [[self undoHelper] duplicateAction];
    [[self allAnimations] setHorizontalFlipAtFinish:aFinish];
    [self updatePathOptionsUI];
}

- (void)toggleHorizontalFlipAtFinish:(id)aFinish
{
    [self setHorizontalFlipAtFinish:(unsigned int)(![[self animation] horizontalFlipAtFinish])];
}

- (void)setVerticalFlipAtStart:(BOOL)aStart
{
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change Options" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setVerticalFlipAtStart:(unsigned int)(aStart == 0)];
    [[self undoHelper] duplicateAction];
    [[self allAnimations] setVerticalFlipAtStart:aStart];
    [self updatePathOptionsUI];
}

- (void)toggleVerticalFlipAtStart:(id)aStart
{
    [self setVerticalFlipAtStart:(unsigned int)(![[self animation] verticalFlipAtStart])];
}

- (void)setHorizontalFlipAtStart:(BOOL)aStart
{
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change Options" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setHorizontalFlipAtStart:(unsigned int)(aStart == 0)];
    [[self undoHelper] duplicateAction];
    [[self allAnimations] setHorizontalFlipAtStart:aStart];
    [self updatePathOptionsUI];
}

- (void)toggleHorizontalFlipAtStart:(id)aStart
{
    [self setHorizontalFlipAtStart:(unsigned int)(![[self animation] horizontalFlipAtStart])];
}

- (void)setPlayBackAndForth:(BOOL)aForth
{
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change Options" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setPlayBackAndForth:(unsigned int)(aForth == 0)];
    [[self undoHelper] duplicateAction];
    [[self allAnimations] setPlayBackAndForth:aForth];
    [self updatePathOptionsUI];
}

- (void)toggleEndArrow:(id)aArrow
{
    if ([[self animation] playbackDirection] == 0) {
        [self setPlayBackAndForth:(unsigned int)(![[self animation] playBackAndForth])];
    }
}

- (void)toggleBeginArrow:(id)aArrow
{
    if ([[self animation] playbackDirection] == 0x1) {
        [self setPlayBackAndForth:(unsigned int)(![[self animation] playBackAndForth])];
    }
}

- (void)toggleTransparentColor:(id)aColor
{
    [self toggleTransparentColorToValue:(unsigned int)([aColor state] == 0x1)];
}

- (void)toggleTransparentColorToValue:(BOOL)aValue
{
    BOOL registeredUndo = NO;
    if (!aValue || [[self allAnimations] transparentColor] != nil) {
        [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change Options" value:@"" table:@"UndoManager"]];
        [[[self undoManager] prepareWithInvocationTarget:self] toggleTransparentColorToValue:!aValue];
        [[self undoHelper] duplicateAction];
        [self disableAnimationsUndo];
        registeredUndo = YES;
    }
    if (!aValue) {
        [[self allAnimations] setUsesTransparentColor:NO];
    }
    else if ([[self allAnimations] transparentColor] != nil) {
        [[self allAnimations] setUsesTransparentColor:YES];
    }
    else {
        [self changeTransparentColor:nil];
    }
    if (registeredUndo) {
        [self enableAnimationsUndo];
    }
    [self transparentColorValidate];
}

- (void)flipVertically:(id)aVertically
{
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change Options" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] flipVertically:aVertically];
    [[self undoHelper] duplicateAction];
    id animations[2] = { [self animation], [self tryItAnimation] };
    for (int i = 0; i < 2; i++) {
        [[[animations[i] animatedObject] undoManager] disableUndoRegistration];
        [animations[i] flipAnimatedObjectVertically];
        [[[animations[i] animatedObject] undoManager] enableUndoRegistration];
    }
    [self updateMainOptionsUI];
}

- (void)flipHorizontally:(id)aHorizontally
{
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change Options" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] flipHorizontally:aHorizontally];
    [[self undoHelper] duplicateAction];
    id animations[2] = { [self animation], [self tryItAnimation] };
    for (int i = 0; i < 2; i++) {
        [[[animations[i] animatedObject] undoManager] disableUndoRegistration];
        [animations[i] flipAnimatedObjectHorizntally];
        [[[animations[i] animatedObject] undoManager] enableUndoRegistration];
    }
    [self updateMainOptionsUI];
}

- (void)changePlayForTypeOptionsFrom:(id)aFrom to:(id)aTo
{
    int pvVar1_6;
    int pvVar2_4;

    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change Options" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] changePlayForTypeOptionsFrom:aTo to:aFrom];
    [[self undoHelper] duplicateAction];
    pvVar1_6 = [[aTo objectAtIndex:0] intValue];
    pvVar2_4 = [[aTo objectAtIndex:1] intValue];
    [[self allAnimations] setLoopMode:pvVar1_6];
    [[self allAnimations] setLoopSeconds:(double)(int)pvVar2_4];
    [[self allAnimations] setLoopPathRepeats:pvVar2_4];
    [[self allAnimations] setLoopFrameRepeats:pvVar2_4];
    [self updateMainOptionsUI];
}

- (BOOL)optionsDiffer:(id)aDiffer :(id)aArg
{
    int iVar3;

    iVar3 = 0;
    while( YES ) {
        if (1 < iVar3) {
            return NO;
        }
        if ([[aDiffer objectAtIndex:iVar3] intValue] != [[aArg objectAtIndex:iVar3] intValue]) break;
        iVar3 = iVar3 + 1;
    }
    return YES;
}

- (void)changePlayForValue:(id)aValue
{
    NSInteger type = [[_playForPopUpButton selectedItem] tag];
    if ([aValue intValue] < 1) {
        [_playForValueTextField setIntValue:1];
    }
    NSArray *oldOptions = [self oldOptions];
    NSMutableArray *newOptions = [[oldOptions mutableCopy] autorelease];
    if (type == 1) {
        [newOptions replaceObjectAtIndex:0 withObject:[NSNumber numberWithInt:2]];
    }
    [newOptions replaceObjectAtIndex:1 withObject:[NSNumber numberWithInt:[aValue intValue]]];
    if ([self optionsDiffer:oldOptions :newOptions]) {
        [self changePlayForTypeOptionsFrom:oldOptions to:newOptions];
    }
}

- (id)oldOptions
{
    NSInteger loopMode = [[self animation] loopMode];
    int value;
    if (loopMode == 3) {
        value = (int)[[self animation] loopSeconds];
    }
    else if (loopMode == 1 || loopMode == 2) {
        value = (int)[[self animation] loopPathRepeats];
    }
    else if (loopMode == 4) {
        value = (int)[[self animation] loopFrameRepeats];
    }
    else {
        value = 1;
    }
    // A loop mode of 0 is reported as path repeats.
    return [NSArray arrayWithObjects:[NSNumber numberWithInt:(int)(loopMode != 0 ? loopMode : 2)], [NSNumber numberWithInt:value], nil];
}

- (void)setMovieSpeed:(double)aSpeed
{
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change Options" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setMovieSpeed:[[self animation] movieSpeed]];
    [[self undoHelper] duplicateAction];
    [[self allAnimations] setMovieSpeed:aSpeed];
    [self updateMainOptionsUI];
}

- (void)changeMovieSpeeed:(id)aSpeeed
{
    double speed = [aSpeeed doubleValue];
    if (!(speed >= 1.0)) {
        speed = 1.0;
    }
    else if (speed > 100.0) {
        speed = 100.0;
    }
    [self setMovieSpeed:speed];
    [self updateMainOptionsUI];
}

- (void)setUseClones:(BOOL)aClones
{
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change Options" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setUseClones:(unsigned int)(aClones == 0)];
    [[self undoHelper] duplicateAction];
    [[self allAnimations] setUseClones:aClones];
    [self updateMainOptionsUI];
}

- (void)toggleAllowClones:(id)aClones
{
    [self setUseClones:(unsigned int)([aClones state] == 0x1)];
}

- (void)setMatchToMovement:(BOOL)aMovement
{
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change Options" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setMatchToMovement:(unsigned int)(aMovement == 0)];
    [[self undoHelper] duplicateAction];
    [[self allAnimations] setMatchToMovement:aMovement];
    [self updateMainOptionsUI];
}

- (void)toggleMatchToMovement:(id)aMovement
{
    [self setMatchToMovement:(unsigned int)([aMovement selectedRow] == 0)];
}

- (void)setHideOnLastFrame:(BOOL)aFrame
{
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change Options" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setHideOnLastFrame:(unsigned int)(aFrame == 0)];
    [[self undoHelper] duplicateAction];
    [[self allAnimations] setHideOnLastFrame:aFrame];
    [self updateMainOptionsUI];
}

- (void)toggleEraseWhenDone:(id)aDone
{
    [self setHideOnLastFrame:(unsigned int)([aDone state] == 0x1)];
}

- (void)setHideOnFirstFrame:(BOOL)aFrame
{
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change Options" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setHideOnFirstFrame:(unsigned int)(aFrame == 0)];
    [[self undoHelper] duplicateAction];
    [[self allAnimations] setHideOnFirstFrame:aFrame];
    [self updateMainOptionsUI];
}

- (void)toggleShowFirstFrame:(id)aFrame
{
    [self setHideOnFirstFrame:(unsigned int)([aFrame state] != 0x1)];
}

- (void)switchToOptionView:(NSInteger)aView
{
    if (aView == 1) {
        [_optionsView replaceSubview:_mainOptionsView with:_pathOptionsView];
        [self updatePathOptionsUI];
    }
    else if (aView == 0) {
        [_optionsView replaceSubview:_pathOptionsView with:_mainOptionsView];
        [self updateMainOptionsUI];
    }
}

- (void)switchOptionView:(id)aView
{
    [self switchToOptionView:[[aView selectedCell] tag]];
}

- (void)enableAnimationsUndo
{
    [[[[self animation] animatedObject] undoManager] enableUndoRegistration];
    [[[[self tryItAnimation] animatedObject] undoManager] enableUndoRegistration];
}

- (void)disableAnimationsUndo
{
    [[[[self animation] animatedObject] undoManager] disableUndoRegistration];
    [[[[self tryItAnimation] animatedObject] undoManager] disableUndoRegistration];
}

- (id)navigationPaneSwitcher
{
    HSNBAAssistantNavigationPaneSwitcher *pHVar1;
    HSNBAAssistantNavigationPaneSwitcher *pHVar1_2;

    pHVar1 = _navigationPaneSwitcher;
    if (pHVar1 == nil) {
        pHVar1_2 = [HSNBAAssistantNavigationPaneSwitcher new];
        _navigationPaneSwitcher = pHVar1_2;
        [pHVar1_2 setDelegate:self];
        pHVar1 = _navigationPaneSwitcher;
    }
    return pHVar1;
}

- (BOOL)assistantShouldBeKeyWindow
{
    return YES;
}

- (id)allAnimations
{
    id pvVar1;

    pvVar1 = [self tryItAnimation];
    return [_HSAnimationsProxy proxyWithObjects:[NSArray arrayWithObjects:[self animation], pvVar1, nil]];
}

- (BOOL)isMovieAnimation
{
    return _isMovieAnimation;
}

- (BOOL)requiresDarkBottomArea
{
    return YES;
}

- (id)init
{
    self = [super initWithNibName:@"AnimationSetupMainPane"];
    if (self != nil) {
        _isBlockingUndoRegistration = NO;
        _initialInspectorSupportsSOTSMode = NO;
        _didFinishAndApply = NO;
    }
    return self;
}

- (void)dealloc
{
    if ([[HSToolManager sharedToolManager] selectedToolTag] == 0x37) {
        id tool = [[HSToolManager sharedToolManager] currentTool];
        if ([tool delegate] == self) {
            [self resetToolToDefault];
        }
    }
    [self setObject:nil];
    [_navigationController release];
    [_navigationPaneSwitcher release];
    [_helpDrawer release];
    [_actionHelpView release];
    [_storedPath release];
    [_storedKeyFrames release];
    [_undoHelper finishDuplicating:NO];
    [_undoHelper release];
    [_undoManager release];
    [_dummyUndoManager release];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_actionEvents release];
    [_animation release];
    [_initialAnimation release];
    [_tryItAnimation release];
    [_pickImageAssistantPane setDelegate:nil];
    [_pickImageAssistantPane release];
    [_drawPathAssistantPane setDelegate:nil];
    [_drawPathAssistantPane release];
    [_transparentColorAssistantPane setDelegate:nil];
    [_transparentColorAssistantPane release];
    [_cardView release];
    [super dealloc];
}

- (id)animation
{
    return _animation;
}

- (id)tryItAnimation
{
    return _tryItAnimation;
}

- (id)undoHelper
{
    return _undoHelper;
}

- (id)undoManager
{
    if (_undoManager == nil) {
        _undoManager = [HSUndoManager new];
    }
    return _undoManager;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [_segmentedControl setBackgroundRenderer:[HSAnimationOptionsControlBackgroundRenderer sharedBackgroundRenderer]];
    [_segmentedControl setPrototype:[_segmentedControl cellAtRow:0 column:1]];
    [_optionsView addSubview:_mainOptionsView];
    [self setPlayStopImage:[[self class] playAnimationImage]];
    [[_beginArrowButton cell] setBackgroundRenderer:[HSAssistantPaneControlBackgroundRenderer sharedBackgroundRenderer]];
    [[_endArrowButton cell] setBackgroundRenderer:[HSAssistantPaneControlBackgroundRenderer sharedBackgroundRenderer]];
    [[_startFromBeginButton cell] setBackgroundRenderer:[HSAssistantPaneControlBackgroundRenderer sharedBackgroundRenderer]];
    [[_startFromEndButton cell] setBackgroundRenderer:[HSAssistantPaneControlBackgroundRenderer sharedBackgroundRenderer]];
    [_playForPopUpButton setAutoenablesItems:NO];
    [[_playForPopUpButton menu] removeItemAtIndex:0];
    [[_playForPopUpButton menu] removeItemAtIndex:1];
}

- (void)viewWillAppear:(BOOL)aAppear
{
    [super viewWillAppear:aAppear];
    [self setState:2];
    if ([self animation] == nil) {
        [self setUpAnimation];
    }
    [self lockAssistantIfNeeded];
    if (_tryItAnimation == nil) {
        [self setUpTryItAnimation];
    }
    [self runEditPath];
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(controlTextDidChange:) name:NSControlTextDidChangeNotification object:_movieSpeedTextField];
    [center addObserver:self selector:@selector(controlTextDidChange:) name:NSControlTextDidChangeNotification object:_playForValueTextField];
    [center addObserver:self selector:@selector(controlTextDidChange:) name:NSControlTextDidChangeNotification object:_moveValueTextField];
    [center addObserver:self selector:@selector(HSAnimationSetupMainAssistantPane_toolDidChange:) name:@"HSActiveToolDidSelectionNotification" object:[HSToolManager sharedToolManager]];
    [center addObserver:self selector:@selector(HSAnimationSetupMainAssistantPane_currentCardWillChange:) name:HSCurrentCardInCardViewWillChange object:_cardView];
    [center addObserver:self selector:@selector(HSAnimationSetupMainAssistantPane_windowDidResignMain:) name:NSWindowDidResignMainNotification object:[_cardView window]];
    id stack = [[self document] stack];
    [stack addObserver:self selector:@selector(HSAnimationSetupMainAssistantPane_cardsWillChange:) ofChanges:HSActualWillAttributeChanges ofAttribute:@protocol(HSNodeContainerChildrenAttribute) withPriority:-0.25];
    [stack addObserver:self selector:@selector(HSAnimationSetupMainAssistantPane_objectsWillChange:) ofChanges:HSActualWillAttributeChanges ofChildrenAttribute:@protocol(HSNodeContainerChildrenAttribute) withPriority:-0.25];
    [_layerPopUpButton setToolTip:[[_layerPopUpButton selectedItem] toolTip]];
    [_movePopUpButton setToolTip:[[_playForPopUpButton selectedItem] toolTip]];
    [self updateUI:YES];
    [self transparentColorValidate];
    [self cleanupTemporaryAnimationAssistantPanes];
    [_drawPathAssistantPane setDelegate:nil];
    [_drawPathAssistantPane release];
    _drawPathAssistantPane = nil;
    [_pickImageAssistantPane setDelegate:nil];
    [_pickImageAssistantPane release];
    _pickImageAssistantPane = nil;
}

- (void)viewWillDisappear:(BOOL)aDisappear
{
    if (!_didFinishAndApply) {
        [self cleanUpAnimation:YES];
    }
    if ([self isHelpVisible]) {
        [self hideHelpNeedsRelayout:YES];
    }
    [super viewWillDisappear:aDisappear];
    if (_transparentColorAssistantPane == nil) {
        [self cleanUpTryItAnimation];
    }
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self name:NSControlTextDidChangeNotification object:_playForValueTextField];
    [center removeObserver:self name:NSControlTextDidChangeNotification object:_movieSpeedTextField];
    [center removeObserver:self name:NSControlTextDidChangeNotification object:_moveValueTextField];
    [center removeObserver:self name:@"HSActiveToolDidSelectionNotification" object:[HSToolManager sharedToolManager]];
    [center removeObserver:self name:HSCurrentCardInCardViewWillChange object:_cardView];
    [center removeObserver:self name:NSWindowDidResignMainNotification object:[_cardView window]];
    id stack = [[self document] stack];
    [stack removeObserver:self selector:@selector(HSAnimationSetupMainAssistantPane_cardsWillChange:) ofChanges:HSActualWillAttributeChanges ofAttribute:@protocol(HSNodeContainerChildrenAttribute)];
    [stack removeObserver:self selector:@selector(HSAnimationSetupMainAssistantPane_objectsWillChange:) ofChanges:HSActualWillAttributeChanges ofChildrenAttribute:@protocol(HSNodeContainerChildrenAttribute)];
}

- (void)controlTextDidChange:(id)aChange
{
    id object = [aChange object];
    if (object == _movieSpeedTextField) {
        [self framesPerSecondChanged:object];
    } else if (object == _playForValueTextField) {
        [self changePlayForValue:object];
    } else if (object == _moveValueTextField) {
        [self changeMoveValue:object];
    }
}

- (void)setIsMovieAnimation:(BOOL)aAnimation
{
    if ([_animation useClones]) {
        [_animation setUseClones:!aAnimation];
    }
    if (_initialAnimation == nil) {
        [_animation setLoopMode:(aAnimation ? 2 : 0) + 2];
    }
    _isMovieAnimation = aAnimation;
    [self updateAnimationForCurrentPath];
}

- (void)getNewSource:(id)aSource
{
    [self updateAnimatedObjectFromTryItAnimation];
    [self setState:3];
    [self runPickImage];
}

- (void)playStop:(id)aStop
{
    if (![[self tryItAnimation] isPlaying]) {
        _initialInspectorSupportsSOTSMode = [[HSObjectAssistantController sharedAssistantController] supportsSettingsOnTheSpotMode];
        [[HSObjectAssistantController sharedAssistantController] setSupportsSettingsOnTheSpotMode:NO];
        if ([_tryItAnimation playMovie]) {
            id playable = [[_tryItAnimation animatedObject] queryHyperInterface:@protocol(HSPlayableObjectAttributes)];
            if (playable != nil) {
                struct HSTimeRange range = [playable hyperPlayRange];
                [playable setHyperCurrentTime:range.location];
            }
        }
        [_cardView selectHyperObjects:nil];
        [self selectToolWithTag:0x38];
        [_cardView setOccupiedByTool:YES];
        [self updateAnimatedObjectFromTryItAnimation];
        [_tryItAnimation setSuppressDontErase:NO];
        [[self undoManager] disableUndoRegistration];
        [self disableAnimationsUndo];
        [[[self card] animationController] changeObjectIndexOnStartingAnimation:_tryItAnimation inAbsoluteLayer:[_tryItAnimation goingAbsoluteLayer] forActingObject:[self object]];
        [_tryItAnimation start:YES];
        [[self undoManager] enableUndoRegistration];
        [self enableAnimationsUndo];
        [self updateUI:NO];
    } else {
        [[self tryItAnimation] stop];
        [self runEditPath];
    }
}

- (void)newPath:(id)aPath
{
    NSNumber *show = [[NSUserDefaults standardUserDefaults] objectForKey:HSShowNewPathAlertKey];
    if (show == nil || [show intValue] != 0) {
        HSDontShowAgainAlert *alert = [HSDontShowAgainAlert new];
        [alert setShowAlertKey:HSShowNewPathAlertKey];
        [alert setMessageText:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"HSNewAnimationPathMessageText" value:@"" table:@"Alerts"]];
        [alert setInformativeText:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"HSNewAnimationPathInformativeText" value:@"" table:@"Alerts"]];
        [alert addButtonWithTitle:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"HSNewAnimationPathCreateButtonTitle" value:@"" table:@"Alerts"]];
        [alert addButtonWithTitle:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"Cancel" value:@"" table:@"Alerts"]];
        NSInteger result = [alert runModal];
        [alert release];
        if (result == NSAlertSecondButtonReturn) {
            return;
        }
    }
    [self updateAnimatedObjectFromTryItAnimation];
    [self cleanUpTryItAnimation];
    [self setState:4];
    [_animation setTimesPerSecond:[HSAnimationOptions undefinedTimesPerSecond]];
    [self runDrawPath];
}

- (void)changeMove:(id)aMove
{
    [self setSpeedMode:[[aMove selectedCell] tag]];
    [_movePopUpButton setToolTip:[[_movePopUpButton selectedItem] toolTip]];
}

- (void)changeTransparentColor:(id)aColor
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"HSActiveToolDidSelectionNotification" object:[HSToolManager sharedToolManager]];
    [self resetToolToDefault];
    _transparentColorAssistantPane = [[HSTransparentColorAssistantPane alloc] init];
    [_transparentColorAssistantPane setDelegate:self];
    [_transparentColorAssistantPane setWindowTitle:[self windowTitle]];
    [self pushAnimationViewController:_transparentColorAssistantPane];
}

- (void)paneDidOK:(id)aOK
{
    [self finishAndApplyChanges:YES];
}

- (void)paneDidCancel:(id)aCancel
{
    [self finishAndApplyChanges:NO];
}

- (void)transparentColorValidate
{
    id animatedObject = [[self animation] animatedObject];
    BOOL enabled = NO;
    if ([animatedObject implementsHyperInterface:@protocol(HSTransparentColorAttributes)]
        && [animatedObject queryHyperInterface:@protocol(HSMovieObjectAttributes)] == nil) {
        enabled = YES;
    }
    if (enabled && [[self allAnimations] usesTransparentColor]) {
        [_transparentColorPickerButton setState:1];
        [_transparentColorPickerButton setTitle:@""];
        [_transparentColorPickerButton sizeToFit];
        [_transparentColorButton setHidden:NO];
        return;
    }
    if (!enabled) {
        [_transparentColorPickerButton setEnabled:NO];
    }
    [_transparentColorPickerButton setState:0];
    [_transparentColorPickerButton setTitle:[_transparentColorButton title]];
    [_transparentColorPickerButton sizeToFit];
    [_transparentColorButton setHidden:YES];
}

- (void)changePlayForType:(id)aType
{
    NSInteger tag = [[_playForPopUpButton selectedItem] tag];
    NSArray *oldOptions = [self oldOptions];
    NSMutableArray *newOptions = [[oldOptions mutableCopy] autorelease];
    int loopMode = 2;
    if (tag != 1) {
        loopMode = (tag == 3) ? 1 : -1;
    }
    [newOptions replaceObjectAtIndex:0 withObject:[NSNumber numberWithInt:loopMode]];
    if ([self optionsDiffer:oldOptions :newOptions]) {
        [self changePlayForTypeOptionsFrom:oldOptions to:newOptions];
    }
}

- (void)updateMainOptionsUI
{
    BOOL playMovie = [[self animation] playMovie];
    BOOL onePoint = [[self animation] isOnePointPathAnimation];
    [_segmentedControl setEnabled:!onePoint];
    if (onePoint) {
        [_optionsView replaceSubview:_pathOptionsView with:_mainOptionsView];
        [_segmentedControl selectCellWithTag:0];
    }
    BOOL hasObject = [[self animation] animatedObject] != nil;
    [_mainPlayStopButton setEnabled:hasObject];
    [_newPathButton setEnabled:hasObject];
    BOOL hideFirst = hasObject && [[self animation] hideOnFirstFrame];
    [_showFirstFrameButton setState:!hideFirst];
    [_showFirstFrameButton setEnabled:hasObject];
    BOOL hideLast = hasObject && [[self animation] hideOnLastFrame];
    [_eraseWhenDoneButton setState:hideLast];
    [_eraseWhenDoneButton setEnabled:hasObject];
    [[_matchToMovementMatrix cellWithTag:0] setEnabled:(!onePoint && playMovie && hasObject)];
    [[_matchToMovementMatrix cellWithTag:1] setEnabled:playMovie];
    BOOL matchToMovement = playMovie && [[self animation] matchToMovement];
    [_matchToMovementMatrix selectCellAtRow:!matchToMovement column:0];
    BOOL allowClones = NO;
    if (!onePoint && hasObject) {
        allowClones = ![self isMovieAnimation];
    }
    [_allowClonesButton setEnabled:allowClones];
    [_allowClonesButton setState:[[self animation] useClones] ? 1 : 0];
    BOOL speedEnabled = NO;
    if (hasObject && playMovie) {
        speedEnabled = ![[self animation] matchToMovement];
    }
    [_movieSpeedTextField setEnabled:speedEnabled];
    [_movieSpeedStepper setEnabled:speedEnabled];
    if (speedEnabled) {
        double speed = [[self animation] movieSpeed];
        [_movieSpeedTextField setDoubleValue:speed];
        [_movieSpeedStepper setDoubleValue:speed];
    } else {
        [_movieSpeedTextField setStringValue:@""];
    }
    [[_playForPopUpButton itemAtIndex:[_playForPopUpButton indexOfItemWithTag:1]] setEnabled:!onePoint];
    BOOL playForEnabled = hasObject && [[self animation] loopMode] != 1;
    [_playForValueTextField setEnabled:playForEnabled];
    [_playForValueStepper setEnabled:playForEnabled];
    NSInteger loopMode = [[self animation] loopMode];
    if (loopMode == 0 || loopMode == 2) {
        [self setPlayForItemWithTag:1];
        if ([[self animation] loopMode] == 0) {
            [_playForValueTextField setIntValue:1];
        } else if ([[self animation] loopMode] == 2) {
            [_playForValueTextField setIntValue:(int)[[self animation] loopPathRepeats]];
        }
    } else if (loopMode == 1) {
        [self setPlayForItemWithTag:3];
        [_playForValueTextField setStringValue:@""];
    }
    [_playForValueStepper setIntValue:[_playForValueTextField intValue]];
    [self transparentColorValidate];
    id geometry = [[[self animation] animatedObject] queryHyperInterface:@protocol(HSGeometryBehaviorAttributes)];
    [_horizontalFlipButton setEnabled:[geometry canFlipHorizontally]];
    [_verticalFlipButton setEnabled:[geometry canFlipVertically]];
}

- (void)HSAnimationSetupMainAssistantPane_animationAbsoluteLayerDidChange:(id)aChange
{
    [self recreateTryItAnimationOnAnimationOptionsChange];
}

- (void)HSAnimationSetupMainAssistantPane_cardsWillChange:(id)aChange
{
    NSSet *removed = [[aChange userInfo] objectForKey:@"HSNodeChildrenForRemoval"];
    if ([[[aChange userInfo] objectForKey:@"HSNodeChildrenForAddition"] count] == 0 && ![removed containsObject:[self card]]) {
        return;
    }
    [self unlockAssistantAndResetTool];
}

- (void)HSAnimationSetupMainAssistantPane_currentCardWillChange:(id)aChange
{
    [self cleanUpTryItAnimation];
    [self unlockAssistantAndResetTool];
}

- (void)HSAnimationSetupMainAssistantPane_nameAttributesDidChange:(id)aChange
{
    [self refreshWindowTitle];
    id top = [_navigationController topViewController];
    if (top != self) {
        [top setWindowTitle:[self windowTitle]];
        if ([top isVisible]) {
            [[top assistant] updateInspectorName];
        }
    }
}

- (void)HSAnimationSetupMainAssistantPane_objectsWillChange:(id)aChange
{
    NSSet *removed = [[aChange userInfo] objectForKey:@"HSNodeChildrenForRemoval"];
    NSSet *added = [[aChange userInfo] objectForKey:@"HSNodeChildrenForAddition"];
    for (id object in added) {
        if (![object isTemporary]) {
            [self unlockAssistantAndResetTool];
            return;
        }
    }
    if ([removed containsObject:[self object]] || [removed containsObject:[_tryItAnimation animatedObject]]) {
        [self unlockAssistantAndResetTool];
    }
}

- (void)HSAnimationSetupMainAssistantPane_toolDidChange:(id)aChange
{
    NSInteger tag = [[HSToolManager sharedToolManager] selectedToolTag];
    if ((NSUInteger)(tag - 0x37) > 1 && tag != 0x35) {
        [self cleanUpTryItAnimation];
        [self unlockAssistantIfNeeded];
        [[_cardView selection] removeAllNodes];
        [[self assistant] deactivate];
    }
}

- (void)HSAnimationSetupMainAssistantPane_windowDidResignMain:(id)aResign
{
    [self cleanUpTryItAnimation];
    [self unlockAssistantAndResetTool];
    [self restoreSelectonAfterExit];
    [self setNeedsActiveToolLater:YES];
}

- (void)HSAnimationSetupMainAssistantPane_windowWillClose:(id)aClose
{
    if ([aClose object] != [_cardView window]) {
        return;
    }
    [self unlockAssistantIfNeeded];
    HSToolManager *manager = [HSToolManager sharedToolManager];
    NSInteger tag = [manager selectedToolTag];
    if (tag == 0x35) {
        [[manager currentTool] cancelPathCreationForDrawPathCanvasLayer:nil];
    } else if ((NSUInteger)(tag - 0x31) <= 3 || tag == 0x37 || tag == 0x38) {
        [self resetToolToDefault];
    }
}

- (id)actingObjectForEditPathTool:(id)aTool
{
    return [self object];
}

- (id)actor
{
    return [[self object] queryHyperInterface:@protocol(HSActor)];
}

- (void)addAnimatedObjectToCardForDrawPathTool:(id)aTool
{
    id object = [_animation animatedObject];
    if ([[[self card] children] indexOfObject:object] == NSNotFound) {
        _initialInspectorSupportsSOTSMode = [[HSObjectAssistantController sharedAssistantController] supportsSettingsOnTheSpotMode];
        [[HSObjectAssistantController sharedAssistantController] setSupportsSettingsOnTheSpotMode:NO];
        [self addTemporaryObjectToCard:object];
        [[[object queryHyperInterface:@protocol(HSGeometryAttributes)] attributeObservingController] beginContinuousChangeOfAttributeSet:[NSEProtocolSet protocolSetWithProtocols:@protocol(HSHorizontalOffsetAttribute), @protocol(HSVerticalOffsetAttribute), nil]];
    }
}

- (void)addTemporaryObjectToCard:(id)aObject
{
    id card = [self card];
    [[card undoManager] disableUndoRegistration];
    [card addTemporaryHyperChild:aObject];
    [[card undoManager] enableUndoRegistration];
}

- (void)animationEditModePickTool:(id)aTool pickedObject:(id)aObject event:(id)aEvent
{
    [aTool setDelegate:nil];
    [self setIsMovieAnimation:NO];
    [_cardView setOccupiedByTool:NO];
    id copy = [[aObject localCopyIncludingNodeUnits:YES] autorelease];
    id previous = [[[_animation animatedObject] retain] autorelease];
    if ([aObject hyperParent] != nil && [aObject implementsHyperInterface:@protocol(HSButtonObjectAttributes)]) {
        [copy setInteractiveInAnimation:YES];
    }
    [_animation setAnimatedObject:copy];
    HSObjectAssistantNavigationController *navigation = nil;
    if (_state == 0) {
        navigation = _navigationController;
        id top = [navigation topViewController];
        if ([top isKindOfClass:[HSAnimationSetupCoachingAssistantPane class]]) {
            [_navigationController changeIdentifierForViewController:top toIdentifier:@"identifierForViewControllerToRemove"];
        }
    }
    [self didSetAnimatedObject];
    [navigation removeAllViewControllersWithIdentifier:@"identifierForViewControllerToRemove"];
    if (previous != nil) {
        [self replaceAnimatedObject:previous with:copy undoRegistrationOnly:YES];
    }
}

- (void)animationEditPathHelpPaneDidDone:(id)aPane contextInfo:(void *)aInfo
{
    [_cardView setOccupiedByTool:NO];
    if (_state == 1) {
        [self pushAnimationViewController:self withIdentifier:HSAnimationModePane];
    } else {
        [_navigationController popAllTopViewControllersWithIdentifier:HSAnimationModeTempPane animate:YES];
    }
}

- (id)animationForDrawPathTool:(id)aTool
{
    return _animation;
}

- (id)animationForEditPathTool:(id)aTool
{
    return [self animation];
}

- (void)animationPlaybackDidEnd:(id)aEnd
{
    [_cardView setOccupiedByTool:NO];
    [self runEditPath];
    [_tryItAnimation prepareAnimation];
    [self updateUI:YES];
    [[HSObjectAssistantController sharedAssistantController] setSupportsSettingsOnTheSpotMode:_initialInspectorSupportsSOTSMode];
}

- (void)animationPlaybackDirectionDidChange:(id)aChange
{
    [self recreateTryItAnimationOnAnimationOptionsChange];
}

- (void)applyChangesIfNeeded
{
    if ([self hasAssistantPaneUnappliedChanges]) {
        [[[self document] undoManager] disableUndoRegistration];
        [self cleanUpAnimation:YES];
        [[[self document] undoManager] enableUndoRegistration];
    }
}

- (void)applyPathAndKeyFramesChanges
{
    [self replacePath:_storedPath keyFrames:_storedKeyFrames withPath:[[[[self animation] path] copy] autorelease] keyFrames:[[[[self animation] pathKeyFrames] copy] autorelease] undoRegistrationOnly:YES];
}

- (id)assistantPaneUndoManager
{
    switch (_state) {
    case 0:
        return [[self document] undoManager];
    case 2:
        return [self undoManager];
    case 1:
    case 3:
    case 4:
        return [self dummyUndoManager];
    default:
        return nil;
    }
}

- (void)cancelFromPickImageTool
{
    [self resetToolToDefault];
    [self unlockAssistantIfNeeded];
    [_cardView setOccupiedByTool:NO];
    [_navigationController popViewControllerAnimated:YES];
}

- (void)cancelFromPickObjectTool:(id)aTool
{
    [aTool setDelegate:nil];
    [self cancelFromPickImageTool];
}

- (id)card
{
    return [_cardView card];
}

- (id)cardViewForPickImageAssistantPane:(id)aPane
{
    return _cardView;
}

- (id)cardViewForPickPartOfCardAssistantPane:(id)aPane
{
    return _cardView;
}

- (void)editingFinishedForTransparentAssistantPane:(id)aPane apply:(BOOL)aApply
{
    if (aApply) {
        [[self undoManager] setMultipleActionsName:[[NSBundle mainBundle] localizedStringForKey:@"Change Options" value:@"" table:@"UndoManager"]];
        id copy = [[[_tryItAnimation animatedObject] localCopyIncludingNodeUnits:YES] autorelease];
        [self replaceAnimatedObject:[_animation animatedObject] with:copy undoRegistrationOnly:NO];
    }
    id layer = [_cardView rootCanvasLayer];
    [layer setEnabledSublayerIdentifiers:[layer vectorToolsIdentifiers]];
    [_transparentColorAssistantPane setDelegate:nil];
    [_transparentColorAssistantPane release];
    _transparentColorAssistantPane = nil;
}

- (void)editingWillBeginForEditPathTool:(id)aTool
{
    [self storeCurrentPathAndKeyFrames];
}

- (void)finishAndApplyChanges:(BOOL)aApply
{
    _didFinishAndApply = YES;
    [_tryItAnimation stop];
    [self updateAnimatedObjectFromTryItAnimation];
    [self cleanUpTryItAnimation];
    [_undoHelper finishDuplicating:aApply];
    [_undoHelper release];
    _undoHelper = nil;
    [[self undoManager] removeAllActions];
    [[self dummyUndoManager] removeAllActions];
    [self cleanUpAnimation:aApply];
    [self restoreSelectonAfterExit];
    [_navigationController removeAllViewControllersWithIdentifier:HSAnimationModeTempPane];
    if ([[_navigationController viewControllers] count] == 1) {
        [[_navigationController topViewController] dismissModalViewControllerAnimated:YES];
    } else {
        [_navigationController popAllTopViewControllersWithIdentifier:HSAnimationModePane animate:YES];
    }
    [self resetToolToDefault];
    [self unlockAssistantIfNeeded];
    [self setActionEvents:nil];
}

- (void)checkActionsForAllEventsAreEqual
{
    id actor = [self actor];
    id first = nil;
    for (id event in _actionEvents) {
        id actions = [actor hyperActionsOfType:[HSPlayAnimationAction actionType] forEvent:event];
        if (first != nil) {
            for (NSUInteger i = 0; i < [actions count]; i++) {
            }
        } else {
            first = actions;
        }
    }
}

- (void)cleanUpAnimation:(BOOL)aApply
{
    id actor = [self actor];
    id actions = [actor hyperActionsOfType:[HSPlayAnimationAction actionType] forEvent:[_actionEvents lastObject]];
    NSUInteger count = [actions count];
    if (!aApply) {
        if (count == 1) {
            [[[self document] undoManager] disableUndoRegistration];
            id action = [actions objectAtIndex:0];
            if (_initialAnimation == nil) {
                for (id event in _actionEvents) {
                    [actor removeHyperAction:action forEvent:event];
                }
            } else {
                [action setAnimation:_initialAnimation];
            }
            [[[self document] undoManager] enableUndoRegistration];
        }
        return;
    }
    if (count == 1) {
        if ([_initialAnimation isEqual:_animation]) {
            return;
        }
        [actor replaceHyperAction:[actions objectAtIndex:0] withAction:[self playAnimationAction] forEvents:_actionEvents];
    } else if (count == 0) {
        [actor addHyperAction:[self playAnimationAction] forEvent:[_actionEvents objectAtIndex:0]];
    }
}

- (void)cleanUpTryItAnimation
{
    if (_tryItAnimation == nil) {
        return;
    }
    id object = [_tryItAnimation animatedObject];
    [_tryItAnimation stop];
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self name:HSAnimationPlaybackDidEndNotification object:_tryItAnimation];
    [center removeObserver:self name:HSAnimationAbsoluteLayerDidChangeNotification object:_tryItAnimation];
    [center removeObserver:self name:HSAnimationPlaybackDirectionDidChangeNotification object:_tryItAnimation];
    [object removeObserver:self selector:@selector(tryItAnimatedObjectGeometryChanged:) ofChanges:HSAllAttributeChanges ofAttribute:@protocol(HSGeometryAttribute)];
    if (_isBlockingUndoRegistration) {
        [[object undoManager] enableUndoRegistration];
        _isBlockingUndoRegistration = NO;
    }
    [_tryItAnimation release];
    _tryItAnimation = nil;
    [[[object card] animationController] cleanUpAfterTryIt];
}

- (void)cleanupTemporaryAnimationAssistantPanes
{
    [_navigationController removeAllViewControllersWithIdentifier:HSAnimationModeTempPane];
}

- (void)coachingAssistantGoBackFromPane:(id)aPane
{
    [_cardView setOccupiedByTool:NO];
    [self resetToolToDefault];
    [self unlockAssistantIfNeeded];
    [aPane dismiss:YES];
}

- (void)configureAnimatedObjectAndAnimation
{
    [self disableAnimatedObjectShadow];
    [self updateAnimationPlayMovie];
    [self makeAnimatedObjectButtonBorderless];
}

- (void)createCelAnimationWithOptions:(id)aOptions croppingPath:(CGPathRef)aPath
{
    if (aPath != NULL && !CGPathIsEmpty(aPath)) {
        id bezierPath = [NSBezierPath hyperBezierPathWithCGPath:aPath];
        NSMutableDictionary *options = [aOptions mutableCopy];
        [options setObject:bezierPath forKey:HSPickImageCroppingPathOptionKey];
        aOptions = [options autorelease];
    }
    id movie = [HSAnimationSetupPickImageAssistantPane movieForCelAnimationWithOptions:aOptions];
    if (movie == nil) {
        [self cancelFromPickImageTool];
        return;
    }
    NSValue *transformValue = [aOptions objectForKey:HSPickImageAffineTransformOptionKey];
    if (transformValue != nil) {
        id applier = [[movie queryHyperInterface:@protocol(HSGeometryBehaviorAdapting)] queryGeometryBehaviorApplier];
        if (applier != nil) {
            CGAffineTransform transform = CGAffineTransformIdentity;
            [transformValue getValue:&transform];
            CGFloat scaleX = hypot(transform.a, transform.b);
            CGFloat scaleY = hypot(transform.c, transform.d);
            CGFloat inverseX = scaleX != 0 ? 1 / scaleX : 1;
            CGFloat inverseY = scaleY != 0 ? 1 / scaleY : 1;
            transform.a *= inverseX;
            transform.b *= inverseX;
            transform.c *= inverseY;
            transform.d *= inverseY;
            [applier resizeFrameBy:NSMakeSize(scaleX, scaleY) aboutRelativePoint:NSZeroPoint withLayoutGuidingContext:nil];
            [applier setAffineTransform:transform withLayoutGuidingContext:nil];
        }
    }
    [self animationEditModePickTool:nil pickedObject:movie event:nil];
    [self setIsMovieAnimation:NO];
    if (_state != 0) {
        return;
    }
    [self setState:1];
    [self runDrawPath];
}

- (void)createCelAnimationWithOptions:(id)aOptions croppingPath:(CGPathRef)aPath assistantPane:(id)aPane
{
    [self lockAssistantIfNeeded];
    if (_state == 0) {
        [self setUpAnimation];
    }
    [self createCelAnimationWithOptions:aOptions croppingPath:aPath];
}

- (void)createImageAnimationWithOptions:(id)aOptions image:(id)aImage
{
    id media = [HSNewMedia mediaWithImage:aImage];
    [self createObjectAnimationWithOptions:aOptions object:[HSDocument userObjectWithMedia:media]];
}

- (void)createObjectAnimationWithOptions:(id)aOptions object:(id)aObject
{
    NSValue *transformValue = [aOptions objectForKey:HSPickImageAffineTransformOptionKey];
    if (transformValue != nil) {
        CGAffineTransform transform = CGAffineTransformIdentity;
        [transformValue getValue:&transform];
        id applier = [[aObject queryHyperInterface:@protocol(HSGeometryBehaviorAdapting)] queryGeometryBehaviorApplier];
        if (applier != nil) {
            [applier setAffineTransform:transform withLayoutGuidingContext:nil];
        }
    }
    id previous = [[[_animation animatedObject] retain] autorelease];
    [_animation setAnimatedObject:aObject];
    [self setIsMovieAnimation:NO];
    [self didSetAnimatedObject];
    if (previous != nil) {
        [self replaceAnimatedObject:previous with:aObject undoRegistrationOnly:YES];
    }
}

- (void)cropTemporaryObject:(id)aObject options:(id)aOptions forAssistantPane:(id)aPane shouldProceedWithMode:(NSInteger)aMode
{
    if (_state == 0) {
        [self setUpAnimation];
    }
    [self runCropForTemporaryObject:aObject options:aOptions withMode:aMode temporaryObjectOwner:aPane];
}

- (void)didSetAnimatedObject
{
    [self configureAnimatedObjectAndAnimation];
    [self resetToolToDefault];
    if (_state == 3) {
        [self setUpTryItAnimation];
        [_navigationController popAllTopViewControllersWithIdentifier:HSAnimationModeTempPane animate:YES];
    } else {
        [self setState:1];
        [self runDrawPath];
    }
}

- (void)disableAnimatedObjectShadow
{
    id shadow = [[_animation animatedObject] queryHyperInterface:@protocol(HSMutableShadowAttributes)];
    if (shadow != nil) {
        [[[_animation animatedObject] undoManager] disableUndoRegistration];
        [shadow setHyperShadowEnabled:NO];
        [[[_animation animatedObject] undoManager] enableUndoRegistration];
    }
}

- (id)document
{
    return [[self card] document];
}

- (id)documentForAnimationSetupEditPathAssistantPane:(id)aPane
{
    return [self document];
}

- (id)documentForPickImageAssistantPane:(id)aPane
{
    return [self document];
}

- (void)documentUndoManagerDidRemoveAllActions:(id)aActions
{
}

- (void)documentUndoManagerWillRegisterUndo:(id)aUndo
{
}

- (void)drawPathShouldCancelFromDrawPathAssistantPane:(id)aPane
{
    [[[HSToolManager sharedToolManager] currentTool] cancelPathCreationForDrawPathCanvasLayer:nil];
}

- (void)drawPathShouldFinishFromDrawPathAssistantPane:(id)aPane
{
    [[[HSToolManager sharedToolManager] currentTool] finishPathCreationForDrawPathCanvasLayer:nil];
}

- (void)drawPathTool:(id)aTool setAnimatedObjectPosition:(NSPoint)aPosition
{
    [self setAnimatedObjectPosition:aPosition];
}

- (void)drawingCanceledForDrawPathTool:(id)aTool
{
    [[[HSToolManager sharedToolManager] currentTool] setDelegate:nil];
    if (_state == 1) {
        [self setState:0];
        [self removeAnimatedObjectFromCard];
        [self resetToolToDefault];
        [self restoreSelectonAfterExit];
        [self unlockAssistantIfNeeded];
    }
    [_cardView setOccupiedByTool:NO];
    [_drawPathAssistantPane dismiss:YES];
    [_drawPathAssistantPane setDelegate:nil];
    [_drawPathAssistantPane release];
    _drawPathAssistantPane = nil;
}

- (void)drawingFinishedForDrawPathTool:(id)aTool
{
    [aTool setDelegate:nil];
    [_cardView setOccupiedByTool:NO];
    if (_state == 4) {
        [[self undoManager] setMultipleActionsName:[[NSBundle mainBundle] localizedStringForKey:@"New Path" value:@"" table:@"UndoManager"]];
        [self applyPathAndKeyFramesChanges];
    }
    [_animation setLoopMode:2];
    [self updateAnimationForCurrentPath];
    [self setUpTryItAnimation];
    HSAnimationSetupEditPathAssistantPane *pane = [HSAnimationSetupEditPathAssistantPane paneWithCoachingKey:@"AnimationEditPath"];
    if (![pane needsToShow]) {
        if (_state != 1) {
            [_navigationController popAllTopViewControllersWithIdentifier:HSAnimationModeTempPane animate:YES];
            return;
        }
        [self pushAnimationViewController:self withIdentifier:HSAnimationModePane];
        return;
    }
    [pane setWindowTitle:[self windowTitle]];
    [pane setDidDoneDelegate:self didDoneSelector:@selector(animationEditPathHelpPaneDidDone:contextInfo:) contextInfo:NULL];
    [pane setDelegate:self];
    [pane setShouldDismissWhenDisappeared:NO];
    [pane setShouldDismissOnOkFromSwitcher:NO];
    [self pushAnimationViewController:pane];
}

- (id)dummyUndoManager
{
    if (_dummyUndoManager == nil) {
        _dummyUndoManager = [NSUndoManager new];
        [_dummyUndoManager disableUndoRegistration];
    }
    return _dummyUndoManager;
}

- (void)editingDidEndForEditPathTool:(id)aTool
{
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Edit Path" value:@"" table:@"UndoManager"]];
    [self applyPathAndKeyFramesChanges];
}

- (void)goBackFromAnimationSetupEditPathAssistantPane:(id)aPane
{
    [self cleanUpTryItAnimation];
    id tool = [self selectToolWithTag:0x35];
    [tool setDelegate:self];
    [tool run];
    [_navigationController popViewControllerAnimated:YES slide:YES];
}

- (BOOL)hasAssistantPaneUnappliedChanges
{
    return ![_initialAnimation isEqual:_animation];
}

- (void)lockAssistantIfNeeded
{
    HSObjectAssistantController *controller = [HSObjectAssistantController sharedAssistantController];
    if (![controller isLocked]) {
        [controller setLocked:YES delegate:self];
    }
}

- (void)lockAssistantIfNeededForTransparentColorAssistantPane:(id)aPane
{
    [self lockAssistantIfNeeded];
}

- (id)lockedObjectAssistantController:(id)aController paneHistoryForObject:(id)aObject
{
    switch (_state) {
    case 0:
    case 3:
        [self setPickImageAssistantPane:[[HSAnimationSetupPickImageAssistantPane new] autorelease]];
        return [NSArray arrayWithObject:_pickImageAssistantPane];
    case 1:
    case 4:
        [self recreateDrawPathAssistantPaneWithKey:@"AnimationDrawPath"];
        return [NSArray arrayWithObject:_drawPathAssistantPane];
    case 2:
        return [NSArray arrayWithObject:self];
    default:
        return [NSArray array];
    }
}

- (id)mainWindowForAnimationSetupEditPathAssistantPane:(id)aPane
{
    return [_cardView window];
}

- (void)makeAnimatedObjectButtonBorderless
{
    if ([[_animation animatedObject] queryHyperInterface:@protocol(HSButtonObjectAttributes)] != nil) {
        id border = [[_animation animatedObject] queryHyperInterface:@protocol(HSBorderAttributes)];
        if (border != nil) {
            [[[_animation animatedObject] undoManager] disableUndoRegistration];
            [border setIsBorderless:YES];
            [[[_animation animatedObject] undoManager] enableUndoRegistration];
        }
    }
}

- (BOOL)needObserveStackChangesForPickImageAssistantPane:(id)aPane
{
    return _state == 3;
}

- (BOOL)needObserveStackChangesForPickPartOfCardAssistantPane:(id)aPane
{
    return _state == 3;
}

- (void)pathStateIsUpdatedForDrawPathTool:(id)aTool
{
    [_drawPathAssistantPane setPathCreationCanBeFinished:YES];
}

- (void)pickCardObjectForAssistantPane:(id)aPane temporaryObject:(id)aObject
{
    if (aObject != nil) {
        id card = [self card];
        [[card undoManager] disableUndoRegistration];
        [card removeHyperChild:aObject];
        [[card undoManager] enableUndoRegistration];
        if ([aPane respondsToSelector:@selector(releaseTemporaryObject)]) {
            [aPane releaseTemporaryObject];
        }
    }
    if (_state == 0) {
        [self setUpAnimation];
    }
    [self runPickCardObjectWithAssistant:[aPane assistant]];
}

- (void)pickMovie:(id)aMovie name:(id)aName forPickImageAssistantPane:(id)aPane
{
    QTMovie *source = [aMovie QTMovie];
    QTTime duration = source != nil ? [source duration] : QTZeroTime;
    QTMovie *movie = [[QTMovie alloc] initWithMovie:source timeRange:QTMakeTimeRange(QTZeroTime, duration) error:NULL];
    if (movie != nil) {
        id object = [HSMovieObject new];
        if (object != nil) {
            [object setSupport:[self document]];
            id objectUndoManager = [[object undoManager] retain];
            [objectUndoManager disableUndoRegistration];
            [[self undoManager] disableUndoRegistration];
            [object setHyperMovie:movie name:aName];
            [object setHyperName:aName];
            if (_state == 0) {
                [[HSObjectAssistantController sharedAssistantController] setSelectedInModelObjectAndBringAssistantToFront:[self object]];
                [[HSObjectAssistantController sharedAssistantController] setActive:YES explicitlyByUser:NO];
                [self lockAssistantIfNeeded];
                [self setUpAnimation];
                [_animation setAnimatedObject:object];
                [self configureAnimatedObjectAndAnimation];
            }
            [self animationEditModePickTool:nil pickedObject:object event:nil];
            id path = [[[aMovie queryHyperInterface:@protocol(HSMediaAttributes)] media] fullPathToMediaFileCreateIfNeeded:YES];
            BOOL isMovieAnimation = NO;
            if (![HSLibraryContentHelper shouldFileBeCreatedAsAnimationAtPath:path]) {
                isMovieAnimation = ![aMovie isAnimatedGifMovie];
            }
            [object setMedia:nil];
            [object setSupport:nil];
            [object release];
            [self setIsMovieAnimation:isMovieAnimation];
            [objectUndoManager enableUndoRegistration];
            [[self undoManager] enableUndoRegistration];
            [objectUndoManager release];
        }
        [movie release];
    }
}

- (id)playAnimationAction
{
    id action = [[[self actor] createActionOfType:[HSPlayAnimationAction actionType] forEvent:[_actionEvents extraFirstObject]] autorelease];
    [action setEvents:_actionEvents];
    [action setAnimation:_animation];
    return action;
}

- (id)prepareToCroppingForAssistantPane:(id)aPane image:(id)aImage options:(id)aOptions
{
    id object = [HSDocument userObjectWithMedia:[HSNewMedia mediaWithImage:aImage]];
    if (object != nil) {
        [[object undoManager] disableUndoRegistration];
        id shadow = [object queryHyperInterface:@protocol(HSMutableShadowAttributes)];
        if (shadow != nil) {
            [shadow setHyperShadowEnabled:NO];
        }
        [[object undoManager] enableUndoRegistration];
        [self lockAssistantIfNeeded];
        [self addTemporaryObjectToCard:object];
        [[object undoManager] disableUndoRegistration];
        id applier = [[object queryHyperInterface:@protocol(HSGeometryBehaviorAdapting)] queryGeometryBehaviorApplier];
        if (applier != nil) {
            NSValue *transformValue = [aOptions objectForKey:HSPickImageAffineTransformOptionKey];
            if (transformValue != nil) {
                CGAffineTransform transform = CGAffineTransformIdentity;
                [transformValue getValue:&transform];
                CGFloat scaleX = hypot(transform.a, transform.b);
                CGFloat scaleY = hypot(transform.c, transform.d);
                CGFloat inverseX = scaleX != 0 ? 1 / scaleX : 1;
                CGFloat inverseY = scaleY != 0 ? 1 / scaleY : 1;
                transform.a *= inverseX;
                transform.b *= inverseX;
                transform.c *= inverseY;
                transform.d *= inverseY;
                [applier resizeFrameBy:NSMakeSize(scaleX, scaleY) aboutRelativePoint:NSZeroPoint withLayoutGuidingContext:nil];
                [applier setAffineTransform:transform withLayoutGuidingContext:nil];
            }
            NSSize size = [[[self document] stack] hyperCardSize];
            [applier moveCenterTo:NSMakePoint(size.width * 0.5, size.height * 0.5) withLayoutGuidingContext:nil];
        }
        [[object undoManager] enableUndoRegistration];
    }
    return object;
}

- (void)prepareToolAndCardViewAfterSwitchForAnimationSetupCoachingAssistantPane:(id)aPane
{
    [self unlockAssistantIfNeeded];
    [self resetToolToDefault];
    [self restoreSelectonAfterExit];
}

- (void)prepareToolAndCardViewAfterSwitchForDrawPathAssistantPane:(id)aPane
{
    [self unlockAssistantIfNeeded];
    [self resetToolToDefault];
    [self restoreSelectonAfterExit];
    [self setNeedsActiveToolLater:YES];
}

- (void)prepareToolAndCardViewForAnimationSetupCoachingAssistantPane:(id)aPane
{
    [self lockAssistantIfNeeded];
    [_cardView setOccupiedByTool:YES];
    id tool = [self selectToolWithTag:0x31];
    [tool setDelegate:self];
}

- (void)prepareToolAndCardViewForAnimationSetupEditPathAssistantPane:(id)aPane
{
    [self lockAssistantIfNeeded];
    if (_tryItAnimation == nil) {
        [self setUpTryItAnimation];
    }
    [self runEditPath];
    [_cardView setOccupiedByTool:YES];
}

- (void)prepareToolAndCardViewForDrawPathAssistantPane:(id)aPane
{
    if ([[HSToolManager sharedToolManager] selectedToolTag] != 0x35) {
        [self lockAssistantIfNeeded];
        id tool = [self selectToolWithTag:0x35];
        [tool setDelegate:self];
        [tool run];
    }
}

- (void)prepareTryItAnimationForTransparentColorAssistantPane:(id)aPane
{
    if (_tryItAnimation == nil) {
        [self setUpTryItAnimation];
    }
}

- (void)pushAnimationViewController:(id)aController
{
    [self pushAnimationViewController:aController withIdentifier:HSAnimationModeTempPane];
}

- (void)pushAnimationViewController:(id)aController withIdentifier:(id)aIdentifier
{
    [_navigationController pushViewController:aController withIdentifier:aIdentifier animate:YES replacePrevious:NO];
}

- (void)recreateDrawPathAssistantPaneWithKey:(id)aKey
{
    [_drawPathAssistantPane setDelegate:nil];
    [_drawPathAssistantPane release];
    _drawPathAssistantPane = [[HSAnimationSetupDrawPathAssistantPane alloc] initWithCoachingKey:aKey];
    if ([aKey isEqualToString:@"AnimationDrawSegmentedPath"]) {
        [_drawPathAssistantPane setupUIForSegmentedPathCreationMode];
    } else {
        [_drawPathAssistantPane setupUIForNonSegmentedPathCreationMode];
    }
    [_drawPathAssistantPane setDelegate:self];
    [_drawPathAssistantPane setWindowTitle:[self windowTitle]];
}

- (void)recreateTryItAnimationOnAnimationOptionsChange
{
    [self updateAnimatedObjectFromTryItAnimation];
    [self setUpTryItAnimation];
}

- (void)refreshWindowTitle
{
    id attributes = [[self object] queryHyperInterface:@protocol(HSObjectAttributes)];
    if (attributes != nil) {
        [self setWindowTitle:[NSString stringWithFormat:@"%@ : %@", [attributes hyperName], [HSPlayAnimationAction localizedNameInInspector]]];
    } else {
        [self setWindowTitle:[HSPlayAnimationAction localizedNameInInspector]];
    }
}

- (void)registerUndoGeometryChangesOfAnimatedObject:(id)aObject withActionName:(id)aName
{
    if (aName != nil) {
        [[self undoManager] setActionName:aName];
    }
    id geometry = [aObject queryHyperInterface:@protocol(HSGeometryAttributes)];
    [[[self undoManager] prepareWithInvocationTarget:self] useAnimatedObjectSize:[geometry size] affineTransform:[geometry affineTransform] actionName:aName];
    [_undoHelper duplicateAction];
}

- (void)releaseTryItAnimationForTransparentColorAssistantPane:(id)aPane
{
    [self cleanUpTryItAnimation];
}

- (void)removeAnimatedObjectFromCard
{
    id object = [_animation animatedObject];
    [[[self card] undoManager] disableUndoRegistration];
    [[self card] removeHyperChild:object];
    [[[self card] undoManager] enableUndoRegistration];
    [_cardView setNeedsDisplay:YES];
}

- (void)removeAnimatedObjectFromCardForDrawPathTool:(id)aTool
{
    [[[_animation animatedObject] queryHyperInterface:@protocol(HSGeometryAttributes)] attributeObservingController];
    [[[[_animation animatedObject] queryHyperInterface:@protocol(HSGeometryAttributes)] attributeObservingController] endContinuousChangeOfAttributeSet:[NSEProtocolSet protocolSetWithProtocols:@protocol(HSHorizontalOffsetAttribute), @protocol(HSVerticalOffsetAttribute), nil]];
    [self removeAnimatedObjectFromCard];
    [[HSObjectAssistantController sharedAssistantController] setSupportsSettingsOnTheSpotMode:_initialInspectorSupportsSOTSMode];
}

- (void)replaceAnimatedObject:(id)aObject with:(id)aWith undoRegistrationOnly:(BOOL)aOnly
{
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change Animated Object" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] replaceAnimatedObject:aWith with:aObject undoRegistrationOnly:NO];
    [_undoHelper duplicateAction];
    if (!aOnly) {
        [_tryItAnimation stop];
        [_animation setAnimatedObject:aWith];
        double pathTime = [_tryItAnimation pathTime];
        [self setUpTryItAnimation];
        [_tryItAnimation setPathTime:pathTime];
        [self updateAnimationPlayMovie];
        [self updateUI:YES];
    }
}

- (void)replacePath:(id)aPath keyFrames:(id)aKeyFrames withPath:(id)aWithPath keyFrames:(id)aWithKeyFrames undoRegistrationOnly:(BOOL)aOnly
{
    [[[self undoManager] prepareWithInvocationTarget:self] replacePath:aWithPath keyFrames:aWithKeyFrames withPath:aPath keyFrames:aKeyFrames undoRegistrationOnly:NO];
    [_undoHelper duplicateAction];
    if (!aOnly) {
        [_tryItAnimation stop];
        [_animation setPath:aWithPath keyFrames:aWithKeyFrames];
        [_tryItAnimation setPath:aWithPath keyFrames:aWithKeyFrames];
        HSAnimationFixation *fixation = [HSAnimationFixation new];
        [fixation setObjectPositionAtZeroTime:[_tryItAnimation pathPointAtTime:0]];
        [[_tryItAnimation positioning] replaceFixationWith:fixation];
        [fixation release];
        double pathTime = [_tryItAnimation pathTime];
        double time = 0;
        if (pathTime >= 0) {
            time = pathTime;
            if ([_tryItAnimation duration] < pathTime) {
                time = [_tryItAnimation duration];
            }
        }
        if ([[HSToolManager sharedToolManager] selectedToolTag] == 0x37) {
            [[[HSToolManager sharedToolManager] currentTool] updatePath];
        }
        [_tryItAnimation setPathTime:time];
    }
    [self updateUI:YES];
}

- (void)resetToolToDefault
{
    [self selectToolWithTag:0];
}

- (void)restoreSelectonAfterExit
{
    id object = [self object];
    [_cardView ignoreNextMouseDown];
    id target = _cardView;
    if ([[object queryHyperInterface:@protocol(HSUserObjectSupport)] card] == object) {
        [_cardView selectObjects:nil];
        target = [[[self document] selectionController] stackController];
    }
    [target selectObject:object];
}

- (void)runCropForTemporaryObject:(id)aObject options:(id)aOptions withMode:(NSInteger)aMode temporaryObjectOwner:(id)aOwner
{
    if (aMode == 3) {
        [aObject retain];
        id card = [self card];
        [[card undoManager] disableUndoRegistration];
        [card removeHyperChild:aObject];
        [[card undoManager] enableUndoRegistration];
        NSUInteger type = [[aOptions objectForKey:HSPickImageGraphicTypeOptionKey] unsignedLongValue];
        if (type == HSGraphicTypeCELMovie) {
            [self createCelAnimationWithOptions:aOptions croppingPath:NULL];
        } else {
            [self createObjectAnimationWithOptions:nil object:aObject];
        }
        if ([aOwner respondsToSelector:@selector(releaseTemporaryObject)]) {
            [aOwner releaseTemporaryObject];
        }
        [aObject release];
        return;
    }
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    NSInteger tag = 0;
    if (aMode == 2) {
        tag = 0x34;
    } else if (aMode == 1) {
        tag = 0x33;
    } else if (aMode == 0) {
        tag = 0x32;
    }
    id tool = [self selectToolWithTag:tag];
    [tool setWorkObject:[aObject queryHyperInterface:@protocol(HSImageObjectAttributes)]];
    [tool setUserInfo:[[NSDictionary alloc] initWithObjectsAndKeys:aOptions, HSUserInfoOptions, aOwner, HSUserInfoTemporaryObjectOwner, nil]];
    id pane = [HSSelectImagePartPane paneWithCoachingKey:[tool toolIdentifier]];
    [pane setWindowTitle:[self windowTitle]];
    [pane setDelegate:self];
    [pane setShouldLeavePaneOnToolChange:NO];
    [pane setShouldDismissWhenDisappeared:NO];
    [tool setDelegate:pane];
    [self pushAnimationViewController:pane];
    [_cardView setOccupiedByTool:YES];
    [pool release];
}

- (void)runDrawPath
{
    if (_state == 4) {
        [self storeCurrentPathAndKeyFrames];
    }
    [_cardView setOccupiedByTool:YES];
    id tool = [self selectToolWithTag:0x35];
    [tool setDelegate:self];
    [tool run];
    [self recreateDrawPathAssistantPaneWithKey:[tool pathCreationMode] == 1 ? @"AnimationDrawSegmentedPath" : @"AnimationDrawPath"];
    [self pushAnimationViewController:_drawPathAssistantPane];
}

- (void)runEditPath
{
    id tool = [self selectToolWithTag:0x37];
    [tool setDelegate:self];
    [tool run];
}

- (void)runEditPathIfNeededForPickImageAssistantPane:(id)aPane
{
    if (_state == 3) {
        [self lockAssistantIfNeeded];
        [self runEditPath];
        [self unlockAssistantIfNeeded];
    }
}

- (void)runEditPathIfNeededForPickPartOfCardAssistantPane:(id)aPane
{
    if (_state == 3) {
        [self lockAssistantIfNeeded];
        [self runEditPath];
        [self unlockAssistantIfNeeded];
    }
}

- (void)runPickCardObjectWithAssistant:(id)aAssistant
{
    [self lockAssistantIfNeeded];
    [_cardView setOccupiedByTool:YES];
    id tool = [self selectToolWithTag:0x31];
    [tool setDelegate:self];
    id pane = [HSAnimationSetupCoachingAssistantPane paneWithCoachingKey:[tool toolIdentifier]];
    [pane setWindowTitle:[self windowTitle]];
    [pane setDelegate:self];
    [self pushAnimationViewController:pane];
}

- (void)runPickImage
{
    [self setPickImageAssistantPane:[[HSAnimationSetupPickImageAssistantPane new] autorelease]];
    [self pushAnimationViewController:_pickImageAssistantPane];
    [self lockAssistantIfNeeded];
}

- (void)runWithImage:(id)aImage options:(id)aOptions fromPane:(id)aPane
{
    id media = nil;
    id path = [aOptions objectForKey:HSPickImageSourcePathKey];
    if (path != nil) {
        media = [HSNewMedia mediaWithPath:path];
    }
    if (media == nil) {
        media = [HSNewMedia mediaWithImage:aImage];
    }
    id object = [HSDocument userObjectWithMedia:media];
    id clipPaths = [aOptions objectForKey:HSPickImageClipPathsOptionKey];
    if (clipPaths != nil) {
        [[HSImageCropApplier cropApplierForImageObject:object] cropImageObjectWithPaths:clipPaths modifyObjectGeometry:YES];
    }
    [self lockAssistantIfNeeded];
    if (_state == 0) {
        [self setUpAnimation];
    }
    [object retain];
    if ([[aOptions objectForKey:HSPickImageGraphicTypeOptionKey] unsignedLongValue] == HSGraphicTypeCELMovie) {
        [self createCelAnimationWithOptions:aOptions croppingPath:NULL];
    } else {
        id transform = [aOptions objectForKey:HSPickImageAffineTransformOptionKey];
        NSDictionary *options = nil;
        if (transform != nil) {
            options = [NSDictionary dictionaryWithObject:transform forKey:HSPickImageAffineTransformOptionKey];
        }
        [self createObjectAnimationWithOptions:options object:object];
    }
    [object release];
}

- (void)selectImagePartPaneCancel:(id)aPane
{
    [_cardView setOccupiedByTool:NO];
    id tool = [[HSToolManager sharedToolManager] currentTool];
    [tool setDelegate:nil];
    id userInfo = [tool userInfo];
    [tool setUserInfo:nil];
    id owner = [userInfo objectForKey:HSUserInfoTemporaryObjectOwner];
    id temporary = [owner respondsToSelector:@selector(temporaryObject)] ? [owner temporaryObject] : [[tool workObject] hyperObject];
    if (temporary != nil) {
        [tool setWorkObject:nil];
        id card = [self card];
        [[card undoManager] disableUndoRegistration];
        [card removeHyperChild:temporary];
        [[card undoManager] enableUndoRegistration];
        if ([owner respondsToSelector:@selector(releaseTemporaryObject)]) {
            [owner releaseTemporaryObject];
        }
    }
    [userInfo release];
    if (_state == 0) {
        [self unlockAssistantIfNeeded];
        [self resetToolToDefault];
    }
    [_navigationController popViewControllerAnimated:YES];
}

- (void)selectImagePartPaneCrop:(id)aPane
{
    [_cardView setOccupiedByTool:NO];
    id tool = [[HSToolManager sharedToolManager] currentTool];
    [tool setDelegate:nil];
    CGRect objectBounds = CGRectZero;
    CGRect pathBounds = CGRectZero;
    CGPathRef path = [tool copiedCGPath];
    id workObject = [[tool workObject] queryHyperInterface:@protocol(HSGeometryAttributes)];
    if (workObject != nil && path != NULL) {
        objectBounds = NSRectToCGRect([workObject boundingRect]);
        if (!CGPathIsEmpty(path)) {
            pathBounds = CGPathGetPathBoundingBox(path);
        }
        if (CGRectIsEmpty(CGRectIntersection(pathBounds, objectBounds))) {
            pathBounds = CGRectZero;
        }
    }
    if (CGRectIsEmpty(pathBounds)) {
        if (path != NULL) {
            CGPathRelease(path);
        }
        [self selectImagePartPaneCancel:aPane];
        return;
    }
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    id userInfo = [tool userInfo];
    [tool setUserInfo:nil];
    [workObject retain];
    [self resetToolToDefault];
    id object = [workObject hyperObject];
    if (object != nil) {
        [tool setWorkObject:nil];
        [object retain];
        id card = [self card];
        [[card undoManager] disableUndoRegistration];
        [card removeHyperChild:object];
        [[card undoManager] enableUndoRegistration];
        id owner = [userInfo objectForKey:HSUserInfoTemporaryObjectOwner];
        if ([owner respondsToSelector:@selector(releaseTemporaryObject)]) {
            [owner releaseTemporaryObject];
        }
        [object autorelease];
    }
    id imageAttributes = [object queryHyperInterface:@protocol(HSImageAttributes)];
    if (imageAttributes != nil) {
        NSSize imageSize = [[imageAttributes image] size];
        CGRect imageRect = CGRectMake(0, 0, imageSize.width, imageSize.height);
        if (!CGRectIsEmpty(imageRect)) {
            CGFloat scaleX = 1;
            CGFloat scaleY = 1;
            if (objectBounds.size.width != 0) {
                scaleX = imageSize.width / objectBounds.size.width;
            }
            if (objectBounds.size.height != 0) {
                scaleY = imageSize.height / objectBounds.size.height;
            }
            CGAffineTransform scale = CGAffineTransformMake(scaleX, 0, 0, scaleY, -objectBounds.origin.x * scaleX, -objectBounds.origin.y * scaleY);
            CGAffineTransform flip = CGAffineTransformMake(1, 0, 0, -1, 0, imageSize.height);
            CGAffineTransform transform = CGAffineTransformConcat(scale, flip);
            CGMutablePathRef flipped = CGPathCreateMutable();
            if (flipped != NULL) {
                CGPathAddPath(flipped, &transform, path);
                CGPathRelease(path);
                pathBounds = CGPathGetPathBoundingBox(flipped);
                path = flipped;
            }
        }
        id options = [userInfo objectForKey:HSUserInfoOptions];
        HSObjectAssistantNavigationController *navigation = nil;
        if (_state == 0) {
            navigation = _navigationController;
            [navigation changeIdentifierForViewController:aPane toIdentifier:@"identifierForViewControllerToRemove"];
        }
        if ([[options objectForKey:HSPickImageGraphicTypeOptionKey] unsignedLongValue] == HSGraphicTypeImage) {
            CGRect crop = CGRectIntersection(CGRectIntegral(pathBounds), imageRect);
            NSImage *cropped = nil;
            NSImage *image = nil;
            if (!CGRectIsEmpty(crop)) {
                cropped = [[NSImage alloc] initWithSize:NSMakeSize(crop.size.width, crop.size.height)];
            }
            if (cropped != nil) {
                NSImage *source = [[[imageAttributes image] copy] autorelease];
                [source setFlipped:NO];
                [cropped lockFocus];
                CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];
                CGContextConcatCTM(context, CGAffineTransformMakeTranslation(-crop.origin.x, -crop.origin.y));
                CGContextBeginPath(context);
                CGContextAddPath(context, path);
                CGContextClip(context);
                [source drawInRect:NSRectFromCGRect(crop) fromRect:NSRectFromCGRect(crop) operation:NSCompositeSourceOver fraction:1];
                [cropped unlockFocus];
                image = cropped;
            } else {
                image = [imageAttributes image];
            }
            [self createImageAnimationWithOptions:options image:image];
            [cropped release];
        } else {
            [self createCelAnimationWithOptions:options croppingPath:path];
        }
        [navigation removeAllViewControllersWithIdentifier:@"identifierForViewControllerToRemove"];
    }
    CGPathRelease(path);
    [workObject release];
    [userInfo release];
    [pool release];
}

- (id)selectToolWithTag:(NSInteger)aTag
{
    [[HSToolManager sharedToolManager] selectToolWithTag:aTag setAsPermanent:YES forceSelection:YES];
    return [[HSToolManager sharedToolManager] currentTool];
}

- (CGFloat)selectionToolTolerance
{
    id setting = [[[HSToolManager sharedToolManager] toolSettings] settingForIdentifier:HSLassoSelectionToolIdentifier andKey:HSLassoToolToleranceKey];
    if (setting == nil) {
        return 0;
    }
    return [setting floatValue];
}

- (void)setActionEvents:(id)aEvents
{
    if (![_actionEvents isEqualToArray:aEvents]) {
        [_actionEvents release];
        _actionEvents = [aEvents copy];
    }
}

- (void)setAnimatedObjectPosition:(NSPoint)aPosition
{
    id object = [_animation animatedObject];
    [[object undoManager] disableUndoRegistration];
    [HSAnimationPositioning setPosition:aPosition ofObject:object];
    [[object undoManager] enableUndoRegistration];
}

- (void)setCardView:(id)aCardView
{
    if (_cardView != aCardView) {
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center removeObserver:self name:NSWindowWillCloseNotification object:[_cardView window]];
        [aCardView retain];
        [_cardView release];
        _cardView = aCardView;
        if (_cardView != nil) {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(HSAnimationSetupMainAssistantPane_windowWillClose:) name:NSWindowWillCloseNotification object:[_cardView window]];
            [_undoHelper finishDuplicating:NO];
            [_undoHelper release];
            _undoHelper = [[HSEditModeUndoHelper alloc] initWithDocument:[self document] documentUndoManager:[[self document] undoManager] editModeUndoManager:[self undoManager] delegate:self];
        }
    }
}

- (void)setNavigationController:(id)aController
{
    [_navigationController release];
    _navigationController = [aController retain];
}

- (void)setNeedsActiveToolLater:(BOOL)aLater
{
    [[HSObjectAssistantController sharedAssistantController] setSelectedInModelObject:nil];
    id object = [self object];
    id windowController = [[self document] currentWindowController];
    if ([windowController respondsToSelector:@selector(setSelectedObjectForAssistantRefresh:)]) {
        [windowController setSelectedObjectForAssistantRefresh:object];
    }
}

- (void)setObject:(id)aObject
{
    if ([self object] == aObject) {
        return;
    }
    id observing = [[[self object] queryHyperInterface:@protocol(HSAttributes)] attributeObservingController];
    if (observing != nil) {
        [observing removeObserver:self selector:@selector(HSAnimationSetupMainAssistantPane_nameAttributesDidChange:) ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSObjectNameAttribute)];
    }
    [super setObject:aObject];
    observing = [[aObject queryHyperInterface:@protocol(HSAttributes)] attributeObservingController];
    if (observing != nil) {
        [observing addObserver:self selector:@selector(HSAnimationSetupMainAssistantPane_nameAttributesDidChange:) ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSObjectNameAttribute) withPriority:-0.25];
    }
    [self refreshWindowTitle];
}

- (void)setPickImageAssistantPane:(id)aPane
{
    [_pickImageAssistantPane setDelegate:nil];
    [_pickImageAssistantPane release];
    _pickImageAssistantPane = [aPane retain];
    [_pickImageAssistantPane setDelegate:self];
    [_pickImageAssistantPane setTolerance:[self selectionToolTolerance]];
}

- (void)setPlayForItemWithTag:(NSInteger)aTag
{
    [_playForPopUpButton selectItemWithTag:aTag];
    [_playForPopUpButton setToolTip:[[_playForPopUpButton selectedItem] toolTip]];
    [_playForValueTextField setToolTip:[[_playForPopUpButton selectedItem] toolTip]];
}

- (void)setState:(NSInteger)aState
{
    _state = (int)aState;
}

- (void)setUpAnimation
{
    [self checkActionsForAllEventsAreEqual];
    id actions = [[self actor] hyperActionsOfType:[HSPlayAnimationAction actionType] forEvent:[_actionEvents lastObject]];
    [_initialAnimation release];
    [_animation release];
    _initialAnimation = nil;
    _animation = nil;
    if ([actions count] == 0) {
        _animation = [HSAnimation new];
    } else if ([actions count] == 1) {
        _initialAnimation = [[[actions objectAtIndex:0] animation] copy];
        _animation = [_initialAnimation copy];
    }
}

- (void)setUpTryItAnimation
{
    if ([_animation animatedObject] == nil) {
        return;
    }
    [self cleanUpTryItAnimation];
    [[[self card] animationController] prepareForTryItAnimation:_animation];
    _tryItAnimation = [[[[self card] animationController] prepareToStartAnimation:_animation forActingObject:[self object]] retain];
    [_tryItAnimation setSuppressDontErase:YES];
    [_tryItAnimation prepareAnimation];
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(animationPlaybackDidEnd:) name:HSAnimationPlaybackDidEndNotification object:_tryItAnimation];
    [center addObserver:self selector:@selector(HSAnimationSetupMainAssistantPane_animationAbsoluteLayerDidChange:) name:HSAnimationAbsoluteLayerDidChangeNotification object:_tryItAnimation];
    [center addObserver:self selector:@selector(animationPlaybackDirectionDidChange:) name:HSAnimationPlaybackDirectionDidChangeNotification object:_tryItAnimation];
    id object = [_tryItAnimation animatedObject];
    [_cardView selectHyperObject:object];
    [object addObserver:self selector:@selector(tryItAnimatedObjectGeometryChanged:) ofChanges:HSAllAttributeChanges ofAttribute:@protocol(HSGeometryAttribute) withPriority:-0.25];
}

- (void)storeCurrentPathAndKeyFrames
{
    [_storedPath release];
    [_storedKeyFrames release];
    _storedPath = [[[self animation] path] copy];
    _storedKeyFrames = [[[self animation] pathKeyFrames] copy];
}

- (void)tryItAnimatedObjectGeometryChanged:(id)aChange
{
    NSUInteger change = [aChange attributeChange];
    if (change == 0x40) {
        NSString *name = [[NSBundle mainBundle] localizedStringForKey:[[aChange attributeProtocolSet] containsProtocol:@protocol(HSRotationAngleAttribute)] ? @"Rotation" : @"Resize" value:@"" table:@"UndoManager"];
        [self registerUndoGeometryChangesOfAnimatedObject:[_tryItAnimation animatedObject] withActionName:name];
    } else if (change == 0x80) {
        [_tryItAnimation updateObject];
    } else if ((HSActualWillAttributeChanges & change) != 0) {
        if (!_isBlockingUndoRegistration) {
            [[[_tryItAnimation animatedObject] undoManager] disableUndoRegistration];
            _isBlockingUndoRegistration = YES;
        }
    } else if ((HSActualDidAttributeChanges & change) != 0 && _isBlockingUndoRegistration) {
        [[[_tryItAnimation animatedObject] undoManager] enableUndoRegistration];
        _isBlockingUndoRegistration = NO;
    }
}

- (id)tryItAnimationForEditPathTool:(id)aTool
{
    return [self tryItAnimation];
}

- (id)tryItAnimationForTransparentColorAssistantPane:(id)aPane
{
    return _tryItAnimation;
}

- (id)undoManagerForAnimationSetupCoachingAssistantPane:(id)aPane
{
    return [self dummyUndoManager];
}

- (id)undoManagerForAnimationSetupEditPathAssistantPane:(id)aPane
{
    return [self undoManager];
}

- (id)undoManagerForDrawPathAssistantPane:(id)aPane
{
    return [self undoManager];
}

- (id)undoManagerForImagePartPane:(id)aPane
{
    return [self dummyUndoManager];
}

- (id)undoManagerForPickImageAssistantPane:(id)aPane
{
    return [self assistantPaneUndoManager];
}

- (id)undoManagerForPickPartOfCardAssistantPane:(id)aPane
{
    return [self dummyUndoManager];
}

- (id)undoManagerForTransparentColorAssistantPane:(id)aPane
{
    return [self dummyUndoManager];
}

- (void)unlockAssistantAndResetTool
{
    [self unlockAssistantIfNeeded];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"HSActiveToolDidSelectionNotification" object:[HSToolManager sharedToolManager]];
    [self resetToolToDefault];
}

- (void)unlockAssistantIfNeeded
{
    HSObjectAssistantController *controller = [HSObjectAssistantController sharedAssistantController];
    if ([controller isLocked]) {
        [controller setLocked:NO delegate:nil];
    }
}

- (void)unlockAssistantIfNeededAndClose:(BOOL)aClose removeTryItAnimation:(BOOL)aRemove forTransparentColorAssistantPane:(id)aPane
{
    if (_tryItAnimation != nil) {
        [[self undoManager] setMultipleActionsName:[[NSBundle mainBundle] localizedStringForKey:@"Change Options" value:@"" table:@"UndoManager"]];
        id copy = [[_tryItAnimation animatedObject] localCopyIncludingNodeUnits:YES];
        [_animation setAnimatedObject:copy];
        [copy release];
        if (aRemove) {
            [self cleanUpTryItAnimation];
        }
    }
    [self unlockAssistantIfNeeded];
    if (aClose) {
        [self restoreSelectonAfterExit];
    }
}

- (void)unprepareCroppingForAssistantPane:(id)aPane temporaryObject:(id)aObject
{
    [self unprepareCroppingForTemporaryObject:aObject];
    if ([aPane respondsToSelector:@selector(releaseTemporaryObject)]) {
        [aPane releaseTemporaryObject];
    }
}

- (void)unprepareCroppingForTemporaryObject:(id)aObject
{
    if (aObject != nil) {
        id card = [self card];
        [[card undoManager] disableUndoRegistration];
        [card removeHyperChild:aObject];
        [[card undoManager] enableUndoRegistration];
    }
    if (_state == 0) {
        [self resetToolToDefault];
    }
}

- (void)unprepareToolAndCardViewForAnimationSetupEditPathAssistantPane:(id)aPane
{
    [self cleanUpTryItAnimation];
    [self resetToolToDefault];
    [_cardView setOccupiedByTool:NO];
    [self unlockAssistantIfNeeded];
    [self restoreSelectonAfterExit];
    [self setNeedsActiveToolLater:YES];
}

- (void)updateAnimatedObjectFromTryItAnimation
{
    id copy = [[[_tryItAnimation animatedObject] localCopyIncludingNodeUnits:YES] autorelease];
    [copy setDraggable:NO];
    [copy setResizable:NO];
    [copy setRotatable:NO];
    [_animation setAnimatedObject:copy];
}

- (void)updateAnimationForCurrentPath
{
    if ([_animation hasPath] && [_animation isOnePointPathAnimation]) {
        [_animation setLoopMode:1];
    }
}

- (void)updateAnimationPathBounds:(NSRect)aBounds forEditPathTool:(id)aTool
{
    [_cardView setAdditionalContentBoundingRect:aBounds];
}

- (void)updateAnimationPlayMovie
{
    id support = [[_animation animatedObject] support];
    [[_animation animatedObject] setSupport:[self document]];
    id framesPerSecond = [[_animation animatedObject] queryHyperInterface:@protocol(HSFramesPerSecondAttributes)];
    if (framesPerSecond == nil) {
        [_animation setPlayMovie:NO];
        [_animation setMovieSpeed:[HSAnimationOptions undefinedMovieSpeed]];
        if ([_animation loopMode] == 4) {
            [_animation setLoopMode:2];
        }
        [self updateAnimationForCurrentPath];
    } else {
        [_animation setPlayMovie:YES];
        if (![_animation wasMovieSpeedSet]) {
            [_animation setMovieSpeed:[framesPerSecond hyperFramesPerSecond]];
        }
    }
    [[_animation animatedObject] setSupport:support];
}

- (void)updatePathInEditPathTool
{
    if ([[HSToolManager sharedToolManager] selectedToolTag] == 0x37) {
        [[[HSToolManager sharedToolManager] currentTool] updatePath];
    }
}

- (void)updateUI:(BOOL)aUpdate
{
    BOOL play = NO;
    if (_state != 3 && _state != 4) {
        play = YES;
        if (_state == 2) {
            play = ![_tryItAnimation isPlaying];
        }
    }
    [self setPlayTryItAnimation:play];
    if (aUpdate) {
        [self updateMainOptionsUI];
        [self updatePathOptionsUI];
    }
}

- (void)useAnimatedObjectSize:(NSSize)aSize affineTransform:(CGAffineTransform)aTransform actionName:(id)aName
{
    id object = [_tryItAnimation animatedObject];
    [self registerUndoGeometryChangesOfAnimatedObject:object withActionName:aName];
    [[object undoManager] disableUndoRegistration];
    [[object queryHyperInterface:@protocol(HSMutableGeometryAttributes)] setSize:aSize affineTransform:aTransform];
    [_tryItAnimation updateObject];
    [[object undoManager] enableUndoRegistration];
}

- (void)userSelectAnotherObject:(id)aObject withEditPathTool:(id)aTool
{
    if ([_cardView isOccupiedByTool]) {
        return;
    }
    [self cleanUpTryItAnimation];
    [self unlockAssistantIfNeeded];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"HSActiveToolDidSelectionNotification" object:[HSToolManager sharedToolManager]];
    [self resetToolToDefault];
    if (aObject != nil) {
        [[_cardView selection] selectNode:aObject];
    } else {
        [[_cardView selection] removeAllNodes];
    }
}

@end

@implementation _HSAnimationsProxy

/* i386 ivar offsets: _objects=0x4 */

+ (id)proxyWithObjects:(id)aObjects
{
    return [[(_HSAnimationsProxy *)[self alloc] initWithObjects:aObjects] autorelease];
}

- (void)forwardInvocation:(id)aInvocation
{
    NSEnumerator *self_00;
    id pvVar1;

    self_00 = [_objects objectEnumerator];
    pvVar1 = [self_00 nextObject];
    while (pvVar1 != nil) {
        [aInvocation invokeWithTarget:pvVar1];
        pvVar1 = [self_00 nextObject];
    }
}

- (id)methodSignatureForSelector:(SEL)aSelector
{
    return [[_objects objectAtIndex:0] methodSignatureForSelector:aSelector];
}

- (void)dealloc
{
    [_objects release];
    [super dealloc];
}

- (id)initWithObjects:(id)aObjects
{
    _objects = [aObjects copy];
    return self;
}

@end

