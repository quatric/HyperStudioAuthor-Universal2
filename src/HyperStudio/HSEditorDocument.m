#import "HSEditorDocument.h"
static id sDAT_00342a44;
static id sDAT_00342a48;
static id sDAT_00342a4c;
static id sDAT_00342a50;

static id sDAT_00342a44;
static id sDAT_00342a48;
static id sDAT_00342a4c;
static id sDAT_00342a50;

@implementation HSEditorDocument

/* i386 ivar offsets: _iPadStack=0xb0, _originalStackStorage=0xb4, _iPadUndoManager=0xb8, _modeSwitcher=0xbc, _animationModeController=0xc0, _exportManager=0xc4, _documentSharingController=0xc8, _commitLogMessage=0xcc, _isReceived=0xd0, _isHyperCollaborative=0xd1, _isHyperServer=0xd2, _isHyperClient=0xd3, _hyperSaveOperation=0xd4, _hyperRemovedItemsPaths=0xd8, _autosaveUndoManager=0xdc, _openWarning=0xe0, _editObjectDialogContext=0xe4, _selectionController=0xe8, _stackSelectionHolder=0xec, _selectionSync=0xf0, _storyboardController=0xf4, _purePlayerWindowController=0xf8, _presentationWindowController=0xfc, _playerInEditorWindowController=0x100, _hyperCastingWindowController=0x104, _invocationsToPerformAfterSwitchToEditMode=0x108, _modeHistory=0x10c, _playerView=0x110, _minimalWindowApplier=0x114, _isReadyToCreateMinimalWindowApplier=0x118, _hasPendingRequestToCreateMinimalWindowApplier=0x119, _isInDocumentClosing=0x11a, _palettesToHideInHypercastingMode=0x11c, _textViewsToResetScrollPosition=0x120, _wasOptimizedAndNotSaved=0x124 */

- (id)previewImageToStoreForCard:(id)aCard
{
    id pvVar1;

    pvVar1 = [super previewImageToStoreForCard:aCard];
    if (pvVar1 == nil) {
        pvVar1 = [[self stackView] previewImageToStoreForCard:aCard];
        [self setPreviewImage:pvVar1 forCard:aCard];
    }
    return pvVar1;
}

- (id)thumbnailImageToStoreForCard:(id)aCard
{
    id pvVar1;

    pvVar1 = [super thumbnailImageToStoreForCard:aCard];
    if (pvVar1 == nil) {
        pvVar1 = [[self stackView] thumbnailImageToStoreForCard:aCard];
        [self setThumbnailImage:pvVar1 forCard:aCard];
    }
    return pvVar1;
}

- (void)exportManagerDidEndPublishing:(id)aPublishing
{
    [[self exportManager] closeExportSession];
}

- (void)exportManagerDidEnd:(id)aEnd
{
    [[self stackView] setMediaStripUpdateDisabled:NO];
    [self clearCaches];
}

- (void)exportManagerWillStart:(id)aStart
{
    [[self stackView] setMediaStripUpdateDisabled:YES];
}

- (void)exportForiBooksAuthor:(id)aAuthor
{
    [self exportToDocumentWithType:@"HSiBooksAuthorDocumentType" inPublishType:3 inFormat:8 withRequiredFileType:@"wdgt"];
}

- (void)exitFromHyperCastingModeWithReturnCode:(NSInteger)aCode
{
    if (![[self modeSwitcher] switching] && [self isInHyperCastingMode]) {
        id lastMode = [[self modeHistory] lastObject];
        if (lastMode != nil) {
            [[self modeSwitcher] switchToModeController:lastMode];
            [[self modeHistory] removeLastObject];
        } else {
            [self switchToEditor];
        }
        [[self hyperCastingWindowController] setHyperCastingWindowControllerDelegate:nil];
        [self showPalettesAfterExport];
    }
}

- (void)switchToHyperCastingModeWithDelegate:(id)aDelegate
{
    id editorWindowController = [self editorWindowController];
    [editorWindowController saveScrollerPosition];
    [editorWindowController saveEditingState];
    [[HSCursor cursorNamed:HSDefaultCursor] set];
    [[self modeHistory] addObject:[[self modeSwitcher] activeModeController]];
    id hyperCastingController = [self hyperCastingWindowController];
    [hyperCastingController setHyperCastingWindowControllerDelegate:aDelegate];
    if ([self isInPurePlayerMode]) {
        [self exitPurePlayerModeWithAnimation:NO];
    }
    [[self modeSwitcher] switchWithoutAnimationToModeController:hyperCastingController deffered:NO];
    [self hidePalettesBeforeExport];
}

- (id)hyperCastingWindowController
{
    HSHyperCastingWindowController *pHVar1;
    HSHyperCastingWindowController *pHVar1_2;

    pHVar1 = _hyperCastingWindowController;
    if (pHVar1 == nil) {
        pHVar1_2 = [HSHyperCastingWindowController new];
        _hyperCastingWindowController = pHVar1_2;
        [self addWindowController:pHVar1_2];
        pHVar1 = _hyperCastingWindowController;
    }
    return pHVar1;
}

- (id)objectListTopLevelParent
{
    return [[self currentWindowController] activeCard];
}

- (id)objectListSelectionSynchronizer
{
    return [self selectionSync];
}

- (void)toggleBottomToolbar:(id)aToolbar
{
    BOOL pvVar1_2;

    pvVar1_2 = [[self currentWindowController] isBottomToolbarVisible];
    [[self currentWindowController] setBottomToolbarVisible:(unsigned int)(!pvVar1_2)];
}

- (void)toggleCardIndex:(id)aIndex
{
    id stackView = [self stackView];
    if ([stackView isStripVisible]) {
        [stackView hideCardIndex:self];
    } else {
        [stackView showCardIndex:self];
    }
}

- (void)removeCurrentCard:(id)aCard
{
    [self removeCurrentCardWithAlert:YES];
}

- (void)removeCards:(id)aCards withAlert:(BOOL)aAlert
{
    BOOL allEmpty = YES;
    NSEnumerator *enumerator = [aCards objectEnumerator];
    id card;
    while ((card = [enumerator nextObject]) != nil) {
        allEmpty = [[card queryHyperInterface:@protocol(HSCardAttributes)] isEmpty];
        if (!allEmpty) {
            break;
        }
    }
    BOOL showAlert = NO;
    if (aAlert) {
        NSInteger setting = [[[NSUserDefaults standardUserDefaults] objectForKey:@"HSDeleteCardAlertShow"] intValue];
        showAlert = (setting != 0 && !allEmpty);
    }
    BOOL inconsistent = NO;
    NSEnumerator *cards = [[[self stack] hyperEnumerator] retain];
    id other;
    while (!inconsistent && (other = [cards nextObject]) != nil) {
        if ([aCards containsObject:other]) {
            continue;
        }
        if ([self hasClickingOtherCardActionLeadingToCards:aCards inObject:other]) {
            inconsistent = YES;
            break;
        }
        NSEnumerator *children = [other hyperEnumerator];
        id child;
        while ((child = [children nextObject]) != nil) {
            if ([self hasClickingOtherCardActionLeadingToCards:aCards inObject:child]) {
                inconsistent = YES;
                break;
            }
        }
    }
    [cards release];
    if (!inconsistent) {
        if (!showAlert) {
            [self actuallyRemoveCards:aCards];
            return;
        }
        HSDontShowAgainAlert *alert = [HSDontShowAgainAlert new];
        BOOL plural = [aCards count] > 1;
        HSExecutableResourceProvider *provider = [HSExecutableResourceProvider sharedInstance];
        [alert setMessageText:[provider localizedStringForKey:(plural ? @"HSDeleteCardsAlertMessageText" : @"HSDeleteCardAlertMessageText") value:@"" table:@"Alerts"]];
        [alert setInformativeText:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:(plural ? @"HSDeleteCardsAlertInformativeText" : @"HSDeleteCardAlertInformativeText") value:@"" table:@"Alerts"]];
        [alert addButtonWithTitle:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:(plural ? @"HSDeleteCardsAlertFirstButtonTitle" : @"HSDeleteCardAlertFirstButtonTitle") value:@"" table:@"Alerts"]];
        [alert addButtonWithTitle:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"HSDeleteCardAlertSecondButtonTitle" value:@"" table:@"Alerts"]];
        [alert setShowAlertKey:@"HSDeleteCardAlertShow"];
        [aCards retain];
        [alert beginSheetModalForWindow:[[self currentWindowController] window] modalDelegate:self didEndSelector:@selector(alertDeleteCardDidEnd:returnCode:contextInfo:) contextInfo:aCards];
        return;
    }
    HSAlert *alert = [HSAlert new];
    [alert setMessageText:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"HSInconsistentActionsAlertMessageText" value:@"" table:@"Alerts"]];
    [alert setInformativeText:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"HSInconsistentActionsAlertInformativeText" value:@"" table:@"Alerts"]];
    [alert addButtonWithTitle:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"HSInconsistentActionsAlertDefaultButtonTitle" value:@"" table:@"Alerts"]];
    [alert addButtonWithTitle:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"Cancel" value:@"" table:@"Alerts"]];
    [aCards retain];
    [alert beginSheetModalForWindow:[[self currentWindowController] window] modalDelegate:self didEndSelector:@selector(alertDeleteCardDidEnd:returnCode:contextInfo:) contextInfo:aCards];
}

- (void)removeCurrentCardWithAlert:(BOOL)aAlert
{
    id pvVar1;

    pvVar1 = [self selectedCard];
    if (pvVar1 == nil) {
        pvVar1 = [self activeCard];
    }
    [self removeCards:[NSArray arrayWithObject:pvVar1] withAlert:aAlert];
}

- (void)removeSelectedCardsWithAlert:(BOOL)aAlert
{
    [self removeCards:[self selectedCards] withAlert:aAlert];
}

- (BOOL)hasClickingOtherCardActionLeadingToCards:(id)aCards inObject:(id)aObject
{
    id otherCardAction = [[aObject queryHyperInterface:@protocol(HSActor)] hyperActionOfType:[HSOtherCardAction actionType] forEvent:[HSActionEvent actionEventOfType:kHSClickActionEventType]];
    NSEnumerator *enumerator = [aCards objectEnumerator];
    id card;
    while ((card = [enumerator nextObject]) != nil) {
        if ([[otherCardAction destinationCardUID] isEqual:[[card queryHyperInterface:@protocol(HSObjectUIDAttribute)] hyperUID]]) {
            return YES;
        }
    }
    return NO;
}

- (void)alertDeleteCardDidEnd:(id)aEnd returnCode:(NSInteger)aCode contextInfo:(void *)aInfo
{
    if (aCode == 1000) {
        [self actuallyRemoveCards:(id)aInfo];
    }
    [(id)aInfo release];
    [aEnd release];
}

- (void)actuallyRemoveCards:(id)aCards
{
    [[HSObjectAssistantController sharedAssistantController] deactivateIfNeeded];
    NSMutableIndexSet *indexes = [[NSMutableIndexSet alloc] init];
    NSMutableArray *groupCards = [[NSMutableArray alloc] init];
    NSMutableArray *plainCards = [[NSMutableArray alloc] init];
    NSEnumerator *enumerator = [aCards objectEnumerator];
    id card;
    while ((card = [enumerator nextObject]) != nil) {
        [indexes addIndex:[card hyperIndex]];
        if ([card cardGroupUID] != nil) {
            [groupCards addObject:card];
        } else {
            [plainCards addObject:card];
        }
    }
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:indexes forKey:@"HSCardsIndexesForRemovalKey"];
    [indexes release];
    id stack = [self stack];
    if ([groupCards count] != 0) {
        [[stack cardGroupController] removeGroupCards:groupCards];
    }
    if ([plainCards count] != 0) {
        [stack removeHyperChildren:plainCards];
    }
    [plainCards release];
    [groupCards release];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HSCardsDidDeleteNotification" object:self userInfo:userInfo];
    if (stack != nil && [stack hyperCount] == 0) {
        [self newCard:self];
    }
}

- (void)liveSlideShow:(id)aShow
{
    if ([self shouldHandleToolSwitching] && [self canTogglePlayEdit]) {
        if ([[self playerView] isSlideshow]) {
            [[self playerView] stopSlideshow];
        } else {
            id playerWindowController = [self playerInEditorWindowController];
            id attributes = [playerWindowController slideshowAttributesFromDialog];
            if (attributes == nil) {
                return;
            }
            [self testCardWithUID:[[self currentCard] hyperUID] animate:NO];
            [playerWindowController startSlideShowWithAttributes:attributes];
        }
    }
}

- (void)newCard:(id)aCard
{
    HSCard *card = [HSCard defaultObject];
    id selectedCard = [[[self selectedHyperObject] queryHyperInterface:@protocol(HSUserObjectSupport)] card];
    id stack = [self stack];
    if (selectedCard != nil) {
        NSUInteger index = [stack indexOfHyperChild:selectedCard];
        index = (index == NSNotFound) ? [[self stack] hyperCount] : index + 1;
        [[self stack] insertHyperChild:card atIndex:index];
    } else {
        [stack addHyperChild:card];
    }
    [card fillBackgroundWithEraserColorIfNeeded];
    [card hyperRefreshTitle];
    if (![self isInPlayerMode]) {
        [[self editorWindowController] didAddNewCard];
    }
}

- (id)selectionSync
{
    id pvVar1;
    HSEditorSelectionSync *pHVar3;
    HSEditorSelectionSync *pHVar3_2;

    pHVar3 = _selectionSync;
    if (pHVar3 == nil) {
        pvVar1 = [self editorWindowController];
        pHVar3_2 = [[HSEditorSelectionSync alloc] init];
        _selectionSync = pHVar3_2;
        [pHVar3_2 setStackSelectionHost:[self stackSelectionHolder]];
        [_selectionSync setWindowController:pvVar1];
        pHVar3 = _selectionSync;
    }
    return pHVar3;
}

- (id)stackSelectionHolder
{
    HSStackSelectionHolder *pHVar1;
    HSStackSelectionHolder *pHVar1_2;

    pHVar1 = _stackSelectionHolder;
    if (pHVar1 == nil) {
        pHVar1_2 = [[HSStackSelectionHolder alloc] init];
        _stackSelectionHolder = pHVar1_2;
        [pHVar1_2 setDocument:self];
        pHVar1 = _stackSelectionHolder;
    }
    return pHVar1;
}

- (id)selectionController
{
    id pvVar1;
    HSEditorSelectionController *pHVar2;
    HSEditorSelectionController *pHVar2_2;

    pHVar2 = _selectionController;
    if (pHVar2 == nil) {
        pvVar1 = [self editorWindowController];
        pHVar2_2 = [[HSEditorSelectionController alloc] init];
        _selectionController = pHVar2_2;
        [pHVar2_2 setWindowController:pvVar1];
        [_selectionController setCardView:[self editorCardView]];
        [_selectionController setStackController:[self stackView]];
        [_selectionController setEnabled:YES];
        pHVar2 = _selectionController;
    }
    return pHVar2;
}

