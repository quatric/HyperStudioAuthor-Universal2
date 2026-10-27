#import "BTObjectWrapperForUndoManagerList.h"
#include <pthread.h>

// Undo registrations that hold purgeable objects (BTCGImages) are wrapped,
// and the wrappers of each undo manager's undo and redo stacks are listed
// oldest first: once more than 10 are listed the older ones are asked to
// write their objects out (-prepareToPurge), and past 20 the oldest is purged.

static pthread_mutex_t listsLock = PTHREAD_MUTEX_INITIALIZER;
static CFMutableDictionaryRef undoLists, redoLists; // undo manager (not retained) -> list

static CFStringRef CopyKeyDescription(const void *key)
{
    return (CFStringRef)[[(id)key description] retain];
}

static id ListForUndoManager(Class self, id manager, CFMutableDictionaryRef *lists)
{
    pthread_mutex_lock(&listsLock);
    id list = *lists ? [[(id)CFDictionaryGetValue(*lists, manager) retain] autorelease] : nil;
    if (!list) {
        if (!*lists) {
            CFDictionaryKeyCallBacks keys = {0, NULL, NULL, CopyKeyDescription, NULL, NULL};
            *lists = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &keys, &kCFTypeDictionaryValueCallBacks);
        }
        list = [[[self alloc] initWithUndoManager:manager undoManagerStack:*lists] autorelease];
        if (list && *lists)
            CFDictionarySetValue(*lists, manager, list);
    }
    pthread_mutex_unlock(&listsLock);
    return list;
}

@implementation BTObjectWrapperForUndoManagerList

+ (id)redoStackWrapperListWithUndoManager:(id)aManager
{
    return ListForUndoManager(self, aManager, &redoLists);
}

+ (id)undoStackWrapperListWithUndoManager:(id)aManager
{
    return ListForUndoManager(self, aManager, &undoLists);
}

- (id)initWithUndoManager:(id)aManager undoManagerStack:(struct __CFDictionary *)aStack
{
    self = [super init];
    if (!self)
        return nil;
    _undoManager = aManager;
    _undoManagerStack = aStack;
    return self;
}

- (void)addObject:(id)aObject
{
    if (!aObject || [aObject list])
        return;
    [aObject setNext:nil];
    [aObject setPrev:nil];
    [aObject setList:self];
    if (!_last)
        _head = aObject;
    else
        [_last setNext:aObject];
    [aObject setPrev:_last];
    _last = aObject;
    _count++;
    if (_objectToPrepareToFreeCashes)
        _objectToPrepareToFreeCashes = [_objectToPrepareToFreeCashes next];
    else if (_count > 10)
        _objectToPrepareToFreeCashes = _head;
    [_objectToPrepareToFreeCashes prepareToPurgeObjects];
    if (_count > 20) {
        [_head purgeObjects];
        [self removeObject:_head];
    }
}

// The list (held by its dictionary) goes when it is empty.
- (void)removeObject:(id)aObject
{
    if (!aObject || [aObject list] != self)
        return;
    BTObjectWrapperForUndoManager *next = [aObject next];
    BTObjectWrapperForUndoManager *prev = [aObject prev];
    [next setPrev:prev];
    [prev setNext:next];
    if (!next)
        _last = prev;
    if (!prev)
        _head = next;
    if (_objectToPrepareToFreeCashes == aObject)
        _objectToPrepareToFreeCashes = prev;
    [aObject setNext:nil];
    [aObject setPrev:nil];
    [aObject setList:nil];
    if (--_count < 1) {
        pthread_mutex_lock(&listsLock);
        if (_undoManagerStack)
            CFDictionaryRemoveValue(_undoManagerStack, _undoManager);
        pthread_mutex_unlock(&listsLock);
    }
}

@end

@implementation BTObjectWrapperForUndoManager

+ (id)wrapperWithObjectList:(id)aList invocation:(id)aInvocation
{
    return [[[self alloc] initWithObjectList:aList invocation:aInvocation] autorelease];
}

- (id)init
{
    return [self initWithObjectList:nil invocation:nil];
}

- (id)initWithObjectList:(id)aList invocation:(id)aInvocation
{
    self = [super init];
    if (!self)
        return nil;
    _objectList = [aList retain];
    _invocation = [aInvocation retain];
    [_invocation retainArguments];
    return self;
}

- (void)dealloc
{
    [_list removeObject:self];
    [_objectList release];
    [_invocation release];
    [super dealloc];
}

- (id)invocation
{
    return _invocation;
}

- (void)prepareToPurgeObjects
{
    [_objectList makeObjectsPerformSelector:@selector(prepareToPurge)];
}

- (void)purgeObjects
{
    [_objectList makeObjectsPerformSelector:@selector(purge)];
}

- (void)willAddToUndoStackInUndoManager:(id)aManager
{
    [[BTObjectWrapperForUndoManagerList undoStackWrapperListWithUndoManager:aManager] addObject:self];
}

- (void)willAddToRedoStackInUndoManager:(id)aManager
{
    [[BTObjectWrapperForUndoManagerList redoStackWrapperListWithUndoManager:aManager] addObject:self];
}

- (id)list
{
    return _list;
}

- (void)setList:(id)aList
{
    _list = aList;
}

