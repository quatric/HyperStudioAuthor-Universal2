#import "HSUndoManager.h"
// The undo manager: announces registrations and removals, and (with
// "multiple actions name") names a whole group after its first action:
// the name is registered as an undo action itself, just before the
// group's first real action, so undo and redo restore it.
@implementation HSUndoManager
- (void)setMultipleActionsNameEnabled:(BOOL)aEnabled
{
    _isMultipleActionsNameEnabled = aEnabled ? 1 : 0;
}
- (BOOL)isMultipleActionsNameEnabled
{
    return _isMultipleActionsNameEnabled != 0;
}
- (void)removeAllActionsWithTarget:(id)aTarget
{
    [super removeAllActionsWithTarget:aTarget];
    [self postNotificationWithName:HSUndoManagerDidRemoveAllActionsForTargetNotification withActionTarget:aTarget];
}
- (void)removeAllActions
{
    [super removeAllActions];
    [self setGroupActionName:nil];
    _isGroupActionNameRegistrationScheduled = 0;
    [self postNotificationWithName:HSUndoManagerDidRemoveAllActionsNotification withActionTarget:nil];
}
- (id)prepareWithInvocationTarget:(id)aTarget
{
    [self postNotificationWithName:HSUndoManagerWillRegisterUndoActionNotification withActionTarget:aTarget];
    if (_isGroupActionNameRegistrationScheduled && [self isMultipleActionsNameEnabled]) {
        [super registerUndoWithTarget:self selector:@selector(realSetActionName:) object:_groupActionName];
        _isGroupActionNameRegistrationScheduled = 0;
    }
    id proxy = [super prepareWithInvocationTarget:aTarget];
    [self postNotificationWithName:HSUndoManagerDidRegisterUndoActionNotification withActionTarget:aTarget];
    return proxy;
}
- (void)registerUndoWithTarget:(id)aTarget selector:(SEL)aSelector object:(id)aObject
{
    [self postNotificationWithName:HSUndoManagerWillRegisterUndoActionNotification withActionTarget:aTarget];
    if (_isGroupActionNameRegistrationScheduled) {
        [super registerUndoWithTarget:self selector:@selector(realSetActionName:) object:_groupActionName];
        _isGroupActionNameRegistrationScheduled = 0;
    }
    [super registerUndoWithTarget:aTarget selector:aSelector object:aObject];
    [self postNotificationWithName:HSUndoManagerDidRegisterUndoActionNotification withActionTarget:aTarget];
}
- (void)postNotificationWithName:(id)aName withActionTarget:(id)aTarget
{
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    NSDictionary *userInfo = aTarget != nil ? [NSDictionary dictionaryWithObject:aTarget forKey:HSUndoManagerTargetForActionKey] : nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:aName object:self userInfo:userInfo];
    [pool release];
}
- (void)setGroupActionName:(id)aName
{
    if (_groupActionName == aName)
        return;
    [_groupActionName release];
    _groupActionName = [aName copy];
}
// The first name in a group wins. While redoing, the name is registered
// back for the next undo.
- (void)realSetActionName:(id)aName
{
    if (![self isUndoRegistrationEnabled])
        return;
    if (![self isUndoing]) {
        if (_groupActionName != nil)
            return;
        if (![self isRedoing])
            _isGroupActionNameRegistrationScheduled = 1;
        else
            [super registerUndoWithTarget:self selector:@selector(realSetActionName:) object:aName];
    }
    [self setGroupActionName:aName];
}
- (void)setActionName:(id)aName
{
    if ([self isMultipleActionsNameEnabled] && [self NSE_pendingActionName] == nil) {
        [self realSetActionName:aName];
        return;
    }
    [super setActionName:aName];
}
- (void)endUndoGrouping
{
    if ([self groupingLevel] == 1 && _groupActionName != nil) {
        [super setActionName:_groupActionName];
        [self setGroupActionName:nil];
        _isGroupActionNameRegistrationScheduled = 0;
    }
    [super endUndoGrouping];
}
- (void)beginUndoGrouping
{
    if (!_isGroupActionNameRegistrationScheduled && [self groupingLevel] == 0 && [self isMultipleActionsNameEnabled])
        [self setGroupActionName:nil];
    [super beginUndoGrouping];
}
- (void)dealloc
{
    [_groupActionName release];
    [super dealloc];
}
- (id)init
{
    self = [super init];
    if (self != nil)
        _isMultipleActionsNameEnabled = 1;
    return self;
}
@end

@implementation NSUndoManager (MultipleActionsName)
// An action name that undo and redo restore.
- (void)setMultipleActionsName:(id)aName
{
    if ([self isMultipleActionsNameEnabled])
        [self registerUndoWithTarget:self selector:@selector(setMultipleActionsName:) object:aName];
    [self setActionName:aName];
}
- (BOOL)isMultipleActionsNameEnabled
{
    return YES;
}
- (void)setMultipleActionsNameEnabled:(BOOL)aEnabled
{
}
@end
