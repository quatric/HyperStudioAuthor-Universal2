#import "HSActionExecutionContext.h"
#import "HyperPlayerBaseData.h"
#import <objc/message.h>

static NSCharacterSet *HSButtonScannerDigits = nil;

// Sends a sheet's did-end selector the way the pre-10.6 sheet APIs did.
static void HSActionExecutionContextSendSheetDidEnd(id aDelegate, SEL aSelector, id aSheet, NSInteger aReturnCode, void *aInfo)
{
    if (aDelegate != nil && aSelector != NULL)
        ((void (*)(id, SEL, id, NSInteger, void *))objc_msgSend)(aDelegate, aSelector, aSheet, aReturnCode, aInfo);
}

@implementation HSActionExecutionContext

- (void)notifyUserAboutActionRunningFailureIfNeeded:(id)aNeeded
{
    BOOL unsupported = [self isInWebPlayer] && ![aNeeded supportedInWebPlayer];
    if (!unsupported && (![self isInStackToGo] || [aNeeded supportedInStackToGo]))
        return;
    HSAlert *alert = [HSAlert new];
    [alert setMessageText:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"Cannot perform action" value:@"" table:@"Alerts"]];
    [alert setInformativeText:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"The action links to a file made in an earlier version of HyperStudio and is not supported in the current format." value:@"" table:@"Alerts"]];
    [alert addButtonWithTitle:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"OK" value:@"" table:@"Alerts"]];
    [self displayAlert:alert modalDelegate:self didEndSelector:@selector(actionRunningFailureAlertDidEnd:returnCode:contextInfo:) contextInfo:NULL];
    [NSApp runModalForWindow:[alert window]];
    [alert release];
}

- (void)actionRunningFailureAlertDidEnd:(id)aEnd returnCode:(NSInteger)aCode contextInfo:(void *)aInfo
{
    [NSApp stopModal];
}

- (BOOL)canRunAction:(id)aAction
{
    if ([self isInWebPlayer] && ![aAction supportedInWebPlayer])
        return NO;
    if ([self isInStackToGo] && ![aAction supportedInStackToGo])
        return NO;
    return [aAction canRunInContext:self];
}

- (BOOL)isInStackToGo
{
    id controller = [NSDocumentController sharedDocumentController];
    if (![controller respondsToSelector:@selector(isStackToGoController)])
        return NO;
    return [controller isStackToGoController];
}

- (BOOL)isInWebPlayer
{
    return [[[self document] fileType] isEqualTo:@"HSWebDocumentType"];
}

- (void)setTransitionPlaying:(BOOL)aPlaying
{
    _isCardChangeTransitionPlaying = aPlaying;
}

- (BOOL)isTransitionPlaying
{
    return _isCardChangeTransitionPlaying;
}

- (void)deactivateActiveTextField
{
    [[self cardView] deactivateActiveTextField];
}

- (id)activeTextField
{
    return [[self cardView] activeTextField];
}

- (void)deactivate
{
    _isActive = 0;
    [self unregisterNotificationForUndoManager];
    if (_arduinoWatchers != nil)
        [[NSNotificationCenter defaultCenter] removeObserver:self name:HSArduinoDevicePinStateDidChangeNotification object:[HSArduinoDevice defaultDevice]];
    [self shutDownSpeechRecognition];
    [_currentTemporaryPlayableObject removeAllObjects];
    [_currentTemporaryPlayableObjectPlacedBottom removeAllObjects];
    [[HSAttributeNotificationCenter defaultCenter] removeObserver:self selector:@selector(hiddenStateChanged:)];
    NSEnumerator *movies = [_currentHiddenMovieObjects objectEnumerator];
    id movie;
    while ((movie = [movies nextObject]) != nil)
        [movie setHiddenInPlayer:[movie isHidden]];
    [_currentHiddenMovieObjects removeAllObjects];
}

- (void)activate
{
    if (_arduinoWatchers != nil)
    {
        id device = [HSArduinoDevice defaultDevice];
        if (device != nil)
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(HSActionExecutionContext_arduinoDevicePinConfigurationDidChange:) name:HSArduinoDevicePinStateDidChangeNotification object:device];
    }
    _hasChangesInPlayerMode = 0;
    id undoManager = [_document undoManager];
    if (undoManager != nil)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(HSActionExecutionContext_undoManagerDidOpenUndoGroup:) name:NSUndoManagerDidOpenUndoGroupNotification object:undoManager];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(HSActionExecutionContext_undoManagerDidRemoveAllActions:) name:HSUndoManagerDidRemoveAllActionsNotification object:undoManager];
    }
    _isActive = 1;
}

- (void)restoreStack
{
    id manager = [[[self document] queryHyperInterface:@protocol(HSActionExecutionManagerProvider)] actionExecutionManager];
    [[manager automaticTimerManager] stopAllAutomaticActionTimersForCard:[self card]];
    [[HSActionMediaPlayer sharedActionMediaPlayer] stopAllSoundsForStackUID:[[self stack] hyperUID] andSoundAttributes:nil];
    [[HSActionMediaPlayer sharedActionMediaPlayer] stopAllMovies];

    // Undo every change the presentation made since the stack was opened.
    NSUndoManager *undoManager = [_document undoManager];
    if (_hasChangesInPlayerMode && undoManager != nil)
    {
        [[self cardView] deactivateActiveTextField];
        // The original looped without checking canUndo, which never ends
        // when the undo stack runs out first.
        while (_hasChangesInPlayerMode && [undoManager canUndo])
            [undoManager undo];
    }

    id stack = [[self stack] queryHyperInterface:@protocol(HSMutableStackAttributes)];
    [stack restoreObjectsVisibility];
    [stack restoreMovieObjectsCurrentTime];
    [[[self stack] allActionsOfType:@protocol(HSPlayMovieActionAttributes) shouldLoadChildren:NO] makeObjectsPerformSelector:@selector(restoreMovieObjectVisibilityInContext:) withObject:self];
    id animationController = [self animationController];
    [animationController stopAllPlayingAnimations];
    [animationController presentationIsStarting];
    id arriveEvent = [HSActionEvent actionEventOfType:kHSArriveActionEventType];
    if (![manager areAnyActionsRunningForEvent:arriveEvent])
        [[manager automaticTimerManager] runAutomaticActionTimersForCard:[self card] withContext:self actionEvent:arriveEvent];
}

