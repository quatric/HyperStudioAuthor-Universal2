#import "HSActionSettingsAssistantFactory.h"
static HSActionSettingsAssistantFactory *sharedFactory;

@implementation HSActionSettingsAssistantFactory

+ (id)allocWithZone:(NSZone *)aZone
{
    @synchronized (self) {
        if (sharedFactory == nil) {
            sharedFactory = [super allocWithZone:aZone];
            if (sharedFactory != nil)
                [[NSNotificationCenter defaultCenter] addObserver:sharedFactory selector:@selector(disabledActionsListDidChange:) name:HSDisabledActionsListDidChangeNotification object:nil];
            return sharedFactory;
        }
    }
    return nil;
}

+ (id)sharedActionSettingsAssistantFactory
{
    @synchronized (self) {
        if (sharedFactory == nil)
            [[self alloc] init];
    }
    return sharedFactory;
}

- (void)invalidateDisabledActionTypes
{
    [_disabledActionTypes release];
    _disabledActionTypes = nil;
}

- (id)disabledActionTypes
{
    if (_disabledActionTypes == nil && [HSRestrictionsManager restrictionState:HSPrintCardsAndTextDisabled])
        _disabledActionTypes = [[NSArray alloc] initWithObjects:[HSPrintCardAction actionType], nil];
    return _disabledActionTypes;
}

- (void)disabledActionsListDidChange:(id)aChange
{
    [self invalidateDisabledActionTypes];
}

// Each call hands out a copy of the pane prototype; NSNull marks action types without settings.
- (id)actionAssistantForActionType:(id)aType
{
    id assistant = [[[self actionTypeToAssistantMap] objectForKey:aType] copy];
    if (assistant == [NSNull null])
        assistant = nil;
    return [assistant autorelease];
}

