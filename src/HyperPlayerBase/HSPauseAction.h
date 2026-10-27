#import "HyperPlayerBasePrefix.h"
#import "HSScriptAction.h"


@interface HSPauseAction : HSNBAAction <HSPauseActionAttributes, HSActionAttributes, HSAttributes, HyperInterface, NSObject, HSAction, HSActionSynchronousAttribute, HSAttribute, HSActionEventsAttribute, HSActionLocalizedNameAttribute, HSPauseDurationAttribute>
{
    double _pauseDuration;
    NSTimer *_pauseTimer;
}
- (void)importFromXMLElementRepresentation:(id)aRepresentation inContext:(id)aContext;
- (id)XMLElementRepresentationInContext:(id)aContext;
- (id)XMLElementName;
- (BOOL)canBeStoredAsXMLElement;
- (BOOL)supportedInIPad;
- (void)setPauseDuration:(double)aDuration;
- (double)pauseDuration;
- (void)pauseTimerInvalidated:(id)aInvalidated;
- (void)startInContext:(id)aContext;
- (void)stop:(id)aStop;
- (BOOL)canBeStopped;
- (BOOL)isSynchronous;
- (BOOL)canChangeSynchronousFlag;
- (id)keysForExtraStoringWithCodingContext:(id)aContext;
- (void)dealloc;
- (id)initWithDuration:(double)aDuration;
- (id)init;
@end