- (void)HSActionExecutionContext_undoManagerDidOpenUndoGroup:(id)aGroup
{
    id undoManager = [_document undoManager];
    if (_hasChangesInPlayerMode || undoManager == nil)
        return;
    [[undoManager prepareWithInvocationTarget:self] HSActionExecutionContext_setHasChangesInPlayerMode:NO];
    _hasChangesInPlayerMode = 1;
}

- (void)handleClickInInteractiveLayer
{
    [self stopGhostWriterActions];
    if ([self isRecording])
    {
        _shouldIgnoreRecording = YES;
        [self stopRecording];
    }
    if ([self currentPauseAction] != nil && [[self currentPauseAction] canBeStopped])
    {
        [[self currentPauseAction] stop:self];
        [self setCurrentPauseAction:nil];
    }
}

- (BOOL)handleMouseDownEvent:(id)aEvent
{
    NSEnumerator *actions = [_eventResponderActions reverseObjectEnumerator];
    id action;
    while ((action = [actions nextObject]) != nil)
    {
        if ([action handleMouseDownEvent:aEvent])
            return YES;
    }
    if ([self waitingForMouseDownEvent])
        [self handleClickInInteractiveLayer];
    return NO;
}

- (BOOL)handleKeyUpEvent:(id)aEvent
{
    for (id action in _eventResponderActions)
    {
        if ([action handleKeyUpEvent:aEvent])
            return YES;
    }
    return NO;
}

- (BOOL)handleKeyDownEvent:(id)aEvent
{
    for (id action in _eventResponderActions)
    {
        if ([action handleKeyDownEvent:aEvent])
            return YES;
    }
    return NO;
}

- (BOOL)waitingForMouseDownEvent
{
    return [self activeObject] != nil;
}

- (void)doCommandBySelector:(SEL)aSelector forNode:(id)aNode
{
    [[self cardView] doCommandBySelector:aSelector forNode:aNode];
}

- (void)insertText:(id)aText toNode:(id)aNode
{
    [[self cardView] insertText:aText toNode:aNode];
}

- (void)speechRecognizer:(id)aRecognizer didRecognizeCommand:(id)aCommand
{
    id object = [self objectWithName:aCommand];
    if ([object card] == [[self document] currentCard])
        [self runActionsForObject:object];
}

// The recognizer hands back the command objects it was given, so the name
// is matched by identity, as in the original.
- (id)objectWithName:(id)aName
{
    NSEnumerator *objects = [[self stack] hyperDeepEnumerator];
    id object;
    while ((object = [objects nextObject]) != nil)
    {
        if (![object implementsHyperInterface:@protocol(HSActor)]
            || [object implementsHyperInterface:@protocol(HSCardAttributes)]
            || [object implementsHyperInterface:@protocol(HSStackAttributes)])
            continue;
        object = [object queryHyperInterface:@protocol(HSObjectAttributes)];
        if ([object hyperName] == aName)
            return object;
    }
    return nil;
}

- (void)shutDownSpeechRecognition
{
    [self invalidateSpeechRecognizer];
}

- (void)addSpeechCommands:(id)aCommands
{
    NSSpeechRecognizer *recognizer = [self speechRecognizer];
    NSArray *commands = [recognizer commands];
    NSMutableSet *set = commands != nil ? [NSMutableSet setWithArray:commands] : [NSMutableSet set];
    [set addObjectsFromArray:aCommands];
    [recognizer setCommands:[set allObjects]];
}

- (void)invalidateSpeechRecognizer
{
    [_speechRecognizer stopListening];
    if ([_speechRecognizer delegate] == (id)self)
        [_speechRecognizer setDelegate:nil];
    [_speechRecognizer release];
    _speechRecognizer = nil;
}

- (id)speechRecognizer
{
    if (_speechRecognizer == nil)
    {
        _speechRecognizer = [[NSSpeechRecognizer alloc] init];
        [_speechRecognizer setDelegate:self];
        [_speechRecognizer performSelector:@selector(startListening) withObject:nil afterDelay:0];
    }
    return _speechRecognizer;
}

- (void)resumeAllPlayAnimationActions
{
    [[self animationController] resumeAllPlayingAnimations];
}

- (void)pauseAllPlayAnimationActions
{
    [[self animationController] pauseAllPlayingAnimations];
}

- (id)interactiveObjectForKeyEvent:(id)aEvent
{
    if ([self isButtonScannerEvent:aEvent])
    {
        id object = [self activeObject];
        [[self buttonScannerAction] stop:self];
        return object;
    }
    id mapping = [HSKeyMapping keyMappingForEvent:aEvent];
    if (mapping == nil)
        return nil;
    return [self objectForKeyMapping:mapping];
}

