#import "HSActionExecutionManager.h"
// Runs objects' action queues: one queue per object and event (a new one
// stops the old), tracks who asked for them, and announces when an
// object's actions for an event finish and when nothing runs any more.
@implementation HSActionExecutionManager
- (id)automaticTimerManager
{
    if (_automaticTimerManager == nil)
        _automaticTimerManager = [HSAutomaticTimerActionsExecutionManager new];
    return _automaticTimerManager;
}
- (void)actionQueueDidFinish:(id)aFinish
{
    [self removeActionQueue:[aFinish object]];
}
// Removes the queue from its object's events (one at most), notifies the
// requestor, and drops objects left without queues.
- (void)removeActionQueue:(id)aQueue
{
    NSMapTable *events = NSCopyMapTableWithZone([self objectsToEventsMap], [self zone]);
    NSMapEnumerator enumerator = NSEnumerateMapTable(events);
    id object = nil;
    NSMutableDictionary *queues = nil;
    NSMutableArray *finishedObjects = [NSMutableArray new];
    BOOL found = NO;
    while (NSNextMapEnumeratorPair(&enumerator, (void **)&object, (void **)&queues)) {
        NSEnumerator *keys = [[NSDictionary dictionaryWithDictionary:queues] keyEnumerator];
        id event;
        while ((event = [keys nextObject]) != nil && !found) {
            if ([queues objectForKey:event] != aQueue)
                continue;
            [queues removeObjectForKey:event];
            [[NSNotificationCenter defaultCenter] removeObserver:self name:@"HSActionQueueDidFinishNotification" object:aQueue];
            [self notifyRequestor:NSMapGet([self objectsToRequestorsMap], object) actionsForObject:object didFinishForEvent:event];
            found = YES;
            if ([queues count] == 0)
                [finishedObjects addObject:object];
        }
    }
    NSEndMapTableEnumeration(&enumerator);
    NSFreeMapTable(events);
    for (id finished in finishedObjects)
        NSMapRemove([self objectsToEventsMap], finished);
    [finishedObjects release];
    if (![self areAnyActionsRunning])
        [[NSNotificationCenter defaultCenter] postNotificationName:@"HSActionExecutionManagerDidBecomeIdleNotification" object:self];
}
- (void)notifyRequestor:(id)aRequestor actionsForObject:(id)aObject didFinishForEvent:(id)aEvent
{
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:aEvent, @"HSActionsForObjectDidFinishEventKey", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HSActionsForObjectDidFinishNotification" object:aObject userInfo:userInfo];
    if (aRequestor != nil && [aRequestor respondsToSelector:@selector(actionsForObject:didFinishForEvent:inActionExecutionManager:)])
        [aRequestor actionsForObject:aObject didFinishForEvent:aEvent inActionExecutionManager:self];
}
- (void)setLeaveActionsDisabled:(BOOL)aDisabled
{
    _isLeaveActionsDisabled = aDisabled;
}
- (BOOL)isLeaveActionsDisabled
{
    return _isLeaveActionsDisabled;
}
- (BOOL)areAnyActionsRunningForEvent:(id)aEvent
{
    for (NSDictionary *queues in NSAllMapTableValues([self objectsToEventsMap]))
        if ([[queues allKeys] containsObject:aEvent])
            return YES;
    return NO;
}
- (BOOL)areAnyActionsRunning
{
    return [NSAllMapTableKeys([self objectsToEventsMap]) count] != 0;
}
- (void)stopAllActionQueues
{
    NSMapTable *events = NSCopyMapTableWithZone([self objectsToEventsMap], [self zone]);
    NSMapEnumerator enumerator = NSEnumerateMapTable(events);
    id object = nil;
    NSDictionary *queues = nil;
    while (NSNextMapEnumeratorPair(&enumerator, (void **)&object, (void **)&queues))
        [[queues allValues] makeObjectsPerformSelector:@selector(stop:) withObject:self];
    NSEndMapTableEnumeration(&enumerator);
    NSFreeMapTable(events);
}
- (void)stopAllActionQueuesForStack:(id)aStack
{
    NSMapTable *events = NSCopyMapTableWithZone([self objectsToEventsMap], [self zone]);
    NSMapEnumerator enumerator = NSEnumerateMapTable(events);
    id object = nil;
    NSDictionary *queues = nil;
    while (NSNextMapEnumeratorPair(&enumerator, (void **)&object, (void **)&queues)) {
        if ([[object queryHyperInterface:@protocol(HSUserObjectSupport)] stack] != aStack)
            continue;
        for (id event in [NSDictionary dictionaryWithDictionary:queues])
            [[queues objectForKey:event] stop:self];
    }
    NSEndMapTableEnumeration(&enumerator);
    NSFreeMapTable(events);
}
// (The objects are the requestors' keys: an object's own queues.)
- (void)stopAllActionsQueuesForRequestor:(id)aRequestor
{
    NSMapTable *events = NSCopyMapTableWithZone([self objectsToEventsMap], [self zone]);
    NSMapEnumerator enumerator = NSEnumerateMapTable(events);
    id object = nil;
    NSDictionary *queues = nil;
    while (NSNextMapEnumeratorPair(&enumerator, (void **)&object, (void **)&queues)) {
        if (object != aRequestor)
            continue;
        for (id event in [NSDictionary dictionaryWithDictionary:queues])
            [[queues objectForKey:event] stop:self];
    }
    NSEndMapTableEnumeration(&enumerator);
    NSFreeMapTable(events);
}
// Stack-level actors keep running.
- (void)stopAllActionQueuesExceptForObjectsInSet:(id)aSet
{
    NSMapTable *events = NSCopyMapTableWithZone([self objectsToEventsMap], [self zone]);
    NSMapEnumerator enumerator = NSEnumerateMapTable(events);
    id object = nil;
    NSDictionary *queues = nil;
    while (NSNextMapEnumeratorPair(&enumerator, (void **)&object, (void **)&queues)) {
        if ([aSet containsObject:object])
            continue;
        for (id event in [NSDictionary dictionaryWithDictionary:queues]) {
            id queue = [queues objectForKey:event];
            if (![[queue actor] implementsHyperInterface:@protocol(HSStackAttributes)])
                [queue stop:self];
        }
    }
    NSEndMapTableEnumeration(&enumerator);
    NSFreeMapTable(events);
}
// Leave actions are skipped while disabled. An empty queue replaces the
// running one for the event but isn't started (nor reported).
- (void)runActionsForObject:(id)aObject withEvent:(id)aEvent inContext:(id)aContext forRequestor:(id)aRequestor
{
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    id queue = nil;
    if (!_isLeaveActionsDisabled || ![[aEvent eventType] isEqualToString:kHSLeaveActionEventType])
        queue = [[aObject queryHyperInterface:@protocol(HSActor)] actionQueueForEvent:aEvent callingObject:aObject];
    if (queue == nil) {
        [self notifyRequestor:aRequestor actionsForObject:aObject didFinishForEvent:aEvent];
        [pool release];
        return;
    }
    BOOL empty = [queue isEmpty];
    NSMutableDictionary *queues = NSMapGet([self objectsToEventsMap], aObject);
    if (queues == nil)
        queues = [NSMutableDictionary dictionary];
    else {
        id running = [queues objectForKey:aEvent];
        if (running != nil) {
            [[NSNotificationCenter defaultCenter] removeObserver:self name:@"HSActionQueueDidFinishNotification" object:running];
            [running stop:self];
        }
    }
    [queues setObject:queue forKey:aEvent];
    if (!empty) {
        NSMapInsert([self objectsToEventsMap], aObject, queues);
        if (aRequestor != nil)
            NSMapInsert([self objectsToRequestorsMap], aObject, aRequestor);
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(actionQueueDidFinish:) name:@"HSActionQueueDidFinishNotification" object:queue];
        [queue startInContext:aContext];
    }
    [pool release];
}
// Objects (not retained) → requestors (retained).
- (id)objectsToRequestorsMap
{
    if (_objectsToRequestorsMap == nil)
        _objectsToRequestorsMap = NSCreateMapTable(NSNonOwnedPointerMapKeyCallBacks, NSObjectMapValueCallBacks, 0);
    return _objectsToRequestorsMap;
}
// Objects → dictionaries of queues by event (both retained).
- (id)objectsToEventsMap
{
    if (_objectsToEventsMap == nil)
        _objectsToEventsMap = NSCreateMapTable(NSObjectMapKeyCallBacks, NSObjectMapValueCallBacks, 0);
    return _objectsToEventsMap;
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (_objectsToEventsMap != nil)
        NSFreeMapTable(_objectsToEventsMap);
    if (_objectsToRequestorsMap != nil)
        NSFreeMapTable(_objectsToRequestorsMap);
    [_automaticTimerManager stopAllAutomaticActionTimers];
    [_automaticTimerManager release];
    [super dealloc];
}
@end
