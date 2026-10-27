#import "HyperPlayerBasePrefix.h"
#import "HSSpecialAccessAction.h"


@interface HSButtonStepperAction : HSSpecialAccessAction <HSButtonStepperActionAttributes, HSSpecialAccessActionAttributes, HSActionAttributes, HSAttributes, HyperInterface, NSObject, HSAction, HSActionSynchronousAttribute, HSAttribute, HSActionEventsAttribute, HSActionLocalizedNameAttribute, HSSpecialAccessAudioCueAttribute, HSSpecialAccessAudioMediaAttribute, HSButtonStepperButtonsAttribute, HSEventResponderActionInterface, HyperObject>
{
    NSArray *_buttonUIDs;
    int _curentButtonIndex;
    HSActionExecutionContext *_context;
    NSArray *_availableObjects;
}
- (BOOL)canBeExportedToHTML5DocumentType:(id)aType;
- (id)HTML5DictionaryRepresentationInContext:(id)aContext;
- (id)XMLElementRepresentationInContext:(id)aContext;
- (id)XMLElementName;
- (BOOL)supportedInIPad;
- (BOOL)canBeStoredAsXMLElement;
- (BOOL)handleKeyUpEvent:(id)aEvent;
- (BOOL)handleMouseDownEvent:(id)aEvent;
- (BOOL)handleKeyDownEvent:(id)aEvent;
- (void)runActionsForActiveObject;
- (BOOL)isObjectActivationEvent:(id)aEvent;
- (BOOL)isMoveBackwardEvent:(id)aEvent;
- (BOOL)isMoveForwardEvent:(id)aEvent;
- (void)stop:(id)aStop;
- (BOOL)canBeStopped;
- (void)startInContext:(id)aContext;
- (id)activeObject;
- (void)setCurentButtonIndex:(NSInteger)aIndex;
- (NSInteger)currentButtonIndex;
- (id)availableButtons;
- (BOOL)canUseObject:(id)aObject;
- (id)keysForExtraStoringWithCodingContext:(id)aContext;
- (void)setButtonUIDs:(id)aDs;
- (id)buttonUIDs;
- (void)mergeInButtonStepperAction:(id)aAction replacingObjectUIDs:(id)aDs sortedByPriority:(id)aPriority withImageObjectUID:(id)aUID;
- (id)copyReplacingObjectUIDs:(id)aDs sortedByPriority:(id)aPriority withImageObjectUID:(id)aUID;
- (void)dealloc;
@end