// A keypad digit or the space bar triggers the scanned button.
- (BOOL)isButtonScannerEvent:(id)aEvent
{
    if ([self activeObject] == nil)
        return NO;
    if (HSButtonScannerDigits == nil)
        HSButtonScannerDigits = [[NSCharacterSet characterSetWithCharactersInString:@"0123"] retain];
    NSString *characters = [aEvent charactersIgnoringModifiers];
    if (characters == nil || [characters length] == 0)
        return NO;
    if (([(NSEvent *)aEvent modifierFlags] & NSEventModifierFlagNumericPad) != 0
        && [characters rangeOfCharacterFromSet:HSButtonScannerDigits].location != NSNotFound)
        return YES;
    return [characters rangeOfString:@" "].location != NSNotFound;
}

- (void)unregisterEventResponderAction:(id)aAction
{
    [_eventResponderActions removeObject:aAction];
}

- (void)registerEventResponderAction:(id)aAction
{
    if (_eventResponderActions == nil)
        _eventResponderActions = [NSMutableArray new];
    [_eventResponderActions addObject:aAction];
}

- (void)setButtonStepperAction:(id)aAction
{
    if (_buttonStepperAction == aAction)
        return;
    [_buttonStepperAction release];
    _buttonStepperAction = [aAction retain];
}

- (id)buttonStepperAction
{
    return _buttonStepperAction;
}

- (void)setButtonListerAction:(id)aAction
{
    if (_buttonListerAction == aAction)
        return;
    [_buttonListerAction release];
    _buttonListerAction = [aAction retain];
}

- (id)buttonListerAction
{
    return _buttonListerAction;
}

- (void)setButtonScannerAction:(id)aAction
{
    if (_buttonScannerAction == aAction)
        return;
    [_buttonScannerAction release];
    _buttonScannerAction = [aAction retain];
}

- (id)buttonScannerAction
{
    return _buttonScannerAction;
}

- (id)activeObject
{
    id object = [_buttonScannerAction activeObject];
    if (object == nil)
        object = [_buttonListerAction activeObject];
    if (object == nil)
        object = [_buttonStepperAction activeObject];
    return object;
}

- (void)HSActionExecutionContext_arduinoDevicePinConfigurationDidChange:(id)aChange
{
    // 6 is the connected status.
    if ([[HSArduinoDevice defaultDevice] connectionStatus] != 6)
        return;
    NSMutableSet *watchers = [NSMutableSet set];
    NSIndexSet *pins = [[aChange userInfo] objectForKey:HSArduinoDeviceNotificationInfoDigitalPins];
    if (pins != nil)
    {
        for (NSUInteger pin = [pins firstIndex]; pin != NSNotFound; pin = [pins indexGreaterThanIndex:pin])
            [watchers unionSet:[_arduinoWatchers triggeringWatchersForDigitalPin:(unsigned char)pin]];
    }
    pins = [[aChange userInfo] objectForKey:HSArduinoDeviceNotificationInfoAnalogPins];
    if (pins != nil)
    {
        for (NSUInteger pin = [pins firstIndex]; pin != NSNotFound; pin = [pins indexGreaterThanIndex:pin])
            [watchers unionSet:[_arduinoWatchers triggeringWatchersForAnalogPin:(unsigned char)pin]];
    }
    if ([watchers count] != 0)
        [self runActionsForObjects:[watchers allObjects] forRequestor:nil actionEvent:[HSActionEvent actionEventOfType:kHSDefaultActionEventType]];
}

- (void)setArduinoWatchers:(id)aWatchers
{
    id oldWatchers = _arduinoWatchers;
    if (oldWatchers == aWatchers)
        return;
    [aWatchers retain];
    [_arduinoWatchers release];
    _arduinoWatchers = aWatchers;
    id device = [HSArduinoDevice defaultDevice];
    if (device == nil)
        return;
    if ([device connectionStatus] == 6)
    {
        NSArray *triggering = [[_arduinoWatchers triggeringWatchers] allObjects];
        if ([triggering count] != 0)
            [self runActionsForObjects:triggering forRequestor:nil actionEvent:[HSActionEvent actionEventOfType:kHSDefaultActionEventType]];
    }
    if (oldWatchers == nil && _arduinoWatchers != nil)
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(HSActionExecutionContext_arduinoDevicePinConfigurationDidChange:) name:HSArduinoDevicePinStateDidChangeNotification object:device];
    else if (oldWatchers != nil && _arduinoWatchers == nil)
        [[NSNotificationCenter defaultCenter] removeObserver:self name:HSArduinoDevicePinStateDidChangeNotification object:device];
}

- (void)removeKeyMappings
{
    [_keyMappings release];
    _keyMappings = nil;
}

- (void)setKeyMappings:(id)aMappings
{
    if ([_keyMappings isEqualToDictionary:aMappings])
        return;
    [_keyMappings release];
    _keyMappings = [aMappings retain];
}

- (id)objectForKeyMapping:(id)aMapping
{
    return [_keyMappings objectForKey:aMapping];
}

- (void)setCurrentPauseAction:(id)aAction
{
    if (_currentPauseAction == aAction)
        return;
    [_currentPauseAction release];
    _currentPauseAction = [aAction retain];
}

- (id)currentPauseAction
{
    return _currentPauseAction;
}

