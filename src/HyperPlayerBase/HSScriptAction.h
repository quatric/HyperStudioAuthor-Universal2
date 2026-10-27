#import "HyperPlayerBasePrefix.h"
#import "HSObject.h"


@interface HSAction : HSObject <HSAttributeObserving, NSObject, HSActionAttributes, HSAttributes, HyperInterface, HSAction, HSActionSynchronousAttribute, HSAttribute, HSActionEventsAttribute, HSActionLocalizedNameAttribute, HSActionValidation, HSActionValidationStatusAttribute, EXKeyValueCoding, NSCopying, HSXMLStoringSupport, HSXMLLoadingSupport, HSHTML5ExportSupport>
{
    id<HSActionOwner> _owner;
    BOOL _synchronous;
    NSArray *_events;
    unsigned int _shouldBeRemoved:1;
}
+ (id)tooltip;
+ (id)localizedNameInInspector;
+ (id)actionsNamedWithEllipsis;
+ (id)localizedName;
+ (id)action;
+ (id)actionOfType:(id)aType;
+ (id)actionType;
+ (BOOL)accessInstanceVariablesDirectly;
- (void)importFromXMLElementRepresentation:(id)aRepresentation inContext:(id)aContext;
- (id)XMLElementName;
- (BOOL)canBeStoredAsXMLElement;
- (id)XMLElementRepresentationInContext:(id)aContext;
- (id)HTML5UnsupportedFeaturesForDocumentType:(id)aType;
- (BOOL)hasUnsupportedHTML5FeaturesForDocumentType:(id)aType;
- (id)HTML5UnsupportedFunctionalityDescription;
- (BOOL)shouldBeExportedAsImage;
- (id)HTML5DictionaryRepresentationInContext:(id)aContext;
- (BOOL)canBeExportedToHTML5DocumentType:(id)aType;
- (void)updateActionValidationStatus;
- (BOOL)isAbleToStartInInvalidState;
- (BOOL)isValid;
- (BOOL)wantsSaveAfterRemove;
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
- (void)loadExtraDictionaryRepresentation:(id)aRepresentation withCodingContext:(id)aContext;
- (id)keysForExtraStoringWithCodingContext:(id)aContext;
- (BOOL)canChangeSynchronousFlag;
- (void)setSynchronous:(BOOL)aSynchronous;
- (BOOL)isSynchronous;
- (id)undoManager;
- (void)convertOldVersionAttributesIfNeeded;
- (void)willDisconnectFromDocument;
- (void)didConnectToDocument;
- (void)willRemoveFromDocument;
- (void)didAddToDocument;
- (void)performPrimarySetupOnCard:(id)aCard actionExecutionContext:(id)aContext;
- (void)notifyDidFinish;
- (void)stop:(id)aStop;
- (BOOL)canBeStopped;
- (BOOL)canRunInContext:(id)aContext;
- (void)startInContext:(id)aContext;
- (void)removeActionEvent:(id)aEvent;
- (void)addActionEvent:(id)aEvent;
- (void)setEvents:(id)aEvents;
- (id)events;
- (BOOL)runsWithActionEvent:(id)aEvent;
- (BOOL)supportedInIPad;
- (BOOL)supportedInStackToGo;
- (BOOL)supportedInWebPlayer;
- (id)copyReplacingObjectUIDs:(id)aDs sortedByPriority:(id)aPriority withImageObjectUID:(id)aUID;
- (BOOL)isKindOfType:(id)aType;
- (id)card;
- (id)stack;
- (void)pause;
- (void)resume;
- (void)removeUnsupportedFeatures;
- (BOOL)shouldBeRemoved;
- (void)setShouldBeRemoved:(BOOL)aRemoved;
- (id)localizedNameInInspector;
- (id)localizedName;
- (id)document;
- (id)queryHyperInterface:(id)aInterface;
- (id)hyperObject;
- (void)ownerDidChange;
- (void)ownerWillChange;
- (void)setOwner:(id)aOwner;
- (id)owner;
- (void)dealloc;
- (id)copyWithZone:(NSZone *)aZone;
@end

@interface HSToDoAction : HSAction
{
}
@end

@interface HSScriptAction : HSToDoAction
{
}
@end

@interface HSNBAAction : HSAction
{
}
- (id)initWithExtraDictionary:(id)aDictionary codingContext:(id)aContext;
@end

@interface HSToGoAction : HSAction
{
}
- (BOOL)supportedInIPad;
- (BOOL)canChangeSynchronousFlag;
- (BOOL)isSynchronous;
@end

