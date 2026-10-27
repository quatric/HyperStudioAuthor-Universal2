#import "HyperPlayerBasePrefix.h"


@interface HSAutomaticTimer : NSObject <HSAutomaticTimerAttributes, HSAttributes, HyperInterface, NSObject, HSAutomaticTimerActionsEnabledAttribute, HSAttribute, HSAutomaticTimerActionsDelayAttribute, HSAutomaticTimerActionsDelayBetweenRepeatingActionsAttribute, HSAttributeObserving, EXKeyValueCoding>
{
    HSActor *_actor;
    BOOL _runActionsAutomatically;
    double _delayBeforeRunActionsAutomatically;
    double _delayBetweenRepeatingActions;
}
- (void)loadExtraDictionaryRepresentation:(id)aRepresentation withCodingContext:(id)aContext;
- (id)keysForExtraLoadingWithCodingContext:(id)aContext;
- (id)keysForExtraStoringWithCodingContext:(id)aContext;
- (void)setRepeating:(BOOL)aRepeating;
- (BOOL)isRepeating;
- (id)implementationForHyperObject:(id)aObject;
- (id)hyperObject;
- (BOOL)implementsHyperInterface:(id)aInterface;
- (id)queryHyperInterface:(id)aInterface;
- (id)attributesChangedTemporary;
- (id)attributesBeingChangedContinuously;
- (void)removeObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributesFromSet:(id)aSet;
- (void)addObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributesFromSet:(id)aSet withPriority:(CGFloat)aPriority;
- (void)endContinuousChangeOfAttributeSet:(id)aSet;
- (void)beginContinuousChangeOfAttributeSet:(id)aSet;
- (void)endContinuousChangeOfAttribute:(id)aAttribute;
- (void)beginContinuousChangeOfAttribute:(id)aAttribute;
- (void)removeAttributeObserver:(id)aObserver;
- (void)removeAttributeObserver:(id)aObserver selector:(SEL)aSelector;
- (void)removeObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributesOfHyperInterfaces:(id *)aInterfaces;
- (void)removeObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributesOfHyperInterface:(id)aInterface;
- (void)removeObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributes:(id *)aAttributes;
- (void)removeObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttribute:(id)aAttribute;
- (void)addObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributesOfHyperInterfaces:(id *)aInterfaces withPriority:(CGFloat)aPriority;
- (void)addObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributesOfHyperInterface:(id)aInterface withPriority:(CGFloat)aPriority;
- (void)addObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributes:(id *)aAttributes withPriority:(CGFloat)aPriority;
- (void)addObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttribute:(id)aAttribute withPriority:(CGFloat)aPriority;
- (id)attributeObservingController;
- (void)setDelayBetweenRepeatingActions:(double)aActions;
- (double)delayBetweenRepeatingActions;
- (void)setDelayBeforeRunActionsAutomatically:(double)aAutomatically;
- (double)delayBeforeRunActionsAutomatically;
- (void)setRunActionsAutomatically:(BOOL)aAutomatically;
- (BOOL)runActionsAutomatically;
- (id)attributeNotificationCenter;
- (id)undoManager;
- (void)setActor:(id)aActor;
- (id)actor;
- (id)initActive:(BOOL)aActive;
- (id)init;
@end

