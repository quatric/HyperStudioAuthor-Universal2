#import "_HSMultiItemsProxy.h"
#import "NSMutableArray+EXMutableArray.h"

// A proxy that forwards every message to a collection of hyper objects and
// records their return values. Object returns that differ between the items
// come back as a new "all" proxy over the returned objects.
@implementation _HSMultiItemsProxy

+ (id)proxyForAnyItemsWithStrictReturnValueBehavior:(id)aBehavior
{
    if ([aBehavior count] == 0)
        return nil;
    return [[[_HSAnyItemsProxy alloc] initWithProvider:aBehavior strictReturnValueBehavior:YES] autorelease];
}

+ (id)proxyForAnyItems:(id)aItems
{
    if ([aItems count] == 0)
        return nil;
    return [[[_HSAnyItemsProxy alloc] initWithProvider:aItems] autorelease];
}

+ (id)proxyForAllItemsWithStrictReturnValueBehavior:(id)aBehavior
{
    if ([aBehavior count] == 0)
        return nil;
    return [[[_HSAllItemsProxy alloc] initWithProvider:aBehavior strictReturnValueBehavior:YES] autorelease];
}

+ (id)proxyForAllItems:(id)aItems
{
    if ([aItems count] == 0)
        return nil;
    return [[[_HSAllItemsProxy alloc] initWithProvider:aItems] autorelease];
}

- (id)hyperAnyProxy
{
    if ([self isHyperAllProxy])
        return [_HSMultiItemsProxy proxyForAnyItems:[self hyperInstances]];
    return self;
}

- (id)hyperAllProxy
{
    if (![self isHyperAllProxy])
        return [_HSMultiItemsProxy proxyForAllItems:[self hyperInstances]];
    return self;
}

// Abstract; the any/all subclasses answer.
- (BOOL)isHyperAllProxy
{
    [self doesNotRecognizeSelector:_cmd];
    return NO;
}

- (void)forwardInvocation:(id)aInvocation
{
    [self hyperInstancesInvokeInvocation:aInvocation];
}

- (id)methodSignatureForSelector:(SEL)aSelector
{
    NSMethodSignature *signature = [super methodSignatureForSelector:aSelector];
    if (signature == nil)
        signature = [self hyperInstancesMethodSignatureForSelector:aSelector];
    return signature;
}

// Objects are recorded as is (nil as NSNull), other values as NSValues.
// An object return is replaced by an "all" proxy over the returned objects:
// when they differ, or (in strict mode) whenever they are hyper objects.
- (void)hyperInstancesInvokeInvocation:(id)aInvocation
{
    NSEnumerator *enumerator = [[self hyperInstances] objectEnumerator];
    NSMethodSignature *signature = [aInvocation methodSignature];
    const char *returnType = [signature methodReturnType];
    BOOL returnsVoid = strcmp(returnType, "v") == 0;
    BOOL returnsObject = strcmp(returnType, "@") == 0;
    [_returnValues removeAllObjects];
    _calculated = NO;
    void *buffer = NULL;
    id instance;
    while ((instance = [enumerator nextObject]) != nil) {
        [aInvocation invokeWithTarget:instance];
        if (returnsVoid)
            continue;
        if (buffer == NULL)
            buffer = malloc([signature methodReturnLength]);
        [aInvocation getReturnValue:buffer];
        if (returnsObject) {
            id value = *(id *)buffer;
            [_returnValues addObject:(value != nil ? value : [NSNull null])];
        } else {
            [_returnValues addObject:[NSValue valueWithBytes:buffer objCType:returnType]];
        }
    }
    if (returnsObject) {
        if (!_returnsMultipleObjectsProxyOnlyForHyperInterfaces) {
            if ([self lastHyperAccessDidReturnMultipleValues]) {
                id proxy = [_HSMultiItemsProxy proxyForAllItems:_returnValues];
                [(NSInvocation *)aInvocation setReturnValue:&proxy];
            }
        } else {
            id proxy = [_HSMultiItemsProxy proxyForAllItems:_returnValues];
            if ([proxy queryHyperInterface:@protocol(HyperInterface)] != nil)
                [(NSInvocation *)aInvocation setReturnValue:&proxy];
        }
    }
    free(buffer);
}

- (id)hyperInstancesMethodSignatureForSelector:(SEL)aSelector
{
    return [[[self hyperInstances] anyHyperInstance] methodSignatureForSelector:aSelector];
}

- (id)hyperInstances
{
    return _hyperInstances;
}