- (id)selectedHyperObject
{
    id pvVar1_2;

    pvVar1_2 = [[self selectionController] selectedHyperObject];
    if (pvVar1_2 == nil) {
        pvVar1_2 = [self stack];
    }
    return pvVar1_2;
}

- (id)activeCard
{
    id pvVar1_3;

    if (![self isInStoryboardMode]) {
        pvVar1_3 = [[self editorWindowController] activeCard];
    }
    else {
        pvVar1_3 = nil;
    }
    return pvVar1_3;
}

- (id)selectedCard
{
    id self_00;
    BOOL pvVar1;
    id pvVar2;

    self_00 = [self selectedHyperObject];
    pvVar1 = [self_00 implementsHyperInterface:@protocol(HSCardAttributes)];
    pvVar2 = nil;
    if (pvVar1) {
        pvVar2 = self_00;
    }
    return pvVar2;
}

- (id)exportManager
{
    if (_exportManager == nil) {
        _exportManager = [HSExportManager new];
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self selector:@selector(exportManagerWillStart:) name:HSExportManagerWillStartExportNotification object:_exportManager];
        [center addObserver:self selector:@selector(exportManagerDidEnd:) name:HSExportManagerDidEndExportNotification object:_exportManager];
        [center addObserver:self selector:@selector(exportManagerDidEndPublishing:) name:HSExportManagerDidEndPublishNotification object:_exportManager];
        [center addObserver:self selector:@selector(exportManagerDidEndPublishing:) name:HSExportManagerDidFailNotification object:_exportManager];
    }
    return _exportManager;
}

- (id)purePlayerWindowControllerCreateIfNeeded:(BOOL)aNeeded withPreferencesSettings:(BOOL)aSettings
{
    id pvVar1;
    id *ppvVar2;
    id pvVar1_3;

    if (aSettings == NO) {
        if ((_purePlayerWindowController == nil) && (aNeeded != NO)) {
            pvVar1 = [HSPurePlayerInEditorWindowController new];
            _purePlayerWindowController = pvVar1;
            [pvVar1 setShouldCloseDocument:YES];
            [self addWindowController:_purePlayerWindowController];
        }
        ppvVar2 = &_purePlayerWindowController;
        if ([_presentationWindowController playerSettingsDataSource] != nil) {
            [_presentationWindowController setPlayerSettingsDataSource:nil];
        }
    }
    else {
        if ((_presentationWindowController == nil) && (aNeeded != NO)) {
            pvVar1_3 = [HSPurePlayerInEditorWindowController new];
            _presentationWindowController = pvVar1_3;
            [pvVar1_3 setShouldCloseDocument:YES];
            [self addWindowController:_presentationWindowController];
        }
        ppvVar2 = &_presentationWindowController;
        [*ppvVar2 setPlayerSettingsDataSource:[[[HSPlayerSettingsDataSource alloc] initPreferencesSettingsDataSource] autorelease]];
    }
    return *ppvVar2;
}

- (id)presentationWindowControllerCreateIfNeeded:(BOOL)aNeeded
{
    return [self purePlayerWindowControllerCreateIfNeeded:(unsigned int)aNeeded withPreferencesSettings:YES];
}

- (id)purePlayerWindowControllerCreateIfNeeded:(BOOL)aNeeded
{
    return [self purePlayerWindowControllerCreateIfNeeded:(unsigned int)aNeeded withPreferencesSettings:NO];
}

- (id)storyboardController
{
    HSStoryboardController *pHVar1;
    HSStoryboardController *pHVar1_2;

    pHVar1 = _storyboardController;
    if (pHVar1 == nil) {
        pHVar1_2 = [HSStoryboardController new];
        _storyboardController = pHVar1_2;
        [self addWindowController:pHVar1_2];
        pHVar1 = _storyboardController;
    }
    return pHVar1;
}

- (void)setIsReadyToCreateMinimalWindowApplier
{
    char cVar1;

    cVar1 = _hasPendingRequestToCreateMinimalWindowApplier;
    _hasPendingRequestToCreateMinimalWindowApplier = NO;
    _isReadyToCreateMinimalWindowApplier = YES;
    if (cVar1 != NO) {
        [self minimalWindowApplier];
    }
}

- (id)minimalWindowApplier
{
    HSMinimalWindowApplier *pHVar1;
    id self_00;

    if (_minimalWindowApplier == nil) {
        if (_isReadyToCreateMinimalWindowApplier == NO) {
            _hasPendingRequestToCreateMinimalWindowApplier = YES;
        }
        else {
            if (_modeSwitcher == nil) {
                self_00 = nil;
                pHVar1 = nil;
            }
            else {
                self_00 = [self currentWindowController];
                pHVar1 = [self newMinimalWindowApplierWithWindowController:self_00];
                _minimalWindowApplier = pHVar1;
            }
            if (pHVar1 != nil) {
                [[self editorWindowController] setupMinimalWindowApplier:_minimalWindowApplier];
                if ([self_00 respondsToSelector:@selector(documentDidCreateMinimalWindowApplier)]) {
                    [self_00 documentDidCreateMinimalWindowApplier];
                }
            }
        }
    }
    return _minimalWindowApplier;
}

- (id)newMinimalWindowApplierWithWindowController:(id)aController
{
    if ([aController supportsMinimalWindowMode] && [aController window] != nil && [aController cardView] != nil && [[aController cardView] window] == [aController window]) {
        return [[HSMinimalWindowApplier alloc] initWithWindow:[aController window] cardView:[aController cardView]];
    }
    return nil;
}

- (void)addReadyMadeCards:(id)aCards
{
    [[HSEditorController sharedDocumentController] addReadyMadeCards:aCards];
}

- (void)selectInEditorCardViewObjects:(id)aObjects
{
    [[self editorCardView] selectHyperObjects:aObjects];
}

- (void)finalizeBitmapToolIfNeededForAction:(SEL)aAction to:(id)aTo from:(id)aFrom
{
    if (![self isInStandardMode] || [self internalPlayerActive]) {
        return;
    }
    if ([[HSToolManager sharedToolManager] selectedToolTag] != 0x12) {
        return;
    }
    if (aAction == @selector(redo:) || aAction == @selector(undo:) || aAction == @selector(openDrawer:) || aAction == @selector(actionToleranceChanged:)) {
        BOOL skipChecks = NO;
        if (aAction == @selector(actionToleranceChanged:) && ![aTo isKindOfClass:[HSPaintBucketSettingsViewController class]]) {
            skipChecks = YES;
        }
        if (!skipChecks) {
            if (aAction != @selector(openDrawer:)) {
                return;
            }
            if ([HSToolPaletteController sharedInstance] == aTo) {
                return;
            }
        }
    }
    [[[[HSToolManager sharedToolManager] currentTool] bitmapTool] doCommandBySelector:@selector(finalize:)];
    NSUndoManager *undoManager = [self undoManager];
    if ([undoManager groupsByEvent] && [undoManager groupingLevel] == 1) {
        [undoManager NSE_endUndoAutogroup];
    }
}

- (void)togglePresentationMode:(id)aMode
{
    if (![self isPresentationModeSwitching]) {
        if ([self isInPresentationMode]) {
            [self exitPresentationMode];
        } else {
            [self beginEnteringInPresentationMode];
        }
    }
}

- (void)exitPurePlayerModeWithAnimation:(BOOL)aAnimation
{
    if (![self isStackProtected]) {
        BOOL inPurePlayer = [self isInPurePlayerMode];
        BOOL inPresentation = [self isInPresentationMode];
        if (![[self modeSwitcher] switching]) {
            id firstMode = [[self modeHistory] extraFirstObject];
            if (aAnimation) {
                [[self modeSwitcher] switchToModeController:firstMode];
            } else {
                [[self modeSwitcher] switchWithoutAnimationToModeController:firstMode deffered:NO];
            }
            if (firstMode != nil) {
                [[self modeHistory] removeAllObjects];
            }
            [[HSObjectAssistantController sharedAssistantController] activateIfNeeded];
        }
        if (inPresentation || inPurePlayer) {
            [[HSEditorController sharedDocumentController] documentEnteredPurePlayerMode:NO];
        }
        if (!inPresentation) {
            if (inPurePlayer) {
                [self removeWindowController:_purePlayerWindowController];
                [_purePlayerWindowController release];
                _purePlayerWindowController = nil;
            }
        } else {
            [self removeWindowController:_presentationWindowController];
            [_presentationWindowController release];
            _presentationWindowController = nil;
        }
    }
}

- (void)enterPurePlayerModeWithAnimation:(BOOL)aAnimation withPreferencesSettings:(BOOL)aSettings
{
    [[HSEditorController sharedDocumentController] setDocumentInEditor:NO];
    BOOL inPresentation = [self isInPresentationMode];
    BOOL inPurePlayer = [self isInPurePlayerMode];
    if (!inPurePlayer && !inPresentation) {
        [[HSEditorController sharedDocumentController] documentEnteredPurePlayerMode:YES];
    }
    if (![[self modeSwitcher] switching]) {
        [[HSObjectAssistantController sharedAssistantController] setActive:NO explicitlyByUser:NO];
        [[self editorWindowController] saveScrollerPosition];
        id purePlayerController = [self purePlayerWindowControllerCreateIfNeeded:YES withPreferencesSettings:aSettings];
        [[self modeHistory] addObject:[[self modeSwitcher] activeModeController]];
        if (aAnimation) {
            [[self modeSwitcher] switchToModeController:purePlayerController];
        } else {
            [[self modeSwitcher] switchWithoutAnimationToModeController:purePlayerController deffered:NO];
        }
        if (!inPresentation) {
            if (inPurePlayer) {
                [self removeWindowController:_purePlayerWindowController];
                [_purePlayerWindowController release];
                _purePlayerWindowController = nil;
            }
        } else {
            [self removeWindowController:_presentationWindowController];
            [_presentationWindowController release];
            _presentationWindowController = nil;
        }
    }
}

- (void)enterPurePlayerModeWithAnimation:(BOOL)aAnimation
{
    [self enterPurePlayerModeWithAnimation:aAnimation withPreferencesSettings:NO];
}

- (void)setStoryboardModeOn:(BOOL)aOn
{
    BOOL pvVar1;

    pvVar1 = [self isInStoryboardMode];
    if (aOn == NO) {
        if (!pvVar1) {
            return;
        }
    }
    if (pvVar1) {
        return;
    }
    [self toggleStoryboard:nil];
}

- (void)exitStoryboardMode:(id)aMode
{
    id pvVar1_3;

    if ([self isInStoryboardMode]) {
        pvVar1_3 = [[self modeHistory] lastObject];
        [[self modeSwitcher] switchToModeController:pvVar1_3];
        [[self modeHistory] removeLastObject];
    }
}

- (void)enterStoryboardMode:(id)aMode
{
    if (![[self modeSwitcher] switching]) {
        if (![self isInStoryboardMode]) {
            if ([self isInPresentationMode]) {
                [self exitPurePlayerModeWithAnimation:YES];
            }
            [[self modeHistory] addObject:[[self modeSwitcher] activeModeController]];
            if ([[self modeSwitcher] activeModeController] == [self playerInEditorWindowController]) {
                [[HSActionMediaPlayer sharedActionMediaPlayer] stopAllSoundsForStackUID:[[self stack] hyperUID] andSoundAttributes:nil];
            }
            [[self modeSwitcher] switchToModeController:[self storyboardController]];
        }
    }
}

- (void)toggleStoryboard:(id)aStoryboard
{
    if (![[self modeSwitcher] switching]) {
        if ([self isInPresentationMode] || [self isInPurePlayerMode]) {
            [self exitPurePlayerModeWithAnimation:YES];
        }
        if ([self isInStoryboardMode]) {
            [self exitStoryboardMode:aStoryboard];
        } else {
            [self enterStoryboardMode:aStoryboard];
        }
    }
}

- (id)modeHistory
{
    id pvVar1;

    pvVar1 = _modeHistory;
    if (pvVar1 == nil) {
        [self setModeHistory:[[[NSMutableArray alloc] init] autorelease]];
        pvVar1 = _modeHistory;
    }
    return pvVar1;
}

- (void)setModeHistory:(id)aHistory
{
    if (_modeHistory != aHistory) {
        [_modeHistory autorelease];
        _modeHistory = [aHistory retain];
    }
}

- (void)optimizeAndSaveAs:(id)aAs
{
    NSSavePanel *panel = [NSSavePanel savePanel];
    [panel setPrompt:[[NSBundle mainBundle] localizedStringForKey:@"Optimize" value:@"" table:nil]];
    NSString *name = [[[[self fileURL] path] lastPathComponent] stringByDeletingPathExtension];
    [panel setAllowedFileTypes:[NSArray arrayWithObject:@"stack"]];
    [panel setDirectoryURL:[NSURL fileURLWithPath:[[HSPathsProvider sharedPathsProvider] hyperStudioDocumentsFolder] isDirectory:YES]];
    if (name == nil) {
        name = [self displayName];
    }
    [panel setNameFieldStringValue:name];
    [panel beginSheetModalForWindow:[[self currentWindowController] window] completionHandler:^(NSInteger result) {
        [self optimizeAndSaveAsPanelDidEnd:panel returnCode:result contextInfo:NULL];
    }];
}

- (void)showPalettesAfterExport
{
    if (_palettesToHideInHypercastingMode != nil) {
        [_palettesToHideInHypercastingMode makeObjectsPerformSelector:@selector(showPalette)];
        [_palettesToHideInHypercastingMode release];
        _palettesToHideInHypercastingMode = nil;
    }
}

- (void)hidePalettesBeforeExport
{
    if (_palettesToHideInHypercastingMode == nil) {
        _palettesToHideInHypercastingMode = [[NSMutableArray alloc] init];
    }
    if ([[HSObjectListPaletteController sharedInstance] isPaletteVisible]) {
        [_palettesToHideInHypercastingMode addObject:[HSObjectListPaletteController sharedInstance]];
    }
    if ([[HSLayoutPaletteController sharedInstance] isPaletteVisible]) {
        [_palettesToHideInHypercastingMode addObject:[HSLayoutPaletteController sharedInstance]];
    }
    [_palettesToHideInHypercastingMode makeObjectsPerformSelector:@selector(hidePalette)];
}

- (void)saveDocumentAs:(id)aAs
{
    if (![self isWritingDisabled]) {
        [super saveDocumentAs:aAs];
    }
}

- (void)saveDocument:(id)aDocument
{
    if (![self isWritingDisabled]) {
        [super saveDocument:aDocument];
    }
}

- (void)testCard:(id)aCard
{
    [self testCardWithUID:[[self currentCard] hyperUID] animate:YES];
}

- (void)testStack:(id)aStack
{
    [self testCardWithUID:[[[self stack] hyperChildAtIndex:0] hyperUID] animate:YES];
}

- (void)togglePlayEditViaGlobalShortcut:(id)aShortcut
{
    if (![self isStackProtected]) {
        if (![self isInPurePlayerMode]) {
            [self togglePlayEdit:aShortcut];
        }
    }
}