- (BOOL)stopGhostWriterActions
{
    BOOL stopped = NO;
    NSEnumerator *actions = [[self ghostWriterActions] objectEnumerator];
    id action;
    while ((action = [actions nextObject]) != nil)
    {
        if ([action canBeStopped])
        {
            [action stop:self];
            stopped = YES;
        }
    }
    return stopped;
}

- (id)objectWithUID:(id)aUID
{
    return [[[self card] queryHyperInterface:@protocol(HSUserObjectUIDBasedAccess)] childWithUID:aUID];
}

- (void)removeGhostWriterAction:(id)aAction
{
    [[self ghostWriterActions] removeObject:aAction];
}

- (void)addGhostWriterAction:(id)aAction
{
    [[self ghostWriterActions] addObject:aAction];
}

- (id)ghostWriterActions
{
    if (_ghostWriterActions == nil)
        _ghostWriterActions = [NSMutableArray new];
    return _ghostWriterActions;
}

- (void)resetMovie
{
    [self resetMovieOnCard:[self card]];
}

- (void)resetMovieOnCard:(id)aCard
{
    if (aCard == nil)
        aCard = [self card];
    id movie = [self playableObjectOnCard:aCard];
    if (movie != nil && [movie isHyperPlaying])
        [movie hyperStop];
    [movie setHyperCurrentTime:[movie hyperStartTime]];
}

// The original steps forward here too.
- (void)stepBackward
{
    [self stepForwardOnCard:[self card]];
}

- (void)stepBackwardOnCard:(id)aCard
{
    if (aCard == nil)
        aCard = [self card];
    id movie = [self playableObjectOnCard:aCard];
    if (movie == nil)
        return;
    [movie hyperStop];
    [movie hyperStepBack];
}

- (void)stepForward
{
    [self stepForwardOnCard:[self card]];
}

- (void)stepForwardOnCard:(id)aCard
{
    if (aCard == nil)
        aCard = [self card];
    id movie = [self playableObjectOnCard:aCard];
    if (movie == nil)
        return;
    [movie hyperStop];
    [movie hyperStepForward];
}

- (void)pauseMovie
{
    [self pauseMovieOnCard:[self card]];
}

- (void)pauseMovieOnCard:(id)aCard
{
    if (aCard == nil)
        aCard = [self card];
    id movie = [self playableObjectOnCard:aCard];
    if (movie != nil && [movie isHyperPlaying])
        [movie hyperStop];
}

- (BOOL)playMovie:(id)aMovie
{
    return [self playMovie:aMovie onCard:[self card]];
}

- (BOOL)playMovie:(id)aMovie onCard:(id)aCard
{
    if (aCard == nil)
        aCard = [self card];
    id movie = [self playableObjectOnCard:aCard];
    if (movie == nil || [movie isHyperPlaying])
        return NO;
    if ([[movie queryHyperInterface:@protocol(HSCardObjectAttributes)] isHiddenInPlayer])
        return NO;
    [movie hyperStart:aMovie];
    return YES;
}

- (BOOL)playPauseMovie:(id)aMovie onCard:(id)aCard
{
    id movie = [self playableObjectOnCard:aCard != nil ? aCard : [self card]];
    if (movie == nil || [movie isHyperPlaying])
    {
        [self pauseMovieOnCard:aCard];
        return YES;
    }
    return [self playMovie:aMovie onCard:aCard];
}

- (id)playableObjectOnCard:(id)aCard
{
    id object = nil;
    if ([[self currentTemporaryPlayableObject] count] != 0)
        object = [[self currentTemporaryPlayableObject] extraFirstObject];
    else
    {
        NSEnumerator *children = [aCard hyperEnumerator];
        while ((object = [children nextObject]) != nil)
        {
            if ([object implementsHyperInterface:@protocol(HSMovieObjectAttributes)])
                break;
        }
        if (object == nil)
            return nil;
    }
    return [object queryHyperInterface:@protocol(HSPlayableObjectAttributes)];
}

- (void)hiddenStateChanged:(id)aChanged
{
    if ([[[aChanged object] queryHyperInterface:@protocol(HSCardObjectHiddenAttribute)] isHidden] != YES)
        return;
    [[self currentHiddenMovieObjects] removeObject:[aChanged object]];
    [[HSAttributeNotificationCenter defaultCenter] removeObserver:self selector:@selector(hiddenStateChanged:) ofChanges:2 ofAttribute:@protocol(HSCardObjectHiddenAttribute) ofObject:[aChanged object]];
}

- (void)removeMovieHiddenByPlayMovieAction:(id)aAction
{
    if (![[self currentHiddenMovieObjects] containsObject:aAction])
        return;
    [[self currentHiddenMovieObjects] removeObject:aAction];
    [[HSAttributeNotificationCenter defaultCenter] removeObserver:self selector:@selector(hiddenStateChanged:) ofChanges:2 ofAttribute:@protocol(HSCardObjectHiddenAttribute) ofObject:aAction];
}

- (void)restoreMovieHiddenByPlayMovieAction:(id)aAction
{
    if ([[self currentHiddenMovieObjects] containsObject:aAction])
        [aAction setHiddenInPlayer:[aAction isHidden]];
}

- (void)addMovieHiddenByPlayMovieAction:(id)aAction
{
    if ([[self currentHiddenMovieObjects] containsObject:aAction])
        return;
    [[self currentHiddenMovieObjects] addObject:aAction];
    [[HSAttributeNotificationCenter defaultCenter] addObserver:self selector:@selector(hiddenStateChanged:) ofChanges:2 ofAttribute:@protocol(HSCardObjectHiddenAttribute) ofObject:aAction withPriority:0.25f];
}

