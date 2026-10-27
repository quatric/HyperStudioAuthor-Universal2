#import "HyperPlayerBasePrefix.h"
#import "HSSpecialAccessAction.h"


@interface HSButtonScannerAction : HSSpecialAccessAction <HSButtonScannerActionAttributes, HSSpecialAccessActionAttributes, HSActionAttributes, HSAttributes, HyperInterface, NSObject, HSAction, HSActionSynchronousAttribute, HSAttribute, HSActionEventsAttribute, HSActionLocalizedNameAttribute, HSSpecialAccessAudioCueAttribute, HSSpecialAccessAudioMediaAttribute, HSButtonScannerScanDelayAttribute, HSButtonScannerResetDelayAttribute, HSButtonScannerScanCyclesAttribute, HSButtonScannerHidesCursorAttribute, HSEventResponderActionInterface, HyperObject>
{
    float _scanDelay;
    float _resetDelay;
    unsigned int _scanCyclesCount;
    NSArray *_availableObjects;
    NSUInteger _curentButtonIndex;  // unsigned int on i386; widened so NSNotFound fits
    HSActionExecutionContext *_context;
    unsigned int _cyclesDoneCount;
    BOOL _isChildActionRunning;
    BOOL _hidesCursor;
    id<HSStackAttributes> _currentStack;
}
- (BOOL)canBeExportedToHTML5DocumentType:(id)aType;
- (id)HTML5DictionaryRepresentationInContext:(id)aContext;
- (id)XMLElementRepresentationInContext:(id)aContext;
- (id)XMLElementName;
- (BOOL)supportedInIPad;
- (BOOL)canBeStoredAsXMLElement;
- (void)actionsForObject:(id)aObject didFinishForEvent:(id)aEvent inActionExecutionManager:(id)aManager;
- (BOOL)handleMouseDownEvent:(id)aEvent;
- (BOOL)handleKeyUpEvent:(id)aEvent;
- (BOOL)handleKeyDownEvent:(id)aEvent;
- (BOOL)isButtonScannerEvent:(id)aEvent;
- (void)stop:(id)aStop;
- (BOOL)canBeStopped;
- (void)startInContext:(id)aContext;
- (void)runActionsForActiveObject;
- (id)activeObject;
- (void)moveToNextButton;
- (void)setCurentButtonIndex:(NSUInteger)aIndex;
- (NSUInteger)currentButtonIndex;
- (void)containerAttributeDidChange:(id)aChange;
- (void)setCurrentStack:(id)aStack;
- (id)availableButtons;
- (BOOL)canUseObject:(id)aObject;
- (BOOL)isValid;
- (id)keysForExtraStoringWithCodingContext:(id)aContext;
- (void)setHidesCursor:(BOOL)aCursor;
- (BOOL)hidesCursor;
- (void)setScanCyclesCount:(NSUInteger)aCount;
- (NSUInteger)scanCyclesCount;
- (void)setResetDelay:(CGFloat)aDelay;
- (CGFloat)resetDelay;
- (void)setScanDelay:(CGFloat)aDelay;
- (CGFloat)scanDelay;
- (void)dealloc;
- (id)init;
@end

