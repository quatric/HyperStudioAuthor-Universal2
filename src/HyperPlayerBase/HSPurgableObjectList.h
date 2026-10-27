#import "HyperPlayerBasePrefix.h"


@interface HSPurgableObjectList : NSObject
{
    NSRecursiveLock *_dataLock;
    struct HSPurgableObjectListNode *_head;
    struct HSPurgableObjectListNode *_last;
    unsigned long long _size;
    struct HSPurgableObjectListNode *_objectToPrepareToFreeCashes;
}
- (void)addObject:(struct HSPurgableObjectListNode *)aObject;
- (void)removeObject:(struct HSPurgableObjectListNode *)aObject;
- (id)init;
- (void)dealloc;
@end

@interface HSPurgableObjectRegistry : NSObject
{
    struct __CFDictionary *_purgableObjectToListMap;
    HSPurgableObjectList *_purgableObjectList;
    NSRecursiveLock *_mapLock;
}
+ (id)sharedRegistry;
- (void)purgableObjectDidPurgeOrDie:(id)aDie;
- (void)purgableObjectDidUseData:(id)aData;
- (id)init;
- (void)dealloc;
@end

