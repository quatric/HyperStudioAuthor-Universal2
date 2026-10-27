#import "SMKBitmapToolsPrefix.h"


@interface BTObjectWrapperForUndoManagerList : NSObject
{
    struct __CFDictionary *_undoManagerStack;
    NSUndoManager *_undoManager;
    BTObjectWrapperForUndoManager *_head;
    BTObjectWrapperForUndoManager *_last;
    NSInteger _count;
    BTObjectWrapperForUndoManager *_objectToPrepareToFreeCashes;
}
+ (id)redoStackWrapperListWithUndoManager:(id)aManager;
+ (id)undoStackWrapperListWithUndoManager:(id)aManager;
- (void)addObject:(id)aObject;
- (void)removeObject:(id)aObject;
- (id)initWithUndoManager:(id)aManager undoManagerStack:(struct __CFDictionary *)aStack;
@end

@interface BTObjectWrapperForUndoManager : NSObject
{
    NSArray *_objectList;
    NSInvocation *_invocation;
    BTObjectWrapperForUndoManagerList *_list;
    BTObjectWrapperForUndoManager *_next;
    BTObjectWrapperForUndoManager *_prev;
}
+ (id)wrapperWithObjectList:(id)aList invocation:(id)aInvocation;
- (id)prev;
- (void)setPrev:(id)aPrev;
- (id)next;
- (void)setNext:(id)aNext;
- (id)list;
- (void)setList:(id)aList;
- (void)willAddToRedoStackInUndoManager:(id)aManager;
- (void)willAddToUndoStackInUndoManager:(id)aManager;
- (void)purgeObjects;
- (void)prepareToPurgeObjects;
- (id)invocation;
- (id)init;
- (id)initWithObjectList:(id)aList invocation:(id)aInvocation;
- (void)dealloc;
@end

@interface BTUndoManagerCoreProxy : NSProxy
{
    NSUndoManager *_undoManager;
    id _target;
}
+ (id)undoManagerCoreProxyWithUndoManager:(id)aManager target:(id)aTarget;
- (void)forwardInvocation:(NSInvocation *)aInvocation;
- (id)objectCashesInvalidationListFromInvocation:(id)aInvocation;
- (id)methodSignatureForSelector:(SEL)aSelector;
- (id)init;
- (id)initWithUndoManager:(id)aManager target:(id)aTarget;
- (void)dealloc;
@end

@interface NSObject (BTUndoManagerCoreProxySupport)
- (void)BTUndoManagerCoreProxySupport_executeUndoOperationWithObjectWrapper:(id)aWrapper;
@end

@interface NSUndoManager (BTExtensions)
- (id)BT_prepareWithInvocationTarget:(id)aTarget;
- (void)BT_registerUndoWithTarget:(id)aTarget selector:(SEL)aSelector object:(id)aObject;
@end

