#import "HSPurgableObjectList.h"
// Purgeable caches by recent use: a list oldest first, kept to a quarter
// of the memory (at most 384 MB). Past half that, the oldest are asked to
// get ready to purge (as much as was just added); past all of it, the
// oldest are purged.
static unsigned long long HSPurgableMemoryLimit(void)
{
    static unsigned long long limit = 0;
    if (limit == 0) {
        unsigned long long memory = [[NSProcessInfo processInfo] physicalMemory];
        limit = memory > 0x60000003ULL ? 0x18000000ULL : memory / 4;
    }
    return limit;
}

@implementation HSPurgableObjectList
- (void)addObject:(struct HSPurgableObjectListNode *)aObject
{
    [_dataLock lock];
    if (aObject != NULL && aObject->f2 == nil) {
        aObject->f3 = NULL;
        aObject->f4 = NULL;
        aObject->f2 = self;
        if (_last == NULL)
            _head = aObject;
        else
            _last->f3 = aObject;
        aObject->f4 = _last;
        _last = aObject;
        _size += aObject->f1;
        unsigned long long limit = HSPurgableMemoryLimit();
        if (_size > limit / 2) {
            long long remaining = aObject->f1;
            struct HSPurgableObjectListNode *node = _objectToPrepareToFreeCashes;
            if (node == NULL) {
                if (_head != aObject)
                    node = _objectToPrepareToFreeCashes = _head;
                if (node != NULL && node != aObject) {
                    [node->f0 prepareToPurge];
                    remaining -= _objectToPrepareToFreeCashes->f1;
                }
            }
            if (node != NULL && node != aObject) {
                while (remaining > 0 && (node = node->f3) != NULL && node != aObject) {
                    _objectToPrepareToFreeCashes = node;
                    [node->f0 prepareToPurge];
                    remaining -= _objectToPrepareToFreeCashes->f1;
                }
            }
        }
        struct HSPurgableObjectListNode *head;
        while (_size > limit && (head = _head) != NULL && head != aObject) {
            id object = head->f0;
            [self removeObject:head];
            [object purge];
        }
    }
    [_dataLock unlock];
}
- (void)removeObject:(struct HSPurgableObjectListNode *)aObject
{
    [_dataLock lock];
    if (aObject != NULL && aObject->f2 == self) {
        struct HSPurgableObjectListNode *next = aObject->f3, *previous = aObject->f4;
        if (next != NULL)
            next->f4 = previous;
        if (previous != NULL)
            previous->f3 = next;
        if (next == NULL)
            _last = previous;
        if (previous == NULL)
            _head = next;
        if (_objectToPrepareToFreeCashes == aObject)
            _objectToPrepareToFreeCashes = previous;
        aObject->f3 = NULL;
        aObject->f4 = NULL;
        aObject->f2 = nil;
        _size = _size > aObject->f1 ? _size - aObject->f1 : 0;
    }
    [_dataLock unlock];
}
- (id)init
{
    self = [super init];
    if (self != nil)
        _dataLock = [[NSRecursiveLock allocWithZone:[self zone]] init];
    return self;
}
- (void)dealloc
{
    [_dataLock release];
    while (_head != NULL) {
        struct HSPurgableObjectListNode *next = _head->f3;
        free(_head);
        _head = next;
    }
    [super dealloc];
}
@end

// Tracks purgeable objects: each use moves the object to the end of the
// list with its current size.
@implementation HSPurgableObjectRegistry
+ (id)sharedRegistry
{
    static HSPurgableObjectRegistry *registry = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        registry = [[[self class] alloc] init];
    });
    return registry;
}
- (void)purgableObjectDidPurgeOrDie:(id)aDie
{
    [_mapLock lock];
    struct HSPurgableObjectListNode *node = NULL;
    if (_purgableObjectToListMap != NULL) {
        node = (struct HSPurgableObjectListNode *)CFDictionaryGetValue(_purgableObjectToListMap, aDie);
        if (node != NULL)
            CFDictionaryRemoveValue(_purgableObjectToListMap, aDie);
    }
    [_mapLock unlock];
    if (node != NULL) {
        [_purgableObjectList removeObject:node];
        free(node);
    }
}
- (void)purgableObjectDidUseData:(id)aData
{
    if (aData == nil)
        return;
    [_mapLock lock];
    struct HSPurgableObjectListNode *node = NULL;
    if (_purgableObjectToListMap != NULL)
        node = (struct HSPurgableObjectListNode *)CFDictionaryGetValue(_purgableObjectToListMap, aData);
    if (node == NULL && (node = calloc(1, sizeof(*node))) != NULL) {
        node->f0 = aData;
        if (_purgableObjectToListMap == NULL)
            _purgableObjectToListMap = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, NULL, NULL);
        if (_purgableObjectToListMap != NULL)
            CFDictionarySetValue(_purgableObjectToListMap, aData, node);
    }
    if (_purgableObjectList == nil)
        _purgableObjectList = [[HSPurgableObjectList alloc] init];
    [_mapLock unlock];
    if (node != NULL) {
        [_purgableObjectList removeObject:node];
        node->f1 = (unsigned int)[aData purgableSize];
        [_purgableObjectList addObject:node];
    }
}
- (id)init
{
    self = [super init];
    if (self != nil)
        _mapLock = [[NSRecursiveLock allocWithZone:[self zone]] init];
    return self;
}
- (void)dealloc
{
    [_mapLock release];
    [super dealloc];
}
@end