- (id)next
{
    return _next;
}

- (void)setNext:(id)aNext
{
    _next = aNext;
}

- (id)prev
{
    return _prev;
}

- (void)setPrev:(id)aPrev
{
    _prev = aPrev;
}

@end

// -prepareWithInvocationTarget: for invocations that may hold purgeable
// objects: those are registered through a wrapper; others as usual.
@implementation BTUndoManagerCoreProxy

+ (id)undoManagerCoreProxyWithUndoManager:(id)aManager target:(id)aTarget
{
    return [[[self alloc] initWithUndoManager:aManager target:aTarget] autorelease];
}

- (id)init
{
    [self release];
    return nil;
}

- (id)initWithUndoManager:(id)aManager target:(id)aTarget
{
    _undoManager = [aManager retain];
    _target = [aTarget retain];
    return self;
}

- (void)dealloc
{
    [_undoManager release];
    [super dealloc];
}

- (id)methodSignatureForSelector:(SEL)aSelector
{
    NSMethodSignature *signature = [_undoManager methodSignatureForSelector:aSelector];
    if (signature)
        return signature;
    return [_target methodSignatureForSelector:aSelector];
}

// The purgeable objects among the invocation's object arguments, also
// inside invocation arguments.
- (id)objectCashesInvalidationListFromInvocation:(id)aInvocation
{
    NSMethodSignature *signature = [aInvocation methodSignature];
    NSUInteger count = [signature numberOfArguments];
    NSMutableArray *list = nil;
    for (NSUInteger i = 2; i < count; i++) {
        if (strcmp([signature getArgumentTypeAtIndex:i], "@"))
            continue;
        id argument = nil;
        [aInvocation getArgument:&argument atIndex:i];
        if ([argument conformsToProtocol:@protocol(BTPurgableObject)]) {
            if (!list)
                list = [NSMutableArray arrayWithObject:argument];
            else
                [list addObject:argument];
        } else if ([argument isKindOfClass:[NSInvocation class]]) {
            NSArray *inner = [self objectCashesInvalidationListFromInvocation:argument];
            if ([inner count]) {
                if (!list)
                    list = [NSMutableArray arrayWithArray:inner];
                else
                    [list addObjectsFromArray:inner];
            }
        }
    }
    return list;
}

- (void)forwardInvocation:(NSInvocation *)aInvocation
{
    NSArray *list = [self objectCashesInvalidationListFromInvocation:aInvocation];
    if ([list count]) {
        [aInvocation setTarget:nil];
        BTObjectWrapperForUndoManager *wrapper = [BTObjectWrapperForUndoManager wrapperWithObjectList:list
                                                                                           invocation:aInvocation];
        if (wrapper) {
            if ([_undoManager isUndoing])
                [wrapper willAddToRedoStackInUndoManager:_undoManager];
            else
                [wrapper willAddToUndoStackInUndoManager:_undoManager];
            [_undoManager registerUndoWithTarget:_target
                                        selector:@selector(BTUndoManagerCoreProxySupport_executeUndoOperationWithObjectWrapper:)
                                          object:wrapper];
            [_target release];
            _target = nil;
            return;
        }
    }
    [aInvocation invokeWithTarget:[_undoManager prepareWithInvocationTarget:_target]];
    [aInvocation setTarget:nil];
    [_target release];
    _target = nil;
}

@end

@implementation NSObject (BTUndoManagerCoreProxySupport)

- (void)BTUndoManagerCoreProxySupport_executeUndoOperationWithObjectWrapper:(id)aWrapper
{
    NSInvocation *invocation = [aWrapper invocation];
    [invocation invokeWithTarget:self];
    [invocation setTarget:nil];
}

@end

@implementation NSUndoManager (BTExtensions)

- (id)BT_prepareWithInvocationTarget:(id)aTarget
{
    return [BTUndoManagerCoreProxy undoManagerCoreProxyWithUndoManager:self target:aTarget];
}

// A purgeable object is registered through a wrapper. (The original asked the
// target for -instanceMethodSignatureForSelector:, a class method.)
- (void)BT_registerUndoWithTarget:(id)aTarget selector:(SEL)aSelector object:(id)aObject
{
    SEL selector = aSelector;
    id object = aObject;
    NSMethodSignature *signature;
    NSInvocation *invocation;
    if ([aObject conformsToProtocol:@protocol(BTPurgableObject)] &&
        (signature = [aTarget methodSignatureForSelector:aSelector]) &&
        (invocation = [NSInvocation invocationWithMethodSignature:signature])) {
        [invocation setSelector:aSelector];
        [invocation setArgument:&aObject atIndex:2];
        BTObjectWrapperForUndoManager *wrapper =
            [BTObjectWrapperForUndoManager wrapperWithObjectList:[NSArray arrayWithObject:aObject] invocation:invocation];
        if (wrapper) {
            if ([self isUndoing])
                [wrapper willAddToRedoStackInUndoManager:self];
            else
                [wrapper willAddToUndoStackInUndoManager:self];
            selector = @selector(BTUndoManagerCoreProxySupport_executeUndoOperationWithObjectWrapper:);
            object = wrapper;
        }
    }
    [self registerUndoWithTarget:aTarget selector:selector object:object];
}

@end
