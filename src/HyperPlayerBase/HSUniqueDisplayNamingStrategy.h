#import "HyperPlayerBasePrefix.h"


@interface HSUniqueDisplayNamingStrategy : NSObject <HSUniqueNaming, NSObject>
{
}
+ (id)defaultNamingStrategy;
- (id)uniqueName:(id)aName step:(NSUInteger)aStep uniqueSeparator:(id)aSeparator;
- (void)dealloc;
- (id)init;
@end