- (void)removeAllTemporaryPlayableObject
{
    [_currentTemporaryPlayableObject removeAllObjects];
    [_currentTemporaryPlayableObjectPlacedBottom removeAllObjects];
}

- (NSInteger)bottomPositionOfLastTemporaryPlayableObject
{
    id node = [[[self currentTemporaryPlayableObjectPlacedBottom] lastObject] queryHyperInterface:@protocol(HSNodeAttributes)];
    if (node == nil)
        return -1;
    return [node hyperIndex];
}

- (void)addTemporaryPlayableObjectPlacedBottomOnCard:(id)aCard
{
    [self checkPlayableObjects:[self currentTemporaryPlayableObjectPlacedBottom] replaceTemporaryPlayableObjectSimilaryTo:aCard removeFromParent:NO];
    [[self currentTemporaryPlayableObjectPlacedBottom] addObject:aCard];
}

- (void)addTemporaryPlayableObjectOnCard:(id)aCard
{
    [self checkPlayableObjects:[self currentTemporaryPlayableObject] replaceTemporaryPlayableObjectSimilaryTo:aCard removeFromParent:YES];
    [[self currentTemporaryPlayableObject] addObject:aCard];
}

- (void)checkPlayableObjects:(id)aObjects replaceTemporaryPlayableObjectSimilaryTo:(id)aTo removeFromParent:(BOOL)aParent
{
    id uid = [aTo hyperPlayableObjectUID];
    if (uid == nil)
        return;
    NSEnumerator *objects = [[NSArray arrayWithArray:aObjects] objectEnumerator];
    id object;
    while ((object = [objects nextObject]) != nil)
    {
        id objectUID = [object hyperPlayableObjectUID];
        if (objectUID == nil || ![uid isEqual:objectUID])
            continue;
        if (aParent)
        {
            id child = [object queryHyperInterface:@protocol(HSNodeChild)];
            id parent = [child hyperParent];
            if (parent != nil)
                [parent removeHyperChild:child];
        }
        [aObjects removeObject:object];
    }
}

- (id)currentHiddenMovieObjects
{
    if (_currentHiddenMovieObjects == nil)
        _currentHiddenMovieObjects = [NSMutableArray new];
    return _currentHiddenMovieObjects;
}

- (id)currentTemporaryPlayableObjectPlacedBottom
{
    if (_currentTemporaryPlayableObjectPlacedBottom == nil)
        _currentTemporaryPlayableObjectPlacedBottom = [NSMutableArray new];
    return _currentTemporaryPlayableObjectPlacedBottom;
}

- (id)currentTemporaryPlayableObject
{
    if (_currentTemporaryPlayableObject == nil)
        _currentTemporaryPlayableObject = [NSMutableArray new];
    return _currentTemporaryPlayableObject;
}

- (BOOL)slideshowExecutedByAction
{
    return [[[self document] playerView] slideshowExecutedByAction];
}

- (id)currentSlideshowAttributes
{
    return [[[self document] playerView] slideshowAttributes];
}

- (void)stopSlideshow
{
    [[[self document] playerView] stopSlideshow];
}

- (void)startSlideshowWithDataSource:(id)aSource attributes:(id)aAttributes
{
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:aAttributes, HSCustomSlideshowAttributesKey, nil];
    [[[self document] playerView] startSlideshowWithDataSource:aSource options:options];
}

- (void)startSlideshowWithAttributes:(id)aAttributes
{
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:aAttributes, HSCustomSlideshowAttributesKey, [NSNumber numberWithBool:YES], HSSlideshowExecutedByActionKey, nil];
    [[[self document] playerView] startSlideshowWithOptions:options];
}

- (BOOL)isSlideshow
{
    return [[[self document] playerView] isSlideshow];
}

- (void)stopTransition
{
    [[[self document] playerView] stopTransition];
}

- (void)showTransition:(id)aTransition
{
    [[[self document] playerView] showTransition:aTransition];
}

- (void)HSActionExecutionContext_playerViewGraphicCompositionDidStop:(id)aStop
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self name:@"HSPlayerViewGraphicCompositionDidEndNotification" object:[(id)_document playerView]];
    [center postNotificationName:@"HSActionExecutionContextGraphicCompositionDidEnd" object:self];
}

- (BOOL)isGraphicCompositionPlaying
{
    return [[(id)_document playerView] isGraphicCompositionPlaying];
}

- (void)stopGraphicComposition
{
    [[(id)_document playerView] stopGraphicComposition];
}

- (void)showGraphicComposition:(id)aComposition duringTimeInterval:(double)aInterval stopOnMouseClick:(BOOL)aClick
{
    id playerView = [(id)_document playerView];
    if (playerView == nil)
        return;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(HSActionExecutionContext_playerViewGraphicCompositionDidStop:) name:@"HSPlayerViewGraphicCompositionDidEndNotification" object:playerView];
    [playerView showGraphicComposition:aComposition duringTimeInterval:aInterval stopOnMouseClick:aClick];
}

- (void)scrollCardToPoint:(NSPoint)aPoint withAnimationDelegate:(id)aDelegate
{
    if ([[(id)_document playerView] isFullScreen])
        return;
    id view = [self cardView];
    if (view == nil)
        return;
    CGFloat y = aPoint.y;
    if ([self isInWebPlayer])
    {
        // The web player scrolls its document view, below a 40 point header.
        view = [[[view playerView] enclosingScrollView] documentView];
        y = aPoint.y + 40.0f;
    }
    HSScrollCardActionAnimation *animation = [[HSScrollCardActionAnimation alloc] initWithView:view scrollPoint:NSMakePoint(aPoint.x, y)];
    [animation setAnimationBlockingMode:NSAnimationBlocking];
    [animation setDelegate:aDelegate];
    [animation startAnimation];
    [animation release];
}

