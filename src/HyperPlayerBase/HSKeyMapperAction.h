#import "HyperPlayerBasePrefix.h"
#import "HSScriptAction.h"


@interface HSKeyMapperAction : HSNBAAction <HSKeyMapperActionAttributes, HSActionAttributes, HSAttributes, HyperInterface, NSObject, HSAction, HSActionSynchronousAttribute, HSAttribute, HSActionEventsAttribute, HSActionLocalizedNameAttribute, HSKeyMappingsAttribute>
{
    NSArray *_keyMappings;
}
- (id)HTML5DictionaryRepresentationInContext:(id)aContext;
- (id)specialStringKeyFromCode:(unsigned short)aCode;
- (BOOL)canBeExportedToHTML5DocumentType:(id)aType;
- (void)addUIDKeyToKeyMappings;
- (BOOL)isKeyMappingsWithoutUIDKey;
- (id)buttonWithUID:(id)aUID;
- (void)checkKeyMappingsForUIDKey;
- (void)setKeyMappings:(id)aMappings;
- (id)keyMappings;
- (void)mergeInKeyMapperAction:(id)aAction replacingObjectUIDs:(id)aDs sortedByPriority:(id)aPriority withImageObjectUID:(id)aUID;
- (id)copyReplacingObjectUIDs:(id)aDs sortedByPriority:(id)aPriority withImageObjectUID:(id)aUID;
- (BOOL)isUsedShiftForKey:(unsigned short)aKey;
- (void)startInContext:(id)aContext;
- (BOOL)canChangeSynchronousFlag;
- (BOOL)isSynchronous;
- (id)keysForExtraStoringWithCodingContext:(id)aContext;
- (void)dealloc;
@end

