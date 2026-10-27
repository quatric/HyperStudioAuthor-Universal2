#import "HyperPlayerBasePrefix.h"


@interface NSObject (HyperObject)
- (id)implementationForHyperObject:(id)aObject;
- (NSUInteger)hyperIdentifier;
- (id)hyperObject;
- (BOOL)implementsHyperInterface:(id)aInterface;
- (id)queryHyperInterface:(id)aInterface;
@end

