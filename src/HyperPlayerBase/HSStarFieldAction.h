#import "HyperPlayerBasePrefix.h"
#import "HSScriptAction.h"


@interface HSStarFieldAction : HSNBAAction <HSStarFieldActionAttributes, HSActionAttributes, HSAttributes, HyperInterface, NSObject, HSAction, HSActionSynchronousAttribute, HSAttribute, HSActionEventsAttribute, HSActionLocalizedNameAttribute, HSStarFieldDurationAttribute, HSStarFieldDurationModeAttribute>
{
    int _starFieldDurationMode;
    double _starFieldDuration;
    HSGraphicComposition *_graphicComposition;
    HSActionExecutionContext *_context;
    double _remainingDuration;
    BOOL _stopOnMouseClick;
    NSDate *_startDate;
}
+ (NSInteger)starFieldDurationModeFromStringForXMLStoring:(id)aStoring;
+ (id)stringForXMLStoringFromStarFieldDurationType:(NSInteger)aType;
- (void)importFromXMLElementRepresentation:(id)aRepresentation inContext:(id)aContext;
- (id)XMLElementRepresentationInContext:(id)aContext;
- (id)XMLElementName;
- (BOOL)canBeStoredAsXMLElement;
- (id)HTML5DictionaryRepresentationInContext:(id)aContext;
- (BOOL)canBeExportedToHTML5DocumentType:(id)aType;
- (BOOL)supportedInIPad;
- (void)notifyDidFinish;
- (void)setStarFieldDuration:(double)aDuration;
- (double)starFieldDuration;
- (void)setStarFieldDurationMode:(NSInteger)aMode;
- (NSInteger)starFieldDurationMode;
- (void)HSStarFieldAction_actionExecutionContextGraphicCompositionDidStop:(id)aStop;
- (void)startInContext:(id)aContext;
- (void)stop:(id)aStop;
- (BOOL)canBeStopped;
- (id)keysForExtraStoringWithCodingContext:(id)aContext;
- (void)dealloc;
- (id)init;
- (void)pause;
- (void)resume;
@end