- (id)actionTypeToAssistantMap
{
    if (_actionTypeToAssistantMap == nil) {
        NSNull *none = [NSNull null];
        _actionTypeToAssistantMap = [[NSDictionary alloc] initWithObjectsAndKeys:
            [[HSReadWriteTextActionAssistantPane new] autorelease], [HSReadWriteTextAction actionType],
            none, [HSRestoreStackAction actionType],
            [[HSCardShufflerActionAssistantPane new] autorelease], [HSCardShufflerAction actionType],
            [[HSCompareTextActionAssistantPane new] autorelease], [HSCompareTextAction actionType],
            [[HSGoogleEarthActionAssistantPane new] autorelease], [HSGoogleEarthAction actionType],
            [[HSShowInFinderActionAssistantPane new] autorelease], [HSShowInFinderAction actionType],
            [[HSButtonStepperActionAssistantPane new] autorelease], [HSButtonStepperAction actionType],
            [[HSButtonListerActionAssistantPane new] autorelease], [HSButtonListerAction actionType],
            [[HSScrollCardActionAssistantPane new] autorelease], [HSScrollCardAction actionType],
            [[HSButtonScannerActionAssistantPane new] autorelease], [HSButtonScannerAction actionType],
            none, [HSClearChangeFlagAction actionType],
            [[HSGhostWriterActionAssistantPane new] autorelease], [HSGhostWriterAction actionType],
            [[HSKeyMapperActionAssistantPane new] autorelease], [HSKeyMapperAction actionType],
            [[HSStarFieldActionAssistantPane new] autorelease], [HSStarFieldAction actionType],
            [[HSSequencerActionAssistantPane new] autorelease], [HSSequencerAction actionType],
            none, [HSMakeHomeStackAction actionType],
            none, [HSQuitAction actionType],
            [[HSTestingFunctionsAssistantPane new] autorelease], [HSTestingFunctionsAction actionType],
            [[HSShowHideCursorActionAssistantPane new] autorelease], [HSShowHideCursorAction actionType],
            [[HSSpeechRecognitionActionAssistantPane new] autorelease], [HSSpeechRecognitionAction actionType],
            [[[HSSetCursorPositionAssistantPane alloc] initWithCoachingKey:@"SetCursorPosition"] autorelease], [HSSetCursorPositionAction actionType],
            [[HSRunAppleScriptActionAssistantPane new] autorelease], [HSRunAppleScriptAction actionType],
            [[HSQuitAnotherApplicationActionAssistantPane new] autorelease], [HSQuitAnotherApplicationAction actionType],
            [[HSPrintCardActionAssistantPane new] autorelease], [HSPrintCardAction actionType],
            [[HSSetVolumeActionAssistantPane new] autorelease], [HSSetVolumeAction actionType],
            [[HSPauseActionAssistantPane new] autorelease], [HSPauseAction actionType],
            [[HSMoveToFrontActionAssistantPane new] autorelease], [HSMoveToFrontAction actionType],
            [[HSMoveTextActionAssistantPane new] autorelease], [HSMoveTextAction actionType],
            [[HSSlideShowActionAssistantPane new] autorelease], [HSSlideShowAction actionType],
            [[HSPictureShowActionAssistantPane new] autorelease], [HSPictureShowAction actionType],
            [[HSMovieControllerActionAssistantPane new] autorelease], [HSMovieControllerAction actionType],
            [[HSAutoRecordActionAssistantPane new] autorelease], [HSAutoRecordAction actionType],
            [[HSAutoScrollActionAssistantPane new] autorelease], [HSAutoScrollAction actionType],
            [[HSTextToSpeechActionAssistantPane new] autorelease], [HSTextToSpeechAction actionType],
            [[HSShowMessageActionAssistantPane new] autorelease], [HSShowMessageAction actionType],
            [[HSArduinoWatcherActionAssistantPane new] autorelease], [HSArduinoWatcherAction actionType],
            [[HSArduinoSetupActionAssistantPane new] autorelease], [HSArduinoSetupAction actionType],
            [[[HSTransitionsAssistantPane alloc] initWithActionType:[HSGoToLastMarkedCardAction actionType] paneMultiApplier:nil] autorelease], [HSGoToLastMarkedCardAction actionType],
            [[HSAnotherCardActionAssistantPane new] autorelease], [HSOtherCardAction actionType],
            [[HSOpenStackActionAssistantPane new] autorelease], [HSOpenStackAction actionType],
            [[[HSTransitionsAssistantPane alloc] initWithActionType:[HSGoToHomeStackAction actionType] paneMultiApplier:nil] autorelease], [HSGoToHomeStackAction actionType],
            [[[HSTransitionsAssistantPane alloc] initWithActionType:[HSPreviousCardAction actionType] paneMultiApplier:nil] autorelease], [HSPreviousCardAction actionType],
            [[[HSTransitionsAssistantPane alloc] initWithActionType:[HSNextCardAction actionType] paneMultiApplier:nil] autorelease], [HSNextCardAction actionType],
            [[[HSTransitionsAssistantPane alloc] initWithActionType:[HSForwardAction actionType] paneMultiApplier:nil] autorelease], [HSForwardAction actionType],
            [[[HSTransitionsAssistantPane alloc] initWithActionType:[HSBackAction actionType] paneMultiApplier:nil] autorelease], [HSBackAction actionType],
            [[HSOpenLocationActionAssistantPane new] autorelease], [HSOpenLocationAction actionType],
            [[HSAnimationSetupPickImageAssistantPane new] autorelease], [HSPlayAnimationAction actionType],
            [[HSPlayMovieActionAssistantPane new] autorelease], [HSPlayMovieAction actionType],
            [[HSPlaySoundActionAssistantPane new] autorelease], [HSPlaySoundAction actionType],
            [[HSGoToURLActionAssistantPane new] autorelease], [HSGoToURLAction actionType],
            [[HSRunCommandActionAssistancePane new] autorelease], [HSRunCommandAction actionType],
            [[HSShowHideObjectsActionAssistantPane new] autorelease], [HSShowHideObjectAction actionType],
            nil];
    }
    return _actionTypeToAssistantMap;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_actionTypeToAssistantMap release];
    [_disabledActionTypes release];
    [super dealloc];
}

- (id)autorelease
{
    return self;
}

- (oneway void)release
{
}

- (NSUInteger)retainCount
{
    return NSUIntegerMax;
}

- (id)retain
{
    return self;
}

- (id)copyWithZone:(NSZone *)aZone
{
    return self;
}

@end
