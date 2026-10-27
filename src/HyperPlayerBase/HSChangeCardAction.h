#import "HyperPlayerBasePrefix.h"
#import "HSScriptAction.h"


@interface HSChangeCardAction : HSToGoAction <HSChangeCardActionAttributes, HSActionAttributes, HSAttributes, HyperInterface, NSObject, HSAction, HSActionSynchronousAttribute, HSAttribute, HSActionEventsAttribute, HSActionLocalizedNameAttribute, HSTransitionOwner, HSTransitionAttribute, HSXMLTransitionStoringSupport>
{
    HSActionExecutionContext *_context;
    HSTransition *_transition;
    double _transitionDuration;
    HSNavigationOperation *_navigationOperation;
    HSAlert *_alert;
    BOOL _isRunning;
}
- (void)importFromXMLElementRepresentation:(id)aRepresentation inContext:(id)aContext;
- (id)XMLElementRepresentationInContext:(id)aContext;
- (id)xmlTransitionElement;
- (id)HTML5UnsupportedFeaturesForDocumentType:(id)aType;
- (BOOL)hasUnsupportedHTML5FeaturesForDocumentType:(id)aType;
- (id)HTML5DictionaryRepresentationInContext:(id)aContext;
- (void)stopCurrentNavigationOperation;
- (void)notifyDidFinish;
- (void)alertDidEnd:(id)aEnd returnCode:(NSInteger)aCode contextInfo:(void *)aInfo;
- (void)navigationOperationStageDidChange:(id)aChange;
- (void)startInContext:(id)aContext;
- (BOOL)canRunInContext:(id)aContext;
- (BOOL)canBeStopped;
- (void)setAndPerformNavigationOperationInContext:(id)aContext;
- (void)willConcludeNavigationOperation:(id)aOperation;
- (void)willStartNavigationOperation:(id)aOperation;
- (id)createNavigationOperation;
- (id)alert;
- (id)cantChangeCardAlertMessage;
- (id)cantChangeCardAlertTitle;
- (id)attributeNotificationCenterForTransition:(id)aTransition;
- (id)undoManagerForTransition:(id)aTransition;
- (BOOL)canGoToHyperDestinationCard;
- (void)setTransition:(id)aTransition;
- (id)transition;
- (id)queryHyperInterface:(id)aInterface;
- (id)keysForExtraStoringWithCodingContext:(id)aContext;
- (void)dealloc;
@end

