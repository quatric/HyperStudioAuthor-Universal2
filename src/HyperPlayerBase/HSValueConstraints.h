#import "HyperPlayerBasePrefix.h"


@interface HSValueConstraints : NSObject
{
    NSDictionary *_constraintsDictionary;
}
+ (id)sharedConstraints;
- (id)constraintForKey:(id)aKey;
- (id)constraintsDictionary;
- (void)dealloc;
@end

@interface NSObject (HSValueConstraints)
- (id)hyperConstraintValue:(id)aValue forAttribute:(SEL)aAttribute;
@end

