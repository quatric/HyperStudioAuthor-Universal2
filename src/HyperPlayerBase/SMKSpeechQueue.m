#import "SMKSpeechQueue.h"
// Queue of objects waiting to be spoken. The first object is the one
// being spoken. Each requestor's pending count is kept so its objects
// can be dropped together.

@implementation SMKSpeechQueue

// The first queued object that has nothing to speak yet.
- (id)firstObjectNeedingProcessing
{
    id object = [self currentSpokenObject];
    while (object && [object dataToSpeak])
        object = [self _nextSpokenObject:object];
    return object;
}

- (BOOL)hasPendingObjectsWithRequestor:(id)aRequestor
{
    _SMKSpeechRequestorData *data = [self _dataForRequestor:aRequestor];
    if (!data)
        return NO;
    if ([[self currentSpokenObject] requestor] == aRequestor)
        return data->requestsCount > 1;
    return data->requestsCount != 0;
}

// Drops the requestor's queued objects. Its current object is marked to
// be dropped, and stops counting for the requestor only with aCurrent.
- (void)removeAllPendingObjectsWithRequestor:(id)aRequestor clearCurrent:(BOOL)aCurrent
{
    _SMKSpeechRequestorData *data = [self _dataForRequestor:aRequestor];
    if (!data)
        return;
    id object = [self currentSpokenObject];
    [data retain];
    // (The original leaves this count unset when the current object
    // belongs to another requestor.)
    unsigned int kept = 0;
    if ([object requestor] == aRequestor) {
        [object markAsShouldBeDropped];
        if (aCurrent) {
            [object clearRequestor];
            data->requestsCount--;
        } else {
            kept = 1;
        }
    }
    while (kept < data->requestsCount) {
        id next = [self _nextSpokenObject:object];
        if ([next requestor] == aRequestor)
            [self _removeSpokenObject:next];
        else
            object = next;
    }
    [data release];
}

- (void)removeAllPendingObjects
{
    id current = [self currentSpokenObject];
    [current markAsShouldBeDropped];
    id next;
    while ((next = [self _nextSpokenObject:current]))
        [self _removeSpokenObject:next];
}

// Removes the current object and returns the one after it.
- (id)nextSpokenObject
{
    id current = [self currentSpokenObject];
    if (![self currentSpokenObject])
        return nil;
    id next = [self _nextSpokenObject:current];
    [self _removeSpokenObject:current];
    return next;
}

- (id)currentSpokenObject
{
    return [_queue count] ? [_queue objectAtIndex:0] : nil;
}

- (void)addSpokenObject:(id)aObject
{
    if ([aObject requestor]) {
        _SMKSpeechRequestorData *data = [self _registerRequestor:[aObject requestor]];
        data->requestsCount++;
    }
    [_queue addObject:aObject];
}

- (void)_removeSpokenObject:(id)aObject
{
    if ([aObject requestor]) {
        _SMKSpeechRequestorData *data = [self _dataForRequestor:[aObject requestor]];
        if (--data->requestsCount == 0)
            [self _unregisterRequestorWithData:data];
    }
    [_queue removeObject:aObject];
}

- (id)_nextSpokenObject:(id)aObject
{
    NSUInteger index = [_queue indexOfObject:aObject] + 1;
    if (index == [_queue count])
        return nil;
    return [_queue objectAtIndex:index];
}

- (void)_unregisterRequestorWithData:(id)aData
{
    [_requestorsRegistry removeObject:aData];
}

- (id)_registerRequestor:(id)aRequestor
{
    _SMKSpeechRequestorData *data = [self _dataForRequestor:aRequestor];
    if (!data) {
        data = [_SMKSpeechRequestorData new];
        data->requestor = aRequestor;
        data->requestsCount = 0;
        [_requestorsRegistry addObject:data];
        [data release];
    }
    return data;
}

- (id)_dataForRequestor:(id)aRequestor
{
    NSUInteger count = [_requestorsRegistry count];
    for (NSUInteger i = 0; i < count; i++) {
        _SMKSpeechRequestorData *data = [_requestorsRegistry objectAtIndex:i];
        if (data->requestor == aRequestor)
            return data;
    }
    return nil;
}

- (void)dealloc
{
    [_queue release];
    [_requestorsRegistry release];
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self) {
        _queue = [[NSMutableArray alloc] initWithCapacity:20];
        _requestorsRegistry = [[NSMutableArray alloc] initWithCapacity:5];
    }
    return self;
}

@end

@implementation _SMKSpeechRequestorData

- (BOOL)isEqual:(id)aEqual
{
    return requestor == ((_SMKSpeechRequestorData *)aEqual)->requestor;
}

@end
