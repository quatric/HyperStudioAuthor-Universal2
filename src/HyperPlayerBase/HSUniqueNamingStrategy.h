#import "HyperPlayerBasePrefix.h"


@interface HSUniqueNamingStrategy : NSObject <HSUniqueNaming, NSObject>
{
    NSCharacterSet *_digitCharacterSet;
}
+ (id)defaultNamingStrategy;
- (id)uniqueName:(id)aName step:(NSUInteger)aStep uniqueSeparator:(id)aSeparator;
- (id)digitCharacterSet;
- (void)dealloc;
- (id)init;
@end