- (void)togglePlayEdit:(id)aEdit
{
    if ([self shouldHandleToolSwitching] && [self canTogglePlayEdit]) {
        if ([self internalPlayerActive]) {
            if ([self isInPurePlayerMode])
                [self exitPurePlayerModeWithAnimation:NO];
            else if ([self isInPresentationMode])
                [self exitPresentationMode];
            [self switchToEditorWithToolTag:1];
        } else {
            [self testCard:aEdit];
        }
    }
}

- (void)switchToPurePlayerMode:(id)aMode
{
    if (![self isInPurePlayerMode]) {
        [self enterPurePlayerModeWithAnimation:YES withPreferencesSettings:NO];
    }
}

- (void)switchToPresentationMode:(id)aMode
{
    if (![self isInPresentationMode]) {
        [self enterPurePlayerModeWithAnimation:YES withPreferencesSettings:YES];
    }
}

- (void)switchToStandardMode:(id)aMode
{
    if ([self isInStandardMode]) {
        return;
    }
    if ([self isInPresentationMode] || [self isInPurePlayerMode]) {
        [self exitPurePlayerModeWithAnimation:YES];
    } else if ([self isInStoryboardMode]) {
        [self exitStoryboardMode:aMode];
    } else if (NO) {
        [self toggleIpadExportPreview:self];
    }
    [[self modeSwitcher] switchToModeController:[self editorWindowController]];
}

- (BOOL)canTogglePlayEdit
{
    BOOL canDeactivate = [[[self mainWindowController] cardView] canDeactivate];
    BOOL switching = [[self modeSwitcher] switching];
    BOOL occupiedByTool = [[self editorCardView] isOccupiedByTool];
    if (![self isInPlayerMode] && (NO || [self isInPurePlayerMode] || [self isInStoryboardMode])) {
        [[self modeHistory] lastObject];
        return NO;
    }
    if (canDeactivate) {
        return !occupiedByTool && !switching;
    }
    return NO;
}

- (BOOL)prepareForHandlingActionThatRequiresConditionalSwitchToEditMode
{
    return (BOOL)[self prepareForActionThatRequiresSwitchToEditMode];
}

- (BOOL)shouldHandleActionThatRequiresConditionalSwitchToEditMode
{
    return ![[self modeSwitcher] switching];
}

- (BOOL)shouldHandleActionThatRequiresImmediateSwitchToEditMode:(BOOL)aMode
{
    return (BOOL)[self prepareForActionThatRequiresSwitchToEditMode:aMode];
}

- (BOOL)shouldHandleActionThatRequiresImmediateSwitchToEditMode
{
    return (BOOL)[self shouldHandleActionThatRequiresImmediateSwitchToEditMode:YES];
}

- (BOOL)prepareForActionThatRequiresSwitchToEditMode
{
    return (BOOL)[self prepareForActionThatRequiresSwitchToEditMode:YES];
}

- (BOOL)prepareForActionThatRequiresSwitchToEditMode:(BOOL)aMode
{
    if ([[self modeSwitcher] switching]) {
        return NO;
    }
    if (![self isInPlayerMode] || [self isStackProtected]) {
        return YES;
    }
    if ([self isInPurePlayerMode] || [self isInPresentationMode]) {
        [self exitPurePlayerModeWithAnimation:NO];
    }
    [self switchToEditor:aMode];
    return YES;
}

- (BOOL)shouldHandleToolSwitching
{
    return ![[self modeSwitcher] switching];
}

- (void)stopExport
{
    [[self exportManager] stopExport];
}

- (void)switchToEditor:(BOOL)aEditor
{
    [self switchToEditor:aEditor blockingAnimation:NO];
}

- (void)switchToEditor
{
    [self switchToEditor:YES];
}

- (void)switchToEditor:(BOOL)aEditor blockingAnimation:(BOOL)aAnimation
{
    [[HSEditorController sharedDocumentController] setDocumentInEditor:YES];
    [[self editorWindowController] saveScrollerPosition];
    [[self modeHistory] removeAllObjects];
    [[self navigationController] interruptAllNavigationOperations];
    NSEnumerator *enumerator = [[self textViewsToResetScrollPosition] objectEnumerator];
    id textView;
    while ((textView = [enumerator nextObject]) != nil) {
        [textView setVerticalScrollPosition:0];
        [textView setHorizontalScrollPosition:0];
    }
    [[self textViewsToResetScrollPosition] removeAllObjects];
    if (aAnimation) {
        [[self modeSwitcher] switchWithBlockingAnimationAnimationToModeController:[self editorWindowController]];
    } else {
        [[self modeSwitcher] switchToModeController:[self editorWindowController]];
    }
    if (![[self navigationController] isKindOfClass:[HSEditorNavigationController class]]) {
        [self setNavigationController:nil];
    }
    if (aEditor) {
        id activeCard = [[[[self modeSwitcher] previousModeController] modeSwitcherWindowController:[self modeSwitcher]] activeCard];
        if (activeCard != nil) {
            [[[self mainWindowController] cardView] setCard:activeCard];
        }
    }
}

- (void)switchToEditorWithToolTag:(NSInteger)aTag
{
    [self switchToEditor];
    [[self editorWindowController] switchToToolWithTag:aTag];
}

- (void)switchToEditorWithTool:(id)aTool
{
    [self switchToEditorWithToolTag:[aTool tag]];
}

- (void)selectAllArea:(id)aArea
{
    [[[self mainWindowController] cardView] setCard:[[[self playerInEditorWindowController] cardView] card]];
    [[self modeHistory] removeAllObjects];
    [self addActionToPerformAfterSwitchToEditMode:@selector(selectAllArea:) sender:aArea handler:[self editorWindowController]];
    [[self modeSwitcher] switchToModeController:[self editorWindowController]];
}

- (void)testCardWithUID:(id)aUID animate:(BOOL)aAnimate
{
    [[HSEditorController sharedDocumentController] setDocumentInEditor:NO];
    id editorWindowController = [self editorWindowController];
    [editorWindowController saveScrollerPosition];
    [editorWindowController saveEditingState];
    [[HSCursor cursorNamed:HSDefaultCursor] set];
    [[self cardView] setCard:[[self stack] childWithUID:aUID]];
    [[self modeHistory] removeAllObjects];
    if (aAnimate) {
        [[self modeSwitcher] switchToModeController:[self playerInEditorWindowController]];
    } else {
        [[self modeSwitcher] switchWithoutAnimationToModeController:[self playerInEditorWindowController] deffered:NO];
    }
}

- (BOOL)internalPlayerActive
{
    return (BOOL)[self isInPlayerMode];
}

- (id)modeSwitcher
{
    HSModeSwitcher *self_00;

    if (_modeSwitcher == nil) {
        if ([self mainWindowController] != nil) {
            self_00 = [[HSModeSwitcher alloc] initWithModeController:[self mainWindowController]];
            _modeSwitcher = self_00;
            [self_00 awakeFromInit];
        }
    }
    return _modeSwitcher;
}

- (void)setModeSwitcher:(id)aSwitcher
{
    if (_modeSwitcher != aSwitcher) {
        [_modeSwitcher autorelease];
        _modeSwitcher = [aSwitcher retain];
    }
}

- (id)editObjectDialogContext
{
    HSEditObjectDialogContext *pHVar1;

    pHVar1 = _editObjectDialogContext;
    if (pHVar1 == nil) {
        pHVar1 = [[HSEditObjectDialogContext alloc] initWithEditorDocument:self];
        _editObjectDialogContext = pHVar1;
    }
    return pHVar1;
}

- (id)selectedCards
{
    id pvVar1_2;

    if (![self isInStoryboardMode]) {
        pvVar1_2 = [super selectedCards];
    }
    else {
        pvVar1_2 = [[[self selectionController] selectedHyperObject] allHyperInterfaces];
    }
    return pvVar1_2;
}

- (id)transitionNames
{
    id pvVar1;
    id self_00;
    id self_01;
    NSUInteger pvVar2;
    NSUInteger pvVar4;
    id pvVar3_2;

    pvVar1 = [NSMutableArray array];
    if (((pvVar1 != nil) && (self_00 = [HSTransitionEffectProvider sharedTransitionEffectProvider], self_00 != nil)) && (self_01 = [self_00 transitionEffectNames], self_01 != nil)) {
        pvVar2 = [self_01 count];
        if (pvVar2 != 0) {
            pvVar4 = 0;
            do {
                pvVar3_2 = [self_00 displayNameForTransitionEffectWithName:[self_01 objectAtIndex:pvVar4]];
                if (pvVar3_2 != nil) {
                    [pvVar1 addObject:pvVar3_2];
                }
                pvVar4 = (pvVar4 + 1);
            } while (pvVar4 < pvVar2);
        }
        return [[pvVar1 copy] autorelease];
    }
    return nil;
}

- (void)detachToolView
{
    [[HSToolManager sharedToolManager] setToolView:nil];
}

- (void)close
{
    if (!_isInDocumentClosing) {
        _isInDocumentClosing = YES;
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
        [[self selectionController] noteWindowControllerWillClose];
        BOOL pure = (_purePlayerWindowController != nil && [self currentWindowController] == _purePlayerWindowController && [self isInPurePlayerMode]);
        BOOL presentation = (_presentationWindowController != nil && [self currentWindowController] == _presentationWindowController && [self isInPresentationMode]);
        if (presentation || pure) {
            [[HSEditorController sharedDocumentController] documentEnteredPurePlayerMode:NO];
        }
        [super close];
        _isInDocumentClosing = NO;
    }
}

- (void)removeWindowControllers
{
    [super removeWindowControllers];
    if (_playerInEditorWindowController != nil) {
        [_playerInEditorWindowController setStatusbarController:nil];
        [_playerInEditorWindowController setToolbarController:nil];
        [_playerInEditorWindowController release];
        _playerInEditorWindowController = nil;
    }
    if (_storyboardController != nil) {
        [_storyboardController release];
        _storyboardController = nil;
    }
    if (_minimalWindowApplier != nil) {
        [_minimalWindowApplier release];
        _minimalWindowApplier = nil;
    }
}

- (void)createWindowControllers
{
    HSEditorController *controller = [HSEditorController sharedDocumentController];
    [super createWindowControllers];
    id playerInEditor = [controller sharedPlayerInEditorWindowController];
    if (playerInEditor != nil) {
        _playerInEditorWindowController = [playerInEditor retain];
        [self addWindowController:_playerInEditorWindowController];
        [controller sharedPLayerInEditorWindowControllerHandled];
    }
    id purePlayer = [controller sharedPurePlayerWindowController];
    if (purePlayer != nil) {
        _purePlayerWindowController = [purePlayer retain];
        [self addWindowController:_purePlayerWindowController];
        [controller sharedPurePlayerWindowControllerHandled];
    }
    id presentation = [controller sharedPresentationWindowController];
    if (presentation != nil) {
        _presentationWindowController = [presentation retain];
        [self addWindowController:_presentationWindowController];
        [controller sharedPresentationWindowControllerHandled];
    }
}

- (void)cleanupWindowControllers
{
    if ([[HSEditorController sharedDocumentController] sharedPlayerInEditorWindowController] == _playerInEditorWindowController) {
        [self removeWindowController:_playerInEditorWindowController];
    }
    [super cleanupWindowControllers];
}

- (void)removeWindowController:(id)aController
{
    if ([self mainWindowController] == aController) {
        [self setModeSwitcher:nil];
    }
    [super removeWindowController:aController];
}

- (void)document:(id)aDocument didSave:(BOOL)aSave contextInfo:(void *)aInfo
{
    [(id)aInfo invokeCanCloseCallbackFrom:self shouldClose:aSave];
    [(id)aInfo release];
}

- (void)alertCloseStackProtectedDocumentDidEnd:(id)aEnd returnCode:(NSInteger)aCode contextInfo:(void *)aInfo
{
    [[aEnd window] orderOut:self];
    if (aCode == 1000) {
        [self runModalSavePanelForSaveOperation:1 delegate:self didSaveSelector:@selector(document:didSave:contextInfo:) contextInfo:aInfo];
    } else {
        [(id)aInfo invokeCanCloseCallbackFrom:self shouldClose:(aCode == 0x3ea)];
        [(id)aInfo release];
    }
    [aEnd release];
}

- (void)alertCloseHyperCastingModeDidEnd:(id)aEnd returnCode:(NSInteger)aCode contextInfo:(void *)aInfo
{
    if (aCode == 1000) {
        [[self exportManager] stopExport];
        [super canCloseDocumentWithDelegate:[(id)aInfo delegate] shouldCloseSelector:[(id)aInfo selector] contextInfo:[(id)aInfo contextInfo]];
    } else {
        [(id)aInfo invokeCanCloseCallbackFrom:self shouldClose:NO];
    }
    [(id)aInfo release];
    [aEnd release];
}

- (void)alertCloseRecordingMovieOrSoundDidEnd:(id)aEnd returnCode:(NSInteger)aCode contextInfo:(void *)aInfo
{
    if (aCode == 1000) {
        [[HSObjectAssistantController sharedAssistantController] setActive:NO explicitlyByUser:NO];
        [super canCloseDocumentWithDelegate:[(id)aInfo delegate] shouldCloseSelector:[(id)aInfo selector] contextInfo:[(id)aInfo contextInfo]];
    } else {
        [(id)aInfo invokeCanCloseCallbackFrom:self shouldClose:NO];
    }
    [(id)aInfo release];
    [aEnd release];
}

- (void)canCloseDocumentWithDelegate:(id)aDelegate shouldCloseSelector:(SEL)aSelector contextInfo:(void *)aInfo
{
    BOOL inAnimationMode = NO;
    BOOL inHyperCastingMode = [self isInHyperCastingMode];
    BOOL stackProtected = [[self stack] isStackProtected];
    BOOL recordingMovie = [[HSObjectAssistantController sharedAssistantController] isRecordingMovie];
    BOOL recordingSound = [[HSObjectAssistantController sharedAssistantController] isRecordingSound];
    if (!inHyperCastingMode && !inAnimationMode && (!stackProtected || ![self isDocumentEdited]) && !recordingSound && !recordingMovie) {
        [super canCloseDocumentWithDelegate:aDelegate shouldCloseSelector:aSelector contextInfo:aInfo];
        return;
    }
    HSCanCloseDocumentParametersData *parameters = [[HSCanCloseDocumentParametersData alloc] initWithDelegate:aDelegate selector:aSelector contextInfo:aInfo];
    id window = [[self currentWindowController] window];
    id alert;
    SEL didEnd;
    if (inAnimationMode) {
        alert = [self createCanCloseAnimationModeAlert];
        didEnd = @selector(alertCloseAnimationModeDidEnd:returnCode:contextInfo:);
    } else if (inHyperCastingMode) {
        alert = [self createCanCloseHyperCastingModeAlert];
        didEnd = @selector(alertCloseHyperCastingModeDidEnd:returnCode:contextInfo:);
    } else if (recordingMovie || recordingSound) {
        alert = recordingMovie ? [self createCanCloseRecordingMovieAlert] : [self createCanCloseRecordingSoundAlert];
        didEnd = @selector(alertCloseRecordingMovieOrSoundDidEnd:returnCode:contextInfo:);
    } else if (stackProtected) {
        alert = [self newCanCloseProtectedStackAlert];
        didEnd = @selector(alertCloseStackProtectedDocumentDidEnd:returnCode:contextInfo:);
    } else {
        return;
    }
    [alert beginSheetModalForWindow:window modalDelegate:self didEndSelector:didEnd contextInfo:parameters];
}

