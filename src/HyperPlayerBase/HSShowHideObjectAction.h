#import "HyperPlayerBasePrefix.h"
#import "HSScriptAction.h"


@interface HSShowHideObjectAction : HSToDoAction <HSShowHideObjectActionAttributes, HSActionAttributes, HSAttributes, HyperInterface, NSObject, HSAction, HSActionSynchronousAttribute, HSAttribute, HSActionEventsAttribute, HSActionLocalizedNameAttribute, HSShowHideObjectsAttribute>
{
    NSMutableArray *_unsupportedTransitions;
    NSMutableDictionary *_objectUIDsToActionMap;
    int _runningCount;
    NSMutableDictionary *_hideOnFinishMap;
    HSNavigationOperation *_navigationOperation;
    HSActionExecutionContext *_context;
}
- (void)importFromXMLElementRepresentation:(id)aRepresentation inContext:(id)aContext;
- (id)importXMLTransitionSettingsFromElement:(id)aElement;
- (id)XMLElementRepresentationInContext:(id)aContext;
- (id)XMLTransitionElementForName:(id)aName WithSettings:(id)aSettings;
- (NSInteger)visibilityActionTypeFromString:(id)aString;
- (id)visibilityActionTypeToString:(NSInteger)aString;
- (BOOL)canBeStoredAsXMLElement;
- (id)XMLElementName;
- (BOOL)supportedInIPad;
- (BOOL)canBeExportedToHTML5DocumentType:(id)aType;
- (id)HTML5DictionaryRepresentationInContext:(id)aContext;
- (id)HTML5UnsupportedFeaturesForDocumentType:(id)aType;
- (BOOL)hasUnsupportedHTML5FeaturesForDocumentType:(id)aType;
- (BOOL)hasUnsupportedTransitionNames:(id *)aNames;
- (BOOL)isValid;
- (void)notifyDidFinish;
- (void)HSShowHideObjectAction_stopShowHideTransitionForObject:(id)aObject;
- (void)stop:(id)aStop;
- (BOOL)canBeStopped;
- (void)addObjectUID:(id)aUID action:(NSInteger)aAction showEffectSettings:(id)aSettings hideEffectSettings:(id)aSettings2;
- (id)hideEffectSettingsWithUID:(id)aUID;
- (id)showEffectSettingsWithUID:(id)aUID;
- (NSInteger)actionForObjectWithUID:(id)aUID;
- (id)objectsToToggle;
- (id)objectsToHide;
- (id)objectsToShow;
- (id)objectsWithAction:(NSInteger)aAction;
- (void)HSShowHideObjectAction_transitionDidFinish:(id)aFinish;
- (void)HSShowHideObjectAction_runShowHideTransitionForObject:(id)aObject transitionAttributes:(id)aAttributes transitionSettings:(id)aSettings hideOnFinish:(BOOL)aFinish;
- (id)HSShowHideObjectAction_copyShowHideTransitionAttributesForObject:(id)aObject effectType:(NSInteger)aType settings:(id *)aSettings;
- (void)navigationOperationStageDidChange:(id)aChange;
- (void)startInContext:(id)aContext;
- (void)startAction;
- (void)showCardObject:(id)aObject;
- (void)hideCardObject:(id)aObject;
- (id)objectForUID:(id)aUID;
- (void)mergeInShowHideObjectAction:(id)aAction replacingObjectUIDs:(id)aDs sortedByPriority:(id)aPriority withImageObjectUID:(id)aUID;
- (id)copyReplacingObjectUIDs:(id)aDs sortedByPriority:(id)aPriority withImageObjectUID:(id)aUID;
- (void)loadExtraDictionaryRepresentation:(id)aRepresentation withCodingContext:(id)aContext;
- (id)keysForExtraStoringWithCodingContext:(id)aContext;
- (void)setObjectUIDsToActionsMapForSerialization:(id)aSerialization;
- (void)setUIDStringsToActionsMap:(id)aMap;
- (id)objectUIDsToActionsMapForSerialization;
- (id)UIDStringsToActionsMap;
- (id)objectUIDsToActionMap;
- (void)dealloc;
- (id)init;
- (void)removeUnsupportedFeatures;
- (void)clearUnsupportedTransitions;
- (id)unsupportedTransitions;
- (id)HTML5UnsupportedFunctionalityDescriptionForTransitionName:(id)aName;
@end

