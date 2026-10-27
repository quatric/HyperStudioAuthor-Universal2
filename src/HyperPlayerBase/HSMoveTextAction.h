#import "HyperPlayerBasePrefix.h"
#import "HSScriptAction.h"


@interface HSMoveTextAction : HSNBAAction <HSMoveTextActionAttributes, HSActionAttributes, HSAttributes, HyperInterface, NSObject, HSAction, HSActionSynchronousAttribute, HSAttribute, HSActionEventsAttribute, HSActionLocalizedNameAttribute, HSMoveTextSourceObjectUIDAttribute, HSMoveTextDestinationObjectUIDAttribute, HSMoveTextSourceDataTypeAttribute, HSMoveTextSourceActionAttribute, HSMoveTextDestinationActionAttribute>
{
    HSActionExecutionContext *_context;
    HSUID *_sourceObjectUID;
    HSUID *_destinationObjectUID;
    int _sourceDataType;
    int _sourceAction;
    int _destinationAction;
    id _sourceObject;
    id _destinationObject;
}
+ (NSInteger)moveTextDestinationActionFromStringForXMLStoring:(id)aStoring;
+ (id)stringForXMLStoringFromMoveTextDestinationAction:(NSInteger)aAction;
+ (NSInteger)moveTextSourceActionFromStringForXMLStoring:(id)aStoring;
+ (id)stringForXMLStoringFromMoveTextSourceAction:(NSInteger)aAction;
+ (NSInteger)moveTextSourceDataTypeFromStringForXMLStoring:(id)aStoring;
+ (id)stringForXMLStoringFromMoveTextSourceDataType:(NSInteger)aType;
- (id)HTML5DictionaryRepresentationInContext:(id)aContext;
- (BOOL)canBeExportedToHTML5DocumentType:(id)aType;
- (BOOL)isValid;
- (void)importFromXMLElementRepresentation:(id)aRepresentation inContext:(id)aContext;
- (id)XMLElementRepresentationInContext:(id)aContext;
- (id)XMLElementName;
- (BOOL)canBeStoredAsXMLElement;
- (BOOL)supportedInIPad;
- (void)setDoAppend:(BOOL)aAppend;
- (BOOL)doAppend;
- (void)setDoCopy:(BOOL)aCopy;
- (BOOL)doCopy;
- (void)ownerDidChange;
- (void)ownerWillChange;
- (void)didConnectToDocument;
- (void)willDisconnectFromDocument;
- (void)setDestinationAction:(NSInteger)aAction;
- (NSInteger)destinationAction;
- (void)setSourceAction:(NSInteger)aAction;
- (NSInteger)sourceAction;
- (void)setSourceDataType:(NSInteger)aType;
- (NSInteger)sourceDataType;
- (void)setDestinationObjectUID:(id)aUID;
- (id)destinationObjectUID;
- (void)setSourceObjectUID:(id)aUID;
- (id)sourceObjectUID;
- (void)setDestinationObjectValue:(id)aValue;
- (id)destinationObjectValue;
- (void)setSourceObjectValue:(id)aValue;
- (id)sourceObjectValue;
- (void)updateDestinationObjectIfNeeded;
- (void)updateSourceObjectIfNeeded;
- (void)setDestinationObject:(id)aObject;
- (id)destinationObject;
- (void)setSourceObject:(id)aObject;
- (id)sourceObject;
- (id)objectOnCardWithUID:(id)aUID;
- (id)objectWithUID:(id)aUID;
- (id)copyReplacingObjectUIDs:(id)aDs sortedByPriority:(id)aPriority withImageObjectUID:(id)aUID;
- (void)startInContext:(id)aContext;
- (id)init;
- (void)setContext:(id)aContext;
- (id)keysForExtraLoadingWithCodingContext:(id)aContext;
- (id)keysForExtraStoringWithCodingContext:(id)aContext;
- (void)dealloc;
- (BOOL)isTextObjectRotationAngleZero:(id)aObject;
@end

