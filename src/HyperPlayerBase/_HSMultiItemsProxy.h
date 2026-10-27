#import "HyperPlayerBasePrefix.h"


@interface _HSMultiItemsProxy : NSObject
{
    BOOL _lastAccessDidReturnMultiValue;
    BOOL _calculated;
    BOOL _returnsMultipleObjectsProxyOnlyForHyperInterfaces;
    NSMutableArray *_returnValues;
    NSMutableArray *_hyperInstances;
}
+ (id)proxyForAnyItemsWithStrictReturnValueBehavior:(id)aBehavior;
+ (id)proxyForAnyItems:(id)aItems;
+ (id)proxyForAllItemsWithStrictReturnValueBehavior:(id)aBehavior;
+ (id)proxyForAllItems:(id)aItems;
- (id)hyperAnyProxy;
- (id)hyperAllProxy;
- (BOOL)isHyperAllProxy;
- (void)forwardInvocation:(id)aInvocation;
- (id)methodSignatureForSelector:(SEL)aSelector;
- (void)hyperInstancesInvokeInvocation:(id)aInvocation;
- (id)hyperInstancesMethodSignatureForSelector:(SEL)aSelector;
- (id)hyperInstances;
- (void)sortHyperInterfacesUsingSelector:(SEL)aSelector;
- (NSUInteger)countOfAllHyperInterfaces;
- (id)allHyperInterfaces;
- (id)hyperReturnValues;
- (BOOL)lastHyperAccessDidReturnMultipleValues;
- (BOOL)returnsMultipleObjectsProxyOnlyForHyperInterfaces;
- (BOOL)isHyperProxy;
- (void)dealloc;
- (id)initWithProvider:(id)aProvider;
- (id)initWithProvider:(id)aProvider strictReturnValueBehavior:(BOOL)aBehavior;
@end

@interface _HSAnyItemsProxy : _HSMultiItemsProxy
{
}
- (BOOL)isHyperAllProxy;
- (id)queryHyperInterface:(id)aInterface;
@end

@interface _HSAllItemsProxy : _HSMultiItemsProxy
{
}
- (BOOL)isHyperAllProxy;
- (id)queryHyperInterface:(id)aInterface;
@end

@interface NSObject (HSMultiProxy)
- (id)hyperAnyProxy;
- (id)hyperAllProxy;
- (BOOL)isHyperAllProxy;
- (void)sortHyperInterfacesUsingSelector:(SEL)aSelector;
- (NSUInteger)countOfAllHyperInterfaces;
- (id)allHyperInterfaces;
- (BOOL)lastHyperAccessDidReturnMultipleValues;
- (id)hyperReturnValues;
- (BOOL)isHyperProxy;
@end

@interface NSObject (HSCollectionExtras)
- (id)hyperObjectForAnyInterfacesWithStrictReturnValueBehavior;
- (id)hyperObjectForAnyInterfaces;
- (id)hyperObjectForAllInterfacesWithStrictReturnValueBehavior;
- (id)hyperObjectForAllInterfaces;
- (id)queryHyperInterfaceForAnyObjects:(id)aObjects;
- (id)queryHyperInterfaceForAllObjects:(id)aObjects;
@end

@interface NSObject (HSCollection)
- (id)anyHyperObjects;
- (BOOL)implementsAnyHyperInterfaces:(id)aInterfaces;
- (id)queryAnyHyperInterfaces:(id)aInterfaces;
- (id)allHyperObjects;
- (id)queryAllHyperInterfaces:(id)aInterfaces;
@end

@interface NSSet (HSAnyObject)
- (NSUInteger)countOfAllHyperInstances;
- (id)allHyperInstances;
- (id)anyHyperInstance;
@end

@interface NSArray (HSAnyObject)
- (NSUInteger)countOfAllHyperInstances;
- (id)allHyperInstances;
- (id)anyHyperInstance;
@end