- (id)newCanCloseProtectedStackAlert
{
    HSAlert *alert = [HSAlert new];
    [alert setMessageText:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"NavigationSaveDocumentAlertText" value:@"" table:@"Alerts"]];
    [alert setInformativeText:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"NavigationSaveDocumentAlertInformativeText" value:@"" table:@"Alerts"]];
    [alert addButtonWithTitle:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"NavigationSaveDocumentSaveAsButtonTitle" value:@"" table:@"Alerts"]];
    [alert addButtonWithTitle:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"Cancel" value:@"" table:@"Alerts"]];
    [alert addButtonWithTitle:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"NavigationSaveDocumentDontSaveTitle" value:@"" table:@"Alerts"]];
    return alert;
}

- (id)createCanCloseHyperCastingModeAlert
{
    HSAlert *alert = [HSAlert new];
    HSExecutableResourceProvider *provider = [HSExecutableResourceProvider sharedInstance];
    [alert setMessageText:[provider localizedStringForKey:@"HSHyperCastingModeQuitMessageText" value:@"" table:@"Alerts"]];
    [alert setInformativeText:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"HSHyperCastingModeQuitInformativeText" value:@"" table:@"Alerts"]];
    [alert addButtonWithTitle:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"HSHyperCastingModeQuitCloseButtonText" value:@"" table:@"Alerts"]];
    [alert addButtonWithTitle:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"HSHyperCastingModeQuitCancelButtonText" value:@"" table:@"Alerts"]];
    return alert;
}

- (id)createCanCloseRecordingMovieAlert
{
    HSAlert *alert = [HSAlert new];
    HSExecutableResourceProvider *provider = [HSExecutableResourceProvider sharedInstance];
    [alert setMessageText:[provider localizedStringForKey:@"HSRecordingMovieQuitMessageText" value:@"" table:@"Alerts"]];
    [alert setInformativeText:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"HSRecordingMovieQuitInformativeText" value:@"" table:@"Alerts"]];
    [alert addButtonWithTitle:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"HSRecordingMovieQuitOKButtonText" value:@"" table:@"Alerts"]];
    [alert addButtonWithTitle:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"HSRecordingMovieQuitCancelButtonText" value:@"" table:@"Alerts"]];
    return alert;
}

- (id)createCanCloseRecordingSoundAlert
{
    HSAlert *alert = [HSAlert new];
    HSExecutableResourceProvider *provider = [HSExecutableResourceProvider sharedInstance];
    [alert setMessageText:[provider localizedStringForKey:@"HSRecordingSoundQuitMessageText" value:@"" table:@"Alerts"]];
    [alert setInformativeText:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"HSRecordingSoundQuitInformativeText" value:@"" table:@"Alerts"]];
    [alert addButtonWithTitle:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"HSRecordingSoundQuitOKButtonText" value:@"" table:@"Alerts"]];
    [alert addButtonWithTitle:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"HSRecordingSoundQuitCancelButtonText" value:@"" table:@"Alerts"]];
    return alert;
}

- (void)setPlayerView:(id)aView
{
    if (_playerView != aView) {
        [_playerView release];
        _playerView = [aView retain];
    }
}

- (id)playerView
{
    if (_playerView == nil) {
        id controller = _playerInEditorWindowController;
        if ([self isInPurePlayerMode] || [self isInPresentationMode] || controller == nil) {
            controller = [self isInPresentationMode] ? _presentationWindowController : _purePlayerWindowController;
        }
        _playerView = [[controller playerView] retain];
    }
    return _playerView;
}

- (id)editorWindowController
{
    return [self mainWindowController];
}

- (id)editorCardView
{
    return [[self editorWindowController] cardView];
}

- (id)playerCardView
{
    return [[self playerView] cardView];
}

- (void)makeWindowControllers
{
    [super makeWindowControllers];
    if (_playerInEditorWindowController == nil) {
        _playerInEditorWindowController = [[[HSEditorController sharedDocumentController] sharedPlayerInEditorWindowController] retain];
        if (_playerInEditorWindowController != nil) {
            [self addWindowController:_playerInEditorWindowController];
        }
    }
    [[HSEditorController sharedDocumentController] sharedPLayerInEditorWindowControllerHandled];
    if (_presentationWindowController == nil) {
        _presentationWindowController = [[[HSEditorController sharedDocumentController] sharedPresentationWindowController] retain];
        if (_presentationWindowController != nil) {
            [self addWindowController:_presentationWindowController];
        }
    }
    [[HSEditorController sharedDocumentController] sharedPresentationWindowControllerHandled];
    if (_purePlayerWindowController == nil) {
        _purePlayerWindowController = [[[HSEditorController sharedDocumentController] sharedPurePlayerWindowController] retain];
        if (_purePlayerWindowController != nil) {
            [self addWindowController:_purePlayerWindowController];
        }
    }
    [[HSEditorController sharedDocumentController] sharedPurePlayerWindowControllerHandled];
    if ([self fileURL] == nil) {
        [[HSCoachingHelpManager sharedCoachingHelpManager] addObject:[self stack] forStack:[self stack]];
        if (!NSEqualSizes([HSStack newStackCardSize], NSZeroSize)) {
            HSNewStackCoachingPane *pane = [HSNewStackCoachingPane new];
            [[HSCoachingHelpManager sharedCoachingHelpManager] pushAdditionalCoachingPane:pane forObject:[self stack]];
            [pane release];
        }
    }
}

- (id)hyperScriptableEntityWithScriptName:(id)aName
{
    id pvVar1;
    id pvVar1_2;

    pvVar1 = [HSUID uidWithScriptValue:aName];
    if (pvVar1 != nil) {
        pvVar1_2 = [[self stack] childInTreeWithUID:pvVar1];
        if (pvVar1_2 != nil) {
            return [pvVar1_2 queryHyperInterface:@protocol(HSScriptableEntity)];
        }
    }
    return nil;
}

- (id)objectInTopLevelHyperScriptableEntitiesAtIndex:(NSUInteger)aIndex
{
    return [[self stack] queryHyperInterface:@protocol(HSScriptableEntity)];
}

- (NSUInteger)countOfTopLevelHyperScriptableEntities
{
    return (unsigned int)([[self stack] queryHyperInterface:@protocol(HSScriptableEntity)] != nil);
}

- (void)performActionThatRequiresSwitchToEditMode:(SEL)aMode sender:(id)aSender
{
    id target;
    if ([[self mainWindowController] respondsToSelector:aMode]) {
        target = [self mainWindowController];
    } else {
        target = [self respondsToSelector:aMode] ? self : nil;
    }
    BOOL conditional = NO;
    if ([target respondsToSelector:@selector(actionRequiresConditionalPreprocessingBeforeSwitchToEditMode:)]) {
        conditional = ![target actionRequiresConditionalPreprocessingBeforeSwitchToEditMode:aMode];
    }
    if ([target respondsToSelector:@selector(actionShouldWaitForFinishingSwitchToEditModeBeforeExecution:)] && [target actionShouldWaitForFinishingSwitchToEditModeBeforeExecution:aMode]) {
        id invocation = [self addActionToPerformAfterSwitchToEditMode:aMode sender:aSender handler:target];
        if ([self shouldHandleActionThatRequiresImmediateSwitchToEditMode]) {
            return;
        }
        [self removeDelayedInvocationIfExists:invocation];
        return;
    }
    if (!((conditional && [self shouldHandleActionThatRequiresImmediateSwitchToEditMode]) || [self shouldHandleActionThatRequiresConditionalSwitchToEditMode])) {
        return;
    }
    [target performSelector:aMode withObject:aSender];
}

- (void)didFinishSwitchToEditMode
{
    [[self stack] restoreObjectsVisibility];
    [[self stack] dropMovieObjectsCurrentTime];
    [[self stack] discardTemporaryChildrenOrder];
    [self flushActionsAfterSwitchToEditMode];
}

- (void)flushActionsAfterSwitchToEditMode
{
    if ([_invocationsToPerformAfterSwitchToEditMode count] != 0) {
        NSArray *invocations = [NSArray arrayWithArray:_invocationsToPerformAfterSwitchToEditMode];
        [_invocationsToPerformAfterSwitchToEditMode removeAllObjects];
        NSEnumerator *enumerator = [invocations objectEnumerator];
        NSInvocation *invocation;
        while ((invocation = [enumerator nextObject]) != nil) {
            id target = [invocation target];
            if (target == nil) {
                target = self;
            }
            [invocation invokeWithTarget:target];
        }
    }
}

- (id)addActionToPerformAfterSwitchToEditMode:(SEL)aMode sender:(id)aSender handler:(id)aHandler
{
    id sender = aSender;
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[aHandler methodSignatureForSelector:aMode]];
    [invocation setSelector:aMode];
    if (self != aHandler) {
        [invocation setTarget:aHandler];
    }
    [invocation setArgument:&sender atIndex:2];
    [invocation retainArguments];
    if (_invocationsToPerformAfterSwitchToEditMode == nil) {
        _invocationsToPerformAfterSwitchToEditMode = [NSMutableArray new];
    }
    [_invocationsToPerformAfterSwitchToEditMode addObject:invocation];
    return invocation;
}

- (void)removeDelayedInvocationIfExists:(id)aExists
{
    NSUInteger pvVar1;

    if (_invocationsToPerformAfterSwitchToEditMode != nil) {
        pvVar1 = [_invocationsToPerformAfterSwitchToEditMode indexOfObjectIdenticalTo:aExists];
        if (pvVar1 != NSNotFound) {
            [_invocationsToPerformAfterSwitchToEditMode removeObjectAtIndex:pvVar1];
        }
    }
}

- (BOOL)actionShouldWaitForFinishingSwitchToEditModeBeforeExecution:(SEL)aExecution
{
    return @selector(addReadyMadeCards:) == aExecution;
}

- (BOOL)actionRequiresConditionalPreprocessingBeforeSwitchToEditMode:(SEL)aMode
{
    if (@selector(addGraphic:) != aMode) {
        return @selector(addGraphicObject:) == aMode;
    }
    return YES;
}

- (BOOL)validateUserInterfaceItemThatRequiresTogglePlayEditModes:(id)aModes
{
    if (NO || [self isInStoryboardMode] || [self isInPurePlayerMode] || ![self canTogglePlayEdit]) {
        return NO;
    }
    return ![self isInHyperCastingMode];
}

- (BOOL)validateUserInterfaceItemThatRequiresSwitchToEditMode:(id)aMode
{
    if ([[self mainWindowController] respondsToSelector:[aMode action]]) {
        return [[self mainWindowController] validateUserInterfaceItem:aMode];
    }
    if ([self respondsToSelector:[aMode action]]) {
        return [self validateUserInterfaceItem:aMode];
    }
    return NO;
}

