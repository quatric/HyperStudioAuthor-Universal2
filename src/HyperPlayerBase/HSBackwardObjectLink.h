#import "HyperPlayerBasePrefix.h"


@interface HSBackwardObjectLink : NSObject
{
    id<HSBackwardReferenceCounting> _object;
}
+ (id)linkToObject:(id)aObject;
- (NSUInteger)hash;
- (BOOL)isEqual:(id)aEqual;
- (id)object;
- (void)dealloc;
- (id)init;
- (id)initWithObject:(id)aObject;
@end

