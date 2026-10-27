#import "HyperPlayerBasePrefix.h"
#import "HSScriptAction.h"


@interface HSSpeechRecognitionAction : HSNBAAction <HSSpeechRecognitionActionAttributes, HSActionAttributes, HSAttributes, HyperInterface, NSObject, HSAction, HSActionSynchronousAttribute, HSAttribute, HSActionEventsAttribute, HSActionLocalizedNameAttribute, HSObjectUIDsAttribute>
{
    NSArray *_objectUIDs;
}
- (id)objectWithUID:(id)aUID;
- (void)setObjectUIDs:(id)aDs;
- (id)objectUIDs;
- (void)startInContext:(id)aContext;
- (BOOL)canChangeSynchronousFlag;
- (BOOL)isSynchronous;
- (void)mergeInSpeechRecognitionAction:(id)aAction replacingObjectUIDs:(id)aDs sortedByPriority:(id)aPriority withImageObjectUID:(id)aUID;
- (id)copyReplacingObjectUIDs:(id)aDs sortedByPriority:(id)aPriority withImageObjectUID:(id)aUID;
- (id)keysForExtraStoringWithCodingContext:(id)aContext;
- (void)dealloc;
@end