- (BOOL)validateUserInterfaceItem:(id)aItem
{
    BOOL ok = [super validateUserInterfaceItem:aItem];
    SEL action = [aItem action];
    BOOL anim = NO;
    BOOL pure = [self isInPurePlayerMode];
    BOOL story = [self isInStoryboardMode];
    BOOL hyper = [self isInHyperCastingMode];
    BOOL pres = [self isInPresentationMode];
    BOOL ipad = NO;
    id cardView;
    id navigationOperation;
    NSImage *image;
    if (action == @selector(togglePresentationMode:) || action == @selector(switchToPresentationMode:)) {
        pure = (pres != 0);
        if ([aItem respondsToSelector:@selector(setState:)]) {
            [aItem setState:pure];
        }
        if (story || anim) {
            return NO;
        }
        goto togglePlayEditCheck;
    }
    if (action == @selector(togglePlayerMode:) || action == @selector(switchToPurePlayerMode:)) {
        if ([aItem respondsToSelector:@selector(setState:)]) {
            [aItem setState:pure != 0];
        }
        if (story || anim) {
            return NO;
        }
        goto togglePlayEditCheck;
    }
    if (action == @selector(saveDocument:) || action == @selector(saveDocumentAs:) || action == @selector(optimizeAndSaveAs:)) {
        if (anim || [self isWritingDisabled] || ipad || hyper) {
            return NO;
        }
        goto chain;
    }
    if (action == @selector(revertDocumentToSaved:)) {
        cardView = [[self currentWindowController] cardView];
        BOOL occupied = [cardView respondsToSelector:@selector(isOccupiedByTool)] ? [cardView isOccupiedByTool] : NO;
        if (pure || !ok || occupied || story || ![self isDocumentEdited] || ![[self fileType] isEqualToString:@"HSDocumentType"] || pres || hyper) {
            return NO;
        }
        goto chain;
    }
    if (action == @selector(exportTo:) || action == @selector(exportToHTML5:) || action == @selector(exportForiBooksAuthor:)) {
        if ([self isWritingDisabled] || hyper || anim) {
            return NO;
        }
        ok = ![[self exportManager] isExporting];
        goto joined;
    }
    if (action == @selector(togglePlayEdit:)) {
        ok = [self validateUserInterfaceItemThatRequiresTogglePlayEditModes:aItem];
        BOOL playerState = [self isInPlayerMode] || ((story || anim) && [[self modeHistory] lastObject] == _playerInEditorWindowController);
        if ([aItem respondsToSelector:@selector(setState:)]) {
            [aItem setState:playerState];
        }
        if (pure) {
            return NO;
        }
        goto joined;
    }
    if (action == @selector(switchToStandardMode:)) {
        ok = !(NO || [self isInHyperCastingMode]);
        BOOL standard = [self isInStandardMode];
        if ([aItem respondsToSelector:@selector(setState:)]) {
            [aItem setState:standard != 0];
        }
        goto joined;
    }
    if (action == @selector(toggleStoryboard:) || action == @selector(enterStoryboardMode:)) {
        if (!(pure || pres) && !anim && ok && ![[self modeSwitcher] switching] && [[self navigationController] currentNavigationOperation] == nil && !(ipad || hyper)) {
            ok = YES;
        } else {
            ok = NO;
        }
        if ([aItem isKindOfClass:[NSMenuItem class]]) {
            [aItem setState:story != 0];
        }
        if ([aItem isKindOfClass:[HSButton class]]) {
            [aItem setImage:[NSImage imageNamed:@"Storyboard"]];
        } else if ([aItem isKindOfClass:[NSButton class]]) {
            [aItem setImage:[NSImage imageNamed:story ? @"StoryBoard_On" : @"StoryBoardIcon"]];
        }
        goto joined;
    }
    if (action == @selector(toggleCardIndex:)) {
        if (!(pure || story || pres) && !anim && ok && ![[self modeSwitcher] switching] && [[self navigationController] currentNavigationOperation] == nil && !hyper) {
            ok = YES;
        } else {
            ok = NO;
        }
        if ([aItem isKindOfClass:[NSMenuItem class]]) {
            [aItem setState:[[self stackView] isStripVisible] != 0];
        }
        if ([aItem isKindOfClass:[NSButton class]]) {
            [aItem setImage:[NSImage imageNamed:([[self stackView] isStripVisible] && ok) ? @"CardIndex_On" : @"CardIndex"]];
        }
        goto joined;
    }
    if (action == @selector(toggleBottomToolbar:)) {
        if ([aItem respondsToSelector:@selector(setState:)]) {
            [aItem setState:[[self currentWindowController] isBottomToolbarVisible] != 0];
        }
        ok = !(pure || story || hyper || pres);
        goto joined;
    }
    if (action == @selector(newCard:) || action == @selector(goToCard:)) {
        if (!(anim || pure) && [[self editorCardView] isEditable] && [[self navigationController] currentNavigationOperation] == nil && !hyper) {
            ok = YES;
        } else {
            ok = NO;
        }
        if (action == @selector(newCard:)) {
            ok = ok && !pres;
        }
        goto joined;
    }
    if (action == @selector(removeCurrentCard:)) {
        if (anim || pure || hyper) {
            return NO;
        }
        id cards = [[[[self selectionController] selectedHyperObject] allHyperInterfaces] queryHyperInterfaceForAllObjects:@protocol(HSCardAttributes)];
        if ([cards countOfAllHyperInterfaces] == 0 && [self activeCard] == nil) {
            return NO;
        }
        if ([[self navigationController] currentNavigationOperation] != nil) {
            return NO;
        }
        goto chain;
    }
    if (action == @selector(goBack:) || action == @selector(goForward:) || action == @selector(goToNextCard:) || action == @selector(goToPreviousCard:) || action == @selector(goToNextCardWithoutLeaveActions:) || action == @selector(goToPreviousCardWithoutLeaveActions:) || action == @selector(goToLastCardWithoutLeaveActions:) || action == @selector(goToFirstCardWithoutLeaveActions:) || action == @selector(goBackWithoutLeaveActions:) || action == @selector(goForwardWithoutLeaveActions:) || action == @selector(goToSpecificCardWithoutLeaveActions:) || action == @selector(goToHomeWithoutLeaveActions:) || action == @selector(goToLastCard:) || action == @selector(goToFirstCard:) || action == @selector(goToSpecificCard:)) {
        if (!anim && ok && [self currentWindowController] != [self storyboardController]) {
            ok = YES;
        } else {
            ok = NO;
        }
        if (![[self navigationController] respondsToSelector:action]) {
            goto joined;
        }
        if (!ok) {
            return NO;
        }
        ok = [[self navigationController] validateUserInterfaceItem:aItem];
        goto joined;
    }
    if (action == @selector(testStack:) || action == @selector(testCard:)) {
        if (!anim && ok && !(story || hyper)) {
            ok = YES;
        } else {
            ok = NO;
        }
        cardView = [[self currentWindowController] cardView];
        if ([cardView respondsToSelector:@selector(isOccupiedByTool)]) {
            if (!ok) {
                return NO;
            }
            if ([cardView isOccupiedByTool]) {
                return NO;
            }
            ok = YES;
        } else if (!ok) {
            goto joined;
        }
        if (![aItem isKindOfClass:[NSButtonCell class]]) {
            goto joined;
        }
        image = [self internalPlayerActive] ? [self browseModeSelectedImage] : [self browseModeNormalImage];
        [aItem setImage:image];
        goto joined;
    }
    if (action == @selector(editStack:)) {
        if (!pure && ok && !(story || anim || hyper)) {
            ok = YES;
        } else {
            ok = NO;
        }
        BOOL notBrowsing;
        if ([self internalPlayerActive]) {
            notBrowsing = YES;
        } else {
            notBrowsing = [[HSToolManager sharedToolManager] selectedToolTag] != 1;
        }
        if (!ok) {
            goto joined;
        }
        if ([aItem isKindOfClass:[NSButtonCell class]]) {
            image = notBrowsing ? [self editModeNormalImage] : [self editModeSelectedImage];
            [aItem setImage:image];
        }
        goto joined;
    }
    if (action == @selector(addReadyMadeCards:)) {
        if (pure || anim || hyper || pres || ipad || [[[self currentWindowController] cardView] isOccupiedByTool]) {
            ok = NO;
        }
        cardView = [[self currentWindowController] cardView];
        if (![cardView respondsToSelector:@selector(isOccupiedByTool)]) {
            goto joined;
        }
        if (!ok) {
            return NO;
        }
        if ([cardView isOccupiedByTool]) {
            return NO;
        }
        goto chain;
    }
    if (action == @selector(liveSlideShow:)) {
        BOOL valid = [self validateUserInterfaceItemThatRequiresTogglePlayEditModes:aItem];
        id playerController = [self playerInEditorWindowController];
        if (!valid) {
            return NO;
        }
        if (![playerController respondsToSelector:action]) {
            return NO;
        }
        ok = [playerController validateUserInterfaceItem:aItem];
        goto joined;
    }
    if (action == @selector(toggleIpadExportPreview:)) {
        if ([aItem respondsToSelector:@selector(setState:)]) {
            [aItem setState:ipad != 0];
        }
        if (pure || anim || story || hyper) {
            return NO;
        }
        if ([self isStackProtected]) {
            return NO;
        }
        goto chain;
    }
    goto joined;
togglePlayEditCheck:
    if (!pure && ![self canTogglePlayEdit]) {
        return NO;
    }
    if (hyper) {
        return NO;
    }
    if (ipad || [self isStackProtected]) {
        return NO;
    }
    goto chain;
joined:
    if (!ok) {
        return NO;
    }
chain:
    if (![self validateUserInterfaceItemIfInLockStackMode:aItem]) {
        return NO;
    }
    if (![self validateUserInterfaceItemIfInOccupiedByToolMode:aItem]) {
        return NO;
    }
    return [self validateUserInterfaceItemIfInModalSession:aItem] != 0;
}

- (BOOL)validateUserInterfaceItemIfInModalSession:(id)aSession
{
    SEL action = [aSession action];
    if (![self isModalSessionPresent]) {
        return YES;
    }
    if (action == @selector(togglePresentationMode:) ||
        action == @selector(togglePlayerMode:) ||
        action == @selector(toggleStoryboard:) ||
        action == @selector(enterStoryboardMode:) ||
        action == @selector(newCard:) ||
        action == @selector(removeCurrentCard:) ||
        action == @selector(goToCard:) ||
        action == @selector(goBack:) ||
        action == @selector(goForward:) ||
        action == @selector(goToNextCard:) ||
        action == @selector(goToPreviousCard:) ||
        action == @selector(goToNextCardWithoutLeaveActions:) ||
        action == @selector(goToPreviousCardWithoutLeaveActions:) ||
        action == @selector(goToLastCardWithoutLeaveActions:) ||
        action == @selector(goToFirstCardWithoutLeaveActions:) ||
        action == @selector(goBackWithoutLeaveActions:) ||
        action == @selector(goForwardWithoutLeaveActions:) ||
        action == @selector(goToSpecificCardWithoutLeaveActions:) ||
        action == @selector(goToHomeWithoutLeaveActions:) ||
        action == @selector(goToLastCard:) ||
        action == @selector(goToFirstCard:) ||
        action == @selector(goToSpecificCard:) ||
        action == @selector(testStack:) ||
        action == @selector(testCard:) ||
        action == @selector(editStack:) ||
        action == @selector(goToHome:) ||
        action == @selector(addReadyMadeCards:) ||
        action == @selector(togglePlayEdit:) ||
        action == @selector(revertDocumentToSaved:) ||
        action == @selector(saveDocument:) ||
        action == @selector(saveDocumentAs:) ||
        action == @selector(optimizeAndSaveAs:) ||
        action == @selector(exportTo:) ||
        action == @selector(exportToHTML5:) ||
        action == @selector(exportForiBooksAuthor:) ||
        action == @selector(printCard:) ||
        action == @selector(printDocument:) ||
        action == @selector(printText:) ||
        action == @selector(switchToStandardMode:) ||
        action == @selector(toggleCardIndex:) ||
        action == @selector(toggleBottomToolbar:)) {
        return NO;
    }
    return action != @selector(toggleIpadExportPreview:);
}

- (BOOL)validateUserInterfaceItemIfInLockStackMode:(id)aMode
{
    SEL action = [aMode action];
    if (![self isStackProtected]) {
        return YES;
    }
    if (action == @selector(toggleStoryboard:) ||
        action == @selector(enterStoryboardMode:) ||
        action == @selector(sendBackward:) ||
        action == @selector(sendToBack:) ||
        action == @selector(bringForward:) ||
        action == @selector(bringToFront:) ||
        action == @selector(removeCurrentObject:) ||
        action == @selector(editStack:) ||
        action == @selector(removeCurrentCard:) ||
        action == @selector(newCard:) ||
        action == @selector(testStack:) ||
        action == @selector(testCard:) ||
        action == @selector(resizeToFillCard:) ||
        action == @selector(togglePlayEdit:) ||
        action == @selector(addReadyMadeCards:) ||
        action == @selector(switchToStandardMode:) ||
        action == @selector(resizeToFitCard:)) {
        return NO;
    }
    return action != @selector(toggleIpadExportPreview:);
}

- (BOOL)validateUserInterfaceItemIfInOccupiedByToolMode:(id)aMode
{
    if ([[self actionExecutionContext] waitingForMouseDownEvent]) {
        return NO;
    }
    SEL action = [aMode action];
    if (![[self editorCardView] isOccupiedByTool] && ![self isDocumentClosing]) {
        return YES;
    }
    if (action == @selector(toggleStoryboard:) ||
            action == @selector(enterStoryboardMode:) ||
            action == @selector(goToSpecificCard:) ||
            action == @selector(goBack:) ||
            action == @selector(goForward:) ||
            action == @selector(goToNextCard:) ||
            action == @selector(goToPreviousCard:) ||
            action == @selector(goToNextCardWithoutLeaveActions:) ||
            action == @selector(goToPreviousCardWithoutLeaveActions:) ||
            action == @selector(goToLastCardWithoutLeaveActions:) ||
            action == @selector(goToFirstCardWithoutLeaveActions:) ||
            action == @selector(goBackWithoutLeaveActions:) ||
            action == @selector(goForwardWithoutLeaveActions:) ||
            action == @selector(goToSpecificCardWithoutLeaveActions:) ||
            action == @selector(goToLastCard:) ||
            action == @selector(goToFirstCard:) ||
            action == @selector(goToHome:) ||
            action == @selector(goToHomeWithoutLeaveActions:) ||
            action == @selector(sendBackward:) ||
            action == @selector(sendToBack:) ||
            action == @selector(bringForward:) ||
            action == @selector(bringToFront:) ||
            action == @selector(removeCurrentObject:) ||
            action == @selector(editStack:) ||
            action == @selector(removeCurrentCard:) ||
            action == @selector(newCard:) ||
            action == @selector(togglePlayerMode:) ||
            action == @selector(togglePresentationMode:) ||
            action == @selector(switchToPresentationMode:) ||
            action == @selector(switchToPurePlayerMode:)) {
        return NO;
    }
    return action != @selector(toggleIpadExportPreview:);
}

- (void)setHyperRemovedItemsPaths:(id)aPaths
{
    if (_hyperRemovedItemsPaths != aPaths) {
        [_hyperRemovedItemsPaths release];
        _hyperRemovedItemsPaths = [aPaths retain];
    }
}

- (id)hyperRemovedItemsPaths
{
    return _hyperRemovedItemsPaths;
}

- (void)setHyperSaveOperation:(NSUInteger)aOperation
{
    _hyperSaveOperation = (short)aOperation;
}

- (NSUInteger)hyperSaveOperation
{
    return _hyperSaveOperation;
}

- (void)setHyperClient:(BOOL)aClient
{
    if (_isHyperClient != aClient) {
        _isHyperClient = aClient;
    }
}

- (BOOL)isHyperClient
{
    return _isHyperClient;
}

- (void)setHyperServer:(BOOL)aServer
{
    if (_isHyperServer != aServer) {
        _isHyperServer = aServer;
    }
}

- (BOOL)isHyperServer
{
    return _isHyperServer;
}

- (void)setHyperCollaborative:(BOOL)aCollaborative
{
    _isHyperCollaborative = aCollaborative;
}

- (BOOL)isHyperCollaborative
{
    return _isHyperCollaborative;
}

- (void)setReceived:(BOOL)aReceived
{
    if (_isReceived != aReceived) {
        _isReceived = aReceived;
    }
}

- (BOOL)isReceived
{
    return _isReceived;
}

- (void)setCommitLogMessage:(id)aMessage
{
    if (_commitLogMessage != aMessage) {
        [_commitLogMessage release];
        _commitLogMessage = [aMessage retain];
    }
}

- (id)commitLogMessage
{
    return _commitLogMessage;
}

- (void)setDocumentSharingController:(id)aController
{
    if (_documentSharingController != aController) {
        [_documentSharingController release];
        _documentSharingController = [aController retain];
    }
}

- (id)documentSharingController
{
    return _documentSharingController;
}

- (void)textViewWillBeginScrolling:(id)aScrolling
{
    if ([self isInPlayerMode]) {
        [[self textViewsToResetScrollPosition] addObject:[aScrolling object]];
    }
}

- (id)textViewsToResetScrollPosition
{
    id pvVar1;

    pvVar1 = _textViewsToResetScrollPosition;
    if (pvVar1 == nil) {
        pvVar1 = [NSMutableSet new];
        _textViewsToResetScrollPosition = pvVar1;
    }
    return pvVar1;
}

- (void)backgroundDidChange:(id)aChange
{
    NSEnumerator *enumerator = [[self windowControllers] objectEnumerator];
    id controller;
    while ((controller = [enumerator nextObject]) != nil) {
        if ([controller respondsToSelector:@selector(documentBackgroundPatternDidChange:)]) {
            [controller documentBackgroundPatternDidChange:self];
        }
    }
}

- (id)windowForSheet
{
    return [[self modeSwitcher] mainWindow];
}

- (id)stackView
{
    return [[self editorWindowController] stackView];
}

- (void)cardView:(id)aView inWindowController:(id)aController didSetCard:(id)aCard
{
    if ([self cardViewForNavigation] == aView) {
        [[self mainWindowController] activeCardViewDidSetCard:aCard];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"HSObjectListDataProviderDidChangeTopLevelParentNotification" object:self];
    }
}

- (id)cardViewForNavigation
{
    id cardView = nil;
    id activeController = [[self modeSwitcher] activeModeController];
    if ([activeController respondsToSelector:@selector(cardView)]) {
        cardView = [[[self modeSwitcher] activeModeController] cardView];
    }
    if (cardView == nil) {
        NSEnumerator *enumerator = [[self modeHistory] objectEnumerator];
        id controller;
        while ((controller = [enumerator nextObject]) != nil && cardView == nil) {
            if ([controller respondsToSelector:@selector(cardView)]) {
                cardView = [controller cardView];
            }
        }
    }
    if (cardView == nil) {
        cardView = [[self mainWindowController] cardView];
    }
    return cardView;
}