- (void)setDocument:(id)aDocument
{
    if (_document == aDocument)
        return;
    id undoManager = [_document undoManager];
    if (_isActive && undoManager != nil)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:NSUndoManagerDidOpenUndoGroupNotification object:undoManager];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:HSUndoManagerDidRemoveAllActionsNotification object:undoManager];
    }
    _hasChangesInPlayerMode = 0;
    [self shutDownSpeechRecognition];
    _document = aDocument;
    undoManager = [aDocument undoManager];
    if (_isActive && undoManager != nil)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(HSActionExecutionContext_undoManagerDidOpenUndoGroup:) name:NSUndoManagerDidOpenUndoGroupNotification object:undoManager];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(HSActionExecutionContext_undoManagerDidRemoveAllActions:) name:HSUndoManagerDidRemoveAllActionsNotification object:undoManager];
    }
}

- (void)cancelOperation:(id)aOperation
{
    [[self buttonScannerAction] stop:self];
}

- (BOOL)canCancelOperation
{
    return [[self buttonScannerAction] canBeStopped];
}

- (BOOL)runActionsForKeyEvent:(id)aEvent
{
    if ([self handleKeyDownEvent:aEvent])
        return YES;
    if ([self currentPauseAction] != nil && [[self currentPauseAction] canBeStopped])
    {
        [[self currentPauseAction] stop:self];
        [self setCurrentPauseAction:nil];
    }
    id object = [self interactiveObjectForKeyEvent:aEvent];
    if (object == nil)
        return NO;
    if (![self HSActionExecutionContext_drawHighlighButtonIfNeeded:object])
        [self HSActionExecutionContext_drawHighlighImageIfNeeded:object];
    [self runActionsForObject:object];
    return YES;
}

- (void)resumeAutomaticTimer
{
    [[[[[self document] queryHyperInterface:@protocol(HSActionExecutionManagerProvider)] actionExecutionManager] automaticTimerManager] resumeAutomaticTimer];
}

- (void)pauseAutomaticTimer
{
    [[[[[self document] queryHyperInterface:@protocol(HSActionExecutionManagerProvider)] actionExecutionManager] automaticTimerManager] pauseAutomaticTimer];
}

- (void)stopAllActionsForRequestor:(id)aRequestor
{
    [[[[self document] queryHyperInterface:@protocol(HSActionExecutionManagerProvider)] actionExecutionManager] stopAllActionsQueuesForRequestor:aRequestor];
}

- (void)runActionsForObject:(id)aObject
{
    [self runActionsForObject:aObject forRequestor:nil];
}

- (void)runActionsForObjects:(id)aObjects
{
    [self runActionsForObjects:aObjects forRequestor:nil actionEvent:[HSActionEvent actionEventOfType:kHSDefaultActionEventType]];
}

- (void)actionQueue:(id)aQueue didSetupDelayTimer:(id)aTimer
{
    [[[[[self document] queryHyperInterface:@protocol(HSActionExecutionManagerProvider)] actionExecutionManager] automaticTimerManager] actionQueue:aQueue didSetupDelayTimer:aTimer];
}

- (void)startSequencerActionForObjects:(id)aObjects delays:(id)aDelays forRequestor:(id)aRequestor
{
    [[self sequencerRequestorToIgnore] removeObject:aRequestor];
    id timerManager = [[[[self document] queryHyperInterface:@protocol(HSActionExecutionManagerProvider)] actionExecutionManager] automaticTimerManager];
    NSEnumerator *objects = [aObjects objectEnumerator];
    NSEnumerator *delays = [aDelays objectEnumerator];
    id object;
    while ((object = [objects nextObject]) != nil)
    {
        id delay = [delays nextObject];
        if (delay == nil)
            break;
        [timerManager startAutomaticTimerActionsForObject:object withContext:self delay:[delay doubleValue] actionEvent:[HSActionEvent actionEventOfType:kHSDefaultActionEventType] requestor:aRequestor];
    }
}

- (void)runActionsForObjects:(id)aObjects forRequestor:(id)aRequestor actionEvent:(id)aEvent
{
    if ([[self sequencerRequestorToIgnore] containsObject:aRequestor])
        return;
    id manager = [[[self document] queryHyperInterface:@protocol(HSActionExecutionManagerProvider)] actionExecutionManager];
    NSEnumerator *objects = [aObjects objectEnumerator];
    id object;
    while ((object = [objects nextObject]) != nil)
        [manager runActionsForObject:object withEvent:aEvent inContext:self forRequestor:aRequestor];
}

- (void)runActionsForObject:(id)aObject forRequestor:(id)aRequestor
{
    [self runActionsForObjects:[NSArray arrayWithObject:aObject] forRequestor:aRequestor actionEvent:[HSActionEvent actionEventOfType:kHSDefaultActionEventType]];
}

- (void)setCursorPosition:(NSPoint)aPosition
{
    id cardView = [self cardView];
    NSPoint point = [cardView convertPointFromUserSpaceToViewSpace:aPosition];
    point = [cardView convertPoint:point toView:nil];
    // -convertBaseToScreen: in the original.
    point = [[cardView window] convertRectToScreen:NSMakeRect(point.x, point.y, 0, 0)].origin;
    NSRect screenFrame = [[NSScreen mainScreen] frame];
    CGDisplayMoveCursorToPoint(CGMainDisplayID(), CGPointMake(point.x, screenFrame.size.height - point.y));
}

