#import "HSAvailableActionsProvider.h"
// The actions an object (an actor) can have, by type (class name).
@implementation HSAvailableActionsProvider
+ (id)actionTypes
{
    static NSArray *types = nil;
    if (types == nil)
        types = [[NSArray alloc] initWithObjects:
            [HSOtherCardAction actionType], [HSNextCardAction actionType], [HSPreviousCardAction actionType],
            [HSBackAction actionType], [HSGoToHomeStackAction actionType], [HSGoToLastMarkedCardAction actionType],
            [HSOpenStackAction actionType], [HSPlaySoundAction actionType], [HSPlayMovieAction actionType],
            [HSPlayAnimationAction actionType], [HSShowHideObjectAction actionType], [HSGoToURLAction actionType],
            [HSRunCommandAction actionType], [HSOpenLocationAction actionType], [HSArduinoSetupAction actionType],
            [HSArduinoWatcherAction actionType], [HSCardShufflerAction actionType], [HSCompareTextAction actionType],
            [HSGoogleEarthAction actionType], [HSQuitAction actionType], [HSTextToSpeechAction actionType],
            [HSPauseAction actionType], [HSAutoScrollAction actionType], [HSMoveTextAction actionType],
            [HSMoveToFrontAction actionType], [HSPrintCardAction actionType], [HSShowMessageAction actionType],
            [HSMakeHomeStackAction actionType], [HSRunAppleScriptAction actionType], [HSSetCursorPositionAction actionType],
            [HSShowHideCursorAction actionType], [HSQuitAnotherApplicationAction actionType], [HSSetVolumeAction actionType],
            [HSSlideShowAction actionType], [HSPictureShowAction actionType], [HSMovieControllerAction actionType],
            [HSAutoRecordAction actionType], [HSSpeechRecognitionAction actionType], [HSSequencerAction actionType],
            [HSStarFieldAction actionType], [HSKeyMapperAction actionType], [HSClearChangeFlagAction actionType],
            [HSGhostWriterAction actionType], [HSButtonScannerAction actionType], [HSTestingFunctionsAction actionType],
            [HSScrollCardAction actionType], [HSButtonListerAction actionType], [HSButtonStepperAction actionType],
            [HSShowInFinderAction actionType], [HSRestoreStackAction actionType], [HSReadWriteTextAction actionType],
            nil];
    return types;
}
+ (id)sharedAvailableActionsProvider
{
    static id provider = nil;
    if (provider == nil)
        provider = [HSAvailableActionsProvider new];
    return [[provider retain] autorelease];
}
- (id)createDefaultActionOfType:(id)aType
{
    return [HSAction actionOfType:aType];
}
- (BOOL)canActionOfType:(id)aType beAppliedToObject:(id)aObject
{
    return [[self availableActionsForObject:aObject forEvent:nil] containsObject:aType];
}
// Of the types, those of subclasses of the type's class.
static id HSAvailableActionsProviderTypesOfType(NSArray *aTypes, id aType)
{
    NSMutableArray *result = [[aTypes mutableCopy] autorelease];
    Class class = NSClassFromString(aType);
    for (NSString *type in aTypes) {
        if (![NSClassFromString(type) isSubclassOfClass:class])
            [result removeObject:type];
    }
    return [[result copy] autorelease];
}
- (id)availableActionsOfType:(id)aType forObject:(id)aObject forEvent:(id)aEvent
{
    return HSAvailableActionsProviderTypesOfType([self availableActionsForObject:aObject forEvent:aEvent], aType);
}
- (id)allActionsOfType:(id)aType forObject:(id)aObject
{
    return HSAvailableActionsProviderTypesOfType([self allActionsForObject:aObject], aType);
}
- (id)allActionsForObject:(id)aObject
{
    if (aObject == nil || ![aObject implementsHyperInterface:@protocol(HSActor)])
        return nil;
    return [[[HSAvailableActionsProvider actionTypes] mutableCopy] autorelease];
}
// All the actions, less those the object doesn't support for the event.
- (id)availableActionsForObject:(id)aObject forEvent:(id)aEvent
{
    NSMutableArray *actions = nil;
    if (aObject != nil && [aObject implementsHyperInterface:@protocol(HSActor)])
        actions = [[[HSAvailableActionsProvider actionTypes] mutableCopy] autorelease];
    if ([aObject respondsToSelector:@selector(supportsActionType:forEvent:)]) {
        NSArray *types = [actions copy];
        for (id type in types) {
            if (![aObject supportsActionType:type forEvent:aEvent])
                [actions removeObject:type];
        }
        [types release];
    }
    return actions;
}
+ (id)unsupportediBooksActionTypes
{
    static NSArray *unsupportediBooksActionTypes;
    if (unsupportediBooksActionTypes == nil)
        unsupportediBooksActionTypes = [[NSArray alloc] initWithObjects:[HSOpenLocationAction actionType], [HSRunCommandAction actionType], [HSArduinoSetupAction actionType], [HSArduinoWatcherAction actionType], [HSQuitAction actionType], [HSTextToSpeechAction actionType], [HSPauseAction actionType], [HSRunAppleScriptAction actionType], [HSSetCursorPositionAction actionType], [HSQuitAnotherApplicationAction actionType], [HSAutoRecordAction actionType], [HSSpeechRecognitionAction actionType], [HSClearChangeFlagAction actionType], [HSShowInFinderAction actionType], [HSReadWriteTextAction actionType], [HSPictureShowAction actionType], [HSTestingFunctionsAction actionType], [HSSetVolumeAction actionType], [HSScrollCardAction actionType], [HSButtonListerAction actionType], [HSKeyMapperAction actionType], [HSPrintCardAction actionType], [HSButtonScannerAction actionType], [HSButtonStepperAction actionType], [HSShowHideCursorAction actionType], [HSGoogleEarthAction actionType], nil];
    return unsupportediBooksActionTypes;
}

+ (id)allowediBooksHomeStackActionTypes
{
    static NSArray *allowediBooksHomeStackActionTypes;
    if (allowediBooksHomeStackActionTypes == nil)
        allowediBooksHomeStackActionTypes = [[NSArray alloc] initWithObjects:[HSRunCommandAction actionType], nil];
    return allowediBooksHomeStackActionTypes;
}

@end