- (id)currentCard
{
    id card = nil;
    id activeController = [[self modeSwitcher] activeModeController];
    if ([activeController respondsToSelector:@selector(cardView)]) {
        card = [[activeController cardView] card];
    }
    if (card == nil) {
        if ([[self modeSwitcher] switching]) {
            id previousController = [[self modeSwitcher] previousModeController];
            if ([previousController respondsToSelector:@selector(cardView)]) {
                card = [[previousController cardView] card];
            }
        }
    }
    if (card == nil) {
        card = [[[self mainWindowController] cardView] card];
    }
    return card;
}

- (id)cardView
{
    id activeController = [[self modeSwitcher] activeModeController];
    id cardView = nil;
    if ([activeController respondsToSelector:@selector(cardView)]) {
        cardView = [activeController cardView];
    }
    if (cardView == nil) {
        id previousController = [_modeSwitcher previousModeController];
        if ([previousController respondsToSelector:@selector(cardView)]) {
            cardView = [previousController cardView];
        }
    }
    if (cardView == nil) {
        cardView = [[self mainWindowController] cardView];
    }
    return cardView;
}

- (Class)navigationControllerClass
{
    return [[self currentWindowController] navigationControllerClass];
}

- (void)setOpenWarning:(id)aWarning
{
    if (_openWarning != aWarning) {
        [_openWarning release];
        _openWarning = [aWarning retain];
    }
}

- (id)openWarning
{
    return _openWarning;
}

- (id)editModeNormalImage
{
    if (sDAT_00342a50 == nil) {
        sDAT_00342a50 = [[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForImageResource:@"Edit_Mode_Normal"]];
    }
    return sDAT_00342a50;
}

- (id)editModeSelectedImage
{
    if (sDAT_00342a4c == nil) {
        sDAT_00342a4c = [[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForImageResource:@"Edit_Mode_Selected"]];
    }
    return sDAT_00342a4c;
}

- (id)browseModeSelectedImage
{
    if (sDAT_00342a48 == nil) {
        sDAT_00342a48 = [[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForImageResource:@"Browse_Mode_Selected"]];
    }
    return sDAT_00342a48;
}

- (id)browseModeNormalImage
{
    if (sDAT_00342a44 == nil) {
        sDAT_00342a44 = [[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForImageResource:@"Browse_Mode_Normal"]];
    }
    return sDAT_00342a44;
}

- (BOOL)hasUnautosavedChanges
{
    unsigned char bVar1;

    if (![super hasUnautosavedChanges]) {
        bVar1 = _wasOptimizedAndNotSaved & 1;
    }
    else {
        bVar1 = 1;
    }
    return bVar1;
}

- (BOOL)isDocumentEdited
{
    BOOL bVar3;
    BOOL pvVar1_2;

    id assistant = [HSObjectAssistantController sharedAssistantController];
    BOOL unapplied = [assistant hasCurrentAssistantPaneUnappliedChanges];
    if (unapplied)
        [assistant applyChangesInCurrentAssistantPaneIfNeeded];
    pvVar1_2 = [assistant isRecordingSound];
    if (![super isDocumentEdited]) {
        bVar3 = (_wasOptimizedAndNotSaved & 1) != 0 || unapplied || pvVar1_2;
    }
    else {
        bVar3 = YES;
    }
    return bVar3;
}

- (id)createDefaultStack
{
    id self_00;

    self_00 = [super createDefaultStack];
    [self_00 setBackgroundGraphics:[[HSUI sharedUI] backgroundGraphics]];
    return self_00;
}

- (void)showWindows
{
    id controller = [HSEditorController sharedDocumentController];
    if ([controller replacingDocument]) {
        return;
    }
    if ([self isStackProtected]) {
        [self enterPurePlayerModeWithAnimation:NO];
    } else if (![self isTutorialStack] && ([controller isDuplicationInProgress] || [self isNewAndNotChanged] || [controller shouldBeDocumentOpenedInEditorMode])) {
        [controller setDocumentInEditor:YES];
        [[self stackSelectionHolder] makeCurrent];
    } else {
        [self testCardWithUID:[[self currentCard] hyperUID] animate:NO];
    }
    [super showWindows];
}

- (void)saveDocumentWithDelegate:(id)aDelegate didSaveSelector:(SEL)aSelector contextInfo:(void *)aInfo
{
    [NSApp sendAction:@selector(finalize:) to:0 from:self];
    [super saveDocumentWithDelegate:aDelegate didSaveSelector:aSelector contextInfo:aInfo];
}

- (void)autosaveDocumentWithDelegate:(id)aDelegate didAutosaveSelector:(SEL)aSelector contextInfo:(void *)aInfo
{
    if ([NSView BT_mouseTrackingView] == nil) {
        if (![self isInHyperCastingMode]) {
            if (!NO) {
                _autosaveUndoManager = [[NSUndoManager alloc] init];
                [NSApp sendAction:@selector(stamp:) to:0 from:self];
                [super autosaveDocumentWithDelegate:aDelegate didAutosaveSelector:aSelector contextInfo:aInfo];
                [_autosaveUndoManager undo];
                [_autosaveUndoManager release];
                _autosaveUndoManager = nil;
            }
        }
    }
}

- (BOOL)isAutosaving
{
    return _autosaveUndoManager != nil;
}

- (void)optimizeAndSaveAsPanelDidEnd:(id)aEnd returnCode:(NSInteger)aCode contextInfo:(void *)aInfo
{
    [aEnd orderOut:self];
    if (aCode == 1) {
        [self setShouldStoreCardPreviewImages:NO];
        HSStackOptimizer *optimizer = [HSStackOptimizer new];
        [optimizer optimizeStack:[self stack]];
        _wasOptimizedAndNotSaved = 1;
        [[self undoManager] removeAllActions];
        [self updateChangeCount:2];
        [self saveToURL:[aEnd URL] ofType:@"HSDocumentType" forSaveOperation:1 delegate:self didSaveSelector:@selector(optimizedDocument:didSave:contextInfo:) contextInfo:NULL];
        [[HSPathsProvider sharedPathsProvider] setHyperStudioDocumentsFolder:[[aEnd directoryURL] path]];
        [optimizer postprocessAfterOptimization];
        [optimizer release];
    }
}

- (void)optimizedDocument:(id)aDocument didSave:(BOOL)aSave contextInfo:(void *)aInfo
{
    if (aSave) {
        _wasOptimizedAndNotSaved = 0;
    }
    [self setShouldStoreCardPreviewImages:YES];
}

- (id)currentWindowController
{
    return [[self modeSwitcher] activeModeController];
}

- (BOOL)isInHyperCastingMode
{
    BOOL bVar2;

    if (_modeSwitcher == nil) {
        bVar2 = NO;
    }
    else {
        bVar2 = [self currentWindowController] == _hyperCastingWindowController;
    }
    return bVar2;
}

- (BOOL)isInPurePlayerMode
{
    BOOL bVar2;

    if (_modeSwitcher == nil) {
        bVar2 = NO;
    }
    else {
        bVar2 = [self currentWindowController] == _purePlayerWindowController;
    }
    return bVar2;
}

- (BOOL)isInStoryboardMode
{
    BOOL bVar2;

    if (_modeSwitcher == nil) {
        bVar2 = NO;
    }
    else {
        bVar2 = [self currentWindowController] == _storyboardController;
    }
    return bVar2;
}

- (id)playerInEditorWindowController
{
    id pvVar1;
    id pvVar1_2;

    pvVar1 = _playerInEditorWindowController;
    if (pvVar1 == nil) {
        pvVar1_2 = [HSDependentPlayerWindowController new];
        _playerInEditorWindowController = pvVar1_2;
        [self addWindowController:pvVar1_2];
        pvVar1 = _playerInEditorWindowController;
    }
    return pvVar1;
}

- (Class)mainWindowControllerClass
{
    return [HSEditorWindowController class];
}

- (void)setStack:(id)aStack notify:(BOOL)aNotify clearChanges:(BOOL)aChanges
{
    if (_stack != aStack) {
        [_stack removeObserver:self selector:@selector(textViewWillBeginScrolling:) ofChanges:0x40 ofAttribute:@protocol(HSSystemTextViewHorizontalScrollPostionAttribute) ofChildrenInDepthRange:NSMakeRange(0, 2)];
        [_stack removeObserver:self selector:@selector(textViewWillBeginScrolling:) ofChanges:0x40 ofAttribute:@protocol(HSSystemTextViewVerticalScrollPositionAttribute) ofChildrenInDepthRange:NSMakeRange(0, 2)];
        [super setStack:aStack notify:aNotify clearChanges:aChanges];
        [_stack addObserver:self selector:@selector(textViewWillBeginScrolling:) ofChanges:0x40 ofAttribute:@protocol(HSSystemTextViewHorizontalScrollPostionAttribute) ofChildrenInDepthRange:NSMakeRange(0, 2) withPriority:0.5];
        [_stack addObserver:self selector:@selector(textViewWillBeginScrolling:) ofChanges:0x40 ofAttribute:@protocol(HSSystemTextViewVerticalScrollPositionAttribute) ofChildrenInDepthRange:NSMakeRange(0, 2) withPriority:0.5];
    }
}

- (void)destoyModel
{
    [_stack removeObserver:self selector:@selector(textViewWillBeginScrolling:) ofChanges:0x40 ofAttribute:@protocol(HSSystemTextViewHorizontalScrollPostionAttribute) ofChildrenInDepthRange:NSMakeRange(0, 2)];
    [_stack removeObserver:self selector:@selector(textViewWillBeginScrolling:) ofChanges:0x40 ofAttribute:@protocol(HSSystemTextViewVerticalScrollPositionAttribute) ofChildrenInDepthRange:NSMakeRange(0, 2)];
    [super destoyModel];
}

- (BOOL)_shouldShowAutosaveButtonForWindow:(id)aWindow
{
    if ([self isTutorialStack]) {
        return NO;
    }
    return [super _shouldShowAutosaveButtonForWindow:aWindow];
}

- (id)animatingWindow
{
    if (_animatingWindow == nil) {
        _animatingWindow = [[NSWindow alloc] initWithContentRect:NSZeroRect styleMask:0 backing:NSBackingStoreBuffered defer:NO];
        [_animatingWindow useOptimizedDrawing:YES];
        [_animatingWindow setOpaque:NO];
        [_animatingWindow setReleasedWhenClosed:NO];
        [_animatingWindow setBackgroundColor:[NSColor clearColor]];
    }
    return _animatingWindow;
}

- (void)applicationWillBecomeActive:(id)aActive
{
    if (![[self windowForSheet] isMiniaturized]) {
        [[self windowForSheet] orderFront:nil];
        [[self windowForSheet] setLevel:CGWindowLevelForKey(kCGFloatingWindowLevelKey)];
    }
}

- (void)applicationWillResignActive:(id)aActive
{
    if (![[self windowForSheet] isMiniaturized]) {
        [[self windowForSheet] setLevel:CGWindowLevelForKey(kCGNormalWindowLevelKey)];
        [[self windowForSheet] orderBack:nil];
    }
}

- (void)autosaveWithImplicitCancellability:(BOOL)aCancellability completionHandler:(id)aHandler
{
    if (!aCancellability) {
        [[self currentWindowController] saveEditingState];
    }
    [super autosaveWithImplicitCancellability:aCancellability completionHandler:aHandler];
}

- (void)beginAnimatingEnteringInPresentationMode
{
    NSWindow *window = [self animatingWindow];
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:0.8];
    [[NSAnimationContext currentContext] setCompletionHandler:^{
        [window close];
        [self finalizeSwitchingPresentationMode];
    }];
    [[window animator] setAlphaValue:0];
    [NSAnimationContext endGrouping];
}

- (void)beginAnimatingExitingFromPresentationMode
{
    NSWindow *window = [self animatingWindow];
    NSWindow *editorWindow = [[self currentWindowController] window];
    [editorWindow setAlphaValue:0.6];
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:1.0];
    [[NSAnimationContext currentContext] setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    [[NSAnimationContext currentContext] setCompletionHandler:^{
        [window close];
        [[self mainWindowController] restoreFloatingPalettes];
        [self finalizeSwitchingPresentationMode];
    }];
    [[window animator] setAlphaValue:0];
    [[editorWindow animator] setAlphaValue:1];
    [NSAnimationContext endGrouping];
}

- (void)beginEnteringInPresentationMode
{
    if ([self isPresentationModeSwitching]) {
        return;
    }
    if ([self isInPurePlayerMode]) {
        [self exitPurePlayerModeWithAnimation:NO];
    }
    NSApplicationPresentationOptions options = [NSApp presentationOptions];
    _isInPresentationMode = YES;
    _wasInFullScreenBeforePresentationMode = (options & NSApplicationPresentationFullScreen) != 0;
    _isPresentationModeSwitching = YES;
    _willExitFullScreenWhilePresentationMode = NO;
    _didSwitchToPlayerInEditorWhileEnteringPresentationMode = NO;
    if (options & NSApplicationPresentationFullScreen) {
        [[self mainWindowController] hideFloatingPalettes];
        [self performSelector:@selector(enterPresentationMode) withObject:nil afterDelay:0.2];
    } else {
        [self enterPresentationMode];
    }
}

- (id)browseUndoManager
{
    if (_browseUndoManager == nil) {
        _browseUndoManager = [NSUndoManager new];
    }
    return _browseUndoManager;
}

- (void)clearBrowseUndoManagerIfNeeded
{
    if (_browseUndoManager != nil) {
        while ([_browseUndoManager canUndo]) {
            [_browseUndoManager undo];
        }
        [_browseUndoManager release];
        _browseUndoManager = nil;
    }
}

- (CGImageRef)createImageForAnimatingPresentationModeSwitching
{
    NSRect frame = [self currentWindowFrameForAnimatingPresentationModeSwitching];
    return CGDisplayCreateImageForRect(CGMainDisplayID(), NSRectToCGRect(frame));
}

- (NSRect)currentWindowFrameForAnimatingPresentationModeSwitching
{
    NSApplicationPresentationOptions options = [[NSApplication sharedApplication] presentationOptions];
    NSWindow *window = [[self currentWindowController] window];
    if (options & NSApplicationPresentationFullScreen) {
        return [[window screen] frame];
    }
    return [window frame];
}

- (BOOL)didSwitchToPlayerInEditorWhileEnteringPresentationMode
{
    return _didSwitchToPlayerInEditorWhileEnteringPresentationMode;
}

- (id)duplicateAndReturnError:(NSError **)aError
{
    id controller = [[self windowControllers] extraFirstObject];
    BOOL assigned = NO;
    if ([self isInPlayerMode] || [self isInStoryboardMode]) {
        if ([controller window] == nil) {
            [controller setWindow:[[self currentWindowController] window]];
            assigned = YES;
        }
    }
    HSEditorController *documentController = [HSEditorController sharedDocumentController];
    [documentController setDuplicationInProgress:YES];
    id result = [super duplicateAndReturnError:aError];
    [documentController setDuplicationInProgress:NO];
    if (assigned) {
        id window = [controller window];
        [controller setWindow:nil];
        [window setWindowController:[self currentWindowController]];
    }
    return result;
}