- (void)sortHyperInterfacesUsingSelector:(SEL)aSelector
{
    [[self hyperInstances] sortUsingSelector:aSelector];
}

- (NSUInteger)countOfAllHyperInterfaces
{
    return [[self hyperInstances] countOfAllHyperInstances];
}

- (id)allHyperInterfaces
{
    return [[self hyperInstances] allHyperInstances];
}

- (id)hyperReturnValues
{
    if ([_returnValues count] == 0)
        return nil;
    return _returnValues;
}

// Compares the recorded values with the first one. Floating-point values
// count as equal within a relative tolerance of 0.0005.
- (BOOL)lastHyperAccessDidReturnMultipleValues
{
    if (_calculated)
        return _lastAccessDidReturnMultiValue;
    NSEnumerator *enumerator = [_returnValues objectEnumerator];
    id first = [enumerator nextObject];
    _lastAccessDidReturnMultiValue = NO;
    BOOL compareObjects = YES;
    BOOL isFloat = YES;
    if ([first isKindOfClass:[NSValue class]]) {
        const char *type = [first objCType];
        isFloat = strcmp(type, "d") != 0;
        compareObjects = isFloat && strcmp(type, "f") != 0;
    }
    id value;
    while ((value = [enumerator nextObject]) != nil && !_lastAccessDidReturnMultiValue) {
        BOOL differs;
        if (compareObjects) {
            differs = ![first isEqual:value];
        } else {
            float a = 0.0f;
            float b = 0.0f;
            if (isFloat) {
                [first getValue:&a];
                [value getValue:&b];
            } else {
                double da = 0.0;
                double db = 0.0;
                [first getValue:&da];
                [value getValue:&db];
                a = (float)da;
                b = (float)db;
            }
            float scaleA = a != 0.0f ? fabsf(a) : 1.0f;
            float scaleB = b != 0.0f ? fabsf(b) : 1.0f;
            float scale = scaleB <= scaleA ? scaleA : scaleB;
            differs = scale * 0.0005f < fabsf(a - b);
        }
        _lastAccessDidReturnMultiValue = differs;
    }
    _calculated = YES;
    return _lastAccessDidReturnMultiValue;
}

- (BOOL)returnsMultipleObjectsProxyOnlyForHyperInterfaces
{
    return _returnsMultipleObjectsProxyOnlyForHyperInterfaces;
}

- (BOOL)isHyperProxy
{
    return YES;
}

- (void)dealloc
{
    [_hyperInstances release];
    [_returnValues release];
    [super dealloc];
}

- (id)initWithProvider:(id)aProvider
{
    return [self initWithProvider:aProvider strictReturnValueBehavior:NO];
}

- (id)initWithProvider:(id)aProvider strictReturnValueBehavior:(BOOL)aBehavior
{
    self = [super init];
    if (self != nil) {
        _hyperInstances = [[NSMutableArray alloc] initWithArray:[aProvider allHyperInstances]];
        _returnValues = [[NSMutableArray alloc] init];
        _returnsMultipleObjectsProxyOnlyForHyperInterfaces = aBehavior;
    }
    return self;
}

@end

// Answers for the items implementing an interface.
@implementation _HSAnyItemsProxy

- (BOOL)isHyperAllProxy
{
    return NO;
}

- (id)queryHyperInterface:(id)aInterface
{
    NSArray *instances = [[self hyperInstances] queryAnyHyperInterfaces:aInterface];
    if ([instances count] == 0)
        return nil;
    return [[[_HSAnyItemsProxy alloc] initWithProvider:instances strictReturnValueBehavior:[self returnsMultipleObjectsProxyOnlyForHyperInterfaces]] autorelease];
}

@end

// Answers only when every item implements an interface.
@implementation _HSAllItemsProxy

- (BOOL)isHyperAllProxy
{
    return YES;
}

- (id)queryHyperInterface:(id)aInterface
{
    NSArray *instances = [[self hyperInstances] queryAllHyperInterfaces:aInterface];
    if ([instances count] == 0)
        return nil;
    return [[[_HSAllItemsProxy alloc] initWithProvider:instances strictReturnValueBehavior:[self returnsMultipleObjectsProxyOnlyForHyperInterfaces]] autorelease];
}

@end

// A plain object acts as a proxy over itself.
@implementation NSObject (HSMultiProxy)

- (id)hyperAnyProxy
{
    return self;
}

- (id)hyperAllProxy
{
    return self;
}

- (BOOL)isHyperAllProxy
{
    return NO;
}

