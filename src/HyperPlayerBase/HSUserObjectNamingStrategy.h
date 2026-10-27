#import "HyperPlayerBasePrefix.h"


@interface HSUserObjectNamingStrategy : NSObject
{
}
+ (id)defaultNamingStrategy;
- (BOOL)isAcceptableObjectName:(id)aName;
- (id)acceptableObjectName:(id)aName;
- (BOOL)isAcceptableObjectName:(id)aName correctName:(id *)aName2;
- (void)dealloc;
- (id)init;
@end

