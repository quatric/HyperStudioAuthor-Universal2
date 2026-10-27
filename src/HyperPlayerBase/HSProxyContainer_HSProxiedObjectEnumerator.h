#import "HyperPlayerBasePrefix.h"


@interface HSProxyContainer_HSProxiedObjectEnumerator : NSEnumerator
{
    NSEnumerator *_proxyEnumerator;
}
- (id)allObjects;
- (id)nextObject;
- (void)dealloc;
- (id)initWithProxyEnumerator:(id)aEnumerator;
- (id)init;
@end

@interface NSDictionary (HSProxyContainer)
- (id)allHyperProxiedObjects;
- (id)hyperProxiedObjectEnumerator;
@end

@interface NSSet (HSProxyContainer)
- (id)allHyperProxiedObjects;
- (id)hyperProxiedObjectEnumerator;
@end

@interface NSArray (HSProxyContainer)
- (id)allHyperProxiedObjects;
- (id)hyperProxiedObjectEnumerator;
@end

@interface NSEnumerator (HSProxyContainer)
- (id)allHyperProxiedObjects;
- (id)nextHyperProxiedObject;
@end