- (void)sortHyperInterfacesUsingSelector:(SEL)aSelector
{
}

- (NSUInteger)countOfAllHyperInterfaces
{
    return 1;
}

- (id)allHyperInterfaces
{
    return [NSArray arrayWithObject:self];
}

- (BOOL)lastHyperAccessDidReturnMultipleValues
{
    return NO;
}

- (id)hyperReturnValues
{
    return nil;
}

- (BOOL)isHyperProxy
{
    return NO;
}

@end

@implementation NSObject (HSCollectionExtras)

- (id)hyperObjectForAnyInterfacesWithStrictReturnValueBehavior
{
    return [_HSMultiItemsProxy proxyForAllItemsWithStrictReturnValueBehavior:[self anyHyperObjects]];
}

- (id)hyperObjectForAnyInterfaces
{
    return [_HSMultiItemsProxy proxyForAllItems:[self anyHyperObjects]];
}

- (id)hyperObjectForAllInterfacesWithStrictReturnValueBehavior
{
    return [_HSMultiItemsProxy proxyForAllItemsWithStrictReturnValueBehavior:[self allHyperObjects]];
}

- (id)hyperObjectForAllInterfaces
{
    return [_HSMultiItemsProxy proxyForAllItems:[self allHyperObjects]];
}

- (id)queryHyperInterfaceForAnyObjects:(id)aObjects
{
    return [[_HSMultiItemsProxy proxyForAnyItems:self] queryHyperInterface:aObjects];
}

- (id)queryHyperInterfaceForAllObjects:(id)aObjects
{
    return [[_HSMultiItemsProxy proxyForAllItems:self] queryHyperInterface:aObjects];
}

@end

// Collection helpers for arrays and sets; the result has the receiver's kind.
static id HSCollectionWithCapacityLike(id aCollection)
{
    if ([aCollection isKindOfClass:[NSSet class]])
        return [NSMutableSet setWithCapacity:[aCollection count]];
    return [NSMutableArray arrayWithCapacity:[aCollection count]];
}

@implementation NSObject (HSCollection)

- (id)anyHyperObjects
{
    NSEnumerator *enumerator = [(id)self objectEnumerator];
    id collection = HSCollectionWithCapacityLike(self);
    id item;
    while ((item = [enumerator nextObject]) != nil) {
        id object = [item hyperObject];
        if (object != nil)
            [collection addObject:object];
    }
    return collection;
}

- (BOOL)implementsAnyHyperInterfaces:(id)aInterfaces
{
    NSEnumerator *enumerator = [(id)self objectEnumerator];
    id item;
    while ((item = [enumerator nextObject]) != nil) {
        if ([item implementsHyperInterface:aInterfaces])
            return YES;
    }
    return NO;
}

- (id)queryAnyHyperInterfaces:(id)aInterfaces
{
    NSEnumerator *enumerator = [(id)self objectEnumerator];
    id collection = HSCollectionWithCapacityLike(self);
    id item;
    while ((item = [enumerator nextObject]) != nil) {
        id object = [item queryHyperInterface:aInterfaces];
        if (object != nil)
            [collection addObject:object];
    }
    return collection;
}

// nil unless every item is a hyper object.
- (id)allHyperObjects
{
    NSEnumerator *enumerator = [(id)self objectEnumerator];
    id collection = HSCollectionWithCapacityLike(self);
    id item;
    while ((item = [enumerator nextObject]) != nil) {
        id object = [item hyperObject];
        if (object == nil)
            return nil;
        [collection addObject:object];
    }
    return collection;
}

// nil unless every item implements the interface.
- (id)queryAllHyperInterfaces:(id)aInterfaces
{
    NSEnumerator *enumerator = [(id)self objectEnumerator];
    id collection = HSCollectionWithCapacityLike(self);
    id item;
    while ((item = [enumerator nextObject]) != nil) {
        id object = [item queryHyperInterface:aInterfaces];
        if (object == nil)
            return nil;
        [collection addObject:object];
    }
    return collection;
}

@end

@implementation NSSet (HSAnyObject)

- (NSUInteger)countOfAllHyperInstances
{
    return [self count];
}

- (id)allHyperInstances
{
    return [self allObjects];
}

- (id)anyHyperInstance
{
    return [self anyObject];
}

@end

@implementation NSArray (HSAnyObject)

- (NSUInteger)countOfAllHyperInstances
{
    return [self count];
}

- (id)allHyperInstances
{
    return self;
}

- (id)anyHyperInstance
{
    return [(NSMutableArray *)self extraFirstObject];
}

@end
