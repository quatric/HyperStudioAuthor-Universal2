#import "HSActionGroup.h"
// An action made of sub-actions, run together by an action synchronizer.
// Sub-actions are copies owned by the group; the calling object stands in
// as the hyper object of each.

@implementation HSActionGroup

- (void)actionSynchronizerDidFinishPerformActions:(id)aActions
{
    [_actionSynchronizer setDelegate:nil];
    [_actionSynchronizer release];
    _actionSynchronizer = nil;
    [self notifyDidFinish];
}

- (void)stop:(id)aStop
{
    if ([_actionSynchronizer isRunning])
        [_actionSynchronizer stop:aStop];
}

- (BOOL)canBeStopped
{
    return YES;
}

- (void)startInContext:(id)aContext
{
    // (The original doesn't release a synchronizer still running.)
    _actionSynchronizer = [[HSActionSynchronizer alloc] initWithActions:[self subActions]];
    [_actionSynchronizer setDelegate:self];
    [_actionSynchronizer startInContext:aContext];
}

- (id)hyperObjectForAction:(id)aAction
{
    return _callingObject;
}

- (void)removeSubAction:(id)aAction
{
    [aAction willRemoveFromDocument];
    [[self mutableSubActions] removeObject:aAction];
}

- (void)addSubActions:(id)aActions
{
    NSEnumerator *enumerator = [aActions objectEnumerator];
    id action;
    while ((action = [enumerator nextObject]))
        [self addSubAction:action];
}

- (void)addSubAction:(id)aAction
{
    [self insertSubAction:aAction atIndex:[[self subActions] count]];
}

- (void)insertSubAction:(id)aAction atIndex:(NSUInteger)aIndex
{
    id action = [[aAction copy] autorelease];
    [action setOwner:self];
    [action didAddToDocument];
    [[self mutableSubActions] insertObject:action atIndex:aIndex];
}

- (BOOL)supportedInWebPlayer
{
    BOOL supported = [super supportedInWebPlayer];
    NSEnumerator *enumerator = [_subActions objectEnumerator];
    id action;
    while (supported && (action = [enumerator nextObject]))
        supported = [action supportedInWebPlayer];
    return supported;
}

- (BOOL)isKindOfType:(id)aType
{
    if ([super isKindOfType:aType])
        return YES;
    NSEnumerator *enumerator = [_subActions objectEnumerator];
    id action;
    while ((action = [enumerator nextObject])) {
        if ([action isKindOfType:aType])
            return YES;
    }
    return NO;
}

- (id)subActions
{
    return [self mutableSubActions];
}

- (id)mutableSubActions
{
    if (!_subActions)
        _subActions = [NSMutableArray new];
    return _subActions;
}

- (void)dealloc
{
    [_subActions makeObjectsPerformSelector:@selector(willRemoveFromDocument)];
    [_subActions makeObjectsPerformSelector:@selector(setOwner:) withObject:nil];
    [_subActions release];
    [_actionSynchronizer setDelegate:nil];
    [_actionSynchronizer release];
    [_callingObject release];
    [super dealloc];
}

- (id)initWithCallingObject:(id)aObject
{
    self = [super init];
    if (self)
        _callingObject = [aObject retain];
    return self;
}

- (void)pause
{
    [_actionSynchronizer pause];
}

- (void)resume
{
    [_actionSynchronizer resume];
}

@end
