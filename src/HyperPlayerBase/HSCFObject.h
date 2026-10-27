#import "HyperPlayerBasePrefix.h"


@interface HSCFObject : NSObject
{
    void *_CFObject;
}
+ (id)wrapperForCFObject:(void *)aObject;
+ (void *)autoreleasedCFObject:(void *)aObject;
- (void *)CFObject;
- (void)dealloc;
- (id)initWithCFObject:(void *)aObject;
@end

