#import "HyperPlayerBasePrefix.h"


@interface HSUndoManager : NSUndoManager
{
    NSString *_groupActionName;
    unsigned int _isGroupActionNameRegistrationScheduled:1;
    unsigned int _isMultipleActionsNameEnabled:1;
}
- (void)setMultipleActionsNameEnabled:(BOOL)aEnabled;
- (BOOL)isMultipleActionsNameEnabled;
- (void)removeAllActionsWithTarget:(id)aTarget;
- (void)removeAllActions;
- (id)prepareWithInvocationTarget:(id)aTarget;
- (void)registerUndoWithTarget:(id)aTarget selector:(SEL)aSelector object:(id)aObject;
- (void)postNotificationWithName:(id)aName withActionTarget:(id)aTarget;
- (void)setGroupActionName:(id)aName;
- (void)realSetActionName:(id)aName;
- (void)setActionName:(id)aName;
- (void)endUndoGrouping;
- (void)beginUndoGrouping;
- (void)dealloc;
- (id)init;
@end

@interface NSUndoManager (MultipleActionsName)
- (void)setMultipleActionsName:(id)aName;
- (BOOL)isMultipleActionsNameEnabled;
- (void)setMultipleActionsNameEnabled:(BOOL)aEnabled;
@end