- (void)editWebIcon:(id)aIcon
{
    HSWebAppIconEditorDialogController *dialog = [[HSWebAppIconEditorDialogController new] autorelease];
    [dialog setCards:[[self stack] children]];
    if ([[NSApplication sharedApplication] runModalForWindow:[dialog window]] == NSModalResponseStop) {
        [[self stack] setWebAppIcon:[dialog croppedImageWithHorizontalSelection]];
    }
}

- (void)enterAppFullScreen_WindowDidEnterFullScreen:(id)aNotification
{
    id window = [aNotification object];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowDidEnterFullScreenNotification object:window];
    if (_selectorToPerformAfterWindowExitFullScreen != NULL) {
        [self performSelector:_selectorToPerformAfterWindowExitFullScreen withObject:nil];
    }
}

- (void)enterAppFullScreen_WindowWillEnterFullScreen:(id)aNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowWillEnterFullScreenNotification object:[aNotification object]];
    if ([self isInPresentationMode]) {
        [[self mainWindowController] hideAllPalettesAndToolbars];
    }
}

- (void)enterPresentationMode
{
    NSWindow *window = [[self currentWindowController] window];
    if (!_wasInFullScreenBeforePresentationMode) {
        [window disableFlushWindow];
    }
    BOOL internalPlayerActive = [self internalPlayerActive];
    _wasInEditorModeBeforePresentationMode = !internalPlayerActive;
    if (!internalPlayerActive) {
        [self synchronizePlayerInEditorCardViewWithEditorForPresentationModeAnimation];
        [self testCardWithUID:[[self currentCard] hyperUID] animate:NO];
    } else {
        [[[self playerInEditorWindowController] cardView] deactivateActiveTextField];
    }
    _didSwitchToPlayerInEditorWhileEnteringPresentationMode = YES;
    [[self playerInEditorWindowController] verifyCardViewZoomFactor];
    [[[self playerInEditorWindowController] cardView] setRoundsCardCorners:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(exitAppFullScreen_WindowWillExitFullScreen:) name:NSWindowWillExitFullScreenNotification object:window];
    if (!_wasInFullScreenBeforePresentationMode) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterAppFullScreen_WindowWillEnterFullScreen:) name:NSWindowWillEnterFullScreenNotification object:window];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterAppFullScreen_WindowDidEnterFullScreen:) name:NSWindowDidEnterFullScreenNotification object:window];
        _selectorToPerformAfterWindowExitFullScreen = @selector(finalizeSwitchingPresentationMode);
        [window toggleFullScreen:nil];
        [window enableFlushWindow];
    } else {
        [self prepareForAnimatingPresentationModeSwitching];
        [[self mainWindowController] hideFixedToolbars];
        [self performSelector:@selector(beginAnimatingEnteringInPresentationMode) withObject:nil afterDelay:0.2];
    }
}

- (void)exitAppFullScreenPerformSelectorAtDone:(SEL)aSelector
{
    if ([NSApp presentationOptions] & NSApplicationPresentationFullScreen) {
        NSWindow *window = [[self currentWindowController] window];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(exitAppFullScreen_WindowDidExitFullScreen:) name:NSWindowDidExitFullScreenNotification object:window];
        [window toggleFullScreen:nil];
        _selectorToPerformAfterWindowExitFullScreen = aSelector;
    }
}

- (void)exitAppFullScreen_WindowDidExitFullScreen:(id)aNotification
{
    id window = [aNotification object];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowDidExitFullScreenNotification object:window];
    if (_selectorToPerformAfterWindowExitFullScreen != NULL) {
        [self performSelector:_selectorToPerformAfterWindowExitFullScreen withObject:nil];
    }
}

- (void)exitAppFullScreen_WindowWillExitFullScreen:(id)aNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowWillExitFullScreenNotification object:[aNotification object]];
    if ([self isInPresentationMode] && ![self isPresentationModeSwitching]) {
        _willExitFullScreenWhilePresentationMode = YES;
        [self exitPresentationMode];
    }
}

- (void)exitPresentationMode
{
    if ([self isPresentationModeSwitching]) {
        return;
    }
    BOOL wasInFullScreen = _wasInFullScreenBeforePresentationMode;
    BOOL willExit = _willExitFullScreenWhilePresentationMode;
    _isInPresentationMode = NO;
    _isPresentationModeSwitching = YES;
    if (wasInFullScreen && !willExit) {
        [self performExitingFromPresentationMode];
    } else {
        NSWindow *window = [[self currentWindowController] window];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(exitAppFullScreen_WindowDidExitFullScreen:) name:NSWindowDidExitFullScreenNotification object:window];
        _selectorToPerformAfterWindowExitFullScreen = @selector(performExitingFromPresentationMode);
        if (!_willExitFullScreenWhilePresentationMode) {
            [window toggleFullScreen:nil];
        }
        [[self mainWindowController] restoreAllPalettesAndToolbars];
        [[self playerInEditorWindowController] verifyCardViewZoomFactor];
        if (_wasInEditorModeBeforePresentationMode) {
            [self synchronizePlayerInEditorCardViewWithEditorForPresentationModeAnimation];
        }
    }
    [[[self playerInEditorWindowController] cardView] setRoundsCardCorners:NO];
}

- (void)exportPanelControllerDidEnd:(id)aController forDocumentWithType:(id)aType
{
    NSError *error = nil;
    BOOL valid = [self panel:[aController window] validateFilename:[aController filename] error:&error];
    if (!valid && error != nil) {
        [self runInvalidExportFilenameAlertWithError:error andContextInfo:aType shouldComeback:YES];
        return;
    }
    [self setResourcesWrapper:nil];
    [[HSMediaValidator mediaValidatorForDocument:self] validateMedia];
    [HSMediaSaver saveMediaForDocument:self resourcesWrapper:[self resourcesWrapper]];
    [self reloadDocumentMedia];
    [[self editorCardView] saveEditingState];
    [[self exportManager] exportDocumentWithFileName:[aController filename] ofType:aType];
    [[HSPathsProvider sharedPathsProvider] setHyperStudioDocumentsExportFolder:[aController directory]];
}

- (void)exportPanelControllerDidEndWithoutComeback:(id)aController returnCode:(NSInteger)aCode contextInfo:(void *)aInfo
{
    if (aCode != 1) {
        return;
    }
    NSError *error = nil;
    BOOL valid = [self panel:[aController window] validateFilename:[aController filename] error:&error];
    if (!valid && error != nil) {
        [self runInvalidExportFilenameAlertWithError:error andContextInfo:aInfo shouldComeback:NO];
    } else {
        [self exportPanelControllerDidEnd:aController forDocumentWithType:(id)aInfo];
    }
}

- (void)exportToFTPServer:(id)aServer
{
    [self exportToDocumentWithType:@"HSFTPServerDocumentType" inPublishType:5 inFormat:0xb withRequiredFileType:@""];
}

- (void)exportToWebPage:(id)aPage
{
    [self runPublishComboDialogForExportFormat:9 didEndSelector:@selector(publishComboDialogDidEndWithoutComeBack:returnCode:)];
}

- (void)finalizeSwitchingPresentationMode
{
    _isPresentationModeSwitching = NO;
    if (![self isInPresentationMode] && _shouldEnterPurePlayerAfterExitPresentationMode) {
        [self togglePlayerMode:nil];
        _shouldEnterPurePlayerAfterExitPresentationMode = NO;
    }
    [[self playerInEditorWindowController] verifyCardViewZoomFactor];
}

- (void)finishPublishComboDialog:(id)aDialog returnCode:(BOOL)aCode showExportComboDialogIfNeeded:(BOOL)aShow
{
    [[aDialog window] orderOut:nil];
    if (aCode) {
        [self runExportSessionWithExportFormat:[aDialog exportFormat] publishType:[aDialog publishType]];
    } else if (aShow) {
        [self exportTo:nil];
    }
    [aDialog autorelease];
}

- (void)invalidExportFilenameAlertWithoutComebackDidEnd:(id)aAlert returnCode:(NSInteger)aCode contextInfo:(void *)aInfo
{
    [self runModalExportPanelWithDelegate:self didSaveSelector:@selector(exportPanelControllerDidEndWithoutComeback:returnCode:contextInfo:) contextInfo:aInfo];
}

- (BOOL)isAddingNewButtonInProcess
{
    return _addingNewButtonInProcess;
}

- (BOOL)isPaused
{
    return _isPaused;
}

- (BOOL)isPresentationModeSwitching
{
    return _isPresentationModeSwitching;
}

- (BOOL)isRecordingMovie
{
    return _isRecordingMovie;
}

- (BOOL)isRecordingSound
{
    return _isRecordingSound;
}

- (void)moveDocument:(id)aDocument
{
    NSString *path = [[self fileURL] path];
    if ([path length] != 0 && [path rangeOfString:[[NSBundle mainBundle] resourcePath]].length != 0) {
        HSExecutableResourceProvider *provider = [HSExecutableResourceProvider sharedInstance];
        NSString *message = [NSString stringWithFormat:[provider localizedStringForKey:@"HSAMoveStackMessageText" value:@"" table:@"Alerts"], [[self fileURL] lastPathComponent]];
        NSString *informative = [[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"HSAMoveStackInformativeText" value:@"" table:@"Alerts"];
        NSArray *options = [NSArray arrayWithObjects:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"Duplicate" value:@"" table:@"Alerts"], [[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"Cancel" value:@"" table:@"Alerts"], nil];
        NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:message, NSLocalizedDescriptionKey, informative, NSLocalizedRecoverySuggestionErrorKey, self, NSRecoveryAttempterErrorKey, options, NSLocalizedRecoveryOptionsErrorKey, nil];
        NSError *error = [HSError errorWithDomain:HSSpecificErrorDomain code:0x4e38 userInfo:userInfo];
        [NSApp presentError:error modalForWindow:[self windowForSheet] delegate:self didPresentSelector:NULL contextInfo:NULL];
        return;
    }
    [super moveDocument:aDocument];
}

- (BOOL)panel:(id)aPanel validateFilename:(id)aFilename error:(NSError **)aError
{
    HSExportManager *manager = [self exportManager];
    id controller = [manager exportPanelController];
    if (![controller isWindowLoaded]) {
        return YES;
    }
    if ([controller window] != aPanel) {
        return YES;
    }
    if (aFilename == nil) {
        return NO;
    }
    NSInteger format = [manager exportFormat];
    NSString *messageKey = nil;
    NSString *informativeKey = nil;
    if (format == 1) {
        NSCharacterSet *invalid = [NSCharacterSet characterSetWithCharactersInString:@"?;/"];
        if (invalid == nil) {
            return NO;
        }
        if ([aFilename rangeOfCharacterFromSet:invalid].location == NSNotFound) {
            return YES;
        }
        messageKey = @"HSInvalidWebExportPanelFilenameMessageText";
        informativeKey = @"HSInvalidWebExportPanelFilenameInformativeText";
    } else if (format == 10) {
        NSString *relative = [[NSURL fileURLWithPath:aFilename isDirectory:NO] relativeString];
        if (relative == nil) {
            return NO;
        }
        if ([relative isEqualToString:aFilename]) {
            return YES;
        }
        messageKey = @"HSInvalidIBAExportPanelFilenameMessageText";
        informativeKey = @"HSInvalidIBAExportPanelFilenameInformativeText";
    } else {
        return YES;
    }
    NSString *message = [NSString stringWithFormat:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:messageKey value:@"" table:@"Alerts"], aFilename];
    if (message != nil && aError != NULL) {
        NSString *informative = [[HSExecutableResourceProvider sharedInstance] localizedStringForKey:informativeKey value:@"" table:@"Alerts"];
        *aError = [NSError errorWithDomain:NSCocoaErrorDomain code:0x102 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:message, NSLocalizedDescriptionKey, informative, NSLocalizedRecoverySuggestionErrorKey, nil]];
    }
    return NO;
}

- (void)pause
{
    if (![[HSApplicationController sharedDocumentController] isPauseResumeEnabled] || [self isPaused]) {
        return;
    }
    _isPaused = YES;
    id playerView = [self playerView];
    if ([playerView isPictureShow]) {
        [playerView pausePictureShow];
    } else if ([playerView isSlideshow]) {
        [playerView pauseSlideshowIfNeeded];
    }
    [playerView pauseTransition];
    [[[self navigationController] presentationSync] pause];
    [[self actionExecutionContext] pauseSpeechRecognition];
}

- (void)performExitingFromPresentationMode
{
    if (_wasInFullScreenBeforePresentationMode && !_willExitFullScreenWhilePresentationMode) {
        [self prepareForAnimatingPresentationModeSwitching];
        [[self mainWindowController] restoreFixedToolbars];
        [[self playerInEditorWindowController] verifyCardViewZoomFactor];
    }
    if (_wasInEditorModeBeforePresentationMode) {
        if ([self isInPurePlayerMode]) {
            [self exitPurePlayerModeWithAnimation:NO];
        }
        [self switchToEditorWithToolTag:1];
    }
    [[[self currentWindowController] window] update];
    if (_wasInFullScreenBeforePresentationMode && !_willExitFullScreenWhilePresentationMode) {
        [self performSelector:@selector(beginAnimatingExitingFromPresentationMode) withObject:nil afterDelay:0.2];
    } else {
        [self finalizeSwitchingPresentationMode];
    }
}

- (void)prepareForAnimatingPresentationModeSwitching
{
    NSWindow *window = [[self currentWindowController] window];
    NSWindow *animatingWindow = [self animatingWindow];
    NSView *view = [self viewForAnimatingPresentationModeSwitching];
    [animatingWindow setFrame:[self currentWindowFrameForAnimatingPresentationModeSwitching] display:NO];
    [animatingWindow setContentView:view];
    [animatingWindow setAlphaValue:1];
    [window addChildWindow:animatingWindow ordered:NSWindowAbove];
    [animatingWindow orderFront:nil];
}

- (void)publishComboDialogDidEndWithComeBack:(id)aDialog returnCode:(NSInteger)aCode
{
    [self finishPublishComboDialog:aDialog returnCode:(char)aCode showExportComboDialogIfNeeded:YES];
}

- (void)publishComboDialogDidEndWithoutComeBack:(id)aDialog returnCode:(NSInteger)aCode
{
    [self finishPublishComboDialog:aDialog returnCode:(char)aCode showExportComboDialogIfNeeded:NO];
}

- (void)publishToDotMac:(id)aSender
{
    [self isWritingDisabled];
}

