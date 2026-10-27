#import "HyperPlayerBasePrefix.h"
#import "HSScriptAction.h"


@interface HSMoveToFrontAction : HSNBAAction <HSMoveToFrontActionAttributes, HSActionAttributes, HSAttributes, HyperInterface, NSObject, HSAction, HSActionSynchronousAttribute, HSAttribute, HSActionEventsAttribute, HSActionLocalizedNameAttribute, HSMoveToFrontSourceObjectUIDAttribute>
{
    HSActionExecutionContext *_context;
    HSUID *_sourceObjectUID;
    id _sourceObject;
}
- (id)HTML5DictionaryRepresentationInContext:(id)aContext;
- (BOOL)canBeExportedToHTML5DocumentType:(id)aType;
- (BOOL)isValid;
- (void)importFromXMLElementRepresentation:(id)aRepresentation inContext:(id)aContext;
- (id)XMLElementRepresentationInContext:(id)aContext;
- (id)XMLElementName;
- (BOOL)canBeStoredAsXMLElement;
- (BOOL)supportedInIPad;
- (void)ownerDidChange;
- (void)ownerWillChange;
- (void)didConnectToDocument;
- (void)willDisconnectFromDocument;
- (void)setSourceObjectUID:(id)aUID;
- (id)sourceObjectUID;
- (void)updateSourceObjectIfNeeded;
- (void)setSourceObject:(id)aObject;
- (id)sourceObject;
- (id)objectWithUID:(id)aUID;
- (void)startInContext:(id)aContext;
- (id)copyReplacingObjectUIDs:(id)aDs sortedByPriority:(id)aPriority withImageObjectUID:(id)aUID;
- (void)setContext:(id)aContext;
- (id)keysForExtraStoringWithCodingContext:(id)aContext;
- (void)dealloc;
@end