- (void)obscureCursor
{
    [[self cardView] obscureCursor];
}

- (void)hideCursor
{
    [[self cardView] hideCursor];
}

- (void)showCursor
{
    [[self cardView] showCursor];
}

- (void)presentHyperError:(id)aError
{
    [NSApp presentError:aError];
}

- (void)setHomeStackToCurrentStack
{
    [[HSHomeStackController sharedHomeStackController] setHomeStackURL:[[self document] fileURL] storeInDefaults:NO];
}

- (void)runModalSavePanelForSaveOperation:(NSUInteger)aOperation delegate:(id)aDelegate didSaveSelector:(SEL)aSelector contextInfo:(void *)aInfo
{
    [[self document] setFileType:@"HSAiBADocumentType"];
    [[self document] runModalSavePanelForSaveOperation:aOperation delegate:aDelegate didSaveSelector:aSelector contextInfo:aInfo];
}

- (void)displayAlert:(id)aAlert modalDelegate:(id)aDelegate didEndSelector:(SEL)aSelector contextInfo:(void *)aInfo
{
    [aAlert beginSheetModalForWindow:[[self document] windowForSheet] modalDelegate:aDelegate didEndSelector:aSelector contextInfo:aInfo];
}

- (void)document:(id)aDocument didPrint:(BOOL)aPrint contextInfo:(void *)aInfo
{
    id delegate = (id)aInfo;
    if ([delegate respondsToSelector:@selector(documentDidEndPrinting)])
        [delegate documentDidEndPrinting];
}

- (void)printCurrentCardWithDelegate:(id)aDelegate showPrintDialog:(BOOL)aDialog centerPrintout:(BOOL)aPrintout
{
    NSNumber *one = [NSNumber numberWithInt:1];
    NSDictionary *settings = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithBool:YES], HSDocumentPrintCurrentCardKey,
                              one, NSPrintFirstPage,
                              one, NSPrintLastPage,
                              [NSNumber numberWithBool:!aPrintout], HSDocumentDontCenterPrintoutKey, nil];
    [[self document] printDocumentWithSettings:settings showPrintPanel:aDialog delegate:self didPrintSelector:@selector(document:didPrint:contextInfo:) contextInfo:aDelegate];
}

- (void)documentDidRunModalPageLayout:(id)aLayout accepted:(BOOL)aAccepted contextInfo:(void *)aInfo
{
    id delegate = (id)aInfo;
    if (aAccepted && [delegate respondsToSelector:@selector(documentDidEndPageSetupDialog)])
        [delegate documentDidEndPageSetupDialog];
    else if ([delegate respondsToSelector:@selector(documentDidCancelPrinting)])
        [delegate documentDidCancelPrinting];
    // Retained by displayPageSetupDialogWithDelegate:.
    [delegate release];
}

- (void)displayPageSetupDialogWithDelegate:(id)aDelegate
{
    [[self document] runModalPageLayoutWithPrintInfo:[[self document] printInfo] delegate:self didRunSelector:@selector(documentDidRunModalPageLayout:accepted:contextInfo:) contextInfo:[aDelegate retain]];
}

// Through the block-based sheet, as beginSheetForDirectory:… is gone.
- (void)showSavePanel:(id)aPanel sheetForDirectory:(id)aDirectory file:(id)aFile modalDelegate:(id)aDelegate didEndSelector:(SEL)aSelector contextInfo:(void *)aInfo
{
    NSSavePanel *panel = aPanel;
    if (aDirectory != nil)
        [panel setDirectoryURL:[NSURL fileURLWithPath:aDirectory isDirectory:YES]];
    if (aFile != nil)
        [panel setNameFieldStringValue:aFile];
    [panel beginSheetModalForWindow:[[self document] windowForSheet] completionHandler:^(NSModalResponse aResult) {
        HSActionExecutionContextSendSheetDidEnd(aDelegate, aSelector, panel, aResult, aInfo);
    }];
}

- (void)showOpenPanel:(id)aPanel sheetForDirectory:(id)aDirectory file:(id)aFile types:(id)aTypes modalDelegate:(id)aDelegate didEndSelector:(SEL)aSelector contextInfo:(void *)aInfo
{
    NSOpenPanel *panel = aPanel;
    if (aDirectory != nil)
        [panel setDirectoryURL:[NSURL fileURLWithPath:aDirectory isDirectory:YES]];
    if (aFile != nil)
        [panel setNameFieldStringValue:aFile];
    // (No types meant any file.)
    [panel setAllowedFileTypes:[aTypes count] != 0 ? aTypes : nil];
    [panel beginSheetModalForWindow:[[self document] windowForSheet] completionHandler:^(NSModalResponse aResult) {
        HSActionExecutionContextSendSheetDidEnd(aDelegate, aSelector, panel, aResult, aInfo);
    }];
}

- (void)beginModalSheet:(id)aSheet modalDelegate:(id)aDelegate didEndSelector:(SEL)aSelector contextInfo:(void *)aInfo
{
    [[[self document] windowForSheet] beginSheet:aSheet completionHandler:^(NSModalResponse aResult) {
        HSActionExecutionContextSendSheetDidEnd(aDelegate, aSelector, aSheet, aResult, aInfo);
    }];
}

- (id)currentWindowWithSheet
{
    return [[self document] windowForSheet];
}

