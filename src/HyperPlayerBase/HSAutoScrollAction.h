#import "HyperPlayerBasePrefix.h"
#import "HSTextViewProcessingAction.h"


@interface HSAutoScrollAction : HSTextViewProcessingAction <HSAutoScrollActionAttributes, HSTextViewProcessingActionAttributes, HSActionAttributes, HSAttributes, HyperInterface, NSObject, HSAction, HSActionSynchronousAttribute, HSAttribute, HSActionEventsAttribute, HSActionLocalizedNameAttribute, HSTextViewUIDsAttribute, HSTextViewNamesAttribute, HSAutoScrollNumberOfStepsAttribute, HSAutoScrollStepsPerSecondAttribute, HSAutoScrollScrollAmountAttribute, HSAutoScrollScrollDirectionAttribute, HSAutoScrollIgnoreMouseClicksAttribute>
{
    int _numberOfSteps;
    int _stepsPerSecond;
    int _scrollAmount;
    int _scrollDirection;
    int _scrollUnits;
    NSTimer *_timer;
    NSDate *_timerTickDate;
    double _timePassedSinceTimerStart;
    BOOL _ignoreMouseClicks;
}
- (id)HTML5DictionaryRepresentationInContext:(id)aContext;
- (BOOL)canBeExportedToHTML5DocumentType:(id)aType;
- (BOOL)isValid;
- (void)textViewPerformedClick:(id)aClick;
- (void)setIgnoreMouseClicks:(BOOL)aClicks;
- (BOOL)ignoreMouseClicks;
- (void)setScrollUnits:(NSInteger)aUnits;
- (NSInteger)scrollUnits;
- (void)setScrollDirection:(NSInteger)aDirection;
- (NSInteger)scrollDirection;
- (void)setScrollAmount:(NSInteger)aAmount;
- (NSInteger)scrollAmount;
- (void)setStepsPerSecond:(NSInteger)aSecond;
- (NSInteger)stepsPerSecond;
- (void)setNumberOfSteps:(NSInteger)aSteps;
- (NSInteger)numberOfSteps;
- (void)fireTimer:(id)aTimer;
- (void)scrollTextViewHorizontally:(id)aHorizontally;
- (void)scrollTextViewVertically:(id)aVertically;
- (void)stop:(id)aStop;
- (BOOL)canBeStopped;
- (void)startInContext:(id)aContext;
- (void)systemTextViewHiddenChanged:(id)aChanged;
- (void)restoreSystemTextView:(id)aView;
- (void)prepareSystemTextView:(id)aView;
- (void)restoreTextViewParameters;
- (id)keysForExtraStoringWithCodingContext:(id)aContext;
- (void)notifyDidFinish;
- (void)dealloc;
- (id)init;
- (void)stopScrolling;
- (void)invalidateTimer;
- (id)XMLElementName;
- (id)XMLElementRepresentationInContext:(id)aContext;
- (BOOL)canBeStoredAsXMLElement;
- (BOOL)supportedInIPad;
- (void)pause;
- (void)resume;
- (void)didConnectToDocument;
- (void)willDisconnectFromDocument;
- (void)cardChildrenAttributeDidChange:(id)aChange;
- (void)rotatableAttributeDidChange:(id)aChange;
@end

