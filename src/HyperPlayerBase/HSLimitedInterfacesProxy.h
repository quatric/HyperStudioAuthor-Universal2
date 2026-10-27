#import "HyperPlayerBasePrefix.h"


@interface HSLimitedInterfacesProxy : NSObject
{
    id _hyperObject;
    NSSet *_allowedInterfaces;
}
- (NSUInteger)hyperIdentifier;
- (id)queryHyperInterface:(id)aInterface;
- (id)hyperObject;
- (void)dealloc;
- (id)initWithHyperObject:(id)aObject interfaces:(id)aInterfaces;
@end

