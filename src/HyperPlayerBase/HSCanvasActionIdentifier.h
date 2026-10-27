#import "HyperPlayerBasePrefix.h"


@interface HSCanvasActionIdentifier : NSObject <NSCopying>
{
    SEL _selector;
    unsigned int _hash;
}
+ (id)identifierWithActionSelector:(SEL)aSelector;
- (id)copyWithZone:(NSZone *)aZone;
- (NSUInteger)hash;
- (BOOL)isEqual:(id)aEqual;
- (SEL)selector;
- (id)init;
- (id)initWithActionSelector:(SEL)aSelector;
@end

