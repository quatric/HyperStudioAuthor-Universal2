#import "NSObject+HyperObject.h"
@implementation NSObject (HyperObject)
- (id)implementationForHyperObject:(id)aObject
{
    return [HSHyperImplementationProxy proxyWithImplementation:self forObject:aObject];
}
- (NSUInteger)hyperIdentifier
{
    return (NSUInteger)self;
}
- (id)hyperObject
{
    return self;
}
- (BOOL)implementsHyperInterface:(id)aInterface
{
    return [self queryHyperInterface:aInterface] != nil;
}
// Itself when it conforms; otherwise its hyper object's answer (when that's
// another object).
- (id)queryHyperInterface:(id)aInterface
{
    if ([self conformsToProtocol:aInterface])
        return self;
    id hyperObject = [self hyperObject];
    if (hyperObject == self)
        return nil;
    return [hyperObject queryHyperInterface:aInterface];
}
@end
