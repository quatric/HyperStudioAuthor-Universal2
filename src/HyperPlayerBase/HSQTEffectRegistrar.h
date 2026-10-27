#import "HyperPlayerBasePrefix.h"


@interface HSQTEffectRegistrar : NSObject
{
}
+ (void)registerObjects;
+ (void)load;
- (id)objectWithName:(id)aName;
@end

