#import "HyperPlayerBasePrefix.h"
#import "HSScriptAction.h"


@interface HSSlideShowAction : HSNBAAction <HSSlideShowActionAttributes, HSActionAttributes, HSAttributes, HyperInterface, NSObject, HSAction, HSActionSynchronousAttribute, HSAttribute, HSActionEventsAttribute, HSActionLocalizedNameAttribute, HSSlideTransitionAttribute, HSSlideDurationAttribute, HSReturnsToOriginalCardAttribute, HSLoopSlideShowAttribute, HSUseClickOnExitCardAttribute>
{
    HSTransition *_slideTransition;
    double _slideDuration;
    BOOL _returnsToOriginalCard;
    BOOL _loopSlideShow;
    BOOL _useClickOnExitCard;
}
- (id)attributeNotificationCenterForTransition:(id)aTransition;
- (id)undoManagerForTransition:(id)aTransition;
- (id)destinationCard;
- (id)sourceCard;
- (void)setUseClickOnExitCard:(BOOL)aCard;
- (BOOL)useClickOnExitCard;
- (void)setLoopSlideShow:(BOOL)aShow;
- (BOOL)loopSlideShow;
- (void)setReturnsToOriginalCard:(BOOL)aCard;
- (BOOL)returnsToOriginalCard;
- (void)setSlideDuration:(double)aDuration;
- (double)slideDuration;
- (void)HSSlideShowAction_transitionEffectChange:(id)aChange;
- (void)setSlideTransition:(id)aTransition;
- (id)slideTransition;
- (void)startInContext:(id)aContext;
- (id)keysForExtraStoringWithCodingContext:(id)aContext;
- (void)dealloc;
- (id)init;
@end

