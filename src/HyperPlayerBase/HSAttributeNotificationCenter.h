#import "HyperPlayerBasePrefix.h"


@interface HSAttributeNotificationCenter : NSObject
{
    struct __CFDictionary *_objectToAttributeChangesMap;
}
+ (id)defaultCenter;
- (void)notifyChange:(NSInteger)aChange ofAttributeSet:(id)aSet ofObject:(id)aObject withUserInfoInvocation:(id)aInvocation;
- (void)notifyChange:(NSInteger)aChange ofAttribute:(id)aAttribute ofObject:(id)aObject withUserInfoInvocation:(id)aInvocation;
- (void)notifyChange:(NSInteger)aChange ofAttributeSet:(id)aSet ofObject:(id)aObject withUserInfo:(id)aInfo;
- (void)notifyChange:(NSInteger)aChange ofAttribute:(id)aAttribute ofObject:(id)aObject withUserInfo:(id)aInfo;
- (void)postAttributeChangeNotification:(id)aNotification;
- (void)HSAttributeNotificationCenter_gatherObserverPriorityRecordsIntoArray:(id *)aArray forAttributeChangeNotification:(id)aNotification object:(id)aObject withAttributeHierarchySet:(id *)aSet;
- (void)removeObserver:(id)aObserver;
- (void)removeObserver:(id)aObserver selector:(SEL)aSelector;
- (void)removeObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributesOfHyperInterfaces:(id *)aInterfaces ofObject:(id)aObject;
- (void)removeObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributesOfHyperInterface:(id)aInterface ofObject:(id)aObject;
- (void)removeObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributesFromSet:(id)aSet ofObject:(id)aObject;
- (void)removeObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributes:(id *)aAttributes ofObject:(id)aObject;
- (void)removeObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttribute:(id)aAttribute ofObject:(id)aObject;
- (void)HSAttributeNotificationCenter_removeObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributes:(id *)aAttributes ofObject:(id)aObject;
- (void)addObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributesOfHyperInterfaces:(id *)aInterfaces ofObject:(id)aObject withPriority:(CGFloat)aPriority;
- (void)addObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributesOfHyperInterface:(id)aInterface ofObject:(id)aObject withPriority:(CGFloat)aPriority;
- (void)addObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributesFromSet:(id)aSet ofObject:(id)aObject withPriority:(CGFloat)aPriority;
- (void)addObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributes:(id *)aAttributes ofObject:(id)aObject withPriority:(CGFloat)aPriority;
- (void)addObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttribute:(id)aAttribute ofObject:(id)aObject withPriority:(CGFloat)aPriority;
- (void)HSAttributeNotificationCenter_addObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributes:(id *)aAttributes ofObject:(id)aObject withPriority:(CGFloat)aPriority;
- (void)HSAttributeNotificationCenter_addObserver:(id)aObserver selector:(SEL)aSelector ofChange:(NSInteger)aChange ofAttributes:(id *)aAttributes withPriority:(CGFloat)aPriority toAttributeChangeToAttributesMap:(struct __CFDictionary *)aMap;
- (void)HSAttributeNotificationCenter_addObserver:(id)aObserver selector:(SEL)aSelector ofAttribute:(id)aAttribute withPriority:(CGFloat)aPriority toAttributeToPrioritiesMap:(struct __CFDictionary *)aMap;
- (BOOL)hasObservers;
- (id)description;
- (void)dealloc;
@end

@interface HSAttributeNotificationCenter_HSObserverPriorityRecord : NSObject
{
    int _priority;
    struct __CFDictionary *_observerToSelectorsMap;
}
- (struct __CFDictionary *)observerToSelectorsMap;
- (NSInteger)priority;
- (id)description;
- (void)dealloc;
- (id)initWithPriority:(NSInteger)aPriority;
- (id)init;
@end

@interface HSAttributeNotificationCenter_HSObserverRecord : NSObject
{
    id _observer;
    SEL _selector;
}
- (void)invalidate;
- (SEL)selector;
- (id)observer;
- (id)description;
- (id)initWithObserver:(id)aObserver selector:(SEL)aSelector;
- (id)init;
@end

@interface HSAttributeNotification : NSObject
{
    int _attributeChange;
    NSEProtocolSet *_attributeProtocolSet;
    id _object;
    NSDictionary *_userInfo;
    NSInvocation *_userInfoInvocation;
}
+ (id)notificationWithChange:(NSInteger)aChange attributeSet:(id)aSet object:(id)aObject userInfoInvocation:(id)aInvocation;
+ (id)notificationWithChange:(NSInteger)aChange attributeSet:(id)aSet object:(id)aObject userInfo:(id)aInfo;
+ (id)notificationWithChange:(NSInteger)aChange attribute:(id)aAttribute object:(id)aObject userInfoInvocation:(id)aInvocation;
+ (id)notificationWithChange:(NSInteger)aChange attribute:(id)aAttribute object:(id)aObject userInfo:(id)aInfo;
- (id)description;
- (id)HSAttributeNotification_attributeChangeString;
- (id)userInfoIfCreated;
- (id)userInfo;
- (id)object;
- (id)attributeProtocolSet;
- (NSInteger)attributeChange;
- (id)notificationWithChange:(NSInteger)aChange attributeSet:(id)aSet object:(id)aObject;
- (id)notificationWithObject:(id)aObject;
- (id)notificationWithChange:(NSInteger)aChange;
- (void)dealloc;
- (id)init;
- (id)initWithChange:(NSInteger)aChange attributeSet:(id)aSet object:(id)aObject userInfoInvocation:(id)aInvocation;
- (id)initWithChange:(NSInteger)aChange attributeSet:(id)aSet object:(id)aObject userInfo:(id)aInfo;
- (id)initWithChange:(NSInteger)aChange attribute:(id)aAttribute object:(id)aObject userInfoInvocation:(id)aInvocation;
- (id)initWithChange:(NSInteger)aChange attribute:(id)aAttribute object:(id)aObject userInfo:(id)aInfo;
@end