- (BOOL)isAnySheetRunning
{
    return [[[self document] windowForSheet] attachedSheet] != nil;
}

- (BOOL)isFullscreen
{
    return [[[self document] playerView] isFullScreen];
}

- (void)closePlayer
{
    [[self document] closePlayer];
}

- (void)clearAllChangesInDocument
{
    [[self document] clearChanges];
}

- (id)animationController
{
    return [[self card] animationController];
}

- (id)navigationController
{
    return [[self document] navigationController];
}

- (id)documentAuxillaryPath
{
    return [[self document] auxillaryPath];
}

- (id)documentURL
{
    return [[self document] fileURL];
}

- (id)stack
{
    return [[[self card] stack] queryHyperInterface:@protocol(HSMutableStackAttributes)];
}

- (id)card
{
    return [[self cardView] card];
}

- (id)cardView
{
    return [_document playerCardView];
}

- (id)document
{
    return _document;
}

- (void)decreaseHyperCastingMode
{
    if (_hyperCastingModeCounter != 0)
        _hyperCastingModeCounter--;
}

- (void)increaseHyperCastingMode
{
    _hyperCastingModeCounter++;
}

- (BOOL)isInHyperCastingMode
{
    return _hyperCastingModeCounter != 0;
}

- (void)forceLeaveLimitedMode
{
    _limitedModeCounter = 0;
}

- (void)decreaseLimitedMode
{
    if (_limitedModeCounter != 0)
        _limitedModeCounter--;
}

- (void)increaseLimitedMode
{
    _limitedModeCounter++;
}

// The original truncated the counter to its low byte.
- (BOOL)isInLimitedMode
{
    return _limitedModeCounter != 0;
}

- (void)setActionExecutionContextMode:(NSInteger)aMode
{
    _mode = (int)aMode;
}

- (NSInteger)mode
{
    return _mode;
}

- (void)dealloc
{
    if (_isActive)
    {
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        id undoManager = [_document undoManager];
        if (undoManager != nil)
        {
            [center removeObserver:self name:NSUndoManagerDidOpenUndoGroupNotification object:undoManager];
            [center removeObserver:self name:HSUndoManagerDidRemoveAllActionsNotification object:undoManager];
        }
        [center removeObserver:self name:@"HSPlayerViewGraphicCompositionDidEndNotification" object:[(id)_document playerView]];
        if (_arduinoWatchers != nil)
            [center removeObserver:self name:HSArduinoDevicePinStateDidChangeNotification object:[HSArduinoDevice defaultDevice]];
    }
    [[HSAttributeNotificationCenter defaultCenter] removeObserver:self];
    [self invalidateSpeechRecognizer];
    [_arduinoWatchers release];
    [_currentAutoRecordAction release];
    [_currentPauseAction release];
    [_currentHiddenMovieObjects release];
    [_currentTemporaryPlayableObject release];
    [_currentTemporaryPlayableObjectPlacedBottom release];
    [_ghostWriterActions release];
    [_keyMappings release];
    [_buttonScannerAction release];
    [_buttonListerAction release];
    [_buttonStepperAction release];
    [_eventResponderActions release];
    [_sequencerRequestorToIgnore release];
    [super dealloc];
}

- (id)initWithDocument:(id)aDocument
{
    self = [super init];
    if (self != nil)
        _document = aDocument;
    return self;
}

- (BOOL)hasChangesInPlayerMode
{
    return _hasChangesInPlayerMode;
}

- (void)setHasChangesInPlayerMode:(BOOL)aChanges
{
    _hasChangesInPlayerMode = aChanges;
}

- (void)HSActionExecutionContext_setHasChangesInPlayerMode:(BOOL)aChanges
{
    [[[_document undoManager] prepareWithInvocationTarget:self] HSActionExecutionContext_setHasChangesInPlayerMode:[self hasChangesInPlayerMode]];
    [self setHasChangesInPlayerMode:aChanges];
}

- (void)HSActionExecutionContext_undoManagerDidRemoveAllActions:(id)aActions
{
    [self setHasChangesInPlayerMode:NO];
}

- (void)invalidateScrollCardAnimation
{
    [_scrollCardAnimation stopAnimation];
    [_scrollCardAnimation setDelegate:nil];
    [_scrollCardAnimation release];
    _scrollCardAnimation = nil;
}

- (void)pauseSpeechRecognition
{
    if (_speechRecognizer != nil) {
        [_currentSpeechRecognitionCommands release];
        _currentSpeechRecognitionCommands = [[[self speechRecognizer] commands] retain];
        [self shutDownSpeechRecognition];
    }
}

- (void)resumeSpeechRecognition
{
    if ([_currentSpeechRecognitionCommands count] != 0)
        [self addSpeechCommands:_currentSpeechRecognitionCommands];
}

- (void)registerNotificationForUndoManager
{
    id undoManager = [_document undoManager];
    if (_isActive && undoManager != nil) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(HSActionExecutionContext_undoManagerDidRemoveAllActions:) name:HSUndoManagerDidRemoveAllActionsNotification object:undoManager];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(HSActionExecutionContext_undoManagerDidOpenUndoGroup:) name:NSUndoManagerDidOpenUndoGroupNotification object:undoManager];
    }
}

- (void)unregisterNotificationForUndoManager
{
    id undoManager = [_document undoManager];
    if (undoManager != nil) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:HSUndoManagerDidRemoveAllActionsNotification object:undoManager];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:NSUndoManagerDidOpenUndoGroupNotification object:undoManager];
    }
}

@end