- (void)renameDocument:(id)aDocument
{
    NSString *path = [[self fileURL] path];
    if ([path length] != 0 && [path rangeOfString:[[NSBundle mainBundle] resourcePath]].length != 0) {
        HSExecutableResourceProvider *provider = [HSExecutableResourceProvider sharedInstance];
        NSString *message = [NSString stringWithFormat:[provider localizedStringForKey:@"HSARenameStackMessageText" value:@"" table:@"Alerts"], [[self fileURL] lastPathComponent]];
        NSString *informative = [[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"HSARenameStackInformativeText" value:@"" table:@"Alerts"];
        NSArray *options = [NSArray arrayWithObjects:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"Duplicate" value:@"" table:@"Alerts"], [[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"Cancel" value:@"" table:@"Alerts"], nil];
        NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:message, NSLocalizedDescriptionKey, informative, NSLocalizedRecoverySuggestionErrorKey, self, NSRecoveryAttempterErrorKey, options, NSLocalizedRecoveryOptionsErrorKey, nil];
        NSError *error = [HSError errorWithDomain:HSSpecificErrorDomain code:0x4e38 userInfo:userInfo];
        [NSApp presentError:error modalForWindow:[self windowForSheet] delegate:self didPresentSelector:NULL contextInfo:NULL];
        return;
    }
    [super renameDocument:aDocument];
}

- (void)resume
{
    if (![self isPaused]) {
        return;
    }
    _isPaused = NO;
    id playerView = [self playerView];
    if ([playerView isPictureShow]) {
        [playerView resumePictureShow];
    } else if ([playerView isSlideshow]) {
        [playerView resumeSlideshowIfNeeded];
    }
    [playerView resumeTransition];
    [[[self navigationController] presentationSync] resume];
    [[self actionExecutionContext] resumeSpeechRecognition];
}

- (void)runExportSessionWithExportFormat:(NSInteger)aFormat publishType:(NSInteger)aType
{
    HSExportManager *manager = [self exportManager];
    if ([manager isOpenExportSession]) {
        [manager closeExportSession];
    }
    [manager openExportSessionWithDocument:self];
    [manager setExportFormat:aFormat];
    [manager setPublishType:aType];
    NSString *documentType = nil;
    switch (aFormat) {
    case 1:
        documentType = @"HSWebDocumentType";
        break;
    case 2:
        documentType = @"HSMakeStackToGoDocumentType";
        break;
    case 3:
        documentType = @"HSImageSequenceDocumentType";
        break;
    case 4:
        documentType = @"HSQTMovieDocumentType";
        break;
    case 5:
        documentType = @"HSiPodDocumentType";
        break;
    case 6:
        documentType = @"HSiPhoneDocumentType";
        break;
    case 8:
    case 9:
        documentType = @"HSHTML5DocumentType";
        break;
    case 10:
        documentType = @"HSiBooksAuthorDocumentType";
        break;
    case 0xb:
        documentType = @"HSFTPServerDocumentType";
        break;
    }
    [self runModalExportPanelWithDelegate:self didSaveSelector:@selector(exportPanelControllerDidEnd:returnCode:contextInfo:) contextInfo:documentType];
}

- (void)runInvalidExportFilenameAlertWithError:(id)aError andContextInfo:(void *)aInfo shouldComeback:(BOOL)aComeback
{
    HSAlert *alert = [HSAlert new];
    [alert setAlertStyle:NSWarningAlertStyle];
    [alert setMessageText:[aError localizedDescription]];
    [alert setInformativeText:[aError localizedRecoverySuggestion]];
    SEL didEnd = aComeback ? @selector(invalidExportFilenameAlertDidEnd:returnCode:contextInfo:) : @selector(invalidExportFilenameAlertWithoutComebackDidEnd:returnCode:contextInfo:);
    [alert beginSheetModalForWindow:[self windowForSheet] modalDelegate:self didEndSelector:didEnd contextInfo:aInfo];
    [alert release];
}

- (void)runModalExportPanelWithDelegate:(id)aDelegate didSaveSelector:(SEL)aSelector contextInfo:(void *)aInfo
{
    id controller = [[self exportManager] exportPanelController];
    NSString *name = [[[self fileURL] lastPathComponent] stringByDeletingPathExtension];
    if (name == nil) {
        name = [self displayName];
    }
    name = [[self exportManager] escapeFileNameForExport:name];
    id directory = [[HSPathsProvider sharedPathsProvider] hyperStudioDocumentsExportFolder];
    [controller beginSheetForDirectory:directory file:name modalForWindow:[self windowForSheet] modalDelegate:aDelegate didEndSelector:aSelector contextInfo:aInfo];
}

- (void)runPublishComboDialogForExportFormat:(NSInteger)aFormat didEndSelector:(SEL)aSelector
{
    HSPublishComboDialog *dialog = [[HSPublishComboDialog alloc] initWithExportFormat:aFormat];
    [dialog runForWindow:[self windowForSheet] delegate:self didEndSelector:aSelector];
}

- (void)setAddingNewButtonInProcess:(BOOL)aProcess
{
    _addingNewButtonInProcess = aProcess;
}

- (void)setIsRecordingMovie:(BOOL)aMovie
{
    _isRecordingMovie = aMovie;
}

- (void)setIsRecordingSound:(BOOL)aSound
{
    _isRecordingSound = aSound;
}

- (BOOL)shouldSaveChangesMadeInBrowseMode
{
    return [[self stack] shouldSaveChangesMadeInBrowseMode];
}

- (void)slideShowAttributesWindowDidEnd:(id)aWindow returnedCode:(NSInteger)aCode
{
    id controller = [self playerInEditorWindowController];
    if (aCode == 1) {
        id attributes = [[[aWindow slideshowAttributes] retain] autorelease];
        if (attributes != nil) {
            [self testCardWithUID:[[self currentCard] hyperUID] animate:NO];
            [controller startSlideShowWithAttributes:attributes];
        }
    }
    [aWindow autorelease];
}

- (void)storeDocumentWindowState:(id)aState
{
    [[self editorWindowController] storeDocumentWindowState:aState];
    [_playerInEditorWindowController storeDocumentWindowState:aState];
    if ([self isInPresentationMode]) {
        [aState setObject:[NSNumber numberWithBool:_wasInEditorModeBeforePresentationMode] forKey:HSDocumentInEditModeKey];
    }
}

- (void)synchronizePlayerInEditorCardViewWithEditorForPresentationModeAnimation
{
    [[[self playerInEditorWindowController] cardView] setZoomFactor:[[[self editorWindowController] cardView] zoomFactor]];
}

- (void)togglePresentationModeButton:(id)aButton
{
    SEL action = @selector(togglePresentationMode:);
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"HSPresentationModeButtonSwitchesPlayerMode"]) {
        action = @selector(togglePlayerMode:);
    }
    [NSApp sendAction:action to:nil from:aButton];
}

- (id)viewForAnimatingPresentationModeSwitching
{
    CGImageRef image = [self createImageForAnimatingPresentationModeSwitching];
    NSView *view = nil;
    if (image != NULL) {
        view = [[[NSView alloc] initWithFrame:[self currentWindowFrameForAnimatingPresentationModeSwitching]] autorelease];
        CALayer *layer = [CALayer layer];
        [layer setFrame:NSRectToCGRect([view bounds])];
        [view setLayer:layer];
        [view setWantsLayer:YES];
        CALayer *imageLayer = [CALayer layer];
        [imageLayer setFrame:[layer bounds]];
        [imageLayer setContents:(id)image];
        [layer addSublayer:imageLayer];
        CGImageRelease(image);
    }
    return view;
}

+ (BOOL)autosavesInPlace
{
    return YES;
}

- (id)initForURL:(id)aURL withContentsOfURL:(id)aURL2 ofType:(id)aType error:(id *)aError
{
    self = [super initForURL:aURL withContentsOfURL:aURL2 ofType:aType error:aError];
    if (self != nil && [aType length] == 0) {
        NSString *extension = [[[aURL path] pathExtension] lowercaseString];
        if (![extension isEqualToString:@"stack"] && ![extension isEqualToString:@"hsa"]) {
            [self setFileType:[extension isEqualToString:@"key"] ? @"HSKeynoteDocumentType" : @"HSNativeDocumentType"];
        }
    }
    return self;
}

- (void)dealloc
{
    [self destoryModelIfNeeded];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_hyperRemovedItemsPaths release];
    [_commitLogMessage release];
    [_documentSharingController release];
    [_editObjectDialogContext release];
    [_modeSwitcher release];
    [_exportManager release];
    [_selectionController setCardView:nil];
    [_selectionController release];
    [_storyboardController release];
    [_selectionSync setCardView:nil];
    [_selectionSync release];
    [_stackSelectionHolder setDocument:nil];
    [_stackSelectionHolder release];
    [_playerInEditorWindowController release];
    [_hyperCastingWindowController release];
    [_purePlayerWindowController release];
    [_presentationWindowController release];
    [_modeHistory release];
    [_playerView release];
    [_invocationsToPerformAfterSwitchToEditMode release];
    [_minimalWindowApplier release];
    [_openWarning release];
    [_palettesToHideInHypercastingMode release];
    [_textViewsToResetScrollPosition release];
    [_animatingWindow release];
    [_browseUndoManager release];
    [super dealloc];
}

- (BOOL)isInPlayerMode
{
    if (_modeSwitcher == nil) {
        return NO;
    }
    return [[self currentWindowController] isMemberOfClass:[HSDependentPlayerWindowController class]] || [[self currentWindowController] isMemberOfClass:[HSPurePlayerInEditorWindowController class]];
}

- (BOOL)isInPresentationMode
{
    return _isInPresentationMode;
}

- (BOOL)isInStandardMode
{
    return ![self isInStoryboardMode] && ![self isInPurePlayerMode] && ![self isInPresentationMode];
}

- (BOOL)hyperReadFromFileWrapper:(id)aWrapper ofType:(id)aType error:(id *)aError
{
    if ([aType isEqual:@"HSDocumentType"] || [aType isEqual:@"HSAiBADocumentType"]) {
        return [super hyperReadFromFileWrapper:aWrapper ofType:aType error:aError];
    }
    if (![aType isEqualToString:@"HSKeynoteDocumentType"]) {
        return NO;
    }
    if ([KeynoteImportManager isKeynote2FileWrapperRepresentation:aWrapper]) {
        [[self undoManager] disableUndoRegistration];
        KeynoteImportManager *manager = [KeynoteImportManager new];
        [manager setPathToDocument:[[self fileURL] path]];
        [manager setFileWrapper:aWrapper];
        id presentation = [manager presentation];
        [presentation detailChildren];
        BOOL imported = [manager shouldImportPresentation];
        if (!imported) {
            *aError = [HSError errorWithHSCode:0x2711];
        } else {
            HSStack *stack = [HSStack defaultObject];
            [self setStack:stack];
            [stack importFromKeynoteObject:presentation];
        }
        [manager release];
        [[self undoManager] enableUndoRegistration];
        return imported;
    }
    if (aError != NULL) {
        *aError = [HSError errorWithHSCode:0x5026];
    }
    return NO;
}

- (void)exportPanelControllerDidEnd:(id)aController returnCode:(NSInteger)aCode contextInfo:(void *)aInfo
{
    if (![(id)aInfo isEqualToString:@"HSDocumentType"] || ![(id)aInfo isEqualToString:@"HSAiBADocumentType"]) {
        if (aCode == 1) {
            [self exportPanelControllerDidEnd:aController forDocumentWithType:(id)aInfo];
        } else {
            [self exportTo:self];
        }
    }
}

- (void)invalidExportFilenameAlertDidEnd:(id)aAlert returnCode:(NSInteger)aCode contextInfo:(void *)aInfo
{
    [self runModalExportPanelWithDelegate:self didSaveSelector:@selector(exportPanelControllerDidEnd:returnCode:contextInfo:) contextInfo:aInfo];
}

- (id)undoManager
{
    if ([self isInPlayerMode] && ![self shouldSaveChangesMadeInBrowseMode]) {
        return [self browseUndoManager];
    }
    if (_autosaveUndoManager != nil) {
        return _autosaveUndoManager;
    }
    return [super undoManager];
}

- (void)takeDataFromDocument:(id)aDocument
{
    [self setModeSwitcher:[aDocument modeSwitcher]];
    if ([aDocument isKindOfClass:[HSEditorDocument class]]) {
        HSEditorDocument *other = aDocument;
        [self setModeHistory:[other modeHistory]];
        BOOL inPresentation = [other isInPresentationMode];
        _isInPresentationMode = inPresentation;
        _wasInEditorModeBeforePresentationMode = other->_wasInEditorModeBeforePresentationMode;
        _wasInFullScreenBeforePresentationMode = other->_wasInFullScreenBeforePresentationMode;
        _isPresentationModeSwitching = other->_isPresentationModeSwitching;
        _willExitFullScreenWhilePresentationMode = other->_willExitFullScreenWhilePresentationMode;
        _shouldEnterPurePlayerAfterExitPresentationMode = other->_shouldEnterPurePlayerAfterExitPresentationMode;
        _didSwitchToPlayerInEditorWhileEnteringPresentationMode = other->_didSwitchToPlayerInEditorWhileEnteringPresentationMode;
        _selectorToPerformAfterWindowExitFullScreen = other->_selectorToPerformAfterWindowExitFullScreen;
        if (inPresentation) {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(exitAppFullScreen_WindowWillExitFullScreen:) name:NSWindowWillExitFullScreenNotification object:[[self currentWindowController] window]];
        }
    }
    [super takeDataFromDocument:aDocument];
}

- (void)editStack:(id)aStack
{
    [[self stack] stopPlayingTemporaryObjects];
    [self switchToEditorWithToolTag:1];
}

- (void)togglePlayerMode:(id)aMode
{
    if (([NSApp presentationOptions] & 0x400) == 0) {
        if ([self isInPurePlayerMode]) {
            return;
        }
        if ([self isInPurePlayerMode]) {
            [self exitPurePlayerModeWithAnimation:YES];
        } else if ([self canTogglePlayEdit]) {
            [self enterPurePlayerModeWithAnimation:YES];
        }
    } else if ([self isInPresentationMode]) {
        _shouldEnterPurePlayerAfterExitPresentationMode = YES;
        [[[self currentWindowController] window] toggleFullScreen:nil];
    } else {
        [self exitAppFullScreenPerformSelectorAtDone:@selector(togglePlayerMode:)];
    }
}

- (void)exportTo:(id)aTo
{
    if ([self isWritingDisabled]) {
        return;
    }
    HSExportComboDialog *dialog = [HSExportComboDialog new];
    if ([dialog runModalWithDelegate:self] == 1) {
        NSInteger publishType = [dialog publishType];
        NSInteger format = [dialog exportFormat];
        if (publishType == 0) {
            [self runPublishComboDialogForExportFormat:format didEndSelector:@selector(publishComboDialogDidEndWithComeBack:returnCode:)];
        } else {
            [self runExportSessionWithExportFormat:format publishType:publishType];
        }
    }
    [dialog release];
}

- (void)exportToDocumentWithType:(id)aType inPublishType:(NSInteger)aType2 inFormat:(NSInteger)aFormat withRequiredFileType:(id)aType3
{
    if (![self isWritingDisabled]) {
        id manager = [self exportManager];
        if ([manager isOpenExportSession]) {
            [manager closeExportSession];
        }
        [manager openExportSessionWithDocument:self];
        [manager setPublishType:aType2];
        [manager setExportFormat:aFormat];
        [self runModalExportPanelWithDelegate:self didSaveSelector:@selector(exportPanelControllerDidEndWithoutComeback:returnCode:contextInfo:) contextInfo:aType];
    }
}

@end

