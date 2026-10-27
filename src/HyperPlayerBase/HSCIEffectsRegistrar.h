#import "HyperPlayerBasePrefix.h"


@interface HSCIEffectsRegistrar : NSObject
{
}
+ (void)registerObjects;
+ (void)load;
- (id)objectWithName:(id)aName;
@end

