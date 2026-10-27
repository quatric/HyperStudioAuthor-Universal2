#import "HyperPlayerBasePrefix.h"
#import "HSSpecialAccessAction.h"


@interface HSButtonListerAction : HSSpecialAccessAction <HSButtonListerActionAttributes, HSSpecialAccessActionAttributes, HSActionAttributes, HSAttributes, HyperInterface, NSObject, HSAction, HSActionSynchronousAttribute, HSAttribute, HSActionEventsAttribute, HSActionLocalizedNameAttribute, HSSpecialAccessAudioCueAttribute, HSSpecialAccessAudioMediaAttribute, HSButtonListerRepeatAttribute, HSButtonListerDelayAttribute, HSButtonListerButtonsAttribute, HSEventResponderActionInterface, HyperObject>
{
    float _performDelay;
    BOOL _shouldRepeat;
    NSArray *_buttonUIDs;
    NSArray *_availableObjects;
    HSActionExecutionContext *_context;
    int _curentButtonIndex;
}
- (BOOL)canBeExportedToHTML5DocumentType:(id)aType;
- (id)HTML5DictionaryRepresentationInContext:(id)aContext;
- (id)XMLElementRepresentationInContext:(id)aContext;
- (id)XMLElementName;
- (BOOL)supportedInIPad;
- (BOOL)canBeStoredAsXMLElement;
- (BOOL)handleMouseDownEvent:(id)aEvent;
- (BOOL)handleKeyUpEvent:(id)aEvent;
- (BOOL)handleKeyDownEvent:(id)aEvent;
- (BOOL)isMoveBackwardEvent:(id)aEvent;
- (BOOL)isMoveForwardEvent:(id)aEvent;
- (void)stop:(id)aStop;
- (BOOL)canBeStopped;
- (void)startInContext:(id)aContext;
- (id)activeObject;
- (void)setCurentButtonIndex:(NSInteger)aIndex;
- (NSInteger)currentButtonIndex;
- (void)runActionsForActiveObject;
- (id)availableButtons;
- (BOOL)canUseObject:(id)aObject;
- (id)keysForExtraStoringWithCodingContext:(id)aContext;
- (void)setShouldRepeat:(BOOL)aRepeat;
- (void)setPerformDelay:(CGFloat)aDelay;
- (BOOL)shouldRepeat;
- (CGFloat)performDelay;
- (void)setButtonUIDs:(id)aDs;
- (id)buttonUIDs;
- (void)mergeInButtonListerAction:(id)aAction replacingObjectUIDs:(id)aDs sortedByPriority:(id)aPriority withImageObjectUID:(id)aUID;
- (id)copyReplacingObjectUIDs:(id)aDs sortedByPriority:(id)aPriority withImageObjectUID:(id)aUID;
- (void)dealloc;
@end

