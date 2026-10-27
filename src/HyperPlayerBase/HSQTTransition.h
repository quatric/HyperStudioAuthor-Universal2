#import "HyperPlayerBasePrefix.h"


@interface HSTransition : NSObject <HSAttributeObserving, NSObject, HSTransitionAttributes, HSTransitionNameAttribute, HSAttribute, HSTransitionDisplayNameAttribute, HSTransitionSoundAttribute, HSTransitionDurationAttribute, HSTransitionSoundPlaybackModeAttribute, HSHTML5ExportSupport, HSAttributes, HyperInterface, EXKeyValueCoding>
{
    NSString *_name;
    HSTransitionEffect *_effect;
    double _duration;
    id _sound;
    int _soundMode;
    id _delegate;
    BOOL _isPlaying;
    BOOL _shouldStopOnMouseClick;
}
+ (id)oppositeTransitionForTransition:(id)aTransition;
+ (id)transitionWithName:(id)aName;
- (id)HTML5UnsupportedFeaturesForDocumentType:(id)aType;
- (BOOL)hasUnsupportedHTML5FeaturesForDocumentType:(id)aType;
- (BOOL)shouldBeExportedAsImage;
- (id)HTML5UnsupportedFunctionalityDescription;
- (BOOL)canBeExportedToHTML5DocumentType:(id)aType;
- (id)HTML5DictionaryRepresentationInContext:(id)aContext;
- (id)attributesChangedTemporary;
- (id)attributesBeingChangedContinuously;
- (void)endContinuousChangeOfAttributeSet:(id)aSet;
- (void)beginContinuousChangeOfAttributeSet:(id)aSet;
- (void)endContinuousChangeOfAttribute:(id)aAttribute;
- (void)beginContinuousChangeOfAttribute:(id)aAttribute;
- (void)removeAttributeObserver:(id)aObserver;
- (void)removeAttributeObserver:(id)aObserver selector:(SEL)aSelector;
- (void)removeObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributesOfHyperInterfaces:(id *)aInterfaces;
- (void)removeObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributesOfHyperInterface:(id)aInterface;
- (void)removeObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributesFromSet:(id)aSet;
- (void)removeObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributes:(id *)aAttributes;
- (void)removeObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttribute:(id)aAttribute;
- (void)addObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributesOfHyperInterfaces:(id *)aInterfaces withPriority:(CGFloat)aPriority;
- (void)addObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributesOfHyperInterface:(id)aInterface withPriority:(CGFloat)aPriority;
- (void)addObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributesFromSet:(id)aSet withPriority:(CGFloat)aPriority;
- (void)addObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributes:(id *)aAttributes withPriority:(CGFloat)aPriority;
- (void)addObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttribute:(id)aAttribute withPriority:(CGFloat)aPriority;
- (id)attributeObservingController;
- (id)attributeNotificationCenter;
- (id)undoManager;
- (void)setDelegate:(id)aDelegate;
- (id)delegate;
- (BOOL)isFastestTransition;
- (void)setShouldStopOnMouseClick:(BOOL)aClick;
- (BOOL)shouldStopOnMouseClick;
- (void)setSoundPlaybackMode:(NSInteger)aMode;
- (NSInteger)soundPlaybackMode;
- (void)setDuration:(double)aDuration;
- (double)duration;
- (void)setSound:(id)aSound;
- (id)sound;
- (id)displayName;
- (id)effect;
- (void)setEffect:(id)aEffect;
- (void)setTransitionName:(id)aName;
- (id)transitionName;
- (NSUInteger)hash;
- (BOOL)isEqual:(id)aEqual;
- (void)loadExtraDictionaryRepresentation:(id)aRepresentation withCodingContext:(id)aContext;
- (double)_duration;
- (void)set_transitionName:(id)aName;
- (id)_transitionName;
- (void)set_compositionName:(id)aName;
- (id)_compositionName;
- (void)setName:(id)aName;
- (id)name;
- (id)keysForExtraLoadingWithCodingContext:(id)aContext;
- (id)keysForExtraStoringWithCodingContext:(id)aContext;
- (id)HSTransition_nameKeyToMaintainForwardCompatibility;
- (id)extraClassNameForStoring;
- (id)HSTransition_QTTransitionNames;
- (id)HSTransition_QCTransitionNames;
- (void)dealloc;
- (id)initWithName:(id)aName;
- (id)init;
- (void)removeUnsupportedFeatures;
@end

@interface HSQTTransition : HSTransition
{
}
+ (id)allocWithZone:(NSZone *)aZone;
@end

@interface HSQCViewTransition : HSTransition
{
}
+ (id)allocWithZone:(NSZone *)aZone;
@end

@interface HSFastestTransition : HSTransition
{
}
+ (id)allocWithZone:(NSZone *)aZone;
@end

