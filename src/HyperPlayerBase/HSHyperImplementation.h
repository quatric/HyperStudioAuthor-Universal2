#import "HyperPlayerBasePrefix.h"


@interface HSHyperImplementation : NSObject
{
    id _hyperObject;
}
- (id)implementationForHyperObject:(id)aObject;
- (id)hyperObject;
- (void)dealloc;
- (id)initWithHyperObject:(id)aObject;
@end

