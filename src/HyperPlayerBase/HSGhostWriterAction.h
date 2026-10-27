#import "HyperPlayerBasePrefix.h"
#import "HSScriptAction.h"


@interface HSGhostWriterAction : HSNBAAction <HSGhostWriterActionAttributes, HSGhostWriterCommandsAttribute, HSAttribute, HSActionAttributes, HSAttributes, HyperInterface, NSObject, HSAction, HSActionSynchronousAttribute, HSActionEventsAttribute, HSActionLocalizedNameAttribute>
{
    HSActionExecutionContext *_context;
    NSArray *_commands;
    BOOL _finishedInActionPerfromer;
    NSMutableArray *_notificationObservers;
}
+ (id)ghostWriterActionFromAutoTypeAction:(id)aAction;
+ (BOOL)canUseObject:(id)aObject;
- (id)HTML5DictionaryRepresentationInContext:(id)aContext;
- (BOOL)canBeExportedToHTML5DocumentType:(id)aType;
- (void)validateActionWithNotification:(id)aNotification;
- (void)unsubscribeFromNotificationsForObject:(id)aObject;
- (void)unsubscribeFromNotifications;
- (void)subscribeToNotificationsForObject:(id)aObject;
- (void)subscribeToNotifications;
- (id)notificationObservers;
- (void)insertText:(id)aText toNode:(id)aNode;
- (void)doCommandBySelector:(SEL)aSelector forNode:(id)aNode;
- (void)setCommands:(id)aCommands;
- (id)commands;
- (void)mergeInGhostWriterAction:(id)aAction replacingObjectUIDs:(id)aDs sortedByPriority:(id)aPriority withImageObjectUID:(id)aUID;
- (BOOL)isEqual:(id)aEqual;
- (BOOL)isValid;
- (id)textObjectWithUID:(id)aUID;
- (void)stop:(id)aStop;
- (BOOL)canBeStopped;
- (void)startInContext:(id)aContext;
- (BOOL)canRunInContext:(id)aContext;
- (void)didFinishInActionPerfromer;
- (void)setContext:(id)aContext;
- (id)keysForExtraStoringWithCodingContext:(id)aContext;
- (void)dealloc;
@end

