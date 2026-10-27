#import "HyperPlayerBasePrefix.h"
#import "HSScriptAction.h"


@interface HSSequencerAction : HSNBAAction <HSSequencerActionAttributes, HSActionAttributes, HSAttributes, HyperInterface, NSObject, HSAction, HSActionSynchronousAttribute, HSAttribute, HSActionEventsAttribute, HSActionLocalizedNameAttribute, HSSequenceItemsAttribute>
{
    NSArray *_sequenceItems;
    NSArray *_objectsWithRunningActions;
    HSActionExecutionContext *_context;
    BOOL _oldFormat;
}
- (BOOL)isValid;
- (void)importFromXMLElementRepresentation:(id)aRepresentation inContext:(id)aContext;
- (id)XMLElementRepresentationInContext:(id)aContext;
- (id)XMLElementName;
- (BOOL)canBeStoredAsXMLElement;
- (BOOL)supportedInIPad;
- (id)HTML5DictionaryRepresentationInContext:(id)aContext;
- (BOOL)canBeExportedToHTML5DocumentType:(id)aType;
- (void)actionsForObject:(id)aObject didFinishForEvent:(id)aEvent inActionExecutionManager:(id)aManager;
- (BOOL)shouldIgnoreObject:(id)aObject withDelay:(CGFloat)aDelay;
- (void)getObjects:(id *)aObjects delays:(id *)aDelays forSequenceItems:(id)aItems;
- (id)objectsWithSequenceItems:(id)aItems;
- (id)sequenceItemForObjectWithUID:(id)aUID;
- (id)objectWithUID:(id)aUID;
- (void)convertOldVersionAttributesIfNeeded;
- (void)setObjectUIDs:(id)aDs;
- (void)setSequenceItems:(id)aItems;
- (id)objectUIDsForSequnceItems:(id)aItems;
- (id)sequenceItems;
- (void)setObjectsWithRunningActions:(id)aActions;
- (id)objectsWithRunningActions;
- (void)startInContext:(id)aContext;
- (void)stop:(id)aStop;
- (BOOL)canBeStopped;
- (void)notifyDidFinish;
- (id)keysForExtraLoadingWithCodingContext:(id)aContext;
- (id)keysForExtraStoringWithCodingContext:(id)aContext;
- (void)mergeInSequencerAction:(id)aAction replacingObjectUIDs:(id)aDs sortedByPriority:(id)aPriority withImageObjectUID:(id)aUID;
- (id)copyReplacingObjectUIDs:(id)aDs sortedByPriority:(id)aPriority withImageObjectUID:(id)aUID;
- (void)dealloc;
@end

@interface HSSequenceItem : NSObject <EXKeyValueCoding, NSCopying>
{
    HSUID *_objectUID;
    float _delay;
}
- (id)keysForExtraStoringWithCodingContext:(id)aContext;
- (CGFloat)delay;
- (void)setDelay:(CGFloat)aDelay;
- (id)objectUID;
- (void)setObjectUID:(id)aUID;
- (void)dealloc;
- (id)initWithUID:(id)aUID withDelay:(CGFloat)aDelay;
- (id)copyWithZone:(NSZone *)aZone;
@end

