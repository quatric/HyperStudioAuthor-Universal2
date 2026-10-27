#import "HSProxyContainer_HSProxiedObjectEnumerator.h"
// Enumerates the objects behind the weak proxies in a collection (each
// proxy's -object), skipping the ones that have gone away.
@implementation HSProxyContainer_HSProxiedObjectEnumerator
- (id)allObjects
{
    if (_proxyEnumerator == nil)
        return [NSArray array];
    id objects = [_proxyEnumerator allHyperProxiedObjects];
    [_proxyEnumerator release];
    _proxyEnumerator = nil;
    return objects;
}
- (id)nextObject
{
    id object = [_proxyEnumerator nextHyperProxiedObject];
    if (object == nil) {
        [_proxyEnumerator release];
        _proxyEnumerator = nil;
    }
    return object;
}
- (void)dealloc
{
    [_proxyEnumerator release];
    [super dealloc];
}
- (id)initWithProxyEnumerator:(id)aEnumerator
{
    self = [super init];
    if (self != nil)
        _proxyEnumerator = [aEnumerator retain];
    return self;
}
- (id)init
{
    return [self initWithProxyEnumerator:nil];
}
@end
@implementation NSDictionary (HSProxyContainer)
- (id)allHyperProxiedObjects
{
    return [[self objectEnumerator] allHyperProxiedObjects];
}
- (id)hyperProxiedObjectEnumerator
{
    return [[[HSProxyContainer_HSProxiedObjectEnumerator alloc] initWithProxyEnumerator:[self objectEnumerator]] autorelease];
}
@end
@implementation NSSet (HSProxyContainer)
- (id)allHyperProxiedObjects
{
    return [[self objectEnumerator] allHyperProxiedObjects];
}
- (id)hyperProxiedObjectEnumerator
{
    return [[[HSProxyContainer_HSProxiedObjectEnumerator alloc] initWithProxyEnumerator:[self objectEnumerator]] autorelease];
}
@end
@implementation NSArray (HSProxyContainer)
- (id)allHyperProxiedObjects
{
    return [[self objectEnumerator] allHyperProxiedObjects];
}
- (id)hyperProxiedObjectEnumerator
{
    return [[[HSProxyContainer_HSProxiedObjectEnumerator alloc] initWithProxyEnumerator:[self objectEnumerator]] autorelease];
}
@end
@implementation NSEnumerator (HSProxyContainer)
- (id)allHyperProxiedObjects
{
    NSMutableArray *objects = [NSMutableArray array];
    id proxy;
    while ((proxy = [self nextObject]) != nil) {
        id object = [proxy object];
        if (object != nil)
            [objects addObject:object];
    }
    return [[objects copy] autorelease];
}
- (id)nextHyperProxiedObject
{
    id proxy;
    while ((proxy = [self nextObject]) != nil) {
        id object = [proxy object];
        if (object != nil)
            return object;
    }
    return nil;
}
@end
