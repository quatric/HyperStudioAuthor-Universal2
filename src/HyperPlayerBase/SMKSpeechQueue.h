#import "HyperPlayerBasePrefix.h"


@interface SMKSpeechQueue : NSObject
{
    id _queue;
    id _requestorsRegistry;
}
- (id)firstObjectNeedingProcessing;
- (BOOL)hasPendingObjectsWithRequestor:(id)aRequestor;
- (void)removeAllPendingObjectsWithRequestor:(id)aRequestor clearCurrent:(BOOL)aCurrent;
- (void)removeAllPendingObjects;
- (id)nextSpokenObject;
- (id)currentSpokenObject;
- (void)addSpokenObject:(id)aObject;
- (void)_removeSpokenObject:(id)aObject;
- (id)_nextSpokenObject:(id)aObject;
- (void)_unregisterRequestorWithData:(id)aData;
- (id)_registerRequestor:(id)aRequestor;
- (id)_dataForRequestor:(id)aRequestor;
- (void)dealloc;
- (id)init;
@end

@interface _SMKSpeechRequestorData : NSObject
{
@public
    id requestor;
    unsigned int requestsCount;
}
- (BOOL)isEqual:(id)aEqual;
@end

